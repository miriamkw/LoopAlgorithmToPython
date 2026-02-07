#!/bin/bash

echo "Building dynamic c library from Swift code..."

# 1. Clean and Build
# Using -v (verbose) is critical for debugging why it's silent
swift package clean
swift package update
echo "Building Swift package..."
swift build --configuration release -v

echo "Build completed. Locating artifacts..."

# 2. Detect OS and set Extension
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS system..."
    OS_DIR="macos"
    EXT="dylib"
    PREFIX="lib"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
    echo "Detected Windows system..."
    OS_DIR="windows"
    EXT="dll"
    PREFIX="" # Windows often drops the 'lib' prefix
else
    echo "Detected Linux system..."
    OS_DIR="linux"
    EXT="so"
    PREFIX="lib"
fi

# 3. DYNAMIC SEARCH
echo "Searching for LoopAlgorithmToPython.$EXT in .build directory..."

# Try searching for both 'libLoopAlgorithmToPython' and 'LoopAlgorithmToPython'
# We use -iname to ignore case and look specifically for the release folder
SOURCE_LIB=$(find .build -type f \( -iname "libLoopAlgorithmToPython.$EXT" -o -iname "LoopAlgorithmToPython.$EXT" \) | grep -i "release" | head -n 1)

# If find fails, let's try a direct path check for the standard Windows output location
if [ -z "$SOURCE_LIB" ]; then
    DIRECT_WIN_PATH=".build/x86_64-unknown-windows-msvc/release/LoopAlgorithmToPython.dll"
    if [ -f "$DIRECT_WIN_PATH" ]; then
        SOURCE_LIB="$DIRECT_WIN_PATH"
    fi
fi

if [ -z "$SOURCE_LIB" ] || [ ! -f "$SOURCE_LIB" ]; then
    echo "ERROR: Could not find the compiled library!"
    echo "Debugging: Current directory structure in .build:"
    ls -R .build 2>/dev/null | head -n 20
    exit 1
fi

echo "Found library at: $SOURCE_LIB"

# 4. Prepare Destination
DEST_DIR="./loop_to_python_api/dlibs/$OS_DIR"
# We force the destination name to 'libLoopAlgorithmToPython.dll' so your Python code remains consistent
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