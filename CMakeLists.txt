cmake_minimum_required ( VERSION 3.0 )
set ( CMAKE_Fortran_COMPILER ifx )
#set ( CMAKE_Fortran_COMPILER gfortran )
enable_language ( Fortran )
enable_testing ()
project ( hello LANGUAGES Fortran VERSION 1.0.0 )
add_subdirectory ( test )
