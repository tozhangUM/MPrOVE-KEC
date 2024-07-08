

/* REVFEATURE has 64934 observations and 43 variable: review_features_wide-2024-05-07.csv */
PROC IMPORT DATAFILE="&ReadInPath.\&RevFeature."
            OUT=RevFeature  /*name of the sas data */  
            DBMS=CSV REPLACE;
            GETNAMES=YES; 	/*take the var names from csv header */
RUN;


/* DUP DUP DUP! unique or_case_id: 43,344 (it's caused by multiple score times */
proc sql;
	select
	count(distinct or_case_id) as case_cnt
	from RevFeature 
;
quit;

/* Rev model: Evaluate cat and cont vars by KEC_req (0 or 1) */
/* left join: 16901 rows and 50 columns */
/* inner join:   5475 rows and 50 columns */
/* ProcID Num 8 */

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

/* Rev model: Evaluate cat and cont vars by KEC_req (0 or 1) */
/* left join: 16901 rows and 50 columns */
/* inner join:   5475 rows and 50 columns ~ use inner for this analysis.  */
/* case in Feature tbl NOT in Master file: req_date <= 20230504, min=20210305 max=20240502 */
proc sql;
    create table proc_not_inA as
    select *
    from RevFeature_01
    where or_case_id_char not in (select or_case_id from master_Ms3_a02);
quit;

proc freq;
tables req_date;
run;

proc print data=proc_not_inA (obs=50);
run;

data check_case_in_master;
set master_Ms3_a02;
if or_case_id in (
"2569875",
"2656435",
"2971555",
"3020259",
"3044458",
"3062959",
"3109605",
"3129836",
"3134246",
"3145058",
"3146049",
"3163144",
"3178751",
"3204005",
"3227621",
"3228622",
"3257913",
"3290175",
"3300530",
"3312871"
);
run;

/*check if in this master data: outfile.master_keep: 0 obs */
/* reason of not in both master */

data NotInA;
set RevFeature_01;
if or_case_id_char in (
"2569875",
"2656435",
"2971555",
"3020259",
"3044458",
"3062959",
"3109605",
"3129836",
"3134246",
"3145058",
"3146049",
"3163144",
"3178751",
"3204005",
"3227621",
"3228622",
"3257913",
"3290175",
"3300530",
"3312871"
);
run;

proc print (obs=50);
run;

*********** above solved question: why case in feature tble not in master ****;

proc sql;
    create table proc_not_inA as
    select *
    from kec_perform_procID_01
    where procID_char not in (select proc_id from RandomHLoc);
quit;

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

/* 5404, 433 */
proc sql;
	select
		count(distinct or_case_id) as case_cnt,
		count(distinct ProcID_char) as proc_cnt
	from feature_R 
;
quit;



/****** read in LocFeature:  64201 observations and 42 variable, tbl: location_features_wide-2024-05-07.csv */
PROC IMPORT DATAFILE="&ReadInPath.\&LocFeature."
            OUT=LocFeature  /*name of the sas data */  
            DBMS=CSV REPLACE;
            GETNAMES=YES; 	/*take the var names from csv header */
RUN;

/* DUPs! 43327 cases_id */
proc sql;
	select
		count(distinct or_case_id) as case_cnt
	from LocFeature 
;
quit;


/*1824 uniqe procID, 1029 unique H in Location Model featurefile */
proc sql;
	select
		count(distinct ProcID) as procID_cnt,
		count(distinct H) as H_cnt
	from LocFeature 
;
quit;

/*1809 uniqe procID, 8 uniqe H value in Review Model featurefile */
proc sql;
	select
		count(distinct ProcID) as procID_cnt,
		count(distinct H) as H_cnt
	from RevFeature 
;
quit;

/* unique proc_id=1429 unique H value =1427 */ 
proc sql;
	select
		count(distinct proc_id) as procID_cnt,
		count(distinct H) as H_cnt
	from RandomHLoc 
;
quit;

proc contents data=RandomHLoc varnum;
run;


proc freq data=outfile.feature_R;
tables  ASC_req KEC_req ASC_perf KEC_perf;
run;

/*or KEC-req cases, uniqe case=1768, unique proc_id= 76 */ 
proc sql;
	select
		count(distinct or_case_id) as procID_cnt,
		count(distinct proc_id) as procID_cnt

	from outfile.feature_R 
	where KEC_req=1
