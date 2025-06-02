#!/usr/bin/env bash
set -euo pipefail

export WORKFLOW_ROOT="/Users/runner/work/futurerestore/futurerestore/.github/workflows"
export DEP_ROOT="/Users/runner/work/futurerestore/futurerestore/dep_root"
export BASE="/Users/runner/work/futurerestore/futurerestore"
export PROCURSUS="/opt/procursus"

cd "$BASE"

typeset -A targets=(
  [release-x86_64] "$DEP_ROOT/macOS_x86_64_Release"
  [debug-x86_64]   "$DEP_ROOT/macOS_x86_64_Debug"
  [release-arm64]  "$DEP_ROOT/macOS_arm64_Release"
  [debug-arm64]    "$DEP_ROOT/macOS_arm64_Debug"
)

for key val in ${(kv)targets}; do
  ln -sf "$val/lib" "$DEP_ROOT/lib"
  ln -sf "$val/include" "$DEP_ROOT/include"

  build_type=${key%%-*}
  arch=${key##*-}
  build_dir="cmake-build-${key}"

  cmake -DCMAKE_BUILD_TYPE="${build_type:u}" \
        -DCMAKE_MAKE_PROGRAM="$(which make)" \
        -DCMAKE_C_COMPILER="$(which clang)" \
        -DCMAKE_CXX_COMPILER="$(which clang++)" \
        -DCMAKE_MESSAGE_LOG_LEVEL=WARNING \
        -G "CodeBlocks - Unix Makefiles" \
        -S ./ -B "$build_dir" -DARCH="$arch" -DNO_PKGCFG=ON

  make -j4 -C "$build_dir"
done

# ASAN builds
for arch in x86_64 arm64; do
  ln -sf "$DEP_ROOT/macOS_${arch}_Debug/lib" "$DEP_ROOT/lib"
  ln -sf "$DEP_ROOT/macOS_${arch}_Debug/include" "$DEP_ROOT/include"

  build_dir="cmake-build-asan-${arch}"
  cmake -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_MAKE_PROGRAM="$(which make)" \
        -DCMAKE_C_COMPILER="$(which clang)" \
        -DCMAKE_CXX_COMPILER="$(which clang++)" \
        -DCMAKE_MESSAGE_LOG_LEVEL=WARNING \
        -G "CodeBlocks - Unix Makefiles" \
        -S ./ -B "$build_dir" -DARCH="$arch" -DNO_PKGCFG=ON -DASAN=OFF

  make -j4 -C "$build_dir"
done

# Strip final release binaries
llvm-strip -s cmake-build-release-x86_64/src/futurerestore || true
llvm-strip -s cmake-build-release-arm64/src/futurerestore || true
