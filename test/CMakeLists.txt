set ( EXE hss_test_duckdb )
set ( SRCS
  #../src/common.f90
  #../src/constants.f90
  #../src/strings.f90
  ../src/duckdb.f90
  ../src/duckdb_mo.f90
  ./01_unit_test_open_close.f90
  #./hss_test_appender.f90
  #./hss_test_duckdb.f90
  )
set ( CMAKE_Fortran_FLAGS "-ffree-line-length-none -fdefault-integer-8")
set ( CMAKE_Fortran_FLAGS_DEBUG
  "-O0 -fbounds-check -fbacktrace -Wall -Wno-uninitialized -Wno-maybe-uninitialized" )

add_executable ( ${EXE} ${SRCS} )
target_link_libraries( ${EXE} duckdb )
add_test ( NAME ${EXE} COMMAND ${EXE} WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} )
install ( TARGETS ${EXE} )
