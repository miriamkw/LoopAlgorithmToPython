#!/bin/bash

echo "Building dynamic c library from Swift code..."

# Run the Swift package commands to build the dynamic c library
swift package clean
swift package update
echo "Building Swift package..."
swift build --configuration release --verbose

echo "Build completed. Files in .build/release/:"
ls -la .build/release/ 2>/dev/null || echo "No .build/release directory found"

# Detect the operating system and set the library paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    SOURCE_LIB=".build/release/libLoopAlgorithmToPython.dylib"
    DEST_LIB="./loop_to_python_api/dlibs/macos/libLoopAlgorithmToPython.dylib"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux: Swift might generate different library names/paths
    # Check for possible library names
    if [ -f ".build/release/libLoopAlgorithmToPython.so" ]; then
        SOURCE_LIB=".build/release/libLoopAlgorithmToPython.so"
    elif [ -f ".build/release/LoopAlgorithmToPython.so" ]; then
        SOURCE_LIB=".build/release/LoopAlgorithmToPython.so"
    elif [ -f ".build/release/libLoopAlgorithmToPython" ]; then
        SOURCE_LIB=".build/release/libLoopAlgorithmToPython"
    else
        echo "ERROR: Could not find Linux library file. Available files:"
        find .build/release/ -name "*Loop*" -o -name "*.so" 2>/dev/null || echo "No library files found"
        exit 1
    fi
    DEST_LIB="./loop_to_python_api/dlibs/linux/libLoopAlgorithmToPython.so"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    SOURCE_LIB=".build/release/LoopAlgorithmToPython.dll"
    DEST_LIB="./loop_to_python_api/dlibs/windows/libLoopAlgorithmToPython.dll"
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Copy the library
if cp "$SOURCE_LIB" "$DEST_LIB"; then
    echo "Library successfully copied to the loop_to_python_api folder!"
else
    echo "Failed to copy the library. Source: $SOURCE_LIB"
    echo "Available files in .build/release/:"
    ls -la .build/release/ 2>/dev/null || echo "No build output found"
fi

