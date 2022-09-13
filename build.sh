#!/bin/bash
# Copyright 2021 Saleem Abdulrasool <compnerd@compnerd.org>
# Copyright 2022 Puyan Lotfi <puyan@puyan.org>
#
# Base on https://github.com/compnerd/swift-build by compnerd.
# Modified specifically for Darwin.

# Set a clean path. Edit as you see fit.
export PATH=/Applications/CMake.app/Contents/bin/:/usr/bin:/bin:/usr/sbin:/sbin

# Fill these in.
SourceRoot=$(pwd)
# BuildType=Release
BuildType=RelWithDebInfo
# BuildType=Debug

SourceCache=$SourceRoot
BuildDir=$SourceRoot/build/$BuildType
BinaryCache=$BuildDir/BinaryCache
InstallRoot=$BuildDir/Library
ToolchainInstallRoot=${InstallRoot}/Developer/Toolchains/unknown-Asserts-development.xctoolchain
PlatformInstallRoot=${InstallRoot}/Developer/Platforms/macOS.platform
SDKInstallRoot="${PlatformInstallRoot}/Developer/SDKs/macOS.sdk"

export PYTHON_HOME=/usr/bin/

# Uncomment to clean up.
# rm -rf $BuildDir

set -e

cmake -E copy $SourceRoot/swift/stdlib/public/Cxx/cxxshim/libcxxshim.modulemap $BinaryCache/toolchain/./lib/swift/macosx/x86_64/libcxxshim.modulemap
cmake -E copy $SourceRoot/swift/stdlib/public/Cxx/cxxshim/libcxxshim.h         $BinaryCache/toolchain/./lib/swift/macosx/x86_64/libcxxshim.h
cmake -E copy $SourceRoot/swift/stdlib/public/Cxx/cxxshim/libcxxshim.modulemap $BinaryCache/toolchain/./lib/swift/macosx/arm64/libcxxshim.modulemap
cmake -E copy $SourceRoot/swift/stdlib/public/Cxx/cxxshim/libcxxshim.h         $BinaryCache/toolchain/./lib/swift/macosx/arm64/libcxxshim.h

# toolchain
cmake                                                                           \
  -B "${BinaryCache}/toolchain"                                                 \
  -D CMAKE_C_COMPILER=clang                                                     \
  -D CMAKE_CXX_COMPILER=clang++                                                 \
  -D CMAKE_BUILD_TYPE=$BuildType                                                \
  -D CMAKE_INSTALL_LIBDIR=lib                                                   \
  -D CMAKE_INSTALL_PREFIX="${ToolchainInstallRoot}/usr"                         \
  -D LLVM_EXTERNAL_CMARK_SOURCE_DIR="${SourceCache}/cmark"                      \
  -D LLVM_EXTERNAL_SWIFT_SOURCE_DIR="${SourceCache}/swift"                      \
  -D PYTHON_EXECUTABLE=/usr/bin/python3                                         \
  -D Python3_EXECUTABLE=/usr/bin/python3                                        \
  -D LLVM_EXTERNAL_SWIFT_Python3_EXECUTABLE=/usr/bin/python3                    \
  -D LLVM_EXTERNAL_swift_PYTHON_EXECUTABLE=/usr/bin/python3                     \
  -D LLVM_EXTERNAL_cmark_PYTHON_EXECUTABLE=/usr/bin/python3                     \
  -D LLVM_EXTERNAL_swift_SWIFT_STDLIB_ENABLE_OBJC_INTEROP=ON                    \
  -D SWIFT_STDLIB_ENABLE_OBJC_INTEROP=ON                                        \
  -D LLVM_ENABLE_ASSERTIONS=ON                                                  \
  -D CMAKE_OSX_DEPLOYMENT_TARGET=12.3                                           \
  -D SWIFT_PATH_TO_SWIFT_SYNTAX_SOURCE=${SourceCache}/swift-syntax                      \
  -D LLVM_ENABLE_PROJECTS="llvm;clang;lld;libcxx;libcxxabi;clang-tools-extra;compiler-rt" \
  -D LLVM_EXTERNAL_PROJECTS="cmark;swift"                                       \
  -D CMAKE_VERBOSE_MAKEFILE=OFF                                                 \
  -D SWIFT_ENABLE_EXPERIMENTAL_CONCURRENCY=YES                                  \
  -D SWIFT_ENABLE_EXPERIMENTAL_DIFFERENTIABLE_PROGRAMMING=YES                   \
  -D SWIFT_ENABLE_EXPERIMENTAL_DISTRIBUTED=YES                                  \
  -D SWIFT_ENABLE_EXPERIMENTAL_STRING_PROCESSING=YES                            \
  -D EXPERIMENTAL_STRING_PROCESSING_SOURCE_DIR=${SourceCache}/swift-experimental-string-processing \
  -D SWIFT_STDLIB_SUPPORT_BACK_DEPLOYMENT=YES                                   \
  -D SWIFT_PATH_TO_LIBDISPATCH_SOURCE=${SourceCache}/swift-corelibs-libdispatch \
  -G Ninja                                                                      \
  -S "${SourceCache}/llvm-project/llvm"
cmake --build "${BinaryCache}/toolchain"
cmake --build "${BinaryCache}/toolchain" --target install

