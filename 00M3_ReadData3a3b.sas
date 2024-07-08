%let sharefolder=T:\OCA_Admin\ACR-Select\Toni;
%let includedir=&sharefolder.;
%include "&includedir.\Include_Setup.sas" /*/source2 */;
/******Varlist for Ms3 file ******/
%include "&includedir.\Include_RevModelVarlist.sas" /*/source2 */;
%include "&includedir.\Include_LocModelVarlist.sas" /*/source2 */;



/** cleaned master file, filtered with  */
/** CASE_PROGRESS)="COMPLETE") and (upcase(CASE_TYPE) = "OR CASE") and (upcase(CASE_CLASS) = "C. SCHEDULED"))
/** date filtered (req_date2 >= '04May2023'd ) OR (req_date3 >= '04May2023'd) */
/** create var categorize     cases requested @ ASC (ASC_req) vs. non ASC*/
/** create var categorize ASC cases requested @ KEC (kec_req) vs non KEC*/
/** create var categorize ASC cases performed @ ASC (ASC_req) vs. non ASC*/
/** create var categorize ASC cases performed @ KEC (kec_req) vs non KEC*/

/* read in the clean master file: 46,238 observations, 32 var*/
data master_Ms3_a01;
set outfile.master_keep ;
ASC_req=0;
if upcase(REQ_LOC) in ("BCSC OR", "EASC OR", "KEC OR", "LCSC OR") then ASC_req=1;
KEC_req=0;
if upcase(REQ_LOC) in ("KEC OR") then KEC_req=1;
ASC_perf=0;
if upcase(CURRENT_SCHED_LOC) in ("BCSC OR", "EASC OR", "KEC OR", "LCSC OR") then ASC_perf=1;
KEC_perf=0;
if upcase(CURRENT_SCHED_LOC) in ("KEC OR") then KEC_perf=1;
run;


/* 16,830 observations  and 5 variables. ASC=1 cases*/
/** master file: reduce size by ASC, date */ 
/** keep only ASC cases */
data master_Ms3_a02 (keep=or_case_id ASC_req KEC_req ASC_perf KEC_perf) ;
set  master_Ms3_a01;
if ASC_req=1;
run;

/****** read in RevFeature:  64934 observations and 43 variable,tbl: review_features_wide-2024-05-07.csv */
PROC IMPORT DATAFILE="&ReadInPath.\&RevFeature."
            OUT=RevFeature  /*name of the sas data */  
            DBMS=CSV REPLACE;
            GETNAMES=YES; 	/*take the var names from csv header */
RUN;


/****** read in LocFeature:  64201 observations and 42 variable, tbl: location_features_wide-2024-05-07.csv */
PROC IMPORT DATAFILE="&ReadInPath.\&LocFeature."
            OUT=LocFeature  /*name of the sas data */  
            DBMS=CSV REPLACE;
            GETNAMES=YES; 	/*take the var names from csv header */
RUN;


/****** read in Loc model's random effect H, 1429 observations and 2 variables, tble: location_params_combo_17Jan2023_v4.xlsx */
PROC IMPORT DATAFILE="&ReadInPath.\&RandomHLoc."
            OUT=RandomHLoc  /*name of the sas data */  
            DBMS=xlsx REPLACE;
			sheet="h";		/*pick the right tab */
            GETNAMES=YES; 	/*take the var names from csv header */
RUN;

proc sql;
	select
		count(distinct or_case_id) as case_cnt
	from RandomHLoc
;
quit;

/* Rev Model: dedup for the same case and procID */
proc sort data=RevFeature out=RevFeature_s;
by or_case_id ProcID descending score_calc_utc_dttm;
run;

/*Rev Model: 43915 observations and 43 variable */
data RevFeature_dedup;
set RevFeature_s;
by or_case_id ProcID descending score_calc_utc_dttm;
if first.ProcID;
run;

/* Loc Model: dedup for the same case and procID */
proc sort data=LocFeature out=LocFeature_s;
by or_case_id ProcID descending score_calc_utc_dttm;
run;

/* Loc Model: 43925 observations and 42 variables */
data LocFeature_dedup;
set LocFeature_s;
by or_case_id ProcID descending score_calc_utc_dttm;
if first.ProcID;
run;


/*proc_id table created in Ms2, 93 procID performed @KEC observations and 3 variable */
/*format: proc_id format */
data kec_perform_procID_01;
set outfile.kec_perform_procID (drop=case_id_cn kec_cnt );
procID_char=strip(put(proc_id, 6.));
kec_procID=1;
run;

/*format 2vars: or_case_id & ProcID,Rev model features,43,915 observations and 46 variables */
data RevFeature_01;
set RevFeature_dedup;
or_case_id_char=strip(put(or_case_id, 9.));
procID_char=strip(put(ProcID, 6.));
RevModelCase=1;
run;

/*format 2vars: or_case_id & ProcID,Loc model features,, 43,925 observations and 45 variables */
data LocFeature_01;
set LocFeature_dedup;
or_case_id_char=strip(put(or_case_id, 9.));
procID_char=strip(put(ProcID, 6.));
LocModelCase=1;
run;


