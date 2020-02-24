* Project: quasi markets and school segregation
* File: create cohort and basic covars
* Last edited: 5/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
* define max educational level in household
	forval i=1992/2015{
		use "$rf\grund`i'.dta", clear
		if `i'<2007{
			gen age=`i'-year(foed_dag)
		}
		if `i'>2006{
			gen age=`i'-year(FOED_DAG)
		}
		* merge with formats to get level of schooling
		rename hfaudd audd
		merge m:1 audd using "$ff\audd_raw.dta", nogen keep(3)
		* gen length
		gen educ=pria/12
		replace pria=. if age<30
		* find highest level in familly:
		bys familie_id: egen mudd=max(educ)
		* keep what we need
		keep pnr mudd
		save "$tf\edc`i'.dta",replace
	}
* append
	use "$tf\edc1992.dta",clear
	gen year=1992
forval i=1993/2015{
		append using "$tf\edc`i'.dta",force
		replace year=`i' if year==.
	}
*save
	compress
	bys pnr year: keep if _n==1
	save "$tf\educ.dta",replace
