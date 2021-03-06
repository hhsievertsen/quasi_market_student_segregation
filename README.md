# Quasi-Market Competition in Public Service Provision: User Sorting and Cream Skimming
 
 

[Sejr Guul, T., Hvidman, U., & Henrik Sievertsen, H. (2021) "Quasi-market competition in public service provision: User sorting and cream-skimming." Journal of Public Administration Research and Theory.](https://academic.oup.com/jpart/advance-article-abstract/doi/10.1093/jopart/muab002/6134454?redirectedFrom=fulltext)

Note: see the folder "teaching_example" for an R script, a Stata do file, and a simplified version of the data that allows you to replicate the main findings in the paper. You can also use [this dynamic tutorial in R](https://hhsievertsen.shinyapps.io/r_tutorial_guul_et_al/)

### Contents

#### do_files

The folder "do_files" contains all Stata do files used to create the analysis dataset and all figures and tables in the paper and the online appendix.



#### Data

The project is based on confidential individual level register data from Statistics Denmark that cannot be shared publicly. However, we encourage researchers who wish to replicate our findings to apply for access to Statistics Denmark through a recognized institutions (for example a Danish University or Research Institute) and ask for the following data:

- **Sample**: All individuals who enrolled in upper-secondary education in Denmark in the period 2000 to 2011 and their parents.
- **Variables**:

  - *pnr* (personal identifier, anonymized)
  - *koen* (gender)
  - *foed_dag* (date of birth: only required if sample is not already restricted by age)
  - *hfaudd* (highest completed educational degree)
  - *koen* (gender)
  - *kltrin* (grade)
  - *grundskolekarakter* (mark)
  - *skoleaar* (school year)
  - *udd* (educational program)
  - *ELEV3_VFRA* (enrollment date)
  - *instnr* (institution identifier)
  - *kom* (municipality)

Using the personal identifier, we merged the data with data from  the Ministry of Education we obtained data on students' applications containing the following variables:

- *dwid_kalenderaar* (year applied)
- *prioritet* (priority)
- *til_udd* (educational program)
- *til_institution* (institution applied to)

Using the variable on the municipality of residence we merged the data with the following three datasets from Statistics Denmark's public database (https://statistikbanken.dk/statbank5a/default.asp?w=1680): AARD, AULP01X, and AULP01,


Please contact Hans H. Sievertsen if you have any questions regarding the data (h.h.sievertsen@bristol.ac.uk). The project ID at Statistics Denmark is 704236. 

