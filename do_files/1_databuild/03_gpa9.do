* Project: quasi markets and school segregation
* File: 9th grade GPA
* Last edited: 6/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
* load data on grades
  use "$rf\UDFK2015.dta", clear
 * keep only 9th grade
  keep if kltrin=="09"
* year
  gen year=substr(skoleaar,6,4)
  destring year,replace
* collapse
	collapse (mean) gpa=grundskolekarakter  (max) year ///
	(count) n=grundskolekarakter, by( pnr ) fast
	drop if n<7 /* drop if less than 7 grades */
* standardize by year
  bys year: egen m=mean(gpa)
  bys year: egen sd=sd(gpa)
  gen gpa_std=(gpa-m)/sd
  drop m sd
* above median indicator
  bys year: egen med=median(gpa)
  gen gpa_above=gpa>med
* drop year
	keep pnr gpa_std gpa_above
	bys pnr: keep if _n==1
* save
	compress
	save "$tf\gpa9.dta",replace
