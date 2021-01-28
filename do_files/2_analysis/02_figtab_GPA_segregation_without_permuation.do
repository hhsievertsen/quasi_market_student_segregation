* Project: quasi markets and school segregation
* File: GPA segregation without permutations
* Last edited: 25/2-2020 by HHS
* load global settings
do "D:\Data\workdata\704236\xdrev\704236\quasi_market_segregation\do_files\settings.do"

* Program for actual R2 - permuted R2
cap program drop mypermut
program mypermut,eclass
	* temporary datasets 
	tempfile main estimates
	qui: save `main',replace
	/**************************************************************************
		1. Permutations
	**************************************************************************/
			* create to store estimates
			clear
			qui: set obs 1
			forval i=2003/2011{
				qui: gen _r2_high0_`i'=.
				qui: gen _r2_high1_`i'=.
				}
			qui: save `estimates',replace
			
	/**************************************************************************
		1. Actual
	**************************************************************************/
					* load analysis data
			use `main',clear
			* loop over years
			forval year=2003/2011{
				* loop over level of competition
				forval i=0/1{
						* obtain R2
						qui: reg foc_gpa i.enrollment_instnr if enrollment_competition_p50_20k==`i' & foc_year==`year'
						* store
						preserve
							qui:  use `estimates',clear
							qui: replace _r2_high`i'_`year'=e(r2) 
							qui: save `estimates',replace
						restore
						}
			}
	/**************************************************************************
		2. Store
	**************************************************************************/			
			use `estimates',clear
			keep _*
			gen _pre_low=((_r2_high0_2003+_r2_high0_2004+_r2_high0_2005+_r2_high0_2006)/4) 
			gen _post_low=((_r2_high0_2007+_r2_high0_2008+_r2_high0_2009+_r2_high0_2010+_r2_high0_2011)/5)
			gen _pre_high=((_r2_high1_2003+_r2_high1_2004+_r2_high1_2005+_r2_high1_2006)/4)
			gen _post_high=((_r2_high1_2007+_r2_high1_2008+_r2_high1_2009+_r2_high1_2010+_r2_high1_2011)/5)
			gen _dif_post=_post_high-_post_low
			gen _dif_pre =_pre_high-_pre_low ///
						  
			gen _dif_high=_post_high-_pre_high
			gen _dif_low =_post_low-_pre_low
			gen _dif_in_dif=_dif_post-_dif_pre
			
			xpose,clear varname
			mkmat v1, matrix(output) rownames(_varname)
			mat a=output'
			ereturn post a
			use `main',clear
end

* empty dataset to store estimates for time series chart
clear 
set obs 9
gen year=_n+2002
gen beta_low=.
gen beta_high=.
save "$tf\estimatesR2_by_year_fortimechart_np.dta",replace
* bootstrap
use "$tf\analysisdata.dta",clear
bootstrap _b , reps(200) cluster(enrollment_instnr)  : mypermut
esttab using "$df\tab_GPAsegregation_notpermuted.txt", star(* 0.05) se replace 
esttab using "$df\tab_GPAsegregation_notpermutedpval.txt", star(* 0.05) p replace 
* store estimates for line chart
use "$tf\estimatesR2_by_year_fortimechart_np.dta",clear
forval i=2003/2011{
	replace beta_low=_b[_r2_high0_`i'] if year==`i' 
	replace beta_high=_b[_r2_high1_`i'] if year==`i' 
}
save "$tf\estimatesR2_by_year_fortimechart_np.dta",replace

tw (connected beta_high year, lcolor(black) mcolor(black) msymbol(S) lwidth(medthick))  ///
   (connected beta_low year, lcolor(gs6) mcolor(gs6) msymbol(X) msize(large) lwidth(medthick)) ///
   , ylab(0(0.01)0.08, noticks nogrid angle(horizontal) format(%4.2f)) ///
   xlab(2003(2)2011,noticks) yscale(noline)  xline(2006.5, lcolor(black) lpattern(dash)) ///
   ytitle("R-squared") xtitle("Year of enrollment") ///
   legend(order(1 "High concentration areas" 2 "Low concentration areas") region(lcolor(white)) position(12)) ///
   graphregion(lcolor(white) fcolor(white)) plotregion(lcolor(white) fcolor(white))
   graph export "$df\fig2_GPAsegregation.png",replace width(2000)



