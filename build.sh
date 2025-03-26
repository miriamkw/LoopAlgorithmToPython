#!/bin/bash

echo "Building dynamic c library from Swift code..."

# Run the Swift package commands to build the dynamic c library
swift package clean
swift package update
swift build --configuration release

# Copy the library
if cp .build/release/libLoopAlgorithmToPython.so ./loop_to_python_api/; then
    echo "Library successfully copied to the loop_to_python_api folder!"
else
    echo "Failed to copy the library to the loop_to_python_api folder."
fi
