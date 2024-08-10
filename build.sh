#!/bin/bash

echo "Building dynamic c library from Swift code..."

# Run the Swift package commands to build the dynamic c library
swift package clean
swift build --configuration release

# Copy the library
if cp .build/release/libLoopAlgorithmToPython.dylib ./python_api/; then
    echo "Library successfully copied to the python_api folder!"
else
    echo "Failed to copy the library to the python_api folder."
fi
