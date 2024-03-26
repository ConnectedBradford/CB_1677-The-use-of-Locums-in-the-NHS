 (The University of Manchester)\Locums local\EPR"
The University of Manchester)\Locums local\EPR\sumTab.dta" , clear
su 
codebook orig_ordered_by_personnel_id_has
codebook wk
codebook ordersperwk
codebook patientsperwk
drop if wk==16
*recode dates
split wkstart, gen(part) p("/")
gen tmp = part1 + part2 + part3
gen weekstart = date(tmp, "DMY")
format weekstart %td
drop part* tmp wkstart
order n orig_ordered_by_personnel_id_has wk weekstart
rename orig_ordered_by_personnel_id_has doctor
encode doctor, gen(docid)
*
drop if wk<38
drop if doctor=="NULL"
bys doctor: egen patientsdoctor=sum(patientsperwk)
bys doctor: egen ordersdoctor=sum(ordersperwk)
su patientsdoctor ordersdoctor, d
bys docid: gen serno2=_n
sort patientsdoctor
*br docid patientsdoctor ordersdoctor if serno2==1
drop if patientsdoctor>6000 // 4 doctors dropped

*ANALYSIS 
codebook weekstart
codebook docid

*fig1 - mean pateints and orders over time
bys wk: egen meanorders=mean(ordersperwk)
bys wk: egen meanpatients=mean(patientsperwk)
bys weekstart: gen serno=_n

twoway bar meanpatients weekstart if serno==1, ytitle("Patients per week") tlabel(24sep2017(60)07nov2021) xtitle("Week") xlabel( , format(%tdDD_Mon_YY)  labsize(small) angle(45)) graphregion( fcolor(white) lcolor(white)) saving(fig1a, replace)

twoway bar meanorders weekstart if serno==1, ytitle("Orders per week") tlabel(24sep2017(60)07nov2021) xtitle("Week") xlabel( , format(%tdDD_Mon_YY)  labsize(small) angle(45)) graphregion( fcolor(white) lcolor(white)) saving(fig1b, replace)

graph combine fig1a.gph fig1b.gph, ysize(4) xsize(8) graphregion( fcolor(white) lcolor(white)) 

*fig2 - pateints and orders over doctors
bys doctor: egen patientsdoctor=sum(patientsperwk)
bys doctor: egen ordersdoctor=sum(ordersperwk)
su patientsdoctor ordersdoctor, d
lab var docid "Doctor ID"
graph bar (first) patientsdoctor if serno2==1, over(docid, lab(nolabel) sort(patientsdoctor)) b1title("Doctor ID") ytitle("Patients per doctor") graphregion( fcolor(white) lcolor(white))  saving(fig2a, replace)

graph bar (first) ordersdoctor if serno2==1, over(docid, lab(nolabel) sort(ordersdoctor)) b1title("Doctor ID") ytitle("Orders per doctor") graphregion( fcolor(white) lcolor(white))  saving(fig2b, replace)

graph combine fig2a.gph fig2b.gph, ysize(4) xsize(8) graphregion( fcolor(white) lcolor(white)) 

*fig3_p99 - pateints and orders over doctors
su patientsdoctor ordersdoctor, d
lab var docid "Doctor ID"
graph bar (first) patientsdoctor if serno2==1&patientsdoctor<2890, over(docid, lab(nolabel) sort(patientsdoctor)) b1title("Doctor ID") ytitle("Patients per doctor") graphregion( fcolor(white) lcolor(white))  saving(fig3a, replace)

graph bar (first) ordersdoctor if serno2==1&ordersdoctor<47490, over(docid, lab(nolabel) sort(ordersdoctor)) b1title("Doctor ID") ytitle("Orders per doctor") graphregion( fcolor(white) lcolor(white))  saving(fig3b, replace)

graph combine fig3a.gph fig3b.gph, ysize(4) xsize(8) graphregion( fcolor(white) lcolor(white)) saving(fig3, replace)

*clean and focus on 52 weeks from start
drop serno2 serno
replace wk=wk-37
drop if wk>52
drop patientsdoctor ordersdoctor
drop meanorders meanpatients
bys doctor: egen patientsdoctor=mean(patientsperwk)
bys doctor: egen ordersdoctor=mean(ordersperwk)
codebook docid if patientsdoctor==0 // 1,620  
drop if patientsdoctor==0
codebook docid // 1461 

