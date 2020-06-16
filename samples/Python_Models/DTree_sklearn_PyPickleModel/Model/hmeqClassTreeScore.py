import math
import pickle
import pandas as pd
import numpy as np
import settings

def scorehmeqClassTree(REASON, JOB, YOJ, DEROG, DELINQ, CLAGE, NINQ, CLNO, DEBTINC):
    "Output: EM_EVENTPROBABILITY, EM_CLASSIFICATION"

    try:
        _thisModelFit
    except NameError:
        with open(settings.pickle_path + 'hmeqClassTree.pickle', 'rb') as _pFile:
            _thisModelFit = pickle.load(_pFile)

    try:
        categoryStr = REASON.strip()
    except AttributeError:
        categoryStr = 'Other'

    REASON_HomeImp = np.where(categoryStr == 'HomeImp', 1.0, 0.0)
    REASON_DebtCon = np.where(categoryStr == 'DebtCon', 1.0, 0.0)

    try:
        categoryStr = JOB.strip()
    except AttributeError:
        categoryStr = 'Other'

    JOB_Other = np.where(categoryStr == 'Other', 1.0, 0.0)
    JOB_Office = np.where(categoryStr == 'Office', 1.0, 0.0)
    JOB_Sales = np.where(categoryStr == 'Sales', 1.0, 0.0)
    JOB_Mgr = np.where(categoryStr == 'Mgr', 1.0, 0.0)
    JOB_ProfExe = np.where(categoryStr == 'ProfExe', 1.0, 0.0)
    JOB_Self = np.where(categoryStr == 'Self', 1.0, 0.0)

    try:
        if math.isnan(YOJ):
            YOJ = 8.922268135904499
    except TypeError:
        YOJ = 8.922268135904499

    try:
        if math.isnan(DEROG):
            DEROG = 0.2545696877380046
    except TypeError:
        DEROG = 0.2545696877380046

    try:
        if math.isnan(DELINQ):
            DELINQ = 0.4494423791821561
    except TypeError:
        DELINQ = 0.4494423791821561

    try:
        if math.isnan(CLAGE):
            CLAGE = 179.76627518656605
    except TypeError:
        CLAGE = 179.76627518656605

    try:
        if math.isnan(NINQ):
            NINQ = 1.1860550458715597
    except TypeError:
        NINQ = 1.1860550458715597

    try:
        if math.isnan(CLNO):
            CLNO = 21.29609620076682
    except TypeError:
        CLNO = 21.29609620076682

    try:
        if math.isnan(DEBTINC):
            DEBTINC = 33.77991534872112
    except TypeError:
        DEBTINC = 33.77991534872112

    inputArray = pd.DataFrame([[1.0, YOJ, DEROG, DELINQ, CLAGE, NINQ, CLNO, DEBTINC, REASON_HomeImp, REASON_DebtCon, JOB_Other, JOB_Office, JOB_Sales, JOB_Mgr, JOB_ProfExe, JOB_Self]],
                              columns = ['const', 'YOJ', 'DEROG', 'DELINQ', 'CLAGE', 'NINQ', 'CLNO', 'DEBTINC', 'REASON_HomeImp', 'REASON_DebtCon', 'JOB_Other', 'JOB_Office', 'JOB_Sales', 'JOB_Mgr', 'JOB_ProfExe', 'JOB_Self'],
                              dtype = float)

    prediction = _thisModelFit.predict(inputArray)

    EM_EVENTPROBABILITY = float(prediction)

    if (EM_EVENTPROBABILITY >= 0.199496644295302):
        EM_CLASSIFICATION = '1'
    else:
        EM_CLASSIFICATION = '0' 

    return(EM_EVENTPROBABILITY, EM_CLASSIFICATION)