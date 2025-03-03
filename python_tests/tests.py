import json
import pandas as pd
from loop_to_python_api.api import (
    initialize_exception_handlers,
    generate_prediction,
    get_prediction_dates,
    get_prediction_values_and_dates,
    get_dose_recommendations,
    get_glucose_effect_velocity,
    get_glucose_effect_velocity_dates,
    get_glucose_effect_velocity_and_dates,
    get_active_carbs,
    get_active_insulin,
    percent_absorption_at_percent_time,
    piecewise_linear_percent_rate_at_percent_time,
    linear_percent_rate_at_percent_time,
    get_dynamic_carbs_on_board,
)


def get_generate_prediction_input():
    with open('python_tests/test_files/generate_prediction_input.json', 'r') as f:
        return json.load(f)


def get_loop_algorithm_input():
    with open('python_tests/test_files/loop_algorithm_input.json', 'r') as f:
        return json.load(f)


def get_dynamic_carbs_input():
    with open('python_tests/test_files/dynamic_carbs_input.json', 'r') as f:
        return json.load(f)


def test_initialize_exception_handlers():
    result = initialize_exception_handlers()
    assert result is None  # Replace with the expected result


def test_generate_prediction():
    prediction_input = get_generate_prediction_input()
    prediction_values = generate_prediction(prediction_input)
    assert isinstance(prediction_values, list)  # Replace with the expected type or value


def test_get_prediction_dates():
    prediction_input = get_generate_prediction_input()
    prediction_dates = get_prediction_dates(prediction_input)
    assert isinstance(prediction_dates, list)  # Replace with the expected type or value


def test_get_prediction_values_and_dates():
    prediction_input = get_generate_prediction_input()
    values, dates = get_prediction_values_and_dates(prediction_input)

    # Assertions to check the types
    assert isinstance(values, list), "The prediction values should be a list."
    assert isinstance(dates, list), "The prediction dates should be a list."
    assert all(isinstance(value, (int, float)) for value in values), "All prediction values should be integers or floats."
    assert all(isinstance(date, str) for date in dates), "All prediction dates should be strings."


def test_get_dose_recommendations():
    loop_algorithm_input = get_loop_algorithm_input()
    dose_recommendations = get_dose_recommendations(loop_algorithm_input)
    assert isinstance(dose_recommendations, dict)  # Replace with the expected type or value


def test_get_glucose_effect_velocity():
    prediction_input = get_generate_prediction_input()
    glucose_effect_velocity = get_glucose_effect_velocity(prediction_input)
    assert isinstance(glucose_effect_velocity, list)  # Replace with the expected type or value


def test_get_glucose_effect_velocity_dates():
    prediction_input = get_generate_prediction_input()
    glucose_effect_velocity_dates = get_glucose_effect_velocity_dates(prediction_input)
    assert isinstance(glucose_effect_velocity_dates, list)  # Replace with the expected type or value


def test_get_glucose_effect_velocity_values_and_dates():
    loop_algorithm_input = get_loop_algorithm_input()
    values, dates = get_glucose_effect_velocity_and_dates(loop_algorithm_input)

    # Assertions to check the types
    assert isinstance(values, list), "The prediction values should be a list."
    assert isinstance(dates, list), "The prediction dates should be a list."
    assert all(isinstance(value, (int, float)) for value in values), "All prediction values should be integers or floats."


def test_get_active_carbs():
    loop_algorithm_input = get_loop_algorithm_input()
    active_carbs = get_active_carbs(loop_algorithm_input)
    assert isinstance(active_carbs, float)  # Replace with the expected type or value


def test_get_active_insulin():
    loop_algorithm_input = get_loop_algorithm_input()
    active_insulin = get_active_insulin(loop_algorithm_input)
    assert isinstance(active_insulin, float)  # Replace with the expected type or value


def test_percent_absorption_at_percent_time():
    result = percent_absorption_at_percent_time(0.2)
    assert isinstance(result, float)  # Replace with the expected type or value


def test_piecewise_linear_percent_rate_at_percent_time():
    result = piecewise_linear_percent_rate_at_percent_time(0.2)
    assert isinstance(result, float)  # Replace with the expected type or value


def test_linear_percent_rate_at_percent_time():
    result = linear_percent_rate_at_percent_time(0.2)
    assert isinstance(result, float)  # Replace with the expected type or value


def test_get_dynamic_carbs_on_board():
    dynamic_carbs_input = get_dynamic_carbs_input()
    dynamic_carbs_on_board = get_dynamic_carbs_on_board(dynamic_carbs_input)
    assert isinstance(dynamic_carbs_on_board, float)  # Replace with the expected type or value


