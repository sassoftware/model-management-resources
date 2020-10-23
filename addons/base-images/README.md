# Creating Base Images

Here are the types of model base images that are currently supported:

* Python 3 base image that is used for scoring Python 3 models.
* R base image that is used for scoring R models.

Before running the scripts, verify the following configurations:
* Python 3 is installed with the requests package on the machine where you are going to run the scripts.
* Modify the Python script and specify the proper user name, password, and destination name. 

#### Create a Python 3 Base Image
In this script we use synchronous publish mode to generate Python base images. Please wait until it returns a result.
```
python create_python3_baseImage.py
```
#### Create an R Base Image
It might take longer to create an R base image, so in this script we use asynchronous publish.
```
python create_r_baseImage.py
```