*fig4 - pateints and orders over time
su patientsdoctor ordersdoctor, d
su patientsperwk ordersperwk, d
su meanpatients meanorders, d

bys wk: egen meanorders=mean(ordersperwk) if ordersperwk>0
bys wk: egen meanpatients=mean(patientsperwk) if patientsperwk>0
bys weekstart: gen serno=_n

twoway bar meanpatients weekstart, ytitle("Patients per week") tlabel(24sep2017(14)16sep2018) xtitle("Week") xlabel( , format(%tdDD_Mon_YY)  labsize(small) angle(45)) graphregion( fcolor(white) lcolor(white)) saving(fig4a, replace)

twoway bar meanorders weekstart, ytitle("Orders per week") tlabel(24sep2017(15)16sep2018) xtitle("Week") xlabel( , format(%tdDD_Mon_YY)  labsize(small) angle(45)) graphregion( fcolor(white) lcolor(white)) saving(fig4b, replace)

graph combine fig4a.gph fig4b.gph, ysize(4) xsize(8) graphregion( fcolor(white) lcolor(white)) saving(fig4, replace)


*fig5 - pateints and orders over doctors
bys doctor: egen totalordersdoctor=sum(ordersperwk)
su  totalordersdoctor, d
bys docid: gen serno2=_n
graph bar (first) patientsdoctor if serno2==1, over(docid, lab(nolabel) sort(patientsdoctor)) b1title("Doctor ID") ytitle("Patients per doctor") graphregion( fcolor(white) lcolor(white)) yline(167, noextend) yline(78, noextend lp(dash))  saving(fig5a, replace)

graph bar (first) ordersdoctor if serno2==1, over(docid, lab(nolabel) sort(ordersdoctor)) b1title("Doctor ID") ytitle("Orders per doctor") graphregion( fcolor(white) lcolor(white))  yline(1870, noextend) yline(564, noextend lp(dash)) saving(fig5b, replace)

graph combine fig5a.gph fig5b.gph, ysize(4) xsize(8) graphregion( fcolor(white) lcolor(white))  saving(fig5, replace)


* define active weeks
gen active=1 if ordersperwk>0
bys docid (wk): egen docactive=sum(active) 

tabplot docactive if serno2==1, showval(offset(0.5))  horizontal  ytitle(Weeks active) ylabel(,labsize(small)) subtitle(Doctors active (count)) ysize(16) graphregion( fcolor(white) lcolor(white)) saving(fig6a, replace)
tabplot docactive if serno2==1, showval(offset(0.5))  horizontal percent ytitle(Weeks active) ylabel(,labsize(small)) subtitle(Doctors active (%)) ysize(16) graphregion( fcolor(white) lcolor(white)) saving(fig6b, replace)
graph combine fig6a.gph fig6b.gph, ysize(12) xsize(8) graphregion( fcolor(white) lcolor(white))  saving(fig6, replace)


*find 3 locums and 3 perm and tab plot and write up

*define very short term locums
tab wk if active==1 
tabplot wk if active==1, showval(offset(0.5)) horizontal  ytitle(Week number) ylabel( , labsize(small)) title() subtitle(Doctors active (count)) ysize(16) graphregion( fcolor(white) lcolor(white)) saving(fig7a, replace)

tab wk if active==1&docactive==1 
codebook docid if docactive==1
tabplot wk if active==1&docactive==1 , showval(offset(0.3)) horizontal  ytitle(Week number, xoffset(-4)) ylabel( , labsize(small)) subtitle(1 week) ysize(16) graphregion( fcolor(white) lcolor(white)) saving(fig7b, replace)

tab wk if active==1&docactive==2 
codebook docid if docactive==2
tabplot wk if active==1&docactive==2 , showval(offset(0.3)) horizontal  ytitle("") ylabel( , labsize(small)) subtitle(2 weeks) ysize(16) graphregion( fcolor(white) lcolor(white)) saving(fig7c, replace)

