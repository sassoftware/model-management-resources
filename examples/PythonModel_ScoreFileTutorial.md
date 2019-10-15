# How to Fit Your Scoring Script for Python Model Containerization

## Overview
The Web services in the container store the input CSV file and pass the input file name to your scoring script. Your scoring script must follow a specific pattern. 

In this tutorial, I explain the pattern that you must follow in your scoring script.

## Search Order
The Web services in the container first start searching for the scoring script that is defined in the fileMetadata.json file, if it exists.

The fileMetadata.json file is created by the Model Repository API when the model is downloaded from the common model repository. 

You can use the SAS Model Manager or SAS Open Model Manager web application to set the file role for the scoring script to "Score code". This can be done by selecting the scoring script file on the **Files** tab of a model object and editing the file properties. For more information, see [Assign Model File Roles](https://documentation.sas.com/?cdcId=openmmcdc&cdcVersion=1.2&docsetId=openmmug&docsetTarget=n026ttfq4xcn5an19dpfo4jcyuqz.htm&locale=en#n1k0tfrt0d1dqtn1gvw5huqz7gpb) in the _SAS Open Model Manager 1.2: User's Guide_.

If, the file role for the scoring script is not set as "Score code", the Web services searches for the first script whose file name ends with 'score.py' for a Python model.
    
## Commands
The Web services call your scoring script using the following formats. 

Note: The log file records all of the stdout and stderr outputs from the scoring script during execution.

### Python
```
python -W ignore <score filename> [-m <pickle filename>] -i <input csv filename> -o <output csv filename> >> <log filename> 2>&1
```

### R
```
Rscript <score filename> [model filename] <input csv filename> <output csv filename> >> <log filename> 2>&1
```

## Samples
Based on above description, the pattern of the scoring script must accept two parameters for input and output CSV files. 

In the next section there is a Python scoring script sample with the pattern.

### Python
If you have a scoring script ready in a Jupyter notebook, please download the script as a .py file first. 
In your Python script, you can copy most of the following sample script and modify the **run** function to fit your requirements. 

If you export the model ZIP file from the common model repository, the ZIP file might include the  inputVar.json and outputVar.json files. In the scoring script, you use the configuration that you have done in the SAS Model Manager or SAS Open Model Manager web application.

```
# If the pickle file has not specified in command-line arguments, the script
# looks for the first pickle file in the current directory, and the script quits, if the file is not found.

# The scoring script reads the input variables from the inputVar.json file, and the output variables
# from the outputVar.json file.

# The scoring script reads the input data from input CSV file and stores the output data in the CSV file.

import argparse
import os
import os.path
import sys
import pandas as pd
import numpy as np
import pickle
import json

# Find the first file that matches the pattern.
def find_file(suffix):
    current_dir = os.path.dirname( os.path.abspath(__file__))
    for file in os.listdir(current_dir):
        if file.endswith(suffix):
            filename = file
            return os.path.join(current_dir, filename)

    return None


def load_var_names(filename):
    var_file = find_file(filename)
    if var_file is None:
        return None
    if os.path.isfile(var_file):
        with open(var_file) as f:
            json_object = json.load(f)

        names = []
        for row in json_object:
            names.append(row["name"])
        return names
    else:
        print('Didnot find file: ', filename)
        return None


def intersection(lst1, lst2):
    lst3 = [value for value in lst1 if value in lst2]
    return lst3


def load_data_by_input_vars(data):
    names = load_var_names('inputVar.json')
    if names is None:
        return data
    else:
        newcolumns = intersection(list(data.columns), names)
        return data[newcolumns]

def run(model_file, input_file, output_file):
    if model_file is None:
        print('Not found Python pickle file!')
        sys.exit()

    if not os.path.isfile(input_file):
        print('Not found input file', input_file)
        sys.exit()

    inputDf = pd.read_csv(input_file).fillna(0)

    output_vars = load_var_names('outputVar.json')

    in_dataf = load_data_by_input_vars(inputDf)

    model = open(model_file, 'rb')
    pkl_model = pickle.load(model)
    model.close()

    outputDf = pd.DataFrame(pkl_model.predict_proba(in_dataf))

    if output_vars is None:
        outputcols = map(lambda x: 'P_' + str(x), list(pkl_model.classes_))
    else:
        outputcols = map(lambda x: output_vars[x], list(pkl_model.classes_))
    outputDf.columns = outputcols

    # merge with input data
    outputDf = pd.merge(inputDf, outputDf, how='inner', left_index=True, right_index=True)

    print('printing first few lines...')
    print(outputDf.head())
    outputDf.to_csv(output_file, sep=',', index=False)
    return outputDf.to_dict()

def main():
    # parse arguments
    parser = argparse.ArgumentParser(description='Score')
    parser.add_argument('-m', dest="modelFile", help='model file name, the default is the first PKL file that is found in the directory')
    parser.add_argument('-i', dest="scoreInputCSV", required=True, help='input filename')
    parser.add_argument('-o', dest="scoreOutputCSV", required=True, help='output csv filename')

    args = parser.parse_args()
    model_file = args.modelFile
    input_file = args.scoreInputCSV
    output_file = args.scoreOutputCSV

    # Search for the first PKL file in the directory if argument is not specified.
    if model_file is None:
        for file in os.listdir("."):
            if file.endswith(".pkl"):
                model_file = file
                break

    result = run(model_file, input_file, output_file)
    return 0


if __name__ == "__main__":
    sys.exit(main())

```

## License

This project is licensed under the [Apache 2.0 License](../LICENSE).

