#!/bin/bash

echo "Building dynamic c library from Swift code..."

# Run the Swift package commands
swift package clean
swift package update
echo "Building Swift package..."
# Note: Windows requires the toolchain to be set up, which your YAML handles
swift build --configuration release --verbose

echo "Build completed. Locating artifacts..."

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS system..."
    OS_DIR="macos"
    EXT="dylib"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
    echo "Detected Windows system..."
    OS_DIR="windows"
    EXT="dll"
else
    echo "Detected Linux system..."
    OS_DIR="linux"
    EXT="so"
fi

# THE FIX: Search the entire .build folder for the library.
# Windows uses paths like .build/x86_64-unknown-windows-msvc/release/
echo "Searching for *LoopAlgorithmToPython.$EXT in .build directory..."
SOURCE_LIB=$(find .build -name "*LoopAlgorithmToPython.$EXT" | grep -i "release" | head -n 1)

if [ -z "$SOURCE_LIB" ] || [ ! -f "$SOURCE_LIB" ]; then
    echo "ERROR: Could not find the compiled library!"
    echo "Check above for Swift compiler errors."
    echo "Current directory contents:"
    ls -R .build 2>/dev/null | grep ":$" | head -n 20
    exit 1
fi

echo "Found library at: $SOURCE_LIB"

# Define destination
DEST_DIR="./loop_to_python_api/dlibs/$OS_DIR"
DEST_LIB="$DEST_DIR/libLoopAlgorithmToPython.$EXT"

# Create destination directory
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
    ls -la "$DEST_LIB"
else
    echo "✗ Failed to copy the library!"
    exit 1
fi