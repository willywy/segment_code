set more off
clear all
cd "C:\Users\User\Project\segment\2_ccm_crsp_fundamental"

use "raw_data\fundamentals_annual.dta", clear
gen year = year(datadate)
rename GVKEY gvkey
keep if year >= 1993 & year <= 2004

duplicates report gvkey year
duplicates drop gvkey year, force

drop if missing(cik)
drop if missing(sale)
drop if missing(capx)


keep gvkey LPERMNO sic datadate year fyear capx ppent ppegt at ib dp at cfo csho prcc_f ceq

save "1_ccm_crsp_fundamental.dta", replace