* Project: quasi markets and school segregation
* File: enrollment data
* Last edited: 6/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
* Load elevregistret
	use "$rf\KOTRE2015.dta", clear
* Define High school programs
	merge m:1 udd using "$ff\uddan_2013_udd.dta", keep(1 3) nogen
	keep if inlist(M1TEKST,"Gymnasiet")
	keep if udd==1199|udd==1189|udd==1179
* define enrollment in first year only
	keep if udel==21
* gen year
	gen year=year(ELEV3_VFRA)
* keep what we need
	rename M1TEKST type
	keep instnr  year pnr
	rename instnr instnr_enrollment
	duplicates drop pnr year,force
* save 
	compress
	drop if pnr==""
	save "$tf\enrollment.dta",replace
