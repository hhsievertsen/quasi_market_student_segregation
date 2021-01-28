* Project: quasi markets and school segregation
* File: predict graduation
* Last edited: 18/2-2020 by HHS
/* predict graduation*/
* load preamble
do "D:\Data\workdata\704236\xdrev\704236\quasi_market_segregation\do_files\settings.do"
/*************************************************************************
High school GPA 
**************************************************************************/
	use "$rf\udg2013.dta", clear
	* keep first observation
	sort pnr KARAKTER_UDD_VTIL
	by pnr: keep if _n==1
	gen year_finished=year(KARAKTER_UDD_VTIL)
	gen gpa=KARAKTER_UDD/10
	* standardize
	sort year_finished 
	by year_finished: egen sd=sd(gpa)
	by year_finished: egen mean=mean(gpa)
	replace gpa=(gpa-mean)/sd
	keep pnr year_finished gpa
	compress
	save "$tf\gymgradyear.dta", replace
/*************************************************************************
Drop out
**************************************************************************/	
* elevregistet
	 use "$rf\kotre2015.dta", clear
	* Define High school programs
	merge m:1 udd using "$ff\uddan_2013_udd.dta", keep(1 3) nogen
	keep if inlist(M1TEKST,"Gymnasiet")
	keep if udd==1199|udd==1189|udd==1179|udd==1899|udd==1894|udd==1895
	drop M1TEKST h1 H1TEKST
	* year enrolled *
	preserve
		sort pnr udd ELEV3_VFRA
		by pnr udd: keep if _n==1
		gen year_started=year(ELEV3_VFRA)
		keep pnr udd year_started instnr
		save "$tf\enrollmentinhs.dta",replace
	restore 	
	* year graduated
	preserve
		replace audd=0 if audd>=1140 & audd<=1144 /*1. og 2. g*/
		replace audd=0 if audd>=1149 & audd<=1165 /*1. og 2. g*/
		replace audd=0 if audd==1196 /*1. g*/
		replace audd=0 if audd==1197 /*2. g*/
		replace audd=0 if audd==1891 /*1.g pre IB*/
		replace audd=0 if audd==1892 /*2.g pre IB*/
		replace audd=0 if audd==1896 /*1. g int gym*/
		replace audd=0 if audd==1896 /*2. g int gym*/
		replace audd=0 if audd==9999
		keep if audd!=0
		sort pnr udd ELEV3_VFRA
		by pnr udd: keep if _n==1
		gen year_finished=year(ELEV3_VTIL)
		keep pnr udd year_finished instnr
		save "$tf\graduationfromhs.dta",replace
	restore
	* merge
	use "$tf\enrollmentinhs.dta",clear
	merge 1:1 pnr udd instnr using "$tf\graduationfromhs.dta",keep(1 3)
	gen graduatedOntime=year_fin-year_start<=3 
	* keep relevant years
	keep if inlist(year_started,2003,2004,2005,2006)
	drop _merge udd 
	save "$tf\graduation.dta",replace
/*************************************************************************
Analysis sample
**************************************************************************/		
	use "$tf\analysisdata.dta",clear
	keep enrollment_instnr
	bys enrollment_instnr: keep if _n==1
	rename enrollment_instnr instnr
	save "$tf\instnrinsample.dta",replace
/*************************************************************************
Merge sample
**************************************************************************/	
use "$tf\graduation.dta",clear
merge m:1  pnr year_finished using "$tf\gymgradyear.dta",keep(1 3) nogen
* merge with gpa from 9th grade
merge m:1 pnr using "$tf\gpa9.dta", keep(1 3) nogen
* merge to parental background
gen year=year_started-2
merge m:1 pnr year using  "$tf\educ.dta", nogen keep(1 3)
* merge to sample of high schools
merge m:1 instnr using "$tf\instnrinsample.dta", keep(3) nogen
save "$tf\dataforanalysis.dta",replace
* run regression

