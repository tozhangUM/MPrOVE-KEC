* Location Model varlist;
* LocCat_varlist;
* LocCont_varlist;
* LocH_varlist=;
* Data contains procedure ID & randome effect, varnames are procID and h; 
* Need to identify KEC-procID to run the proc univariate;

%let LocCat_varlist=
A1C
ASCReq
ASCReqxHighBP
ASCReqxNoBP
Anemiaresolved
Anemiaunresolved
AnesIssue
BMI40
BMI50
CIHD
CardiacArrest
CardiacDevice
Creatinine
DisabilityProxy
HeartFailure
HighBP
InternalMMpatient
MultProc
NeuromuscularDis
NoBMI
NoBP
NoCreatinine
PriorASCsurgery
Sex
ValveDisease
;

%let LocCont_varlist=
ASCReqxMaxBP
ASCReqxMinBP
Age
AgeSq
BMI
MPROVE_LOCATION
NonASCReqxMaxBP
NonASCReqxMinBP
;

%let LocH_varlist=
H
;
