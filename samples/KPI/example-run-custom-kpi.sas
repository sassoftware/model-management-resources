cas _mmcas_;
caslib _ALL_ assign;

%let projectUUID = %nrstr(HMEQ-Classification);
libname mmkpi cas caslib="ModelPerformanceData" tag="&projectUUID.";

%mm_kpi_actionSet;

/* 
   Run the custom KPI code that is written in DATA step code 
   and specify a value for the inputTable parameter.
*/

filename kpifile filesrvc "/files/files/<KPI-file-UUID>";
filename kpicode temp;
%let x=%sysfunc(fcopy(kpifile, kpicode));

proc cas;

  builtins.loadactionset / 
    actionSet = 'mmkpi'
  ;

  projectID = "&projectUUID.";
  code = readfile('kpicode');

  casin =  {
      caslib = 'ModelPerformanceData',
      name = projectID || '.mm_ks'
  };

  casout = {
      caslib = 'casuser',
      name = 'Custom_KPI'
  };

  mmkpi.runCustomKPI result=r status=s /
    customKPICode = code 
    codeType ='DS'
    inputTable = casin
    outputTable = casout
    debug=True
  ;
  print _status;

  if (_status.severity) ==0 then do;
    mmkpi.addCustomKPI status=s /
      kpiTable = casout
      projectUUID = projectID
      ; 
  end;

run;
quit;

/* 
   Run the custom KPI code that is written in DATA step code 
   with no value specified for the inputTable parameter.
*/
filename kpifile filesrvc "/files/files/<KPI-file-UUID>";
filename kpicode temp;
%let x=%sysfunc(fcopy(kpifile, kpicode));

proc cas;

  builtins.loadactionset / 
    actionSet = 'mmkpi'
  ;

  projectID = "&projectUUID.";
  code = readfile('kpicode');

  casout = {
      caslib = 'casuser',
      name = 'Custom_KPI'
  };

  mmkpi.runCustomKPI result=r status=s /
    customKPICode = code 
    codeType ='DS'
    outputTable = casout
    debug=True
  ;
  print _status;

  if (_status.severity) ==0 then do;
    mmkpi.addCustomKPI status=s /
      kpiTable = casout
      projectUUID = projectID
      ; 
  end;

run;
quit;


/* Run the custom KPI code that is written in CASL. */
filename kpifile filesrvc "/files/files/<KPI-file-UUID>";
filename kpicode temp;
%let x=%sysfunc(fcopy(kpifile, kpicode));


proc cas;

  builtins.loadactionset / 
    actionSet = 'mmkpi'
  ;

  projectID = "&projectUUID.";
  code = readfile('kpicode');

  casin =  {
      caslib = 'ModelPerformanceData',
      name = projectID || '.mm_roc'
  };

  casout = {
      caslib = 'casuser',
      name = 'Custom_KPI_CASL'
  };

  mmkpi.runCustomKPI result=r status=s /
    projectUUID = projectID
    customKPICode = code 
    codeType ='CASL'
    inputTable = casin
    outputTable = casout
    debug=True
  ;
  print _status;

  if (_status.severity) ==0 then do;
    mmkpi.addCustomKPI status=s /
      kpiTable = casout
      projectUUID = projectID
      ; 
  end;

run;
quit;