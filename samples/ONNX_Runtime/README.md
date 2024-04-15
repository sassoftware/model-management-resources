# Scoring ONNX Models with CAS in SAS Viya 4

This example aims to show how to score open-source models that use more complicated frameworks, such as ONNX models. Due to the language invariant nature of ONNX models, the model within SAS Model Manager can use any supported score code type that can send a REST API call. This example uses a Python-centric source.

Here are the contents of this example:
- [k8-manifest](#k8-manifest-directory): This directory contains the YAML files used within the Kubernetes cluster to stand up the new service and stateful set.
- [models](#models-directory): This directory contains an example notebook that builds three different ONNX models and saves them to the directory.
- [onnx-app](#onnx-app-directory): This directory contains the basic web application code and Dockerfile for building the container that executes the ONNX runtime within SAS Viya.

_**Note:** Your thoughts, questions, and comments are welcome. 
Leave feedback using the **Issues** tab of the [Model Management Resources](https://github.com/sassoftware/model-management-resources) GitHub repository._


## k8-manifest Directory

Two YAML files create the service and stateful set inside the SAS Viya Kubernetes cluster. The main components that must be adjusted from the example are the namespace and the image registry location. Please note that the use of the Persistent Volume Claim that contains the model assets used in scoring **must** be in the same namespace as the service and stateful set.

Access your Kubernetes cluster and run the following command to spin up the Service and pods associated with the StatefulSet:

`kubectl apply -f onnx-service.yaml -f onnx-stateful.yaml`

## models Directory

The build_onnx_model.ipynb is a Jupyter notebook that creates three different models (regression, binary classification, and multi-classification) from scikit-learn data sets. The notebook walks through the process of creating the models, converting them to an ONNX format, and then uploading the models to SAS Model Manager.

The example models are also included within subdirectories.

At this point, any user with access to the models within SAS Model Manager should be able to run a score test and successfully score an ONNX model in CAS using the custom service created on the SAS Viya Kubernetes cluster.

## onnx-app Directory

The onnx_app.py file is a basic flask app with a single endpoint, `/predict`, which is used to generate predictions from a user-specified ONNX model. The `Dockerfile` can be used to spin up a container with the flask app from onnx_app.py. With both Dockerfile and the onnx_app.py file in the same directory, you can run the following terminal call:

`docker build -t <CONTAINER-NAME> .`

This command creates the Docker image that is used by the YAML files within Kubernetes. Note that you must push the created image to a registry that SAS Viya is able to access. Here is an example:

`docker tag <CONTAINER-NAME> registry.sas.viya.com/<CONTAINER-NAME>`

`docker push registry.sas.viya.com/<CONTAINER_NAME>`

## License

This project is licensed under the [Apache 2.0 License](../../LICENSE).