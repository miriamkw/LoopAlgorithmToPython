#!/bin/bash

echo "Building dynamic c library from Swift code..."

# Run the Swift package commands to build the dynamic c library
swift package clean
# swift package update
swift build --configuration release

# Determine the OS and handle the library accordingly
case "$(uname -s)" in
    Darwin)
        # macOS
        if cp .build/release/libLoopAlgorithmToPython.dylib ./loop_to_python_api/; then
            echo "macOS: Library successfully copied to the loop_to_python_api folder!"
        else
            echo "macOS: Failed to copy the library to the loop_to_python_api folder."
        fi
        ;;
    Linux)
        # Linux
        if cp .build/release/libLoopAlgorithmToPython.so ./loop_to_python_api/; then
            echo "Linux: Library successfully copied to the loop_to_python_api folder!"
        else
            echo "Linux: Failed to copy the library to the loop_to_python_api folder."
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)
        # Windows
        if cp .build/release/LoopAlgorithmToPython.dll ./loop_to_python_api/; then
            echo "Windows: Library successfully copied to the loop_to_python_api folder!"
        else
            echo "Windows: Failed to copy the library to the loop_to_python_api folder."
        fi
        ;;
    *)
        echo "Unsupported OS: $(uname -s). Please check your environment."
        exit 1
        ;;
esac

