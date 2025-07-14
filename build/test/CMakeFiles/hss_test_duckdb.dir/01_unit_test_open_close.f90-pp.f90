# 1 "/home/hss/0_tkd/1_hss/2_tools/fortran-duckdb/test/01_unit_test_open_close.f90"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/home/hss/0_tkd/1_hss/2_tools/fortran-duckdb/test/01_unit_test_open_close.f90"
program unit_test_open_close
  use duckdb_mo
  implicit none
  type(duckdb_ty) :: db

  print *, 'Test: Open database: "db.duckdb"'
  call db%open ( "db.duckdb" )
  call db%close

  print *, 'Test: Open database'
  call db%open ( 'db.duckdb' )
  call db%close

  print *, 'Test: Open database with automatic mode'
  call db%open ( 'db.duckdb', 'AUTOMATIC' )
  call db%close

  print *, 'Test: Open database with READ_WRITE mode'
  call db%open ( 'db.duckdb', 'READ_WRITE' )
  call db%close

  print *, 'Test: Open in-memory database with READ_ONLY mode'
  call db%open ( 'db.duckdb', 'READ_ONLY' )
  call db%close

  print *, 'Test: Open in-memory database'
  call db%open ( '' )
  call db%close

  print *, 'Test: Open in-memory database with automatic mode'
  call db%open ( '', 'AUTOMATIC' )
  call db%close

  print *, 'Test: Open in-memory database with READ_WRITE mode'
  call db%open ( '', 'READ_WRITE' )
  call db%close

  ! This causes error stop
  print *, 'Test: Open in-memory database with READ_ONLY mode'
  call db%open ( '', 'READ_ONLY' )
  call db%close

end program
