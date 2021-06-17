/*************************************************************/
/******************* Gathering information *******************/
/*************************************************************/

/* Number of performance tables */
%let tbl_num = 4;

/* Performance table prefix */
%let _MM_Perf_InTablePrefix = FRAUDPERF;

/* Performance table time label */
%let time_label = Q;

/* Performance table CASLib */
%let _MM_PerfInCaslib = Public;

/* Project ID */
%let _MM_ProjectUUID = %nrstr(XXXXXXXX); /* Can be taken directly from performance code */

/* Model ID */
%let _MM_ModelID = %nrstr(XXXXXXXX); /* Can be taken directly from performance code */

/* Score code URI */
%let _MM_ScoreCodeURI = /files/files/XXXXXXXX; /* Can be taken directly from performance code */

/* Astore location */ 
%let _MM_aStoreLocation=_XXXXXXXX; /* Can be taken directly from performance code */

/* For distribution */
%let dist_cent = 500;
%let db_points = 10;



/*************************************************************/
/************ Build connection to CAS and CASLibs ************/
/*************************************************************/
options cashost='sas-cas-server-default-client' casport=5570 validvarname=any; 

cas _mmcas_ cassessopts=(caslib="Public");

caslib _all_ assign;

libname _outlib cas caslib="Public" sessref=_mmcas_;
libname _mstore cas caslib="MODELSTORE" sessref=_mmcas_;
libname _inlib cas caslib="Public" sessref=_mmcas_;

filename srcEp filesrvc "&_MM_ScoreCodeURI";
filename epCode temp;


/*************************************************************/
/* Create macro program to generate custom performance data **/
/*************************************************************/

%macro create_tbls;

/* Loading ASTORE into memory if it isn't already */
proc cas;
	session _mmcas_;
	table.tableExists result=e /
	name="&_MM_aStoreLocation";
	haveTable = dictionary(e, "exists");
	if haveTable < 1 then do;
		table.loadTable result=r /
		caslib="ModelStore"
		casOut={caslib="ModelStore", name="&_MM_aStoreLocation"}
		path="&_MM_aStoreLocation..sashdat";
	end;
run;

/* Loop through all performance tables */
%do I = 1 %to &tbl_num;

	/* Specify table names */
	%let in_tbl = &_mm_perf_intableprefix._&I._&time_label.&I;
	%let out_tbl = temp&I;

	/* Load epcode file */
	data _null_;
		infile srcEp length=len recfm=f _infile_=tmp;
		file epCode recfm=n;
		input;
		put tmp $varying32767. len;
	run;	

	options VALIDMEMNAME=EXTEND VALIDVARNAME=ANY;

	/* Prepare input table */
	proc ds2 sessref=_mmcas_;
		data temp_1623093246714_5;
		method run();
		;   set "Public".&in_tbl;
		end;
		enddata;
	run;
	quit;

	/* Score table */
	proc astore;
		score data=_inlib.temp_1623093246714_5 out=casuser.temp_scored
		epcode=epCode 
		rstore=_mstore.&_MM_aStoreLocation;
	run;

	/* Bucket model predictions */
	data casuser.temp_bucket;
		set casuser.temp_scored;
		length score  $ 10;
		target = (FRAUD_LABEL=1);
		prob = EM_EVENTPROBABILITY;
		odds = prob / (1-prob);
		score_value = &dist_cent + ((&db_points/log(2))*log(odds));	
		if score_value < 320 then score = '< 320'; 
		else if score_value < 340 then score = '320 - <340';
		else if score_value < 360 then score = '340 - <360';
		else if score_value < 380 then score = '360 - <380';
		else if score_value < 400 then score = '380 - <400';
		else if score_value < 420 then score = '400 - <420';
		else if score_value < 440 then score = '420 - <440';
		else if score_value < 460 then score = '440 - <460';
		else if score_value < 480 then score = '460 - <480';
		else if score_value < 500 then score = '480 - <500';
		else if score_value < 520 then score = '500 - <520';
		else if score_value < 540 then score = '520 - <540';
		else if score_value < 560 then score = '540 - <560';
		else if score_value < 580 then score = '560 - <580';
		else score = '>= 580';
		keep target score;
	run; 
	
	/* Group by prediction buckets */ 
	PROC FEDSQL SESSREF=_mmcas_;
		CREATE TABLE CASUSER."temp_grouped" AS
			SELECT
				(t1."score") AS "Bucket",
				(SUM(t1.target)) AS "Fraud_Count",
				(COUNT(t1.target)) AS "Total_Count"
			FROM
				CASUSER."TEMP_BUCKET" t1
			GROUP BY
				t1."score"
		;
	QUIT;
	RUN;	

	/* Create output table */ 
	%let timeLabel = &time_label.&I;

	data casuser.&out_tbl;
		set casuser.temp_grouped;
		Genuine_Count = Total_Count-Fraud_Count;
		TimeSK = &I;
		TimeLabel = "&timeLabel";
	run; 

	/* Drop temporary tables */
	proc casutil;
		droptable casdata="temp_grouped" incaslib="casuser" quiet;
		droptable casdata="temp_bucket" incaslib="casuser" quiet;
		droptable casdata="temp_scored" incaslib="casuser" quiet;
		droptable casdata='TEMP_1623093246714_5' incaslib='public' quiet;
	run;
%end; 
%mend create_tbls;

%create_tbls;

/*************************************************************/
/******** Append results into single performance table *******/
/*************************************************************/

/* Appended each quarter of data */
data casuser.fraud_kpi;
	set casuser.temp1 
		casuser.temp2
		casuser.temp3
		casuser.temp4;
run; 

/* Drop individual tables and promote final table */
proc casutil;
	droptable casdata="temp1" incaslib="casuser" quiet;
	droptable casdata="temp2" incaslib="casuser" quiet;
	droptable casdata="temp3" incaslib="casuser" quiet;
	droptable casdata="temp4" incaslib="casuser" quiet;
	promote casdata="fraud_kpi" incaslib="casuser" outcaslib="casuser"
	     casout="fraud_kpi";
run;

/*************************************************************/
/********* Add custom KPI table using provided macro *********/
/*************************************************************/

%mm_kpi_actionSet;

proc cas;
	_projectID = "&_MM_ProjectUUID.";
	mmkpi.addCustomKPI result=r /
		kpiTable = {caslib='casuser', name='FRAUD_KPI'}
		projectUUID = _projectID
		;
	run;
quit;


/* Terminate session */
cas _mmcas_ terminate;





	


 