tab wk if active==1&docactive==3 
tabplot wk if active==1&docactive==3 , showval(offset(0.3)) horizontal  ytitle("") ylabel( , labsize(small)) subtitle(3 weeks) ysize(16) graphregion( fcolor(white) lcolor(white)) saving(fig7d, replace)

tab wk if active==1&docactive==4
tabplot wk if active==1&docactive==4 , showval(offset(0.3)) horizontal  ytitle("") ylabel( , labsize(small)) subtitle(4 weeks) ysize(16) graphregion( fcolor(white) lcolor(white)) saving(fig7e, replace)

graph combine fig7b.gph fig7c.gph fig7d.gph fig7e.gph, title("Doctors worked in only...", size(small)) r(1) ysize(14) xsize(10) graphregion( fcolor(white) lcolor(white))  saving(fig7, replace)

tab wk if active==1&docactive<5
tabplot wk if active==1&docactive<5 , showval(offset(0.5)) horizontal  ytitle(Week number) ylabel( , labsize(small)) subtitle(Doctors active (count)) ysize(16) graphregion( fcolor(white) lcolor(white))


tab wk if active==1&docactive<5

tabplot docactive if serno2==1, showval(offset(0.5))  horizontal  ytitle(Weeks active) ylabel(,labsize(small)) subtitle(Doctors active (count)) ysize(16) graphregion( fcolor(white) lcolor(white)) saving(fig6a, replace)

*define short term locums
gen week1=docactive==1
tab week1 if serno2==1
replace week1=0 if active==1&wk==1
replace week1=0 if active==1&wk==2
replace week1=0 if active==1&wk==52
bys docid: egen week11=min(week1)
tab week11 if serno2==1
drop week1 
rename week11 week1

gen temp=docactive==2
tab temp if serno2==1
replace temp=0 if active==1&wk==1
replace temp=0 if active==1&wk==2
replace temp=0 if active==1&wk==51
replace temp=0 if active==1&wk==52
bys docid: egen week2=min(temp)
tab week2 if serno2==1
drop temp 

gen temp=docactive==3
tab temp if serno2==1
replace temp=0 if active==1&wk==1
replace temp=0 if active==1&wk==2
replace temp=0 if active==1&wk==3
replace temp=0 if active==1&wk==50
replace temp=0 if active==1&wk==51
replace temp=0 if active==1&wk==52
bys docid: egen week3=min(temp)
tab week3 if serno2==1
drop temp 

gen temp=docactive==4
tab temp if serno2==1
replace temp=0 if active==1&wk==1
replace temp=0 if active==1&wk==2
replace temp=0 if active==1&wk==3
replace temp=0 if active==1&wk==4
replace temp=0 if active==1&wk==49
replace temp=0 if active==1&wk==50
replace temp=0 if active==1&wk==51
replace temp=0 if active==1&wk==52
bys docid: egen week4=min(temp)
tab week4 if serno2==1
drop temp 

gen locum=0
replace locum=1 if week1==1|week2==1|week3==1|week4==1
tab locum if serno2==1
tabplot wk if active==1&locum==1 , showval(offset(0.5)) horizontal  ytitle(Week number) ylabel( , labsize(small)) subtitle(Doctors active (count)) ysize(16) graphregion( fcolor(white) lcolor(white))



bys doctor: egen meanpatientsdoctor=mean(patientsperwk) if active==1
bys doctor: egen meanordersdoctor=mean(ordersperwk) if active==1
bys locum: su meanpatientsdoctor meanordersdoctor

bys locum: egen totalp=sum(patientsperwk)
bys locum: egen totalo=sum(ordersperwk)


bys locum: su totalp totalo
* 494/243740 = 0.20%
* 4133/2723835 = 0.15%

tabplot wk if docactive==1&active==1, showval(offset(0.5))   ytitle(Weeks active) ylabel(,labsize(small)) subtitle(xxx) graphregion( fcolor(white) lcolor(white)) 

tab wk if docactive<=10&active==1
tabplot wk if docactive==10&active==1, showval(offset(0.5))   ytitle(Weeks active) ylabel(,labsize(small)) subtitle(xxx) graphregion( fcolor(white) lcolor(white)) 












