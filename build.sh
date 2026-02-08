#!/bin/bash

echo "Building dynamic library..."

# 1. Clean and Build
# Removing 'swift package update' from every CI run saves time; 'clean' is enough.
swift package clean
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
    OS_DIR="linux"; EXT="so"; PREFIX="lib"
fi

# 3. DYNAMIC SEARCH
echo "Searching for library in .build directory..."

# Try the most likely Windows path first if on Windows
if [ "$OS_DIR" == "windows" ]; then
    # Swift 6 on Windows usually outputs here:
    SOURCE_LIB=$(find .build -name "LoopAlgorithmToPython.dll" | grep -i "release" | head -n 1)
    
    # Fallback: Check the explicit target-based path
    if [ -z "$SOURCE_LIB" ]; then
        SOURCE_LIB=".build/x86_64-unknown-windows-msvc/release/LoopAlgorithmToPython.dll"
    fi
fi

if [ -z "$SOURCE_LIB" ] || [ ! -f "$SOURCE_LIB" ]; then
    echo "ERROR: Could not find the compiled library!"
    echo "Debugging: Current directory structure in .build:"
    ls -R .build 2>/dev/null | head -n 20
    exit 1
fi
