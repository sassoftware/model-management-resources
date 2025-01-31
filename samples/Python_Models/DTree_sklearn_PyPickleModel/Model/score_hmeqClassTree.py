import math
import pickle
import pandas as pd
import numpy as np
from pathlib import Path

import settings

with open(Path(settings.pickle_path) / "hmeqClassTree.pickle", "rb") as pickle_model:
    model = pickle.load(pickle_model)

def score(JOB_Mgr, JOB_Office, JOB_Other, JOB_ProfExe, JOB_Sales, JOB_Self, REASON_DebtCon, REASON_HomeImp, CLAGE, CLNO, DEBTINC, DELINQ, DEROG, NINQ, YOJ):
    "Output: EM_EVENTPROBABILITY, EM_CLASSIFICATION"

    try:
        global model
    except NameError:
        with open(Path(settings.pickle_path) / "hmeqClassTree.pickle", "rb") as pickle_model:
            model = pickle.load(pickle_model)


    index=None
    if not isinstance(JOB_Mgr, pd.Series):
        index=[0]
    input_array = pd.DataFrame(
        {"JOB_Mgr": JOB_Mgr, "JOB_Office": JOB_Office, "JOB_Other": JOB_Other,
        "JOB_ProfExe": JOB_ProfExe, "JOB_Sales": JOB_Sales, "JOB_Self": JOB_Self,
        "REASON_DebtCon": REASON_DebtCon, "REASON_HomeImp": REASON_HomeImp, "CLAGE":
        CLAGE, "CLNO": CLNO, "DEBTINC": DEBTINC, "DELINQ": DELINQ, "DEROG": DEROG,
        "NINQ": NINQ, "YOJ": YOJ}, index=index
    )
    input_array = impute_missing_values(input_array)
    prediction = model.predict_proba(input_array).tolist()

    # Check for numpy values and convert to a CAS readable representation
    if isinstance(prediction, np.ndarray):
        prediction = prediction.tolist()

    if input_array.shape[0] == 1:
        if prediction[0][1] > 0.5:
            EM_EVENTPROBABILITY = "1"
        else:
            EM_EVENTPROBABILITY = "0"
        return EM_EVENTPROBABILITY, prediction[0][1]
    else:
        df = pd.DataFrame(prediction)
        proba = df[1]
        classifications = np.where(df[1] > 0.5, '1', '0')
        return pd.DataFrame({'EM_EVENTPROBABILITY': classifications, 'EM_CLASSIFICATION': proba})

def impute_missing_values(data):
    impute_values = \
        {'DEBTINC': np.float64(33.93743100224461), 'YOJ': np.float64(9.029266572637518),
        'DEROG': np.float64(0.15479548660084627), 'NINQ':
        np.float64(1.0253878702397743), 'CLNO': np.float64(21.916784203102964), 'CLAGE':
        np.float64(182.05155708750038), 'DELINQ': np.float64(0.2782087447108604),
        'JOB_Mgr': np.False_, 'JOB_Office': np.False_, 'JOB_Other': np.False_,
        'JOB_ProfExe': np.False_, 'JOB_Sales': np.False_, 'JOB_Self': np.False_,
        'REASON_DebtCon': np.True_, 'REASON_HomeImp': np.False_}
    return data.replace('           .', np.nan).fillna(impute_values).apply(pd.to_numeric, errors='ignore')
