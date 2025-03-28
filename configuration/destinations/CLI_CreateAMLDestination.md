Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

# Configure an Azure Machine Learning Publishing Destination

_**Note:** Before you can use the models plug-in CLI to create a publishing destination, you must complete the [prerequisites](./README.md#prerequisites) in the README.md file._

To list the models plug-in CLI help for the destination create commands, use one of the following commands:

```commandline
sas-viya models destination create --help
sas-viya models destination createAML --help
```

For more information about the models plug-in CLI commands and options, see [SAS Viya: Models Command-Line Interface](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrcli&docsetTarget=titlepage.htm).

Here are some examples of using the models plug-in to the SAS Viya CLI to create an Azure Machine Learning publishing destination.

## Example 1: Create an Azure Machine Learning Destination

```commandline
sas-viya models destination create --type aml --name AMLDemo --baseRepoURL <CONTAINER-REGISTRY-ID>.azurecr.io 
--subscriptionId <SUBSCRIPTION-ID> --region eastus
```

OR

```commandline
sas-viya models destination createAML --name AMLDemo --baseRepoURL <CONTAINER-REGISTRY-ID>.azurecr.io 
--subscriptionId <SUBSCRIPTION-ID> --region eastus
```

