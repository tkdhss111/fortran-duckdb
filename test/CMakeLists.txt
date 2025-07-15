set ( EXE unit_test )
set ( SRCS
  ../src/duckdb.f90
  ../src/duckdb_mo.f90
  ./unit_test.f90
  )
set ( CMAKE_Fortran_FLAGS "-fpscomp logicals -g -traceback -check all,nouninit -fstack-protector" )
set ( CMAKE_Fortran_FLAGS_DEBUG "-coarray=single -Ddebug -O0" )
add_executable ( ${EXE} ${SRCS} )
target_link_libraries( ${EXE} duckdb )
add_test ( NAME ${EXE} COMMAND ${EXE} WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} )
