# LoopAlgorithmToPython

This Swift module uses LoopAlgorithm to create C functions for generating predictions and prediction dates from JSON data.

How?
I create a foreign function interface (FFI) in Swift by using the unofficial @_cdecl Swift function. This interfaces the Swift code with C. Then we can create a dynamic library, import it into a Python (or other) repositories, and use for example ctypes to compile the C code.


## Installation

1. Clone the repository
2. Build the dynamic library:

```
swift package clean
swift build --configuration release
```
Check if the dynamic library got properly generated and print the path:
```
find .build -name "libLoopAlgorithmToPython.dylib"
```
Output should be something like: /release/libLoopAlgorithmToPython.dylib

Copy that file into your repository.


## Exposed functions

You can find the C-exposed functions in the file `LoopAlgorithmToPython.swift`.



## Usage in Python

Here's how you can use the dynamic library (`libLoopAlgorithmToPython.dylib`) in Python to call the exposed functions:

```
import ctypes
import json

json_file_path = 'some_file.json'

# Load the shared library
swift_lib = ctypes.CDLL('./libLoopAlgorithmToPython.dylib')

# Specify the argument types and return type of the Swift function
swift_lib.generatePrediction.argtypes = [ctypes.c_char_p]
swift_lib.generatePrediction.restype = ctypes.POINTER(ctypes.c_double)

# Read JSON file
def read_json_file(file_path):
    with open(file_path, 'r') as f:
        data = json.load(f)
    return data

json_data = read_json_file(json_file_path) # Read JSON file
json_str = json.dumps(json_data) # Convert JSON data to JSON string
json_bytes = json_str.encode('utf-8') # Convert JSON string to bytes

# Prepare a variable to receive the length of the predicted values
length = 82

# Call the Swift function
result = swift_lib.generatePrediction(json_bytes)

# Read the generated predictions
array = [result[i] for i in range(length)]
print(array[0])
print(f"The result from generatePrediction is: {array}")

# Specify the argument types and return type of the prediction dates
swift_lib.getPredictionDates.argtypes = [ctypes.c_char_p]
swift_lib.getPredictionDates.restype = ctypes.c_char_p

# Call the Swift function
result = swift_lib.getPredictionDates(json_bytes).decode('utf-8')
date_list = result.split(',')[:-1]
print(f"The result from getPredictionDates is: {date_list}")
```

Adjust the paths, function names, and details as per your specific project setup and requirements.









