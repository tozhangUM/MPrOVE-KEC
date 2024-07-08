* Review model varlist;
* RevCat_varlist;
* RevCont_varlist;
* RevH_varlist=;
* Data contains procedure ID & randome effect, varnames are procID and h; 
* Need to identify KEC-procID to run the proc univariate;

%let RevCat_varlist=
A1C
ASA
ASCReq
ASCReqxHighBP
ASCReqxNoBP
Abnbreath
Afib
Anemiaresolved
Anemiaunresolved
AnesIssue
BMI40
BMI50
CHD
CIHD
CardiacArrest
CardiacAssist
CardiacDevice
DisabilityProxy
ESRD
HTN
HeartFailure
HighBP
InternalMMpatient
NoBMI
NoBP
PriorASCsurgery
Sex	
StrokeTIA	
ValveDisease
;

%let RevCont_varlist=
ASCReqxMinBP 
Age
AgeSq
H
HighBP
MPROVE_REVIEW 
NonASCReqxMinBP
;

%let RevH_varlist=
H
;
