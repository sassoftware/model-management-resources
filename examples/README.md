# Overview

This directory contains examples of Jupyter notebooks and Python code that can be used to perform the following SAS Model Manager tasks:
* [Calculate fit statistics, ROC, and lift, and then generate JSON files for a Python model](#calculate-fit-statistics-roc-and-lift-and-then-generate-json-files)
* [Get the number of published models](#get-the-number-of-published-models)
* [Build and import a trained Python model](#build-and-import-a-trained-python-model)
* [Fit a scoring script for Python model containerization](#fit-a-scoring-script-for-python-model-containerization)
* [Fit a scoring script for R model containerization](#fit-a-scoring-script-for-r-model-containerization)
* [Upload data to SAS Cloud Analytics Services (CAS)](#upload-data-to-the-sas-cloud-analytics-services-cas)
* [Delete model content logs](#delete-model-content-logs)
* [Score open-source models with CAS in SAS Viya 3.5](#score-open-source-models-with-cas-in-sas-viya-35)

## Calculate Fit Statistics, ROC, and Lift, and then Generate JSON Files

When you compare models, the model comparison output includes model properties, user-defined properties, and variables. The model comparison output
might also include fit statistics, and lift and ROC plots for the models if the required model files are available. The fit statistics, as well as
plots for lift and ROC, can be produced using Python packages that generate JSON files. These JSON files are used to show the fit statistics
and plots when comparing models in SAS Model Manager.

To calculate fit statistics, see [ CalculateFitStatisticsROCLift.ipynb](./CalculateFitStatisticsROCLift.ipynb) in the examples directory.


## Get the Number of Published Models

You can return the number of projects with published models and the total number of published models by destination type.

To return a count for published models, see [GetPublishedModelsCount.ipynb](./GetPublishedModelsCount.ipynb) in the examples directory.

## Build and Import a Trained Python Model

A Python model can be built and trained before importing the model in SAS Model Manager as a ZIP file. The ZIP file contains model files that are associated
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

* Default R score code that helps score the R model with an RDA model file
* The RDA model file must be specified in the command-line arguments to be read by the script

To fit a scoring script for an R model containerization, see [RModel_ScoreFileTutorial.md](./RModel_ScoreFileTutorial.md) in the examples directory.

## Upload Data to the SAS Cloud Analytics Services (CAS)

The SAS Scripting Wrapper for Analytics Transfer (SWAT) package can be used to upload local data to the CAS server. 

To upload data to CAS, see [UploadDataToCAS.ipynb](./UploadDataToCAS.ipynb) in the examples directory.

## Delete Model Content Logs
When you publish a model to a destination, there are log and SAS code files that are generated within the contents of a model object. 
You can delete the files for a specific model, all models within a project, or all models within the common model repository. 
The model content is only deleted for the following file types: ScoreCodeGen{}.sas or ScoreCodeGen{}.log. The most recent revision of each file type is not deleted.

To delete model content logs, see [DeleteModelContentLogs.ipynb](./DeleteModelContentLogs.ipynb) in the examples directory.

## Score Open-Source Models with CAS in SAS Viya 3.5
SAS Model Manager in SAS Viya 3.5 provides the ability to score Python and R models within CAS. For Python models, the user must modify their Python model files. 
However, for R models, a user must modify their model files and verify details about the SAS Viya server.

To score open-source models within CAS, see [ScoringOpenSourceModelsWithCAS.md](./ScoringOpenSourceModelsWithCAS.md) in the examples directory.

## Additional Resources
* [SAS Model Manager: Help Center documentation](https://documentation.sas.com/doc/en/mdlmgrcdc/default/mdlmgrwlcm/home.htm)


This project is licensed under the [Apache 2.0 License](../LICENSE).
