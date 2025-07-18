!
! Modified by tkdhss111 @date 2025-07-14
!
module duckdb
  use, intrinsic :: iso_fortran_env
  use, intrinsic :: iso_c_binding
  ! use util
  ! use constants
  implicit none
  private
  public :: duckdb_database
  public :: duckdb_connection

  public :: duckdb_prepared_statement
  public :: duckdb_extracted_statements
  public :: duckdb_pending_result
  public :: duckdb_appender
  public :: duckdb_arrow
  public :: duckdb_arrow_schema
  public :: duckdb_config
  public :: duckdb_arrow_array

  public :: duckdb_logical_type
  public :: duckdb_data_chunk
  public :: duckdb_vector
  public :: duckdb_value
  public :: duckdb_date
  public :: duckdb_date_struct
  public :: duckdb_time
  public :: duckdb_time_struct
  public :: duckdb_timestamp
  public :: duckdb_timestamp_struct
  public :: duckdb_interval
  public :: duckdb_hugeint
  public :: duckdb_decimal
  public :: duckdb_string
  public :: duckdb_blob
  public :: duckdb_list_entry
  public :: duckdb_column
  public :: duckdb_result
  public :: duckdb_type
  public :: duckdb_type_invalid
  public :: duckdb_type_boolean
  public :: duckdb_type_tinyint
  public :: duckdb_type_smallint
  public :: duckdb_type_integer
  public :: duckdb_type_bigint
  public :: duckdb_type_utinyint
  public :: duckdb_type_usmallint
  public :: duckdb_type_uinteger
  public :: duckdb_type_ubigint
  public :: duckdb_type_float
  public :: duckdb_type_double
  public :: duckdb_type_timestamp
  public :: duckdb_type_date
  public :: duckdb_type_time
  public :: duckdb_type_interval
  public :: duckdb_type_hugeint
  public :: duckdb_type_varchar
  public :: duckdb_type_blob
  public :: duckdb_type_decimal
  public :: duckdb_type_timestamp_s
  public :: duckdb_type_timestamp_ms
  public :: duckdb_type_timestamp_ns
  public :: duckdb_type_enum
  public :: duckdb_type_list
  public :: duckdb_type_struct
  public :: duckdb_type_map
  public :: duckdb_type_uuid
  public :: duckdb_type_union
  public :: duckdb_type_bit
  public :: duckdb_pending_state
  public :: duckdb_pending_result_ready
  public :: duckdb_pending_result_not_ready
  public :: duckdb_pending_error_state
  public :: duckdb_state
  public :: duckdbsuccess
  public :: duckdberror
  public :: duckdb_open
  public :: duckdb_open_ext
  public :: duckdb_close
  public :: duckdb_connect
  public :: duckdb_disconnect

  public :: duckdb_create_config
  public :: duckdb_config_count
  public :: duckdb_get_config_flag
  public :: duckdb_set_config
  public :: duckdb_destroy_config
  public :: duckdb_query
  public :: duckdb_destroy_result
  public :: duckdb_column_count
  public :: duckdb_row_count
  public :: duckdb_rows_changed
  public :: duckdb_column_data
  public :: duckdb_nullmask_data
  public :: duckdb_library_version
  public :: duckdb_column_name
  public :: duckdb_column_type
  public :: duckdb_result_error
  public :: duckdb_result_get_chunk
  public :: duckdb_result_chunk_count
  public :: duckdb_value_boolean
  public :: duckdb_value_int8
  public :: duckdb_value_int16
  public :: duckdb_value_int32
  public :: duckdb_value_int64
  public :: duckdb_value_hugeint
  public :: duckdb_value_decimal
  public :: duckdb_value_float
  public :: duckdb_value_double
  public :: duckdb_value_date
  public :: duckdb_value_time
  public :: duckdb_value_timestamp
  public :: duckdb_value_interval
  public :: duckdb_value_varchar
  public :: duckdb_value_string
  public :: duckdb_value_varchar_internal
  public :: duckdb_value_string_internal
  public :: duckdb_value_blob
  public :: duckdb_value_is_null
  public :: duckdb_malloc
  public :: duckdb_free
  public :: duckdb_vector_size
  public :: duckdb_from_date
  public :: duckdb_to_date
  public :: duckdb_from_time
  public :: duckdb_to_time
  public :: duckdb_from_timestamp
  public :: duckdb_to_timestamp
  public :: duckdb_hugeint_to_double
  public :: duckdb_double_to_hugeint
  public :: duckdb_decimal_to_double
  public :: duckdb_double_to_decimal
  public :: duckdb_string_to_character

  public :: duckdb_prepare
  public :: duckdb_destroy_prepare
  public :: duckdb_prepare_error
  public :: duckdb_nparams
  public :: duckdb_param_type
  public :: duckdb_clear_bindings
  public :: duckdb_bind_boolean
  public :: duckdb_bind_int8
  public :: duckdb_bind_int16
  public :: duckdb_bind_int32
  public :: duckdb_bind_int64
  public :: duckdb_bind_hugeint
  public :: duckdb_bind_decimal

  ! no uints in fortran - use ints instead
  ! public :: duckdb_bind_uint8
  ! public :: duckdb_bind_uint16
  ! public :: duckdb_bind_uint32
  ! public :: duckdb_bind_uint64

  public :: duckdb_bind_float
  public :: duckdb_bind_double
  public :: duckdb_bind_date
  public :: duckdb_bind_time
  public :: duckdb_bind_timestamp
  public :: duckdb_bind_interval
  public :: duckdb_bind_varchar
  public :: duckdb_bind_varchar_length
  ! TODO: helper function to wrap duckdb_bind_varchar_length
  ! public :: duckdb_bind_string
  public :: duckdb_bind_blob ! the way it should work
  public :: duckdb_bind_null
  public :: duckdb_execute_prepared
  ! public :: duckdb_execute_prepared_arrow
  public :: duckdb_extract_statements
  public :: duckdb_prepare_extracted_statement
  public :: duckdb_extract_statements_error
  public :: duckdb_destroy_extracted

  public :: duckdb_pending_prepared
  public :: duckdb_destroy_pending
  public :: duckdb_pending_error
  public :: duckdb_pending_execute_task
  public :: duckdb_execute_pending

  public :: duckdb_data_chunk_get_size
  public :: duckdb_data_chunk_get_vector
  public :: duckdb_data_chunk_get_column_count
  public :: duckdb_data_chunk_reset
  public :: duckdb_data_chunk_set_size
  public :: duckdb_destroy_data_chunk
  public :: duckdb_vector_get_column_type
  public :: duckdb_vector_get_data
  public :: duckdb_vector_get_validity
  public :: duckdb_vector_ensure_validity_writable

  ! public :: duckdb_vector_assign_string_element
  ! public :: duckdb_vector_assign_string_element_len

  public :: duckdb_list_vector_get_child
  public :: duckdb_list_vector_get_size
  public :: duckdb_list_vector_set_size
  public :: duckdb_list_vector_reserve
  public :: duckdb_struct_vector_get_child

  public :: duckdb_validity_row_is_valid
  public :: duckdb_validity_set_row_validity
  public :: duckdb_validity_set_row_invalid
  public :: duckdb_validity_set_row_valid

  public :: duckdb_create_logical_type
  public :: duckdb_create_list_type
  public :: duckdb_create_map_type
  public :: duckdb_get_type_id
  public :: duckdb_decimal_width
  public :: duckdb_decimal_scale
  public :: duckdb_decimal_internal_type
  public :: duckdb_enum_internal_type
  public :: duckdb_enum_dictionary_size
  public :: duckdb_enum_dictionary_value
  public :: duckdb_list_type_child_type
  public :: duckdb_map_type_key_type
  public :: duckdb_map_type_value_type
  public :: duckdb_struct_type_child_count
  public :: duckdb_struct_type_child_name
  public :: duckdb_struct_type_child_type
  public :: duckdb_destroy_logical_type
  public :: duckdb_create_data_chunk

  public :: duckdb_appender_create
  public :: duckdb_appender_error
  public :: duckdb_appender_flush
  public :: duckdb_appender_close
  public :: duckdb_appender_destroy
  public :: duckdb_appender_begin_row
  public :: duckdb_appender_end_row
  public :: duckdb_append_bool
  public :: duckdb_append_int8
  public :: duckdb_append_int16
  public :: duckdb_append_int32
  public :: duckdb_append_int64
  public :: duckdb_append_hugeint
  public :: duckdb_append_float
  public :: duckdb_append_double
  public :: duckdb_append_date
  public :: duckdb_append_time
  public :: duckdb_append_timestamp
  public :: duckdb_append_interval
  public :: duckdb_append_varchar
  public :: duckdb_append_varchar_length
  public :: duckdb_append_blob
  public :: duckdb_append_null
  public :: duckdb_append_data_chunk

  public :: duckdb_query_arrow
  public :: duckdb_query_arrow_schema
  public :: duckdb_query_arrow_array
  public :: duckdb_query_arrow_error
  public :: duckdb_destroy_arrow

  public :: STANDARD_VECTOR_SIZE

  enum, bind(c)
    enumerator :: duckdb_state                    = 0
    enumerator :: duckdbsuccess                   = 0
    enumerator :: duckdberror                     = 1
  end enum

  enum, bind(c)
    enumerator :: duckdb_type                     = 0
    enumerator :: duckdb_type_invalid             = 0
    ! bool
    enumerator :: duckdb_type_boolean             = 1
    ! int8_t
    enumerator :: duckdb_type_tinyint             = 2
    ! int16_t
    enumerator :: duckdb_type_smallint            = 3
    ! int32_t
    enumerator :: duckdb_type_integer             = 4
    ! int64_t
    enumerator :: duckdb_type_bigint              = 5
    ! uint8_t
    enumerator :: duckdb_type_utinyint            = 6
    ! uint16_t
    enumerator :: duckdb_type_usmallint           = 7
    ! uint32_t
    enumerator :: duckdb_type_uinteger            = 8
    ! uint64_t
    enumerator :: duckdb_type_ubigint             = 9
    ! float
    enumerator :: duckdb_type_float               = 10
    ! double
    enumerator :: duckdb_type_double              = 11
    ! duckdb_timestamp, in microseconds
    enumerator :: duckdb_type_timestamp           = 12
    ! duckdb_date
    enumerator :: duckdb_type_date                = 13
    ! duckdb_time
    enumerator :: duckdb_type_time                = 14
    ! duckdb_interval
    enumerator :: duckdb_type_interval            = 15
    ! duckdb_hugeint
    enumerator :: duckdb_type_hugeint             = 16
    ! const char*
    enumerator :: duckdb_type_varchar             = 17
    ! duckdb_blob
    enumerator :: duckdb_type_blob                = 18
    ! decimal
    enumerator :: duckdb_type_decimal             = 19
    ! duckdb_timestamp, in seconds
    enumerator :: duckdb_type_timestamp_s         = 20
    ! duckdb_timestamp, in milliseconds
    enumerator :: duckdb_type_timestamp_ms        = 21
    ! duckdb_timestamp, in nanoseconds
    enumerator :: duckdb_type_timestamp_ns        = 22
    ! enum type, only useful as logical type
    enumerator :: duckdb_type_enum                = 23
    ! list type, only useful as logical type
    enumerator :: duckdb_type_list                = 24
    ! struct type, only useful as logical type
    enumerator :: duckdb_type_struct              = 25
    ! map type, only useful as logical type
    enumerator :: duckdb_type_map                 = 26
    ! duckdb_hugeint
    enumerator :: duckdb_type_uuid                = 27
    ! union type, only useful as logical type
    enumerator :: duckdb_type_union               = 28
    ! duckdb_bit
    enumerator :: duckdb_type_bit                 = 29
  end enum

  enum, bind(c)
    enumerator :: duckdb_pending_state            = 0
    enumerator :: duckdb_pending_result_ready     = 0
    enumerator :: duckdb_pending_result_not_ready = 1
    enumerator :: duckdb_pending_error_state      = 2
  end enum

  type, bind(c) :: duckdb_database
    type(c_ptr) :: db = c_null_ptr
  end type

  type, bind(c) :: duckdb_connection
    type(c_ptr) :: conn = c_null_ptr
  end type

  type, bind(c) :: duckdb_prepared_statement
    type(c_ptr) :: prep = c_null_ptr
  end type

  type, bind(c) :: duckdb_extracted_statements
    type(c_ptr) :: extrac = c_null_ptr
  end type

  type, bind(c) :: duckdb_pending_result
    type(c_ptr) :: pend = c_null_ptr
  end type

  type, bind(c) :: duckdb_appender
    type(c_ptr) :: appn = c_null_ptr
  end type

  type, bind(c) :: duckdb_arrow
    type(c_ptr) :: arrw = c_null_ptr
  end type

  type, bind(c) :: duckdb_config
    type(c_ptr) :: cnfg = c_null_ptr
  end type

  type, bind(c) :: duckdb_arrow_schema
    type(c_ptr) :: arrs = c_null_ptr
  end type

  type, bind(c) :: duckdb_arrow_array
    type(c_ptr) :: arra = c_null_ptr
  end type

  type, bind(c) :: duckdb_logical_type
    type(c_ptr) :: lglt = c_null_ptr
  end type

  type, bind(c) :: duckdb_data_chunk
    type(c_ptr) :: dtck = c_null_ptr
  end type

  type, bind(c) :: duckdb_vector
    type(c_ptr) :: vctr = c_null_ptr
  end type

  type, bind(c) :: duckdb_value
    type(c_ptr) :: val = c_null_ptr
  end type

  type, bind(c) :: duckdb_date
    integer(kind=c_int32_t) :: days
  end type

  type, bind(c) :: duckdb_date_struct
    integer(kind=c_int32_t) :: year
    integer(kind=c_int8_t) :: month
    integer(kind=c_int8_t) :: day
  end type

  type, bind(c) :: duckdb_time
   integer(kind=c_int64_t) :: micros
  end type

  type, bind(c) :: duckdb_time_struct
    integer(kind=c_int8_t) :: hour
    integer(kind=c_int8_t) :: min
    integer(kind=c_int8_t) :: sec
    integer(kind=c_int32_t) :: micros
  end type

  type, bind(c) :: duckdb_timestamp
   integer(kind=c_int64_t) :: micros
  end type

  type, bind(c) :: duckdb_timestamp_struct
    type(duckdb_date_struct) :: date
    type(duckdb_time_struct) :: time
  end type

  type, bind(c) :: duckdb_interval
    integer(kind=c_int32_t) :: months
    integer(kind=c_int32_t) :: days
    integer(kind=c_int64_t) :: micros
  end type

  type, bind(c) :: duckdb_hugeint
    integer(kind=c_int64_t) :: lower = 0
    integer(kind=c_int64_t) :: upper = 0
  end type

  type, bind(c) :: duckdb_decimal
    integer(kind=c_int8_t) :: width = 0
    integer(kind=c_int8_t) :: scale = 0
    type(duckdb_hugeint) :: value = duckdb_hugeint()
  end type

  type, bind(c) :: duckdb_string
    type(c_ptr) :: data = c_null_ptr
    integer(kind=c_int64_t) :: size = 0
  end type

  type, bind(c) :: duckdb_blob
    type(c_ptr) :: data = c_null_ptr
    integer(kind=c_int64_t) :: size = 0
  end type

  type, bind(c) :: duckdb_list_entry
    integer(kind=c_int64_t) :: offset = 0
    integer(kind=c_int64_t) :: length = 0
  end type

  type, bind(c) :: duckdb_column
    type(c_ptr) :: deprecated_data = c_null_ptr
    type(c_ptr) :: deprecated_nullmask = c_null_ptr
    integer(kind(duckdb_type)) :: deprecated_type = duckdb_type_invalid
    type(c_ptr) :: deprecated_name = c_null_ptr
    type(c_ptr) :: internal_data = c_null_ptr
  end type

  type, bind(c) :: duckdb_result
    integer(kind=c_int64_t) :: deprecated_column_count = 0
    integer(kind=c_int64_t) :: deprecated_row_count = 0
    integer(kind=c_int64_t) :: deprecated_rows_changed = 0
    type(c_ptr) :: deprecated_columns = c_null_ptr
    type(c_ptr) :: deprecated_error_message = c_null_ptr
    type(c_ptr) :: internal_data = c_null_ptr
  end type

  ! from vector_size.hpp
  integer, parameter :: STANDARD_VECTOR_SIZE = 2048

  interface !******************************************************************

    function c_strlen(str) bind(c, name='strlen')
      import :: c_ptr, c_size_t
      type(c_ptr), value :: str
      integer(c_size_t) :: c_strlen
    end function c_strlen

    ! =========================================================================
    ! Open/Connect
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_open(const char *path, duckdb_database *db);
    function duckdb_open_char(path, db) &
    & bind(c, name='duckdb_open') result(res)
      import :: duckdb_state, c_char, duckdb_database
      integer(kind(duckdb_state)) :: res
      character(kind=c_char) :: path
      type(duckdb_database) :: db
    end function duckdb_open_char

    function duckdb_open_ptr(path, db) &
    & bind(c, name='duckdb_open') result(res)
      import :: duckdb_state, c_char, c_ptr, duckdb_database
      integer(kind(duckdb_state)) :: res
      type(c_ptr) ::  path
      type(duckdb_database) :: db
    end function duckdb_open_ptr

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_open_ext(const char *path, duckdb_database *db,
    ! duckdb_config config,char **out_error);
    function duckdb_open_ext_(path, db, config, out_error) &
    & bind(c, name='duckdb_open_ext') result(res)
      import :: duckdb_state, c_char, duckdb_database, duckdb_config, c_ptr
      integer(kind(duckdb_state)) :: res
      character(kind=c_char) :: path
      type(duckdb_database) :: db
      type(duckdb_config), value :: config
      type(c_ptr) :: out_error
    end function duckdb_open_ext_

    ! DUCKDB_API
    ! void
    ! duckdb_close(duckdb_database *database);
    subroutine duckdb_close(database) bind(c, name='duckdb_close')
      import :: duckdb_database
      type(duckdb_database) :: database
    end subroutine duckdb_close

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_connect(duckdb_database database,
    ! duckdb_connection *out_connection);
    function duckdb_connect(database, out_connection) &
    & bind(c, name='duckdb_connect') result(res)
      import :: duckdb_state, duckdb_database, duckdb_connection
      integer(kind(duckdb_state)) :: res
      type(duckdb_database), value :: database
      type(duckdb_connection) :: out_connection
    end function duckdb_connect

    ! DUCKDB_API
    ! void
    ! duckdb_disconnect(duckdb_connection *connection);
    subroutine duckdb_disconnect(connection) &
    & bind(c, name='duckdb_disconnect')
      import :: duckdb_connection
      type(duckdb_connection) :: connection
    end subroutine duckdb_disconnect

    ! DUCKDB_API
    ! const char
    ! *duckdb_library_version();
    function duckdb_library_version_() &
    & bind(c, name='duckdb_library_version') result(res)
      import :: c_ptr
      type(c_ptr) :: res
    end function duckdb_library_version_

    ! =========================================================================
    ! Configuration
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_create_config(duckdb_config *out_config);
    function duckdb_create_config(out_config) &
    & bind(c, name='duckdb_create_config') result(res)
      import :: duckdb_state, duckdb_config
      integer(kind(duckdb_state)) :: res
      type(duckdb_config) :: out_config
    end function duckdb_create_config

    ! DUCKDB_API
    ! size_t
    ! duckdb_config_count();
    function duckdb_config_count_() &
    & bind(c, name='duckdb_config_count') result(res)
      import :: c_size_t
      integer(kind=c_size_t) :: res
    end function duckdb_config_count_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_get_config_flag(size_t index, const char **out_name,
    ! const char **out_description);
    function duckdb_get_config_flag_(idx, out_name, out_description) &
    & bind(c, name='duckdb_get_config_flag') result(res)
      import :: duckdb_state, c_size_t, c_ptr
      integer(kind(duckdb_state)) :: res
      integer(kind=c_size_t), value :: idx
      type(c_ptr) :: out_name
      type(c_ptr) :: out_description
    end function duckdb_get_config_flag_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_set_config(duckdb_config config, const char *name,
    ! const char *option);
    function duckdb_set_config_(config, name, option) &
    & bind(c, name='duckdb_set_config') result(res)
      import :: duckdb_state, duckdb_config, c_char
      integer(kind(duckdb_state)) :: res
      type(duckdb_config), value :: config
      character(c_char) :: name
      character(c_char) :: option
    end function duckdb_set_config_

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_config(duckdb_config *config);
    subroutine duckdb_destroy_config(config) &
    & bind(c, name='duckdb_destroy_config')
      import :: duckdb_config
      type(duckdb_config) :: config
    end subroutine duckdb_destroy_config

    ! =========================================================================
    ! Query Execution
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_query(duckdb_connection connection, const char *query,
    ! duckdb_result *out_result);
    function duckdb_query_(connection, query, out_result) &
    & bind(c, name='duckdb_query') result(res)
      import :: duckdb_state, duckdb_connection, duckdb_result, c_char
      integer(kind(duckdb_state)) :: res
      type(duckdb_connection), value :: connection
      character(kind=c_char) :: query ! must be a c string
      type(duckdb_result) :: out_result
    end function duckdb_query_

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_result(duckdb_result *result);
    subroutine duckdb_destroy_result(res) &
    & bind(c, name='duckdb_destroy_result')
      import :: duckdb_result
      type(duckdb_result) :: res
    end subroutine duckdb_destroy_result

    ! DUCKDB_API
    ! const char
    ! *duckdb_column_name(duckdb_result *result, idx_t col);
    function duckdb_column_name_(res, col) &
    & bind(c, name='duckdb_column_name') result(name)
      import :: c_ptr, duckdb_result, c_int64_t
      type(c_ptr) :: name
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col
    end function duckdb_column_name_

    ! DUCKDB_API
    ! duckdb_type
    ! duckdb_column_type(duckdb_result *result, idx_t col);
    function duckdb_column_type_(res, col) &
    & bind(c, name='duckdb_column_type') result(col_type)
      import :: duckdb_result, duckdb_type, c_int64_t
      integer(kind(duckdb_type)) :: col_type
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col
    end function duckdb_column_type_

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_column_logical_type(duckdb_result *result, idx_t col);
    function duckdb_column_logical_type_(res, idx) &
    & bind(c, name='duckdb_column_logical_type') result(t)
      import :: duckdb_result, duckdb_logical_type, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: idx
      type(duckdb_logical_type) :: t
    end function duckdb_column_logical_type_

    ! DUCKDB_API
    ! idx_t
    ! duckdb_column_count(duckdb_result *result);
    function duckdb_column_count_(res) &
    & bind(c, name='duckdb_column_count') result(cc)
      import :: duckdb_result, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t) :: cc
    end function duckdb_column_count_

    ! DUCKDB_API
    ! idx_t
    ! duckdb_row_count(duckdb_result *result);
    function duckdb_row_count_(res) &
    & bind(c, name='duckdb_row_count') result(rc)
      import :: duckdb_result, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t) :: rc
    end function duckdb_row_count_

    ! DUCKDB_API
    ! idx_t
    ! duckdb_rows_changed(duckdb_result *result);
    function duckdb_rows_changed_(res) &
    & bind(c, name='duckdb_rows_changed') result(rc)
      import :: duckdb_result, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t) :: rc
    end function duckdb_rows_changed_

    ! DUCKDB_API
    ! void
    ! *duckdb_column_data(duckdb_result *result, idx_t col);
    function duckdb_column_data_(res, col) &
    & bind(c, name='duckdb_column_data') result(data)
      import :: duckdb_result, c_int64_t, c_ptr
      type(c_ptr) :: data
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col
    end function duckdb_column_data_

    ! DUCKDB_API
    ! bool
    ! *duckdb_nullmask_data(duckdb_result *result, idx_t col);
    function duckdb_nullmask_data_(res, col) &
    & bind(c, name='duckdb_nullmask_data') result(ptr)
      import :: duckdb_result, c_int64_t, c_ptr
      type(c_ptr) :: ptr
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col
    end function duckdb_nullmask_data_

    ! DUCKDB_API
    ! const char
    ! *duckdb_result_error(duckdb_result *result);
    function duckdb_result_error_(res) &
    & bind(c, name='duckdb_result_error') result(err)
      import :: c_ptr, duckdb_result
      type(duckdb_result) :: res
      type(c_ptr) :: err
    end function duckdb_result_error_

    ! =========================================================================
    ! Result Functions
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_data_chunk
    ! duckdb_result_get_chunk(duckdb_result result, idx_t chunk_index);
    function duckdb_result_get_chunk_(res, idx) &
    & bind(c, name='duckdb_result_get_chunk') result(chunk)
      import :: c_int64_t, duckdb_result, duckdb_data_chunk
      type(duckdb_result), value :: res
      integer(kind=c_int64_t), value :: idx
      type(duckdb_data_chunk) :: chunk
    end function duckdb_result_get_chunk_

    ! DUCKDB_API
    ! idx_t
    ! duckdb_result_chunk_count(duckdb_result result);
    function duckdb_result_chunk_count_(res) &
    & bind(c, name='duckdb_result_chunk_count') result(cc)
      import :: c_int64_t, duckdb_result
      type(duckdb_result), value :: res
      integer(kind=c_int64_t) :: cc
    end function duckdb_result_chunk_count_

    ! DUCKDB_API
    ! bool
    ! duckdb_value_boolean(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_boolean_(res, col, row) &
    & bind(c, name='duckdb_value_boolean') result(r)
      import :: duckdb_result, c_bool, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      logical(kind=c_bool) :: r
    end function duckdb_value_boolean_

    ! DUCKDB_API
    ! int8_t
    ! duckdb_value_int8(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_int8_(res, col, row) &
    & bind(c, name='duckdb_value_int8') result(r)
      import :: duckdb_result, c_int8_t, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      integer(kind=c_int8_t) :: r
    end function duckdb_value_int8_

    ! DUCKDB_API
    ! int16_t
    ! duckdb_value_int16(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_int16_(res, col, row) &
    & bind(c, name='duckdb_value_int16') result(r)
      import :: duckdb_result, c_int16_t, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      integer(kind=c_int16_t) :: r
    end function duckdb_value_int16_

    ! DUCKDB_API
    ! int32_t
    ! duckdb_value_int32(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_int32_(res, col, row) &
    & bind(c, name='duckdb_value_int32') result(r)
      import :: duckdb_result, c_int32_t, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      integer(kind=c_int32_t) :: r
    end function duckdb_value_int32_

    ! DUCKDB_API
    ! int64_t
    ! duckdb_value_int64(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_int64_(res, col, row) &
    & bind(c, name='duckdb_value_int64') result(r)
      import :: duckdb_result, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      integer(kind=c_int64_t) :: r
    end function duckdb_value_int64_

    ! DUCKDB_API
    ! duckdb_hugeint
    ! duckdb_value_hugeint(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_hugeint_(res, col, row) &
    & bind(c, name='duckdb_value_hugeint') result(r)
      import :: duckdb_result, c_ptr, c_int64_t, duckdb_hugeint
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(duckdb_hugeint) :: r
    end function duckdb_value_hugeint_

    ! DUCKDB_API
    ! duckdb_decimal
    ! duckdb_value_decimal(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_decimal_(res, col, row) &
    & bind(c, name='duckdb_value_decimal') result(r)
      import :: duckdb_result, c_ptr, c_int64_t, duckdb_decimal
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(duckdb_decimal) :: r
    end function duckdb_value_decimal_

    ! NOTE: Fortran doesn't currently have an unsigned integer definition.
    !       Use the signed versions of these functions above.

    ! DUCKDB_API
    ! uint8_t
    ! duckdb_value_uint8(duckdb_result *result, idx_t col, idx_t row);

    ! DUCKDB_API
    ! uint16_t
    ! duckdb_value_uint16(duckdb_result *result, idx_t col, idx_t row);

    ! DUCKDB_API
    ! uint32_t
    ! duckdb_value_uint32(duckdb_result *result, idx_t col, idx_t row);

    ! DUCKDB_API
    ! uint64_t
    ! duckdb_value_uint64(duckdb_result *result, idx_t col, idx_t row);

    ! DUCKDB_API
    ! float
    ! duckdb_value_float(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_float_(res, col, row) &
    & bind(c, name='duckdb_value_float') result(r)
      import :: duckdb_result, c_float, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      real(kind=c_float) :: r
    end function duckdb_value_float_

    ! DUCKDB_API
    ! double
    ! duckdb_value_double(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_double_(res, col, row) &
    & bind(c, name='duckdb_value_double') result(r)
      import :: duckdb_result, c_double, c_int64_t
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      real(kind=c_double) :: r
    end function duckdb_value_double_

    ! DUCKDB_API
    ! duckdb_date
    ! duckdb_value_date(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_date_(res, col, row) &
    & bind(c, name='duckdb_value_date') result(r)
      import :: duckdb_result, c_int64_t, duckdb_date
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(duckdb_date) :: r
    end function duckdb_value_date_

    ! DUCKDB_API
    ! duckdb_time
    ! duckdb_value_time(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_time_(res, col, row) &
    & bind(c, name='duckdb_value_time') result(r)
      import :: duckdb_result, c_int64_t, duckdb_time
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(duckdb_time) :: r
    end function duckdb_value_time_

    ! DUCKDB_API
    ! duckdb_timestamp
    ! duckdb_value_timestamp(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_timestamp_(res, col, row) &
    & bind(c, name='duckdb_value_timestamp') result(r)
      import :: duckdb_result, c_int64_t, duckdb_timestamp
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(duckdb_timestamp) :: r
    end function duckdb_value_timestamp_

    ! DUCKDB_API
    ! duckdb_interval
    ! duckdb_value_interval(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_interval_(res, col, row) &
    & bind(c, name='duckdb_value_interval') result(r)
      import :: duckdb_result, c_int64_t, duckdb_interval
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(duckdb_interval) :: r
    end function duckdb_value_interval_

    ! DUCKDB_API
    ! char
    ! *duckdb_value_varchar(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_varchar_(res, col, row) &
    & bind(c, name='duckdb_value_varchar') result(ptr)
      import :: duckdb_result, c_int64_t, c_ptr
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(c_ptr) :: ptr
    end function duckdb_value_varchar_

    ! DUCKDB_API
    ! duckdb_string
    ! duckdb_value_string(duckdb_result *result, idx_t col, idx_t row);
    ! NOTE: The result must be freed with `duckdb_free`.
    function duckdb_value_string_(res, col, row) &
    & bind(c, name='duckdb_value_string') result(r)
      import :: duckdb_result, c_int64_t, duckdb_string
      type(duckdb_result), intent(in) :: res
      integer(kind=c_int64_t), value :: col, row
      type(duckdb_string) :: r
    end function duckdb_value_string_

    ! DUCKDB_API
    ! char
    ! *duckdb_value_varchar_internal(duckdb_result *result, idx_t col,
    ! idx_t row);
    function duckdb_value_varchar_internal_(res, col, row) &
    & bind(c, name='duckdb_value_varchar_internal') result(ptr)
      import :: duckdb_result, c_int64_t, c_ptr
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(c_ptr) :: ptr
    end function duckdb_value_varchar_internal_

    ! DUCKDB_API
    ! duckdb_string
    ! duckdb_value_string_internal(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_string_internal_(res, col, row) &
    & bind(c, name='duckdb_value_string_internal') result(str)
      import :: duckdb_result, c_int64_t, duckdb_string
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(duckdb_string) :: str
    end function duckdb_value_string_internal_

    ! DUCKDB_API
    ! duckdb_blob
    ! duckdb_value_blob(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_blob_(res, col, row) &
    & bind(c, name='duckdb_value_blob') result(r)
      import :: duckdb_result, c_int64_t, duckdb_blob
      type(duckdb_result) :: res
      integer(kind=c_int64_t), value :: col, row
      type(duckdb_blob) :: r
    end function duckdb_value_blob_

    ! DUCKDB_API
    ! bool
    ! duckdb_value_is_null(duckdb_result *result, idx_t col, idx_t row);
    function duckdb_value_is_null_(res, col, row) &
    & bind(c, name='duckdb_value_is_null') result(r)
      import :: duckdb_result, c_bool, c_int64_t
      type(duckdb_result), intent(in) :: res
      integer(kind=c_int64_t), value :: col, row
      logical(kind=c_bool) :: r
    end function duckdb_value_is_null_

    ! =========================================================================
    ! Helpers
    ! =========================================================================

    ! DUCKDB_API
    ! void
    ! *duckdb_malloc(size_t size);
    function duckdb_malloc(siz) &
    & bind(c, name='duckdb_malloc') result(res)
      import :: c_ptr, c_size_t
      integer(kind=c_size_t) :: siz
      type(c_ptr) :: res
    end function duckdb_malloc

    ! DUCKDB_API
    ! void
    ! duckdb_free(void *ptr);
    subroutine duckdb_free(ptr) bind(c, name='duckdb_free')
      import :: c_ptr
      type(c_ptr), value :: ptr
    end subroutine duckdb_free

    ! DUCKDB_API
    ! idx_t
    ! duckdb_vector_size();
    function duckdb_vector_size_() &
    & bind(c, name='duckdb_vector_size') result(res)
      import :: c_int64_t
      integer(kind=c_int64_t) :: res
    end function duckdb_vector_size_

    ! =========================================================================
    ! Date/Time/Timestamp Helpers
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_date_struct
    ! duckdb_from_date(duckdb_date date);
    function duckdb_from_date(date) &
    & bind(c, name='duckdb_from_date') result(res)
      import :: duckdb_date, duckdb_date_struct
      type(duckdb_date), value :: date
      type(duckdb_date_struct) :: res
    end function duckdb_from_date

    ! DUCKDB_API
    ! duckdb_date
    ! duckdb_to_date(duckdb_date_struct date);
    function duckdb_to_date(date) &
    & bind(c, name='duckdb_to_date') result(res)
      import :: duckdb_date, duckdb_date_struct
      type(duckdb_date) :: res
      type(duckdb_date_struct), value :: date
    end function duckdb_to_date

    ! DUCKDB_API
    ! duckdb_time_struct
    ! duckdb_from_time(duckdb_time time);
    function duckdb_from_time(time) &
    & bind(c, name='duckdb_from_time') result(res)
      import :: duckdb_time, duckdb_time_struct
      type(duckdb_time), value :: time
      type(duckdb_time_struct) :: res
    end function duckdb_from_time

    ! DUCKDB_API
    ! duckdb_time
    ! duckdb_to_time(duckdb_time_struct time);
    function duckdb_to_time(time) &
    & bind(c, name='duckdb_to_time') result(res)
      import :: duckdb_time, duckdb_time_struct
      type(duckdb_time) :: res
      type(duckdb_time_struct), value :: time
    end function duckdb_to_time

    ! DUCKDB_API
    ! duckdb_timestamp_struct
    ! duckdb_from_timestamp(duckdb_timestamp ts);
    function duckdb_from_timestamp(ts) &
    & bind(c, name='duckdb_from_timestamp') result(res)
      import :: duckdb_timestamp, duckdb_timestamp_struct
      type(duckdb_timestamp), value :: ts
      type(duckdb_timestamp_struct) :: res
    end function duckdb_from_timestamp

    ! DUCKDB_API
    ! duckdb_timestamp
    ! duckdb_to_timestamp(duckdb_timestamp_struct ts);
    function duckdb_to_timestamp(ts) &
    & bind(c, name='duckdb_to_timestamp') result(res)
      import :: duckdb_timestamp, duckdb_timestamp_struct
      type(duckdb_timestamp) :: res
      type(duckdb_timestamp_struct), value :: ts
    end function duckdb_to_timestamp

    ! =========================================================================
    ! Hugeint Helpers
    ! =========================================================================

    ! DUCKDB_API
    ! double
    ! duckdb_hugeint_to_double(duckdb_hugeint val);
    function duckdb_hugeint_to_double_(val) &
    & bind(c, name='duckdb_hugeint_to_double') result(res)
      import :: c_double, duckdb_hugeint
      type(duckdb_hugeint), value :: val
      real(kind=c_double) :: res
    end function duckdb_hugeint_to_double_

    ! DUCKDB_API
    ! duckdb_hugeint
    ! duckdb_double_to_hugeint(double val);
    function duckdb_double_to_hugeint_(val) &
    & bind(c, name='duckdb_double_to_hugeint') result(res)
      import :: c_double, duckdb_hugeint
      type(duckdb_hugeint) :: res
      real(kind=c_double), value :: val
    end function duckdb_double_to_hugeint_

    ! DUCKDB_API
    ! duckdb_decimal
    ! duckdb_double_to_decimal(double val, uint8_t width, uint8_t scale);
    function duckdb_double_to_decimal_(val, width, scale) &
    & bind(c, name='duckdb_double_to_decimal') result(res)
      import :: c_double, c_int8_t, duckdb_decimal
      type(duckdb_decimal) :: res
      real(kind=c_double), value :: val
      integer(kind=c_int8_t), value :: width, scale
    end function duckdb_double_to_decimal_

    ! DUCKDB_API
    ! double
    ! duckdb_decimal_to_double(duckdb_decimal val);
    function duckdb_decimal_to_double_(val) &
    & bind(c, name='duckdb_decimal_to_double') result(res)
      import :: c_double, duckdb_decimal
      type(duckdb_decimal), value :: val
      real(kind=c_double) :: res
    end function duckdb_decimal_to_double_

    ! =========================================================================
    ! Prepared Statements
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_prepare(duckdb_connection connection, const char *query,
    ! duckdb_prepared_statement *out_prepared_statement);
    function duckdb_prepare_(connection, query, out_prepared_statement) &
    & bind(c, name='duckdb_prepare') result(res)
      import :: duckdb_state, duckdb_connection, duckdb_result, c_char, &
      & duckdb_prepared_statement
      integer(kind(duckdb_state)) :: res
      type(duckdb_connection), value :: connection
      character(kind=c_char) :: query ! must be a c string
      type(duckdb_prepared_statement) :: out_prepared_statement
    end function duckdb_prepare_

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_prepare(duckdb_prepared_statement *prepared_statement);
    subroutine duckdb_destroy_prepare(prepared_statement) &
    & bind(c, name='duckdb_destroy_prepare')
      import :: duckdb_prepared_statement
      type(duckdb_prepared_statement) :: prepared_statement
    end subroutine duckdb_destroy_prepare

    ! DUCKDB_API
    ! const char
    ! *duckdb_prepare_error(duckdb_prepared_statement prepared_statement);
    function duckdb_prepare_error_(prepared_statement) &
    & bind(c, name='duckdb_prepare_error') result(ptr)
      import :: duckdb_prepared_statement, c_ptr
      type(duckdb_prepared_statement), value :: prepared_statement
      type(c_ptr) :: ptr
    end function duckdb_prepare_error_

    ! DUCKDB_API
    ! idx_t
    ! duckdb_nparams(duckdb_prepared_statement prepared_statement);
    function duckdb_nparams_(ps) &
    & bind(c, name='duckdb_nparams') result(n)
      import :: duckdb_prepared_statement, c_int64_t
      type(duckdb_prepared_statement), value :: ps
      integer(kind=c_int64_t) :: n
    end function duckdb_nparams_

    ! DUCKDB_API
    ! duckdb_type
    ! duckdb_param_type(duckdb_prepared_statement prepared_statement,
    !                   idx_t param_idx);
    function duckdb_param_type_(prepared_statement, param_idx) &
    & bind(c, name='duckdb_param_type') result(res)
      import :: duckdb_type, duckdb_prepared_statement, c_int64_t
      integer(kind(duckdb_type)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
    end function duckdb_param_type_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_clear_bindings(duckdb_prepared_statement prepared_statement);
    function duckdb_clear_bindings(prepared_statement) &
    & bind(c, name='duckdb_clear_bindings') result(res)
      import :: duckdb_state, duckdb_prepared_statement
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
    end function duckdb_clear_bindings

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_boolean(duckdb_prepared_statement prepared_statement,
    !                     idx_t param_idx, bool val);
    function duckdb_bind_boolean_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_boolean') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, c_bool
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      logical(kind=c_bool), value :: val
    end function duckdb_bind_boolean_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_int8(duckdb_prepared_statement prepared_statement,
    !                  idx_t param_idx, int8_t val);
    function duckdb_bind_int8_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_int8') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int8_t, c_int64_t
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      integer(kind=c_int8_t), value :: val
    end function duckdb_bind_int8_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_int16(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, int16_t val);
    function duckdb_bind_int16_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_int16') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int16_t, c_int64_t
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      integer(kind=c_int16_t), value :: val
    end function duckdb_bind_int16_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_int32(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, int32_t val);
    function duckdb_bind_int32_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_int32') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int32_t, c_int64_t
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      integer(kind=c_int32_t), value :: val
    end function duckdb_bind_int32_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_int64(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, int64_t val);
    function duckdb_bind_int64_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_int64') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      integer(kind=c_int64_t), value :: val
    end function duckdb_bind_int64_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_hugeint(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, duckdb_hugeint val);
    function duckdb_bind_hugeint_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_hugeint') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, &
      & duckdb_hugeint
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      type(duckdb_hugeint), value :: val
    end function duckdb_bind_hugeint_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_decimal(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, duckdb_decimal val);
    function duckdb_bind_decimal_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_decimal') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, &
      & duckdb_decimal
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      type(duckdb_decimal), value :: val
    end function duckdb_bind_decimal_

    ! NOTE: Fortran doesn't currently have an unsigned integer definition.
    !       Use the signed versions of these functions above.

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_uint8(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, uint8_t val);

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_uint16(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, uint16_t val);

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_uint32(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, uint32_t val);

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_uint64(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, uint64_t val);

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_float(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, float val);
    function duckdb_bind_float_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_float') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, c_float
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      real(kind=c_float), value :: val
    end function duckdb_bind_float_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_double(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, double val);
    function duckdb_bind_double_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_double') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, c_double
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      real(kind=c_double), value :: val
    end function duckdb_bind_double_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_date(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, duckdb_date val);
    function duckdb_bind_date_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_date') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, duckdb_date
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      type(duckdb_date), value :: val
    end function duckdb_bind_date_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_time(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, duckdb_time val);
    function duckdb_bind_time_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_time') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, duckdb_time
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      type(duckdb_time), value :: val
    end function duckdb_bind_time_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_timestamp(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, duckdb_timestamp val);
    function duckdb_bind_timestamp_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_timestamp') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, &
      & duckdb_timestamp
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      type(duckdb_timestamp), value :: val
    end function duckdb_bind_timestamp_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_interval(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, duckdb_interval val);
    function duckdb_bind_interval_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_interval') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, &
      & duckdb_interval
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      type(duckdb_interval), value :: val
    end function duckdb_bind_interval_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_varchar(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, const char *val);
    function duckdb_bind_varchar_(prepared_statement, param_idx, val) &
    & bind(c, name='duckdb_bind_varchar') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, c_char
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
      character(kind=c_char) :: val
    end function duckdb_bind_varchar_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_varchar_length(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, const char *val, idx_t length);
    ! FIXME: shouldn't this be fixed on the c-api side to use duckdb_string
    !        instead - propose addressing in the helper function
    function duckdb_bind_varchar_length_(prepared_statement, param_idx, val, &
    & length) bind(c, name='duckdb_bind_varchar_length') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, c_char
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx, length
      character(kind=c_char) :: val
    end function duckdb_bind_varchar_length_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_blob(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx, const void *data, idx_t length);
    function duckdb_bind_blob_(prepared_statement, param_idx, data, length) &
    & bind(c, name='duckdb_bind_blob') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, c_ptr
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx, length
      type(c_ptr) :: data
    end function duckdb_bind_blob_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_bind_null(duckdb_prepared_statement prepared_statement,
    ! idx_t param_idx);
    function duckdb_bind_null_(prepared_statement, param_idx) &
    & bind(c, name='duckdb_bind_null') result(res)
      import :: duckdb_state, duckdb_prepared_statement, c_int64_t, c_char
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      integer(kind=c_int64_t), value :: param_idx
    end function duckdb_bind_null_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_execute_prepared(duckdb_prepared_statement prepared_statement,
    ! duckdb_result *out_result);
    function duckdb_execute_prepared(prepared_statement, out_result) &
    & bind(c, name='duckdb_execute_prepared') result(res)
      import :: duckdb_state, duckdb_prepared_statement, duckdb_result
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement), value :: prepared_statement
      type(duckdb_result) :: out_result
    end function duckdb_execute_prepared

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_execute_prepared_arrow(duckdb_prepared_statement
    ! prepared_statement, duckdb_arrow *out_result);

    ! =========================================================================
    ! Extract Statements
    ! =========================================================================

    ! DUCKDB_API
    ! idx_t
    ! duckdb_extract_statements(duckdb_connection connection, const char *query,
    ! duckdb_extracted_statements *out_extracted_statements);
    function duckdb_extract_statements_(connection, query, &
    & out_extracted_statements) bind(c, name='duckdb_extract_statements') &
    & result(res)
      import :: duckdb_connection, c_char, duckdb_extracted_statements, &
      & c_int64_t
      type(duckdb_connection), value :: connection
      character(kind=c_char) :: query
      type(duckdb_extracted_statements) :: out_extracted_statements
      integer(kind=c_int64_t) :: res
    end function duckdb_extract_statements_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_prepare_extracted_statement(duckdb_connection connection,
    ! duckdb_extracted_statements extracted_statements, idx_t index,
    ! duckdb_prepared_statement *out_prepared_statement);
    function duckdb_prepare_extracted_statement_(connection, &
    & extracted_statements, idx, out_prepared_statement) &
    & bind(c, name='duckdb_prepare_extracted_statement') result(res)
      import :: duckdb_connection, duckdb_prepared_statement, &
      & duckdb_extracted_statements, c_int64_t, duckdb_state
      type(duckdb_connection), value :: connection
      type(duckdb_extracted_statements), value :: extracted_statements
      type(duckdb_prepared_statement) :: out_prepared_statement
      integer(kind=c_int64_t), value :: idx
      integer(kind(duckdb_state)) :: res
    end function duckdb_prepare_extracted_statement_

    ! DUCKDB_API
    ! const char
    ! *duckdb_extract_statements_error(duckdb_extracted_statements
    ! extracted_statements);
    function duckdb_extract_statements_error_(extracted_statements) &
    & bind(c, name='duckdb_extract_statements_error') result(res)
      import :: duckdb_extracted_statements, c_ptr
      type(duckdb_extracted_statements), value :: extracted_statements
      type(c_ptr) :: res
    end function duckdb_extract_statements_error_

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_extracted(duckdb_extracted_statements
    ! *extracted_statements);
    subroutine duckdb_destroy_extracted(extracted_statements) &
    & bind(c, name='duckdb_destroy_extracted')
      import :: duckdb_extracted_statements
      type(duckdb_extracted_statements) :: extracted_statements
    end subroutine duckdb_destroy_extracted

    ! =========================================================================
    ! Pending Result Interface
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_pending_prepared(duckdb_prepared_statement prepared_statement,
    ! duckdb_pending_result *out_result);
    function duckdb_pending_prepared(prepared_statement, out_result) &
    & bind(c, name='duckdb_pending_prepared') result(res)
      import :: duckdb_prepared_statement, duckdb_pending_result, duckdb_state
      type(duckdb_prepared_statement), value :: prepared_statement
      type(duckdb_pending_result) :: out_result
      integer(kind(duckdb_state)) :: res
    end function duckdb_pending_prepared

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_pending(duckdb_pending_result *pending_result);
    subroutine duckdb_destroy_pending(pending_result) &
    & bind(c, name='duckdb_destroy_pending')
      import :: duckdb_pending_result
      type(duckdb_pending_result) :: pending_result
    end subroutine duckdb_destroy_pending

    ! DUCKDB_API
    ! const char
    ! *duckdb_pending_error(duckdb_pending_result pending_result);
    function duckdb_pending_error_(pending_result) &
    & bind(c, name='duckdb_pending_error') result(err)
      import :: c_ptr, duckdb_pending_result
      type(duckdb_pending_result), value :: pending_result
      type(c_ptr) :: err
    end function duckdb_pending_error_

    ! DUCKDB_API
    ! duckdb_pending_state
    ! duckdb_pending_execute_task(duckdb_pending_result pending_result);
    function duckdb_pending_execute_task(pending_result) &
    & bind(c, name='duckdb_pending_execute_task') result(res)
      import :: duckdb_pending_result, duckdb_pending_state
      type(duckdb_pending_result), value :: pending_result
      integer(kind(duckdb_pending_state)) :: res
    end function duckdb_pending_execute_task

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_execute_pending(duckdb_pending_result pending_result,
    ! duckdb_result *out_result);
    function duckdb_execute_pending(pending_result, out_result) &
    & bind(c, name='duckdb_execute_pending') result(res)
      import :: duckdb_pending_result, duckdb_state, duckdb_result
      type(duckdb_pending_result), value :: pending_result
      type(duckdb_result) :: out_result
      integer(kind(duckdb_state)) :: res
    end function duckdb_execute_pending

    ! =========================================================================
    ! Value Interface
    ! =========================================================================

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_value(duckdb_value *value);

    ! DUCKDB_API
    ! duckdb_value
    ! duckdb_create_varchar(const char *text);

    ! DUCKDB_API
    ! duckdb_value
    ! duckdb_create_varchar_length(const char *text, idx_t length);

    ! DUCKDB_API
    ! duckdb_value
    ! duckdb_create_int64(int64_t val);

    ! DUCKDB_API
    ! char
    ! *duckdb_get_varchar(duckdb_value value);

    ! DUCKDB_API
    ! int64_t
    ! duckdb_get_int64(duckdb_value value);


    ! =========================================================================
    ! Logical Type Interface
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_create_logical_type(duckdb_type type);
    function duckdb_create_logical_type(typ) &
    & bind(c, name='duckdb_create_logical_type') result(res)
      import :: duckdb_logical_type, duckdb_type
      integer(kind(duckdb_type)), value :: typ
      type(duckdb_logical_type) :: res
    end function duckdb_create_logical_type

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_create_list_type(duckdb_logical_type type);
    function duckdb_create_list_type(typ) &
    & bind(c, name='duckdb_create_list_type') result(res)
      import :: duckdb_logical_type
      type(duckdb_logical_type), value :: typ
      type(duckdb_logical_type) :: res
    end function duckdb_create_list_type

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_create_map_type(duckdb_logical_type key_type,
    ! duckdb_logical_type value_type);
    function duckdb_create_map_type(key_type, value_type) &
    & bind(c, name='duckdb_create_map_type') result(res)
      import :: duckdb_logical_type
      type(duckdb_logical_type), value :: key_type, value_type
      type(duckdb_logical_type) :: res
    end function duckdb_create_map_type

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_create_union_type(duckdb_logical_type member_types,
    ! const char **member_names, idx_t member_count);
    function duckdb_create_union_type_(member_types, member_names, &
    & member_counts) bind(c, name='duckdb_create_union_type') result(res)
      import :: duckdb_logical_type, c_ptr, c_int64_t
      type(duckdb_logical_type), value :: member_types
      type(c_ptr) :: member_names
      integer(kind=c_int64_t), value :: member_counts
      type(duckdb_logical_type) :: res
    end function duckdb_create_union_type_

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_create_decimal_type(uint8_t width, uint8_t scale);
    function duckdb_create_decimal_type_(width, scale) &
    & bind(c, name='duckdb_create_decimal_type') result(res)
      import :: duckdb_logical_type, c_int8_t
      integer(kind=c_int8_t), value :: width, scale
      type(duckdb_logical_type) :: res
    end function duckdb_create_decimal_type_

    ! DUCKDB_API
    ! duckdb_type
    ! duckdb_get_type_id(duckdb_logical_type type);
    function duckdb_get_type_id(typ) &
    & bind(c, name="duckdb_get_type_id") result(res)
      import :: duckdb_logical_type, duckdb_type
      type(duckdb_logical_type), value :: typ
      integer(kind(duckdb_type)) :: res
    end function duckdb_get_type_id

    ! DUCKDB_API
    ! uint8_t
    ! duckdb_decimal_width(duckdb_logical_type type);
    function duckdb_decimal_width_(typ) &
    & bind(c, name='duckdb_decimal_width') result(res)
      import :: duckdb_logical_type, c_int8_t
      type(duckdb_logical_type), value :: typ
      integer(kind=c_int8_t) :: res
    end function duckdb_decimal_width_

    ! DUCKDB_API
    ! uint8_t
    ! duckdb_decimal_scale(duckdb_logical_type type);
    function duckdb_decimal_scale_(typ) &
    & bind(c, name='duckdb_decimal_scale') result(res)
      import :: duckdb_logical_type, c_int8_t
      type(duckdb_logical_type), value :: typ
      integer(kind=c_int8_t) :: res
    end function duckdb_decimal_scale_

    ! DUCKDB_API
    ! duckdb_type
    ! duckdb_decimal_internal_type(duckdb_logical_type type);
    function duckdb_decimal_internal_type(typ) &
    & bind(c, name="duckdb_decimal_internal_type") result(res)
      import :: duckdb_logical_type, duckdb_type
      type(duckdb_logical_type), value :: typ
      integer(kind(duckdb_type)) :: res
    end function duckdb_decimal_internal_type

    ! DUCKDB_API
    ! duckdb_type
    ! duckdb_enum_internal_type(duckdb_logical_type type);
    function duckdb_enum_internal_type(typ) &
    & bind(c, name="duckdb_enum_internal_type") result(res)
      import :: duckdb_logical_type, duckdb_type
      type(duckdb_logical_type), value :: typ
      integer(kind(duckdb_type)) :: res
    end function duckdb_enum_internal_type

    ! DUCKDB_API
    ! uint32_t
    ! duckdb_enum_dictionary_size(duckdb_logical_type type);
    function duckdb_enum_dictionary_size_(typ) &
    & bind(c, name='duckdb_enum_dictionary_size') result(res)
      import :: duckdb_logical_type, c_int32_t
      type(duckdb_logical_type), value :: typ
      integer(kind=c_int32_t) :: res
    end function duckdb_enum_dictionary_size_

    ! DUCKDB_API
    ! char
    ! *duckdb_enum_dictionary_value(duckdb_logical_type type, idx_t index);
    function duckdb_enum_dictionary_value_(typ, idx) &
    & bind(c, name="duckdb_enum_dictionary_value") result(res)
      import :: duckdb_logical_type, c_ptr, c_int64_t
      type(duckdb_logical_type), value :: typ
      integer(kind=c_int64_t), value :: idx
      type(c_ptr) :: res
    end function duckdb_enum_dictionary_value_

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_list_type_child_type(duckdb_logical_type type);
    function duckdb_list_type_child_type(typ) &
    & bind(c, name="duckdb_list_type_child_type") result(res)
      import :: duckdb_logical_type
      type(duckdb_logical_type), value :: typ
      type(duckdb_logical_type) :: res
    end function duckdb_list_type_child_type

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_map_type_key_type(duckdb_logical_type type);
    function duckdb_map_type_key_type(typ) &
    & bind(c, name="duckdb_map_type_key_type") result(res)
      import :: duckdb_logical_type
      type(duckdb_logical_type), value :: typ
      type(duckdb_logical_type) :: res
    end function duckdb_map_type_key_type

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_map_type_value_type(duckdb_logical_type type);
    function duckdb_map_type_value_type(typ) &
    & bind(c, name="duckdb_map_type_value_type") result(res)
      import :: duckdb_logical_type
      type(duckdb_logical_type), value :: typ
      type(duckdb_logical_type) :: res
    end function duckdb_map_type_value_type

    ! DUCKDB_API
    ! idx_t
    ! duckdb_struct_type_child_count(duckdb_logical_type type);
    function duckdb_struct_type_child_count_(typ) &
    & bind(c, name="duckdb_struct_type_child_count") result(res)
      import :: duckdb_logical_type, c_int64_t
      type(duckdb_logical_type), value :: typ
      integer(kind=c_int64_t) :: res
    end function duckdb_struct_type_child_count_

    ! DUCKDB_API
    ! char
    ! *duckdb_struct_type_child_name(duckdb_logical_type type, idx_t index);
    function duckdb_struct_type_child_name_(typ, idx) &
    & bind(c, name="duckdb_struct_type_child_name") result(res)
      import :: duckdb_logical_type, c_int64_t, c_ptr
      type(duckdb_logical_type), value :: typ
      integer(kind=c_int64_t), value :: idx
      type(c_ptr) :: res
    end function duckdb_struct_type_child_name_

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_struct_type_child_type(duckdb_logical_type type, idx_t index);
    function duckdb_struct_type_child_type_(typ, idx) &
    & bind(c, name="duckdb_struct_type_child_type") result(res)
      import :: duckdb_logical_type, c_int64_t
      type(duckdb_logical_type), value :: typ
      integer(kind=c_int64_t), value :: idx
      type(duckdb_logical_type) :: res
    end function duckdb_struct_type_child_type_

    ! DUCKDB_API
    ! idx_t
    ! duckdb_union_type_member_count(duckdb_logical_type type);

    ! DUCKDB_API
    ! char
    ! *duckdb_union_type_member_name(duckdb_logical_type type, idx_t index);

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_union_type_member_type(duckdb_logical_type type, idx_t index);

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_logical_type(duckdb_logical_type *type);
    subroutine duckdb_destroy_logical_type(type) &
    & bind(c, name='duckdb_destroy_logical_type')
      import :: duckdb_logical_type
      type(duckdb_logical_type) :: type
    end subroutine duckdb_destroy_logical_type

    ! =========================================================================
    ! Data Chunk Interface
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_data_chunk
    ! duckdb_create_data_chunk(duckdb_logical_type *types, idx_t column_count);
    function duckdb_create_data_chunk_(types, column_count) &
    & bind(c, name='duckdb_create_data_chunk') result(res)
      import :: duckdb_data_chunk, duckdb_logical_type, c_int64_t
      type(duckdb_logical_type) :: types(*)
      integer(kind=c_int64_t), value :: column_count
      type(duckdb_data_chunk) :: res
    end function duckdb_create_data_chunk_

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_data_chunk(duckdb_data_chunk *chunk);
    subroutine duckdb_destroy_data_chunk(chunk) &
    & bind(c, name='duckdb_destroy_data_chunk')
      import :: duckdb_data_chunk
      type(duckdb_data_chunk) :: chunk
    end subroutine duckdb_destroy_data_chunk

    ! DUCKDB_API
    ! void
    ! duckdb_data_chunk_reset(duckdb_data_chunk chunk);
    subroutine duckdb_data_chunk_reset(chunk) &
    & bind(c, name='duckdb_data_chunk_reset')
      import :: duckdb_data_chunk
      type(duckdb_data_chunk), value :: chunk
    end subroutine duckdb_data_chunk_reset

    ! DUCKDB_API
    ! idx_t
    ! duckdb_data_chunk_get_column_count(duckdb_data_chunk chunk);
    function duckdb_data_chunk_get_column_count_(chunk) &
    & bind(c, name='duckdb_data_chunk_get_column_count') result(res)
      import :: duckdb_data_chunk, c_int64_t
      type(duckdb_data_chunk), value :: chunk
      integer(kind=c_int64_t) :: res
    end function duckdb_data_chunk_get_column_count_

    ! DUCKDB_API
    ! duckdb_vector
    ! duckdb_data_chunk_get_vector(duckdb_data_chunk chunk, idx_t col_idx);
    function duckdb_data_chunk_get_vector_(chunk, col_idx) &
    & bind(c, name='duckdb_data_chunk_get_vector') result(res)
      import :: duckdb_data_chunk, duckdb_vector, c_int64_t
      type(duckdb_data_chunk), value, intent(in) :: chunk
      integer(kind=c_int64_t), value :: col_idx
      type(duckdb_vector) :: res
    end function duckdb_data_chunk_get_vector_

    ! DUCKDB_API
    ! idx_t
    ! duckdb_data_chunk_get_size(duckdb_data_chunk chunk);
    function duckdb_data_chunk_get_size_(chunk) &
    & bind(c, name='duckdb_data_chunk_get_size') result(res)
      import :: duckdb_data_chunk, c_int64_t
      type(duckdb_data_chunk), value :: chunk
      integer(kind=c_int64_t) :: res
    end function duckdb_data_chunk_get_size_

    ! DUCKDB_API
    ! void
    ! duckdb_data_chunk_set_size(duckdb_data_chunk chunk, idx_t size);
    subroutine duckdb_data_chunk_set_size_(chunk, siz) &
    & bind(c, name='duckdb_data_chunk_set_size')
      import :: duckdb_data_chunk, c_int64_t
      type(duckdb_data_chunk), value :: chunk
      integer(kind=c_int64_t), value :: siz
    end subroutine duckdb_data_chunk_set_size_

    ! =========================================================================
    ! Vector Interface
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_logical_type
    ! duckdb_vector_get_column_type(duckdb_vector vector);
    function duckdb_vector_get_column_type(vector) &
    & bind(c, name='duckdb_vector_get_column_type') result(res)
      import :: duckdb_vector, duckdb_logical_type
      type(duckdb_vector), value :: vector
      type(duckdb_logical_type) :: res
    end function duckdb_vector_get_column_type

    ! DUCKDB_API
    ! void
    ! *duckdb_vector_get_data(duckdb_vector vector);
    function duckdb_vector_get_data(vector) &
    & bind(c, name='duckdb_vector_get_data') result(res)
      import :: duckdb_vector, c_ptr
      type(duckdb_vector), value :: vector
      type(c_ptr) :: res
    end function duckdb_vector_get_data

    ! DUCKDB_API
    ! uint64_t
    ! *duckdb_vector_get_validity(duckdb_vector vector);
    function duckdb_vector_get_validity(vector) &
    & bind(c, name='duckdb_vector_get_validity') result(res)
      import :: duckdb_vector, c_int64_t, c_ptr
      type(duckdb_vector), value :: vector
      type(c_ptr) :: res
      ! integer(kind=c_int64_t) :: res
    end function duckdb_vector_get_validity

    ! DUCKDB_API
    ! void
    ! duckdb_vector_ensure_validity_writable(duckdb_vector vector);
    subroutine duckdb_vector_ensure_validity_writable(vector) &
    & bind(c, name='duckdb_vector_ensure_validity_writable')
      import :: duckdb_vector
      type(duckdb_vector), value :: vector
    end subroutine duckdb_vector_ensure_validity_writable

    ! DUCKDB_API
    ! void
    ! duckdb_vector_assign_string_element(duckdb_vector vector, idx_t index,
    ! const char *str);
    subroutine duckdb_vector_assign_string_element_(vector, index, str) &
    & bind(c, name='duckdb_vector_assign_string_element')
      import :: duckdb_vector, c_char, c_int64_t
      type(duckdb_vector), value :: vector
      integer(kind=c_int64_t), value :: index
      character(kind=c_char) :: str
    end subroutine duckdb_vector_assign_string_element_

    ! DUCKDB_API
    ! void
    ! duckdb_vector_assign_string_element_len(duckdb_vector vector, idx_t index,
    ! const char *str, idx_t str_len);
    subroutine duckdb_vector_assign_string_element_len_(vec, idx, str, slen) &
    & bind(c, name='duckdb_vector_assign_string_element_len')
      import :: duckdb_vector, c_char, c_int64_t
      type(duckdb_vector), value :: vec
      integer(kind=c_int64_t), value :: idx
      character(kind=c_char) :: str
      integer(kind=c_int64_t), value :: slen
    end subroutine duckdb_vector_assign_string_element_len_

    ! DUCKDB_API
    ! duckdb_vector
    ! duckdb_list_vector_get_child(duckdb_vector vector);
    function duckdb_list_vector_get_child(vector) &
    & bind(c, name='duckdb_list_vector_get_child') result(res)
      import :: duckdb_vector
      type(duckdb_vector), value :: vector
      type(duckdb_vector) :: res
    end function duckdb_list_vector_get_child

    ! DUCKDB_API
    ! idx_t
    ! duckdb_list_vector_get_size(duckdb_vector vector);
    function duckdb_list_vector_get_size_(vector) &
    & bind(c, name='duckdb_list_vector_get_size') result(res)
      import :: duckdb_vector, c_int64_t
      type(duckdb_vector), value :: vector
      integer(kind=c_int64_t) :: res
    end function duckdb_list_vector_get_size_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_list_vector_set_size(duckdb_vector vector, idx_t size);
    function duckdb_list_vector_set_size_(vector, size) &
    & bind(c, name='duckdb_list_vector_set_size') result(res)
      import :: duckdb_vector, c_int64_t, duckdb_state
      type(duckdb_vector), value :: vector
      integer(kind=c_int64_t), value :: size
      integer(kind(duckdb_state)) :: res
    end function duckdb_list_vector_set_size_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_list_vector_reserve(duckdb_vector vector, idx_t required_capacity);
    function duckdb_list_vector_reserve_(vector, required_capacity) &
    & bind(c, name='duckdb_list_vector_reserve') result(res)
      import :: duckdb_vector, c_int64_t, duckdb_state
      type(duckdb_vector), value :: vector
      integer(kind=c_int64_t), value :: required_capacity
      integer(kind(duckdb_state)) :: res
    end function duckdb_list_vector_reserve_

    ! DUCKDB_API
    ! duckdb_vector
    ! duckdb_struct_vector_get_child(duckdb_vector vector, idx_t index);
    function duckdb_struct_vector_get_child(vector, index) &
    & bind(c, name='duckdb_struct_vector_get_child') result(res)
      import :: duckdb_vector, c_int64_t, duckdb_state
      type(duckdb_vector), value :: vector
      type(duckdb_vector) :: res
      integer(kind=c_int64_t), value :: index
    end function duckdb_struct_vector_get_child

    ! =========================================================================
    ! Validity Mask Functions
    ! =========================================================================

    ! DUCKDB_API
    ! bool
    ! duckdb_validity_row_is_valid(uint64_t *validity, idx_t row);
    function duckdb_validity_row_is_valid_(validity, row) &
    & bind(c, name='duckdb_validity_row_is_valid') result(res)
      import :: c_bool, c_int64_t, c_ptr
      type(c_ptr), value :: validity
      integer(kind=c_int64_t), value :: row
      logical(kind=c_bool) :: res
    end function duckdb_validity_row_is_valid_

    ! DUCKDB_API
    ! void
    ! duckdb_validity_set_row_validity(uint64_t *validity, idx_t row,
    ! bool valid);
    subroutine duckdb_validity_set_row_validity_(validity, row, valid) &
    & bind(c, name='duckdb_validity_set_row_validity')
      import :: c_bool, c_int64_t, c_ptr
      type(c_ptr), value :: validity
      integer(kind=c_int64_t), value :: row
      logical(kind=c_bool), value :: valid
    end subroutine duckdb_validity_set_row_validity_

    ! DUCKDB_API
    ! void
    ! duckdb_validity_set_row_invalid(uint64_t *validity, idx_t row);
    subroutine duckdb_validity_set_row_invalid_(validity, row) &
    & bind(c, name='duckdb_validity_set_row_invalid')
      import :: c_int64_t, c_ptr
      type(c_ptr), value :: validity
      integer(kind=c_int64_t), value :: row
    end subroutine duckdb_validity_set_row_invalid_

    ! DUCKDB_API
    ! void
    ! duckdb_validity_set_row_valid(uint64_t *validity, idx_t row);
    subroutine duckdb_validity_set_row_valid_(validity, row) &
    & bind(c, name='duckdb_validity_set_row_valid')
      import :: c_int64_t, c_ptr
      type(c_ptr), value :: validity
      integer(kind=c_int64_t), value :: row
    end subroutine duckdb_validity_set_row_valid_

    ! =========================================================================
    ! Table Functions
    ! =========================================================================

    ! typedef void *duckdb_table_function;
    ! typedef void *duckdb_bind_info;
    ! typedef void *duckdb_init_info;
    ! typedef void *duckdb_function_info;

    ! typedef void (*duckdb_table_function_bind_t)(duckdb_bind_info info);
    ! typedef void (*duckdb_table_function_init_t)(duckdb_init_info info);
    ! typedef void (*duckdb_table_function_t)(duckdb_function_info info,
    ! duckdb_data_chunk output);
    ! typedef void (*duckdb_delete_callback_t)(void *data);

    ! DUCKDB_API
    ! duckdb_table_function
    ! duckdb_create_table_function();

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_table_function(duckdb_table_function *table_function);

    ! DUCKDB_API
    ! void
    ! duckdb_table_function_set_name(duckdb_table_function table_function,
    ! const char *name);

    ! DUCKDB_API
    ! void
    ! duckdb_table_function_add_parameter(duckdb_table_function table_function,
    ! duckdb_logical_type type);

    ! DUCKDB_API
    ! void
    ! duckdb_table_function_set_extra_info(duckdb_table_function table_function,
    ! void *extra_info, duckdb_delete_callback_t destroy);

    ! DUCKDB_API
    ! void
    ! duckdb_table_function_set_bind(duckdb_table_function table_function,
    ! duckdb_table_function_bind_t bind);

    ! DUCKDB_API
    ! void
    ! duckdb_table_function_set_init(duckdb_table_function table_function,
    ! duckdb_table_function_init_t init);

    ! DUCKDB_API
    ! void
    ! duckdb_table_function_set_local_init(duckdb_table_function table_function,
    ! duckdb_table_function_init_t init);

    ! DUCKDB_API
    ! void
    ! duckdb_table_function_set_function(duckdb_table_function table_function,
    ! duckdb_table_function_t function);

    ! DUCKDB_API
    ! void
    ! duckdb_table_function_supports_projection_pushdown(duckdb_table_function
    ! table_function, bool pushdown);

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_register_table_function(duckdb_connection con,
    ! duckdb_table_function function);

    ! =========================================================================
    ! Table Function Bind
    ! =========================================================================

    ! DUCKDB_API
    ! void
    ! *duckdb_bind_get_extra_info(duckdb_bind_info info);

    ! DUCKDB_API
    ! void
    ! duckdb_bind_add_result_column(duckdb_bind_info info, const char *name,
    ! duckdb_logical_type type);

    ! DUCKDB_API
    ! idx_t
    ! duckdb_bind_get_parameter_count(duckdb_bind_info info);

    ! DUCKDB_API
    ! duckdb_value
    ! duckdb_bind_get_parameter(duckdb_bind_info info, idx_t index);

    ! DUCKDB_API
    ! void
    ! duckdb_bind_set_bind_data(duckdb_bind_info info, void *bind_data,
    ! duckdb_delete_callback_t destroy);

    ! DUCKDB_API
    ! void
    ! duckdb_bind_set_cardinality(duckdb_bind_info info, idx_t cardinality,
    ! bool is_exact);

    ! DUCKDB_API
    ! void
    ! duckdb_bind_set_error(duckdb_bind_info info, const char *error);

    ! =========================================================================
    ! Table Function Init
    ! =========================================================================

    ! DUCKDB_API
    ! void
    ! *duckdb_init_get_extra_info(duckdb_init_info info);

    ! DUCKDB_API i
    ! void
    ! *duckdb_init_get_bind_data(duckdb_init_info info);

    ! DUCKDB_API
    ! void
    ! duckdb_init_set_init_data(duckdb_init_info info, void *init_data,
    ! duckdb_delete_callback_t destroy);

    ! DUCKDB_API
    ! idx_t
    ! duckdb_init_get_column_count(duckdb_init_info info);

    ! DUCKDB_API
    ! idx_t
    ! duckdb_init_get_column_index(duckdb_init_info info, idx_t column_index);

    ! DUCKDB_API
    ! void
    ! duckdb_init_set_max_threads(duckdb_init_info info, idx_t max_threads);

    ! DUCKDB_API
    ! void
    ! duckdb_init_set_error(duckdb_init_info info, const char *error);

    ! =========================================================================
    ! Table Function
    ! =========================================================================

    ! DUCKDB_API
    ! void
    ! *duckdb_function_get_extra_info(duckdb_function_info info);

    ! DUCKDB_API
    ! void
    ! *duckdb_function_get_bind_data(duckdb_function_info info);

    ! DUCKDB_API
    ! void
    ! *duckdb_function_get_init_data(duckdb_function_info info);

    ! DUCKDB_API
    ! void
    ! *duckdb_function_get_local_init_data(duckdb_function_info info);

    ! DUCKDB_API
    ! void
    ! duckdb_function_set_error(duckdb_function_info info, const char *error);

    ! =========================================================================
    ! Replacement Scans
    ! =========================================================================

    ! typedef void *duckdb_replacement_scan_info;

    ! typedef void (*duckdb_replacement_callback_t)(
    ! duckdb_replacement_scan_info info, const char *table_name, void *data);

    ! DUCKDB_API
    ! void
    ! duckdb_add_replacement_scan(
    ! duckdb_database db, duckdb_replacement_callback_t replacement,
    ! void *extra_data, duckdb_delete_callback_t delete_callback);

    ! DUCKDB_API
    ! void
    ! duckdb_replacement_scan_set_function_name(
    ! duckdb_replacement_scan_info info, const char *function_name);

    ! DUCKDB_API
    ! void
    ! duckdb_replacement_scan_add_parameter(
    ! duckdb_replacement_scan_info info, duckdb_value parameter);

    ! DUCKDB_API
    ! void
    ! duckdb_replacement_scan_set_error(
    ! duckdb_replacement_scan_info info, const char *error);

    ! =========================================================================
    ! Appender
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_appender_create(
    ! duckdb_connection connection, const char *schema, const char *table,
    ! duckdb_appender *out_appender);
    function duckdb_appender_create_(connection, schema, table, out_appender) &
      & bind(c, name='duckdb_appender_create') result(res)
      import :: duckdb_state, duckdb_connection, duckdb_appender, c_char
      integer(kind(duckdb_state)) :: res
      type(duckdb_connection), value :: connection
      character(kind=c_char) :: schema
      character(kind=c_char) :: table
      type(duckdb_appender) :: out_appender
    end function duckdb_appender_create_

    ! DUCKDB_API
    ! const char
    ! *duckdb_appender_error(duckdb_appender appender);
    function duckdb_appender_error_(appender) &
    & bind(c, name='duckdb_appender_error') result(err)
      import :: c_ptr, duckdb_appender
      type(duckdb_appender), value :: appender
      type(c_ptr) :: err
    end function duckdb_appender_error_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_appender_flush(duckdb_appender appender);
    function duckdb_appender_flush(appender) &
    & bind(c, name='duckdb_appender_flush') result(res)
      import :: duckdb_state, duckdb_appender
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
    end function duckdb_appender_flush

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_appender_close(duckdb_appender appender);
    function duckdb_appender_close(appender) &
    & bind(c, name='duckdb_appender_close') result(res)
      import :: duckdb_state, duckdb_appender
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
    end function duckdb_appender_close

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_appender_destroy(duckdb_appender *appender);
    function duckdb_appender_destroy(appender) &
    & bind(c, name='duckdb_appender_destroy') result(res)
      import :: duckdb_state, duckdb_appender
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: appender
    end function duckdb_appender_destroy

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_appender_begin_row(duckdb_appender appender);
    function duckdb_appender_begin_row(appender) &
    & bind(c, name='duckdb_appender_begin_row') result(res)
      import :: duckdb_state, duckdb_appender
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
    end function duckdb_appender_begin_row

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_appender_end_row(duckdb_appender appender);
    function duckdb_appender_end_row(appender) &
    & bind(c, name='duckdb_appender_end_row') result(res)
      import :: duckdb_state, duckdb_appender
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
    end function duckdb_appender_end_row

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_bool(duckdb_appender appender, bool value);
    function duckdb_append_bool_(appender, val) &
    & bind(c, name='duckdb_append_bool') result(res)
      import :: duckdb_state, duckdb_appender, c_bool
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      logical(kind=c_bool), value :: val
    end function duckdb_append_bool_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_int8(duckdb_appender appender, int8_t value);
    function duckdb_append_int8_(appender, val) &
    & bind(c, name='duckdb_append_int8') result(res)
      import :: duckdb_state, duckdb_appender, c_int8_t
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      integer(kind=c_int8_t), value :: val
    end function duckdb_append_int8_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_int16(duckdb_appender appender, int16_t value);
    function duckdb_append_int16_(appender, val) &
    & bind(c, name='duckdb_append_int16') result(res)
      import :: duckdb_state, duckdb_appender, c_int16_t
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      integer(kind=c_int16_t), value :: val
    end function duckdb_append_int16_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_int32(duckdb_appender appender, int32_t value);
    function duckdb_append_int32_(appender, val) &
    & bind(c, name='duckdb_append_int32') result(res)
      import :: duckdb_state, duckdb_appender, c_int32_t
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      integer(kind=c_int32_t), value :: val
    end function duckdb_append_int32_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_int64(duckdb_appender appender, int64_t value);
    function duckdb_append_int64_(appender, val) &
    & bind(c, name='duckdb_append_int64') result(res)
      import :: duckdb_state, duckdb_appender, c_int64_t
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      integer(kind=c_int64_t), value :: val
    end function duckdb_append_int64_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_hugeint(duckdb_appender appender, duckdb_hugeint value);
    function duckdb_append_hugeint(appender, val) &
    & bind(c, name='duckdb_append_hugeint') result(res)
      import :: duckdb_state, duckdb_appender, duckdb_hugeint
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      type(duckdb_hugeint), value :: val
    end function duckdb_append_hugeint

    ! NOTE: Fortran doesn't currently have an unsigned integer definition.
    !       Use the signed versions of these functions above.

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_uint8(duckdb_appender appender, uint8_t value);

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_uint16(duckdb_appender appender, uint16_t value);

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_uint32(duckdb_appender appender, uint32_t value);

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_uint64(duckdb_appender appender, uint64_t value);

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_float(duckdb_appender appender, float value);
    function duckdb_append_float_(appender, val) &
    & bind(c, name='duckdb_append_float') result(res)
      import :: duckdb_state, duckdb_appender, c_float
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      real(kind=c_float), value :: val
    end function duckdb_append_float_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_double(duckdb_appender appender, double value);
    function duckdb_append_double_(appender, val) &
    & bind(c, name='duckdb_append_double') result(res)
      import :: duckdb_state, duckdb_appender, c_double
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      real(kind=c_double), value :: val
    end function duckdb_append_double_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_date(duckdb_appender appender, duckdb_date value);
    function duckdb_append_date(appender, val) &
    & bind(c, name='duckdb_append_date') result(res)
      import :: duckdb_state, duckdb_appender, duckdb_date
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      type(duckdb_date), value :: val
    end function duckdb_append_date

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_time(duckdb_appender appender, duckdb_time value);
    function duckdb_append_time(appender, val) &
    & bind(c, name='duckdb_append_time') result(res)
      import :: duckdb_state, duckdb_appender, duckdb_time
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      type(duckdb_time), value :: val
    end function duckdb_append_time

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_timestamp(duckdb_appender appender, duckdb_timestamp value);
    function duckdb_append_timestamp(appender, val) &
    & bind(c, name='duckdb_append_timestamp') result(res)
      import :: duckdb_state, duckdb_appender, duckdb_timestamp
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      type(duckdb_timestamp), value :: val
    end function duckdb_append_timestamp

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_interval(duckdb_appender appender, duckdb_interval value);
    function duckdb_append_interval(appender, val) &
    & bind(c, name='duckdb_append_interval') result(res)
      import :: duckdb_state, duckdb_appender, duckdb_interval
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      type(duckdb_interval), value :: val
    end function duckdb_append_interval

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_varchar(duckdb_appender appender, const char *val);
    function duckdb_append_varchar_(appender, val) &
    & bind(c, name='duckdb_append_varchar') result(res)
      import :: duckdb_state, duckdb_appender, c_char
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      character(kind=c_char) :: val
    end function duckdb_append_varchar_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_varchar_length(duckdb_appender appender, const char *val,
    ! idx_t length);
    function duckdb_append_varchar_length_(appender, val, length) &
    & bind(c, name='duckdb_append_varchar_length') result(res)
      import :: duckdb_state, duckdb_appender, c_char, c_int64_t
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      integer(kind=c_int64_t), value :: length
      character(kind=c_char) :: val
    end function duckdb_append_varchar_length_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_blob(duckdb_appender appender, const void *data,
    ! idx_t length);
    ! FIXME: Similar to duckdb_bind_blob_ the c-api uses a pointer rather than
    !        using a type_blob. Address in the helper function?
    function duckdb_append_blob_(appender, data, length) &
    & bind(c, name='duckdb_append_blob') result(res)
      import :: duckdb_state, duckdb_appender, c_ptr, c_int64_t
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      type(c_ptr), value :: data
      integer(kind=c_int64_t), value :: length
    end function duckdb_append_blob_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_null(duckdb_appender appender);
    function duckdb_append_null(appender) &
    & bind(c, name='duckdb_append_null') result(res)
      import :: duckdb_state, duckdb_appender
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
    end function duckdb_append_null

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_append_data_chunk(duckdb_appender appender,
    ! duckdb_data_chunk chunk);
    function duckdb_append_data_chunk(appender, chunk) &
    & bind(c, name='duckdb_append_data_chunk') result(res)
      import :: duckdb_state, duckdb_appender, duckdb_data_chunk
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender), value :: appender
      type(duckdb_data_chunk), value :: chunk
    end function duckdb_append_data_chunk

    ! =========================================================================
    ! Arrow Interface
    ! =========================================================================

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_query_arrow(duckdb_connection connection, const char *query,
    ! duckdb_arrow *out_result);
    function duckdb_query_arrow_(connection, query, out_result) &
    & bind(c, name='duckdb_query_arrow') result(res)
      import :: duckdb_state, duckdb_connection, duckdb_arrow, c_char
      integer(kind(duckdb_state)) :: res
      type(duckdb_connection), value :: connection
      character(kind=c_char) :: query
      type(duckdb_arrow) :: out_result
    end function duckdb_query_arrow_

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_query_arrow_schema(duckdb_arrow result,
    ! duckdb_arrow_schema *out_schema);
    function duckdb_query_arrow_schema(rslt, out_schema) &
    & bind(c, name='duckdb_query_arrow_schema') result(res)
      import :: duckdb_state, duckdb_arrow, duckdb_arrow_schema
      integer(kind(duckdb_state)) :: res
      type(duckdb_arrow), value :: rslt
      type(duckdb_arrow_schema) :: out_schema
    end function duckdb_query_arrow_schema

    ! DUCKDB_API
    ! duckdb_state
    ! duckdb_query_arrow_array(duckdb_arrow result,
    ! duckdb_arrow_array *out_array);
    function duckdb_query_arrow_array(rslt, out_array) &
    & bind(c, name='duckdb_query_arrow_array') result(res)
      import :: duckdb_state, duckdb_arrow, duckdb_arrow_array
      integer(kind(duckdb_state)) :: res
      type(duckdb_arrow), value :: rslt
      type(duckdb_arrow_array) :: out_array
    end function duckdb_query_arrow_array

    ! DUCKDB_API
    ! idx_t
    ! duckdb_arrow_column_count(duckdb_arrow result);

    ! DUCKDB_API
    ! idx_t
    ! duckdb_arrow_row_count(duckdb_arrow result);

    ! DUCKDB_API
    ! idx_t
    ! duckdb_arrow_rows_changed(duckdb_arrow result);

    ! DUCKDB_API
    ! const char
    ! *duckdb_query_arrow_error(duckdb_arrow result);
    function duckdb_query_arrow_error_(rslt) &
    & bind(c, name='duckdb_query_arrow_error') result(err)
      import :: c_ptr, duckdb_arrow
      type(c_ptr) :: err
      type(duckdb_arrow), value :: rslt
    end function duckdb_query_arrow_error_

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_arrow(duckdb_arrow *result);
    subroutine duckdb_destroy_arrow(rslt) &
    & bind(c, name='duckdb_destroy_arrow')
      import :: duckdb_arrow
      type(duckdb_arrow) :: rslt
    end subroutine duckdb_destroy_arrow

    ! =========================================================================
    ! Threading Information
    ! =========================================================================

    ! typedef void *duckdb_task_state;

    ! DUCKDB_API
    ! void
    ! duckdb_execute_tasks(duckdb_database database, idx_t max_tasks);

    ! DUCKDB_API
    ! duckdb_task_state
    ! duckdb_create_task_state(duckdb_database database);

    ! DUCKDB_API
    ! void
    ! duckdb_execute_tasks_state(duckdb_task_state state);

    ! DUCKDB_API
    ! idx_t
    ! duckdb_execute_n_tasks_state(duckdb_task_state state, idx_t max_tasks);

    ! DUCKDB_API
    ! void
    ! duckdb_finish_execution(duckdb_task_state state);

    ! DUCKDB_API
    ! bool
    ! duckdb_task_state_is_finished(duckdb_task_state state);

    ! DUCKDB_API
    ! void
    ! duckdb_destroy_task_state(duckdb_task_state state);

    ! DUCKDB_API
    ! bool
    ! duckdb_execution_is_finished(duckdb_connection con);

  end interface !**************************************************************

  contains

    pure function copy(a)
      character, intent(in)  :: a(:)
      character(len=size(a)) :: copy
      integer :: i
      do i = 1, size(a)
        copy(i:i) = a(i)
      end do
    end function copy

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

    ! =========================================================================
    ! Open/Connect
    ! =========================================================================

    function duckdb_open(path, db) result(res)
      integer(kind(duckdb_state)) :: res
      character(len=*), optional :: path
      type(duckdb_database) :: db
      if (present(path)) then
        res = duckdb_open_char(path//c_null_char, db)
      else
        res = duckdb_open_ptr(c_null_ptr, db)
      end if
    end function duckdb_open

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

    function duckdb_library_version() result(res)
      character(len=:), allocatable :: res
      type(c_ptr) :: tmp
      tmp = duckdb_library_version_()
      call c_f_str_ptr(tmp, res)
    end function duckdb_library_version

    ! =========================================================================
    ! Configuration
    ! =========================================================================

    function duckdb_config_count() result(res)
      integer :: res
      res = int(duckdb_config_count_())
    end function duckdb_config_count

    function duckdb_get_config_flag(idx, out_name, out_description) result(res)
      integer(kind(duckdb_state)) :: res
      integer :: idx
      type(c_ptr) :: tmp_name
      type(c_ptr) :: tmp_description
      character(len=:), allocatable :: out_name
      character(len=:), allocatable :: out_description
      out_name=""
      out_description=""
      res = duckdb_get_config_flag_(int(idx, kind=c_size_t), tmp_name, &
      & tmp_description)
      if (c_associated(tmp_name)) call c_f_str_ptr(tmp_name, out_name)
      if (c_associated(tmp_description)) then
        call c_f_str_ptr(tmp_description, out_description)
      end if
    end function duckdb_get_config_flag

    function duckdb_set_config(config, name, option) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_config) :: config
      character(len=*) :: name
      character(len=*) :: option
      res = duckdb_set_config_(config, name//c_null_char, option//c_null_char)
    end function duckdb_set_config

    ! =========================================================================
    ! Query Execution
    ! =========================================================================

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

    function duckdb_column_name(res, col) result(name)
      character(len=:), allocatable :: name
      type(c_ptr) :: tmp
      type(duckdb_result) :: res
      integer(kind=int64) :: col
      name = "NULL"
      if (c_associated(res%internal_data)) then
        tmp = duckdb_column_name_(res, int(col, kind=c_int64_t))
        if (c_associated(tmp)) call c_f_str_ptr(tmp, name)
      end if
    end function duckdb_column_name

    function duckdb_column_type(res, col) result(col_type)
      integer(kind(duckdb_type)) :: col_type
      type(duckdb_result) :: res
      integer(kind=int64) :: col
      col_type = duckdb_type_invalid
      if (c_associated(res%internal_data)) &
        col_type = duckdb_column_type_(res, int(col, kind=c_int64_t))
    end function duckdb_column_type

    function duckdb_column_logical_type(res, idx) result(t)
      type(duckdb_result) :: res
      integer(kind=int64) :: idx
      type(duckdb_logical_type) :: t
      if (c_associated(res%internal_data)) &
        t = duckdb_column_logical_type_(res, int(idx, kind=c_int64_t))
    end function duckdb_column_logical_type

    function duckdb_column_count(res) result(cc)
      type(duckdb_result) :: res
      integer(kind=int64) :: cc
      cc = 0
      if (c_associated(res%internal_data)) &
        cc = int(duckdb_column_count_(res))
    end function duckdb_column_count

    function duckdb_row_count(res) result(rc)
      type(duckdb_result) :: res
      integer(kind=int64) :: rc
      rc = 0
      if (c_associated(res%internal_data)) &
        rc = int(duckdb_row_count_(res))
    end function duckdb_row_count

    function duckdb_rows_changed(res) result(rc)
      type(duckdb_result) :: res
      integer(kind=int64) :: rc
      rc = 0
      if (c_associated(res%internal_data)) &
        rc = int(duckdb_rows_changed_(res))
    end function duckdb_rows_changed

    function duckdb_column_data(res, col) result(data)
      type(c_ptr) :: data
      type(duckdb_result) :: res
      integer(kind=int64) :: col
      data = c_null_ptr
      if (c_associated(res%internal_data)) &
        data = duckdb_column_data_(res, int(col, kind=c_int64_t))
    end function duckdb_column_data

    ! FIXME - howto return rst if not c_associated
    function duckdb_nullmask_data(res, col) result(rst)
      type(c_ptr) :: tmp
      type(duckdb_result) :: res
      integer(kind=int64) :: col
      logical, pointer :: rst
      tmp = c_null_ptr
      ! rst = .false.
      if (c_associated(res%internal_data)) then
        tmp = duckdb_nullmask_data_(res, int(col, kind=c_int64_t))
        if (c_associated(tmp)) &
          call c_f_pointer(tmp, rst)
      end if
    end function duckdb_nullmask_data

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

    ! =========================================================================
    ! Result Functions
    ! =========================================================================

    function duckdb_result_get_chunk(res, idx) result(chunk)
      type(duckdb_result) :: res
      integer(kind=int64) :: idx
      type(duckdb_data_chunk) :: chunk
      chunk = duckdb_result_get_chunk_(res, int(idx, kind=c_int64_t))
    end function duckdb_result_get_chunk

    function duckdb_result_chunk_count(res) result(cc)
      type(duckdb_result):: res
      integer(kind=int64) :: cc
      cc = 0
      if (c_associated(res%internal_data)) then
        cc = int(duckdb_result_chunk_count_(res), kind=int64)
      end if
    end function duckdb_result_chunk_count

    function duckdb_value_boolean(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64), value :: col, row
      logical :: r
      r = .false.
      if (c_associated(res%internal_data)) &
        r = duckdb_value_boolean_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_boolean

    function duckdb_value_int8(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      integer(kind=int8) :: r
      r = 0
      if (c_associated(res%internal_data)) &
        r = int(duckdb_value_int8_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t)), kind=int8)
    end function duckdb_value_int8

    function duckdb_value_int16(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      integer(kind=int16) :: r
      r = 0
      if (c_associated(res%internal_data)) &
        r = int(duckdb_value_int16_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t)), kind=int16)
    end function duckdb_value_int16

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

    function duckdb_value_hugeint(res, col, row)  result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      type(duckdb_hugeint) :: r
      r = duckdb_hugeint()
      if (c_associated(res%internal_data)) &
        r = duckdb_value_hugeint_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_hugeint

    function duckdb_value_decimal(res, col, row)  result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      type(duckdb_decimal) :: r
      if (c_associated(res%internal_data)) &
        r = duckdb_value_decimal_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_decimal

    function duckdb_value_float(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      real(kind=real32) :: r
      if (c_associated(res%internal_data)) &
        r = real(duckdb_value_float_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t)), kind=real32)
    end function duckdb_value_float

    function duckdb_value_double(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      real(kind=real64) :: r
      if (c_associated(res%internal_data)) &
        r = real(duckdb_value_double_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t)), kind=real64)
    end function duckdb_value_double

    function duckdb_value_date(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      type(duckdb_date) :: r
      if (c_associated(res%internal_data)) &
        r = duckdb_value_date_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_date

    function duckdb_value_time(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      type(duckdb_time) :: r
      if (c_associated(res%internal_data)) &
        r = duckdb_value_time_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_time

    function duckdb_value_timestamp(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      type(duckdb_timestamp) :: r
      if (c_associated(res%internal_data)) &
        r = duckdb_value_timestamp_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_timestamp

    function duckdb_value_interval(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      type(duckdb_interval) :: r
      if (c_associated(res%internal_data)) &
        r = duckdb_value_interval_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_interval

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

    function duckdb_value_string(res, col, row) result(r)
      type(duckdb_result), intent(in) :: res
      integer(kind=int64) :: col, row
      type(duckdb_string) :: r
      if (c_associated(res%internal_data)) &
        r = duckdb_value_string_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_string

    function duckdb_value_varchar_internal(res, col, row) result(str)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      type(c_ptr) :: tmp
      character(len=:), allocatable :: str
      tmp = c_null_ptr
      if (c_associated(res%internal_data)) &
        tmp = duckdb_value_varchar_internal_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
      if (c_associated(tmp)) call c_f_str_ptr(tmp, str)
    end function duckdb_value_varchar_internal

    function duckdb_value_string_internal(res, col, row) result(str)
      type(duckdb_result), intent(in) :: res
      integer(kind=int64) :: col, row
      type(duckdb_string) :: str
      if (c_associated(res%internal_data)) &
        str = duckdb_value_string_internal_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_string_internal

    function duckdb_value_blob(res, col, row) result(r)
      type(duckdb_result) :: res
      integer(kind=int64) :: col, row
      type(duckdb_blob) :: r
      if (c_associated(res%internal_data)) &
        r = duckdb_value_blob_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t))
    end function duckdb_value_blob

    function duckdb_value_is_null(res, col, row) result(r)
      type(duckdb_result), intent(in) :: res
      integer(kind=int64) :: col, row
      logical :: r
      r = .false.
      if (c_associated(res%internal_data)) &
        r = logical(duckdb_value_is_null_(res, int(col, kind=c_int64_t), &
        & int(row, kind=c_int64_t)))
    end function duckdb_value_is_null

    function duckdb_string_to_character(str) result(res)
      type(duckdb_string) :: str
      character(len=:), allocatable :: res
      res = ""
      if (c_associated(str%data)) &
        call c_f_str_ptr(str%data, res)
    end function duckdb_string_to_character

    ! =========================================================================
    ! Helpers
    ! =========================================================================

    function duckdb_vector_size() result(res)
      integer :: res
      res = int(duckdb_vector_size_())
    end function duckdb_vector_size

    ! =========================================================================
    ! Date/Time/Timestamp Helpers
    ! =========================================================================

    ! =========================================================================
    ! Hugeint Helpers
    ! =========================================================================

    function duckdb_hugeint_to_double(val)  result(r)
      type(duckdb_hugeint) :: val
      real(kind=real64) :: r
      r = real(duckdb_hugeint_to_double_(val), kind=real64)
    end function duckdb_hugeint_to_double

    function duckdb_double_to_hugeint(val)  result(r)
      type(duckdb_hugeint) :: r
      real(kind=real64) :: val
      r = duckdb_double_to_hugeint_(real(val, kind=c_double))
    end function duckdb_double_to_hugeint

    function duckdb_double_to_decimal(val, width, scale)  result(r)
      type(duckdb_decimal) :: r
      real(kind=real64) :: val
      integer :: width, scale
      r = duckdb_double_to_decimal_(real(val, kind=c_double), &
      & int(width, kind=c_int8_t), int(scale, kind=c_int8_t))
    end function duckdb_double_to_decimal

    function duckdb_decimal_to_double(val)  result(r)
      type(duckdb_decimal) :: val
      real(kind=real64) :: r
      r = real(duckdb_decimal_to_double_(val), kind=real64)
    end function duckdb_decimal_to_double

    ! =========================================================================
    ! Prepared Statements
    ! =========================================================================

    function duckdb_prepare(conn, query, out_prepared_statement) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_connection) :: conn
      character(len=*) :: query
      ! character(len=:), allocatable :: sql
      type(duckdb_prepared_statement) :: out_prepared_statement
      ! sql = query // c_null_char ! convert to c string
      res = duckdb_prepare_(conn, query//c_null_char, out_prepared_statement)
    end function duckdb_prepare

    function duckdb_prepare_error(ps) result(err)
      character(len=:), allocatable :: err
      type(c_ptr) :: tmp
      type(duckdb_prepared_statement) :: ps
      err = ""
      if (c_associated(ps%prep)) then
        tmp = duckdb_prepare_error_(ps)
        if (c_associated(tmp)) call c_f_str_ptr(tmp, err)
      end if
    end function duckdb_prepare_error

    function duckdb_nparams(ps) result(n)
      type(duckdb_prepared_statement) :: ps
      integer :: n
      n = int(duckdb_nparams_(ps))
    end function duckdb_nparams

    function duckdb_param_type(ps, idx) result(res)
      integer(kind(duckdb_type)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      res = duckdb_param_type_(ps, int(idx, kind=c_int64_t))
    end function duckdb_param_type

    function duckdb_bind_boolean(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      logical :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_boolean_(ps, int(idx, kind=c_int64_t), &
        & logical(val, kind=c_bool))
    end function duckdb_bind_boolean

    function duckdb_bind_int8(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      integer(kind=int8) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_int8_(ps, int(idx, kind=c_int64_t), &
        & int(val, kind=c_int8_t))
    end function duckdb_bind_int8

    function duckdb_bind_int16(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      integer(kind=int16) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_int16_(ps, int(idx, kind=c_int64_t), &
        & int(val, kind=c_int16_t))
    end function duckdb_bind_int16

    function duckdb_bind_int32(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      integer(kind=int32) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_int32_(ps, int(idx, kind=c_int64_t), &
        & int(val, kind=c_int32_t))
    end function duckdb_bind_int32

    function duckdb_bind_int64(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      integer(kind=int64) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_int64_(ps, int(idx, kind=c_int64_t), &
        & int(val, kind=c_int64_t))
    end function duckdb_bind_int64

    function duckdb_bind_hugeint(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      type(duckdb_hugeint) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_hugeint_(ps, int(idx, kind=c_int64_t), val)
    end function duckdb_bind_hugeint

    function duckdb_bind_decimal(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      type(duckdb_decimal) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_decimal_(ps, int(idx, kind=c_int64_t), val)
    end function duckdb_bind_decimal

    function duckdb_bind_float(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      real(kind=real32) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_float_(ps, int(idx, kind=c_int64_t), &
        & real(val, kind=c_float))
    end function duckdb_bind_float

    function duckdb_bind_double(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      real(kind=real64) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_double_(ps, int(idx, kind=c_int64_t), &
        & real(val, kind=c_double))
    end function duckdb_bind_double

    function duckdb_bind_date(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      type(duckdb_date) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_date_(ps, int(idx, kind=c_int64_t), val)
    end function duckdb_bind_date

    function duckdb_bind_time(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      type(duckdb_time) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_time_(ps, int(idx, kind=c_int64_t), val)
    end function duckdb_bind_time

    function duckdb_bind_timestamp(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      type(duckdb_timestamp) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_timestamp_(ps, int(idx, kind=c_int64_t), val)
    end function duckdb_bind_timestamp

    function duckdb_bind_interval(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      type(duckdb_interval) :: val
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_interval_(ps, int(idx, kind=c_int64_t), val)
    end function duckdb_bind_interval

    function duckdb_bind_varchar(ps, idx, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      character(len=*) :: val
      character(len=:), allocatable :: cval
      cval = val // c_null_char ! convert to c string
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_varchar_(ps, int(idx, kind=c_int64_t), cval)
    end function duckdb_bind_varchar

    function duckdb_bind_varchar_length(ps, idx, val, length) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx, length
      character(len=*) :: val
      character(len=:), allocatable :: cval
      cval = val // c_null_char ! convert to c string
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_varchar_length_(ps, int(idx, kind=c_int64_t), cval, &
        & int(length, kind=c_int64_t))
    end function duckdb_bind_varchar_length

    function duckdb_bind_blob(ps, idx, blob) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx, length
      type(duckdb_blob) :: blob
      res = duckdb_bind_blob_(ps, int(idx, kind=c_int64_t), blob%data, &
      & blob%size)
    end function duckdb_bind_blob

    ! FIXME
    ! function duckdb_bind_string(ps, idx, val) result(res)
    !   integer(kind(duckdb_state)) :: res
    !   type(duckdb_prepared_statement) :: ps
    !   integer :: idx
    !   type(duckdb_string) :: val
    !   character(len=:), allocatable :: cval
    !   cval = val%data // c_null_char ! convert to c string
    !   if (c_associated(ps%prep)) &
    !     res = duckdb_bind_varchar_length_(ps, int(idx, kind=c_int64_t), cval, int(val%size, kind=c_int64_t))
    ! end function duckdb_bind_string

    function duckdb_bind_null(ps, idx) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_prepared_statement) :: ps
      integer :: idx
      res = duckdberror
      if (c_associated(ps%prep)) &
        res = duckdb_bind_null_(ps, int(idx, kind=c_int64_t))
    end function duckdb_bind_null

    ! =========================================================================
    ! Extract Statements
    ! =========================================================================
    function duckdb_extract_statements(conn, query, oes) result(res)
      type(duckdb_connection) :: conn
      character(len=*) :: query
      type(duckdb_extracted_statements) :: oes
      integer :: res
      res = int(duckdb_extract_statements_(conn, query//c_null_char, oes))
    end function duckdb_extract_statements

    function duckdb_prepare_extracted_statement(conn, es, idx, ops) result(res)
      type(duckdb_connection) :: conn
      type(duckdb_extracted_statements) :: es
      type(duckdb_prepared_statement) :: ops
      integer(kind=int64) :: idx
      integer(kind(duckdb_state)) :: res
      res = duckdb_prepare_extracted_statement_(conn, es, &
        int(idx, c_int64_t), ops)
    end function duckdb_prepare_extracted_statement

    function duckdb_extract_statements_error(es) result(err)
      character(len=:), allocatable :: err
      type(c_ptr) :: tmp
      type(duckdb_extracted_statements) :: es
      err = ""
      if (c_associated(es%extrac)) then
        tmp = duckdb_extract_statements_error_(es)
        if (c_associated(tmp)) call c_f_str_ptr(tmp, err)
      end if
    end function duckdb_extract_statements_error

    ! =========================================================================
    ! Pending Result Interface
    ! =========================================================================
    function duckdb_pending_error(pending_result) result(err)
      character(len=:), allocatable :: err
      type(c_ptr) :: tmp
      type(duckdb_pending_result) :: pending_result
      err = ""
      if (c_associated(pending_result%pend)) then
        tmp = duckdb_pending_error_(pending_result)
        if (c_associated(tmp)) call c_f_str_ptr(tmp, err)
      end if
    end function duckdb_pending_error

    ! =========================================================================
    ! Value Interface
    ! =========================================================================

    ! =========================================================================
    ! Logical Type Interface
    ! =========================================================================

    function duckdb_decimal_width(typ) result(res)
      type(duckdb_logical_type) :: typ
      integer(kind=int8) :: res
      res = int(duckdb_decimal_width_(typ), kind=int8)
    end function duckdb_decimal_width

    function duckdb_decimal_scale(typ) result(res)
      type(duckdb_logical_type) :: typ
      integer(kind=int8) :: res
      res = int(duckdb_decimal_scale_(typ), kind=int8)
    end function duckdb_decimal_scale

    function duckdb_enum_dictionary_size(typ) result(res)
      type(duckdb_logical_type) :: typ
      integer(kind=int32) :: res
      res = int(duckdb_enum_dictionary_size_(typ), kind=int32)
    end function duckdb_enum_dictionary_size

    function duckdb_enum_dictionary_value(typ, index) result(res)
      type(duckdb_logical_type) :: typ
      integer :: index
      type(c_ptr) :: ptr
      character(len=:), allocatable :: res
      res = ""
      ptr = duckdb_enum_dictionary_value_(typ, int(index, kind=c_int64_t))
      if (c_associated(ptr)) &
        call c_f_str_ptr(ptr, res)
    end function duckdb_enum_dictionary_value

    function duckdb_struct_type_child_count(typ) result(res)
      type(duckdb_logical_type) :: typ
      integer :: res
      res = int(duckdb_struct_type_child_count_(typ))
    end function duckdb_struct_type_child_count

    function duckdb_struct_type_child_name(typ, index) result(res)
      type(duckdb_logical_type) :: typ
      integer :: index
      type(c_ptr) :: tmp
      character(len=:), allocatable :: res
      res = ""
      tmp = duckdb_struct_type_child_name_(typ, int(index, kind=c_int64_t))
      if (c_associated(tmp)) call c_f_str_ptr(tmp, res)
    end function duckdb_struct_type_child_name

    function duckdb_struct_type_child_type(typ, index) result(res)
      type(duckdb_logical_type), value :: typ
      integer :: index
      type(duckdb_logical_type) :: res
      res = duckdb_struct_type_child_type_(typ, int(index, kind=c_int64_t))
    end function duckdb_struct_type_child_type
    ! =========================================================================
    ! Data Chunk Interface
    ! =========================================================================

    function duckdb_create_data_chunk(types, column_count) result(res)
      type(duckdb_logical_type) :: types(*)
      integer(kind=int64) :: column_count
      type(duckdb_data_chunk) :: res
      res = duckdb_create_data_chunk_(types, int(column_count, kind=c_int64_t))
    end function duckdb_create_data_chunk

    function duckdb_data_chunk_get_column_count(chunk) result(res)
      type(duckdb_data_chunk) :: chunk
      integer(kind=int64) :: res
      res = int(duckdb_data_chunk_get_column_count_(chunk), kind=int64)
    end function duckdb_data_chunk_get_column_count

    function duckdb_data_chunk_get_vector(chunk, col_idx) result(res)
      type(duckdb_data_chunk), intent(in) :: chunk
      integer(kind=int64) :: col_idx
      type(duckdb_vector) :: res
      res = duckdb_data_chunk_get_vector_(chunk, int(col_idx, kind=c_int64_t))
    end function duckdb_data_chunk_get_vector

    function duckdb_data_chunk_get_size(chunk) result(res)
      type(duckdb_data_chunk) :: chunk
      integer(kind=int64) :: res
      res = int(duckdb_data_chunk_get_size_(chunk), kind=int64)
    end function duckdb_data_chunk_get_size

    subroutine duckdb_data_chunk_set_size(chunk, siz)
      type(duckdb_data_chunk) :: chunk
      integer(kind=int64) :: siz
      call duckdb_data_chunk_set_size_(chunk, int(siz, kind=c_int64_t))
    end subroutine duckdb_data_chunk_set_size

    ! =========================================================================
    ! Vector Interface
    ! =========================================================================

    ! TEST - forego the helper for now, test returning a c_ptr instead
    ! function duckdb_vector_get_validity(vector) result(res)
    !   type(duckdb_vector) :: vector
    !   type(c_ptr) :: ptr
    !   integer(kind=int64), pointer :: res
    !   ptr = duckdb_vector_get_validity_(vector)
    !   call c_f_pointer(ptr, res)
    !   ! res = int(duckdb_vector_get_validity_(vector), kind=int64)
    ! end function duckdb_vector_get_validity

    subroutine duckdb_vector_assign_string_element(vec, idx, str)
      type(duckdb_vector) :: vec
      integer :: idx
      character(len=*) :: str
      call duckdb_vector_assign_string_element_(vec, &
      & int(idx, kind=c_int64_t), str // c_null_char)
    end subroutine duckdb_vector_assign_string_element

    subroutine duckdb_vector_assign_string_element_len(vec, idx, str, slen)
      type(duckdb_vector) :: vec
      integer :: idx
      character(len=*) :: str
      integer :: slen
      call duckdb_vector_assign_string_element_len_(vec, &
      & int(idx, kind=c_int64_t), str // c_null_char, int(slen, kind=c_int64_t))
    end subroutine duckdb_vector_assign_string_element_len

    function duckdb_list_vector_reserve(vec, rc) result(res)
      type(duckdb_vector) :: vec
      integer(kind=int64) :: rc
      integer(kind(duckdb_state)) :: res
      res = duckdb_list_vector_reserve_(vec, int(rc, kind=c_int64_t))
    end function duckdb_list_vector_reserve

    function duckdb_list_vector_get_size(vector) result(res)
      type(duckdb_vector), value :: vector
      integer(kind=int64) :: res
      res = int(duckdb_list_vector_get_size_(vector), kind=int64)
    end function duckdb_list_vector_get_size

    function duckdb_list_vector_set_size(vector, size) result(res)
      type(duckdb_vector) :: vector
      integer(kind=int64) :: size
      integer(kind(duckdb_state)) :: res
      res = duckdb_list_vector_set_size_(vector, int(size, kind=c_int64_t))
    end function duckdb_list_vector_set_size

    ! =========================================================================
    ! Validity Mask Functions
    ! =========================================================================

    function duckdb_validity_row_is_valid(validity, row) result(res)
      type(c_ptr) :: validity
      integer(kind=int64) :: row
      logical :: res
      res = duckdb_validity_row_is_valid_(validity, int(row, kind=c_int64_t))
    end function duckdb_validity_row_is_valid

    subroutine duckdb_validity_set_row_validity(validity, row, valid)
      type(c_ptr) :: validity
      integer(kind=int64) :: row
      logical :: valid
      call duckdb_validity_set_row_validity_(validity, &
      & int(row, kind=c_int64_t), logical(valid, kind=c_bool))
    end subroutine duckdb_validity_set_row_validity

    subroutine duckdb_validity_set_row_invalid(validity, row)
      type(c_ptr) :: validity
      integer(kind=int64) :: row
      call duckdb_validity_set_row_invalid_(validity, int(row, kind=c_int64_t))
    end subroutine duckdb_validity_set_row_invalid

    subroutine duckdb_validity_set_row_valid(validity, row)
      type(c_ptr) :: validity
      integer(kind=int64) :: row
      call duckdb_validity_set_row_invalid_(validity, int(row, kind=c_int64_t))
    end subroutine duckdb_validity_set_row_valid

    ! =========================================================================
    ! Table Functions
    ! =========================================================================

    ! =========================================================================
    ! Table Function Bind
    ! =========================================================================

    ! =========================================================================
    ! Table Function Init
    ! =========================================================================

    ! =========================================================================
    ! Table Function
    ! =========================================================================

    ! =========================================================================
    ! Replacement Scans
    ! =========================================================================

    ! =========================================================================
    ! Appender
    ! =========================================================================

    function duckdb_appender_create(conn, schema, table, out_app) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_connection) :: conn
      character(len=*) :: schema
      character(len=*) :: table
      type(duckdb_appender) :: out_app
      res = duckdb_appender_create_(conn, trim(schema)//c_null_char, &
        trim(table)//c_null_char, out_app)
    end function duckdb_appender_create

    function duckdb_appender_error(appender) result(err)
      character(len=:), allocatable :: err
      type(c_ptr) :: tmp
      type(duckdb_appender) :: appender
      err = ""
      if (c_associated(appender%appn)) then
        tmp = duckdb_appender_error_(appender)
        if (c_associated(tmp)) call c_f_str_ptr(tmp, err)
      end if
    end function duckdb_appender_error

    function duckdb_append_bool(appender, value) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: appender
      logical :: value
      res = duckdb_append_bool_(appender, logical(value, kind=c_bool))
    end function duckdb_append_bool

    function duckdb_append_int8(appender, value) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: appender
      integer(kind=int8) :: value
      res = duckdb_append_int8_(appender, int(value, kind=c_int8_t))
    end function duckdb_append_int8

    function duckdb_append_int16(appender, value) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: appender
      integer(kind=int16) :: value
      res = duckdb_append_int16_(appender, int(value, kind=c_int16_t))
    end function duckdb_append_int16

    function duckdb_append_int32(appender, value) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: appender
      integer :: value
      res = duckdb_append_int32_(appender, int(value, kind=c_int32_t))
    end function duckdb_append_int32

    function duckdb_append_int64(appender, value) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: appender
      integer(kind=int64) :: value
      res = duckdb_append_int64_(appender, int(value, kind=c_int64_t))
    end function duckdb_append_int64

    function duckdb_append_float(appender, value) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: appender
      real(kind=real32) :: value
      res = duckdb_append_float_(appender, real(value, kind=c_float))
    end function duckdb_append_float

    function duckdb_append_double(appender, value) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: appender
      real(kind=real64) :: value
      res = duckdb_append_double_(appender, real(value, kind=c_double))
    end function duckdb_append_double

    function duckdb_append_varchar(appender, val) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: appender
      character(len=*) :: val
      character(len=:), allocatable :: cval
      cval = val // c_null_char ! convert to c string
      res = duckdberror
      if (c_associated(appender%appn)) &
        res = duckdb_append_varchar_(appender, cval)
    end function duckdb_append_varchar

    function duckdb_append_varchar_length(app, val, lng) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: app
      integer :: lng
      character(len=*) :: val
      character(len=:), allocatable :: cval
      cval = val // c_null_char ! convert to c string
      res = duckdberror
      if (c_associated(app%appn)) &
        res = duckdb_append_varchar_length_(app, cval, int(lng, kind=c_int64_t))
    end function duckdb_append_varchar_length

    function duckdb_append_blob(appender, blob) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_appender) :: appender
      type(duckdb_blob) :: blob
      res = duckdb_append_blob_(appender, blob%data, blob%size)
    end function duckdb_append_blob

    ! =========================================================================
    ! Arrow Interface
    ! =========================================================================

    function duckdb_query_arrow(connection, query, out_result) result(res)
      integer(kind(duckdb_state)) :: res
      type(duckdb_connection), value :: connection
      character(len=*) :: query
      type(duckdb_arrow) :: out_result
      res = duckdb_query_arrow_(connection, query//c_null_char, out_result)
    end function duckdb_query_arrow

    function duckdb_query_arrow_error(res) result(err)
      character(len=:), allocatable :: err
      type(c_ptr) :: tmp
      type(duckdb_arrow) :: res
      err = "NULL"
      if (c_associated(res%arrw)) then
        tmp = duckdb_query_arrow_error_(res)
        if (c_associated(tmp)) call c_f_str_ptr(tmp, err)
      end if
    end function duckdb_query_arrow_error

    ! =========================================================================
    ! Threading Information
    ! =========================================================================

end module duckdb

