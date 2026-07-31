program unit_test_varchar

  ! Regression test for get_cell on VARCHAR.
  !
  ! DuckDB stores short strings inline (<= 12 bytes) and longer ones out of line, so a
  ! string-reading bug typically shows up only past that boundary and looks
  ! data-dependent. Both lengths are checked here for that reason.

  use duckdb_mo
  implicit none
  type(duckdb_ty) :: db
  character(64)   :: s
  integer(8)      :: n
  logical         :: bad
  character(*), parameter :: long_str  = '2026-07-31 12:34:56'   ! 19 bytes, NOT inlined
  character(*), parameter :: short_str = 'short'                 !  5 bytes, inlined

  bad = .false.
  print *, '========================================='
  print *, ' VARCHAR read tests'
  print *, '========================================='

  call db%open( '' )
  call db%send( "CREATE TABLE t AS SELECT '"//long_str//"' AS a, '"//short_str//"' AS b" )
  call db%clear_result( )
  call db%get_table( 't', nrows = n )

  s = ''
  call db%get_cell( 1_8, 1_8, s )
  print *, 'non-inlined (19B): [', trim(s), ']'
  if ( trim(s) /= long_str ) then
    print *, '  *** expected [', long_str, '] — truncated or corrupted'
    bad = .true.
  end if

  s = ''
  call db%get_cell( 1_8, 2_8, s )
  print *, 'inlined      (5B): [', trim(s), ']'
  if ( trim(s) /= short_str ) then
    print *, '  *** expected [', short_str, ']'
    bad = .true.
  end if

  call db%close
  if ( bad ) error stop '*** VARCHAR read is broken'
  print *, 'All VARCHAR tests passed'

end program unit_test_varchar
