import pandas as pd
import loop_to_python_api.api as api

# Read from csv file
# file_path = 'examples/EXAMPLE.csv'
# data = pd.read_csv(file_path, parse_dates=['date'], index_col='date', low_memory=False)

# Generate datetime index with 5-minute intervals
index = pd.date_range(start="2024-02-28 00:00", periods=60, freq="5T")

# Create DataFrame
df = pd.DataFrame({
    "bolus": [10] + [0] * 59,  # First row is 10, rest are 0
    "basal": [1] * 60,           # Always 1
    "CGM": 100 * 60
}, index=index)

insulin_type = "afrezza"
df = api.add_insulin_on_board_to_df(df, 1, 45, 12, insulin_type=insulin_type)
df = api.add_insulin_counteraction_effect_to_df(df, 1, 45, 12, insulin_type=insulin_type)

print("Dataframe with iob and ice:", df)
