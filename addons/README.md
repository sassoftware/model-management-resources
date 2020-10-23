# Overview of Addons
This directory contains the instructions to perform the following tasks in the SAS Open Model Manager or SAS Model Manager container:

* install extra Python packages into the SAS Open Model Manager container
* change PyMAS configuration in the container
* turn on logging debug for a specific service using sas-admin CLI utility
* create container base images for Python 3 and R models with a Python script
* create a CAS, Amazon Web Services (AWS), Azure, or Private Docker publishing destination using a Python script or Jupyter notebook
* administer user group identities
* generate and zip Python pickle model files

## Install Extra Python Packages for SAS Open Model Manager Container
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
In order to use a PyMAS Package. You must configure the Compute server and CAS server. 

For more information, see the following documentation: 

* SAS Viya 3.5: [SAS Micro Analytic Service 5.5: Programming and Administration Guide](https://documentation.sas.com/?docsetId=masag&docsetTarget=titlepage.htm&docsetVersion=5.5).
* SAS Viya 4: [SAS Micro Analytic Service: Programming and Administration Guide](http://documentation.sas.com/?cdcId=mascdc&cdcVersion=default&docsetId=masag&docsetTarget=titlepage.htm)

Here is an example of configuring the PyMAS package for SAS Viya 3.5:

1. Log in to the container instance as the sas user.
   ```
   docker exec -it openmodelmanager bash
   ```

2. Create and edit the following files, if they do not already exist:

   * /opt/sas/viya/config/etc/sysconfig/microanalyticservice.conf
   * /opt/sas/viya/config/etc/sysconfig/compsrv/default/sas-compsrv
   * /opt/sas/viya/config/etc/cas/default/cas_usermods.settings

3. Add the following lines in the files:
   ```
   MAS_M2PATH=/opt/sas/viya/home/SASFoundation/misc/embscoreeng/mas2py.py
   export MAS_M2PATH
 
   MAS_PYPATH=/usr/bin/python3
   export MAS_PYPATH
   ```

## Turn on Logging to Debug with the SAS Viya Administration CLI
Occasionally a user might like to get more debugging information from a log file when troubleshooting certain situations. 
The SAS Viya Administration (sas-admin) command-line interface (CLI) can be used to easily set the logging level for specific SAS services in the CLI.
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

* [Creating publishing destinations](./destinations/README.md)
* [Creating base images](./base-images/README.md)


## Administer User Group Identities
The [UserGroupAdmin.ipynb](UserGroupAdmin.ipynb) Jupyter notebook includes examples for how to administer user group identities by submitting API requests using Python code.

## Generate and Zip Python Pickle Model Files
The Python scripts in the picklezip-mm directory are used to pickle the Python model file, generate the fit statistics, lift and ROC JSON files, and then creates an archive model ZIP file. 
The model ZIP file can then be imported into the SAS Open Model Manager.

For more information, see the [README](./picklezip-mm/README.md) in the picklezip-mm directory. 

## License

This project is licensed under the [Apache 2.0 License](../LICENSE).

