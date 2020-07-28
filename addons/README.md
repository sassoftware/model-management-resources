# Overview

This directory contains the instructions to perform the following tasks in the SAS Open Model Manager container:

* install extra Python packages into the SAS Open Model Manager container
* change PyMAS configuration in the container
* turn on logging debug for a specific service using sas-admin CLI utility
* create container base images for Python 3 and R models with a Python script
* create a CAS, Amazon Web Services (AWS), or Private Docker publishing destination using a Python script
* administer user group identities
* generate and zip Python pickle model files

## Extra Python Packages
When a container instance is running, Python 3 has been installed using the sas user. A user can also install extra Python packages, if needed.

Log in to the container instance as the sas user:
```
docker exec -it openmodelmanager bash
```
Use pip3 to install Python packages, such as:
```
pip3 install --user numpy
pip3 install --user h2o
```

## PyMAS Configuration
In order to use a PyMAS Package. You must configure the Compute Server and CAS Server. 
For more information, see [SAS Micro Analytic Service 5.4: Programming and Administration Guide](https://documentation.sas.com/?docsetId=masag&docsetTarget=titlepage.htm&docsetVersion=5.4&locale=en).

Log in to the container instance as the sas user.
```
docker exec -it openmodelmanager bash
```

Create and edit the following files, if they do not already exist:

* /opt/sas/viya/config/etc/sysconfig/microanalyticservice.conf
* /opt/sas/viya/config/etc/sysconfig/compsrv/default/sas-compsrv
* /opt/sas/viya/config/etc/cas/default/cas_usermods.settings

Add the following lines in the files:
```
MAS_M2PATH=/opt/sas/viya/home/SASFoundation/misc/embscoreeng/mas2py.py
export MAS_M2PATH
 
MAS_PYPATH=/usr/bin/python3
export MAS_PYPATH
```

## Turn on Logging to Debug with the sas-admin CLI
Occasionally a user might like to get more debugging information from a log file when troubleshooting certain situations. 
The SAS Administration (sas-admin) Command Line Interface (CLI) can be used to easily set the logging level for specific SAS services in the CLI.
Users can download the sas-admin CLI from the [SAS Support Downloads site](https://support.sas.com/downloads/package.htm?pid=2133).

To turn on the DEBUG level for the Model Publish API service:

* Download and extract the sas-admin CLI.
* Create a JSON file (such as modelpublish_debug.json) in the same directory.
```
{
    "name": "modelpublish logging level",
    "items": [{
        "metadata": {
            "mediaType": "application/vnd.sas.configuration.config.logging.level+json;version=1",
             "services": ["modelPublish", "modelRepository"]
        },
        "name": "com.sas.modelmanager",
        "level": "DEBUG"
    }]
}
``` 
* Get authorization token with your user name and password.
```
./sas-admin prof set-endpoint http://localhost:8080
./sas-admin auth login -u <username> -p <password>
```
* Create configuration settings for logging.
```
./sas-admin plugins enable-default-repo
./sas-admin plugins install --repo SAS configuration
./sas-admin configuration configurations create --file modelpublish_debug.json
```

## Model Containerization
With the release of SAS Open Model Manager 1.2 and SAS Model Manager 15.3 on SAS Viya 3.5, model containerization for Python and R models is supported. 
You must create a publishing destination and base image before users can publish Python models or R models to a container destination.


### Create Publishing Destinations
You can use the example Python scripts to create new publishing destinations for the following destination types: CAS, Amazon Web Services (AWS), and Private Docker.

Here are the prerequisites for creating a new publishing destination:

* Make sure that you have Python 3 with the requests package installed on the machine where you are going to run the scripts._

Here is an example of using yum to install Python 3 on a machine:
```
sudo yum install -y python3
sudo pip3 install requests
```

* If your destination type is AWS, you must create a credential domain in SAS Credentials service and store the AWS access key information in the credentials. Please modify the host URL (viya_host and port), SAS account, and AWS access key information in the script, and then enter the domain name in the create_aws_destination.py file.
```
python create_aws_credential_domain.py
```

* Make sure that you modify the host URL (viya_host and port), SAS account, Domain name, or private docker information in the script before you run them.

* If Python 3 executable file name is 'python3', then update the following commands to use 'python3', instead of 'python'.

```
python create_cas_destination.py
python create_aws_destination.py
python create_privatedocker_destination.py
```


### Create Base Images
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

## Administer User Group Identities
The UserGroupAdmin.ipynb Jupyter notebook includes examples for how to administer user group identities by submitting API requests using Python code.

## Generate and Zip Python Pickle Model Files
The Python scripts in the picklezip-mm directory are used to pickle the Python model file, generate the fit statistics, lift and ROC JSON files, and then creates an archive model ZIP file. 
The model ZIP file can then be imported into the SAS Open Model Manager.

For more information, see the [README](./picklezip-mm/README.md) in the picklezip-mm directory. 

## License

This project is licensed under the [Apache 2.0 License](../LICENSE).

