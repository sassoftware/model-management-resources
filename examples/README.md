# Overview

This directory contains examples of Jupyter notebooks and Python code that can be used to perform the following SAS Open Model Manager tasks:
* Calculate fit statistics, ROC, and lift, and then generate JSON files for a Python model
* Get the number of published models
* Build and import a trained Python model
* Fit a scoring script for Python model containerization
* Fit a scoring script for R model containerization
* Upload data to SAS Cloud Analytics Services (CAS)


## Calculate Fit Statistics, ROC, and Lift, and then Generate JSON Files

When you compare models, the model comparison output includes model properties, user-defined properties, and variables. The model comparison output
might also include fit statistics, and lift and ROC plots for the models if the required model files are available. The fit statistics, as well as
plots for lift and ROC, can be produced using Python packages that then generate JSON files. These JSON files are used to show the fit statistics
and plots when comparing models in SAS Open Model Manager.

To calculate fit statistics, see [ CalculateFitStatisticsROCLift.ipynb](./CalculateFitStatisticsROCLift.ipynb) in the examples directory.


## Get the Number of Published Models

You can return the number of projects with published models and the total number of published models by destination type.

To return a count for published models, see [GetPublishedModelsCount.ipynb](./GetPublishedModelsCount.ipynb) in the examples directory.


## Build and Import a Trained Python Model

A Python model can be built and trained before importing the model in SAS Open Model Manager as a ZIP file. The ZIP file contains model files that are associated
with a specific model and stored within the ZIP file. The ZIP file can contain model folders at the same level or in a hierarchical folder structure.
Each model folder within the ZIP file is imported as a separate model object that contains the contents of the model folder.
When you import models from a ZIP file into a project version, the hierarchical folder structure is ignored.

To build and import a trained Python model, see [ImportPythonModel.ipynb](./ImportPythonModel.ipynb) in the examples directory.


## Fit a Scoring Script for Python Model Containerization

The web services in the container store the input CSV file and pass the input file name to your scoring script. Web services will search for the first script whose file
name ends with 'score.py' for a Python model. The scoring script reads the input data from an input CSV file and then stores the output data in the CSV file.
The scoring script must follow the below pattern:

* The pickle file must be specified in the command-line arguments to be read by the script
* Input variables must be in the inputVar.json file, and the output variables in the outputVar.json file

To fit a scoring script for a Python model containerization, see [PythonModel_ScoreFileTutorial.md](./PythonModel_ScoreFileTutorial.md) in the examples directory .


## Fit a Scoring Script for R Model Containerization

The web services in the container store the input CSV file and pass the input file name to your scoring script. Web services will search for the first script whose file
name ends with 'score.R' for an R model. The scoring script must follow the below pattern:

* Default R score code that helps score the R model with a RDA model file
* The RDA model file must be specified in the command-line arguments to be read by the script

To fit a scoring script for a R model containerization, see [RModel_ScoreFileTutorial.md](./RModel_ScoreFileTutorial.md) in the examples directory.

## Upload Data to the SAS Cloud Analytics Services (CAS)

The SAS Scripting Wrapper for Analytics Transfer (SWAT) package can be used to upload local data to the CAS server. 

To upload data to CAS, see [UploadDataToCAS.ipynb](./UploadDataToCAS.ipynb) in the examples directory.

This project is licensed under the [Apache 2.0 License](../LICENSE).

## Additional Resources
* [SAS Open Model Manager: Help Center documentation](https://documentation.sas.com/?cdcId=openmmcdc&cdcVersion=1.2&docsetId=openmmug&docsetTarget=titlepage.htm&locale=en)



