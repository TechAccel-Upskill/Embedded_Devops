# cmake/toolchain-riscv64-linux-gnu.cmake
# Cross-compilation toolchain for RISC-V 64-bit (riscv64-linux-gnu)
#
# Target:  64-bit RISC-V, glibc, Linux
# Boards:  SiFive HiFive Unmatched, StarFive VisionFive 2, Milk-V Mars
# Package: apt install gcc-riscv64-linux-gnu g++-riscv64-linux-gnu

set(CMAKE_SYSTEM_NAME      Linux)
set(CMAKE_SYSTEM_PROCESSOR riscv64)

set(TOOLCHAIN_PREFIX       riscv64-linux-gnu)
set(CMAKE_C_COMPILER       ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER     ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_STRIP            ${TOOLCHAIN_PREFIX}-strip)

# Prevent CMake from searching host paths for libraries and includes
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
