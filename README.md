[![DOI](https://zenodo.org/badge/819432700.svg)](https://doi.org/10.5281/zenodo.18524715)

# LoopAlgorithmToPython

This Swift module uses LoopAlgorithm to create C functions for generating predictions and prediction dates from JSON data.

This is achieved by creating a foreign function interface (FFI) in Swift by using the unofficial @_cdecl Swift function. This interfaces the Swift code with C. Then we can create a dynamic library, import it into a Python (or other) repositories, and use for example ctypes to compile the C code.


## Repository Overview

### Exposed functions

You can find the C-exposed functions in the file `Sources/LoopAlgorithmToPython/LoopAlgorithmToPython.swift`.

### Python API 

Python API functions are located in `loop_to_python_api/api.py`.

### Tests and test data

`python_tests/` contains examples of executing all the functions as well as example files providing templates on how to structure the input files.


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
### Get Dose Recommendations

`get_dose_recommendations(json_file)`

Uses the Loop algorithm to get the recommended bolus dose and basal rate.

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
- **Returns**: A dictionary containing the dose recommendation. Example: 
```
{'automatic': {
    'bolusUnits': 0, 
    'basalAdjustment': {
      'unitsPerHour': 0.5,
      'duration': 1800  # Seconds
    }
  }
}
```

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

### Get Loop Recommendations

`get_loop_recommendations(json_file)`

Uses the Loop algorithm to get comprehensive recommendations in JSON format.

- **Parameters**: 
  - `json_file`: The JSON data input. See python tests and test files for example inputs.
- **Returns**: A JSON string containing the complete Loop recommendations.

-------------------------

### Insulin Percent Effect Remaining

`insulin_percent_effect_remaining(minutes, action_duration, peak_activity_time, delay)`

Calculates the percentage of insulin effect remaining at a given time point using the exponential insulin model.

- **Parameters**: 
  - `minutes`: Time point in minutes to calculate effect remaining
  - `action_duration`: Total duration of insulin action in minutes
  - `peak_activity_time`: Time to peak insulin activity in minutes  
  - `delay`: Delay before insulin activity begins in minutes
- **Returns**: Percentage of insulin effect remaining (0.0 to 1.0)
- **Example**:
```python
# Calculate remaining effect at 60 minutes for typical rapid-acting insulin
remaining = insulin_percent_effect_remaining(
    minutes=60,           # 60 minutes after injection
    action_duration=360,  # 6 hours total duration
    peak_activity_time=75, # Peak at 75 minutes
    delay=10             # 10 minute delay
)
```

-------------------------


### Add Insulin Counteraction Effect to DataFrame

`add_insulin_counteraction_effect_to_df(df, basal, isf, cr, insulin_type='novolog')`

Adds an insulin counteraction effect column to the DataFrame input.

- **Parameters**: 
  - `df`: The dataframe data input, with at least the columns basal, bolus and CGM, with datetime index.
  - `basal`: Basal insulin rate (units/hour). 
  - `isf`: Insulin sensitivity factor (mg/dL per unit). 
  - `cr`: Carbohydrate ratio (grams per unit of insulin). 
  - `insulin_type`: Type of insulin (default 'novolog').
- **Returns**: The dataframe with an "ice" column.


-------------------------

### Add Insulin on Board to DataFrame

`add_insulin_on_board_to_df(df, basal, isf, cr, insulin_type='novolog', lookback=72)`

Adds an insulin counteraction effect column to the DataFrame input.

- **Parameters**: 
  - `df`: The dataframe data input, with at least the columns basal, bolus and CGM, with datetime index.
  - `basal`: Basal insulin rate (units/hour). 
  - `isf`: Insulin sensitivity factor (mg/dL per unit). 
  - `cr`: Carbohydrate ratio (grams per unit of insulin). 
  - `insulin_type`: Type of insulin (default 'novolog').
  - `lookback`: Lookback to use for computing insulin on board (default 72).
- **Returns**: The dataframe with an "ice" column.

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

⚠️ **Known Issue**: This function currently has a unit conversion error and may fail with "Conversion Error: g is not compatible with mg/dL·s". See the Known Issues section below for more details.

-------------------------

## Known Issues

### Windows CI Build Limitation

**Issue**: Windows .dll file is not automatically updated via CI  
**Status**: Temporary limitation due to Swift toolchain issues  

**Description**: While the repository includes a Windows .dll file for the LoopAlgorithmToPython library, the CI system currently cannot automatically rebuild this file for Windows due to Swift toolchain circular dependency issues (`cyclic dependency in module 'ucrt': ucrt -> _Builtin_intrinsics -> ucrt`). 

**Current State**: 
- ✅ Windows tests run successfully using the existing committed .dll file
- ✅ macOS (.dylib) and Linux (.so) files are automatically updated via CI
- ❌ Windows (.dll) file requires manual local builds and commits

**Workaround**: The Windows .dll file can still be built locally and manually committed to the repository. The CI tests on Windows will use the committed .dll file.

**Future Resolution**: This limitation will be resolved when Swift's Windows toolchain issues are fixed upstream.

---

### `get_dynamic_carbs_on_board()` Function

**Issue**: Unit conversion error preventing function execution  
**Error Message**: `LoopAlgorithm/LoopQuantity.swift:31: Fatal error: Conversion Error: g is not compatible with mg/dL·s`  
**Status**: Under investigation  

**Description**: The `get_dynamic_carbs_on_board()` function encounters a unit conversion error when attempting to calculate dynamic carbohydrates on board. The error occurs in the underlying LoopAlgorithm library when trying to convert between gram units (for carbohydrates) and glucose rate units (mg/dL per second).

**Workaround**: Currently, no workaround is available. The function exists in the API for future compatibility but should not be used in production until this issue is resolved.

**Test Status**: The corresponding test (`test_get_dynamic_carbs_on_board`) is skipped in the test suite to prevent CI failures.

---

## Build Dynamic Library

The dynamic libraries are organized in platform-specific directories:
- **macOS**: `loop_to_python_api/dlibs/macos/libLoopAlgorithmToPython.dylib`
- **Linux**: `loop_to_python_api/dlibs/linux/libLoopAlgorithmToPython.so` 
- **Windows**: `loop_to_python_api/dlibs/windows/libLoopAlgorithmToPython.dll` (plus dependencies)

After making changes in the Swift code, rebuild the dynamic library by running `chmod +x build.sh` followed by `./build.sh`. The build script automatically detects your platform and places the library in the correct `dlibs/` subdirectory.

## Installing on Linux

See linux_setup.sh

## Run Tests

Run command `pytest`.


## Debugging Advice and Disclaimers

This library supports macOS, Linux, and Windows platforms with cross-platform dynamic library loading. 

Debugging with this pipeline can be a pain... Calling functions with python does not give informative error messages, even though the `initialize_exception_handlers()` helps a little bit.

What I found the most useful is to go into LoopAlgorithm repository and run existing tests, but changing the input json files to the input json file that I am trying to use with this repository.

Getting `zsh: killed` error in the terminal indicates that there are too many processes running, and you have to make sure to stop them - so be aware that this error does not necessarily mean that the dynamic library is corrupted. It is a to do to make the `api.py` a class that automatically makes sure that processes are properly closed after running. 


