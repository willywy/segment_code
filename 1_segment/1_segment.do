set more off
clear all
cd "C:\Users\User\Project\segment\1_segment"

use "raw_data\historical_segment.dta",clear

keep if stype == "BUSSEG"
drop if sales == .
gen year = year(datadate)
keep if year >= 1993 & year <= 2004

by gvkey year sid, sort: gen tag = (_n == 1)
collapse (sum) num_segments=tag, by(gvkey year)
label variable num_segments "Number of unique segments per firm-year"

drop if num_segments == 0
drop if num_segments == .

save "1_segment.dta", replace
