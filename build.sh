#!/bin/bash

echo "Building dynamic c library from Swift code..."

# Run the Swift package commands to build the dynamic c library
swift package clean
swift package update
swift build --configuration release

# Detect the operating system and set the library paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    SOURCE_LIB=".build/release/libLoopAlgorithmToPython.dylib"
    DEST_LIB="./loop_to_python_api/dlibs/macos/libLoopAlgorithmToPython.dylib"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    SOURCE_LIB=".build/release/libLoopAlgorithmToPython.so"
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

