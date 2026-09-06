module ducklake_mo

  ! DuckLake lifecycle helpers built on duckdb_ty.
  !
  ! DuckLake stores data as ordinary parquet files and keeps the file list, schema and
  ! snapshot history in a SQL catalog. Every operation below is plain SQL, so duckdb_ty
  ! already speaks DuckLake without this module. What this module adds is the *ordering*
  ! that a DuckDB-backed catalog requires, because getting it wrong fails quietly.
  !
  ! THE PROBLEM THIS SOLVES
  !
  ! A DuckDB database file is locked to a single process. When the catalog is a .ducklake
  ! file, a reader in another process cannot attach at all while a writer holds it -- not
  ! even READ_ONLY; it fails with "Could not set lock on file". That rules out the obvious
  ! topology of "producer writes, consumers read the same catalog".
  !
  ! The fix is to separate the catalog the producer writes from the catalog consumers read:
  !
  !     producer  ->  catalog (live)        ->  publish  ->  catalog.published (copy)
  !     consumers ->  catalog.published (READ_ONLY)
  !
  ! Data files are immutable, so a published catalog is always a valid, self-consistent
  ! snapshot: consumers see the state as of the last publish and never observe a partial
  ! write. Publishing is a copy followed by an atomic rename, so a consumer either sees the
  ! old catalog or the new one, never a half-written file.
  !
  ! ORDER OF OPERATIONS (all four rules were established by measurement; each failure below
  ! was observed, not theorised)
  !
  !   1. ONE WRITER. The live catalog admits a single process, and maintenance is a writer
  !      too. A producer and a concurrent merge collide with "Conflicting lock is held".
  !      Use lock()/unlock(), or serialise externally.
  !
  !      lock() refuses for two reasons that look identical from the outside but need
  !      OPPOSITE responses: contention (retry; the store is healthy) and an unopenable lock
  !      file (retrying can never help). Ask for the reason and say which one it was:
  !
  !        call lake%lock( ok, reason = why, errmsg = why_text )
  !        if ( .not. ok ) then
  !          if ( why == LOCK_HELD ) then
  !            ! another writer is working -- back off, come back next cycle
  !          else
  !            ! configuration or permission fault; log why_text and stop pretending
  !          end if
  !        end if
  !
  !      Reporting both as one message is how a store goes stale for a day while every log
  !      line says "another writer holds it" and no such writer exists. Both arguments are
  !      optional, so the two-argument form stays valid.
  !
  !   2. COMMIT ONCE. Parallel workers must not each open the catalog. Let them write plain
  !      parquet to a staging directory, then have ONE process call insert_parquet() inside
  !      a single transaction. The cycle then commits atomically or not at all.
  !
  !   3. PUBLISH BEFORE RECLAIMING. reclaim() deletes every file the live catalog no longer
  !      references. A consumer still reading through the previous published catalog needs
  !      some of them and dies with "Cannot open file ... No such file or directory".
  !      Always merge_files() -> publish() -> wait -> reclaim().
  !
  !   4. THE WAIT IS REAL TIME. ducklake_expire_snapshots(older_than => ...) governs
  !      snapshots, not file lifetime, so it cannot protect a running query. The caller must
  !      wait longer than its slowest reader between publish() and reclaim(). This module
  !      deliberately does not sleep -- blocking a library for minutes is the caller's
  !      decision, and splitting merge_files() from reclaim() makes the gap explicit.
  !
  ! Note that reclaim() uses cleanup_all. Without it DuckLake frees nothing at all, so the
  ! store grows without bound; the safety comes from rule 3, not from omitting the flag.
  !
  ! TYPICAL PRODUCER
  !
  !     call lake%lock( ok )                                   ! rule 1
  !     call lake%attach( db )
  !     call lake%insert_parquet( db, 'tbl', '/staging/*.parquet' )   ! rule 2
  !     call lake%publish( db )
  !     call lake%detach( db )
  !     call lake%unlock()
  !
  ! TYPICAL CONSUMER
  !
  !     call lake%attach( db, read_only = .true. )             ! reads the published copy
  !
  ! TYPICAL MAINTENANCE
  !
  !     call lake%lock( ok ); call lake%attach( db )
  !     call lake%merge_files( db ); call lake%publish( db )
  !     call lake%detach( db ); call lake%unlock()
  !     ... caller waits longer than its slowest reader ...    ! rule 4
  !     call lake%lock( ok ); call lake%attach( db )
  !     call lake%reclaim( db ); call lake%publish( db )
  !     call lake%detach( db ); call lake%unlock()

  use duckdb_mo
  use, intrinsic :: iso_c_binding

  implicit none

  private
  public :: ducklake_ty
  public :: LOCK_ACQUIRED, LOCK_HELD, LOCK_UNOPENABLE, LOCK_ERROR

  ! Why lock() refused.
  !
  ! Reported through lock()'s optional `reason` argument. The two-argument form is unchanged,
  ! so existing callers keep compiling and behaving exactly as before.
  !
  ! The distinction matters because the two common failures need OPPOSITE responses, and a
  ! caller that cannot tell them apart will pick the wrong one:
  !
  !   LOCK_HELD       is transient. Someone really is writing. Back off and retry; the store
  !                   is fine and will advance on its own.
  !   LOCK_UNOPENABLE never clears by retrying. The path is wrong, the directory is missing,
  !                   the filesystem is read-only, or the process lacks permission. Retrying
  !                   forever looks exactly like LOCK_HELD from the outside, so an operator
  !                   hunting for the phantom writer never finds one -- while the store stops
  !                   advancing and every unit still reports success.
  !
  ! Reporting both as a bare .false. is what makes that indistinguishable, which is why the
  ! reason is offered here rather than left to the caller to guess.
  integer, parameter :: LOCK_ACQUIRED   = 0   ! the caller now holds the lock
  integer, parameter :: LOCK_HELD       = 1   ! another writer holds it -- back off and retry
  integer, parameter :: LOCK_UNOPENABLE = 2   ! the lock file could not be opened or created
  integer, parameter :: LOCK_ERROR      = 3   ! flock(2) failed for some other reason

  type ducklake_ty
    character(:), allocatable :: alias          ! schema name the lake is attached as
    character(:), allocatable :: catalog        ! live catalog file (producer only)
    character(:), allocatable :: published      ! published copy (consumers, READ_ONLY)
    character(:), allocatable :: data_path      ! directory holding the parquet data files
    integer                   :: stat = 0       ! non-zero after a failed operation
    integer(c_int)            :: lock_fd = -1   ! fd holding the kernel lock; -1 when unlocked
    logical                   :: locked = .false.

    character(:), allocatable :: lock_file

  contains
    procedure :: init
    procedure :: attach
    procedure :: detach
    procedure :: insert_parquet
    procedure :: publish
    procedure :: merge_files
    procedure :: reclaim
    procedure :: lock
    procedure :: unlock
  end type


  ! flock(2) via C. The lock belongs to the KERNEL and to the open file description, so it is
  ! released the instant the holder goes away -- normal exit, error stop, SIGKILL, OOM kill,
  ! container teardown, host reset. That is the entire point. An exclusive-create lock file
  ! cannot do this: nothing runs after SIGKILL to remove it, so the lock outlives its owner
  ! and every later writer is refused forever.
  !
  ! Linux/x86_64 values. Stable ABI rather than implementation detail, spelled out here
  ! because Fortran cannot include the C headers that define them.
  interface
    function c_open ( path, flags, mode ) bind(C, name = 'open') result ( fd )
      import :: c_int, c_char
      character(kind=c_char), intent(in) :: path(*)
      integer(c_int), value              :: flags, mode
      integer(c_int)                     :: fd
    end function c_open
    function c_flock ( fd, operation ) bind(C, name = 'flock') result ( r )
      import :: c_int
      integer(c_int), value :: fd, operation
      integer(c_int)        :: r
    end function c_flock
    function c_close ( fd ) bind(C, name = 'close') result ( r )
      import :: c_int
      integer(c_int), value :: fd
      integer(c_int)        :: r
    end function c_close
    function c_getpid ( ) bind(C, name = 'getpid') result ( p )
      import :: c_int
      integer(c_int) :: p
    end function c_getpid
    ! errno is a thread-local lvalue, not a plain global: glibc exposes it as a function
    ! returning its address. Reading it any other way gives another thread's value.
    function c_errno_location ( ) bind(C, name = '__errno_location') result ( p )
      import :: c_ptr
      type(c_ptr) :: p
    end function c_errno_location
    function c_strerror ( errnum ) bind(C, name = 'strerror') result ( s )
      import :: c_int, c_ptr
      integer(c_int), value :: errnum
      type(c_ptr)           :: s
    end function c_strerror
  end interface

  integer(c_int), parameter :: O_RDWR    = 2_c_int,  O_CREAT = 64_c_int
  integer(c_int), parameter :: LOCK_EX   = 2_c_int,  LOCK_NB = 4_c_int
  integer(c_int), parameter :: MODE_0644 = 420_c_int
  ! flock(LOCK_NB) reports "someone else holds it" as EAGAIN (== EWOULDBLOCK on Linux).
  ! Any other errno from flock is a real fault, not contention, and is reported as such.
  integer(c_int), parameter :: EAGAIN    = 11_c_int

  ! POSIX rename(2): atomic when both paths are on one filesystem, which is what makes a
  ! published catalog appear whole to a consumer. Used instead of shelling out to mv so the
  ! module keeps duckdb_mo as its only dependency.
  interface
    function c_rename ( oldpath, newpath ) bind( c, name = 'rename' ) result ( r )
      import :: c_char, c_int
      character(kind=c_char), intent(in) :: oldpath(*), newpath(*)
      integer(c_int)                     :: r
    end function c_rename
  end interface

