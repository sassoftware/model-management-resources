/*================================================================================================
  Name:     example-custom-kpi-DS-Input.sas                                                         
  Purpose:  Demonstrates how you can write a custom KPI script with DATA step.                        
--------------------------------------------------------------------------------------------------   
    The following example enables you to create a custom KPI 'KsStatistic' from the monitoring results table mm_ks.                 
    You can use valid DATA step code to create your own custom KPI.
    The input table and output table do not need to be specified in your DATA step code.
    
    The input and output table can be passed using the following the action parameters:
    
      inputTable  - the input table, CASTABLE, Optional
      outputTable - the output table, CASOUTTABLE, Required
    
    If your code does not include an input table, then the code simply assigns a KPI value, just like this example.
--------------------------------------------------------------------------------------------------
  Limitations:
    - Only one data action can be included in the code.
    - Only one output table can be created.
                        
================================================================================================*/
/* data customKPI; */
/* set <porjectUUID>.mm_ks; */
by TimeSK;
length Datetime 8;
Datetime = datetime();
if first.TimeSK then do;
  output;
end;
keep ProjectUUID TimeLabel TimeSK Datetime  KsStatistic;