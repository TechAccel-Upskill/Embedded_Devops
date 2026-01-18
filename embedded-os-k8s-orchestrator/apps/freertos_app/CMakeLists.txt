cmake_minimum_required(VERSION 3.10)

# Set the project name
project(freertos_app C)

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Specify the source files
set(SOURCES
    main.c
)

# Add an executable target
add_executable(${PROJECT_NAME} ${SOURCES})

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Link libraries (FreeRTOS and other system libraries)
target_link_libraries(${PROJECT_NAME} PRIVATE
    pthread
    m
)

# Compiler flags
if(CMAKE_C_COMPILER_ID MATCHES "GNU")
    target_compile_options(${PROJECT_NAME} PRIVATE
        -Wall
        -Wextra
        -O2
    )
endif()

# Installation
install(TARGETS ${PROJECT_NAME} DESTINATION bin)