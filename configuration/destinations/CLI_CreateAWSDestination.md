Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

# Configure an Amazon Web Services Publishing Destination

_**Note:** Before you can use the models plug-in CLI to create a publishing destination, you must complete the [prerequisites](./README.md#prerequisites) in the README.md file._

To list the models plug-in CLI help for the destination create commands, use one of the following commands:

```commandline
sas-viya models destination create --help
sas-viya models destination createAWS --help
```

For more information about the models plug-in CLI commands and options, see [SAS Viya: Models Command-Line Interface](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrcli&docsetTarget=titlepage.htm).

Here are some examples of using the models plug-in to the SAS Viya CLI to create an Amazon Web Services publishing destination.

_**Note:** For the following CLI examples, you will be prompted to enter an access key ID and secret access key after the command is submitted._

## Example 1: Create an Amazon Web Services Destination

```commandline
sas-viya models destination create --type aws --name AWSDemo 
--identityId SASAdministrators --identityType group --kubernetesCluster mm-docker-models-eks 
--region us-east-1 --credDomainID domainAWS --validationNamespace default
```

OR

```commandline
sas-viya models destination createAWS --name AWSDemo 
--identityId SASAdministrators --identityType group --kubernetesCluster mm-docker-models-eks 
--region us-east-1 --credDomainID domainAWS --validationNamespace default
```

## Example 2: Create an Amazon Web Services Destination with Git Support

```commandline
sas-viya models destination createAWS --name AWSDemo 
--identityId SASAdministrators --identityType group --kubernetesCluster mm-docker-models-eks 
--region us-east-1 --credDomainID domainAWS --validationNamespace default 
--remoteRepoURL https://gitlab.myserver.com/sasdemo/sasdemo.git  --userEmail myemail@server.com 
--gitUserId sasdemo --gitAccessToken 'D4bPHJvByqSFnxGBrQ73'
```

## Example 3: Create an Amazon Web Services Destination with Git and Database Support

```commandline
sas-viya models destination createAWS --name AWSDemo 
--identityId SASAdministrators --identityType group --kubernetesCluster mm-docker-models-eks 
--region us-east-1 --credDomainID domainAWS --validationNamespace default 
--remoteRepoURL https://gitlab.myserver.com/sasdemo/sasdemo.git --userEmail myemail@server.com 
--gitUserId sasdemo --gitAccessToken 'D4bPHJvByqSFnxGBrQ73' 
--dbSecret oracle-secret-decision --dbConfigMap oracle-config
```