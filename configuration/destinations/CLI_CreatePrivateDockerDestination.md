Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

# Configure a Private Docker Publishing Destination

_**Note:** Before you can use the models plug-in CLI to create a publishing destination, you must complete the [prerequisites](./README.md#prerequisites) in the README.md file._

To list the models plug-in CLI help for the destination create commands, use one of the following commands:

```commandline
sas-viya models destination create --help
sas-viya models destination createPD --help
```

For more information about the models plug-in CLI commands and options, see [SAS Viya: Models Command-Line Interface](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrcli&docsetTarget=titlepage.htm).

Here are some examples of using the models plug-in to the SAS Viya CLI to create a Private Docker publishing destination.

_**Note:** For the following CLI examples, you will be prompted to enter a registry ID and password, as well as a Kubernetes key and certificate after the command is submitted._

## Example 1: Create a Private Docker Destination

```commandline
sas-viya models destination create --type privateDocker --name MyPrivateDocker --description "Private Docker container publishing destination." 
--identityId SASAdministrators --identityType group 
--baseRepoURL registry.myserver.com/mmrepo --kubeURL https://k8s-master.modelmanager.myserver.com:6443 --credDomainID pdOracleDomain 
--validationNamespace default
```

OR

```commandline
sas-viya models destination createPD --name MyPrivateDocker --description "Private Docker container publishing destination." 
--identityId SASAdministrators --identityType group 
--baseRepoURL registry.myserver.com/mmrepo --kubeURL https://k8s-master.modelmanager.myserver.com:6443 --credDomainID pdOracleDomain 
--validationNamespace default
```

## Example 2: Create a Private Docker Destination with Git Support

```commandline
sas-viya models destination createPD --name MyPrivateDocker 
--identityId SASAdministrators --identityType group --baseRepoURL registry.myserver.com/mmrepo
--kubeURL https://k8s-master.modelmanager.myserver.com:6443 --credDomainID pdOracleDomain 
--remoteRepoURL https://gitlab.myserver.com/sasdemo/sasdemo.git --gitUserEmail myemail@server.com 
--gitUserId sasdemo --gitAccessToken D4bPHJvByqSFnxGBrQ73 --deploymentGitFolder /deploymentTest
```

## Example 3: Create a Private Docker Destination with Git and Database Support

```commandline
sas-viya models destination createPD --name MyPrivateDocker 
--identityId SASAdministrators --identityType group --baseRepoURL registry.myserver.com/mmrepo
--kubeURL https://k8s-master.modelmanager.myserver.com:6443 --credDomainID pdOracleDomain 
--remoteRepoURL https://gitlab.myserver.com/sasdemo/sasdemo.git --gitUserEmail myemail@server.com 
--gitUserId sasdemo --gitAccessToken D4bPHJvByqSFnxGBrQ73 
--dbSecret oracle-secret-decision --dbConfigMap oracle-config
```