/*************************************************************************
Figure: Graduation and gpa
**************************************************************************/	
clear 
set obs 50
gen group=_n
gen coefficient=.
gen gpa=.
gen graduated=.
gen upper=.
gen lower=.
save "$tf\estimates.dta",replace

use "$tf\dataforanalysis.dta",clear
drop if gpa_std==.
egen r=xtile(gpa_std), nq(50)
tab r, gen(group)
reg graduated  group1-group50,robust nocons
preserve
	forval i=1/50{

			use "$tf\estimates.dta",clear
				replace graduated=_b[group`i'] if group==`i'
				replace upper=graduated+2*_se[group`i'] if group==`i'
				replace lower=graduated-2*_se[group`i'] if group==`i'
			save "$tf\estimates.dta",replace
		}
restore
forval i=1/50{
	sum gpa_std if r==`i'
	preserve
		use "$tf\estimates.dta",clear
			replace gpa=r(mean) if group==`i'
		save "$tf\estimates.dta",replace
	restore
}
use "$tf\estimates.dta",clear

tw  (rspike upper lower gpa, lcolor(black) lwidth(thin) ) ///
    (scatter graduated gpa, mcolor(black) msize(tiny)) ///
	, plotregion(lcolor(white) fcolor(white)) ///
	  graphregion(lcolor(white) fcolor(white)) ///
	  yscale(noline) ylabel(0.0(0.25)1, nogrid angle(horizontal) format(%4.2f) noticks) ///
	  xlab(-1(0.5)2) note("Note: Each marker shows the average for 2 percent of the observations, the spikes represent the coefficent +/-2* the standard error. " , size(tiny) ) ///
	  xlab(,noticks)  legend(off) xtitle("9th grade GPA (mean=0, SD=1)") ytitle("=1 if graduated from high school")
	  graph export "$df\fig_grad_and_gpa.png",replace width("4000")

/*************************************************************************
Figure: Histogram of graduation by HS
**************************************************************************/		 
use "$tf\dataforanalysis.dta",clear	  
collapse (mean) graduated (count) n=graduated, by(instnr)  fast
drop if n<10
gen r=round(50*graduated)/50
collapse (count) n=n, by(r)
replace r=r*100
tw (bar n r, fcolor(black) lcolor(black) barwidth(1)) , ///
     plotregion(lcolor(white) fcolor(white)) ///
	  graphregion(lcolor(white) fcolor(white)) ///
	  xtitle("Graduated (in %)") ytitle("Number of schools") ///
	  xlab(,nogrid noticks) ylab(,nogrid noticks angle(horizontal)) yscale(noline)
	    graph export "$df\fig_hist_grad.png",replace width("4000")
/*************************************************************************
Regression:Performance and 9th grade GPA
**************************************************************************/		  
use "$tf\dataforanalysis.dta",clear
* run regression	  
eststo clear
eststo: reg graduated  gpa_std ,  cluster(instnr)
eststo: reg graduated  gpa_std  i.instnr, cluster(instnr)
sum graduated
estadd scalar a=r(mean)
eststo: reg gpa gpa_std, cluster(instnr)
eststo: reg gpa gpa_std i.instnr, cluster(instnr)
sum gpa
estadd scalar a=r(mean)
esttab using "$df\tab_predict_gpa.txt", stats(r2 N a) se  replace keep(gpa_std) b(%6.5f)
esttab using "$df\tab_predict_gpap.txt", stats(r2 N a) p  replace keep(gpa_std) b(%6.5f)

* schooling
* run regression
rename mudd schooling
eststo clear
eststo: reg graduated  schooling   ,cluster(instnr)
eststo: reg graduated  schooling  i.instnr, cluster(instnr)
eststo: reg gpa schooling, cluster(instnr)
eststo: reg gpa schooling i.instnr, cluster(instnr)
esttab using "$df\tab_predict_schooling.txt", stats(r2 N a) se  replace keep(schooling)
esttab using "$df\tab_predict_schooling.txtp", stats(r2 N a) p  replace keep(schooling)
