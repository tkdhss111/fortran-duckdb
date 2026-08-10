# Fortran Utility Functions for DuckDB Fortran API

**Work in progress**

This program is a collection of wrapper functions for the following DuckDB Fortran API:

name = "duckdb"  
version = "0.1.0"  
license = "MIT"  
author = "Andre Smit, Ludovico Nicotina"  
maintainer = "freevryheid@gmail.com"  
copyright = "Copyright 2023, Andre Smit"

## Setup

The DuckDB library is not tracked in this repository — it is platform-specific and
~200 MB. Fetch it once after cloning:

```bash
./install_duckdb.sh                      # auto-detects your platform
DUCKDB_VERSION=v1.5.2 ./install_duckdb.sh
DUCKDB_PLATFORM=linux-arm64 ./install_duckdb.sh
```

Linux (amd64/arm64), macOS and Windows are supported. Only `curl` and `unzip` are
needed — no compiler toolchain.

## Modules

| module | purpose |
|---|---|
| `duckdb_mo.f90` | `duckdb_ty` — connection, queries, table/cell access, parquet + CSV export, and the bulk-insert appender. Self-contained: declares the C bindings it needs inline |
| `ducklake_mo.f90` | `ducklake_ty` — DuckLake lifecycle: attach, fan-in commit, publish, merge, reclaim |

`ducklake_mo` is optional; vendor it only if you use DuckLake. It depends on `duckdb_mo`
and `iso_c_binding`, nothing else. Requires DuckDB >= 1.x, since the DuckLake extension
does not exist for older releases.

## Error handling

Every query goes through `send`, and the outcome is on the type:

| member | after a query |
|---|---|
| `stat` | `0` on success, non-zero on failure |
| `errmsg` | the DuckDB error text on failure; **deallocated** on success |

```fortran
type(duckdb_ty) :: db
call db%open( '' )                       ! '' = in-memory
call db%send( "SELECT 1" )
if ( db%stat /= 0 ) then
  write(*,'(a)') 'query failed: '//trim( db%errmsg )   ! e.g. "Catalog Error: Table ..."
end if
call db%clear_result( )
call db%close( )
```

`errmsg` is cleared at the start of every `send`, so it always describes the **most
recent** call — testing `stat` first and only then reading `errmsg` is the safe order.
Check `allocated( db%errmsg )` if you want to be defensive; it is unallocated whenever
the last query succeeded.

The message is also written to stdout when a query fails. That is convenient in a
terminal, but stdout is not something a program can inspect: if you are writing your own
log, retrying selectively, or deciding *which* failure occurred, read `errmsg` — do not
try to scrape it back out of your console.

> **Note.** `open` is not forgiving in the same way: a failure to create the config, set
> the access mode, or open the database is an `error stop`, which ends the caller's
> program. Only query errors are returned via `stat`/`errmsg`.

## A note on `duckdb.f90`

Earlier versions vendored `duckdb.f90`, a ~3700-line binding generated against the whole
of `duckdb.h`. It has been **removed**. `duckdb_mo.f90` is now the only entry point: it
declares inline the handful of C interfaces it actually calls, including the appender
(`duckdb_appender_create` / `_end_row` / `_flush` / `_close` / `_destroy` / `_error` and
`duckdb_append_float` / `_varchar` / `_null`), which was the last part of the generated
binding still reachable from real code.

Consumers need no `src/duckdb.f90` and no `duckdb.f90` entry in `CMakeLists.txt` — just
`use duckdb_mo`. If a build reports

    error #7002: Error in opening the compiled module file ... [DUCKDB]

something still says `use duckdb`; change it to `use duckdb_mo`.

The binding is kept deliberately narrow: add an interface when something here needs it,
rather than mirroring the entire C API again.
