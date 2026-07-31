module duckdb_mo

  ! Fortran interface to the DuckDB C API, plus the duckdb_ty convenience wrapper.
  !
  ! The C bindings used to live in a separate duckdb.f90 generated against the upstream
  ! duckdb.h. That generator is no longer actively maintained, and only a small part of
  ! its ~3700 lines was ever reachable from here, so the pieces this module actually
  ! calls now live inline: five bind(c) types, the state enum, the C interfaces, and the
  ! thin wrappers that handle C-string conversion. Everything else was unused.
  !
  ! Kept deliberately narrow -- add a binding when something here needs it, rather than
  ! mirroring the whole C API again.

  use, intrinsic :: iso_fortran_env
  use, intrinsic :: iso_c_binding

  implicit none

  private :: dirname
  private :: copy, c_f_str_ptr

  ! === DuckDB C API opaque handles ==========================================

  type, bind(c) :: duckdb_database
    type(c_ptr) :: db = c_null_ptr
  end type

  type, bind(c) :: duckdb_connection
    type(c_ptr) :: conn = c_null_ptr
  end type

  type, bind(c) :: duckdb_config
    type(c_ptr) :: cnfg = c_null_ptr
  end type

  type, bind(c) :: duckdb_string
    type(c_ptr)             :: data = c_null_ptr
    integer(kind=c_int64_t) :: size = 0
  end type

  type, bind(c) :: duckdb_result
    integer(kind=c_int64_t) :: deprecated_column_count = 0
    integer(kind=c_int64_t) :: deprecated_row_count = 0
    integer(kind=c_int64_t) :: deprecated_rows_changed = 0
    type(c_ptr)             :: deprecated_columns = c_null_ptr
    type(c_ptr)             :: deprecated_error_message = c_null_ptr
    type(c_ptr)             :: internal_data = c_null_ptr
  end type

  enum, bind(c)
    enumerator :: duckdb_state  = 0
    enumerator :: duckdbsuccess = 0
    enumerator :: duckdberror   = 1
  end enum

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

  ! === C interfaces =========================================================

  interface

    function c_strlen(str) bind(c, name='strlen')
      import :: c_ptr, c_size_t
      type(c_ptr), value :: str
      integer(c_size_t) :: c_strlen
    end function c_strlen

    subroutine duckdb_close(database) bind(c, name='duckdb_close')
      import :: duckdb_database
      type(duckdb_database) :: database
    end subroutine duckdb_close

    function duckdb_column_count_(res) &
    & bind(c, name='duckdb_column_count') result(cc)
      import :: duckdb_result, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t) :: cc
    end function duckdb_column_count_

    function duckdb_connect(database, out_connection) &
    & bind(c, name='duckdb_connect') result(res)
      import :: duckdb_state, duckdb_database, duckdb_connection
      integer(kind(duckdb_state)) :: res
      type(duckdb_database), value :: database
      type(duckdb_connection) :: out_connection
    end function duckdb_connect

    function duckdb_create_config(out_config) &
    & bind(c, name='duckdb_create_config') result(res)
      import :: duckdb_state, duckdb_config
      integer(kind(duckdb_state)) :: res
      type(duckdb_config) :: out_config
    end function duckdb_create_config

    subroutine duckdb_destroy_config(config) &
    & bind(c, name='duckdb_destroy_config')
      import :: duckdb_config
      type(duckdb_config) :: config
    end subroutine duckdb_destroy_config

    subroutine duckdb_destroy_result(res) &
    & bind(c, name='duckdb_destroy_result')
      import :: duckdb_result
      type(duckdb_result) :: res
    end subroutine duckdb_destroy_result

    subroutine duckdb_disconnect(connection) &
    & bind(c, name='duckdb_disconnect')
      import :: duckdb_connection
      type(duckdb_connection) :: connection
    end subroutine duckdb_disconnect

    function duckdb_open_ext_(path, db, config, out_error) &
    & bind(c, name='duckdb_open_ext') result(res)
      import :: duckdb_state, c_char, duckdb_database, duckdb_config, c_ptr
      integer(kind(duckdb_state)) :: res
      character(kind=c_char) :: path
      type(duckdb_database) :: db
      type(duckdb_config), value :: config
      type(c_ptr) :: out_error
    end function duckdb_open_ext_

    function duckdb_query_(connection, query, out_result) &
    & bind(c, name='duckdb_query') result(res)
      import :: duckdb_state, duckdb_connection, duckdb_result, c_char
      integer(kind(duckdb_state)) :: res
      type(duckdb_connection), value :: connection
      character(kind=c_char) :: query ! must be a c string
      type(duckdb_result) :: out_result
    end function duckdb_query_

    function duckdb_result_error_(res) &
    & bind(c, name='duckdb_result_error') result(err)
      import :: c_ptr, duckdb_result
      type(duckdb_result) :: res
      type(c_ptr) :: err
    end function duckdb_result_error_

    function duckdb_row_count_(res) &
    & bind(c, name='duckdb_row_count') result(rc)
      import :: duckdb_result, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t) :: rc
    end function duckdb_row_count_

    function duckdb_set_config_(config, name, option) &
    & bind(c, name='duckdb_set_config') result(res)
      import :: duckdb_state, duckdb_config, c_char
      integer(kind(duckdb_state)) :: res
      type(duckdb_config), value :: config
      character(c_char) :: name
      character(c_char) :: option
    end function duckdb_set_config_

    function duckdb_value_boolean_(res, col, row) &
    & bind(c, name='duckdb_value_boolean') result(r)
      import :: duckdb_result, c_bool, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      logical(kind=c_bool) :: r
    end function duckdb_value_boolean_

    function duckdb_value_double_(res, col, row) &
    & bind(c, name='duckdb_value_double') result(r)
      import :: duckdb_result, c_double, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      real(kind=c_double) :: r
    end function duckdb_value_double_

    function duckdb_value_float_(res, col, row) &
    & bind(c, name='duckdb_value_float') result(r)
      import :: duckdb_result, c_float, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      real(kind=c_float) :: r
    end function duckdb_value_float_

    function duckdb_value_int32_(res, col, row) &
    & bind(c, name='duckdb_value_int32') result(r)
      import :: duckdb_result, c_int32_t, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      integer(kind=c_int32_t) :: r
    end function duckdb_value_int32_

    function duckdb_value_int64_(res, col, row) &
    & bind(c, name='duckdb_value_int64') result(r)
      import :: duckdb_result, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      integer(kind=c_int64_t) :: r
    end function duckdb_value_int64_

    function duckdb_value_is_null_(res, col, row) &
    & bind(c, name='duckdb_value_is_null') result(r)
      import :: duckdb_result, c_bool, c_int64_t
      type(duckdb_result), intent(in) :: res
      integer(kind=c_int64_t), value :: col, row
      logical(kind=c_bool) :: r
    end function duckdb_value_is_null_

    function duckdb_value_string_(res, col, row) &
    & bind(c, name='duckdb_value_string') result(r)
      import :: duckdb_result, c_int64_t, duckdb_string
      type(duckdb_result), intent(in) :: res
      integer(kind=c_int64_t), value :: col, row
      type(duckdb_string) :: r
    end function duckdb_value_string_

    function duckdb_value_varchar_(res, col, row) &
    & bind(c, name='duckdb_value_varchar') result(ptr)
      import :: duckdb_result, c_int64_t, c_ptr
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(c_ptr) :: ptr
    end function duckdb_value_varchar_

  end interface

