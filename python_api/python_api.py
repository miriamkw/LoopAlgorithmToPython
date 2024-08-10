"""
This file provides an API for calling the functions in the dynamic library. These functions are c-embeddings
for swift functions, found in Sources/LoopAlgorithmToPython/LoopAlgorithmToPython.swift.
"""
from helpers import get_bytes_from_json

import ctypes
import json


swift_lib = ctypes.CDLL('python_api/libLoopAlgorithmToPython.dylib')


# This function helps with providing more informative error messages if the code fails
def initialize_exception_handlers():
    # Define the function prototypes
    initializeExceptionHandler = swift_lib.initializeExceptionHandler
    initializeExceptionHandler.restype = None

    initializeSignalHandlers = swift_lib.initializeSignalHandlers
    initializeSignalHandlers.restype = None

    # Initialize the exception handler and signal handlers
    initializeExceptionHandler()
    initializeSignalHandlers()


def generate_prediction(json_file, len=82):
    json_bytes = get_bytes_from_json(json_file)

    swift_lib.generatePrediction.argtypes = [ctypes.c_char_p]
    swift_lib.generatePrediction.restype = ctypes.POINTER(ctypes.c_double)

    result = swift_lib.generatePrediction(json_bytes)
    result_array = [result[i] for i in range(len)]

    return result_array










with open('python_tests/test_files/generate_prediction_input.json', 'r') as f:
    json_file = json.load(f)


initialize_exception_handlers()
res = generate_prediction(json_file)

print(res)