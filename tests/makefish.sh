#!/bin/bash
# makefish.sh

cd ../src

# check all given flags
check_flags () {
    for flag; do
        printf '%s\n' "$flags" | grep -q -w "$flag" || return 1
    done
}

# find the CPU architecture
output=$(g++ -Q -march=native --help=target)
flags=$(printf '%s\n' "$output" | awk '/\[enabled\]/ {print substr($1, 3)}' | tr '\n' ' ')
arch=$(printf '%s\n' "$output" | awk '/march/ {print $NF; exit}' | tr -d '[:space:]')

if check_flags 'avx512vnni' 'avx512dq' 'avx512f' 'avx512bw' 'avx512vl'; then
  arch_cpu='x86-64-vnni256'
elif check_flags 'avx512f' 'avx512bw'; then
  arch_cpu='x86-64-avx512'
elif check_flags 'bmi2' && [ $arch != 'znver1' ] && [ $arch != 'znver2' ]; then
  arch_cpu='x86-64-bmi2'
elif check_flags 'avx2'; then
  arch_cpu='x86-64-avx2'
elif check_flags 'sse4.1' 'popcnt'; then
  arch_cpu='x86-64-sse41-popcnt'
elif check_flags 'ssse3'; then
  arch_cpu='x86-64-ssse3'
elif check_flags 'sse3' 'popcnt'; then
  arch_cpu='x86-64-sse3-popcnt'
else
  arch_cpu='x86-64'
fi

# build the fastest Stockfish executable
make -j profile-build ARCH=${arch_cpu} COMP=mingw
make strip
mv stockfish.exe ../stockfish_${arch_cpu}.exe
make clean
cd