set more off
clear all
cd "C:\Users\User\Project\segment"

use "30_sample.dta", clear


foreach var in illiq prc_inv size {
    winsor2 `var', replace cuts(1 99)
}

su TREAT POST lead1_capxassets q cfo size illiq prc_inv

ttest illiq if POST == 0, by(TREAT)
ttest illiq if POST == 1, by(TREAT)

ttest num_segments if POST == 0, by(TREAT)
ttest num_segments if POST == 1, by(TREAT)