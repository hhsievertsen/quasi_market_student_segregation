* Project: quasi markets and school segregation
* File: Fraction of gifted students
* Last edited: 18/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
use "$tf\analysisdata.dta",clear
bys foc_year enrollment_school_group: egen p90=pctile(foc_gpa), p(90)
bys foc_year enrollment_school_group: egen p10=pctile(foc_gpa), p(10)
gen topstudent=foc_gpa>=p90
gen bottomstudent=foc_gpa<p10
collapse (mean) topstudent bottomstudent, by(enrollment_instnr)
hist topstudent ,lcolor(white) fcolor(black) ///
     plotregion(lcolor(white) fcolor(white)) ///
	  graphregion(lcolor(white) fcolor(white)) ///
	  xtitle("Fraction of top students") ytitle("Density") ///
	  xlab(,nogrid noticks) ylab(,nogrid noticks angle(horizontal)) yscale(noline)
	    graph export "$df\fig_topstudents.png",replace width("4000")
	
