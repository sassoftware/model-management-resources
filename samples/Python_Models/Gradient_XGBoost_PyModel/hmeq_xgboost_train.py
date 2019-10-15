# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import matplotlib.pyplot as plt
import numpy
import pandas
import pickle
import sympy 

import sklearn.metrics as metrics
import xgboost

import json
import os
import sys
import zipfile

# Define the analysis folder
analysisFolder = str('C:\\MyJob\\Projects\\ModelManager\\Test\\HMEQ\\XGBoost\\')
dataFolder = str('C:\\MyJob\\Projects\\ModelManager\\Test\\HMEQ\\')

# Define the prefix for model specific file name
prefixModelFile = str('hmeq_xgboost')

# The Gain and Lift function
def compute_lift_coordinates (
        DepVar,          # The column that holds the dependent variable's values
        EventValue,      # Value of the dependent variable that indicates an event
        EventPredProb,   # The column that holds the predicted event probability
        Debug = 'N'):    # Show debugging information (Y/N)

    # Find out the number of observations
    nObs = len(DepVar)

    # Get the quantiles
    quantileCutOff = numpy.percentile(EventPredProb, numpy.arange(0, 100, 10))
    nQuantile = len(quantileCutOff)

    quantileIndex = numpy.zeros(nObs)
    for i in range(nObs):
        iQ = nQuantile
        EPP = EventPredProb[i]
        for j in range(1, nQuantile):
            if (EPP > quantileCutOff[-j]):
                iQ -= 1
        quantileIndex[i] = iQ

    # Construct the Lift chart table
    countTable = pandas.crosstab(quantileIndex, DepVar)
    decileN = countTable.sum(1)
    decilePct = 100 * (decileN / nObs)
    gainN = countTable[EventValue]
    totalNResponse = gainN.sum(0)
    gainPct = 100 * (gainN /totalNResponse)
    responsePct = 100 * (gainN / decileN)
    overallResponsePct = 100 * (totalNResponse / nObs)
    lift = responsePct / overallResponsePct

    LiftCoordinates = pandas.concat([decileN, decilePct, gainN, gainPct, responsePct, lift],
                                    axis = 1, ignore_index = True)
    LiftCoordinates = LiftCoordinates.rename({0:'Decile N',
                                              1:'Decile %',
                                              2:'Gain N',
                                              3:'Gain %',
                                              4:'Response %',
                                              5:'Lift'}, axis = 'columns')

    # Construct the Accumulative Lift chart table
    accCountTable = countTable.cumsum(axis = 0)
    decileN = accCountTable.sum(1)
    decilePct = 100 * (decileN / nObs)
    gainN = accCountTable[EventValue]
    gainPct = 100 * (gainN / totalNResponse)
    responsePct = 100 * (gainN / decileN)
    lift = responsePct / overallResponsePct

    accLiftCoordinates = pandas.concat([decileN, decilePct, gainN, gainPct, responsePct, lift],
                                       axis = 1, ignore_index = True)
    accLiftCoordinates = accLiftCoordinates.rename({0:'Acc. Decile N',
                                                    1:'Acc. Decile %',
                                                    2:'Acc. Gain N',
                                                    3:'Acc. Gain %',
                                                    4:'Acc. Response %',
                                                    5:'Acc. Lift'}, axis = 'columns')

    if (Debug == 'Y'):
        print('Number of Quantiles = ', nQuantile)
        print(quantileCutOff)
        _u_, _c_ = numpy.unique(quantileIndex, return_counts = True)
        print('Quantile Index: \n', _u_)
        print('N Observations per Quantile Index: \n', _c_)
        print('Count Table: \n', countTable)
        print('Accumulated Count Table: \n', accCountTable)

    return(LiftCoordinates, accLiftCoordinates)

# Define the analysis variable
yName = 'BAD'
catName = ['JOB', 'REASON']
intName = ['CLAGE', 'CLNO', 'DEBTINC', 'DELINQ', 'DEROG', 'NINQ', 'YOJ']

# Read the input data
inputData = pandas.read_csv(dataFolder + 'hmeq_train.csv', sep = ',',
                            usecols = [yName] + catName + intName)

# Define the training data and drop the missing values
useColumn = [yName]
useColumn.extend(catName + intName)
trainData = inputData[useColumn].dropna()

# STEP 1: Explore the data

# Describe the interval variables grouped by category of the target variable
print(trainData.groupby(yName).size())

