cmake_minimum_required(VERSION 3.10)

project( mbed_app LANGUAGES CXX )

set( CMAKE_CXX_STANDARD 14 )
set( CMAKE_CXX_STANDARD_REQUIRED ON )

# Specify the source files
set( SOURCES
    main.cpp
)

# Add the executable
add_executable( mbed_app ${SOURCES} )

# Include directories (if any)
# target_include_directories( mbed_app PRIVATE include )

# Link libraries
target_link_libraries( mbed_app PRIVATE pthread m )