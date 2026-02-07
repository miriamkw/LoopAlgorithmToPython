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
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    SOURCE_LIB=".build/release/LoopAlgorithmToPython.dll"
    DEST_LIB="./loop_to_python_api/libLoopAlgorithmToPython.dll"
    LIBRARY_EXT="dll"
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

## Earlier code commended out
## Copy the library
#if cp .build/release/libLoopAlgorithmToPython.$LIBRARY_EXT ./loop_to_python_api/; then
#    echo "Library successfully copied to the loop_to_python_api folder!"
#else
#    echo "Failed to copy the library to the loop_to_python_api folder."
#fi

# Copy the library
if cp "$SOURCE_LIB" "$DEST_LIB"; then
    echo "Library successfully copied to the loop_to_python_api folder!"
else
    echo "Failed to copy the library. Source: $SOURCE_LIB"
    ls -la .build/release/*.dll 2>/dev/null || echo "No DLL files found"
fi

