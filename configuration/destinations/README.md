# Configuring Publishing Destinations

This directory contains SAS Viya CLI examples that you can use to create publishing destinations for CAS, Git, Azure Machine Learning, and container destinations such as Amazon Web Services (AWS), Azure, Google Cloud Platform (GCP) and Private Docker. 
The [viya35](../../configuration/destinations/viya35) subdirectory contains the examples for configuration publishing destinations for SAS Model Manager 15.3 or later on SAS Viya 3.5.

In SAS Viya, a command-line interface (CLI) is a user interface to the SAS Viya REST API services. In this interface, you enter commands on a command line and receive a response from the system. 
You can use a CLI to interact directly with SAS Viya programmatically without a GUI. For information about the CLIs that are provided with SAS Viya, see [Command-Line Interface: Overview](https://documentation.sas.com/?cdcId=sasadmincdc&cdcVersion=default&docsetId=calcli&docsetTarget=n01xwtcatlinzrn1gztsglukb34a.htm).

The models plug-in to the SAS Viya CLI can be used to create, update, and delete publishing destinations for use with SAS Viya 2022.1.2 and later.

The SAS Viya CLI can be downloaded from the [SAS Viya CLI Downloads](https://support.sas.com/downloads/package.htm?pid=2512) page on the SAS Support website.

## SAS Viya 2022.1.2 and Later

### Prerequisites

Here are the prerequisites for creating a new publishing destination for SAS Viya 2022.1.2 or later:

* Download the SAS Viya CLI and install the models plug-in. See: [SAS Viya: Models Command-Line Interface](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrcli&docsetTarget=titlepage.htm)
* Complete the destination-specific configuration steps. See: [Publishing Destinations: How To](https://documentation.sas.com/?cdcId=sasadmincdc&cdcVersion=default&docsetId=calpubdest&docsetTarget=p02scrqf37kexwn1gi60khpshifz.htm) in _SAS Viya: Publishing Destinations_ documentation
   
### Create Publishing Destinations

* Make sure that you modify the host URL (host-name and port), SAS account, Domain name, or destination-specific information in the examples before you run them.

* Run the destination command and subcommands with options for a specific destination type to create a publishing destination:

  * [CLI_CreateAMLDestination.md](./CLI_CreateAMLDestination.md)
  * [CLI_CreateAWSDestination.md](./CLI_CreateAWSDestination.md)
  * [CLI_CreateAzureDestination.md](./CLI_CreateAzureDestination.md)
  * [CLI_CreateCASDestination.md](./CLI_CreateCASDestination.md)
  * [CLI_CreateGCPDestination.md](./CLI_CreateGCPDestination.md)
  * [CLI_CreateGitDestination.md](./CLI_CreateGitDestination.md)
  * [CLI_CreatePrivateDockerDestination.md](./CLI_CreatePrivateDockerDestination.md)

To list the models plug-in CLI help for the destination command, use the following command:

```commandline
sas-viya models destination --help
```

For more information about the models plug-in CLI commands and options, see [SAS Viya: Models Command-Line Interface](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrcli&docsetTarget=titlepage.htm).


## SAS Viya 3.5

Here are the prerequisites for creating a new publishing destination for SAS Viya 3.5:

* Make sure that you have Python 3 with the requests package installed on the machine where you are going to run the scripts.

  Here is an example of using yum to install Python 3 on a machine:

  ```
   sudo yum install -y python3
   sudo pip3 install requests
  ```

* If your destination type is AWS, you must create a credential domain in SAS Credentials service and store the AWS access key information in the credentials. Please modify the host URL (viya_host and port), SAS account, and AWS access key information in the script, and then enter the domain name in the create_aws_destination.py file.

  ```
   python create_aws_credential_domain.py
  ```

* Make sure that you modify the host URL (viya_host and port), SAS account, Domain name, or private Docker information in the script before you run them.

* If Python 3 executable file name is 'python3', then update the following commands to use 'python3', instead of 'python'.
  ```
   python create_cas_destination.py
   python create_aws_destination.py
   python create_privatedocker_destination.py
  ```
