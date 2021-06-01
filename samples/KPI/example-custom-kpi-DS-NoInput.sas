/*------------------------------------------------------------------------------------------------
  Name:     example-custom-kpi-DS-NoInput.sas                                                         
  Purpose:  Demonstrates how you can write a custom KPI script using DATA step.                       
--------------------------------------------------------------------------------------------------
  Note:     
    The following example enables you to create a custom KPI 'VIF'.                 
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
length ProjectUUID varchar(36);
length Datetime 8;
length TimeSK 8;
length VIF 8;
ProjectUUID='HMEQ-Classification';
Datetime = datetime();
TimeSK=1;
VIF = 0.82;
output;
TimeSK=2;
VIF = 0.63;
output;
format Datetime NLDATM50.;
