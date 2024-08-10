import pytest
import json
from loop_to_python_api.api import generate_prediction


@pytest.fixture
def generate_prediction_input():
    with open('python_tests/test_files/generate_prediction_input.json', 'r') as f:
        return json.load(f)


def test_generate_prediction():
    prediction_input = generate_prediction_input()
    prediction_values = generate_prediction(prediction_input)
    print(prediction_values)
    assert prediction_values == []




