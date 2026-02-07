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

# Also check for any library files specifically
echo "Looking for library files in .build/release/:"
find .build/release/ -name "*Loop*" -o -name "*.dylib" -o -name "*.so" -o -name "*.dll" 2>/dev/null || echo "No library files found"

# Detect the operating system and set the library paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    SOURCE_LIB=".build/release/libLoopAlgorithmToPython.dylib"
    DEST_LIB="./loop_to_python_api/dlibs/macos/libLoopAlgorithmToPython.dylib"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux system. Searching for library files..."
    # Linux: Swift might generate different library names/paths
    # Check for possible library names
    if [ -f ".build/release/libLoopAlgorithmToPython.so" ]; then
        SOURCE_LIB=".build/release/libLoopAlgorithmToPython.so"
        echo "Found library: $SOURCE_LIB"
    elif [ -f ".build/release/LoopAlgorithmToPython.so" ]; then
        SOURCE_LIB=".build/release/LoopAlgorithmToPython.so"
        echo "Found library: $SOURCE_LIB"
    elif [ -f ".build/release/libLoopAlgorithmToPython" ]; then
        SOURCE_LIB=".build/release/libLoopAlgorithmToPython"
        echo "Found library (no extension): $SOURCE_LIB"
    else
        echo "ERROR: Could not find Linux library file!"
        echo "Searched for:"
        echo "  - .build/release/libLoopAlgorithmToPython.so"
        echo "  - .build/release/LoopAlgorithmToPython.so" 
        echo "  - .build/release/libLoopAlgorithmToPython"
        echo ""
        echo "Available files in .build/release/:"
        ls -la .build/release/ 2>/dev/null || echo "Directory not accessible"
        echo ""
        echo "All library-like files found:"
        find .build/release/ -name "*Loop*" -o -name "*.so" -o -name "*.a" -o -name "lib*" 2>/dev/null || echo "No library files found"
        echo ""
        echo "Swift build might have failed or generated different output on Linux."
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

# Create destination directory if it doesn't exist
DEST_DIR=$(dirname "$DEST_LIB")
if [ ! -d "$DEST_DIR" ]; then
    echo "Creating destination directory: $DEST_DIR"
    mkdir -p "$DEST_DIR"
fi

# Copy the library
echo "Copying library:"
echo "  From: $SOURCE_LIB"
echo "  To:   $DEST_LIB"

if cp "$SOURCE_LIB" "$DEST_LIB"; then
    echo "✓ Library successfully copied!"
    echo "Final library info:"
    ls -la "$DEST_LIB"
else
    echo "✗ Failed to copy the library!"
    echo "Source file info:"
    ls -la "$SOURCE_LIB" 2>/dev/null || echo "Source file does not exist or is not accessible"
    echo "Available files in .build/release/:"
    ls -la .build/release/ 2>/dev/null || echo "No build output found"
    exit 1
fi

