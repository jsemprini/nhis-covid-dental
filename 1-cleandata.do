clear all

use "C:\Users\jsemprini\OneDrive - University of Iowa\4-Misc Projects\d-NHIS-covid\nhis_raw\2019-2020_nhis_label_050222.dta"


*id 2019-2020 cohort*

gen cohortid=nhispidprvyr if year==2020
replace cohortid=nhispid if year==2019

 duplicates tag cohortid, generate(samplecohort)
 
tab year samplecohort, missing

drop if samplecohort!=1

tab year samplecohort, missing

egen id = group(cohortid)

sum id

order id


****clean potential controls****

gen x_age= age if age<86

gen x_male=0 if sex==2
replace x_male=1 if sex==1

tab marstat if marstat!=99, gen(x_mar) nolab

tab racea 
tab racea , nolab

tab racea if racea!=980, gen(race)

sum race*

gen x_white=.
replace x_white=0 if race1==0 & race6==0
replace x_white=1 if race1==1

tab hispeth, nolab
tab hispeth, gen(hisp)

gen x_nothisp=.
replace x_nothisp=0 if hisp1==2 | hisp2==1
replace x_nothisp=1 if hisp1==1


tab usborn citizen, missing

tab citizen, nolab
tab citizen, gen(cit)

gen x_citizen=0 if cit1==1
replace x_citizen=1 if cit2==1


tab educ, nolab
tab educ, gen(ed)

gen x_hsorless=0 if ed1!=1 & ed2!=1 & ed3!=1 & ed4!=1 & educ<900
replace x_hsorless=1 if ed1==1 | ed2==1 | ed3==1 | ed4==1 

gen x_somecol=0 if ed6!=1 & ed7!=1 & ed8!=1 & educ<900
replace x_somecol=1 if ed6==1 | ed7==1 | ed8==1

gen x_atleastbach=.
replace x_atleastbach=0 if x_hsorless==1 | x_somecol==1
replace x_atleastbach=1 if x_hsorless==0 & x_somecol==0 & educ<900

sum ed*
foreach n of numlist 1/14{
	drop ed`n'
}

tab spouseduc, missing nolab
tab spouseduc, gen(ed)

 gen x_sphsorless=0 if ed1!=1 & ed2!=1 & ed3!=1 & ed4!=1 & educ<900
replace x_sphsorless=1 if ed1==1 | ed2==1 | ed3==1 | ed4==1 

gen x_spsomecol=0 if ed6!=1 & ed7!=1 & ed8!=1 & educ<900
replace x_spsomecol=1 if ed6==1 | ed7==1 | ed8==1

gen x_spatleastbach=.
replace x_spatleastbach=0 if x_sphsorless==1 | x_spsomecol==1
replace x_spatleastbach=1 if x_sphsorless==0 & x_spsomecol==0 & educ<900

tab empstat, nolab
tab empstat

gen x_employed=0 if empstat==200
replace x_employed=1 if empstat==100

tab emplast, nolab

gen x_uethisyr=0 if empstat!=999 & emplast<7
replace x_uethisyr=1 if emplast==1

tab paidsick , nolab

gen x_sickleave=0 if paidsick<7
replace x_sickleave=1 if paidsick==2

tab emphi, nolab
tab emphi 

gen x_work_hi=0 if emphi<7
replace x_work_hi=1 if emphi==2


tab empft, nolab
tab empft

gen x_fulltime=0 if empft<7
replace x_fulltime=1 if empft==2

tab incfam07on, gen(x_hhinc)

tab poverty, gen(x_pov)

*****clean / code dependent and instrument variables (health, insurance)***

foreach x in painfreq3mo painfeelevl paintooth3m{ 
	
	tab year `x', missing
}

tab dentint, nolab
tab dentint

gen y_delaydt=0 if delaydt==1
replace y_delaydt=1 if delaydt==2

gen y_unabledt=0 if unmtnddt==1
replace y_unabledt=1 if unmtnddt==2

tab dentint if dentint<900, gen(lastdent)

sum lastdent*

rename (lastdent*) (y_neverdent y_01yrdent y_12yrdent y_23yrdent y_35yrdent y_59yrdent y_10dent)

tab hinotyrmo, nolab
tab hinotyrmo

gen h_uninsured=0 if hinotcov==1
replace h_uninsured=1 if hinotcov==2

gen h_private=0 if hiprivatee==1
replace h_private=1 if hiprivatee==2 | hiprivatee==3

gen h_military=0 if himilite==10
replace h_military=1 if himilite==25

gen h_medicaid=0 if himcaide==1
replace h_medicaid=1 if himcaide==2 | himcaide==3

gen h_medicare=0 if himcaree==1
replace h_medicare=1 if himcaree==2 | himcaree==3

gen h_lastinrp12mo=.
replace h_lastinrp12mo=0 if hilast<90
replace h_lastinrp12mo=1 if hilast==14