# Draw boxplots of the interval predictors by levels of the target variable
for ivar in intName:
   trainData.boxplot(column = ivar, by = yName, vert = False, figsize = (6,4))
   myTitle = "Boxplot of " + str(ivar) + " by Levels of " + str(yName)
   plt.title(myTitle)
   plt.suptitle("")
   plt.xlabel(ivar)
   plt.ylabel(yName)
   plt.grid(axis="y")
   plt.show()

# STEP 2: Build the XGBoost model

# Threshold for the misclassification error (BAD: 0-No, 1-Yes)
threshPredProb = numpy.mean(trainData[yName])

# Specify the categorical target variable
y = trainData[yName].astype('category')

# Retrieve the categories of the target variable
y_category = y.cat.categories
nYCat = len(y_category)

# Specify the categorical predictors and generate dummy indicator variables
fullX = pandas.get_dummies(trainData[catName].astype('category'))

# Specify the interval predictors and append to the design matrix
fullX = fullX.join(trainData[intName])

# Find the non-redundant columns in the design matrix fullX
reduced_form, inds = sympy.Matrix(fullX.values).rref()

# Extract only the non-redundant columns for modeling
#print(inds)
X = fullX.iloc[:, list(inds)]

# The number of free parameters
thisDF = len(inds) * (nYCat - 1)

# Maximum depth = 5 and number of estimator is 50
max_depth = 5
n_estimators = 50
_objXGB = xgboost.XGBClassifier(max_depth = max_depth, n_estimators = n_estimators,
                                objective = 'binary:logistic', booster = 'gbtree',
                                verbosity = 1, random_state = 27513)
thisFit = _objXGB.fit(X, y)

# STEP 3: Assess the model
y_predProb = thisFit.predict_proba(X).astype(numpy.float64)

# Average square error
y_sqerr = numpy.where(y == 1, (1.0 - y_predProb[:,1])**2, (0.0 - y_predProb[:,1])**2)
y_ase = numpy.mean(y_sqerr)
y_rase = numpy.sqrt(y_ase) 
print("Root Average Square Error = ", y_rase)

# Misclassification error
y_predict = numpy.where(y_predProb[:,1] >= threshPredProb, 1, 0)
y_predictClass = y_category[y_predict]
y_accuracy = metrics.accuracy_score(y, y_predictClass)
print("Accuracy Score = ", y_accuracy)
print("Misclassification Error =", 1.0 - y_accuracy)

# Area Under Curve
y_auc = metrics.roc_auc_score(y, y_predProb[:,1]) 
print("Area Under Curve = ", y_auc)

# Generate the coordinates for the ROC curve
y_fpr, y_tpr, y_threshold = metrics.roc_curve(y, y_predProb[:,1], pos_label = 1)
y_roc = pandas.DataFrame({'fpr': y_fpr, 'tpr': y_tpr, 'threshold': numpy.minimum(1.0, numpy.maximum(0.0, y_threshold))})

# Draw the ROC curve
plt.figure(figsize=(6,6))
plt.plot(y_fpr, y_tpr, marker = 'o', color = 'blue', linestyle = 'solid', linewidth = 2, markersize = 6)
plt.plot([0, 1], [0, 1], color = 'black', linestyle = ':')
plt.grid(True)
plt.xlabel("1 - Specificity (False Positive Rate)")
plt.ylabel("Sensitivity (True Positive Rate)")
plt.legend(loc = 'lower right')
plt.axis("equal")
plt.show()

# Get the Lift chart coordinates
y_lift, y_acc_lift = compute_lift_coordinates(DepVar = y, EventValue = y_category[1], EventPredProb = y_predProb[:,1])

# Draw the Lift chart
plt.plot(y_lift.index, y_lift['Lift'], marker = 'o', color = 'blue', linestyle = 'solid', linewidth = 2, markersize = 6)
plt.title('Lift Chart')
plt.grid(True)
plt.xticks(numpy.arange(1,11, 1))
plt.xlabel("Decile Group")
plt.ylabel("Lift")
plt.show()

# Draw the Accumulative Lift chart
plt.plot(y_acc_lift.index, y_acc_lift['Acc. Lift'], marker = 'o', color = 'blue', linestyle = 'solid', linewidth = 2, markersize = 6)
plt.title('Accumulated Lift Chart')
plt.grid(True)
plt.xticks(numpy.arange(1,11, 1))
plt.xlabel("Decile Group")
plt.ylabel("Accumulated Lift")
plt.show()

