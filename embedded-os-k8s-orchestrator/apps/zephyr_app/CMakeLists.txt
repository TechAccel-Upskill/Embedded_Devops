cmake_minimum_required(VERSION 3.13.1)

project(zephyr_app C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(SOURCES
    main.c
)

# Try to find Zephyr's CMake configuration
find_package(Zephyr QUIET HINTS $ENV{ZEPHYR_BASE})

if(Zephyr_FOUND)
    include_directories(${ZEPHYR_INCLUDE_DIRS})
    add_executable(zephyr_app ${SOURCES})
    target_link_libraries(zephyr_app ${ZEPHYR_LIBRARIES})
else()
    # Build as standalone application if Zephyr is not found
    message(STATUS "Zephyr not found, building as standalone application")
    add_executable(zephyr_app ${SOURCES})
    target_link_libraries(zephyr_app pthread m)
endif()

# Compiler flags
if(CMAKE_C_COMPILER_ID MATCHES "GNU")
    target_compile_options(zephyr_app PRIVATE
        -Wall
        -Wextra
        -O2
    )
endif()

# Installation
install(TARGETS zephyr_app DESTINATION bin)