set more off
clear all
cd "C:\Users\User\Project\segment"

global output_path "C:\Users\User\Project\segment\output"

use "30_sample.dta", clear

keep if illiq != . & prc_inv != . & size != .
count //10,932

eststo clear
capture estimates drop model*

quietly {
    reghdfe illiq i.TREAT##i.POST /* 
    */ , absorb(gvkey year) vce(cluster sic2)
    estimates store model3

    reghdfe illiq i.TREAT##i.POST /* 
    */ size  prc_inv /*
    */ , absorb(gvkey year) vce(cluster sic2)
    estimates store model4
}
estfe model*, labels(fyearq "Year FE" sic2 "Industry FE" GVKEY "Firm FE")
return list
esttab model*, replace plain b(3) t(2) ar2(2) nogap depvars star(* 0.10 ** 0.05 *** 0.01) /*
     */ keep(1.TREAT#1.POST size prc_inv) /*
    */ indicate(`r(indicate_fe)')

estfe model*, labels(year "Year FE" gvkey "Firm FE")
return list
esttab model* using "$output_path/tab_3a.csv", replace plain b(3) t(2) ar2(2) depvars star(* 0.10 ** 0.05 *** 0.01) /*
    */ keep(1.TREAT#1.POST size prc_inv) /*
    */ indicate(`r(indicate_fe)')