Write-Host "Building dynamic C library from Swift code..."

# Run the Swift package commands to build the dynamic C library
swift package clean
swift build --configuration release

# Determine the OS and handle the library accordingly
$libPath = ".\build\release\LoopAlgorithmToPython.dll"
$destPath = ".\loop_to_python_api\"

# Check if the library exists
if (Test-Path $libPath) {
    Copy-Item -Path $libPath -Destination $destPath -Force
    Write-Host "Windows: Library successfully copied to the loop_to_python_api folder!"
} else {
    Write-Host "Windows: Failed to find the library at $libPath."
    exit 1
}
