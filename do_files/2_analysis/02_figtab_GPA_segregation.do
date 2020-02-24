* Project: quasi markets and school segregation
* File: create figure on GPA segregation (not permuted)
* Last edited: 18/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
* create to store estimates
clear
set obs 9
gen foc_year=2002+_n
gen r2_highconc1=.
gen r2_highconc0=.
save "$tf\fig_GPAsegregation_estimates.dta",replace
* load analysis data
use "$tf\analysisdata.dta",clear
* loop over years
forval year=2003/2011{
* loop over level of competition
	forval i=0/1{
			* obtain R2
			qui: reg foc_gpa i.enrollment_instnr if enrollment_competition_p50_20k==`i' & foc_year==`year'
			* store
			preserve
				use "$tf\fig_GPAsegregation_estimates.dta",clear
				replace r2_highconc`i'=e(r2) if foc_year==`year'
				save "$tf\fig_GPAsegregation_estimates.dta",replace
			restore
			}


}
* create chart
use "$tf\fig_GPAsegregation_estimates.dta",clear
tw (connected r2_highconc1 foc_year, lcolor(black) mcolor(black) msymbol(S) lwidth(medthick))  ///
   (connected r2_highconc0 foc_year, lcolor(gs6) mcolor(gs6) msymbol(X) msize(large) lwidth(medthick)) ///
   , ylab(0(0.01)0.08, noticks nogrid angle(horizontal) format(%4.2f)) ///
   xlab(2003(2)2011,noticks) yscale(noline)  xline(2006.5, lcolor(black) lpattern(dash)) ///
   ytitle("R-squared") xtitle("Year of enrollment") ///
   legend(order(1 "High concentration areas" 2 "Low concentration areas") region(lcolor(white)) position(12)) ///
   graphregion(lcolor(white) fcolor(white)) plotregion(lcolor(white) fcolor(white))
   graph export "$df\fig2_GPAsegregation.png",replace width(2000)

