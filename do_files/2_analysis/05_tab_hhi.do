* Project: quasi markets and school segregation
* File: HHI
* Last edited: 18/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
use "$tf\analysisdata.dta",clear


* Define program
cap program drop myprogram
program myprogram,eclass
	* tempfile
	tempfile data
	save `data',replace
	* calculate high gpa
	collapse (mean)  foc_highgpa (sum) n_high=foc_highgpa (firstnm) enrollment_competition_p50_20k , ///
		by(enrollment_instnr foc_year) fast
	* calc s
	bys foc_year: egen totalhigh=sum(n_high)
	gen s=n_high/totalhigh
	gen s2=s*s
	* sum by area
	collapse (sum) s2,by( enrollment_competition_p50_20k foc_year) fast
	gen pre=foc_year<2007
	collapse (sum) s2,by(pre enrollment_competition_p50_20k pre) fast
	gen s2_pre_low=s2 if pre==1 & enr==0
	gen s2_pre_high=s2 if pre==1 & enr==1
	gen s2_post_low=s2 if pre==0 & enr==0
	gen s2_post_high=s2 if pre==0 & enr==1
	collapse (firstnm) s2_*
	gen pre_dif=s2_pre_high-s2_pre_low
	gen post_dif=s2_post_high-s2_post_low
	gen high_dif=s2_post_high-s2_pre_high
	gen low_dif=s2_post_low-s2_pre_low
	gen did=post_dif-pre_dif
	* output
	xpose,clear varname
	mkmat v1, matrix(output) rownames(_varname)
	mat b=output'
	ereturn post b
	use `data',clear
end
bootstrap _b , reps(200) cluster(enrollment_instnr)   : myprogram
esttab using "$df\tab_hhi.txt", star(* 0.05) se replace
