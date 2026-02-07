#!/bin/bash

echo "Building dynamic c library from Swift code..."

# 1. Clean and Build
swift package clean
swift package update
echo "Building Swift package..."
swift build --configuration release --verbose

echo "Build completed. Locating artifacts..."

# 2. Detect OS and set Extension
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

# 3. DYNAMIC SEARCH
# We search the whole .build folder because Windows/Linux use subfolders
# like .build/x86_64-unknown-windows-msvc/release/
echo "Searching for *LoopAlgorithmToPython.$EXT in .build directory..."
SOURCE_LIB=$(find .build -name "*LoopAlgorithmToPython.$EXT" | grep -i "release" | head -n 1)

if [ -z "$SOURCE_LIB" ] || [ ! -f "$SOURCE_LIB" ]; then
    echo "ERROR: Could not find the compiled library!"
    echo "Check the Swift compiler logs above for errors."
    exit 1
fi

echo "Found library at: $SOURCE_LIB"

# 4. Prepare Destination
DEST_DIR="./loop_to_python_api/dlibs/$OS_DIR"
# On Windows, we ensure the output follows the 'lib...' naming convention for your Python API
DEST_LIB="$DEST_DIR/libLoopAlgorithmToPython.$EXT"

mkdir -p "$DEST_DIR"

# 5. Copy and Verify
echo "Copying to: $DEST_LIB"
if cp "$SOURCE_LIB" "$DEST_LIB"; then
    echo "✓ Library successfully copied!"
    ls -la "$DEST_LIB"
else
    echo "✗ Failed to copy the library!"
    exit 1
fi