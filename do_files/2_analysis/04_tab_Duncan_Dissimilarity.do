* Project: quasi markets and school segregation
* File: duncan dissimilarity
* Last edited: 17/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"

* Define program
cap program drop myprogram
program myprogram,eclass
syntax, var(string)
	tempfile main
	save `main',replace
	* Count the number below and above median GPA in each area
	gen foc_lowgpa=1-foc_highgp
	* calculate shares
	sort foc_year enrollment_sch
	by foc_year enrollment_sch: egen overall_high=sum(foc_highgp)
	by foc_year enrollment_sch: egen overall_low=sum(foc_low)
	sort foc_year enrollment_inst
	by foc_year enrollment_inst: egen school_high=sum(foc_highgp)
	by foc_year enrollment_inst: egen school_low=sum(foc_low)
	* keep one obs per school per year
	by foc_year enrollment_inst: drop if _n>1
	* generate dissimilarity index
	gen dis=abs((school_low/overall_low)-(school_high/overall_high))
	* pre
	gen pre=foc_year<2007
	* sum
	collapse (sum) dis  (firstnm) `var',by(foc_year enrollment_sch)
	replace dis=dis*0.5
	* pre
	gen pre=foc_year<2007
	* mean across groups
	gen dis_pre_low=dis if pre==1 & enrollment_c==0
	gen dis_pre_high=dis if pre==1 & enrollment_c==1
	gen dis_post_low=dis if pre==0 & enrollment_c==0
	gen dis_post_high=dis if pre==0 & enrollment_c==1
	collapse (mean) dis*
	gen did=(dis_post_high-dis_pre_high)-(dis_post_low-dis_pre_low)
	* output
	xpose,clear varname
	mkmat v1, matrix(output) rownames(_varname)
	mat b=output'
	ereturn post b
	use `main',clear
end

/* Estimate for varying level of competition */
* empty dataset to store estimates
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
	save "$tf\estimatesDuncan.dta",replace

* loop over moment
foreach var in mean p50 p25 p75{
* loop over distance
		foreach dist in 5 20{
		* load data
		use "$tf\analysisdata.dta",clear
	
		bootstrap _b , reps(200) cluster(enrollment_instnr)   : myprogram,  var(enrollment_competition_`var'_`dist'k)
		esttab using "$df\tab_DuncanD_`var'_`dist'.txt", star(* 0.05) se replace
		* store
		use "$tf\estimatesDuncan.dta",clear
		replace beta=_b[did] if moment=="`var'" & dist==`dist'
		replace se=_se[did] if moment=="`var'" & dist==`dist'
		save "$tf\estimatesDuncan.dta",replace
		
	}
}

/* create chart */
use "$tf\estimatesDuncan.dta",clear
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
	  yscale(noline) ylabel(0.0(0.02).11, nogrid angle(horizontal) format(%4.2f) noticks) ///
	  xlab(1 "Median" 2 "P25" 3 "P75",noticks)  legend(order (1 "5km" 2 "20km") region(lcolor(white))) ///
	  ytitle("DiD estimate") xtitle("") 
	  graph export "$df\fig_alt_spec_Duncan.png",replace width("4000")

