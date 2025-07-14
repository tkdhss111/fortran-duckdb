set ( EXE unit_test )
set ( SRCS
  ../src/duckdb.f90
  ../src/duckdb_mo.f90
  ./unit_test.f90
  )
set ( CMAKE_Fortran_FLAGS "-ffree-line-length-none -fdefault-integer-8")
set ( CMAKE_Fortran_FLAGS_DEBUG
  "-O0 -fbounds-check -fbacktrace -Wall -Wno-uninitialized -Wno-maybe-uninitialized" )

add_executable ( ${EXE} ${SRCS} )
target_link_libraries( ${EXE} duckdb )
add_test ( NAME ${EXE} COMMAND ${EXE} WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} )
install ( TARGETS ${EXE} )
