program unit_test_ducklake

  use duckdb_mo
  use ducklake_mo
  implicit none

  type(duckdb_ty)   :: db, rdr
  type(ducklake_ty) :: lake
  logical           :: ok, ok2, exists
  integer           :: why
  character(256)    :: why_text
  integer(8)        :: nrows, ncols
  integer           :: n_before, n_after
  character(*), parameter :: root  = 'test/lake_tmp'
  character(*), parameter :: cat   = root//'/catalog.ducklake'
  character(*), parameter :: dpath = root//'/data/'
  character(*), parameter :: stage = root//'/staging'

  print *, '========================================='
  print *, ' DuckLake lifecycle tests'
  print *, '========================================='

  call execute_command_line( 'rm -rf '//root//' && mkdir -p '//dpath//' '//stage )
  call lake%init( cat, dpath )

  print *, 'Test: lock is exclusive'
  call lake%lock( ok, reason = why )
  if ( .not. ok ) error stop '*** Error: first lock should succeed'
  if ( why /= LOCK_ACQUIRED ) error stop '*** Error: a granted lock must report LOCK_ACQUIRED'
  block
    type(ducklake_ty) :: other
    call other%init( cat, dpath )
    call other%lock( ok2, reason = why, errmsg = why_text )
    if ( ok2 ) error stop '*** Error: second lock should fail while the first is held'
    ! Contention must be reported as contention -- never as a fault. Getting this wrong is
    ! what sends an operator hunting for a phantom writer.
    if ( why /= LOCK_HELD ) error stop '*** Error: contention must report LOCK_HELD'
    write ( *, '(a)' ) '    reason: '//trim( why_text )
  end block
  print *, '  ok - second writer refused, and reported as contention'

  ! The case that used to be indistinguishable. Before reason/errmsg existed, an unopenable
  ! lock file returned exactly the same bare .false. as genuine contention, so a caller
  ! logged "another writer holds the lake lock" while no writer existed anywhere. Retrying
  ! could never clear it.
  print *, 'Test: an unopenable lock file is NOT reported as contention'
  block
    type(ducklake_ty) :: broken
    call broken%init( root//'/no_such_dir/catalog.ducklake', dpath )
    call broken%lock( ok2, reason = why, errmsg = why_text )
    if ( ok2 ) error stop '*** Error: lock must fail when its file cannot be created'
    if ( why == LOCK_HELD ) &
      error stop '*** Error: an unopenable lock file must NOT be reported as contention'
    if ( why /= LOCK_UNOPENABLE ) error stop '*** Error: expected LOCK_UNOPENABLE'
    if ( len_trim( why_text ) == 0 ) error stop '*** Error: errmsg must say why'
    write ( *, '(a)' ) '    reason: '//trim( why_text )
  end block
  print *, '  ok - distinguished from contention, with the reason'

  ! Source compatibility: the two-argument form must still work unchanged, because every
  ! existing consumer calls it that way and picks the library up from main at image build.
  print *, 'Test: the two-argument form still compiles and behaves'
  block
    type(ducklake_ty) :: legacy
    call legacy%init( cat, dpath )
    call legacy%lock( ok2 )
    if ( ok2 ) error stop '*** Error: two-argument form should still be refused here'
  end block
  print *, '  ok - unchanged for existing callers'

  print *, 'Test: attach live catalog and create a table'
  call db%open( '' )
  call lake%attach( db )
  if ( lake%stat /= 0 ) error stop '*** Error: attach failed'
  call db%send( "CREATE TABLE lake.t ( id INTEGER, v DOUBLE )" ) ; call db%clear_result( )
  print *, '  ok'

  print *, 'Test: fan-in insert from staged parquet'
  call db%send( "COPY (SELECT i AS id, i * 1.5 AS v FROM range(1000) t(i)) TO '"// &
                stage//"/part_1.parquet' (FORMAT PARQUET)" ) ; call db%clear_result( )
  call db%send( "COPY (SELECT i AS id, i * 2.5 AS v FROM range(1000, 1500) t(i)) TO '"// &
                stage//"/part_2.parquet' (FORMAT PARQUET)" ) ; call db%clear_result( )
  call lake%insert_parquet( db, 't', stage//'/*.parquet' )
  if ( lake%stat /= 0 ) error stop '*** Error: insert_parquet failed'
  call db%get_table( 'lake.t', nrows = nrows, ncols = ncols )
  call db%clear_result( )
  print *, '  rows committed: ', nrows
  if ( nrows /= 1500 ) error stop '*** Error: expected 1500 rows'

  print *, 'Test: publish creates the published catalog'
  call lake%publish( db )
  if ( lake%stat /= 0 ) error stop '*** Error: publish failed'
  inquire ( file = cat//'.published', exist = exists )
  if ( .not. exists ) error stop '*** Error: published catalog missing'
  print *, '  ok'

  print *, 'Test: merge then reclaim reduces the data-file count'
  call db%send( "INSERT INTO lake.t SELECT i, i * 1.0 FROM range(200) t(i)" ) ; call db%clear_result( )
  call db%send( "INSERT INTO lake.t SELECT i, i * 1.0 FROM range(200) t(i)" ) ; call db%clear_result( )
  n_before = count_parquet( dpath )
  call lake%merge_files( db )
  call lake%publish( db )              ! rule 3: publish BEFORE reclaiming
  call lake%reclaim( db, retain_seconds = 0 )
  call lake%publish( db )
  n_after = count_parquet( dpath )
  print *, '  data files: ', n_before, ' -> ', n_after
  if ( n_after >= n_before ) error stop '*** Error: reclaim did not free files'

  print *, 'Test: a separate connection reads the PUBLISHED catalog read-only'
  call lake%detach( db )
  call rdr%open( '' )
  call lake%attach( rdr, read_only = .true. )
  if ( lake%stat /= 0 ) error stop '*** Error: read-only attach failed'
  call rdr%get_table( 'lake.t', nrows = nrows )
  call rdr%clear_result( )
  print *, '  rows visible to consumer: ', nrows
  if ( nrows /= 1900 ) error stop '*** Error: consumer saw the wrong row count'
  call lake%detach( rdr )
  call rdr%close

  print *, 'Test: failed insert rolls back and leaves the table unchanged'
  call lake%attach( db )
  call lake%insert_parquet( db, 't', root//'/nonexistent_*.parquet' )
  if ( lake%stat == 0 ) error stop '*** Error: insert of a missing glob should fail'
  lake%stat = 0
  call db%get_table( 'lake.t', nrows = nrows )
  call db%clear_result( )
  if ( nrows /= 1900 ) error stop '*** Error: rollback did not restore the row count'
  print *, '  ok - rows still ', nrows

  call lake%detach( db )
  call db%close
  call lake%unlock( )

  print *, 'Test: lock is released'
  call lake%lock( ok )
  if ( .not. ok ) error stop '*** Error: lock should be re-acquirable after unlock'
  call lake%unlock( )
  print *, '  ok'

  ! A holder that is SIGKILLed must not strand the lock. This is the regression test for the
  ! failure the kernel lock exists to prevent: with an exclusive-create lock file, the file
  ! outlived its dead owner and every later writer was refused forever, silently.
  ! Linux-specific (flock/fuser), like the rest of this library's platform assumptions.
  print *, 'Test: a SIGKILLed holder does not strand the lock'
  call execute_command_line( 'setsid sh -c "flock '//cat//'.lock sleep 120" ' // &
                             '</dev/null >/dev/null 2>&1 &', wait = .true. )
  call execute_command_line( 'sleep 1', wait = .true. )
  call lake%lock( ok )
  if ( ok ) then
    call lake%unlock( )
    error stop '*** Error: lock should be refused while another process holds it'
  end if
  print *, '  ok - refused while the other process holds it'
  call execute_command_line( 'fuser -k -KILL '//cat//'.lock >/dev/null 2>&1; sleep 1', wait = .true. )
  call lake%lock( ok )
  if ( .not. ok ) error stop '*** Error: lock must be reclaimable after the holder was SIGKILLed'
  call lake%unlock( )
  print *, '  ok - reclaimed automatically after SIGKILL (no manual cleanup)'

  print *, '========================================='
  print *, ' All DuckLake tests passed'
  print *, '========================================='

contains

  integer function count_parquet ( dir ) result ( n )
    character(*), intent(in) :: dir
    integer :: u, ios
    character(256) :: line
    call execute_command_line( 'find '//dir//' -name "*.parquet" | wc -l > '//root//'/.count' )
    n = 0
    open ( newunit = u, file = root//'/.count', status = 'old', iostat = ios )
    if ( ios /= 0 ) return
    read ( u, '(a)', iostat = ios ) line
    if ( ios == 0 ) read ( line, * ) n
    close ( u )
  end function count_parquet

end program unit_test_ducklake
