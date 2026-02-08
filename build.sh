#!/bin/bash

echo "Building dynamic library..."

# 1. Clean and Build
# Removing 'swift package update' from every CI run saves time; 'clean' is enough.
swift package clean
echo "Building Swift package..."
swift build --configuration release -v

echo "Build completed. Locating artifacts..."

# 2. Detect OS and set Extension
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_DIR="macos"; EXT="dylib"; PREFIX="lib"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
    OS_DIR="windows"; EXT="dll"; PREFIX=""
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
else
    # Mac/Linux path
    SOURCE_LIB=$(find .build -name "libLoopAlgorithmToPython.$EXT" | grep -i "release" | head -n 1)
fi

# 4. Verification and Copy
if [ -f "$SOURCE_LIB" ]; then
    echo "Found library at: $SOURCE_LIB"
    DEST_DIR="./loop_to_python_api/dlibs/$OS_DIR"
    # Consistency: Force prefix 'lib' even on Windows for your Python loader
    DEST_LIB="$DEST_DIR/libLoopAlgorithmToPython.$EXT"
    
    mkdir -p "$DEST_DIR"
    cp "$SOURCE_LIB" "$DEST_LIB"
    echo "✓ Library successfully copied to $DEST_LIB"
else
    echo "ERROR: Could not find the compiled library!"
    echo "Check the build log above for 'swiftc' errors."
    exit 1
fi