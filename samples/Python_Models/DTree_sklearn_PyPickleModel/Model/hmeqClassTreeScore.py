# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0


# %%
# import libraries
import math
import numpy as np
import pandas as pd
import pickle
import settings

# %%
def scoreHMEQClassTreeModel(JOB, REASON, CLAGE, CLNO, DEBTINC, DELINQ, DEROG, NINQ):
    "Output: EM_EVENTPROBABILITY, EM_CLASSIFICATION"
    
    try:
        _thisModelFit
    except NameError:
        with open(settings.pickle_path + "hmeqClassTree.pickle", "rb") as _pFile:
            _thisModelFit = pickle.load(_pFile)
            
    # Threshold for the misclassification error (BAD: 0-No, 1-Yes)
    _threshPredProb = 0.08941485864562787

    # Impute the overall median for missing values
    if (math.isnan(CLAGE)):
        CLAGE = 173.46666666666600

    if (math.isnan(CLNO)):
        CLNO = 20.0

    if (math.isnan(DEBTINC)):
        DEBTINC = 34.81826181858690

    # Impute the overall mode for missing values
    if (math.isnan(DEROG)):
        DEROG = 0.0

    if (math.isnan(NINQ)):
        NINQ = 0.0

    if (JOB == None):
        cStr = "Other"
    else:
        cStr = JOB.strip()
        if (not cStr):
            cStr = "Other"

    JOB_Mgr = np.where(cStr == "Mgr", 1.0, 0.0)
    JOB_Office = np.where(cStr == "Office", 1.0, 0.0)
    JOB_Other = np.where(cStr == "Other", 1.0, 0.0)
    JOB_ProfExe = np.where(cStr == "ProfExe", 1.0, 0.0)
    JOB_Sales = np.where(cStr == "Sales", 1.0, 0.0)
    JOB_Self = np.where(cStr == "Self", 1.0, 0.0)

    if (REASON == None):
        cStr = "DebtCon"
    else:
        cStr = REASON.strip()
        if (not cStr):
            cStr = "DebtCon"

    REASON_DebtCon = np.where(REASON == 'DebtCon', 1.0, 0.0)
    REASON_HomeImp = np.where(REASON == 'HomeImp', 1.0, 0.0)

    # Construct the input array for scoring (the first term is for the Intercept)
    inputArray = pd.DataFrame([[JOB_Mgr, JOB_Office,
                                 JOB_Other, JOB_ProfExe,
                                 JOB_Sales, JOB_Self,
                                 REASON_DebtCon, REASON_HomeImp,
                                 CLAGE, CLNO, DEBTINC,
                                 DELINQ, DEROG, NINQ]],
                               columns = ["JOB_Mgr", "JOB_Office",
                                          "JOB_Other", "JOB_ProfExe",
                                          "JOB_Sales", "JOB_Self",
                                          "REASON_DebtCon", "REASON_HomeImp",
                                          "CLAGE", "CLNO", "DEBTINC",
                                          "DELINQ", "DEROG", "NINQ"],
                               dtype = float)

    # Calculate the predicted probabilities
    _predProb = _thisModelFit.predict_proba(inputArray)

    # Retrieve the event probability
    EM_EVENTPROBABILITY = float(_predProb[:,1])

    # Determine the predicted target category
    if (EM_EVENTPROBABILITY >= _threshPredProb):
        EM_CLASSIFICATION = "1"
    else:
        EM_CLASSIFICATION = "0"

    return(EM_EVENTPROBABILITY, EM_CLASSIFICATION)
