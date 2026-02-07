#!/bin/bash

echo "Building dynamic c library from Swift code..."

# 1. Clean and Build
# Using -v (verbose) is critical for debugging why it's silent
swift package clean
swift package update
echo "Building Swift package..."
swift build --configuration release -v

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
    PREFIX="lib"
fi

# 3. DYNAMIC SEARCH
echo "Searching for LoopAlgorithmToPython.$EXT in .build directory..."

# Try searching for both 'libLoopAlgorithmToPython' and 'LoopAlgorithmToPython'
# We use -iname to ignore case and look specifically for the release folder
SOURCE_LIB=$(find .build -type f \( -iname "libLoopAlgorithmToPython.$EXT" -o -iname "LoopAlgorithmToPython.$EXT" \) | grep -i "release" | head -n 1)

# If find fails, let's try a direct path check for the standard Windows output location
if [ -z "$SOURCE_LIB" ]; then
    DIRECT_WIN_PATH=".build/x86_64-unknown-windows-msvc/release/LoopAlgorithmToPython.dll"
    if [ -f "$DIRECT_WIN_PATH" ]; then
        SOURCE_LIB="$DIRECT_WIN_PATH"
    fi
fi

if [ -z "$SOURCE_LIB" ] || [ ! -f "$SOURCE_LIB" ]; then
    echo "ERROR: Could not find the compiled library!"
    echo "Debugging: Current directory structure in .build:"
    ls -R .build 2>/dev/null | head -n 20
    exit 1
fi
