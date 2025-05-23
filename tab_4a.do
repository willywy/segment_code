set more off
clear all
cd "C:\Users\User\Project\segment"

global output_path "C:\Users\User\Project\segment\output"

use "30_sample.dta", clear

destring sic, replace
drop if sic >= 6000 & sic < 7000

egen meanq = mean(q)
egen sdq = sd(q)
replace q = (q - meanq) / sdq

egen meancfo = mean(cfo)
egen sdcfo = sd(cfo)
replace cfo = (cfo - meancfo) / sdcfo

su TREAT POST lead1_capxassets q cfo size, de
foreach var in lead1_capxassets size {
    winsor2 `var', replace cuts(1 99)
}


eststo clear
capture estimates drop model*

quietly {
    reghdfe lead1_capxassets q cfo /* 
    */ , absorb(gvkey year) vce(cluster sic2)
    estimates store model1

    reghdfe lead1_capxassets q cfo i.TREAT#i.POST c.q#i.TREAT c.q#i.POST c.q#i.TREAT#i.POST /* 
    */ , absorb(gvkey year) vce(cluster sic2)
    estimates store model2

    reghdfe lead1_capxassets q cfo i.TREAT#i.POST c.q#i.TREAT c.q#i.POST c.q#i.TREAT#i.POST /* 
    */ c.cfo#i.TREAT c.cfo#i.POST c.cfo#i.TREAT#i.POST size /*
    */ , absorb(gvkey year) vce(cluster sic2)
    estimates store model3
}
estfe model*, labels(fyearq "Year FE" sic2 "Industry FE" GVKEY "Firm FE")
return list
esttab model*, replace plain b(3) t(2) ar2(2) nogap depvars star(* 0.10 ** 0.05 *** 0.01) /*
    */ keep(q cfo 1.TREAT#1.POST 1.TREAT#c.q 1.POST#c.q 1.TREAT#1.POST#c.q /*
    */ 1.TREAT#c.cfo 1.POST#c.cfo 1.TREAT#1.POST#c.cfo size) /*
    */ indicate(`r(indicate_fe)')

estfe model*, labels(year "Year FE" gvkey "Firm FE")
return list
esttab model* using "$output_path/tab_4a.csv", replace plain b(3) t(2) ar2(2) depvars star(* 0.10 ** 0.05 *** 0.01) /*
    */ keep(q cfo 1.TREAT#1.POST 1.TREAT#c.q 1.POST#c.q 1.TREAT#1.POST#c.q /*
    */ 1.TREAT#c.cfo 1.POST#c.cfo 1.TREAT#1.POST#c.cfo size) /*
    */ indicate(`r(indicate_fe)')