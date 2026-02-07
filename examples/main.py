import pandas as pd
import loop_to_python_api.api as api


# USING REAL DATA
# file_path = 'examples/EXAMPLE.csv'
# df = pd.read_csv(file_path, parse_dates=['date'], index_col='date', low_memory=False)

# USING MOCK DATA
def get_mock_data():
    # Generate datetime index with 5-minute intervals
    n_rows = 100
    index = pd.date_range(start="2024-02-28 00:00", periods=n_rows, freq="5min")

    # Create DataFrame
    return pd.DataFrame({
        "bolus": [10] + [0.0] * (n_rows - 1),  # First row is 10, rest are 0
        "basal": [1] * n_rows,  # Always 1 (U/hr)
        "CGM": [100] * n_rows,
    }, index=index)


df = get_mock_data()
insulin_type = "novolog"
df = api.add_insulin_on_board_to_df(df, 1, 45, 12, insulin_type=insulin_type)
df = api.add_insulin_counteraction_effect_to_df(df, 1, 45, 12, insulin_type=insulin_type)

print("Dataframe with iob and ice:", df.tail())
