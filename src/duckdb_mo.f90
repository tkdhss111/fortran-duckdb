module duckdb_mo

  use duckdb
  use, intrinsic :: iso_c_binding

  implicit none

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

  subroutine open_duckdb ( this, path, access )
    class(duckdb_ty),       intent(inout) :: this
    character(*),           intent(in)    :: path
    character(*), optional, intent(in)    :: access ! {AUTOMATIC | READ_ONLY | READ_WRITE}
    character(:), allocatable             :: access_
    if ( present ( access ) ) then
      access_ = access
      if ( access_ == 'READ_ONLY' .and. path == '' ) then
        error stop 'Impossible to open In-memory database as READ_ONLY'
      end if
      print *, 'Database opened as '//trim(access)
    else
      access_ = 'AUTOMATIC'
    end if
    if ( duckdb_create_config ( this%cf ) == duckdberror ) then
      print *, 'Database: '//trim(path)
      error stop '*** Error: Cound not create database config'
    end if
    if ( duckdb_set_config ( this%cf, 'access_mode', access_ ) == duckdberror ) then
      call duckdb_destroy_config ( this%cf  )
      print *, 'Database: '//trim(path)
      error stop '*** Error: Cound not set access_mode as '//trim(access_)
    end if
    if ( duckdb_open_ext ( path, this%db, this%cf, this%errmsg ) == duckdberror ) then
      call duckdb_destroy_config ( this%cf  )
      print *, 'Database: '//trim(path)
      error stop '*** Error: Cound not open database ('//trim(this%errmsg)//')'
    end if
    if ( duckdb_connect ( this%db, this%con ) == duckdberror ) then
      call duckdb_close ( this%db  )
      print *, 'Database: '//trim(path)
      error stop '*** Error: Cound not connect database'
    end if
  end subroutine open_duckdb

  subroutine close_duckdb ( this )
    class(duckdb_ty), intent(inout) :: this
    call duckdb_destroy_result ( this%res )
    call duckdb_destroy_config ( this%cf  )
    call duckdb_disconnect     ( this%con )
    call duckdb_close          ( this%db  )
  end subroutine close_duckdb

  subroutine send_query ( this, query )
    class(duckdb_ty), intent(inout) :: this
    character(*),     intent(in)    :: query
    if ( duckdb_query ( this%con, trim(query)//";", this%res ) == duckdberror ) then
      print *, '[Query] '//trim(query)
      call this%close
      error stop '*** Error: Could not send query ('//trim(duckdb_result_error ( this%res )//')' )
    end if
  end subroutine send_query

  subroutine clear_result ( this )
    class(duckdb_ty), intent(inout) :: this
    call duckdb_destroy_result ( this%res )
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
    if ( present ( cols ) ) then
      colnames = ''
      do i = 1, size(cols)
        colnames = trim(colnames)//concat(i, ',')//trim(cols(i))
      end do
    else
      colnames = '*'
    end if
    print *, 'SELECT '//trim(colnames)//' FROM '//trim(table)
    call this%send ( 'SELECT '//trim(colnames)//' FROM '//trim(table) )
    nrows = duckdb_row_count ( this%res )
    ncols = duckdb_column_count ( this%res )
    print *, 'Table has ', nrows, ' records with ', ncols, ' columns.'
    if ( nrows == 0 ) then
      print *,  '*** Error: No record found'
      this%stat = 1
    end if
  end subroutine get_table

  subroutine get_cell ( this, i, j, x )
    class(duckdb_ty), intent(inout) :: this
    integer(8),       intent(in)    :: i, j
    class(*),         intent(out)   :: x
    select type ( y => x )
      type is ( logical )
        y = duckdb_value_boolean ( this%res, col = j - 1, row = i - 1 )
      type is ( integer(4) )
        y = duckdb_value_int32 ( this%res, col = j - 1, row = i - 1 )
      type is ( integer(8) )
        y = duckdb_value_int64 ( this%res, col = j - 1, row = i - 1 )
      type is ( real(4) )
        y = duckdb_value_float ( this%res, col = j - 1, row = i - 1 )
      type is ( real(8) )
        y = duckdb_value_double ( this%res, col = j - 1, row = i - 1 )
      type is ( character(*) )
        y = duckdb_string_to_character( duckdb_value_string ( this%res, col = j - 1, row = i - 1 ) )
      class default
        call this%close
        error stop '*** Error: Unknown variable type'
    end select

  end subroutine get_cell

  subroutine export_table_as_parquet ( this, table, to )
    class(duckdb_ty), intent(inout) :: this
    character(*),     intent(in)    :: table
    character(*),     intent(in)    :: to
    print *, "COPY "//trim(table)//" TO '"//trim(to)//"' WITH(FORMAT 'parquet')"
    call this%send ( "COPY "//trim(table)//" TO '"//trim(to)//"' WITH(FORMAT 'parquet')" )
    call duckdb_destroy_result ( this%res )
  end subroutine export_table_as_parquet

  subroutine export_table_as_csvfile ( this, table, to )
    class(duckdb_ty), intent(inout) :: this
    character(*),     intent(in)    :: table
    character(*),     intent(in)    :: to
    call this%send ( "COPY "//trim(table)//" TO '"//trim(to)//"' (HEADER, DELIMITER ',')" )
    call duckdb_destroy_result ( this%res )
  end subroutine export_table_as_csvfile

end module duckdb_mo
