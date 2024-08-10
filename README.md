# LoopAlgorithmToPython

This Swift module uses LoopAlgorithm to create C functions for generating predictions and prediction dates from JSON data.

This is achieved by creating a foreign function interface (FFI) in Swift by using the unofficial @_cdecl Swift function. This interfaces the Swift code with C. Then we can create a dynamic library, import it into a Python (or other) repositories, and use for example ctypes to compile the C code.



## Installation

### TODO: Add examples with pypi 



## Repository Overview

### Exposed functions

You can find the C-exposed functions in the file `LoopAlgorithmToPython.swift`.

### Python API 

Python API functions are located in `loop_to_python_api/api.py`.

### Tests and test data

`python_tests/` contains examples of executing all the functions as well as example files providing templates on how to structure the input files.


## Usage in Python

### TODO: Remove this and add examples for pypi usage instead


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

swift_lib.getPredictionDates.argtypes = [ctypes.c_char_p]
swift_lib.getPredictionDates.restype = ctypes.c_char_p

swift_lib.getActiveCarbs.argtypes = [ctypes.c_char_p]
swift_lib.getActiveCarbs.restype = ctypes.c_double

swift_lib.getActiveInsulin.argtypes = [ctypes.c_char_p]
swift_lib.getActiveInsulin.restype = ctypes.c_double

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

# Call the Swift functions
result_prediction_values = swift_lib.generatePrediction(json_bytes)
result_prediction_dates = swift_lib.getPredictionDates(json_bytes).decode('utf-8')
result_active_carbs = swift_lib.getActiveCarbs(json_bytes)
result_active_insulin = swift_lib.getActiveInsulin(json_bytes)

# Read the generated predictions
array = [result_prediction_values[i] for i in range(length)]
print(array[0])
print(f"The result from generatePrediction is: {array}")

# Read the dates
date_list = result.split(',')[:-1]
print(f"The result from getPredictionDates is: {date_list}")

# Read the active carbohydrates
print(f"The result from getActiveCarbs is: {result_active_carbs}")

# Read the active insulin
print(f"The result from getActiveInsulin is: {result_active_insulin}")
```

Adjust the paths, function names, and details as per your specific project setup and requirements.








To do:
- [X] add a python folder
- [X] add a test folder
- [X] add the dlib build script 
  - build to python folder
  - add readme
- [X] write python functions api 
- [X] write tests with example files
- [ ] create pypi package
- [ ] add a build script 
  - [ ] automatically run tests on push 
  - [ ] automatically build new dlib on push
- [X] clean up code swift
- [X] clean up code python
- [ ] update readme with new changes
  - [X] explanation, separating between python and swift code
  - [X] example usage of the api (with signal handlers), and example inputs (refer to test files)
  - [X] refer to example input files
  - build, venv, run commands
  - pypi
  - [X] running tests
- [ ] merge to main
- [ ] next project: take a df as input, convert to json (or do it in tidepool study?)



## Python API Functions

-------------------------

### Initialize Exception Handlers

`initialize_exception_handlers()`

Initializes the exception and signal handlers in the Swift library to provide more informative error messages.

-------------------------

### Generate Prediction

`generate_prediction(json_file, len=72)`

Generates a prediction based on the provided JSON input.

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
  - `len` (optional): The number of prediction values to generate. Defaults to 72.
- **Returns**: A list of prediction values.

-------------------------

### Get Prediction Dates

`get_prediction_dates(json_file)`

Fetches prediction dates based on the provided JSON input.

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
- **Returns**: A list of prediction dates as strings.

-------------------------

### Get Prediction Values and Dates

`get_prediction_values_and_dates(json_file)`

Combines the `generate_prediction` and `get_prediction_dates` functions to return both prediction values and dates.

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
- **Returns**: A tuple containing a list of prediction values and a list of prediction dates.

-------------------------

### Get Glucose Effect Velocity 

`get_glucose_effect_velocity(json_file, len=72)`

Fetches the glucose effect velocity, which is equivalent to Insulin Counteraction Effect (ICE). 

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
  - `len` (optional): The number of values to fetch. Defaults to 72.
- **Returns**: A list of glucose effect velocity values.

-------------------------

### Get Glucose Effect Velocity Dates

`get_glucose_effect_velocity_dates(json_file)`

Fetches the dates associated with the glucose effect velocity.

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
- **Returns**: A list of dates as strings.


-------------------------

### Get Glucose Velocity Values and Dates

`get_glucose_velocity_values_and_dates(json_file)`

Combines the `get_glucose_effect_velocity` and `get_glucose_effect_velocity_dates` functions to return both glucose effect velocity values and dates.

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
- **Returns**: A tuple containing a list of glucose effect velocity values and a list of dates.

-------------------------

### Get Active Carbs

`get_active_carbs(json_file)`

Fetches the active carbohydrates based on the provided JSON input.

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
- **Returns**: The active carbohydrates as a double.


-------------------------

### Get Active Insulin

`get_active_insulin(json_file)`

Fetches the active insulin based on the provided JSON input.

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
- **Returns**: The active insulin as a double.

-------------------------

### Percent Absorption at Percent Time

`percent_absorption_at_percent_time(percent_time)`

Calculates the percentage of carbohydrate absorption at a given percent time using a piecewise linear model.

- **Parameters**: 
  - `percent_time`: The time as a fraction (e.g., 0.2 for 20%).
- **Returns**: The percentage of absorption as a double.

-------------------------

### Piecewise Linear Percent Rate at Percent Time

`piecewise_linear_percent_rate_at_percent_time(percent_time)`

Calculates the percentage rate of carbohydrate absorption at a given percent time using a piecewise linear model.

- **Parameters**: 
  - `percent_time`: The time as a fraction (e.g., 0.2 for 20%).
- **Returns**: The percentage rate of absorption as a double.

-------------------------

### Linear Percent Rate at Percent Time

`linear_percent_rate_at_percent_time(percent_time)`

Calculates the percentage rate of carbohydrate absorption at a given percent time using a linear model.

- **Parameters**: 
  - `percent_time`: The time as a fraction (e.g., 0.2 for 20%).
- **Returns**: The percentage rate of absorption as a double.

-------------------------

### Get Dynamic Carbs on Board

`get_dynamic_carbs_on_board(json_file)`
Fetches the dynamic carbohydrates on board based on the provided JSON input.

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
- **Returns**: The dynamic carbohydrates on board as a double.

-------------------------




## Build Dynamic Library

The file `python_api/libLoopAlgorithmToPython.dylib` contains the dynamic library that is containing the C-embedded Swift functions. 

After making changes in the Swift code, rebuild the dynamic library by running `chmod +x build.sh` followed by `./build.sh`.



## Run Tests

Run command `pytest`.




