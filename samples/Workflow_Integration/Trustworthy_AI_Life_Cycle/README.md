# SAS&#174; Trustworthy AI Life Cycle

The Trustworthy AI Life Cycle workflow definition outlines steps to evaluate and deploy a trustworthy AI system via model assessment, fairness 
and explainability evaluation, performance monitoring, and the appropriate data use. The workflow is informed by 
[SAS&#174; Model Manager](http://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default) capabilities and 
the [_NIST AI Risk Management Framework_](https://www.nist.gov/itl/ai-risk-management-framework) as it appeared in October 2023.

_**Note:** Version 1.0.0-beta of the Trustworthy AI Life Cycle workflow is experimental. 
Your thoughts, questions, and comments are welcome to enhance future versions of this workflow. 
Leave feedback using the **Issues** tab of the [Model Management Resources](https://github.com/sassoftware/model-management-resources) GitHub repository._ 

## Installation

Follow these steps to install the Trustworthy AI Life Cycle workflow:

1. Download and extract the contents of the Trustworthy_AI_Life_Cycle ZIP file.
2. Import the Trustworthy_AI_Life_Cycle.bpmn file into SAS Workflow Manager, and select **SAS Model Manager** as the client identifier. 
   This creates a workflow definition named **Trustworthy_AI_Life_Cycle** by default.
3. Select the **Trustworthy_AI_Life_Cycle** definition.
4. [Customize timer settings](#customizing-timer-settings). 

   _**Note:** Any changes made to the timer settings after the workflow has been activated will create a new workflow version that must be activated._

5. Create a new version of the definition. 
   
   _**Note:** A new workflow version must be created before the workflow can be activated. Make sure the version is not set to "Current"._

6. Activate the new version of the definition. 

   _**Note:** Only administrators can activate the workflow definition._

For more information, see [Import and Activate a Workflow Definition](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrqs&docsetTarget=p19zkxhqe0bvten1f1j1j7h6f7e4.htm#n1dk8lz6tczsunn17mluyiyvabsx) 
in _SAS Model Manager: Quick Start Tutorial_ and 
[_SAS Workflow Manager_: User's Guide](https://documentation.sas.com/?cdcId=wfscdc&cdcVersion=default).

## Usage

Run the Trustworthy_AI_Life_Cycle workflow against a SAS Model Manager project.

### Identifying Stakeholders

When you start the workflow, identify a model owner via the initial prompt. The model owner must be available through the 
SAS&#174; Viya&#174; platform Identities service and have the appropriate permissions. The model owner is assigned a user task to 
identify the remaining participants, such as the model developer and data engineer. Those participants must also be 
available through the SAS Viya platform Identities service and should have the appropriate permissions.

### Customizing Timer Settings

The workflow defines user-customizable timer settings. After you have imported the **Trustworthy_AI_Life_Cycle** definition, select the definition and navigate to the following subprocesses to customize the timer settings:

1. The length of time before initiating model performance monitoring; the default is set to one month.

	a. Navigate to the first step of subprocess 8.1 to access this timer node.

2. How long to wait for a model performance definition to execute; the default is set to thirty seconds.

	a. Navigate to the step after node 8.1.1.3 to access this timer node.

3. How long to wait for model performance results; the default is set to two minutes.

	a. Navigate to the step after node 8.1.2 to access this timer node.

4. The length of time before initiating a review of the project; the default is set to six months.

	a. Navigate to the first step of subprocess 8.2 to access this timer node.

Review the settings and, if necessary, adjust them according to your business needs and execution environment.

For more information, see [Using Timers](https://documentation.sas.com/?cdcId=wfscdc&cdcVersion=default&docsetId=wfsug&docsetTarget=p0rkmi3glzmjgzn1tq567i4e6k41.htm) in _SAS Workflow Manager: User's Guide_.

### Producing Documentation

Use the _Trustworthy AI Life Cycle Workflow Documentation Template_ (Trustworthy_AI_Life_Cycle_Companion.docx) 
in conjunction with the SAS Trustworthy AI Life Cycle workflow. 

_Note: This file is included in the Trustworthy_AI_Life_Cycle ZIP file._

## Contributing

Contributions from users other than the SAS Model Manager support team can be added to the 
[external-samples](../external-samples) subdirectory.

## License

[Apache 2.0 License](../../../LICENSE)
