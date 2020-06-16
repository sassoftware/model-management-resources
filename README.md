# Open Model Manager Resources
This repository contains the start-up script for SAS Open Model Manager, as well as helper scripts for administration and customization. In addition there are sample models and data, and examples of using Jupyter notebooks to submit API requests for common tasks. 

For more information about deploying the container, see [SAS Open Model Manager 1.2 for Containers: Deployment Guide](http://documentation.sas.com/?docsetId=dplymdlmgmt0phy0dkr&docsetTarget=titlepage.htm&docsetVersion=1.2&locale=en).

## Overview
SAS Open Model Manager is a standalone version of SAS Model Manager that is meant for data analysts using open-source modeling languages such as Python and R. SAS Open Model Manager is a new tool to make it easy for open-source modelers to operationalize their models. In a single Web application you can manage your full model life cycle: development, testing, deployment, validation, and monitoring.
The content on this GitHub repository is available for users of SAS Open Model Manager and SAS Model Manager. It provides scripts and sample code that can make it easier to use SAS Open Model Manager. It also serves as a place where the open source community of users can share ideas, code, and models.

For more information about SAS Open Model Manager, see the following resources:

* [Demo videos](#demo-videos)
* [Help Center documentation](https://documentation.sas.com/?cdcId=openmmcdc&cdcVersion=1.2&docsetId=openmmug&docsetTarget=titlepage.htm&locale=en)

## Start Script
The run_docker_container script in the [runOpenMM](runOpenMM/) directory launches SAS Open Model Manager.

## Addons
The [addons](addons/) directory contains how-to information for the following tasks:

* install extra Python packages into the SAS Open Model Manager container
* change the PyMAS configuration in the container
* turn on debugging for a specific service using the sas-admin CLI
* create a CAS, Amazon Web Services (AWS), or Private Docker publishing destination using a Python script
* create container base images for Python 3 and R models using a Python script

## Demo Videos
How-To Tutorial videos available on the [SAS video portal](https://video.sas.com/detail/videos/sas-open-model-manager):

* [Create a SAS Open Model Manager project and import a Python model](http://players.brightcove.net/1872491364001/default_default/index.html?videoId=6160664893001)
* [Importing R and PMML format models](http://players.brightcove.net/1872491364001/default_default/index.html?videoId=6160666070001)
* [Scoring, publishing and comparing models](http://players.brightcove.net/1872491364001/default_default/index.html?videoId=6160664319001)
* [Performance reporting](http://players.brightcove.net/1872491364001/default_default/index.html?videoId=6160664560001)

## Samples
The [samples](samples/) directory contains sample data and models for Python and R programming language models.  

## Examples
The [examples](examples/) directory contains examples of Jupyter notebooks and Python code that can be used to perform SAS Open Model Manager tasks.

## Contributing
We welcome your contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit contributions to this project.

## License
This project is licensed under the [Apache 2.0 License](LICENSE).

## Additional Resources
* [REST API documentation](https://developer.sas.com/apis/rest/DecisionManagement/)
* [REST API Examples](https://github.com/sassoftware/devsascom-rest-api-samples/tree/master/DecisionManagement)

