%let sharefolder=T:\OCA_Admin\ACR-Select\Toni;
%let includedir=&sharefolder.;
%include "&includedir.\Include_Setup.sas" /*/source2 */;
/******Varlist for Ms3 file; ***/
%include "&includedir.\Include_RevModelVarlist.sas" /*/source2 */;
%include "&includedir.\Include_LocModelVarlist.sas" /*/source2 */;

* Review model varlist;
* RevCat_varlist;
* RevCont_varlist;
* RevH_varlist=;

* Location model varlist;
* LocCat_varlist;
* LocCont_varlist;
* LocH_varlist=;

/**********************/
/* For Review   Model */
/**********************/
/* macro for categorical vars*/
%include "&includedir.\Include_m_Ms3_FreqCatVar1way.sas" /*/source2 */;
%Ms3_FreqCatVar1way(data=outfile.feature_R, catVarlist=&RevCat_varlist, grpvar=KEC_req);

/* macro for continous vars*/
%include "&includedir.\Include_m_Ms3_UnivContVar.sas" /*/source2 */;
%Ms3_UnivContVar(data=outfile.feature_R, ContVarList=&RevCont_varlist, grpvar=KEC_req);

/* macro for continous H vars*/
%include "&includedir.\Include_m_Ms3_UnivContVarH.sas" /*/source2 */;
%Ms3_UnivContVarH(data=outfile.feature_R, ContVarList=&RevH_varlist, grpvar=KEC_req);



/**********************/
/* For Location Model */
/**********************/
/* macro for categorical vars*/
%include "&includedir.\Include_m_Ms3_FreqCatVar1way.sas" /*/source2 */;
%Ms3_FreqCatVar1way(data=outfile.feature_L, catVarlist=&LocCat_varlist, grpvar=KEC_req);

/* macro for continous vars*/
%include "&includedir.\Include_m_Ms3_UnivContVar.sas" /*/source2 */;
%Ms3_UnivContVar(data=outfile.feature_L, ContVarList=&LocCont_varlist, grpvar=KEC_req);

/* no need for Review model as there is little variance in H value */
%Ms3_UnivContVarH(data=outfile.Location_H, ContVarList=&LocH_varlist, grpvar=kec_procID);
