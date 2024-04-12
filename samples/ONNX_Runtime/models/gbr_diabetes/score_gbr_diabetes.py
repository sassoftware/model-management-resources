
from pathlib import Path

import requests

import settings

def score_model(AGE, SEX, BMI, BP, S1, S2, S3, S4, S5, S6):
    "Output: EM_CLASSIFICATION"

    model_path = str(Path(settings.pickle_path) / "gbr_diabetes.pickle")
    input_data = [AGE, SEX, BMI, BP, S1, S2, S3, S4, S5, S6]
    data = {"model": model_path, "data": input_data}

    url = "http://onnx-service.base.svc.cluster.local:8080/predict"
    response = requests.post(url, json=data)

    return str(response.json()["output"][0])
