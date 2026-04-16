cmake_minimum_required(VERSION 3.20)
project(sensor_app LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(sensor_app main.cpp)
target_compile_options(sensor_app PRIVATE -Wall -Wextra -O2)
target_link_libraries(sensor_app PRIVATE pthread)