# Put the fit statistics into the fitStats series, names in index
fitStats = pandas.Series(['TRAIN',
                          1,
                          '           1',
                         len(y),
                         y_ase,
                         len(y),
                         y_rase,
                         (1.0 - y_accuracy),
                         threshPredProb,
                         y_auc],
                         index = ['_DataRole_',
                                  '_PartInd_',
                                  '_PartInd__f',
                                  '_NObs_', 
                                  '_ASE_',
                                  '_DIV_',
                                  '_RASE_',
                                  '_MCE_',
                                  '_THRESH_',
                                  '_C_'])

# STEP 4: Prepare the materials for importing the model to the Model Manager

# Create a benchmark data for checking accuracy of score
outputVar = pandas.DataFrame(columns = ['EM_EVENTPROBABILITY', 'EM_CLASSIFICATION'])
outputVar['EM_CLASSIFICATION'] = y_category.astype('str')
outputVar['EM_EVENTPROBABILITY'] = 0.5

outputScore = pandas.DataFrame(index = trainData.index)
outputScore['P_BAD0'] = y_predProb[:,0]
outputScore['P_BAD1'] = y_predProb[:,1]
outputScore['I_BAD'] = y_predictClass

train_wscore = pandas.DataFrame.merge(inputData, outputScore, how = 'left', left_index = True, right_index = True)

with pandas.ExcelWriter(analysisFolder + 'hmeq_xgboost_score.xlsx') as writer:
    train_wscore.to_excel(writer, sheet_name = 'With Score')

# Prepare to create the ZIP file for importing into Model Manager
def WriteVarJSON (inputDF, debug = 'N'):
    inputName = inputDF.columns.values.tolist()
    outJSON = pandas.DataFrame() 

    for pred in inputName:
        thisVar = inputDF[pred]
        firstRow = thisVar.loc[thisVar.first_valid_index()]
        dType = thisVar.dtypes.name
        dKind = thisVar.dtypes.kind
        isNum = pandas.api.types.is_numeric_dtype(firstRow)
        isStr = pandas.api.types.is_string_dtype(thisVar)

        if (debug == 'Y'):
            print('pred =', pred)
            print('dType = ', dType)
            print('dKind = ', dKind)
            print('isNum = ', isNum)
            print('isStr = ', isStr)

        if (isNum):
            if (dType == 'category'):
                outLevel = 'nominal'
            else:
                outLevel = 'interval'
            outType = 'decimal'
            outLen = 8
        elif (isStr):
            outLevel = 'nominal'
            outType = 'string'
            outLen = thisVar.str.len().max()

        outRow = pandas.Series([pred, outLen, outType, outLevel],
                               index = ['name', 'length', 'type', 'level'])
                           
        outJSON = outJSON.append([outRow], ignore_index = True)

    return (outJSON)

def WriteClassModelPropertiesJSON (modelName, modelDesc, targetVariable, modelType, modelTerm, targetEvent, nTargetCat, eventProbVar = None):

    thisForm = modelDesc + ' : ' + targetVariable + ' = '
    iTerm = 0
    for thisTerm in modelTerm:
        if (iTerm > 0):
            thisForm = thisForm + ' + '
        thisForm += thisTerm
        iTerm += 1

    if (nTargetCat > 2):
        targetLevel = 'NOMINAL'
    else:
        targetLevel = 'BINARY'

    if (eventProbVar == None):
        eventProbVar = 'P_' + targetVariable + targetEvent

    modeler = os.getlogin()

    toolVersion = str(sys.version_info.major) + '.' + str(sys.version_info.minor) + '.' + str(sys.version_info.micro)

    thisIndex = ['name', 'description', 'function', 'scoreCodeType', 'trainTable', 'trainCodeType', 'algorithm', \
                 'targetVariable', 'targetEvent', 'targetLevel', 'eventProbVar', 'modeler', 'tool', 'toolVersion']

    thisValue = [modelName, \
                 thisForm, \
                 'classification', \
                 'python', \
                 ' ', \
                 'Python', \
                 modelType, \
                 targetVariable, \
                 targetEvent, \
                 targetLevel, \
                 eventProbVar, \
                 modeler, \
                 'Python 3', \
                 toolVersion]

    outJSON = pandas.Series(thisValue, index = thisIndex)

    return(outJSON)

