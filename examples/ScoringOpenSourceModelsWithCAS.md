# Scoring Open-Source Models with CAS in SAS Viya 3.5

SAS Model Manager in SAS Viya 3.5 provides the ability to score Python and R models within CAS. For Python models, the user must modify their Python model files. However, for R models, a user must modify their model files and verify details about the SAS Viya server.

## Python

Python models that you can score in SAS Micro Analytic Service can also be scored in CAS by completing the following additional steps:

1. Create a copy of the score.sas file and rename the copy to something like scoreEP.sas.
2. Make the following changes to the header and the footer within the scoreEP.sas file, to convert the DS2 package code to DS2 embedded process code:
    - Change `package pythonScore / overwrite=yes;` to `data sasep.out;`. (Note: This is typically line 1 in SAS Model Manager generated DS2 code.)
    - Change `dcl int resultCode revision;` to `dcl double resultCode revision;`.
    - Add declaration statements for the model's output variables. For example, if the output variables were `EM_CLASSIFICATION` and `EM_EVENTPROBABILITY`, then the following lines should be added:
        - `dcl varchar(100) EM_CLASSIFICATION;`
        - `dcl double EM_EVENTPROBABILITY;`
    - Change `endpackage;` to the following code block, where the `score()` function call includes all model input variables:
        ``` 
        method run();
            set SASEP.IN;
            score(inputVar1, inputVar2, inputVar3);
        end;
        enddata;
        ```
3. Save the new file and change its File role property value to 'Score code'.
4. Change the Score code type model property to 'DS2 embedded process' and then save the model. 
   
   _**Note:** After steps 1 - 4 of this process have been completed, the model can no longer be scored or validated in SAS Micro Analytic Service. In order to score or validate the model in both SAS Micro Analytic Service and CAS, you must complete the changes in steps 5 and 6._
   
5. Rename the `score.sas` file to `dmcas_packagescorecode.sas` and the `scoreEP.sas` file to `dmcas_epscorecode.sas`.
6. Change the Score code type model property to "DS2 multi-type" and then save the model.

## R

You can score R models in CAS, similarly to Python models. However, the process is more involved and requires administrator permissions on the SAS Viya server. 

### Part One
Here are the steps to perform for the first part of this process on the SAS Viya server:

1. Verify that R is installed. If it is not installed, you can run one of the following commands to install it: 
    - `$ conda install -c r r`   (Install R through anaconda)
    - `$ bash -c "$(curl -L https://rstd.io/r-install)"` (Install R using curl)
2. Verify that the R path is set by running the command `$ which R` and then check for a response. If the R path is not set, run the following command to set it:
    `$ export PATH=$PATH:<path to R installation>`
3. Set the R_HOME environment for rpy2 to use with the following
    ```
    $ rhome=$(R RHOME)
    $ export R_HOME="${rhome}"
    ```
4. Install the rpy2 package from pip with `$ pip install rpy2`

### Part Two

Here are the steps to perform for the second part of the process in a local environment or in SAS Viya:

_**Note:** An example model can be found in `/samples/R_Models/Fleet_Rmodel`. The directory includes the files previously mentioned. It also includes optional statistical JSON files and a zipped version of the model files._

1. Generate and save the R model file (.rds is the preferred format) and write the R score code to be executed in SAS Model Manager.
2. Using the example model as a template, create an rpy2Wrapper.py file that calls the rpy2 package to run the R score code.
3. Create the inputVar.json, outputVar.json, ModelProperties.json, fileMetadata.json, and any of the other optional JSON files and make the following modifications.
   
   a. Modify the fileMetadata.json file and set the following roles:
   
        - rpy2Wrapper.py score code as "score"
        - \<modelFile>.rds as "scoreResource"
   
   b. Modify the modelProperties.json file to set the scoreCodeType to "Python".
   

4. Combine the model files into a ZIP archive file and import the file into SAS Model Manager.
5. Retrieve the UUID for the imported model and modify the rpy2Wrapper.py file to include the correct model UUID.
   
   _**Note:** You can retrieve the model's UUID from the **Properties** tab of a model._
   
6. Click the "Generate DS2 score code from Python code" icon button next to the left of the **Publish** button in the object toolbar.
7. Create a copy of the score.sas file and rename the copy to something like scoreEP.sas.
8. Make the following changes to the header and the footer within the scoreEP.sas file, to convert the DS2 package code to DS2 embedded process code:
    - Change `package pythonScore / overwrite=yes;` to `data sasep.out;`. (Note: This is typically line 1 in SAS Model Manager generated DS2 code.)
    - Change `dcl int resultCode revision;` to `dcl double resultCode revision;`.
    - Add declaration statements for the model's output variables. For example, if the output variables were `EM_CLASSIFICATION` and `EM_EVENTPROBABILITY`, then the following lines should be added:
        - `dcl varchar(100) EM_CLASSIFICATION;`
        - `dcl double EM_EVENTPROBABILITY;`
    - Change `endpackage;` to the following code block, where the `score()` function call includes all model input variables:
        ``` 
        method run();
            set SASEP.IN;
            score(inputVar1, inputVar2, inputVar3);
        end;
        enddata;
        ```
9.  Save the new file and change its File role property value to "Score code".
10. Change the Score code type model property to "DS2 embedded process" and then save the model.
11. Set the rpy2Wrapper.py model file's role to "Score resource".


### Part Three

Here are the steps to perform the third part of the process on the SAS Viya server:

1. Verify that the `/models/resources` directory exists and has a symbolic link to `/opt/sas/viya/config/data/modelsvr/resources`.
    - If the directory does not exist or is not symbolically linked, run the following commands:
      
        ```
        $ mkdir -p /models/resources
        $ ln -s /opt/sas/viya/config/data/modelsvr/resources /models/resources/viya
        ```
      
    - Next, create a resource folder for the model `$ mkdir /models/resources/viya/<UUID>`

2. Upload the .rds model file and rpy2Wrapper.py file to the server in one of two ways:
   
    a. scp the files into `/models/resources/viya/<UUID>`, and then run this command `$ chmod -R 777 /models/resources/viya/<UUID>` on the server.
   
    b. Run the following python script using python-sasctl:
   
    ```
    from sasctl.services import model_repository as mr
    from sasctl import Session
    sess = Session(host, username, password)
    id = <UUID>
    response = mr.put(f'/models/{id}/scoreResources', headers={'Accept': 'application/json'})
    ```

