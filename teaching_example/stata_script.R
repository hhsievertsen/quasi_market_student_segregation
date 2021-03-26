// replicate DiD charts/results for Quasi-Market Competition in Public Service Provision: User Sorting and Cream Skimming
// Hans Henrik Sievertsen (h.h.sievertsen@bristol.ac.uk), March 2021

// clear workspace
clear
// set working directory
cd "C:/github/quasi_market_student_segregation/teaching_example"
// load data
import delimited "did_data.csv"
// create DiD plot
tw (connected segregation year if type=="Control") ///
   (connected segregation year if type=="Treated") ///
   ,graphregion(fcolor(white)) plotregion(fcolor(white) lcolor(white)) ///
   ylab(0(0.01)0.07) legend(order(1 "Control" 2 "Treated") position(12) region(lcolor(white))) ///
   ytitle("Segregation") xtitle(" ") xline(2006.5)

   
// Compare means
sum if year<2007 & type=="Control"
local pre_control=r(mean)
sum if year<2007 & type=="Treated"
local pre_treated=r(mean)
sum if year>=2007 & type=="Control"
local post_control=r(mean)
sum if year>=2007 & type=="Treated"
local post_treated=r(mean)
local post_dif=`post_treated'-`post_control'
local pre_dif=`pre_treated'-`pre_control'
local did=`post_dif'-`pre_dif'
di "Difference post: `post_dif'" 
di "Difference pre: `pre_dif'"
di "Difference-in-differences: `did''"


// regression
gen Post=year>2006
gen Treated=type=="Treated"
gen PostXTreated=Post*Treated
// Estimate model with OLS
reg segregation Post Treated PostXTreated
