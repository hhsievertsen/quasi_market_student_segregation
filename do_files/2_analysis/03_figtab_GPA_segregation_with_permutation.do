* Project: quasi markets and school segregation
* File: GPA segregation with permutations
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
			forval i=2003/2011{
				qui: gen r2_high0_`i'_permuted=.
				qui: gen r2_high1_`i'_permuted=.
				}
			expand `permutations'
			qui: gen iteration=_n
			qui: save `estimates',replace
			* load analysis data
			use `main',clear
			keep enrollment_instnr enrollment_school_group enrollment_competition_p50_20k foc_gpa foc_year foc_id
			* permutations
			forval iteration=1/`permutations'{
				* reshuffle enrollmet id
				qui: gen sortvar=runiform()
				sort enrollment_school_group foc_year sortvar
				qui: by enrollment_school_group foc_year: gen enrollment_instnrP=enrollment_instnr[_n-1]
				qui: by enrollment_school_group foc_year: replace enrollment_instnrP=enrollment_instnr[_N] if _n==1
				* loop over years
				forval year=2003/2011{
					* loop over level of competition
					forval i=0/1{
							* obtain R2
							qui: reg foc_gpa i.enrollment_instnrP if enrollment_competition_p50_20k==`i' & foc_year==`year'
							* store
							preserve
								qui: use `estimates',clear
								qui: replace r2_high`i'_`year'_permuted=e(r2) if iteration==`iteration'
								qui: save `estimates',replace
							restore
							}
					}
				drop sortvar enrollment_instnrP
				* print iteration
				disp "Iteration `iteration'"
			}
	/**************************************************************************
		2. Actual
	**************************************************************************/
			use `estimates',clear
			collapse (mean) r2_* ,fast
			forval i=2003/2011{
				qui: gen r2_high0_`i'=.
				qui: gen r2_high1_`i'=.
				}
			qui: save `estimates',replace
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
							qui: replace r2_high`i'_`year'=e(r2) 
							qui: save `estimates',replace
						restore
						}
			}
	/**************************************************************************
		3. Compute difference
	**************************************************************************/			
			use `estimates',clear
			forval i=2003/2011{
				qui: gen _r2_high0_`i'= r2_high0_`i'- r2_high0_`i'_permuted
				qui: gen _r2_high1_`i'= r2_high1_`i'- r2_high1_`i'_permuted
				}
			keep _*
			gen _dif_post=((_r2_high1_2007+_r2_high1_2008+_r2_high1_2009+_r2_high1_2010+_r2_high1_2011)/5)- ///
						  ((_r2_high0_2007+_r2_high0_2008+_r2_high0_2009+_r2_high0_2010+_r2_high0_2011)/5)
			gen _dif_pre =((_r2_high1_2003+_r2_high1_2004+_r2_high1_2005+_r2_high1_2006)/4)- ///
						  ((_r2_high0_2003+_r2_high0_2004+_r2_high0_2005+_r2_high0_2006)/4) 
			gen _dif_high=((_r2_high1_2007+_r2_high1_2008+_r2_high1_2009+_r2_high1_2010+_r2_high1_2011)/5)- ///
						  ((_r2_high1_2003+_r2_high1_2004+_r2_high1_2005+_r2_high1_2006)/4)
			gen _dif_low =((_r2_high0_2007+_r2_high0_2008+_r2_high0_2009+_r2_high0_2010+_r2_high0_2011)/5)- ///
						  ((_r2_high0_2003+_r2_high0_2004+_r2_high0_2005+_r2_high0_2006)/4)
			gen _dif_in_dif=_dif_post-_dif_pre
			xpose,clear varname
			mkmat v1, matrix(output) rownames(_varname)
			mat a=output'
			ereturn post a
			use `main',clear
end
use "$tf\analysisdata.dta",clear

/* Estimate for varying level of competition */
	* empty dataset to store estimates for bar chart
		clear 
		set obs 2
		gen dist=5 if _n==1
		replace dist=20 if _n==2
		expand 4
		bys dist: gen ident=_n
		gen moment="mean" if ident==1
		replace  moment="p50" if ident==2
		replace  moment="p25" if ident==3
		replace  moment="p75" if ident==4
		drop ident
		gen beta=.
		gen se=.
		save "$tf\estimatesR2_by_year.dta",replace
	* empty dataset to store estimates for time series chart
		clear 
		set obs 9
		gen year=_n+2002
		gen beta_low=.
		gen beta_high=.
		gen dist=20
		gen moment="p50"
		save "$tf\estimatesR2_by_year_fortimechart.dta",replace
	* loop over moment
	foreach var in mean p50 p25 p75{
	* loop over distance
			foreach dist in 5 20{
			use "$tf\analysisdata.dta",clear
			replace enrollment_competition_p50_20k=enrollment_competition_`var'_`dist'k
			bootstrap _b , reps(200) cluster(enrollment_instnr)  : mypermut, permutations(50)
			esttab using "$df\tab_GPAsegregation_permuted_by_year_`var'_`dist'.txt", star(* 0.05) se replace
			* store estimates for bar chart
			use "$tf\estimatesR2_by_year.dta",clear
			replace beta=_b[_dif_in_dif] if moment=="`var'" & dist==`dist'
			replace se=_se[_dif_in_dif] if moment=="`var'" & dist==`dist'
			save "$tf\estimatesR2_by_year.dta",replace
			* store estimates for line chart
			use "$tf\estimatesR2_by_year_fortimechart.dta",clear
			forval i=2003/2011{
				replace beta_low=_b[_r2_high0_`i'] if year==`i' & moment=="`var'" & dist==`dist'
				replace beta_high=_b[_r2_high1_`i'] if year==`i' & moment=="`var'" & dist==`dist'
			}
			save "$tf\estimatesR2_by_year_fortimechart.dta",replace
			
		}
	}
/* create chart */
use "$tf\estimatesR2_by_year.dta",clear
drop if moment=="mean"
gen order=1 if moment=="p50"
replace order=2 if moment=="p25"
replace order=3 if moment=="p75"
replace order=order-0.225 if dist==5
replace order=order+0.225 if dist==20
gen u=beta+invttail(207402 ,0.025)*se
gen l=beta-invttail(207402 ,0.025)*se
tw (bar beta order if dist==5, barwidth(0.45) fcolor(gs2) lcolor(gs2) ) ///
   (bar beta order if dist==20, barwidth(0.45) fcolor(gs10) lcolor(gs10) ) ///
   (rcap u l order if dist==5, lcolor(black) ) ///
   (rcap u l order if dist==20, lcolor(black)) ///
   , plotregion(lcolor(white) fcolor(white) margin(zero)) ///
	  graphregion(lcolor(white) fcolor(white)) ///
	  yscale(noline) ylabel(0.0(0.02).08, nogrid angle(horizontal) format(%4.2f) noticks) ///
	  xlab(1 "Median" 2 "P25" 3 "P75",noticks)  legend(order (1 "5km" 2 "20km") region(lcolor(white))) ///
	  ytitle("DiD estimate") xtitle("") 
	  graph export "$df\fig_alt_spec_R2.png",replace width("4000")



/* Unbalanced Sample*/
	use "$tf\rawdata.dta",clear
	keep if foc_gpa!=.
	keep if enrollment_school_group!=.
	drop if enrollment_instnr==.
	bootstrap _b , reps(200) cluster(enrollment_instnr)  : mypermut, permutations(50)
	esttab using "$df\tab_GPAsegregation_permuted_unbalanced_by_year.txt", star(* 0.05) se replace

	
