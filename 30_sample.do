set more off
clear all
cd "C:\Users\User\Project\segment"

use "2_ccm_crsp_fundamental\1_ccm_crsp_fundamental.dta", clear

********************************************************
** 1. Merge with Segment Data
********************************************************
// merge with segment data
merge 1:1 gvkey year using "1_segment\1_segment.dta"
keep if _merge == 3
drop _merge

gen month = month(datadate)
keep if month == 12

********************************************************
** 2. Treatment Assignment
********************************************************
preserve
keep year num_segments gvkey
keep if year >= 1996 & year <= 1999
reshape wide num_segments, i(gvkey) j(year)
keep if !missing(num_segments1997) & !missing(num_segments1998)

gen chng_seg = num_segments1998 - num_segments1997

gen TREAT = 0
replace TREAT = 1 if chng_seg > 0
label variable TREAT "1 if more segments in POST than PRE, 0 otherwise"

keep gvkey TREAT chng_seg
tempfile treatment
save `treatment'
restore

* Merge treatment variable back to main dataset
merge m:1 gvkey using `treatment'
keep if _merge == 3
drop _merge

gen POST = 0
replace POST = 1 if year >= 1998
label variable POST "1 if year >= 1998, 0 otherwise"

tab TREAT POST
distinct gvkey if TREAT == 1
distinct gvkey if TREAT == 0

destring gvkey, replace


********************************************************
** 2+. Extract Sample Firm list for CRSP Trading Data
********************************************************
preserve
keep gvkey
duplicates drop
outfile gvkey using "2_gvkey_list.txt", replace
restore

preserve
keep LPERMNO
duplicates drop
outfile LPERMNO using "2_permno_list.txt", replace
restore

********************************************************
** 3. Merge with CRSP Trading Data
********************************************************
merge 1:1 LPERMNO year using "3_crsp_stock\1_illiquidity.dta"
drop if _merge == 2
drop _merge
count if missing(illiq)

********************************************************
** 4. gen key variables
********************************************************
xtset gvkey year
gen lead1_capx = f.capx
gen lead1_year = f.year
drop if lead1_year - year != 1

// Drop observations with missing lead1_capx
drop if missing(lead1_capx)
/* gen lead1_capxassets = lead1_capx/ppent */
gen lead1_capxassets = lead1_capx/ppegt
/* gen lead1_capxassets = lead1_capx/at */
label variable lead1_capxassets "capital expenditures (data item CAPX) as of year t +1 scaled by fixed assets (data item PPENT -> PPEGT -> at) as of year t."

drop cfo
gen cfo = (ib+dp)/at
label variable cfo "earnings before extraordinary items (data item IB) plus depreciation and amortization (data item DP) scaled by total assets"

// Generate marketvalue and q
gen marketvalue = (csho*prcc_f)
gen q = ((csho*prcc_f)+(at-ceq))/at
gen size = log(marketvalue)
gen prc_inv = 1/PRC

drop if missing(q)
drop if missing(cfo)
drop if missing(at)
drop if at == 0
drop if missing(lead1_capxassets)
drop if missing(size)

tostring sic, replace
gen sic2 = substr(sic, 1, 2)

keep if lead1_capxassets > 0
keep if capx > 0

destring sic, replace
drop if sic >= 6000 & sic < 7000

save "30_sample.dta", replace


