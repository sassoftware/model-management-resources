# Model Management Resources for Open-Source Models
This repository contains resources that can be used for administration and customizations that help with managing open-source models. In addition, there are sample models and data, and example Jupyter notebooks that can be used to submit API requests for common model management tasks using SAS Model Manager.

## Overview
The content on this GitHub repository is available for users of SAS Model Manager on SAS Viya. It provides scripts and sample code that can make it easier to perform model management tasks and manage your full model life cycle: development, testing, deployment, validation, and monitoring. 
It is meant for data analysts using open-source modeling languages such as Python and R to make it easy for open-source modelers to operationalize their models. 
This repository also serves as a place where the open source community of users can share ideas, code, and models.

_**Note:** Some capabilities that are used in the scripts and sample code are not supported by SAS Model Manager 15.3 or earlier versions._

For more information about model management, see the following resources:

* [Demo videos](#demo-videos)
* [Examples](#examples)
* [SAS Model Manager documentation](https://support.sas.com/en/software/model-manager-support.html#documentation)
* [SAS Model Manager command-line interfaces (CLIs)](#sas-model-manager-clis)

## Demo Videos

* [SAS Model Manager - ModelOps demo](https://www.sas.com/en_us/software/model-manager.html#demo)
* How-To Tutorial videos are available on the [SAS video portal](https://video.sas.com/?q=SAS%20Model%20Manager)

_Note:_ For how-to tutorial videos about using the pzmm Python package or sasctl.pzmm module to register a Python model, see the [pzmm demos](https://github.com/sassoftware/python-sasctl/blob/master/src/sasctl/pzmm/README.md#demos) in the python-sasctl GitHub Repository. 

## Examples

* Jupyter notebooks and Python code examples that you can use to perform model management tasks are available in the [examples](examples/) directory.
* Sample data and models for Python and R programming language models are available in the [samples](samples/) directory.

For additional examples that demonstrate how to use the pzmm module of the sasctl package to import Python models, see the [examples](https://github.com/sassoftware/python-sasctl/tree/master/examples) directory in the python-sasctl GitHub repository.

## SAS Model Manager CLIs

Here are the CLIs that are available for use with SAS Model Manager on SAS Viya 2020.1 and later:

* SAS Viya Models CLI - enables you to perform the following tasks:

  * Register, organize, and manage models within a common model repository. 
  * Retrieve a list of publishing destinations and published models
  * Retrieve information about a publishing destination or published model.
  * Create, update, and delete publishing destinations. _(SAS Viya 2022.1.2 and later)_
  

The SAS Viya Models CLI can be downloaded from the [SAS Viya CLI Downloads](https://support.sas.com/downloads/package.htm?pid=2512) page on the SAS Support website.


Here are the CLIs that are available for use with SAS Model Manager 15.3 or later on SAS Viya 3.5:

* SAS Model Repository CLI - enables you to register, organize, and manage models within a common model repository.
* SAS Model Publish CLI - enables you to retrieve a list of publishing destinations and published objects (such as models), as well as information about a destination or published model.

The CLIs can be downloaded from the [SAS Model Manager Downloads](https://support.sas.com/downloads/browse.htm?fil=&cat=557) page on the SAS Support website.

## Configuration
The [configuration](configuration/) directory contains how-to information for administration and customization tasks.

## Contributing
We welcome your contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit contributions to this project.

## License
This project is licensed under the [Apache 2.0 License](LICENSE).

## Additional Resources
* [REST API documentation](https://developer.sas.com/apis/rest/DecisionManagement/)
* [REST API Examples](https://github.com/sassoftware/devsascom-rest-api-samples/tree/master/DecisionManagement)

