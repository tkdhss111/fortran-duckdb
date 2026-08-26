# Every unit_test_*.f90 in this directory is a test and gets registered.
#
# Previously only unit_test was built and added to ctest, so unit_test_errmsg,
# unit_test_varchar and unit_test_ducklake were compiled by nobody and run by nobody.
# That is how a lock-lifetime regression reached production unnoticed: the ducklake
# suite had covered lock()/unlock() all along, but `make test` never executed it.
# A test that is not registered is not a test.
#
# Each target gets its OWN Fortran_MODULE_DIRECTORY. Without it every target compiles
# ../src/duckdb_mo.f90 to the same duckdb_mo.mod and ninja refuses the build with
# "multiple rules generate test/duckdb_mo.mod".
set ( CMAKE_Fortran_FLAGS "-fpscomp logicals -g -traceback -check all,nouninit -fstack-protector" )
set ( CMAKE_Fortran_FLAGS_DEBUG "-coarray=single -Ddebug -O0" )

add_executable ( unit_test          ../src/duckdb_mo.f90 ./unit_test.f90 )
add_executable ( unit_test_errmsg   ../src/duckdb_mo.f90 ./unit_test_errmsg.f90 )
add_executable ( unit_test_varchar  ../src/duckdb_mo.f90 ./unit_test_varchar.f90 )
add_executable ( unit_test_ducklake ../src/duckdb_mo.f90 ../src/ducklake_mo.f90 ./unit_test_ducklake.f90 )

foreach ( T unit_test unit_test_errmsg unit_test_varchar unit_test_ducklake )
  set_target_properties ( ${T} PROPERTIES
                          Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod_${T} )
  target_link_libraries ( ${T} duckdb )
  add_test ( NAME ${T} COMMAND ${T} WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} )
endforeach ()
