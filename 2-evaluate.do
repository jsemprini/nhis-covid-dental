
global visit_outcomes y_delaydt y_unabledt y_neverdent y_01yrdent y_12yrdent y_23yrdent y_35yrdent y_59yrdent y_10dent z_dentcov

global controls x_age x_male x_mar1 x_mar2 x_mar3 x_mar4 x_mar5 x_white x_nothisp x_citizen x_hsorless x_somecol x_atleastbach x_sphsorless x_spsomecol x_spatleastbach x_employed x_uethisyr x_sickleave x_work_hi x_fulltime x_hhinc1 x_hhinc2 x_hhinc3 x_hhinc4 x_hhinc5 x_pov1 x_pov2 x_pov3 x_pov4 x_pov5 x_pov6 x_pov7 x_pov8 x_pov9 x_pov10 x_pov11 x_pov12 x_pov13 x_pov14

global hi_controls h_uninsured h_private h_military h_medicaid h_medicare h_lastinrp12mo h_uninsuredp12mo h_mouninsured1 h_mouninsured2 h_mouninsured3 h_mouninsured4 h_mouninsured5 h_mouninsured6 h_mouninsured7 h_mouninsured8 h_mouninsured9 h_mouninsured10 h_mouninsured11 h_mouninsured12 h_mouninsured13

global cd_groups g_asthmaev g_astmanow g_cancer g_heartdis g_highcholev g_highcholyr g_diab g_heartattackev g_hypertenev g_hypertenyr g_stroke g_copd g_totalcddev g_cooccuevr g_totalcdnow g_cooccuryr g_bmi1 g_bmi2 g_bmi3 g_bmi4 g_overweight



tab region , gen(geo)
tab urbrrl, gen(metro)

***carryforward weight to 2019 observations****
gen cf=0 if year==2020
replace cf=1 if year==2019
xtset id cf

****Requires: ssc install carryforward*****
bysort id: carryforward longweight, gen(finalwt)

foreach c in c_coviddiag c_covidtest c_covidpostest c_symp1 c_symp2 c_symp3 c_symp4 c_symp5 c_delaycare c_missedneededcare{
	
	bysort id: carryforward `c', gen(`c'_full)
}

****create four groups of dental insurance: 00, 01, 10, 11*****
bysort id: carryforward z_dentcov, gen(di_20)

xtset id year

bysort id: carryforward z_dentcov, gen(di_19)

tab di_19 di_20, missing

replace di_20=0 if di_20==.
replace di_19=0 if di_19==.

gen di_cat=.
replace di_cat=1 if di_19==0 & di_20==0
replace di_cat=2 if di_19==1 & di_20==0
replace di_cat=3 if di_19==0 & di_20==1
replace di_cat=4 if di_19==1 & di_20==1

* 1 - never (0,0), 2- early only (1,0), 3 - late only (0,1), 4 - both (1,1)


*** 4% decline in annual visit, 1% increase in pain4****
estimates clear
foreach y in $visit_outcomes {
	
	eststo: xtreg `y' i.year [pw=finalwt], vce(cluster id) fe
}


*** by dental health insurance groups*****
estimates clear
foreach y in  y_delaydt y_unabledt y_neverdent y_01yrdent y_12yrdent {
	foreach n of numlist 1/4{
	
	eststo: xtreg `y' i.year [pw=finalwt] if di_cat==`n', vce(cluster id) fe
}
}



*****design subgroups: 1) risk ; 2) region/rural****

gen cat1=1 if region==1
gen cat2=1 if region==2 
gen cat3=1 if region==3
gen cat4=1 if region==4
gen cat5=1 if urbrrl==1
gen cat6=1 if urbrrl==2
gen cat7=1 if urbrrl==3
gen cat8=1 if urbrrl==4
gen cat9=1 if g_totalcddev==0
gen cat10=1 if g_totalcddev>0
gen cat11=1 if g_cooccuevr==0
gen cat12=1 if g_cooccuevr>0
gen cat13=1 if x_age<40
gen cat14=1 if x_age>=40 & x_age<65
gen cat15=1 if x_age>=65 & x_age<75
gen cat16=1 if x_age>=75



estimates clear
foreach n of numlist 1/16{
foreach y in $visit_outcomes {
	
	eststo: xtreg `y' i.year if cat`n'==1 [pw=finalwt], vce(cluster id) fe
}


}
estimates clear



