* Project: quasi markets and school segregation
* File: catchment area data
* Last edited: 6/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
* load data on regions
use "$rf\highschool_areas.dta",clear
* crate indicator for one obs per area
egen tag=tag(ford)
* mean number of competitors:
sort fordelingsudvalg
foreach d in 5 20{
	* calculate average number of institutions with `d' km
		by fordelingsudvalg: egen m=mean(numastx`d'km)
	* indicator if area is above median	
		qui: sum m if tag==1,d
		gen competition_p50_`d'k=1 if m>r(p50)
		replace competition_p50_`d'k=0 if m<=r(p50)
	* indicator if area is above  p25
		qui: sum m if tag==1,d
		gen competition_p25_`d'k=1 if m>r(p25)
		replace competition_p25_`d'k=0 if m<=r(p25)
	* indicator if area is above  p75
		qui: sum m if tag==1,d
		gen competition_p75_`d'k=1 if m>r(p75)
		replace competition_p75_`d'k=0 if m<=r(p75)
	* indicator if area is above  above mean	
		qui: sum m if tag==1
		gen competition_mean_`d'k=1 if m>r(mean)
		replace competition_mean_`d'k=0 if m<=r(mean)
	* rename level of competition
		rename m competion_level_`d'k
}
rename fordelingsudvalg school_group 
* keep and save
keep instnr competition* school_group competion_level*
compress
save "$tf\instdata.dta",replace
	
	
