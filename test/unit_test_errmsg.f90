! unit_test_errmsg — duckdb_ty%send must CAPTURE the DuckDB error, not only print it.
!
! Regression guard. send_query used to fetch duckdb_result_error() and write it to
! stdout while leaving %errmsg unallocated, so a caller could learn THAT a query
! failed but never WHY — it could only report the status code, and the reason was
! reachable solely by whatever happened to capture stdout.
!
! Build (standalone; CMakeLists builds one unit_test at a time):
!   ifx -o unit_test_errmsg ../src/duckdb_mo.f90 unit_test_errmsg.f90 \
!       -I/usr/local/include -L/usr/local/lib -lduckdb
!   LD_LIBRARY_PATH=/usr/local/lib ./unit_test_errmsg
!
! Verified to DISCRIMINATE: against the pre-fix module it exits 1 with
! "errmsg not allocated after a failed query"; against the fix it prints
! ALL TESTS PASSED.
program test_errmsg
  use duckdb_mo, only: duckdb_ty
  implicit none
  type(duckdb_ty) :: db
  integer :: fails = 0

  call db%open('')

  ! --- 1. a failing query must leave stat /= 0 AND a non-empty errmsg ---------
  call db%send( "SELECT * FROM a_table_that_does_not_exist_xyz" )
  if ( db%stat == 0 ) then
    write(*,'(a)') 'FAIL: bad query reported stat = 0'; fails = fails + 1
  end if
  if ( .not. allocated( db%errmsg ) ) then
    write(*,'(a)') 'FAIL: errmsg not allocated after a failed query'; fails = fails + 1
  else if ( len_trim( db%errmsg ) == 0 ) then
    write(*,'(a)') 'FAIL: errmsg allocated but empty'; fails = fails + 1
  else
    write(*,'(a)') 'PASS: captured -> '//trim( db%errmsg )
  end if
  call db%clear_result()

  ! --- 2. a subsequent SUCCESSFUL query must clear it ------------------------
  ! Without this, a caller checking stat then reading errmsg would attribute the
  ! previous failure's message to a query that actually succeeded.
  call db%send( "SELECT 1" )
  if ( db%stat /= 0 ) then
    write(*,'(a)') 'FAIL: good query reported an error'; fails = fails + 1
  end if
  if ( allocated( db%errmsg ) ) then
    write(*,'(a)') 'FAIL: stale errmsg survived a successful query -> '//trim(db%errmsg)
    fails = fails + 1
  else
    write(*,'(a)') 'PASS: errmsg cleared after success'
  end if
  call db%clear_result()
  call db%close()

  if ( fails == 0 ) then
    write(*,'(a)') 'ALL TESTS PASSED'
  else
    write(*,'(a,i0,a)') 'FAILURES: ', fails, ''
    error stop 1
  end if
end program test_errmsg