;
quit;

/*for KEC-perform cases, uniqe case=1750, unique proc_id= 76 */ 
proc sql;
	select
		count(distinct or_case_id) as procID_cnt,
		count(distinct proc_id) as procID_cnt

	from outfile.feature_R 
	where KEC_perf=1
;
quit;

/*for kec_procID=1 cases, uniqe case=2131, unique proc_id= 81 */ 
proc sql;
	select
		count(distinct or_case_id) as procID_cnt,
		count(distinct proc_id) as procID_cnt

	from outfile.feature_R 
	where kec_procID=1
;
quit;

/*if joint only RevFeature and proc_id file */
/*6049 rows and 48 column */

proc sql;
	create table RevFeature_procID as
	select
		a.*,
		b.*	
	from RevFeature_01 as a
	inner join kec_perform_procID_01 as b
		on a.procID_char=b.procID_char
	;
quit;

/*unique case=6045, unique procID=91  */ 
proc sql;
	select
		count(distinct or_case_id) as procID_cnt,
		count(distinct proc_id) as procID_cnt

	from RevFeature_procID
	where kec_procID=1
;
quit;

/* 2 procIDs not in Revfeature */
proc sql;
    create table proc_not_inRev as
    select distinct procID_char
    from kec_perform_procID_01  
    where procID_char not in (select procID_char from RevFeature_01);
quit;

proc print data=proc_not_inRev;
run;

/*if joint only LocFeature and proc_id file */
/* 6054 rows and 47 columns */
proc sql;
	create table LocFeature_procID as
	select
		a.*,
		b.*	
	from LocFeature_01 as a
	inner join kec_perform_procID_01 as b
		on a.procID_char=b.procID_char
	;
quit;

/*unique case=6051, unique procID=93 !!! */ 
proc sql;
	select
		count(distinct or_case_id) as procID_cnt,
		count(distinct proc_id) as procID_cnt

	from LocFeature_procID
	where kec_procID=1
;
quit;

/* 0 procIDs not in Locfeature */
proc sql;
    create table proc_not_inLoc as
    select distinct procID_char
    from kec_perform_procID_01  
    where procID_char not in (select procID_char from LocFeature_01);
quit;

proc print data=proc_not_inLoc;
run;



/****no need ****/
/*
proc sort data= outfile.feature_R out=rev_h_s;
by proc_id descending kec_procID descending KEC_req;
run;

data rev_h_01;
set rev_h_s;
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








/*1429 uniqe proc_id */
proc sql;
	select
		count(distinct proc_id) as procID_cnt
	from RandomHLoc 
;
quit;

/****** read in KEC-performed proc_id,  93 observations and 1 variables */
/*** identify the cases with these ID ****/

/* OR_CASE_ID Char 9  */
proc contents data=master_Ms_3a varnum;
run;

/* or_case_id Num 8 BEST12. */
proc contents data=RevFeature varnum;
run;

/* or_case_id Num 8 BEST12. */
proc contents data=LocFeature varnum;
run;

/* proc_id Char 5 $5.  */
proc contents data=RandomHLoc varnum;
run;

/*proc_id Num 8  */
proc contents data=outfile.kec_perform_procID varnum;
run;

/*** print ****/
/* or_case_id Num 8 BEST12. */
proc print data=RevFeature (obs=200);
title "RevFeature (obs=200)";
run;

/* or_case_id Num 8 BEST12. */
proc print data=LocFeature (obs=200);
title "LocFeature (obs=200";
run;

/* proc_id Char 5 $5.  */
proc contents data=RandomHLoc varnum;
run;


/*  1429 rows and 3 column */
/*  only 68 proc_id if inner-join */
proc sql;
	create table feature_L_procID_01 as
	select
		a.*,
		b.kec_procID	
	from RandomHLoc as a
	inner join kec_perform_procID_01 as b
		on a.proc_id=b.procID_char
	;
quit;

/*25 proc_id not in RandomEffect tbl */
proc sql;
    create table proc_not_inA as
    select *
    from kec_perform_procID_01
    where procID_char not in (select proc_id from RandomHLoc);
quit;

proc freq data=feature_L_procID_01;
tables kec_procID /norow nocol missing;
run;


