# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0


import os
import platform

import pandas as pd
import numpy as np

# %%
class ScoreCode():
    
    def writeScoreCode(self, inputDF, targetDF, modelPrefix,
                       predictMethod, pRemotePath,
                       metrics=['EM_EVENTPROBABILITY', 'EM_CLASSIFICATION'],
                       pyPath=os.getcwd(), threshPrediction=None):
#TODO: Support additional metrics
        '''
        Writes Python score code for SAS Open Model Manager based on training data that is used
        to generate the model pickle file. The Python file is included in 
        the ZIP file that is imported into SAS Open Model Manager.
        
        Parameters
        ---------------
        inputDF : dataframe
            Dataframe containing training data, including only the predictor
            columns. This function currently only supports int(64), float(64),
            and str data types for scoring.
        targetDF : dataframe
            Dataframe containing training data of the target variable.
        modelPrefix : string
            Variable name for the model to be displayed in SAS Open Model Manager
            (i.e. hmeqClassTree + [Score.py || .pickle]).      
        predictMethod : string
            User-defined prediction method for score testing. This should be
            in a form such that the model and data input can be added using 
            the format() command. 
            For example: '{}.predict_proba({}).format(model, input)'.
        pRemotePath : string
            Remote path on the server for the pickle file's location.
        metrics : string list, optional
            Scoring metrics for model manager. The default is a set of two
            metrics: EM_EVENTPROBABILITY and EM_CLASSIFICATION.
        pyPath : string, optional
            Local path of the score code file. The default is the current 
            working directory.
        threshPrediction : float, optional
            Prediction theshold for probability metrics. For classification,
            below this threshold is a 0 and above is a 1.
			
		Yields
		---------------
        '*Score.py'
            Python score code file for SAS Open Model Manager.
        '''        
        
        inputVarList = list(inputDF.columns)
        newVarList = inputVarList
        inputDtypesList = list(inputDF.dtypes)
        
        if platform.system() == 'Windows':
            pRemotePath = ('/' + 
                           os.path.normpath(pRemotePath).replace('\\', '/'))        
        
        pyPath = os.path.join(pyPath, modelPrefix + 'Score.py')
        with open(pyPath, 'w') as self.pyFile:
            
            self.pyFile.write('''\
import pickle
import pandas as pd
import numpy as np''')
            
            self.pyFile.write(f'''
def score{modelPrefix}({', '.join(inputVarList)}):
    "Output: {', '.join(metrics)}"''')
            
            self.pyFile.write('''\n
    arguments = locals()''')
            
            self.pyFile.write(f'''\n
    with open('{pRemotePath}') as pFile:
        model = pickle.load(pFile)''')
            
            for i, dTypes in enumerate(inputDtypesList):
                dTypes = dTypes.name
                if 'int' in dTypes or 'float' in dTypes:
                    if self.checkIfBinary(inputDF[inputVarList[i]]):
                        self.pyFile.write(f'''\n
    if math.isnan({inputVarList[i]}):
        {inputVarList[i]} = {float(list(inputDF[inputVarList[i]].mode())[0])}''')
                    else:
                        self.pyFile.write(f'''\n
    if math.isnan({inputVarList[i]}):
        {inputVarList[i]} = {float(inputDF[inputVarList[i]].mean(axis=0, skipna=True))}''')
                elif 'str' in dTypes or 'object' in dTypes:
                    self.pyFile.write(f'''\n
    if {inputVarList[i]} is None:
        categoryStr = 'Other'
    else:
        categoryStr = {inputVarList[i]}.strip()\n''')
                    tempVar = self.splitStringColumn(inputDF[inputVarList[i]])
                    newVarList.remove(inputVarList[i])
                    newVarList.append(tempVar)
                    self.pyFile.write('''\n''')
            
            self.pyFile.write('''\n
    scoringDF = pd.DataFrame(, columns=[], dtype=float)''')
            # insert the model into the provided predictMethod call
            predictMethod = predictMethod.format('model')
            self.pyFile.write(f'''\n
    prediction = {predictMethod}''')
            
            self.pyFile.write(f'''\n
    {metrics[0]} = float(prediction)''')
            if threshPrediction is None:
                threshPrediction = np.mean(targetDF)
            self.pyFile.write(f'''\n
    if ({metrics[0]} >= {threshPrediction}):
        {metrics[1]} = '1'
    else:
        {metrics[1]} = '0' ''')
            
            self.pyFile.write(f'''\n
    return({metrics[0]}, {metrics[1]})''')
            
    def splitStringColumn(self, inputSeries):
        '''
        Split a column of string values into a number of new variables equal
        to the number of unique values in the original column (excluding None
        values). Then write to file new statements that tokenize the newly
        defined variables.
        
        As an example: given a series named strCol with values ['A', 'B', 'C',
        None, 'A', 'B', 'A', 'D'], designate the following new variables: 
        strCol_A, strCol_B, strCol_D. Then write the following to file:
            strCol_A = np.where(val == 'A', 1.0, 0.0)
            strCol_B = np.where(val == 'B', 1.0, 0.0)
            strCol_D = np.where(val == 'D', 1.0, 0.0)
                    
        Parameters
        ---------------
        inputSeries : string series
            Series with the string dtype.
        self.pyFile : file (class variable)
            Open python file to write into.
            
        Returns
        ---------------
        newVarList : string list
            List of all new variable names split from unique values.
        '''
        
        uniqueValues = inputSeries.unique()
        uniqueValues = list(filter(None, uniqueValues))
        newVarList = []
        for i, uniq in enumerate(uniqueValues):
            uniq = uniq.strip()
            newVarList.append('{}_{}'.format(inputSeries.name, uniq))
            self.pyFile.write('''
    {} = np.where(categoryStr == '{}', 1.0, 0.0)'''.format(newVarList[i],
                                                           uniq))
            
        if 'Other' not in uniqueValues:
            self.pyFile.write(f'''
    {inputSeries.name}_Other = np.where(categoryStr == 'Other', 1.0, 0.0)''')
        
        return newVarList
    
    def checkIfBinary(inputSeries):
        '''
        Check a pandas series to determine if the values are binary or nominal.
        
        Parameters
        ---------------
        inputSeries : float or int series
            Series with numeric values.
        
        Returns
        ---------------
        isBinary : boolean
            True if the series values are binary. False if the series values
            are nominal.
        '''
        
        isBinary = False
        binaryFloat = [float(1), float(0)]
        
        if inputSeries.value_counts().size == 2:
            if (binaryFloat[0] in inputSeries.astype('float') and 
                binaryFloat[1] in inputSeries.astype('float')):
                isBinary = True
                
        return isBinary
        