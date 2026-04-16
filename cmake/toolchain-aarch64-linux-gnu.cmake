# cmake/toolchain-aarch64-linux-gnu.cmake
# Cross-compilation toolchain for AArch64 (aarch64-linux-gnu)
#
# Target:  64-bit ARM, glibc, Linux
# Boards:  Raspberry Pi 4/5 (64-bit), NVIDIA Jetson, BeagleBone AI-64
# Package: apt install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

set(CMAKE_SYSTEM_NAME      Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(TOOLCHAIN_PREFIX       aarch64-linux-gnu)
set(CMAKE_C_COMPILER       ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER     ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_STRIP            ${TOOLCHAIN_PREFIX}-strip)

# Prevent CMake from searching host paths for libraries and includes
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
