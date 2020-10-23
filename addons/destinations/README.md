# Configuring Publishing Destinations

This directory contains examples of Jupyter notebooks that you can use to create container publishing destinations for Amazon Web Services (AWS), Azure, CAS, and Private Docker. 
The [viya35](./viya35) directory contains the examples for configuration publishing destinations for SAS Model Manager 15.3 on SAS Viya 3.5 and SAS Open Model Manager 1.2.

You can use the example Jupyter notebooks or Python scripts to create new publishing destinations for the following destination types: CAS, Amazon Web Services (AWS), Azure and Private Docker.

_**Note:** Creating a publishing destination for Azure is supported only for SAS Viya 4._

## SAS Viya 4


### Prerequisites

Here are the prerequisites for creating a new publishing destination for SAS Viya 2020.1 or later:

* Make sure that you have Python 3 with the requests package installed on the machine where you are going to run the Jupyter notebooks or scripts.
* Configure Azure to enable publishing validation for an Azure destination.

For more information, see [Configuring Publishing Destinations](http://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrag&docsetTarget=n0x0rvwqs9lvpun16sfdqoff4tsk.htm) in _SAS Model Manager: Administrator's Guide_.
   
### Create Publishing Destinations

* Make sure that you modify the host URL (host_name and port), SAS account, Domain name, or private Docker information in the examples before you run them.

* Run the Jupyter notebook or Python script for a specific destination type to create a publishing destination:

  * [CreateAWSDestination.ipynb](./CreateAWSDestination.ipynb)
  * [CreateAzureDestination.ipynb](./CreateAzureDestination.ipynb)
  * [CreatePrivateDockerDestination.ipynb](./CreatePrivateDockerDestination.ipynb)
  * [create_cas_destination.py](./create_cas_destination.py)


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