contains

  ! catalog is the live catalog. published defaults to <catalog>.published, which is the
  ! file consumers attach; it is never written in place, only renamed over.
  subroutine init ( this, catalog, data_path, alias, published )
    class(ducklake_ty),     intent(inout) :: this
    character(*),           intent(in)    :: catalog
    character(*),           intent(in)    :: data_path
    character(*), optional, intent(in)    :: alias
    character(*), optional, intent(in)    :: published
    this%catalog   = trim( catalog )
    this%data_path = trim( data_path )
    if ( present( alias ) ) then
      this%alias = trim( alias )
    else
      this%alias = 'lake'
    end if
    if ( present( published ) ) then
      this%published = trim( published )
    else
      this%published = trim( catalog )//'.published'
    end if
    this%lock_file = trim( catalog )//'.lock'
    this%stat      = 0
  end subroutine init

  ! read_only attaches the PUBLISHED copy; anything else attaches the live catalog. A
  ! consumer must never attach the live catalog, or it will block the producer.
  !
  ! MIGRATE upgrades a catalog written by an older DuckLake to the format the loaded
  ! extension requires. Without it, attaching a catalog older than the extension fails with
  !
  !     Invalid Input Error: DuckLake catalog version mismatch: catalog version is 0.3,
  !     but the extension requires version 1.0.
  !
  ! and, because callers treat a failed attach as "skip this cycle" rather than a crash, the
  ! store then goes stale in silence: the producer keeps reporting success while nothing is
  ! written. A catalog that outlives an extension upgrade hits this, so any long-lived store
  ! eventually needs it.
  !
  ! It is OPT-IN, and deliberately not the default. Migration rewrites the catalog in place
  ! and is one-way: once upgraded, a process still linked against the older extension can no
  ! longer attach it. Turning it on silently for every caller would push that breakage onto
  ! whichever process happened to attach last. Migrating is a decision about the whole set of
  ! readers and writers, so the caller has to make it.
  !
  ! Ignored when read_only, since migration writes and the published copy is opened read-only;
  ! publish() propagates the upgraded catalog to consumers on the next cycle anyway.
  subroutine attach ( this, db, read_only, migrate )
    class(ducklake_ty), intent(inout) :: this
    class(duckdb_ty),   intent(inout) :: db
    logical, optional,  intent(in)    :: read_only
    logical, optional,  intent(in)    :: migrate
    character(:), allocatable         :: path, opts
    logical                           :: ro, mig
    ro = .false. ; mig = .false.
    if ( present( read_only ) ) ro  = read_only
    if ( present( migrate )   ) mig = migrate
    if ( ro ) then
      path = this%published
      opts = ", READ_ONLY"
    else
      path = this%catalog
      opts = ""
      if ( mig ) opts = ", AUTOMATIC_MIGRATION TRUE"
    end if
    call db%send( "INSTALL ducklake" )       ; call db%clear_result( )
    call db%send( "LOAD ducklake" )          ; call db%clear_result( )
    call db%send( "ATTACH 'ducklake:duckdb:"//path//"' AS "//this%alias// &
                  " (DATA_PATH '"//this%data_path//"'"//opts//")" )
    if ( db%stat /= 0 ) then
      this%stat = db%stat
      print *, '*** Error: Could not attach lake '//path
    end if
    call db%clear_result( )
  end subroutine attach

  subroutine detach ( this, db )
    class(ducklake_ty), intent(inout) :: this
    class(duckdb_ty),   intent(inout) :: db
    call db%send( "DETACH "//this%alias )
    call db%clear_result( )
  end subroutine detach

  ! Fan-in commit (rule 2): parallel workers stage plain parquet, one process folds the whole
  ! cycle in under a single transaction. glob may name one file or a wildcard.
  subroutine insert_parquet ( this, db, table, glob, columns )
    class(ducklake_ty),     intent(inout) :: this
    class(duckdb_ty),       intent(inout) :: db
    character(*),           intent(in)    :: table
    character(*),           intent(in)    :: glob
    character(*), optional, intent(in)    :: columns   ! defaults to '*'
    character(:), allocatable             :: cols
    if ( present( columns ) ) then
      cols = trim( columns )
    else
      cols = '*'
    end if
    call db%send( "BEGIN" ) ; call db%clear_result( )
    call db%send( "INSERT INTO "//this%alias//"."//trim(table)// &
                  " SELECT "//cols//" FROM read_parquet('"//trim(glob)//"', union_by_name=true)" )
    if ( db%stat /= 0 ) then
      this%stat = db%stat
      call db%clear_result( )
      call db%send( "ROLLBACK" ) ; call db%clear_result( )
      print *, '*** Error: Insert failed, transaction rolled back'
      return
    end if
    call db%clear_result( )
    call db%send( "COMMIT" ) ; call db%clear_result( )
  end subroutine insert_parquet

  ! Copy the live catalog aside and rename it over the published one. The rename is what
  ! makes the swap atomic; consumers never observe the copy in progress.
  subroutine publish ( this, db )
    class(ducklake_ty), intent(inout) :: this
    class(duckdb_ty),   intent(inout) :: db
    character(:), allocatable         :: tmp
    integer                           :: rc
    logical                           :: exists
    tmp = this%catalog//'.publishing'
    inquire ( file = tmp, exist = exists )
    if ( exists ) call delete_file( tmp )
    call db%send( "ATTACH '"//tmp//"' AS ducklake_publish_tmp" )
    if ( db%stat /= 0 ) then
      this%stat = db%stat ; call db%clear_result( )
      print *, '*** Error: Could not open publish target '//tmp
      return
    end if
    call db%clear_result( )
    call db%send( "COPY FROM DATABASE __ducklake_metadata_"//this%alias//" TO ducklake_publish_tmp" )
    if ( db%stat /= 0 ) this%stat = db%stat
    call db%clear_result( )
    call db%send( "DETACH ducklake_publish_tmp" ) ; call db%clear_result( )
    if ( this%stat /= 0 ) then
      print *, '*** Error: Could not copy catalog for publishing'
      return
    end if
    rc = c_rename( trim(tmp)//c_null_char, trim(this%published)//c_null_char )
    if ( rc /= 0 ) then
      this%stat = 1
      print *, '*** Error: Could not rename published catalog into place'
    end if
  end subroutine publish

  ! Combine small data files. Publish afterwards so consumers move onto the merged files
  ! BEFORE reclaim() is allowed to delete the originals (rule 3).
  subroutine merge_files ( this, db )
    class(ducklake_ty), intent(inout) :: this
    class(duckdb_ty),   intent(inout) :: db
    call db%send( "CALL ducklake_merge_adjacent_files('"//this%alias//"')" )
    if ( db%stat /= 0 ) then
      this%stat = db%stat
      print *, '*** Error: Could not merge data files'
    end if
    call db%clear_result( )
  end subroutine merge_files

  ! Delete superseded data files. ONLY safe once publish() has moved consumers onto the
  ! merged files AND the caller has waited longer than its slowest reader (rules 3 and 4).
  ! cleanup_all is required: without it DuckLake frees nothing and the store grows forever.
  subroutine reclaim ( this, db, retain_seconds )
    class(ducklake_ty), intent(inout) :: this
    class(duckdb_ty),   intent(inout) :: db
    integer, optional,  intent(in)    :: retain_seconds   ! snapshot history to keep
    integer                           :: keep
    character(32)                     :: buf
    keep = 0
    if ( present( retain_seconds ) ) keep = retain_seconds
    write ( buf, '(i0)' ) keep
    call db%send( "CALL ducklake_expire_snapshots('"//this%alias// &
                  "', older_than => now()::TIMESTAMP - INTERVAL "//trim(buf)//" SECOND)" )
    call db%clear_result( )
    call db%send( "CALL ducklake_cleanup_old_files('"//this%alias//"', cleanup_all => true)" )
    if ( db%stat /= 0 ) then
      this%stat = db%stat
      print *, '*** Error: Could not clean up old data files'
    end if
    call db%clear_result( )
  end subroutine reclaim

    ! Advisory single-writer mutex (rule 1). ok is .false. when another writer holds the lock
    ! -- callers should back off and retry rather than proceed.
    !
    ! The mutex is flock(2) on the lock file, NOT the existence of the file. That distinction
    ! is the whole design:
    !
    !   An exclusive-create lock file ( status='new' ) is released only by the code that
    !   removes it, so a holder that dies without reaching that code -- SIGKILL, OOM kill, a
    !   start-timeout, a container torn down, the host losing power -- leaves the file behind
    !   forever. Every later writer is then refused, permanently, while no process anywhere
    !   holds anything. Recovery needs a human to notice and delete a file, and until then the
    !   failure is silent: each run reports "another writer holds it" and exits successfully,
    !   so the store quietly stops advancing while every unit still looks healthy.
    !
    !   A kernel lock cannot leak this way. It lives on the open file description, so the
    !   kernel drops it when the last fd closes -- and process death closes fds no matter what
    !   killed the process. Nothing has to run in the dying process for the lock to clear.
    !
    ! unlock() deliberately LEAVES THE FILE IN PLACE. Do not "tidy up" by deleting it: unlink
    ! reopens the race this closes. A unlocks and unlinks while B has already opened the same
    ! path; B locks an unlinked inode while C creates a fresh file and locks that, and both
    ! believe they are the single writer. A stray empty lock file is not a leak -- its presence
    ! means nothing, only the kernel lock does.
    !
    ! PID is written into the file for humans only. It answers "who holds this?" during an
    ! incident and is never read back. It is deliberately NOT the mechanism: a PID is
    ! meaningless across PID namespaces, so a containerised reader testing whether the
    ! recorded PID is alive would be asking its own namespace about another namespace's
    ! number, and would either reclaim a live lock or trust a dead one forever.
    ! `reason` and `errmsg` are optional and purely diagnostic. Omitting both gives exactly
    ! the previous behaviour, so this is source-compatible with every existing caller.
    ! `errmsg` carries the failing call, the path and strerror(errno) -- the three things an
    ! operator needs and none of which a bare .false. can convey.
    subroutine lock ( this, ok, reason, errmsg )
      class(ducklake_ty), intent(inout)   :: this
      logical,            intent(out)     :: ok
      integer,      intent(out), optional :: reason
      character(*), intent(out), optional :: errmsg
      integer(c_int)                      :: fd, rc, err
      integer                             :: u, ios
      ok = .false.
      if ( present( reason ) ) reason = LOCK_ERROR
      if ( present( errmsg ) ) errmsg = ''
      fd = c_open( trim( this%lock_file )//c_null_char, ior( O_RDWR, O_CREAT ), MODE_0644 )
      if ( fd < 0 ) then                         ! cannot create or open it at all
        err = current_errno( )                   ! read errno BEFORE any other C call
        if ( present( reason ) ) reason = LOCK_UNOPENABLE
        if ( present( errmsg ) ) errmsg = 'open ' // trim( this%lock_file ) // ': ' // errno_text( err )
        return
      end if
      rc = c_flock( fd, ior( LOCK_EX, LOCK_NB ) )
      if ( rc /= 0 ) then                        ! refuse, never block
        err = current_errno( )
        rc  = c_close( fd )
        if ( err == EAGAIN ) then                ! genuine contention: another writer holds it
          if ( present( reason ) ) reason = LOCK_HELD
        else                                     ! not contention -- a real fault
          if ( present( reason ) ) reason = LOCK_ERROR
        end if
        if ( present( errmsg ) ) errmsg = 'flock ' // trim( this%lock_file ) // ': ' // errno_text( err )
        return
      end if
      this%lock_fd = fd
      this%locked  = .true.
      ok           = .true.
      if ( present( reason ) ) reason = LOCK_ACQUIRED
      ! Diagnostics only. A failure to write them must not fail the lock -- we hold it.
      open ( newunit = u, file = this%lock_file, action = 'write', status = 'old', iostat = ios )
      if ( ios == 0 ) then
        write ( u, '(a,i0)', iostat = ios ) 'pid ', c_getpid()
        close ( u )
      end if
    end subroutine lock

    subroutine unlock ( this )
      class(ducklake_ty), intent(inout) :: this
      integer(c_int) :: rc
      if ( .not. this%locked ) return
      rc = c_close( this%lock_fd )   ! releases the kernel lock; the file stays, on purpose
      this%lock_fd = -1
      this%locked  = .false.
    end subroutine unlock

  ! errno right after a failed C call. Must be read before any other C call is made, since
  ! any of them may overwrite it -- that is why lock() saves it into a local immediately.
  integer(c_int) function current_errno ( )
    integer(c_int), pointer :: slot
    call c_f_pointer( c_errno_location( ), slot )
    current_errno = slot
  end function current_errno

  ! strerror(3) text for an errno, with the number kept alongside it. The number matters:
  ! strerror is locale-dependent, so a log read in one locale and a manual read in another
  ! still agree on the number.
  function errno_text ( errnum ) result ( text )
    integer(c_int), intent(in)      :: errnum
    character(:), allocatable       :: text
    character(kind=c_char), pointer :: buf(:)
    type(c_ptr)                     :: cp
    character(16)                   :: num
    integer                         :: i
    text = ''
    cp   = c_strerror( errnum )
    if ( c_associated( cp ) ) then
      call c_f_pointer( cp, buf, [ 256 ] )
      do i = 1, 256
        if ( buf(i) == c_null_char ) exit
        text = text // buf(i)
      end do
    end if
    write ( num, '(i0)' ) errnum
    text = text // ' (errno ' // trim( num ) // ')'
  end function errno_text

  subroutine delete_file ( path )
    character(*), intent(in) :: path
    integer :: u, ios
    open ( newunit = u, file = path, status = 'old', iostat = ios )
    if ( ios == 0 ) close ( u, status = 'delete' )
  end subroutine delete_file

end module ducklake_mo
