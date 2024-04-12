# Overview

This directory contains sample data and models for the Python and R programming languages. You can use these samples to perform various tasks
with SAS Model Manager. To begin using the sample data and models, retrieve the files in the manner that you prefer and place all of the files in the same directory location.

This directory also contains sample workflow templates and sample code for creating custom KPI data.

_Note: Contributions from users other than the SAS Model Manager support team can be added to the external-samples subdirectories. For example, external Python model samples can be placed in the [/Python_Models/external-samples](./Python_Models/external-samples/README.md) subdirectory._

## Python Models

The following sample data and models are available in the [Python Models](./Python_Models) section of the samples directory:

* For a Scikit-learn decision tree, see [DTree_sklearn_PyPickleModel](../samples/Python_Models/DTree_sklearn_PyPickleModel)
* For a gradient boosted decision tree with XGBoost, see [Gradient_XGBoost_PyModel](../samples/Python_Models/Gradient_XGBoost_PyModel)


## R Models

The following sample data and models are available in the [R Models](./R_Models) section of the samples directory:

* For a decision tree using an R model, see [DTree_Rmodel](../samples/R_Models/DTree_Rmodel)
* For a logistical regression using an R model, see [LogisticReg_Rmodel](../samples/R_Models/LogisticReg_Rmodel)

## Workflow Integration

The [Workflow_Integration](./Workflow_Integration) section of the samples directory contains example workflows 
that can be used in conjunction with SAS Model Manager and SAS Workflow Manager.

## Custom KPIs

The [KPI](./KPI) section of the samples directory contains sample scripts for how to use DATA step and CASL code to create custom KPIs for use with SAS Model Manager.

## Container Tools
The [Container Tools](./Container_Tools) section of the samples directory contains tools to help perform tasks that take place outside of SAS Viya, such as the promotion of a container across environments. 

## ONNX Runtime in SAS Viya 4
A simple Kubernetes service can be defined to allow for the use of ONNX runtime in SAS Viya 4, without requiring changes to the entire Python overlay used by other services in SAS Viya 4. 
This sample walks through the creation of the container, web application, service, and models that can be scored within SAS Model Manager.

## Additional Resources

* [SAS Model Manager: Help Center documentation](http://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default)
* [SAS Workflow Manager: Help Center documentation](http://documentation.sas.com/?cdcId=wfscdc&cdcVersion=default)

This project is licensed under the [Apache 2.0 License](../LICENSE).
