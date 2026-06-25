#!/bin/bash
set -e

wget -q -O /tmp/llvm-cmake.tar.xz \
    https://anduin.linuxfromscratch.org/BLFS/llvm/llvm-cmake-21.1.8.src.tar.xz

wget -q -O /tmp/llvm-third-party.tar.xz \
    https://anduin.linuxfromscratch.org/BLFS/llvm/llvm-third-party-21.1.8.src.tar.xz

wget -q -O /tmp/clang.tar.xz \
    https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.8/clang-21.1.8.src.tar.xz

tar -xf /tmp/llvm-cmake.tar.xz
tar -xf /tmp/llvm-third-party.tar.xz

sed '/LLVM_COMMON_CMAKE_UTILS/s@../cmake@cmake-21.1.8.src@' \
    -i CMakeLists.txt
sed '/LLVM_THIRD_PARTY_DIR/s@../third-party@third-party-21.1.8.src@' \
    -i cmake/modules/HandleLLVMOptions.cmake

tar -xf /tmp/clang.tar.xz -C tools
mv tools/clang-21.1.8.src tools/clang

grep -rl '#!.*python' | xargs sed -i '1s/python$/python3/'

sed 's/utility/tool/' -i utils/FileCheck/CMakeLists.txt

mkdir -v build
cd build

CC=gcc CXX=g++ cmake \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_SKIP_INSTALL_RPATH=ON \
    -D LLVM_ENABLE_FFI=ON \
    -D CMAKE_BUILD_TYPE=Release \
    -D LLVM_BUILD_LLVM_DYLIB=ON \
    -D LLVM_LINK_LLVM_DYLIB=ON \
    -D LLVM_ENABLE_RTTI=ON \
    -D LLVM_TARGETS_TO_BUILD="host;AMDGPU" \
    -D LLVM_BINUTILS_INCDIR=/usr/include \
    -D LLVM_INCLUDE_BENCHMARKS=OFF \
    -D CLANG_DEFAULT_PIE_ON_LINUX=ON \
    -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang \
    -W no-dev -G Ninja ..

ninja

DESTDIR="$DESTDIR" ninja install

mkdir -pv "$DESTDIR/etc/clang"
for i in clang clang++; do
    echo -fstack-protector-strong > "$DESTDIR/etc/clang/$i.cfg"
done

rm -f /tmp/llvm-cmake.tar.xz /tmp/llvm-third-party.tar.xz /tmp/clang.tar.xz
