# Symlink the DuckDB headers + shared library into /usr/lib so builds find them without
# LD_LIBRARY_PATH. Paths are derived from this makefile's own location, not hardcoded.
DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

link:
	ln -sf $(DIR)/duckdb.h   /usr/lib/duckdb.h
	ln -sf $(DIR)/duckdb.hpp /usr/lib/duckdb.hpp
	ln -sf $(DIR)/libduckdb.so /usr/lib/libduckdb.so

unlink:
	rm -f /usr/lib/duckdb.h /usr/lib/duckdb.hpp /usr/lib/libduckdb.so
