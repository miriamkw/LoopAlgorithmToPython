"""
This file provides an API for calling the functions in the dynamic library. These functions are c-embeddings
for swift functions, found in Sources/LoopAlgorithmToPython/LoopAlgorithmToPython.swift.
"""
import numpy as np
import pandas as pd

import loop_to_python_api.helpers as helpers
import ctypes
import os
import ast

# swift_lib = ctypes.CDLL('python_api/libLoopAlgorithmToPython.dylib')

current_dir = os.path.dirname(os.path.abspath(__file__))
lib_path = os.path.join(current_dir, 'libLoopAlgorithmToPython.dylib')
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
    json_bytes = helpers.get_bytes_from_json(json_file)

    swift_lib.generatePrediction.argtypes = [ctypes.c_char_p]
    swift_lib.generatePrediction.restype = ctypes.POINTER(ctypes.c_double)

    result = swift_lib.generatePrediction(json_bytes)
    return [result[i] for i in range(len)]


def get_prediction_dates(json_file):
    json_bytes = helpers.get_bytes_from_json(json_file)

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


def get_dose_recommendations(json_file):
    json_bytes = helpers.get_bytes_from_json(json_file)

    swift_lib.getDoseRecommendations.argtypes = [ctypes.c_char_p]
    swift_lib.getDoseRecommendations.restype = ctypes.c_char_p

    result = swift_lib.getDoseRecommendations(json_bytes).decode('utf-8')
    result = ast.literal_eval(result)
    return result


# "Glucose effect velocity" is equivalent to insulin counteraction effect (ICE)
def get_glucose_effect_velocity(json_file, len=72):
    json_bytes = helpers.get_bytes_from_json(json_file)

    swift_lib.getGlucoseEffectVelocity.argtypes = [ctypes.c_char_p]
    swift_lib.getGlucoseEffectVelocity.restype = ctypes.POINTER(ctypes.c_double)

    result = swift_lib.getGlucoseEffectVelocity(json_bytes)
    return [result[i] for i in range(len)]


def get_glucose_effect_velocity_dates(json_file):
    json_bytes = helpers.get_bytes_from_json(json_file)

    swift_lib.getGlucoseEffectVelocityDates.argtypes = [ctypes.c_char_p]
    swift_lib.getGlucoseEffectVelocityDates.restype = ctypes.c_char_p

    result = swift_lib.getGlucoseEffectVelocityDates(json_bytes).decode('utf-8')
    date_list = result.split(',')[:-1]
    #date_list = [pd.to_datetime(date) for date in date_list]

    return date_list


def get_glucose_effect_velocity_and_dates(json_file):
    json_bytes = helpers.get_bytes_from_json(json_file)

    swift_lib.getGlucoseEffectVelocityAndDates.argtypes = [ctypes.c_char_p]
    swift_lib.getGlucoseEffectVelocityAndDates.restype = ctypes.c_char_p

    result = swift_lib.getGlucoseEffectVelocityAndDates(json_bytes).decode('utf-8')

    values = []
    dates = []
    # Parse the string that contains both dates and values
    for item in result.split():
        date_str, float_str = item.split(',')
        dates.append(pd.to_datetime(date_str))
        values.append(float(float_str))

    return values, dates


def get_active_carbs(json_file):
    json_bytes = helpers.get_bytes_from_json(json_file)

    swift_lib.getActiveCarbs.argtypes = [ctypes.c_char_p]
    swift_lib.getActiveCarbs.restype = ctypes.c_double

    return swift_lib.getActiveCarbs(json_bytes)


def get_active_insulin(json_file):
    json_bytes = helpers.get_bytes_from_json(json_file)

    swift_lib.getActiveInsulin.argtypes = [ctypes.c_char_p]
    swift_lib.getActiveInsulin.restype = ctypes.c_double

    return swift_lib.getActiveInsulin(json_bytes)


def add_insulin_counteraction_effect_to_df(df, basal, isf, cr, insulin_type='novolog', batch_size=300, overlap=72):
    """
    Takes a dataframe with at least the columns CGM, bolus, and basal.
    Important note: this function assumes you only give data for a single subject at a time.
    # TODO: The therapy settings should be columns in the dataframe so we can support schedules.

    :param df: Dataframe with at least a "basal" and a "bolus" column, and a datetime index.
    :param basal: Basal rate
    :param isf: Insulin sensitivity factor
    :param cr: Carbohydrate ratio (will not impact the results)
    :param insulin_type: Which insulin profile to use to compute the insulin on board
    :param batch_size: How many samples to include in each batch operation. Might be reduced / increased, but default is optimized for general settings.
    :param overlap: How many time steps to use for computing insulin activity. Can be reduced for some types of insulin, which will improve performance.
    :return: The input df with columns for insulin on board and insulin counteraction effects. Unit of ICE is mg/dL*s
    """
    data = df[['basal', 'bolus', 'CGM']].copy()  # Extract only necessary data to improve performance
    data.loc[:, 'bolus'] = data['bolus'].replace(0.0, np.nan)
    df.loc[:, "ice"] = np.nan

    step_size = batch_size - overlap  # Determine step size based on overlap
    num_rows = len(df)

    for start in range(0, num_rows, step_size):
        end = min(start + batch_size, num_rows)
        batch_data = data.iloc[start:end]
        json_data = helpers.get_json_loop_prediction_input_from_df(batch_data, basal, isf, cr, batch_data.index[-1],
                                                                   insulin_type)

        ice_values, dates = get_glucose_effect_velocity_and_dates(json_file=json_data)
        dates = [date.tz_localize(None) for date in dates]  # Align to UTC if needed

        # We ignore the first overlap samples for each batch, because we need the insulin data to compute correct values
        df.loc[dates[overlap:], "ice"] = ice_values[overlap:]
    return df


def add_insulin_on_board_to_df(df, basal, isf, cr, insulin_type='novolog', lookback=72):
    """
    Adding insulin on board to a dataframe to each row, by using data from the previous rows given by lookback.
    IMPORTANT NOTE: This function does not handle separate subjects within a single dataframe. A subject's data should
    be passed individually.

    :param df: Dataframe with at least a "basal" and a "bolus" column, and a datetime index.
    :param basal: Basal rate
    :param isf: Insulin sensitivity factor
    :param cr: Carbohydrate ratio (will not impact the results)
    :param insulin_type: Which insulin profile to use to compute the insulin on board
    :param lookback: Lookback used to compute each iob value. Increasing lookback will lower performance, but will be
    necessary for insulin types that are long-lasting, or for high datetime frequencies. The default of 72 is based on
    6 hours duration of 5-minute intervals.
    :return: The original dataframe with a new column "iob"
    """
    data = df[['basal', 'bolus']].copy()  # Extract only necessary data to improve performance
    data.loc[:, 'bolus'] = data['bolus'].replace(0.0, np.nan)

    iobs = []
    for i, date in enumerate(data.index[1:]):
        start_index = max(0, i - lookback + 1)
        json_data = helpers.get_json_loop_prediction_input_from_df(data.iloc[start_index:i+1], basal, isf, cr,
                                                                   data.index[i+1], insulin_type=insulin_type)
        iob = get_active_insulin(json_data)
        iobs += [iob]

    df.loc[:, "iob"] = np.nan
    df.loc[df.index[1:], "iob"] = iobs
    return df


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
    json_bytes = helpers.get_bytes_from_json(json_file)

    swift_lib.getDynamicCarbsOnBoard.argtypes = [ctypes.c_char_p]
    swift_lib.getDynamicCarbsOnBoard.restype = ctypes.c_double

    return swift_lib.getDynamicCarbsOnBoard(json_bytes)


