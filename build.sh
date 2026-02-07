#!/bin/bash

echo "Building dynamic c library from Swift code..."

# Run the Swift package commands
swift package clean
swift package update
echo "Building Swift package..."
# Note: Windows requires the toolchain to be set up, which your YAML handles
swift build --configuration release --verbose

echo "Build completed. Checking build output..."

# Check if build directory exists
if [ ! -d ".build/release/" ]; then
    echo "ERROR: No .build/release directory found!"
    echo "Available .build directories:"
    ls -la .build/ 2>/dev/null || echo "No .build directory found at all"
    exit 1
fi

echo "Files in .build/release/:"
ls -la .build/release/ 2>/dev/null || echo "No .build/release directory found"

# Detect the operating system and copy the appropriate library
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if cp .build/release/libLoopAlgorithmToPython.dylib ./loop_to_python_api/; then
        echo "Library successfully copied to the loop_to_python_api folder!"
    else
        echo "Failed to copy the .dylib library to the loop_to_python_api folder."
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if cp .build/release/libLoopAlgorithmToPython.so ./loop_to_python_api/; then
        echo "Library successfully copied to the loop_to_python_api folder!"
    else
        echo "Failed to copy the .so library to the loop_to_python_api folder."
    fi
else
    echo "Detected Linux system..."
    OS_DIR="linux"
    EXT="so"
fi

# THE FIX: Search the entire .build folder for the library.
# Windows uses paths like .build/x86_64-unknown-windows-msvc/release/
echo "Searching for *LoopAlgorithmToPython.$EXT in .build directory..."
SOURCE_LIB=$(find .build -name "*LoopAlgorithmToPython.$EXT" | grep -i "release" | head -n 1)

if [ -z "$SOURCE_LIB" ] || [ ! -f "$SOURCE_LIB" ]; then
    echo "ERROR: Could not find the compiled library!"
    echo "Check above for Swift compiler errors."
    echo "Current directory contents:"
    ls -R .build 2>/dev/null | grep ":$" | head -n 20
    exit 1
fi
