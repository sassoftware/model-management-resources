# Model Management Resources for Open-Source Models
This repository contains resources that can be used for administration and customizations that help with managing open-source models. In addition, there are sample models and data, and examples of using Jupyter notebooks to submit API requests for common tasks for managing models using SAS Model Manager or SAS Open Model Manager.

## Overview
SAS Open Model Manager is a standalone version of SAS Model Manager that is meant for data analysts using open-source modeling languages such as Python and R. SAS Open Model Manager is a new tool to make it easy for open-source modelers to operationalize their models. In a single Web application you can manage your full model life cycle: development, testing, deployment, validation, and monitoring.
The content on this GitHub repository is available for users of SAS Open Model Manager and SAS Model Manager on SAS Viya. It provides scripts and sample code that can make it easier to perform model management tasks. It also serves as a place where the open source community of users can share ideas, code, and models.

_**Note:** Some capabilities that are used in the scripts and sample code are not supported by SAS Model Manager 15.3 or earlier versions._

For more information about model management, see the following resources:

* [Demo videos](#demo-videos)
* [Examples](#examples)
* [SAS Model Manager documentation](https://support.sas.com/en/software/model-manager-support.html#documentation)
* [SAS Open Model Manager documentation](https://support.sas.com/en/software/model-manager-support.html#documentation)
* [SAS Model Manager command-line interfaces (CLIs)](#sas-model-manager-clis)

## Demo Videos
How-To Tutorial videos available on the [SAS video portal](https://video.sas.com/detail/videos/sas-open-model-manager):

* [Create a SAS Open Model Manager project and import a Python model](http://players.brightcove.net/1872491364001/default_default/index.html?videoId=6160664893001)
* [Importing R and PMML format models](http://players.brightcove.net/1872491364001/default_default/index.html?videoId=6160666070001)
* [Scoring, publishing and comparing models](http://players.brightcove.net/1872491364001/default_default/index.html?videoId=6160664319001)
* [Performance reporting](http://players.brightcove.net/1872491364001/default_default/index.html?videoId=6160664560001)

For how-to tutorial videos about using the PZMM Python package or module to register a Python model, see [PZMM Module Demos](https://github.com/sassoftware/python-sasctl/blob/master/src/sasctl/pzmm/README.md#demos) in the sasctl GitHub Repository. 

## Examples

* Jupyter notebooks and Python code examples that you can use to perform model management tasks are available in the [examples](examples/) directory.
* Sample data and models for Python and R programming language models are available in the [samples](samples/) directory.

For additional examples that demonstrate how to use the sasctl PZMM module to import Python models, see the [examples](https://github.com/sassoftware/python-sasctl/tree/master/examples) directory in the sasctl GitHub repository.

## SAS Model Manager CLIs

Here are the CLIs that are available for use with SAS Model Manager and SAS Open Model Manager:

* SAS Model Repository CLI - enables you to register, organize, and manage models within a common model repository.
* SAS Model Publish CLI - enables you to retrieve a list of publishing destinations and published objects (such as models), as well as information about a destination or published model.

The CLIs can be downloaded from the [SAS Model Manager Downloads](https://support.sas.com/downloads/browse.htm?fil=&cat=557) page on the SAS Support website.

## Startup Script for SAS Open Model Manager
The run_docker_container script in the [runOpenMM](runOpenMM/) directory launches the SAS Open Model Manager container.

For information about deploying the container, see [SAS Open Model Manager 1.2 for Containers: Deployment Guide](http://documentation.sas.com/?docsetId=dplymdlmgmt0phy0dkr&docsetTarget=titlepage.htm&docsetVersion=1.2&locale=en).

## Addons
The [addons](addons/) directory contains how-to information for administration and customization tasks.

## Contributing
We welcome your contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit contributions to this project.

## License
This project is licensed under the [Apache 2.0 License](LICENSE).

## Additional Resources
* [REST API documentation](https://developer.sas.com/apis/rest/DecisionManagement/)
* [REST API Examples](https://github.com/sassoftware/devsascom-rest-api-samples/tree/master/DecisionManagement)