contains

  ! === helpers and C-string plumbing ========================================

    subroutine c_f_str_ptr(c_str, f_str)
        type(c_ptr) :: c_str
        character(len=:), allocatable :: f_str
        character(kind=c_char), pointer :: ptrs(:)
        integer(kind=c_size_t) :: sz
        if (.not. c_associated(c_str)) return
        sz = c_strlen(c_str)
        if (sz < 0) return
        call c_f_pointer(c_str, ptrs, [ sz ])
        if ( allocated ( f_str ) ) deallocate ( f_str ) ! added by tkdhss111
        allocate (character(len=sz) :: f_str)
        f_str = copy(ptrs)
    end subroutine c_f_str_ptr

    pure function copy(a)
      character, intent(in)  :: a(:)
      character(len=size(a)) :: copy
      integer :: i
      do i = 1, size(a)
        copy(i:i) = a(i)
      end do
    end function copy

    function duckdb_column_count(res) result(cc)
      type(duckdb_result) :: res
      integer(kind=int64) :: cc
      cc = 0
      if (c_associated(res%internal_data)) &
        cc = int(duckdb_column_count_(res))
    end function duckdb_column_count

    function duckdb_open_ext(path, out_database, config, out_error) result(res)
      integer(kind(duckdb_state)) :: res
      character(len=*) :: path
      type(duckdb_database) :: out_database
      type(duckdb_config) :: config
      type(c_ptr) :: tmp_error
      character(len=:), allocatable :: out_error
      tmp_error = c_null_ptr
      res = duckdb_open_ext_(path//c_null_char, out_database, config, tmp_error)
      if (c_associated(tmp_error)) then
        call c_f_str_ptr(tmp_error, out_error)
      endif
    end function duckdb_open_ext

    function duckdb_query(connection, query, out_result) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_connection), value :: connection
      character(len=*) :: query
      character(len=:), allocatable :: sql
      type(duckdb_result), optional :: out_result
      sql = query // c_null_char ! convert to c string
      res = duckdb_query_(connection, sql, out_result)
      deallocate(sql)
    end function duckdb_query

    function duckdb_result_error(res) result(err)
      character(len=:), allocatable :: err
      type(c_ptr) :: tmp
      type(duckdb_result) :: res
      err = ""
      if (c_associated(res%internal_data)) then
        tmp = duckdb_result_error_(res)
        if (c_associated(tmp)) call c_f_str_ptr(tmp, err)
      end if
    end function duckdb_result_error

    function duckdb_row_count(res) result(rc)
      type(duckdb_result) :: res
      integer(kind=int64) :: rc
      rc = 0
      if (c_associated(res%internal_data)) &
        rc = int(duckdb_row_count_(res))
    end function duckdb_row_count

    function duckdb_set_config(config, name, option) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_config) :: config
      character(len=*) :: name
      character(len=*) :: option
      res = duckdb_set_config_(config, name//c_null_char, option//c_null_char)
    end function duckdb_set_config

    function duckdb_string_to_character(str) result(res)
      type(duckdb_string) :: str
      character(len=:), allocatable :: res
      character(kind=c_char), pointer :: ptrs(:)
      res = ""
      if (c_associated(str%data) .and. str%size > 0) then
        call c_f_pointer(str%data, ptrs, [ str%size ])
        ! No explicit allocate here: `res = ""` above has already allocated it, so
        ! ALLOCATE would abort with "allocatable array is already allocated"
        ! (forrtl severe 151). Assignment to a deferred-length allocatable
        ! reallocates to the right length on its own.
        res = copy(ptrs)
      end if
    end function duckdb_string_to_character

    function duckdb_value_boolean(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64), value :: col, row
      logical :: r
      r = .false.
      if (c_associated(res%internal_data)) &
        r = duckdb_value_boolean_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_boolean

    function duckdb_value_double(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      real(kind=real64) :: r
      if (c_associated(res%internal_data)) &
        r = real(duckdb_value_double_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t)), kind=real64)
    end function duckdb_value_double

    function duckdb_value_float(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      real(kind=real32) :: r
      if (c_associated(res%internal_data)) &
        r = real(duckdb_value_float_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t)), kind=real32)
    end function duckdb_value_float

    function duckdb_value_int32(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      integer(kind=int32) :: r
      r = 0
      if (c_associated(res%internal_data)) &
        r = int(duckdb_value_int32_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t)), kind=int32)
    end function duckdb_value_int32

    function duckdb_value_int64(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      integer(kind=int64) :: r
      r = 0
      if (c_associated(res%internal_data)) &
        r = int(duckdb_value_int64_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t)), kind=int64)
    end function duckdb_value_int64

    function duckdb_value_is_null(res, col, row) result(r)
      type(duckdb_result), intent(in) :: res
      integer(kind=int64) :: col, row
      logical :: r
      r = .false.
      if (c_associated(res%internal_data)) &
        r = logical(duckdb_value_is_null_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t)))
    end function duckdb_value_is_null

    function duckdb_value_string(res, col, row) result(r)
      type(duckdb_result), intent(in) :: res
      integer(kind=int64) :: col, row
      type(duckdb_string) :: r
      if (c_associated(res%internal_data)) &
        r = duckdb_value_string_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_string

    function duckdb_value_varchar(res, col, row) result(str)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      type(c_ptr) :: tmp
      character(len=:), allocatable :: str
      tmp = c_null_ptr
      if (c_associated(res%internal_data)) &
        tmp = duckdb_value_varchar_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
      if (c_associated(tmp)) call c_f_str_ptr(tmp, str)
    end function duckdb_value_varchar

  ! === duckdb_ty ============================================================

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
          ! duckdb_value_string ({ptr,size}, non-deprecated) — NOT the legacy
          ! duckdb_value_varchar: under libduckdb >= 1.5 the legacy call
          ! truncates NON-INLINED strings (> 12 bytes, e.g. a 19-char
          ! 'YYYY-MM-DD HH:MM:SS' timestamp) while short inlined strings read
          ! fine, which made the bug look data-dependent.
          block
            type(duckdb_string)       :: ds
            character(:), allocatable :: tmp_str
            ds = duckdb_value_string( this%res, col = j - 1, row = i - 1 )
            if ( ds%size > 0 ) then
              tmp_str = duckdb_string_to_character( ds )
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
      ! Publish _SUCCESS marker (Hadoop convention) — see file_mo.f90
      ! atomic_commit for the canonical pattern.
      call execute_command_line( 'touch -- "'//dirname(to)//'_SUCCESS"' )
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
      ! Publish _SUCCESS marker (Hadoop convention) — see file_mo.f90
      ! atomic_commit for the canonical pattern.
      call execute_command_line( 'touch -- "'//dirname(to)//'_SUCCESS"' )
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

  !========================================================
  ! best_available — canonical "best available data as of an origin" SELECT builder.
  !
  ! Returns the DuckDB SELECT that gives, for each (keys, valid), the row from the
  ! FRESHEST issuance whose recv <= as_of. Leak-safe by construction and
  ! GRANULARITY-AGNOSTIC: works whether recv is a precise receive time or a snapped
  ! 30-min stamp, so consumers stop caring which the producer wrote. Centralises the
  ! `row_number() OVER (... ORDER BY jst_recv DESC) WHERE rn=1` pattern hand-rolled in
  ! bias/ensemble/blend/wni/jwa/meteo.
  !
  !   source : FROM expression, e.g. "read_parquet('<glob>', union_by_name=true)"
  !   valid  : valid-time column                         (default 'jst')
  !   recv   : issuance/receive column                   (default 'jst_recv')
  !   keys   : extra PARTITION cols before valid, comma-sep, e.g. 'station' (default none)
  !   as_of  : leak-safe upper cutoff 'YYYY-MM-DD HH:MM:SS'; '' = latest available (live)
  !   lead_lo, lead_hi : fair-lead guard in hours. lead_lo alone => MINIMUM lead
  !                      (valid - recv >= lead_lo h) — excludes nowcasts/hindcasts while
  !                      KEEPING far-horizon latest-available (right for a live+backfill store).
  !                      lead_lo AND lead_hi => fixed WINDOW (BETWEEN) — right for fair scoring.
  !
  ! Returns a self-contained SELECT (one row per (keys, valid)) ready to wrap in the
  ! caller's COPY(...) TO or a CTE.
  pure function best_available ( source, valid, recv, keys, as_of, lead_lo, lead_hi ) result ( sql )
    character(*), intent(in)           :: source
    character(*), intent(in), optional :: valid, recv, keys, as_of
    integer,      intent(in), optional :: lead_lo, lead_hi
    character(:), allocatable :: sql, v, r, part, where_
    character(16)             :: lo, hi

    v = 'jst';      if ( present(valid) ) v = trim(valid)
    r = 'jst_recv'; if ( present(recv)  ) r = trim(recv)

    part = v
    if ( present(keys) ) then
      if ( len_trim(keys) > 0 ) part = trim(keys)//', '//v
    end if

    where_ = ''
    if ( present(as_of) ) then
      if ( len_trim(as_of) > 0 ) where_ = r//" <= TIMESTAMP '"//trim(as_of)//"'"
    end if
    if ( present(lead_lo) ) then
      write ( lo, '(i0)' ) lead_lo
      if ( len(where_) > 0 ) where_ = where_//' AND '
      if ( present(lead_hi) ) then
        write ( hi, '(i0)' ) lead_hi
        where_ = where_//v//' - '//r//' BETWEEN INTERVAL '//trim(lo)// &
                 ' HOUR AND INTERVAL '//trim(hi)//' HOUR'
      else
        where_ = where_//v//' - '//r//' >= INTERVAL '//trim(lo)//' HOUR'
      end if
    end if
    if ( len(where_) > 0 ) where_ = ' WHERE '//where_

    sql = 'SELECT * EXCLUDE (_rn) FROM ( SELECT *, row_number() OVER ( PARTITION BY '// &
          part//' ORDER BY '//r//' DESC ) AS _rn FROM '//trim(source)//where_// &
          ' ) WHERE _rn = 1'
  end function

end module duckdb_mo
