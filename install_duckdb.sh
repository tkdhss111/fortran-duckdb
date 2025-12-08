sudo apt-get update
sudo apt-get install -y git g++ cmake ninja-build libssl-dev
git clone https://github.com/duckdb/duckdb
cd duckdb
GEN=ninja make