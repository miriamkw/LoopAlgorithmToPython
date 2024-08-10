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


def get_active_carbs(json_file):
    json_bytes = get_bytes_from_json(json_file)

    swift_lib.getActiveCarbs.argtypes = [ctypes.c_char_p]
    swift_lib.getActiveCarbs.restype = ctypes.c_double

    return swift_lib.getActiveCarbs(json_bytes)


def get_active_insulin(json_file):
    json_bytes = get_bytes_from_json(json_file)

    swift_lib.getActiveInsulin.argtypes = [ctypes.c_char_p]
    swift_lib.getActiveInsulin.restype = ctypes.c_double

    return swift_lib.getActiveInsulin(json_bytes)


# Calculating the percentage of carbohydrate absorption at the percent time, with piecewise linear model
# Input is percent as fraction
def percent_absorption_at_percent_time(percent_time):
    swift_lib.percentAbsorptionAtPercentTime.argtypes = [ctypes.c_double]
    swift_lib.percentAbsorptionAtPercentTime.restype = ctypes.c_double

    return swift_lib.percentAbsorptionAtPercentTime(percent_time)


# Calculating the percentage rate of carbohydrate absorption at the percent time, with piecewise linear model
# Input is percent as fraction
def piecewise_linear_percent_rate_at_percent_time(percent_time):
    swift_lib.percentRateAtPercentTime.argtypes = [ctypes.c_double]
    swift_lib.percentRateAtPercentTime.restype = ctypes.c_double

    return swift_lib.percentRateAtPercentTime(percent_time)


# Input is percent as fraction
def linear_percent_rate_at_percent_time(percent_time):
    swift_lib.linearPercentRateAtPercentTime.argtypes = [ctypes.c_double]
    swift_lib.linearPercentRateAtPercentTime.restype = ctypes.c_double

    return swift_lib.linearPercentRateAtPercentTime(percent_time)


def get_dynamic_carbs_on_board(json_file):
    json_bytes = get_bytes_from_json(json_file)

    swift_lib.getDynamicCarbsOnBoard.argtypes = [ctypes.c_char_p]
    swift_lib.getDynamicCarbsOnBoard.restype = ctypes.c_double

    return swift_lib.getDynamicCarbsOnBoard(json_bytes)




# THIS IS FOR TESTING, REMOVE WHEN DONE!

with open('python_tests/test_files/generate_prediction_input.json', 'r') as f:
    prediction_input = json.load(f)


with open('python_tests/test_files/loop_algorithm_input.json', 'r') as f:
    loop_algorithm_input = json.load(f)


with open('python_tests/test_files/dynamic_carbs_input.json', 'r') as f:
    dynamic_carbs_input = json.load(f)


initialize_exception_handlers()
prediction_values = generate_prediction(prediction_input)
print("prediction values", prediction_values)
print(" ")
prediction_dates = get_prediction_dates(prediction_input)
print("prediction dates", prediction_dates)
print(" ")
glucose_effect_velocity = get_glucose_effect_velocity(prediction_input)
print("glucose_effect_velocity", glucose_effect_velocity)
print(" ")
glucose_effect_velocity_dates = get_glucose_effect_velocity_dates(prediction_input)
print("glucose_effect_velocity_dates", glucose_effect_velocity_dates)
print(" ")
active_carbs = get_active_carbs(loop_algorithm_input)
print("active_carbs", active_carbs)
print(" ")
active_insulin = get_active_insulin(loop_algorithm_input)
print("active_insulin", active_insulin)
print(" ")
percent_absorption_at_percent_time = percent_absorption_at_percent_time(0.2)
print("percent_absorption_at_percent_time", percent_absorption_at_percent_time)
print(" ")
piecewise_linear_percent_rate_at_percent_time = piecewise_linear_percent_rate_at_percent_time(0.2)
print("piecewise_linear_percent_rate_at_percent_time", piecewise_linear_percent_rate_at_percent_time)
print(" ")
linear_percent_rate_at_percent_time = linear_percent_rate_at_percent_time(0.2)
print("linear_percent_rate_at_percent_time", linear_percent_rate_at_percent_time)
print(" ")
dynamic_carbs_on_board = get_dynamic_carbs_on_board(dynamic_carbs_input)
print("dynamic_carbs_on_board", dynamic_carbs_on_board)
print(" ")