/* Rev model tbl: Evaluate cat and cont vars by KEC_req (0 or 1) */
/* inner join: 5475 rows and 50 columns ~ use inner for this analysis.  */
/* left join: 16,901 rows and 50 columns, there were 16,830 ASC cases, RevFeature tbl has >1 procID for the same Case_id */
proc sql;
	create table feature_R_01 as
	select
		a.*,
		b.*	
	from master_Ms3_a02 as a
	inner join RevFeature_01 as b
		on a.or_case_id=b.or_case_id_char
	;
quit;

/* left join:   5475 rows and 52 columns ~ use left for this analysis.  */
/* purpose of this step: identify the KEC-performed procID */
/* inner join: 2134 rows and 52 columns */
proc sql;
	create table feature_R as
	select
		a.*,
		b.*	
	from feature_R_01 as a
	left join kec_perform_procID_01 as b
		on a.ProcID_char=b.ProcID_char
	;
quit;

/* tbl use for Rev variable analysis*/
/*5475 observations and 53 variables */
/*add indicator for prodID that was from the 93 KEC-performed procID */ 
Data outfile.feature_R;
set feature_R;
procID_kecperf=.;
if kec_procID=1 then procID_kecperf=procID;
run;

/*for KEC-req cases, uniqe case=1768, unique proc_id= 76, procID_kecperf_cnt=76 */ 
proc sql;
	select
		count(distinct or_case_id) as caseID_cnt,
		count(distinct proc_id) as procID_cnt,
		count(distinct procID_kecperf) as procID_kecperf_cnt
	from outfile.feature_R 
	where KEC_req=1
;
quit;


/********************************************************************/
/*** Above finished data prep for Milestone 3a3b - Review Model *****/
/********************************************************************/

/* Loc model tbl: Evaluate cat and cont vars by KEC_req (0 or 1) */
/* inner join:  5501 rows and 49 columns ~ use inner for this analysis.  */
/* left join: 16,914 rows and 49 columns, there were 16,830 ASC cases from Master tbl, RevFeature tbl contains >1 procID for the same Case_id */
proc sql;
	create table feature_L_01 as
	select
		a.*,
		b.*	
	from master_Ms3_a02 as a
	inner join LocFeature_01 as b
		on a.or_case_id=b.or_case_id_char
	;
quit;

/* left join:   5501 rows and 51 columns ~ use left for this analysis.  */
/* purpose of this step: identify the KEC-performed procID */
/* inner join: 2143 rows and 51 columns */
proc sql;
	create table feature_L as
	select
		a.*,
		b.*	
	from feature_L_01 as a
	left join kec_perform_procID_01 as b
		on a.ProcID_char=b.ProcID_char
	;
quit;

/* tbl use for Rev variable analysis*/
/* 5501 observations and 52 variable */
/*add indicator for prodID that was from the 93 KEC-performed procID */ 
Data outfile.feature_L;
set feature_L;
procID_kecperf=.;
if kec_procID=1 then procID_kecperf=procID;
run;

/*for KEC-req cases, uniqe case=1780, unique proc_id= 80, procID_kecperf_cnt=80 */ 
proc sql;
	select
		count(distinct or_case_id) as caseID_cnt,
		count(distinct proc_id) as procID_cnt,
		count(distinct procID_kecperf) as procID_kecperf_cnt
	from outfile.feature_L 
	where KEC_req=1
;
quit;

/** no need ***/
/*
proc sort data= outfile.feature_L out=loc_h_s;
by proc_id descending kec_procID descending KEC_req;
run;

data loc_h_01;
set loc_h_s;
by proc_id descending kec_procID descending KEC_req;
if first.kec_procID;
run;

proc freq  ;
tables proc_id
			H
			kec_procID
			KEC_req
;
run;
*/

/*** for location model only ***/
/* left join:   RandomHLoc with ProcID (93 KEC_performed) */
/* 5501 rows and 51 columns ~ use left for this analysis.  */
/* purpose of this step: identify the KEC-performed procID */
/* inner join: 2143 rows and 51 columns */

/* 1429 obs, 3 var */
data RandomHLoc_01;
set RandomHLoc;
procID_char=strip(put(proc_id, 6.));
run;

/* 1429 obs, 4 var */
proc sql;
	create table H_L_01 as
	select
		a.*,
		b.*	
	from RandomHLoc_01 as a
	left join kec_perform_procID_01 as b
		on a.procID_char=b.procID_char
	;
quit;

/*1429 observations and 4 variables */
data outfile.Location_H;
set H_L_01;
if kec_procID=1 then kec_procID=kec_procID;
else kec_procID=0;
run;

/* 68 procID from the 93 identified as KEC-performed */
proc freq  ;
tables kec_procID
;
run;

a/********************************************************************/
/*** Above finished data prep for Milestone 3a3b - Location Model ***/
/********************************************************************/


