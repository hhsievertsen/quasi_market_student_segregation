* Project: quasi markets and school segregation
* File: unemployment data
* Last edited: 18/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
* municipality of residence
forval i=1999/2012{
	use "$rf\GRUND`i'.dta",clear
	keep pnr kom
	gen int year=`i'+1
	bys pnr : keep if _n==1
	if `i'==1999{
			save "$tf\kompanel.dta",replace
	}
	else{
		append using "$tf\kompanel.dta",
		replace kom=400 if inlist(kom,401,403,405,407,409,411)
		save "$tf\kompanel.dta",replace
	}
}
* import unemployment data 2001-2006
import excel "$ef\DST_AARD_TIDY.xlsx", sheet("Sheet1") firstrow clear
keep kom year une
* save
save "$tf\unemploymentrates.dta",replace
* import unemployment data 2007
import excel "$ef\DST_AULP01X_TIDY.xlsx", sheet("Sheet1") firstrow clear
keep kom year une
append using  "$tf\unemploymentrates.dta",
save "$tf\unemploymentrates.dta",replace
* import unemployment data 2008-
import excel "$ef\DST_AULP01_TIDY.xlsx", sheet("Sheet1") firstrow clear
keep kom year une
append using  "$tf\unemploymentrates.dta",
bys kom year: keep if _n==1
replace une=une/100
replace une=. if une==0
save "$tf\unemploymentrates.dta",replace
