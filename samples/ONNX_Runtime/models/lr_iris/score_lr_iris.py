
from pathlib import Path

import requests

import settings

def score_model(SEPALLENGTH, SEPALWIDTH, PETALLENGTH, PETALWIDTH):
    "Output: EM_CLASSIFICATION"

    model_path = str(Path(settings.pickle_path) / "lr_iris.pickle")
    input_data = [SEPALLENGTH, SEPALWIDTH, PETALLENGTH, PETALWIDTH]
    data = {"model": model_path, "data": input_data}

    url = "http://onnx-service.base.svc.cluster.local:8080/predict"
    response = requests.post(url, json=data)

    return str(response.json()["output"][0])
