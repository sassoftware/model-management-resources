# Creating Base Images

_**Note:** You only need to create base images using these Python scripts for SAS Model Manager on SAS Viya 2020.1 - 2021.1.2 and SAS Model Manager 15.3 on SAS Viya 3.5. 
As of the SAS Viya 2021.1.3 stable release of SAS Model Manager, the model base images are automatically created when publishing open-source models to container destinations. 
For more information, see [Container Base Images for Scoring Models](https://documentation.sas.com/doc/en/mdlmgrcdc/v_009/mdlmgrag/n0x0rvwqs9lvpun16sfdqoff4tsk.htm#p0hmbi6svov1lun1wx6ibq8a6u98) in SAS Model Manager: Administrator's Guide._

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
