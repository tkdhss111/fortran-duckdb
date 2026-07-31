#!/usr/bin/env bash
# Fetch the DuckDB C library + CLI this binding is built against.
#
# The library is NOT tracked in this repository. It is platform-specific and ~200 MB, so
# committing it would (a) force every user to download bytes for a platform they may not be
# on, (b) grow the history by that much on every upgrade, and (c) run into GitHub's 100 MB
# per-file limit before long. Run this script once after cloning instead.
#
#   ./install_duckdb.sh                 # default version, auto-detected platform
#   DUCKDB_VERSION=v1.5.2 ./install_duckdb.sh
#   DUCKDB_PLATFORM=linux-arm64 ./install_duckdb.sh
#
# Unpacks into ./libduckdb-<platform>/, which is what CMakeLists.txt and the test makefile
# expect. Requires curl and unzip only -- no compiler toolchain, unlike building from source.
set -euo pipefail

DUCKDB_VERSION=${DUCKDB_VERSION:-v1.5.2}

# Map uname to the asset names DuckDB publishes. Override with DUCKDB_PLATFORM if the guess
# is wrong (e.g. musl-based distributions need the -musl variants).
detect_platform () {
  local os arch
  os=$( uname -s )
  arch=$( uname -m )
  case "$os" in
    Linux)
      case "$arch" in
        x86_64|amd64)  echo linux-amd64 ;;
        aarch64|arm64) echo linux-arm64 ;;
        *) echo "unsupported architecture: $arch" >&2; return 1 ;;
      esac ;;
    Darwin) echo osx-universal ;;
    MINGW*|MSYS*|CYGWIN*)
      case "$arch" in
        x86_64|amd64)  echo windows-amd64 ;;
        aarch64|arm64) echo windows-arm64 ;;
        *) echo "unsupported architecture: $arch" >&2; return 1 ;;
      esac ;;
    *) echo "unsupported OS: $os" >&2; return 1 ;;
  esac
}

PLATFORM=${DUCKDB_PLATFORM:-$( detect_platform )}
DEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/libduckdb-${PLATFORM}"
BASE="https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}"

command -v curl  >/dev/null || { echo "curl is required"  >&2; exit 1; }
command -v unzip >/dev/null || { echo "unzip is required" >&2; exit 1; }

echo "DuckDB ${DUCKDB_VERSION} (${PLATFORM}) -> ${DEST}"
mkdir -p "$DEST"
tmp=$( mktemp -d )
trap 'rm -rf "$tmp"' EXIT

# libduckdb-* carries the shared library, the static archive and the headers.
# duckdb_cli-* carries the standalone CLI, handy for inspecting a database by hand.
for asset in "libduckdb-${PLATFORM}.zip" "duckdb_cli-${PLATFORM}.zip"; do
  echo "  fetching ${asset}"
  if ! curl -fsSL --retry 3 -o "${tmp}/${asset}" "${BASE}/${asset}"; then
    echo "  *** could not download ${BASE}/${asset}" >&2
    echo "      check DUCKDB_VERSION / DUCKDB_PLATFORM against the release page" >&2
    exit 1
  fi
  unzip -qo "${tmp}/${asset}" -d "$DEST"
done

# DuckDB does not publish a checksum file with its releases, so there is nothing to verify
# against beyond the TLS transport. Pin DUCKDB_VERSION rather than tracking "latest".
[ -f "${DEST}/duckdb" ] && chmod +x "${DEST}/duckdb"

echo "installed:"
ls -1 "$DEST" | sed 's/^/  /'
[ -x "${DEST}/duckdb" ] && echo "  version: $( "${DEST}/duckdb" --version )"
