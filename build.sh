#!/bin/bash

echo "Building dynamic c library from Swift code..."

# Run the Swift package commands to build the dynamic c library
swift package clean
swift package update
swift build --configuration release

# Detect the operating system and set the library extension
if [[ "$OSTYPE" == "darwin"* ]]; then
    LIBRARY_EXT="dylib"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    LIBRARY_EXT="so"
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Copy the library
if cp .build/release/libLoopAlgorithmToPython.$LIBRARY_EXT ./loop_to_python_api/; then
    echo "Library successfully copied to the loop_to_python_api folder!"
else
    echo "Failed to copy the library to the loop_to_python_api folder."
fi
