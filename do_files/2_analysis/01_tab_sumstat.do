* Project: quasi markets and school segregation
* File: summary statistics table
* Last edited: 6/2-2020 by HHS
* load global settings
do "X:\Data\Workdata\704236\quasi_market_segregation\do_files\settings.do"
/* Loop over pre, post and overall */
foreach var in post overall pre {
	* Load dataset 
	use "$tf\analysisdata.dta",clear
	if "`var'"=="pre"{
		drop if foc_year>2006
	}
	else if "`var'"=="post"{
		drop if foc_year<2007
	}
	* schools in district
	egen tagschools=tag(enrollment_instnr foc_year)
	gen ratio=gym_app/gym_enr
	bys enrollment_school_group foc_year: egen schools_in_district=sum(tagschools)
	* aggregate on high school level
	collapse (mean) gym_enr ratio foc_female foc_une foc_gpa foc_highgpa foc_par prirorities_used foc_age enrollment_competition_p50_20k schools_in_district ///
			 (count) n=foc_gpa ///
			 ,by(enrollment_i) fast
	* labels
	label var foc_age "Age at enrollment"
	label var foc_gpa "9th grade GPA"
	label var foc_highgpa "GPA above cohort median"
	label var foc_female "Female"
	label var foc_par "Parental years of schooling"
	label var enrollment_competition_p50_20k "High-competition area"
	label var foc_une "Unemployment"
	label var schools_in_district "Schools in district"
	label var gym_enr "Enrollment"
	label var ratio "1st priority/Enrolled"
	label var prirorities_used "Priorities used"
	* create table
	cap file close f 
	* write means and SD
	file open f using "$df\tab_descriptive_statistics_`var'.txt",replace write
		foreach var in prirorities_used foc_female foc_gpa foc_highgpa foc_par foc_age enrollment_competition_p50_20k  foc_une  schools_in_district gym_enr ratio{
		qui: sum `var',
		local v1: disp %10.2f r(mean)
		local v2: disp %10.2f r(sd)
		qui: sum `var' if enrollment_competition_p50_20k==0,
		local v3: disp %10.2f r(mean)
		qui: sum `var' if enrollment_competition_p50_20k==1,
		local v4: disp %10.2f r(mean)		
		local lab: variable lab `var'
		file write f "`lab';`v1';`v2';`v3';`v4'"_n
	}
	* number of schools
	qui: tab enrollment_instnr
	local s1=r(r)
	qui: tab enrollment_instnr if enrollment_competition_p50_20k==0,
	local s2=r(r)
	qui: tab enrollment_instnr if enrollment_competition_p50_20k==1,
	local s3=r(r)
	file write f "Number of schools;`s1';;`s2';`s3'"_n
	* close file
	file close f
		
	
}

