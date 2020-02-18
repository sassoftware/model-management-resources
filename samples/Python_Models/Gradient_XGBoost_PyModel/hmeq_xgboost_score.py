# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0


import math
import numpy
import pandas
import pickle
import settings

def scoreHMEQXGBoostModel (JOB, REASON, CLAGE, CLNO, DEBTINC, DELINQ, DEROG, NINQ, YOJ):
    "Output: EM_EVENTPROBABILITY, EM_CLASSIFICATION"

    try:
       _thisModelFit
    except NameError:
        with open(settings.pickle_path + "hmeq_xgboost.pickle", 'rb') as _pFile:
            _thisModelFit = pickle.load(_pFile)


    # Impute the overall median for missing values
    
    try:
        if math.isnan(CLAGE):
            CLAGE = 173.46666666666600
    except TypeError:
        CLAGE = 173.46666666666600
        
    try:
        if math.isnan(CLNO):
            CLNO = 20.0
    except TypeError:
        CLNO = 20.0
        
    try:
        if math.isnan(DEBTINC):
            DEBTINC = 34.81826181858690
    except TypeError:
        DEBTINC = 34.81826181858690
        
    try:
        if math.isnan(DELINQ):
            DELINQ = 0.45
    except TypeError:
        DELINQ = 0.45
        
    try:
        if math.isnan(YOJ):
            YOJ = 8.96954921803128
    except TypeError:
        YOJ = 8.96954921803128
        
    try:
        if math.isnan(DEROG):
            DEROG = 0.0
    except TypeError:
        DEROG = 0.0
        
    try:
        if math.isnan(NINQ):
            NINQ = 0.0
    except TypeError:
        NINQ = 0.0

    try:
        cStr = JOB.strip()
    except AttributeError:
        cStr = 'Other'
        
    JOB_Mgr = numpy.where(cStr == "Mgr", 1.0, 0.0)
    JOB_Office = numpy.where(cStr == "Office", 1.0, 0.0)
    JOB_Other = numpy.where(cStr == "Other", 1.0, 0.0)
    JOB_ProfExe = numpy.where(cStr == "ProfExe", 1.0, 0.0)
    JOB_Sales = numpy.where(cStr == "Sales", 1.0, 0.0)
    JOB_Self = numpy.where(cStr == "Self", 1.0, 0.0)

    try:
        cStr = REASON.strip()
    except AttributeError:
        cStr = 'DebtCon'
        
    REASON_DebtCon = numpy.where(cStr == "DebtCon", 1.0, 0.0)

    # Construct the input array for scoring
    input_array = pandas.DataFrame([[JOB_Mgr, JOB_Office, JOB_Other, JOB_ProfExe, JOB_Sales, JOB_Self, \
                                     REASON_DebtCon, CLAGE, CLNO, DEBTINC, DELINQ, DEROG, NINQ, YOJ]],
        columns = ["JOB_Mgr", "JOB_Office", "JOB_Other", "JOB_ProfExe", "JOB_Sales", "JOB_Self", \
                   "REASON_DebtCon", "CLAGE", "CLNO", "DEBTINC", "DELINQ", "DEROG", "NINQ", "YOJ"],
        dtype = float)

    # Calculate the predicted probabilities 
    _predProb = _thisModelFit.predict_proba(input_array).astype(numpy.float64)

    # Retrieve the event probability
    EM_EVENTPROBABILITY = float(_predProb[:,1])

    # Determine the predicted target category
    if (EM_EVENTPROBABILITY >= 0.08941485864562787):
        EM_CLASSIFICATION = "1"
    else:
        EM_CLASSIFICATION = "0"

    return(EM_EVENTPROBABILITY, EM_CLASSIFICATION)
