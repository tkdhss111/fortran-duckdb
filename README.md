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
| `duckdb.f90` | generated binding to the DuckDB C API |
| `duckdb_mo.f90` | `duckdb_ty` — connection, queries, table/cell access, parquet + CSV export |
| `ducklake_mo.f90` | `ducklake_ty` — DuckLake lifecycle: attach, fan-in commit, publish, merge, reclaim |

`ducklake_mo` is optional; vendor it only if you use DuckLake. It depends on `duckdb_mo`
and `iso_c_binding`, nothing else. Requires DuckDB >= 1.x, since the DuckLake extension
does not exist for older releases.

