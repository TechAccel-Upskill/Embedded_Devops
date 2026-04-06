#!/bin/bash

# Universal build script for all embedded OS applications

set -e

# Define applications and their respective build systems
declare -A apps
apps=( 
    ["freertos_app"]="CMakeLists.txt Makefile BUILD.bazel"
    ["gcc_app"]="CMakeLists.txt Makefile BUILD.bazel"
    ["zephyr_app"]="CMakeLists.txt Makefile BUILD.bazel"
)

# Function to build each application
build_app() {
    local app_name=$1
    echo "Building $app_name..."

    # Check for CMake build
    if [ -f "apps/$app_name/CMakeLists.txt" ]; then
        mkdir -p "apps/$app_name/build"
        cd "apps/$app_name/build"
        cmake ..
        make
        cd - > /dev/null
    fi

    # Check for Makefile build
    if [ -f "apps/$app_name/Makefile" ]; then
        cd "apps/$app_name"
        make
        cd - > /dev/null
    fi

    # Check for Bazel build
    if [ -f "apps/$app_name/BUILD.bazel" ]; then
        if command -v bazel &> /dev/null; then
            echo "  - Building with Bazel"
            cd "apps/$app_name"
            bazel build //...
            cd - > /dev/null
        else
            echo "  - Bazel not installed, skipping Bazel build"
        fi
    fi

    echo "$app_name built successfully."
}

# Build all applications
for app in "${!apps[@]}"; do
    build_app "$app"
done

echo ""
echo "All applications built successfully!"