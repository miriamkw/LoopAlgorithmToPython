"""
Helper functions not directly related to the API.
"""
import json
import datetime


def get_bytes_from_json(json_file):
    json_str = json.dumps(json_file)  # Convert JSON data to JSON string
    json_bytes = json_str.encode('utf-8')  # Convert JSON string to bytes
    return json_bytes


def get_json_loop_prediction_input_from_df(data, basal, isf, cr, prediction_start, insulin_type='novolog',
                                           max_basal=4.0, max_bolus=9, recommendation_type='automaticBolus',
                                           suspend_threshold=78, target_lower=101, target_upper=115):
    """
    Convert a glucose and insulin DataFrame into a JSON payload suitable for loop prediction input in several
    functions within `api.py`.

    Args:
        data (pd.DataFrame): DataFrame containing the following columns:
            - 'CGM' (mg/dL)
            - 'bolus' (U)
            - 'basal' (U/hr)
            - 'carbs' (g)
            - 'date' (datetime)
        basal (float): Scheduled basal insulin rate to use in the prediction.
        isf (float): Insulin sensitivity factor (mg/dL per unit insulin).
        cr (float): Carbohydrate ratio (grams per unit insulin).
        prediction_start (datetime or str): Timestamp for the start of the prediction period.
        insulin_type (str): Type of insulin used. Must be one of:
            "novolog", "humalog", "apidra", "fiasp", "lyumjev", "afrezza".
        max_basal (float, optional): Maximum allowable basal rate in closed loop (U/hr). Defaults to 4.0.
        max_bolus (float, optional): Maximum allowable bolus dose (U). Defaults to 9.
        recommendation_type (str, optional): Type of recommendation to generate. Defaults to 'automaticBolus'.
            Must be one of: "automaticBolus", "tempBasal", "manualBolus".
        suspend_threshold (float, optional): Glucose level below which insulin delivery is suspended (mg/dL).
            Defaults to 78.
        target_lower (float, optional): Lower bound of target glucose range (mg/dL). Defaults to 101.
        target_upper (float, optional): Upper bound of target glucose range (mg/dL). Defaults to 115.

    Returns:
        dict: JSON-serializable dictionary structured for loop prediction input,
              including glucose values, insulin information, and metadata.
    """
    validate_insulin_type(insulin_type)
    validate_recommendation_type(recommendation_type)

    def get_dates_and_values(column, data):
        if column in data.columns:
            mask = ~data[column].isna()  # ~ inverts the boolean mask
            dates = data.index[mask].to_list()
            values = data[column][mask].to_list()
            return dates, values
        else:
            return [], []

    data.sort_index(inplace=True)
    bolus_dates, bolus_values = get_dates_and_values('bolus', data)
    basal_dates, basal_values = get_dates_and_values('basal', data)

    insulin_json_list = []
    for date, value in zip(bolus_dates, bolus_values):
        entry = {
            "startDate": date.strftime('%Y-%m-%dT%H:%M:%SZ'),
            "endDate": (date + datetime.timedelta(minutes=5)).strftime('%Y-%m-%dT%H:%M:%SZ'),
            "type": 'bolus',
            "volume": value,
            "insulinType": insulin_type,
        }
        insulin_json_list.append(entry)

    for date, value in zip(basal_dates, basal_values):
        entry = {
            "startDate": date.strftime('%Y-%m-%dT%H:%M:%SZ'),
            "endDate": (date + datetime.timedelta(minutes=5)).strftime('%Y-%m-%dT%H:%M:%SZ'),
            "type": 'basal',
            "volume": value / 12,  # Converting from U/hr to delivered units in 5 minutes
            "insulinType": insulin_type,
        }
        insulin_json_list.append(entry)
    insulin_json_list.sort(key=lambda x: x['startDate'])

    bg_dates, bg_values = get_dates_and_values('CGM', data)
    bg_json_list = []
    for date, value in zip(bg_dates, bg_values):
        entry = {
            "date": date.strftime('%Y-%m-%dT%H:%M:%SZ'),
            "value": value
        }
        bg_json_list.append(entry)
    bg_json_list.sort(key=lambda x: x['date'])

    carbs_dates, carbs_values = get_dates_and_values('carbs', data)
    carbs_json_list = []
    for date, value in zip(carbs_dates, carbs_values):
        entry = {
            "date": date.strftime('%Y-%m-%dT%H:%M:%SZ'),
            "grams": value,
            "absorptionTime": 10800,
        }
        carbs_json_list.append(entry)
    carbs_json_list.sort(key=lambda x: x['date'])

    # It is important that the settings dates wrap the first and last glucose data to avoid a code crash
    start_date_settings = data.index[0] - datetime.timedelta(hours=24)
    end_date_settings = data.index[-1] + datetime.timedelta(hours=24)

    start_date_str = start_date_settings.strftime('%Y-%m-%dT%H:%M:%SZ')
    end_date_str = end_date_settings.strftime('%Y-%m-%dT%H:%M:%SZ')

    basal = [{
        "startDate": start_date_str,
        "endDate": end_date_str,
        "value": basal
    }]

    isf = [{
        "startDate": start_date_str,
        "endDate": end_date_str,
        "value": isf
    }]

    cr = [{
        "startDate": start_date_str,
        "endDate": end_date_str,
        "value": cr
    }]

    json_data = {
        "carbEntries": carbs_json_list,
        "doses": insulin_json_list,
        "glucoseHistory": bg_json_list,
        "basal": basal,
        "carbRatio": cr,
        "sensitivity": isf,
    }
    # Adding other mandatory default values for recommendations
    json_data['maxBasalRate'] = max_basal
    json_data['maxBolus'] = max_bolus
    json_data['predictionStart'] = prediction_start.strftime('%Y-%m-%dT%H:%M:%SZ')
    json_data['recommendationInsulinType'] = insulin_type
    json_data['recommendationType'] = recommendation_type
    json_data['suspendThreshold'] = suspend_threshold
    json_data['target'] = [{
            "endDate": data.index[-1].strftime('%Y-%m-%dT%H:%M:%SZ'),
            "lowerBound": target_lower,
            "startDate": data.index[0].strftime('%Y-%m-%dT%H:%M:%SZ'),
            "upperBound": target_upper
    }]
    return json_data


def validate_insulin_type(insulin_type):
    insulin_options = ["novolog", 'humalog', "apidra", "fiasp", "lyumjev", "afrezza"]
    if insulin_type not in insulin_options:
        raise ValueError(f"Invalid insulin type: '{insulin_type}'. Must be one of {insulin_options}.")


def validate_recommendation_type(recommendation_type):
    recommendation_options = ["automaticBolus", "tempBasal", "manualBolus"]
    if recommendation_type not in recommendation_options:
        raise ValueError(f"Invalid insulin type: '{recommendation_type}'. Must be one of {recommendation_options}.")

