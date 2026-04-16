# cmake/toolchain-arm-linux-gnueabihf.cmake
# Cross-compilation toolchain for ARM Cortex-A (arm-linux-gnueabihf)
#
# Target:  32-bit ARM hard-float ABI, glibc, Linux
# Boards:  Raspberry Pi 2/3 (32-bit mode), BeagleBone Black, NXP i.MX6
# Package: apt install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf

set(CMAKE_SYSTEM_NAME      Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TOOLCHAIN_PREFIX       arm-linux-gnueabihf)
set(CMAKE_C_COMPILER       ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER     ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_STRIP            ${TOOLCHAIN_PREFIX}-strip)

# Prevent CMake from searching host paths for libraries and includes
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# ARMv7-A tuning — compatible with Cortex-A7, A8, A9, A53 in 32-bit mode
set(CMAKE_C_FLAGS_INIT   "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard")
set(CMAKE_CXX_FLAGS_INIT "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard")