# Create the dmcas_fitstat.json file
# Names of the statistics are indices to the fitStats series
def WriteFitStatJSON (fitStats, debug = 'N'):
    _dict_DataRole_ = {'parameter': '_DataRole_', 'type': 'char', 'label': 'Data Role',
                       'length': 10, 'order': 1, 'values': ['_DataRole_'], 'preformatted': False}

    _dict_PartInd_ = {'parameter': '_PartInd_', 'type': 'num', 'label': 'Partition Indicator',
                      'length': 8, 'order': 2, 'values': ['_PartInd_'], 'preformatted': False}

    _dict_PartInd__f = {'parameter': '_PartInd__f', 'type': 'char', 'label': 'Formatted Partition',
                        'length': 12, 'order': 3, 'values': ['_PartInd__f'], 'preformatted': False}

    _dict_NObs_ = {'parameter': '_NObs_', 'type': 'num', 'label': 'Sum of Frequencies',
                   'length': 8, 'order': 4, 'values': ['_NObs_'], 'preformatted': False}

    _dict_ASE_ = {'parameter': '_ASE_', 'type': 'num', 'label': 'Average Squared Error',
                  'length': 8, 'order': 5, 'values': ['_ASE_'], 'preformatted': False}

    _dict_DIV_ = {'parameter': '_DIV_', 'type': 'num', 'label': 'Divisor for ASE',
                  'length': 8, 'order': 6, 'values': ['_DIV_'], 'preformatted': False}

    _dict_RASE_ = {'parameter': '_RASE_', 'type': 'num', 'label': 'Root Average Squared Error',
                   'length': 8, 'order': 7, 'values': ['_RASE_'], 'preformatted': False}

    _dict_MCE_ = {'parameter': '_MCE_', 'type': 'num', 'label': 'Misclassification Error',
                  'length': 8, 'order': 8, 'values': ['_MCE_'], 'preformatted': False}

    _dict_THRESH_ = {'parameter': '_THRESH_', 'type': 'num', 'label': 'Threshold for MCE',
                     'length': 8, 'order': 9, 'values': ['_THRESH_'], 'preformatted': False}

    _dict_C_ = {'parameter': '_C_', 'type': 'num', 'label': 'Area Under Curve',
                'length': 8, 'order': 10, 'values': ['_C_'], 'preformatted': False}

    parameterMap = {'_DataRole_': _dict_DataRole_, '_PartInd_': _dict_PartInd_, '_PartInd__f':  _dict_PartInd__f,
                    '_NObs_' : _dict_NObs_, '_ASE_' : _dict_ASE_, '_DIV_' : _dict_DIV_, '_RASE_' : _dict_RASE_,
                    '_MCE_' : _dict_MCE_, '_THRESH_' : _dict_THRESH_, '_C_' : _dict_C_}

    dataMapValue = pandas.Series.to_dict(fitStats)

    outJSON = {'name' : 'dmcas_fitstat',
               'revision' : 0,
               'order' : 0,
               'parameterMap' : parameterMap,
               'data' : [{"dataMap": dataMapValue}],
               'version' : 1,
               'xInteger' : False,
               'yInteger' : False}

    return(outJSON)

