Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

# Configure a Git Destination

_**Note:** Before you can use the models plug-in CLI to create a publishing destination, you must complete the [prerequisites](./README.md#prerequisites) in the README.md file._

To list the models plug-in CLI help for the destination create commands, use one of the following commands:

```commandline
sas-viya models destination create --help
sas-viya models destination createGit --help
```

For more information about the models plug-in CLI commands and options, see [SAS Viya: Models Command-Line Interface](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrcli&docsetTarget=titlepage.htm).

Here are some examples of using the models plug-in to the SAS Viya CLI to create a Git publishing destination.

## Example 1: Create a Git Destination

```commandline
sas-viya models destination create --type git --name GitDemo --credDomainID myGitDomain 
--identityId SASAdministrators --identityType group --remoteRepoURL https://gitlab.myserver.com/sasdemo/sasdemo.git 
--userEmail myemail@server.com --localRepoLocation /mmprojectpublic --userName mmdemo --gitBranch main 
--codeGenerationMode cas --deploymentGitFolder /deploymentTest
```

OR

```commandline
sas-viya models destination createGit --name GitDemo --credDomainID myGitDomain 
--identityId SASAdministrators --identityType group --remoteRepoURL https://gitlab.myserver.com/sasdemo/sasdemo.git 
--userEmail myemail@server.com --localRepoLocation /mmprojectpublic --userName mmdemo --gitBranch main 
--codeGenerationMode cas --deploymentGitFolder /deploymentTest
```

## Example 2: Create a Git Destination with Credentials

```commandline
sas-viya models destination createGit --name GitDemo --gitUserId sasdemo --gitAccessToken 'D4bPHJvByqSFnxGBrQ73' 
--identityId SASAdministrators --identityType group --remoteRepoURL https://gitlab.myserver.com/sasdemo/sasdemo.git
--userEmail myemail@server.com --localRepoLocation /mmprojectpublic --userName mmdemo --gitBranch main 
--codeGenerationMode cas --deploymentGitFolder /deploymentTest
```
