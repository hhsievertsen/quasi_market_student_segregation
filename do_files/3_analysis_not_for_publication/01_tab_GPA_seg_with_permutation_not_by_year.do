* Project: quasi markets and school segregation
* File: calculate permuted DID by not collapsing on year first
* Last edited: 24/2-2020 by HHS
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
			qui: gen r2_high0_pre0_permuted=.
			qui: gen r2_high1_pre0_permuted=.
			qui: gen r2_high0_pre1_permuted=.
			qui: gen r2_high1_pre1_permuted=.
			expand `permutations'
			qui: gen iteration=_n
			qui: save `estimates',replace
			* load analysis data
			use `main',clear
			qui: gen pre=foc_year<2007
			keep enrollment_instnr enrollment_school_group enrollment_competition_p50_20k foc_gpa foc_year pre foc_id
			* permutations
			forval iteration=1/`permutations'{
				* reshuffle enrollmet id
				qui: gen sortvar=runiform()
				sort enrollment_school_group foc_year sortvar
				qui: by enrollment_school_group foc_year: gen enrollment_instnrP=enrollment_instnr[_n-1]
				qui: by enrollment_school_group foc_year: replace enrollment_instnrP=enrollment_instnr[_N] if _n==1
				* loop over years
				forval pre=0/1{
					* loop over level of competition
					forval i=0/1{
							* obtain R2
							qui: reg foc_gpa i.enrollment_instnrP if enrollment_competition_p50_20k==`i' & pre==`pre'
							* store
							preserve
								qui: use `estimates',clear
								qui: replace r2_high`i'_pre`pre'_permuted=e(r2) if iteration==`iteration'
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
			qui: gen r2_high0_pre0=.
			qui: gen r2_high1_pre0=.
			qui: gen r2_high0_pre1=.
			qui: gen r2_high1_pre1=.
			qui: save `estimates',replace
			* load analysis data
			use `main',clear
			* loop over years
			gen pre=foc_year<2007
			* loop over years
			forval pre=0/1{
				* loop over level of competition
				forval i=0/1{
						* obtain R2
						qui: reg foc_gpa i.enrollment_instnr if enrollment_competition_p50_20k==`i' & pre==`pre'
						* store
						preserve
							qui:  use `estimates',clear
							qui: replace r2_high`i'_pre`pre'=e(r2) 
							qui: save `estimates',replace
						restore
						}
			}
	/**************************************************************************
		3. Compute difference
	**************************************************************************/			
			use `estimates',clear
			gen _r2_high_pre =r2_high1_pre1-r2_high1_pre1_permuted
			gen _r2_high_post=r2_high1_pre0-r2_high1_pre0_permuted
			gen _r2_low_pre  =r2_high0_pre1-r2_high0_pre1_permuted
			gen _r2_low_post =r2_high0_pre0-r2_high0_pre0_permuted
			keep _*
			gen _dif_post=_r2_high_post-_r2_low_post
			gen _dif_pre =_r2_high_pre -_r2_low_pre
			gen _dif_high=_r2_high_post-_r2_high_pre
			gen _dif_low =_r2_low_post -_r2_low_pre 
			gen _dif_in_dif=_dif_post-_dif_pre
			xpose,clear varname
			mkmat v1, matrix(output) rownames(_varname)
			mat a=output'
			ereturn post a
			use `main',clear
end


/* Estimate for varying level of competition */
use "$tf\analysisdata.dta",clear
bootstrap _b , reps(200) cluster(enrollment_instnr)  : mypermut, permutations(50)
esttab using "$df\tab_GPAsegregation_not_by_year.txt", star(* 0.05) se replace