def WriteROCJSON (targetVariable, targetEvent, roc_coordinate, debug = 'N'):
    _dict_DataRole_ = {'parameter': '_DataRole_', 'type': 'char', 'label': 'Data Role',
                       'length': 10, 'order': 1, 'values': ['_DataRole_'], 'preformatted': False}

    _dict_PartInd_ = {'parameter': '_PartInd_', 'type': 'num', 'label': 'Partition Indicator',
                      'length': 8, 'order': 2, 'values': ['_PartInd_'], 'preformatted': False}

    _dict_PartInd__f = {'parameter': '_PartInd__f', 'type': 'char', 'label': 'Formatted Partition',
                        'length': 12, 'order': 3, 'values': ['_PartInd__f'], 'preformatted': False}

    _dict_Column_ = {'parameter': '_Column_', 'type': 'num', 'label': 'Analysis Variable',
                   'length': 32, 'order': 4, 'values': ['_Column_'], 'preformatted': False}

    _dict_Event_ = {'parameter' : '_Event_', 'type' : 'char', 'label' : 'Event',
                    'length' : 8, 'order' : 5, 'values' : [ '_Event_' ], 'preformatted' : False}

    _dict_Cutoff_ = {'parameter' : '_Cutoff_', 'type' : 'num', 'label' : 'Cutoff',
                     'length' : 8, 'order' : 6, 'values' : [ '_Cutoff_' ], 'preformatted' : False}

    _dict_Sensitivity_ = {'parameter' : '_Sensitivity_', 'type' : 'num', 'label' : 'Sensitivity',
                          'length' : 8, 'order' : 7, 'values' : [ '_Sensitivity_' ], 'preformatted' : False}

    _dict_Specificity_ = {'parameter' : '_Specificity_', 'type' : 'num', 'label' : 'Specificity',
                          'length' : 8, 'order' : 8, 'values' : [ '_Specificity_' ], 'preformatted' : False}

    _dict_FPR_ = {'parameter' : '_FPR_', 'type' : 'num', 'label' : 'False Positive Rate',
                  'length' : 8, 'order' : 9, 'values' : [ '_FPR_' ], 'preformatted' : False}

    _dict_OneMinusSpecificity_ = {'parameter' : '_OneMinusSpecificity_', 'type' : 'num', 'label' : '1 - Specificity',
                                  'length' : 8, 'order' : 10, 'values' : [ '_OneMinusSpecificity_' ], 'preformatted' : False}

    parameterMap = {'_DataRole_': _dict_DataRole_, '_PartInd_': _dict_PartInd_, '_PartInd__f':  _dict_PartInd__f,
                    '_Column_': _dict_Column_, '_Event_': _dict_Event_, '_Cutoff_': _dict_Cutoff_,
                    '_Sensitivity_': _dict_Sensitivity_, '_Specificity_': _dict_Specificity_,
                    '_FPR_': _dict_FPR_, '_OneMinusSpecificity_': _dict_OneMinusSpecificity_}

    _list_roc_ = []
    irow = 0
    for index, row in roc_coordinate.iterrows():
        fpr = row['fpr']
        tpr = row['tpr']
        threshold = row['threshold']
        irow += 1
        _dict_roc_ = dict()

        _dict_stat = dict()
        _dict_stat.update(_DataRole_ = 'TRAIN')
        _dict_stat.update(_PartInd_ = 1)
        _dict_stat.update(_PartInd__f = '           1')
        _dict_stat.update(_Column_ = targetVariable)
        _dict_stat.update(_Event_ = targetEvent)
        _dict_stat.update(_Cutoff_ = threshold)
        _dict_stat.update(_Sensitivity_ = tpr)
        _dict_stat.update(_Specificity_ = (1.0 - fpr))
        _dict_stat.update(_FPR_ = fpr)
        _dict_stat.update(_OneMinusSpecificity_ = fpr)

        _dict_roc_.update(dataMap = _dict_stat, rowNumber = irow)
        _list_roc_.append(dict(_dict_roc_))

    outJSON = {'name' : 'dmcas_roc',
               'revision' : 0,
               'order' : 0,
               'parameterMap' : parameterMap,
               'data' : _list_roc_,
               'version' : 1,
               'xInteger' : False,
               'yInteger' : False}

    return(outJSON)

