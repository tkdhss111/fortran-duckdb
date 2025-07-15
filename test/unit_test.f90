program unit_test_open_close
  use duckdb_mo
  implicit none
  type(duckdb_ty) :: db

  print *, '========================================='
  print *, ' Open and Close Tests'
  print *, '========================================='

  print *, 'Test: Open database: "test.duckdb"'
  call db%open ( "test/test.duckdb" )
  call db%close

  print *, 'Test: Open database'
  call db%open ( 'test/test.duckdb' )
  call db%close

  print *, 'Test: Open database with automatic mode'
  call db%open ( 'test/test.duckdb', 'AUTOMATIC' )
  call db%close

  print *, 'Test: Open database with READ_WRITE mode'
  call db%open ( 'test/test.duckdb', 'READ_WRITE' )
  call db%close

  print *, 'Test: Open in-memory database with READ_ONLY mode'
  call db%open ( 'test/test.duckdb', 'READ_ONLY' )
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

  ! This causes error stop (error test)
  !print *, 'Test: Open in-memory database with READ_ONLY mode'
  !call db%open ( '', 'READ_ONLY' )
  !call db%close

  print *, 'Test: Open actual database'
  call db%open ( '/mnt/01_TAKEDATA/tkd-09-weighted-weather/04_Chubu/wthr_wgt.duckdb' )
  call db%close

end program
