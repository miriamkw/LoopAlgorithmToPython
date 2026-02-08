import json
import platform
import pytest
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
    get_loop_recommendations,
    percent_absorption_at_percent_time,
    piecewise_linear_percent_rate_at_percent_time,
    linear_percent_rate_at_percent_time,
    get_dynamic_carbs_on_board,
    insulin_percent_effect_remaining,
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
    assert result is None


def test_generate_prediction():
    prediction_input = get_generate_prediction_input()
    prediction_values = generate_prediction(prediction_input)
    assert isinstance(prediction_values, list)


def test_get_prediction_dates():
    prediction_input = get_generate_prediction_input()
    prediction_dates = get_prediction_dates(prediction_input)
    assert isinstance(prediction_dates, list)


def test_get_prediction_values_and_dates():
    prediction_input = get_generate_prediction_input()
    values, dates = get_prediction_values_and_dates(prediction_input)

    # Assertions to check the types
    assert isinstance(values, list), "The prediction values should be a list."
    assert isinstance(dates, list), "The prediction dates should be a list."
    assert all(isinstance(value, (int, float)) for value in values), "All prediction values should be integers or floats."
    assert all(isinstance(date, str) for date in dates), "All prediction dates should be strings."


@pytest.mark.skipif(platform.system() == "Windows", reason="Windows compatibility issue - test disabled for Windows builds")
def test_get_dose_recommendations():
    loop_algorithm_input = get_loop_algorithm_input()
    dose_recommendations = get_dose_recommendations(loop_algorithm_input)
    assert isinstance(dose_recommendations, dict)


def test_get_glucose_effect_velocity():
    prediction_input = get_generate_prediction_input()
    glucose_effect_velocity = get_glucose_effect_velocity(prediction_input)
    assert isinstance(glucose_effect_velocity, list)


def test_get_glucose_effect_velocity_dates():
    prediction_input = get_generate_prediction_input()
    glucose_effect_velocity_dates = get_glucose_effect_velocity_dates(prediction_input)
    assert isinstance(glucose_effect_velocity_dates, list)


@pytest.mark.skipif(platform.system() == "Windows", reason="Windows compatibility issue - test disabled for Windows builds")
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
    assert isinstance(active_carbs, float)


def test_get_active_insulin():
    loop_algorithm_input = get_loop_algorithm_input()
    active_insulin = get_active_insulin(loop_algorithm_input)
    assert isinstance(active_insulin, float)


def test_percent_absorption_at_percent_time():
    result = percent_absorption_at_percent_time(0.2)
    assert isinstance(result, float)


def test_piecewise_linear_percent_rate_at_percent_time():
    result = piecewise_linear_percent_rate_at_percent_time(0.2)
    assert isinstance(result, float)


def test_linear_percent_rate_at_percent_time():
    result = linear_percent_rate_at_percent_time(0.2)
    assert isinstance(result, float)


@pytest.mark.skip(reason="Known unit conversion issue: 'g is not compatible with mg/dL·s' - see README.md Known Issues section")
def test_get_dynamic_carbs_on_board():
    dynamic_carbs_input = get_dynamic_carbs_input()
    dynamic_carbs_on_board = get_dynamic_carbs_on_board(dynamic_carbs_input)
    assert isinstance(dynamic_carbs_on_board, float)


def test_get_loop_recommendations():
    loop_algorithm_input = get_loop_algorithm_input()
    loop_recommendations = get_loop_recommendations(loop_algorithm_input)
    assert isinstance(loop_recommendations, str)


@pytest.mark.skipif(platform.system() == "Windows", reason="Windows compatibility issue - test disabled for Windows builds")
def test_insulin_percent_effect_remaining():
    # Test with typical rapid-acting insulin parameters
    result = insulin_percent_effect_remaining(
        minutes=60,           # 60 minutes after injection
        action_duration=360,  # 6 hours total duration  
        peak_activity_time=75, # Peak at 75 minutes
        delay=10             # 10 minute delay
    )
    
    # Basic assertions
    assert isinstance(result, float), "Result should be a float"
    assert 0.0 <= result <= 1.0, f"Result should be between 0.0 and 1.0, got {result}"
    
    # Test edge cases
    # At time 0 (before delay), should have close to 100% effect remaining
    result_start = insulin_percent_effect_remaining(0, 360, 75, 10)
    assert result_start > 0.9, f"At start, should have >90% remaining, got {result_start}"
    
    # At very end of action duration, should have very little effect remaining
    result_end = insulin_percent_effect_remaining(360, 360, 75, 10)
    assert result_end < 0.1, f"At end, should have <10% remaining, got {result_end}"
    
    # At peak time, should have less than 100% but more than end
    result_peak = insulin_percent_effect_remaining(75, 360, 75, 10)
    assert result_end < result_peak < result_start, "Effect should decrease over time"