def WriteLiftJSON (targetVariable, targetEvent, lift_coordinate, debug = 'N'):

    _dict_DataRole_ = {'parameter': '_DataRole_', 'type': 'char', 'label': 'Data Role',
                       'length': 10, 'order': 1, 'values': ['_DataRole_'], 'preformatted': False}

    _dict_PartInd_ = {'parameter': '_PartInd_', 'type': 'num', 'label': 'Partition Indicator',
                      'length': 8, 'order': 2, 'values': ['_PartInd_'], 'preformatted': False}

    _dict_PartInd__f = {'parameter': '_PartInd__f', 'type': 'char', 'label': 'Formatted Partition',
                        'length': 12, 'order': 3, 'values': ['_PartInd__f'], 'preformatted': False}

    _dict_Column_ = {'parameter' : '_Column_', 'type' : 'char', 'label' : 'Analysis Variable',
                     'length' : 32, 'order' : 4, 'values' : [ '_Column_' ], 'preformatted' : False}

    _dict_Event_ = {'parameter' : '_Event_', 'type' : 'char', 'label' : 'Event',
                    'length' : 8, 'order' : 5, 'values' : [ '_Event_' ], 'preformatted' : False}

    _dict_Depth_ = {'parameter' : '_Depth_', 'type' : 'num', 'label' : 'Depth',
                    'length' : 8, 'order' : 7, 'values' : [ '_Depth_' ], 'preformatted' : False}

    _dict_NObs_ = {'parameter' : '_NObs_', 'type' : 'num', 'label' : 'Sum of Frequencies',
                   'length' : 8, 'order' : 8, 'values' : [ '_NObs_' ], 'preformatted' : False}

    _dict_Gain_ = {'parameter' : '_Gain_', 'type' : 'num', 'label' : 'Gain',
                   'length' : 8, 'order' : 9, 'values' : [ '_Gain_' ], 'preformatted' : False}

    _dict_Resp_ = {'parameter' : '_Resp_', 'type' : 'num', 'label' : '% Captured Response',
                   'length' : 8, 'order' : 10, 'values' : [ '_Resp_' ], 'preformatted' : False}

    _dict_CumResp_ = {'parameter' : '_CumResp_', 'type' : 'num',  'label' : 'Cumulative % Captured Response',
                      'length' : 8, 'order' : 11, 'values' : [ '_CumResp_' ], 'preformatted' : False}

    _dict_PctResp_ = {'parameter' : '_PctResp_', 'type' : 'num', 'label' : '% Response',
                      'length' : 8, 'order' : 12, 'values' : [ '_PctResp_' ], 'preformatted' : False}

    _dict_CumPctResp_ = {'parameter' : '_CumPctResp_', 'type' : 'num', 'label' : 'Cumulative % Response',
                         'length' : 8, 'order' : 13, 'values' : [ '_CumPctResp_' ], 'preformatted' : False}

    _dict_Lift_ = {'parameter' : '_Lift_', 'type' : 'num', 'label' : 'Lift',
                   'length' : 8, 'order' : 14, 'values' : [ '_Lift_' ], 'preformatted' : False}

    _dict_CumLift_ = {'parameter' : '_CumLift_', 'type' : 'num', 'label' : 'Cumulative Lift',
                      'length' : 8, 'order' : 15, 'values' : [ '_CumLift_' ], 'preformatted' : False}

    parameterMap = {'_DataRole_': _dict_DataRole_, '_PartInd_': _dict_PartInd_, '_PartInd__f': _dict_PartInd__f,
                    '_Column_': _dict_Column_, '_Event_': _dict_Event_, '_Depth_': _dict_Depth_,
                    '_NObs_': _dict_NObs_, '_Gain_': _dict_Gain_, '_Resp_': _dict_Resp_, '_CumResp_': _dict_CumResp_,
                    '_PctResp_': _dict_PctResp_, '_CumPctResp_': _dict_CumPctResp_,
                    '_Lift_': _dict_Lift_, '_CumLift_': _dict_CumLift_}

    _list_lift_ = []
    irow = 0
    for index, row in lift_coordinate.iterrows():
        decileN = row['Decile N']
        gainN = row['Gain N']
        gainPct = row['Gain %']
        responsePct = row['Response %']
        lift = row['Lift']

        acc_decilePct = row['Acc. Decile %']
        acc_gainPct = row['Acc. Gain %']
        acc_responsePct = row['Acc. Response %']
        acc_lift = row['Acc. Lift']

        irow += 1
        _dict_lift_train_ = dict()

        _dict_stat = dict()
        _dict_stat.update(_DataRole_ = 'TRAIN')
        _dict_stat.update(_PartInd_ = 1)
        _dict_stat.update(_PartInd__f = '           1')
        _dict_stat.update(_Column_ = targetVariable)
        _dict_stat.update(_Event_ = targetEvent)
        _dict_stat.update(_Depth_ = acc_decilePct)
        _dict_stat.update(_NObs_ = decileN)
        _dict_stat.update(_Gain_ = gainN)
        _dict_stat.update(_Resp_ = gainPct)
        _dict_stat.update(_CumResp_ = acc_gainPct)
        _dict_stat.update(_PctResp_ = responsePct)
        _dict_stat.update(_CumPctResp_ = acc_responsePct)
        _dict_stat.update(_Lift_ = lift)
        _dict_stat.update(_CumLift_ = acc_lift)

        _dict_lift_train_.update(dataMap = _dict_stat, rowNumber = irow)
        _list_lift_.append(dict(_dict_lift_train_))

    outJSON = {'name' : 'dmcas_lift',
               'revision' : 0,
               'order' : 0,
               'parameterMap' : parameterMap,
               'data' : _list_lift_,
               'version' : 1,
               'xInteger' : False,
               'yInteger' : False}

    return(outJSON)

