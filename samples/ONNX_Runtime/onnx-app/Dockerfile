# Use a base image with your preferred Linux distribution that comes with Python
FROM python:3.10-slim

# Install any additional dependencies required for your application
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git

# Install ONNX Runtime
RUN pip install onnxruntime

# Install Flask for creating a simple API
RUN pip install flask

# Copy the Flask app into the container
RUN mkdir app
COPY onnx_app.py /app

# Set the working directory
WORKDIR /app

# Expose port 8080
EXPOSE 8080

# Set the entrypoint to start the Flask app
ENTRYPOINT ["python", "onnx_app.py"]
