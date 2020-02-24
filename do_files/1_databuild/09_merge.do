* Project: quasi markets and school segregation
* File: merge datasets
* Last edited: 5/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
/* load enrollment */
use "$tf\enrollment.dta",clear
/* select years */
keep if year>=2003 & year<2012
/* merge with application data*/
merge 1:1 pnr year using  "$tf\application.dta",keep (1  3) nogen
/* merge with individual characteristics*/
merge m:1 pnr using "$tf\focal_covariates.dta", nogen keep(1 3)
/* merge with 9th grade gpa*/
merge m:1 pnr using "$tf\gpa9.dta", nogen keep(1 3)
/* unemployment rate*/
* merge to municipality
merge m:1 year pnr using "$tf\kompanel.dta",nogen keep (1 3)
* merge to unemployment rate
merge m:1 year kom using "$tf\unemploymentrates.dta",nogen keep(1 3)
/* merge with household education 2y before starting*/
replace year=year-2
merge m:1 pnr year using  "$tf\educ.dta", nogen keep(1 3)
replace year=year+2
/* merge with enrollment catchment area level of competition */
rename instnr_enrollment instnr
merge m:1 instnr using "$tf\instdata.dta",	nogen keep(1 3)	
foreach var in school_group competion_level_5k competition_p50_5k competition_p25_5k competition_p75_5k competition_mean_5k competion_level_20k competition_p50_20k competition_p25_20k competition_p75_20k competition_mean_20k{
	rename `var' enrollment_`var'
}
rename  instnr enrollment_instnr
/* merge with application catchment area level of competition */
rename instnr_application instnr
merge m:1 instnr using "$tf\instdata.dta",	nogen keep(1 3)	
foreach var in school_group competion_level_5k competition_p50_5k competition_p25_5k competition_p75_5k competition_mean_5k competion_level_20k competition_p50_20k competition_p25_20k competition_p75_20k competition_mean_20k{
	rename `var' application_`var'
}
rename  instnr application_instnr
/* rename variables */
drop koen
rename female foc_female
rename mudd foc_parentalschooling
rename gpa_std foc_gpa
rename dateofbirth foc_dateofbirth
rename pnr foc_id
rename gpa_above foc_highgpa
rename une foc_une
rename year foc_year
order foc* enrol* applic*
/* Define age age */
gen foc_age=(mdy(8,1,foc_year)-foc_date)/365.24
/* Create labels*/
label var foc_age "Focal individual's age at entry"
label var foc_id "Focal individual's id"
label var foc_year "Year of enrollment/application"
label var foc_date "Date of birth"
label var foc_gpa "9th grade GPA"
label var foc_highgpa "GPA above cohort median"
label var foc_female "Indicator for female"
label var foc_par "Parental years of schooling (max)"
foreach l in enrollment application{
	label var `l'_instnr "Institution id, `l'"
	label var `l'_school_group "School group, `l'"
}

/* save */
save "$tf\rawdata.dta",replace
