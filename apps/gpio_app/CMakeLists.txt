cmake_minimum_required(VERSION 3.20)
project(gpio_app LANGUAGES CXX)

# Acknowledge toolchain file variable (used by CMake internally for cross-compilation)
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_TOOLCHAIN_FILE}" CACHE FILEPATH "Toolchain file")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(gpio_app main.cpp)
target_compile_options(gpio_app PRIVATE -Wall -Wextra -O2)
# No extra link libraries — uses only C++ standard library and POSIX file I/O
