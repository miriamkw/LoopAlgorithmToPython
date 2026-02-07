#!/bin/bash

echo "Building dynamic c library from Swift code..."

# Run the Swift package commands to build the dynamic c library
swift package clean
swift package update
echo "Building Swift package..."
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
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi
