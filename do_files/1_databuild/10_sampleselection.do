* Project: quasi markets and school segregation
* File: sample selection
* Last edited: 6/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
* load raw data
use "$tf\rawdata.dta",clear
* write selection table
cap file close m
file open m using "$df\tab_selection.txt",replace write
/****************************************************************************** 
	- RAW SAMPLE 
*******************************************************************************/
local N=_N 											/* number of students */
local NDISP: disp %8.0fc `N' 						/* number of students */
qui: tab enrollment_instnr
local school0=r(r) 									/* number of schools */
* write to file
file write m _col(50) ";Students" _col(70) ";Schools"_n
file write m "All students that enrolled 2003-2011" _col(50) ";`NDISP'" _col(70) ";`school0'"_n
/****************************************************************************** 
	- Remove irrelvant institutions
*******************************************************************************/
* delete irrelevant institutions
drop if inlist(enrollment_instnr,101124,101125,101126,101171,147026,159020,207004,227007, ///
					373019,435007,545007,613011,667016)
* delete institutions on Bornholm
drop if enrollment_school_group==100
local N1=_N 										/* number of students */
local NDISP: disp %9.0fc `N1'-`N'  					/* change in number of students */
qui: tab enrollment_instnr
local school1=r(r)  								/* number of schools */
local s0=`school1'-`school0' 						/* change in number of schools */
file write m "Irrelevant institutions" _col(50) ";`NDISP'" _col(70) ";`s0'"_n
/****************************************************************************** 
	- Observe school in all nine years (make balanced)
*******************************************************************************/
* make balanced.
egen tag=tag(enrollment_instnr foc_year)
bys enrollment_instnr:egen ab=sum(tag)
keep if ab==9
drop ab 
local N2=_N 									/* number of students */
local NDISP: disp %9.0fc `N2'-`N1' 				/* change in number of students */
qui: tab enrollment_instnr
local school2=r(r)  							/* number of schools */
local s1=`school2'-`school1' 					/* change in number of schools */
file write m "Balanced panel" _col(50) ";`NDISP'" _col(70) ";`s1'"_n
/****************************************************************************** 
	- Unknown school district
*******************************************************************************/
keep if enrollment_school_group!=.
local N3=_N 									/* number of students */
local NDISP: disp %9.0fc `N3'-`N2' 				/* change in number of students */
qui: tab enrollment_instnr
local school3=r(r)  							/* number of schools */
local s2=`school3'-`school2' 					/* change in number of schools */
file write m "No school district data" _col(50) ";`NDISP'" _col(70) ";`s2'"_n
/****************************************************************************** 
	- Unknown GPA
*******************************************************************************/
keep if foc_gpa!=.
local N4=_N										/* number of students */
local NDISP: disp %9.0fc `N4'-`N3' 				/* change in number of students */
qui: tab enrollment_instnr
local school4=r(r)  							/* number of schools */
local s3=`school4'-`school3' 					/* change in number of schools */
file write m "No 9th grade GPA" _col(50) ";`NDISP';" _col(70) "`s3'"_n
/****************************************************************************** 
	- Analysis SAMPLE
*******************************************************************************/
local NDISP: disp %8.0fc `N4'
* relative numbers
local nshare: disp %3.0fc 100*`N4'/`N'
local sshare: disp %3.0fc 100*`school4'/`school0'
file write m "Analysis sample" _col(50) ";`NDISP' (`nshare'%)" _col(70) ";`school3' (`sshare'%)"_n
file close m
/*low vs high gpa */
bys foc_year: egen rank=rank(foc_gpa)
bys foc_year: egen mrank=max(rank)
gen ra=rank/mrank
replace foc_highgpa=ra>0.5
* save
compress
drop tag kom
order foc* enroll* appl*
save "$tf\analysisdata.dta",replace
/* applicants relative to priorities */
use "$tf\analysisdata.dta",clear
collapse (count) gym_enrolled=foc_female, by(enrollment_instnr foc_year) fast
save "$tf\enrollmentsum.dta",replace
use "$tf\analysisdata.dta",clear
collapse (count) gym_applicants=foc_female, by(application_instnr foc_year) fast
rename application_instnr enrollment_instnr
save "$tf\applicantsum.dta",replace
use "$tf\analysisdata.dta",clear
merge m:1 enrollment_instnr foc_year using "$tf\enrollmentsum.dta",nogen keep(1 3)
merge m:1 enrollment_instnr foc_year using "$tf\applicantsum.dta",nogen keep(1 3)
save "$tf\analysisdata.dta",replace
