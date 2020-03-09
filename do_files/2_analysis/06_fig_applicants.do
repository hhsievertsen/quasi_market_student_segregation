* Project: quasi markets and school segregation
* File: applicants
* Last edited: 18/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"

* Program for acutal R2 - permuted R2
cap program drop mypermut
program mypermut,eclass
syntax ,permutations(string)
	* temporary datasets 
	tempfile main estimates
	qui: save `main',replace
	/**************************************************************************
		1. Permutations
	**************************************************************************/
			* create to store estimates
			clear
			qui: set obs 1
			forval i=2009/2011{
				qui: gen r2_high0_`i'_permuted=.
				qui: gen r2_high1_`i'_permuted=.
				}
			expand `permutations'
			qui: gen iteration=_n
			qui: save `estimates',replace
			* load analysis data
			use `main',clear
			keep application_instnr application_school_group application_competition_p50_20k foc_gpa foc_year foc_id
			* permutations
			forval iteration=1/`permutations'{
				* reshuffle enrollmet id
				qui: gen sortvar=runiform()
				sort application_school_group foc_year sortvar
				qui: by application_school_group foc_year: gen application_instnrP=application_instnr[_n-1]
				qui: by application_school_group foc_year: replace application_instnrP=application_instnr[_N] if _n==1
				* loop over years
				forval year=2009/2011{
					* loop over level of competition
					forval i=0/1{
							* obtain R2
							qui: reg foc_gpa i.application_instnrP if application_competition_p50_20k==`i' & foc_year==`year'
							* store
							preserve
								qui: use `estimates',clear
								qui: replace r2_high`i'_`year'_permuted=e(r2) if iteration==`iteration'
								qui: save `estimates',replace
							restore
							}
					}
				drop sortvar application_instnrP
				* print iteration
				disp "Iteration `iteration'"
			}
	/**************************************************************************
		2. Actual
	**************************************************************************/
			use `estimates',clear
			collapse (mean) r2_* ,fast
			forval i=2009/2011{
				qui: gen r2_high0_`i'=.
				qui: gen r2_high1_`i'=.
				}
			qui: save `estimates',replace
			* load analysis data
			use `main',clear
			* loop over years
			forval year=2009/2011{
				* loop over level of competition
				forval i=0/1{
						* obtain R2
						qui: reg foc_gpa i.application_instnr if application_competition_p50_20k==`i' & foc_year==`year'
						* store
						preserve
							qui:  use `estimates',clear
							qui: replace r2_high`i'_`year'=e(r2) 
							qui: save `estimates',replace
						restore
						}
			}
	/**************************************************************************
		3. Compute difference
	**************************************************************************/			
			use `estimates',clear
			forval i=2009/2011{
				qui: gen _r2_high0_`i'= r2_high0_`i'- r2_high0_`i'_permuted
				qui: gen _r2_high1_`i'= r2_high1_`i'- r2_high1_`i'_permuted
				}
			keep _*
			xpose,clear varname
			mkmat v1, matrix(output) rownames(_varname)
			mat a=output'
			ereturn post a
			use `main',clear
end
use "$tf\analysisdata.dta",clear
drop if application_instnr==.
bootstrap _b , reps(200) cluster(application_instnr)  : mypermut, permutations(50)
/* add to main estimates */
use "$tf\estimatesR2_by_year_fortimechart.dta",clear
gen beta_low_a=.
gen beta_high_a=.
forval i=2009/2011{
	replace beta_low_a=_b[_r2_high0_`i'] if year==`i' 
	replace beta_high_a=_b[_r2_high1_`i'] if year==`i' 
}
save "$tf\estimatesR2_by_year_fortimechart_with_applicants.dta",replace
* create chart
use "$tf\estimatesR2_by_year_fortimechart_with_applicants.dta",clear
tw (connected beta_high year, lcolor(black) mcolor(black) msymbol(S) lwidth(medthick))  ///
   (connected beta_low year, lcolor(gs6) mcolor(gs6) msymbol(X) msize(large) lwidth(medthick)) ///
   (connected beta_high_a year, lcolor(black) lpattern(dash) mcolor(black) msymbol(S) lwidth(medthick))  ///
   (connected beta_low_a year, lcolor(gs6) lpattern(dash)  mcolor(gs6) msymbol(X) msize(large) lwidth(medthick)) ///
   , ylab(0(0.01)0.07, noticks nogrid angle(horizontal) format(%4.2f)) ///
   xlab(2003(2)2011,noticks) yscale(noline)  xline(2006.5, lcolor(black) lpattern(dash)) ///
   ytitle("R-squared") xtitle("Year of enrollment") ///
   legend(order(1 "High conc. enr." 2 "Low conc. enrol" 3 "High conc. appl." 4 "Low conc. appl.") region(lcolor(white)) position(12)) ///
   graphregion(lcolor(white) fcolor(white)) plotregion(lcolor(white) fcolor(white))
   graph export "$df\fig2_GPAsegregation_permute_with_appl.png",replace width(2000)

