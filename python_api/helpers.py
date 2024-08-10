"""
Helper functions not directly related to the API.
"""
import json


def get_bytes_from_json(json_file):
    json_str = json.dumps(json_file)  # Convert JSON data to JSON string
    json_bytes = json_str.encode('utf-8')  # Convert JSON string to bytes
    return json_bytes