gen h_uninsuredp12mo=.
replace h_uninsuredp12mo=0 if hinotyr<7
replace h_uninsuredp12mo=1 if hinotyr==2

tab hinotyrmo if hinotyrmo<90, gen(h_mouninsured)

tab hip1dental, nolab
tab hip1dental

gen z_dentcov=0 if hip1dental==0 | hip1dental==1
replace z_dentcov=1 if hip1dental==2

tab opioidcpain, nolab
tab opioidcpain

gen y_oap=0 if opioidapain==0 | opioidapain==1
replace y_oap=1 if opioidapain==2

gen y_ocp=0 if opioidcpain==0 | opioidcpain==1
replace y_ocp=1 if opioidcpain==2
 
tab painfeelevl, nolab
tab painfeelevl

tab painfreq3mo if painfreq3mo<7, gen(y_painfreq3mo)

tab painfeelevl if painfeelevl<7, gen(y_painlevel)

tab paintooth3m, nolab
tab paintooth3m

tab paintooth3m if paintooth3m<7 , gen(t_toothpain)
gen t_toothpainx=1 if t_toothpain1==1 | t_toothpain2==1
replace t_toothpainx=0 if t_toothpain3==1 | t_toothpain4==1 | t_toothpain5==1
drop t_toothpain1	t_toothpain2
rename t_toothpainx t_toothpain1

tab t_toothpain1 y_painlevel1

anova y_painlevel1 t_toothpain1 if year==2019
reg y_painlevel1 t_toothpain1 if year==2019


****cleat covid/chronic disease variables****
gen g_asthmaev=0 if asthmaev==1
replace g_asthmaev=1 if asthmaev==2

gen g_astmanow=0 if g_asthmaev==0 | asthmastil==1
replace g_astmanow=1 if asthmastil==2

gen g_cancer=0 if cancerev==1
replace g_cancer=1 if cancerev==2

gen g_heartdis=0 if cheartdiev==1
replace g_heartdis=1 if cheartdiev==2

gen g_highcholev=0 if cholhighev==1
replace g_highcholev=1 if cholhighev==2

gen g_highcholyr=0 if g_highcholev==0 | cholhighyr==1
replace g_highcholyr=1 if cholhighyr==2

gen g_diab=0 if diabeticev==1
replace g_diab=1 if diabeticev==2

gen g_heartattackev=0 if heartattev==1
replace g_heartattackev=1 if heartattev==2

gen g_hypertenev=0 if hypertenev==1
replace g_hypertenev=1 if hypertenev==2

gen g_hypertenyr=0 if g_hypertenev==0 | hypertenyr==1
replace g_hypertenyr=1 if hypertenyr==2

gen g_stroke= 0 if strokev==1 
replace g_stroke=1 if strokev==2

gen g_copd=0 if copdev==1
replace g_copd=1 if copdev==2

gen anycdev=0
foreach y in g_asthmaev  g_cancer g_heartdis g_highcholev  g_diab g_heartattackev g_hypertenev  g_stroke g_copd{ 
	
	replace anycdev=1 if `y'==1

}
gen nowcd=0
foreach y in g_astmanow g_highcholyr g_hypertenyr{
	replace nowcd=1 if `y'==1
}

gen totalcdev=g_asthmaev+g_cancer+g_heartdis+g_highcholev+g_diab+g_heartattackev+g_hypertenev+g_stroke+g_copd

rename totalcdev g_totalcddev

gen g_cooccuevr=0 if g_totalcddev<=1
replace g_cooccuevr=1 if g_totalcddev>1

gen g_totalcdnow=g_astmanow+g_highcholyr+g_hypertenyr

gen g_cooccuryr=0 if g_totalcdnow<=1
replace g_cooccuryr=1 if g_totalcdnow>1

tab bmicat if bmicat<5, gen(g_bmi)

gen g_overweight=0 if bmicat<=2
replace g_overweight=1 if bmicat==3 | bmicat==4

*****covid*****
gen c_coviddiag=0 if cvddiag==1
replace c_coviddiag=1 if cvddiag==2

gen c_covidtest=0 if cvdtest==1
replace c_covidtest=1 if cvdtest==2

gen c_covidpostest=0 if c_covidtest==0 | cvdtestrslt==1 | cvdtestrslt==3 
replace c_covidpostest=1 if cvdtestrslt==2

tab cvdsymp if cvdsymp<7, gen(c_symp)

gen c_delaycare=0 if cvddlycare==1
replace c_delaycare=1 if cvddlycare==2

gen c_missedneededcare=0 if cvddngcare==1
replace c_missedneededcare=1 if cvddngcare==2


keep id year serial quarter strata psu nhishid intervwqtr region urbrrl pernum nhispid nhispidprvyr hhx sampweight longweight partweight x_* h_* y_* t_* z_* g_* c_*  bmicalc

save "C:\Users\jsemprini\OneDrive - University of Iowa\4-Misc Projects\d-NHIS-covid\stata_data\nhis_covid_cohort_toanalyze_050222.dta", replace