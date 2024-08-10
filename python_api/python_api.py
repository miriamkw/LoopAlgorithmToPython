"""
This file provides an API for calling the functions in the dynamic library. These functions are c-embeddings
for swift functions, found in Sources/LoopAlgorithmToPython/LoopAlgorithmToPython.swift.
"""
import pandas as pd

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


def generate_prediction(json_file, len=72):
    json_bytes = get_bytes_from_json(json_file)

    swift_lib.generatePrediction.argtypes = [ctypes.c_char_p]
    swift_lib.generatePrediction.restype = ctypes.POINTER(ctypes.c_double)

    result = swift_lib.generatePrediction(json_bytes)
    return [result[i] for i in range(len)]


def get_prediction_dates(json_file):
    json_bytes = get_bytes_from_json(json_file)

    swift_lib.getPredictionDates.argtypes = [ctypes.c_char_p]
    swift_lib.getPredictionDates.restype = ctypes.c_char_p

    result = swift_lib.getPredictionDates(json_bytes).decode('utf-8')
    date_list = result.split(',')[:-1]
    #date_list = [pd.to_datetime(date) for date in date_list]

    return date_list


# TODO: Add combined predictions and dates, with assertequals to check whether they are of same length


# "Glucose effect velocity" is equivalent to insulin counteraction effect (ICE)
def get_glucose_effect_velocity(json_file, len=72):
    json_bytes = get_bytes_from_json(json_file)

    swift_lib.getGlucoseEffectVelocity.argtypes = [ctypes.c_char_p]
    swift_lib.getGlucoseEffectVelocity.restype = ctypes.POINTER(ctypes.c_double)

    result = swift_lib.getGlucoseEffectVelocity(json_bytes)
    return [result[i] for i in range(len)]


def get_glucose_effect_velocity_dates(json_file):
    json_bytes = get_bytes_from_json(json_file)

    swift_lib.getGlucoseEffectVelocityDates.argtypes = [ctypes.c_char_p]
    swift_lib.getGlucoseEffectVelocityDates.restype = ctypes.c_char_p

    result = swift_lib.getGlucoseEffectVelocityDates(json_bytes).decode('utf-8')
    date_list = result.split(',')[:-1]
    #date_list = [pd.to_datetime(date) for date in date_list]

    return date_list









# THIS IS FOR TESTING, REMOVE WHEN DONE!

with open('python_tests/test_files/generate_prediction_input.json', 'r') as f:
    json_file = json.load(f)


initialize_exception_handlers()
prediction_values = generate_prediction(json_file)
print("prediction values", prediction_values)
print(" ")
prediction_dates = get_prediction_dates(json_file)
print("prediction dates", prediction_dates)
print(" ")
glucose_effect_velocity = get_glucose_effect_velocity(json_file)
print("glucose_effect_velocity", glucose_effect_velocity)
print(" ")
glucose_effect_velocity_dates = get_glucose_effect_velocity_dates(json_file)
print("glucose_effect_velocity_dates", glucose_effect_velocity_dates)
print(" ")


