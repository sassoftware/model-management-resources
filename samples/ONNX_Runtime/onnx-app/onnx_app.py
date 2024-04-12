# ONNX runtime can be handled via Python or installed from source into the container
import onnxruntime as ort
# Use numpy to handle json data conversions
import numpy as np
# Use flask for the web application framework
from flask import Flask, request, jsonify

# Initialize the web application based on the name of the file
app = Flask(__name__)

# Initialize a model session object to differentiate from inference sessions
model_sessions = {}


def get_model_session(model_path):
    # Check if the model has been loaded previously
    if model_path not in model_sessions:
        # Load model into ORT session and keep for later reference
        model_sessions[model_path] = ort.InferenceSession(model_path)
    return model_sessions[model_path]


# Create a predict endpoint that accepts JSON data from a normal REST call
@app.route('/predict', methods=['POST'])
def predict():
    # Load model from the SAS Viya PVC containing the model assets
    model_path = request.json['model']
    session = get_model_session(model_path)

    # Get the input data and then the model label and name
    input_data = np.array([request.json['data']], np.float32)
    input_name = session.get_inputs()[0].name
    label_name = session.get_outputs()[0].name

    # Perform an inference via the session previously generated with the ONNX model
    output = session.run([label_name], {input_name: input_data})[0]

    # Return the ONNX model's output to the sender of the REST call
    return jsonify({"output": output.tolist()})


# For a simple example web application, spin up the flask server to localhost and a specified port
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
