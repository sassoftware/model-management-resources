Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

# Configure a Google Cloud Platform Publishing Destination

_**Note:** Before you can use the models plug-in CLI to create a publishing destination, you must complete the [prerequisites](./README.md#prerequisites) in the README.md file._

To list the models plug-in CLI help for the destination create commands, use one of the following commands:

```commandline
sas-viya models destination create --help
sas-viya models destination createGCP --help
```

For more information about the models plug-in CLI commands and options, see [SAS Viya: Models Command-Line Interface](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrcli&docsetTarget=titlepage.htm).

Here are some examples of using the models plug-in to the SAS Viya CLI to create a Google Cloud Platform publishing destination.

_**Note:** For the following CLI examples, you will be prompted to enter a service account and credential in JSON format after the command is submitted._

## Example 1: Create a Google Cloud Platform Destination

```commandline
sas-viya models destination create --type gcp --name GCPDemo 
--identityId SASAdministrators --identityType group --baseRepoURL "gcr.io/solorgasub7" 
--kubernetesCluster edmtestpub-gke --clusterLocation us-east1-b --credDomainID domainGCP 
--validationNamespace default
```

OR

```commandline
sas-viya models destination createGCP --name GCPDemo 
--identityId SASAdministrators --identityType group --baseRepoURL "gcr.io/myserviceaccount" 
--kubernetesCluster edmtestpub-gke --clusterLocation us-east1-b --credDomainID domainGCP 
--validationNamespace default
```

## Example 2: Create a Google Cloud Platform Destination with Git Support

```commandline
sas-viya models destination createGCP --name GCPDemo 
--identityId SASAdministrators --identityType group --baseRepoURL gcr.io/myserviceaccount 
--kubernetesCluster edmtestpub-gke --clusterLocation us-east1-b 
--serviceAccount myserviceaccount@gserviceaccount.com --credDomainID domainGCP 
--validationNamespace default --remoteRepoURL https://gitlab.myserver.com/sasdemo/sasdemo.git  --gitUserEmail myemail@server.com
--gitUserId sasdemo --gitAccessToken D4bPHJvByqSFnxGBrQ73 --deploymentGitFolder /deploymentTest
```

## Example 3: Create a Google Cloud Platform Destination with Git and Database Support

```commandline
sas-viya models destination createGCP --name GCPDemo 
--identityId SASAdministrators --identityType group --baseRepoURL gcr.io/myserviceaccount 
--kubernetesCluster edmtestpub-gke --clusterLocation us-east1-b 
--serviceAccount myserviceaccount@gserviceaccount.com --credDomainID domainGCP 
--validationNamespace default --remoteRepoURL https://gitlab.myserver.com/sasdemo/sasdemo.git  --gitUserEmail myemail@server.com
--gitUserId sasdemo --gitAccessToken D4bPHJvByqSFnxGBrQ73 
--dbSecret oracle-secret-decision --dbConfigMap oracle-config
```