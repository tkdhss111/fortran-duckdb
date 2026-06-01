module duckdb_mo

  use duckdb
  use, intrinsic :: iso_c_binding

  implicit none

  private :: dirname

  type duckdb_ty
    type(duckdb_database)     :: db
    type(duckdb_config)       :: cf
    type(duckdb_connection)   :: con
    type(duckdb_result)       :: res = duckdb_result()
    integer                   :: stat = 0
    character(:), allocatable :: errmsg
  contains
    procedure :: open  => open_duckdb
    procedure :: close => close_duckdb
    procedure :: send  => send_query
    procedure :: clear_result
    procedure :: get_table
    procedure :: get_cell
    procedure :: export_table_as_parquet
    procedure :: export_table_as_csvfile
  end type

contains

  subroutine open_duckdb ( this, path, access, memory_limit, temp_directory )
    class(duckdb_ty),       intent(inout) :: this
    character(*),           intent(in)    :: path
    character(*), optional, intent(in)    :: access          ! {AUTOMATIC | READ_ONLY | READ_WRITE}
    character(*), optional, intent(in)    :: memory_limit    ! e.g. '512MB'. Explicit arg wins; if absent, env DUCKDB_MEMORY_LIMIT; if both absent, no cap (fast local)
    character(*), optional, intent(in)    :: temp_directory  ! e.g. '/srv/data/.duckdb_tmp'. Explicit arg wins; if absent, env DUCKDB_TEMP_DIRECTORY
    character(:), allocatable             :: access_
    character(256)                        :: env_buf
    character(:), allocatable             :: mem_to_apply, tmp_to_apply
    if ( present( access ) ) then
      access_ = access
      if ( access_ == 'READ_ONLY' .and. path == '' ) then
        error stop 'Impossible to open In-memory database as READ_ONLY'
      end if
      print *, 'Database opened as '//trim(access)
    else
      access_ = 'AUTOMATIC'
    end if
    if ( duckdb_create_config( this%cf ) == duckdberror ) then
      print *, 'Database: '//trim(path)
      error stop '*** Error: Cound not create database config'
    end if
    if ( duckdb_set_config( this%cf, 'access_mode', access_ ) == duckdberror ) then
      call duckdb_destroy_config( this%cf  )
      print *, 'Database: '//trim(path)
      error stop '*** Error: Cound not set access_mode as '//trim(access_)
    end if
    if ( duckdb_open_ext( path, this%db, this%cf, this%errmsg ) == duckdberror ) then
      call duckdb_destroy_config( this%cf  )
      print *, 'Database: '//trim(path)
      error stop '*** Error: Cound not open database ('//trim(this%errmsg)//')'
    end if
    if ( duckdb_connect( this%db, this%con ) == duckdberror ) then
      call duckdb_destroy_config( this%cf )
      call duckdb_close( this%db  )
      print *, 'Database: '//trim(path)
      error stop '*** Error: Cound not connect database'
    end if

    ! Resolve memory_limit: explicit arg > env DUCKDB_MEMORY_LIMIT > none
    if ( present( memory_limit ) ) then
      if ( len_trim( memory_limit ) > 0 ) mem_to_apply = trim( memory_limit )
    else
      call get_environment_variable( 'DUCKDB_MEMORY_LIMIT', env_buf )
      if ( len_trim( env_buf ) > 0 ) mem_to_apply = trim( env_buf )
    end if
    if ( allocated( mem_to_apply ) ) then
      call this%send( "SET memory_limit = '"//mem_to_apply//"'" )
      call duckdb_destroy_result( this%res )
    end if

    ! Resolve temp_directory: explicit arg > env DUCKDB_TEMP_DIRECTORY > none
    if ( present( temp_directory ) ) then
      if ( len_trim( temp_directory ) > 0 ) tmp_to_apply = trim( temp_directory )
    else
      call get_environment_variable( 'DUCKDB_TEMP_DIRECTORY', env_buf )
      if ( len_trim( env_buf ) > 0 ) tmp_to_apply = trim( env_buf )
    end if
    if ( allocated( tmp_to_apply ) ) then
      call execute_command_line( '/bin/mkdir -p '//tmp_to_apply )
      call this%send( "SET temp_directory = '"//tmp_to_apply//"'" )
      call duckdb_destroy_result( this%res )
    end if
  end subroutine open_duckdb

  subroutine close_duckdb ( this )
    class(duckdb_ty), intent(inout) :: this

    ! Destroy result first (may contain references to connection)
    call duckdb_destroy_result( this%res )

    ! Disconnect before closing database
    call duckdb_disconnect( this%con )

    ! Close database before destroying config
    call duckdb_close( this%db )

    ! Destroy config last
    call duckdb_destroy_config( this%cf )

    ! Deallocate error message if allocated  ← NEW
    if ( allocated( this%errmsg ) ) deallocate( this%errmsg )

    ! Reset status  ← NEW
    this%stat = 0

  end subroutine close_duckdb

  subroutine send_query ( this, query, print )
    class(duckdb_ty),  intent(inout) :: this
    character(*),      intent(in)    :: query
    logical, optional, intent(in)    :: print
    call duckdb_destroy_result( this%res )
    if ( present( print ) ) then
      if ( print ) write ( *, '(a)' ) '[Query] '//trim(query)
    end if
    this%stat = duckdb_query( this%con, trim(query)//";", this%res )
    if ( this%stat == duckdberror ) then
      if ( .not. present( print ) ) write ( *, '(a)' ) '[Query] '//trim(query)
      write ( *, '(a)' ) '[Query] '//trim(duckdb_result_error( this%res ) )
      return
    end if
  end subroutine send_query

  subroutine clear_result ( this )
    class(duckdb_ty), intent(inout) :: this
    call duckdb_destroy_result( this%res )
  end subroutine clear_result

  function concat ( i, sep ) result ( p )
    integer(8),   intent(in) :: i
    character(*), intent(in) :: sep
    character(:), allocatable :: p
    if ( i == 1 ) then
      p = ''
    else
      p = sep
    end if
  end function

  subroutine get_table ( this, table, cols, nrows, ncols )
    class(duckdb_ty),       intent(inout) :: this
    character(*),           intent(in)    :: table
    character(*), optional, intent(in)    :: cols(:)
    integer(8),   optional, intent(out)   :: nrows, ncols
    character(:), allocatable             :: colnames
    integer(8) i
    if ( present( cols ) ) then
      colnames = ''
      do i = 1, size(cols)
        colnames = trim(colnames)//concat(i, ',')//trim(cols(i))
      end do
    else
      colnames = '*'
    end if
    ! write ( *, '(a)' ) 'SELECT '//trim(colnames)//' FROM '//trim(table)
    call this%send ( 'SELECT '//trim(colnames)//' FROM '//trim(table) )
    if ( present( nrows ) ) then
      nrows = duckdb_row_count( this%res )
      if ( nrows == 0 ) then
        print *,  '*** Error: No record found'
        this%stat = 1
      else
        !print *, 'nrows: ', nrows
      end if
    end if
    if ( present( ncols ) ) then
      ncols = duckdb_column_count( this%res )
      !print *, 'ncols: ', ncols
    end if
  end subroutine get_table

  subroutine get_cell ( this, i, j, x )
    class(duckdb_ty), intent(inout) :: this
    integer(8),       intent(in)    :: i, j
    class(*),         intent(out)   :: x
    type(duckdb_string) :: str
    logical is_null
    is_null = duckdb_value_is_null( this%res, col = j - 1, row = i - 1 )
    select type ( y => x )
      type is ( logical )
        y = duckdb_value_boolean( this%res, col = j - 1, row = i - 1 )
      type is ( integer(4) )
        if ( is_null ) then
          y = -999
        else
          y = duckdb_value_int32( this%res, col = j - 1, row = i - 1 )
        end if
      type is ( integer(8) )
        if ( is_null ) then
          y = -999
        else
          y = duckdb_value_int64( this%res, col = j - 1, row = i - 1 )
        end if
      type is ( real(4) )
        if ( is_null ) then
          y = -999.0
        else
          y = duckdb_value_float( this%res, col = j - 1, row = i - 1 )
        end if
      type is ( real(8) )
        if ( is_null ) then
          y = -999.0
        else
          y = duckdb_value_double( this%res, col = j - 1, row = i - 1 )
        end if
      type is ( character(*) )
        if ( is_null ) then
          y = 'NA'
        else
          block
            character(:), allocatable :: tmp_str
            tmp_str = duckdb_value_varchar( this%res, col = j - 1, row = i - 1 )
            if ( allocated(tmp_str) ) then
              y = tmp_str
            else
              y = 'NA'
            end if
          end block
        end if
      class default
        call this%close
        error stop '*** Error: Unknown variable type'
    end select

  end subroutine get_cell

  !-----------------------------------------------------------
  ! export_table_as_parquet
  !
  ! Write `table` to `to` as a parquet file.
  !
  !   atomic=.false. (default): write directly to `to`. Concurrent
  !     readers may observe a partial file mid-write (DuckDB writes
  !     the parquet footer last; readers reading metadata during
  !     write get TProtocolException / invalid TType).
  !
  !   atomic=.true.: write to `to`.tmp, then `mv -f` it to `to`.
  !     POSIX rename(2) is atomic on the same filesystem, so readers
  !     see either the old `to` or the new one — never partial.
  !     Use this whenever concurrent readers of `to` are possible.
  !
  !   compression='zstd' | 'snappy' | 'gzip' | 'uncompressed':
  !     pass-through to DuckDB's COPY ... COMPRESSION option. If
  !     absent, DuckDB picks its default (snappy as of v1.5). 'zstd'
  !     gives ~20-30 % smaller files than snappy at similar
  !     read/write cost — recommended for archive/persisted parquets.
  !-----------------------------------------------------------
  subroutine export_table_as_parquet ( this, table, to, atomic, compression )
    class(duckdb_ty),       intent(inout) :: this
    character(*),           intent(in)    :: table
    character(*),           intent(in)    :: to
    logical,      optional, intent(in)    :: atomic
    character(*), optional, intent(in)    :: compression
    character(:), allocatable :: target, opts
    logical :: do_atomic
    do_atomic = .false.
    if ( present(atomic) ) do_atomic = atomic
    target = trim(to)
    if ( do_atomic ) target = trim(to) // '.tmp'
    opts = "FORMAT 'parquet'"
    if ( present(compression) ) then
      opts = opts // ", COMPRESSION '" // trim(compression) // "'"
    end if
#ifdef debug
    write ( *, '(a)' ) "COPY "//trim(table)//" TO '"//target//"' WITH("//opts//")"
#endif
    call execute_command_line( 'mkdir -p '//dirname(to) )
    call this%send( "COPY "//trim(table)//" TO '"//target//"' WITH("//opts//")" )
    call duckdb_destroy_result( this%res )
    if ( do_atomic ) then
      call execute_command_line( 'mv -f -- '//target//' '//trim(to) )
    end if
  end subroutine export_table_as_parquet

  !-----------------------------------------------------------
  ! export_table_as_csvfile (same atomic semantics as above)
  !-----------------------------------------------------------
  subroutine export_table_as_csvfile ( this, table, to, atomic )
    class(duckdb_ty),  intent(inout) :: this
    character(*),      intent(in)    :: table
    character(*),      intent(in)    :: to
    logical, optional, intent(in)    :: atomic
    character(:), allocatable :: target
    logical :: do_atomic
    do_atomic = .false.
    if ( present(atomic) ) do_atomic = atomic
    target = trim(to)
    if ( do_atomic ) target = trim(to) // '.tmp'
#ifdef debug
    write ( *, '(a)' ) "COPY "//trim(table)//" TO '"//target//"' (HEADER, DELIMITER ',')"
#endif
    call execute_command_line( 'mkdir -p '//dirname(to) )
    call this%send( "COPY "//trim(table)//" TO '"//target//"' (HEADER, DELIMITER ',')" )
    call duckdb_destroy_result( this%res )
    if ( do_atomic ) then
      call execute_command_line( 'mv -f -- '//target//' '//trim(to) )
    end if
  end subroutine export_table_as_csvfile

  pure function dirname ( path )
    character(*), intent(in)  :: path
    integer                   :: p_sep
    character(:), allocatable :: dirname
    p_sep = index( path, '/', back = .true. )
    if (p_sep > 1) then
      dirname = path(1:p_sep)
    else
      dirname = './'
    end if
  end function

end module duckdb_mo
