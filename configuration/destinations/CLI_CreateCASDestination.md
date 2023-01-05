Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

# Configure a CAS Destination

_**Note:** Before you can use the models plug-in CLI to create a publishing destination, you must complete the [prerequisites](./README.md#prerequisites) in the README.md file._

To list the models plug-in CLI help for the destination create commands, use one of the following commands:

```commandline
sas-viya models destination create --help
sas-viya models destination createCAS --help
```

For more information about the models plug-in CLI commands and options, see [SAS Viya: Models Command-Line Interface](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrcli&docsetTarget=titlepage.htm).

Here are some examples of using the models plug-in to the SAS Viya CLI to create a CAS publishing destination.

## Example 1: Create a Caslib

_**Note:** You must create a caslib before you define a CAS publishing destination._

```commandline
sas-viya cas caslibs create path --name myCaslib
--path /cas/data/caslibs/myCaslib
--server cas-shared-default
```

## Example 2: Create a CAS Destination

```commandline
sas-viya models destination create --type cas --name CASDest --description "CAS publishing destination." 
--casServer cas-shared-default --casLibrary myCaslib --modelTable mm_model_table
```

OR

```commandline
sas-viya models destination createCAS --name CASDest --description "CAS publishing destination." 
--casServer cas-shared-default --casLibrary myCaslib --modelTable mm_model_table
```

