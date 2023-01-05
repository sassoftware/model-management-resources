# Overview of Configuration
This directory contains the instructions to perform the following tasks in the SAS Model Manager container:

* [turn on logging debug for a specific service using sas-admin CLI utility](#turn-on-logging-to-debug-with-the-sas-viya-administration-cli)
* [create container base images for Python 3 and R models with a Python script](base-images/README.md)
* [create a CAS, Git, Azure Machine Learning, or container publishing destination using a Python script or SAS Viya CLI](../configuration/destinations/README.md) 
* [migrate SAS Viya 3.5 Python models to SAS Viya 2020.1 or later](#migrate-sas-viya-35-python-models-to-sas-viya-20201-or-later)
* [administer user group identities](#administer-user-group-identities)


## Turn On Logging to Debug with the SAS Viya Administration CLI
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
With the release of SAS Model Manager 15.3 on SAS Viya 3.5, model containerization for Python and R models is supported. 
You must create a publishing destination and base image before users can publish Python models or R models to a container destination.

* [Creating publishing destinations](../configuration/destinations/README.md)
* [Creating base images](base-images/README.md)

## Migrate SAS Viya 3.5 Python Models to SAS Viya 2020.1 or Later
You can migrate one Python model at a time from SAS Viya 3.5 to SAS Viya 2020.1 or later.

For more information, see the [README](migration/README.md) in the migration directory.

## Administer User Group Identities
The [UserGroupAdmin.ipynb](UserGroupAdmin.ipynb) Jupyter notebook includes examples for how to administer user group identities by submitting API requests using Python code.


## License

This project is licensed under the [Apache 2.0 License](../LICENSE).

