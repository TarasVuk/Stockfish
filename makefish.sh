cd src

gcc_enabled=$(g++ -Q -march=native --help=target | grep "\[enabled\]")
gcc_arch=$(g++ -Q -march=native --help=target | grep "march")

if [[ "${gcc_enabled}" =~ "-mavx512vnni " && "${gcc_enabled}" =~ "-mavx512dq " && "${gcc_enabled}" =~ "-mavx512f " && "${gcc_enabled}" =~ "-mavx512bw " && "${gcc_enabled}" =~ "-mavx512vl " ]] ; then
  arch_cpu="x86-64-vnni256"
elif [[ "${gcc_enabled}" =~ "-mavx512f " && "${gcc_enabled}" =~ "-mavx512bw " ]] ; then
  arch_cpu="x86-64-avx512"
elif [[ "${gcc_enabled}" =~ "-mbmi2 " && ! "${gcc_arch}" =~ "znver1" && ! "${gcc_arch}" =~ "znver2" ]] ; then
  arch_cpu="x86-64-bmi2"
elif [[ "${gcc_enabled}" =~ "-mavx2 " ]] ; then
  arch_cpu="x86-64-avx2"
elif [[ "${gcc_enabled}" =~ "-mpopcnt " && "${gcc_enabled}" =~ "-msse4.1 " ]] ; then
  arch_cpu="x86-64-sse41-popcnt"
elif [[ "${gcc_enabled}" =~ "-mssse3 " ]] ; then
  arch_cpu="x86-64-ssse3"
elif [[ "${gcc_enabled}" =~ "-mpopcnt " && "${gcc_enabled}" =~ "-msse3 " ]] ; then
  arch_cpu="x86-64-sse3-popcnt"
else
  arch_cpu="x86-64"
fi

# build the fastest Stockfish executable
make -j profile-build ARCH=${arch_cpu} COMP=mingw
make strip
mv stockfish.exe /c/Users/Marina/Documents/Arena/Engines/Stockfish/stockfish_${arch_cpu}.exe
make clean
cd