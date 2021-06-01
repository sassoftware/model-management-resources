/*================================================================================================
  Name:     example-custom-kpi-CASL.sas                                                         
  Purpose:  Demonstrates how a user can write a custom KPI script with CASL.                       
  Note: 
--------------------------------------------------------------------------------------------------    
    The following example calculates the custom KPI GiniDecay from SAS Model Manager
    performance monitoring results table "<projectUUID>.mm_roc".                    
    The sample code is written in CASL. You can use valid CASL code to create your own custom KPI code.
    However, the PROC CAS statement and QUIT statement cannot be used.
    To provide more flexibility, you can use the following action parameters in your own code :
    
      projectUUID - the projectUUID, STRING, Optional
      inputTable  - the input table, CASTABLE, Optional
      outputTable - the output table, CASOUTTABLE, Required
    
    For example, you can use InputTable.name to get the input table name
    and InputTable.caslib to get the input caslib.                       
================================================================================================*/
/* proc cas; */
function cfunc_ginidecay(timeSK,inCaslib,srcTable);

  _kpivar={'GiniIndex'};
  _groupby={'TimeSK'};
  _wherestr='TimeSK in (' || '1,' || timeSK || ');';

  
  simple.groupBy status=s result = r /
    aggregator='MAX'
    table={
      name = srcTable
      caslib = inCaslib
      where=_wherestr
      vars=_groupby + _kpivar
    }
;  

describe r;

_last_row = r.GroupBy.nrows;
_base = r.Groupby[1, _kpivar][1];
_curr = r.Groupby[_last_row,_kpivar][1];

if _base > 0 then _decay = (_base - _curr) / _base;
else _decay = 0;

print 'GiniDecay = (' _base ' - ' _curr ') / ' _base;
print 'GiniDecay = ' _decay; 

return _decay;
end;

/* create a CASL result table */
_cols = {'ProjectUUID','Datetime','TimeSK','GiniDecay'};
_ctypes = {'STRING','DATETIME','INT64','DOUBLE'};
_user_table = newtable('MM_USER_GiniDECAY', _cols, _ctypes);

/* insert data */

datetime = datetime();
incaslib = inputTable.caslib;
srcTable = inputTable.name;
timeSK={1,2};

do t over timeSK;
  _kpi = cfunc_ginidecay(t,incaslib,srcTable);
  _row = {projectUUID, datetime, t, _kpi};
  addrow(_user_table,_row);
end;

describe _user_table;
saveresult _user_table casout=outputTable.name caslib=outputTable.caslib replace;

/* modify column attribute as need */
table.alterTable status=s2 /
    columns= {
      {name='ProjectUUID', label='Project UUID'}
      {name='Datetime',format='NLDATM50', label='Created Datetime'}
      {name='TimeSK', label='Time Sequence Key'}
      {name='GiniDecay', label='Gini Decay'}
    }
    caslib = outputTable.caslib
    name = outputTable.name;   

/* run ; */
/* quit ; */