# Create the fileMetadata.json file
fileMetadataJSON = pandas.DataFrame([['inputVariables', 'inputVar.json'],
                                     ['outputVariables', 'outputVar.json'],
                                     ['score', prefixModelFile + '_score.py'],
                                     ['python pickle', prefixModelFile + '.pickle']],
                                    columns = ['role', 'name'])

# STEP 5: Create the JSON files that will be zipped into a ZIP file

# Write inputVar.json
inputVarJSON = WriteVarJSON (trainData[catName+intName], debug = 'N')
jFile = open(analysisFolder + 'inputVar.json', 'w')
json.dump(list(pandas.DataFrame.to_dict(inputVarJSON.transpose()).values()), jFile, indent = 4, skipkeys = True)
jFile.close()

# Write outputVar.json
outputVarJSON = WriteVarJSON (outputVar, debug = 'N')
jFile = open(analysisFolder + 'outputVar.json', 'w')
json.dump(list(pandas.DataFrame.to_dict(outputVarJSON.transpose()).values()), jFile, indent = 4, skipkeys = True)
jFile.close()

# Write fileMetadata.json
jFile = open(analysisFolder + 'fileMetadata.json', 'w')
json.dump(list(pandas.DataFrame.to_dict(fileMetadataJSON.transpose()).values()), jFile, indent = 4, skipkeys = True)
jFile.close()

# Write ModelProperties.json
modelPropertyJSON = WriteClassModelPropertiesJSON ('Home Equity Loan XGBoost', 'XGBoost Model',
                                                   yName, 'Gradient boosting', catName + intName,
                                                   y_category[1].astype('str'), nYCat, 'EM_EVENTPROBABILITY')
jFile = open(analysisFolder + 'ModelProperties.json', 'w')
json.dump(pandas.Series.to_dict(modelPropertyJSON), jFile, indent = 4, skipkeys = True)
jFile.close()

# Write dmcas_fitstat.json
fitstatJSON = WriteFitStatJSON (fitStats)
jFile = open(analysisFolder + 'dmcas_fitstat.json', 'w')
json.dump(fitstatJSON, jFile, indent = 4, skipkeys = True)
jFile.close()

# Write dmcas_roc.json
rocJSON = WriteROCJSON (yName, y_category[1].astype('str'), y_roc)
jFile = open(analysisFolder + 'dmcas_roc.json', 'w')
json.dump(rocJSON, jFile, indent = 4, skipkeys = True)
jFile.close()

# Write dmcas_lift.json
acc_stat_name = ['Acc. Decile %', 'Acc. Gain %', 'Acc. Response %', 'Acc. Lift']
y_lift[acc_stat_name] = y_acc_lift[acc_stat_name]

liftJSON = WriteLiftJSON (yName, y_category[1].astype('str'), y_lift)
jFile = open(analysisFolder + 'dmcas_lift.json', 'w')
json.dump(liftJSON, jFile, indent = 4, skipkeys = True)
jFile.close()

# Open a writable binary file for saving the pickle object
pFile = open(analysisFolder + prefixModelFile + '.pickle', 'wb')
pickle.dump(thisFit, pFile)
pFile.close() 

# Create the zip file package (without the full path name)
zFile = zipfile.ZipFile(analysisFolder + prefixModelFile + '.zip', mode = 'w')
zFile.write(analysisFolder + 'inputVar.json', 'inputVar.json')
zFile.write(analysisFolder + 'outputVar.json', 'outputVar.json')
zFile.write(analysisFolder + 'ModelProperties.json', 'ModelProperties.json')
zFile.write(analysisFolder + 'fileMetadata.json', 'fileMetadata.json')
zFile.write(analysisFolder + 'dmcas_fitstat.json', 'dmcas_fitstat.json')
zFile.write(analysisFolder + 'dmcas_roc.json', 'dmcas_roc.json')
zFile.write(analysisFolder + 'dmcas_lift.json', 'dmcas_lift.json')
zFile.write(analysisFolder + prefixModelFile + '_score.py', prefixModelFile + '_score.py')
zFile.write(analysisFolder + prefixModelFile + '.pickle', prefixModelFile + '.pickle')
zFile.close()