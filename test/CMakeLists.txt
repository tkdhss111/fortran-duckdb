set ( EXE hss_test_duckdb )
set ( SRCS
  ../src/duckdb_mo.f90
  ./unit_test.f90
  )
set ( MKLROOT /opt/intel/oneapi/mkl/latest )
set ( LIBS
  ${MKLROOT}/lib/libmkl_blas95_ilp64.a 
  ${MKLROOT}/lib/libmkl_lapack95_ilp64.a -Wl,--start-group 
  ${MKLROOT}/lib/libmkl_intel_ilp64.a
  ${MKLROOT}/lib/libmkl_sequential.a
  ${MKLROOT}/lib/libmkl_core.a -Wl,--end-group -lpthread -lm -ldl
)
set ( CMAKE_Fortran_FLAGS 
  "-I${MKLROOT}/include/mkl/intel64/ilp64 -i8 -I${MKLROOT}/include -qmkl -lduckdb" )

if ( CMAKE_BUILD_TYPE MATCHES "Release" )
  set ( CMAKE_Fortran_FLAGS_RELEASE
    "-O3 -Drelease ${CMAKE_Fortran_FLAGS}" )
endif()

if ( CMAKE_BUILD_TYPE MATCHES "Debug" )
  set ( CMAKE_Fortran_FLAGS_DEBUG
    "-g -O0 -warn all -check bounds -Ddebug ${CMAKE_Fortran_FLAGS}" )
endif()

add_executable ( ${EXE} ${SRCS} )
target_link_libraries ( ${EXE} ${LIBS} )
add_test ( NAME ${EXE} COMMAND ${EXE} ${ARGS} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )
install ( TARGETS ${EXE} )
