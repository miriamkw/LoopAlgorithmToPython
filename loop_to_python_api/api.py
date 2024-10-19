"""
This file provides an API for calling the functions in the dynamic library. These functions are c-embeddings
for swift functions, found in Sources/LoopAlgorithmToPython/LoopAlgorithmToPython.swift.
"""
from loop_to_python_api.helpers import get_bytes_from_json

import ctypes
import os


current_dir = os.path.dirname(os.path.abspath(__file__))
lib_path = os.path.join(current_dir, 'libLoopAlgorithmToPython.dylib')

"""
if platform.system() == 'Darwin':  # macOS
    lib_path = 'path/to/libmylib.dylib'
elif platform.system() == 'Windows':  # Windows
    lib_path = 'path/to/mylib.dll'
else:  # Linux or others
    lib_path = 'path/to/libmylib.so'

"""

swift_lib = ctypes.CDLL(lib_path)


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


def get_prediction_values_and_dates(json_file):
    dates = get_prediction_dates(json_file)
    values = generate_prediction(json_file, len(dates))
    return values, dates


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


def get_glucose_velocity_values_and_dates(json_file):
    # TODO: Add validation of json dates here to be more flexible?

    dates = get_glucose_effect_velocity_dates(json_file)
    values = get_glucose_effect_velocity(json_file, len(dates))
    return values, dates


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


