* Project: quasi markets and school segregation
* File: GPA placebo reform in 2004
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
			forval i=2003/2006{
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
				forval year=2003/2006{
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
			forval i=2003/2006{
				qui: gen r2_high0_`i'=.
				qui: gen r2_high1_`i'=.
				}
			qui: save `estimates',replace
			* load analysis data
			use `main',clear
			* loop over years
			forval year=2003/2006{
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
			forval i=2003/2006{
				qui: gen _r2_high0_`i'= r2_high0_`i'- r2_high0_`i'_permuted
				qui: gen _r2_high1_`i'= r2_high1_`i'- r2_high1_`i'_permuted
				}
			keep _*
			gen _dif_post=((_r2_high1_2005+_r2_high1_2006)/2)- ///
						  ((_r2_high0_2005+_r2_high0_2006)/2)
			gen _dif_pre =((_r2_high1_2004+_r2_high1_2003)/2)- ///
						  ((_r2_high0_2004+_r2_high0_2003)/2)
			gen _dif_high=((_r2_high1_2005+_r2_high1_2006)/2)- ///
						  ((_r2_high1_2003+_r2_high1_2004)/2)
			gen _dif_low =((_r2_high0_2005+_r2_high0_2006)/2)- ///
						  ((_r2_high0_2003+_r2_high0_2004)/2)
			gen _dif_in_dif=_dif_post-_dif_pre
			xpose,clear varname
			mkmat v1, matrix(output) rownames(_varname)
			mat a=output'
			ereturn post a
			use `main',clear
end
use "$tf\analysisdata.dta",clear
bootstrap _b , reps(200) cluster(enrollment_instnr)  : mypermut, permutations(50)
esttab using "$df\tab_placebo.txt", star(* 0.05) se replace
