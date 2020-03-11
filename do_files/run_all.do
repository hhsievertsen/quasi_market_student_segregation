* Project: quasi markets and school segregation
* File: run all files
* Last edited: 19/2-2020 by HHS
* run global
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"

* start log
cap log close
log using "$df\log.txt", text replace

/* Databuild */
local databuild: dir "do_files\1_databuild" files "*.do", respectcase
foreach f of local databuild{
	di as red "Running: `f'"
	qui: do "do_files\1_databuild\\`f'"
}

/* Analyses */
local analyses: dir "do_files\2_analysis" files "*.do", respectcase
foreach f of local analyses{
	di as red "Running: `f'"
	qui: do "do_files\2_analysis\\`f'"
}
