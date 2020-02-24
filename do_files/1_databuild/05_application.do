* Project: quasi markets and school segregation
* File: application data
* Last edited: 6/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
* Load data
use "X:\Data\Workdata\704236\stataraw\stildata.dta", clear
/* only keep first priority */
keep if prioritet=="1"
/* only keep stx*/
keep if til_udd=="Studentereksamen - stx"
* Redefine variables
destring til_institution,gen(instnr)
rename dwid_kalenderaar year
* keep variables we need
keep pnr instnr year
* remove duplicates
bys pnr: keep if _n==1
* save
rename instnr instnr_application
compress
save "$tf\application.dta" , replace
