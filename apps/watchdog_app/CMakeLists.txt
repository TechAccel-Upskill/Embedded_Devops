cmake_minimum_required(VERSION 3.20)
project(watchdog_app LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(watchdog_app main.cpp)
target_compile_options(watchdog_app PRIVATE -Wall -Wextra -O2)
target_link_libraries(watchdog_app PRIVATE pthread)
