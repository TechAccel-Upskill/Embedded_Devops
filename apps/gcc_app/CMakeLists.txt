cmake_minimum_required(VERSION 3.20)

project(gcc_app LANGUAGES CXX)

# Acknowledge toolchain file variable (used by CMake internally for cross-compilation)
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_TOOLCHAIN_FILE}" CACHE FILEPATH "Toolchain file")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Specify the source files
set( SOURCES
    main.cpp
)

# Add the executable
add_executable( gcc_app ${SOURCES} )

# Include directories (if any)
# target_include_directories( gcc_app PRIVATE include )

# Link libraries
target_link_libraries( gcc_app PRIVATE pthread m )