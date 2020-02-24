* Project: quasi markets and school segregation
* File: create cohort and basic covars
* Last edited: 5/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
* loop over years and save gender and date of birth
forval i=1994/2015{
	use "$rf\grund`i'.dta", clear
	if `i'>2006{
		rename   FOED_DAG foed_dag
	}
	keep foed_dag pnr koen 
	* date of birth
	rename foed_dag dateofbirth
	* gender
	gen byte female=koen==2
	* year
	gen int year=`i'
	compress
	save "$tf\grund`i'.dta",replace
}
* append
use "$tf\grund1994.dta",clear
forval i=1995/2015{
		append using "$tf\grund`i'.dta", force
	}
* remove duplicates	
bys pnr: keep if _n==1
* save
compress
save "$tf\focal_covariates.dta",replace

