#!/bin/bash

echo "Building dynamic c library from Swift code..."

# Run the Swift package commands to build the dynamic c library
swift package clean
swift build --configuration release

# Copy the dlib that got created and paste it into the python_api folder
# Assuming the .dylib or .so file is located in the .build/release/ directory
cp .build/release/libLoopAlgorithmToPython.dylib ./python_api/

echo "Library successfully copied to the python_api folder!"
