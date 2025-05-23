set more off
clear all
cd "C:\Users\User\Project\segment\3_crsp_stock"

use "raw_data\Daily Stock File.dta", clear

distinct PERMNO
gen year = year(date)
su year
drop if VOL <= 0
drop if PRC <= 5

gen illiq = abs(RETX) / (VOL*PRC) * 10^6

collapse (mean) illiq (mean) RETX (sum) VOL (count) date (last) PRC, by(PERMNO year)
drop if date < 200

rename PERMNO LPERMNO
save "1_illiquidity.dta", replace

su illiq
winsor2 illiq, replace cuts(1 99)
su illiq


