* Analyze Google Search Trends (find the peak)
local fname an_02_googletrends_state

/*******************************************************************************

* obtain the peaks and upticks of google search trend

Author: Zirui Song
Date Created: Feb 7th, 2022
Date Modified: Apr 14th, 2022

********************************************************************************/

/**************
	Basic Set-up
	***************/
	clear all
	set more off, permanently
	capture log close
	
	* Set local directory
	* notice that repodir path for Mac/Windows might differ
	global repodir = "/Users/zsong/Dropbox/Fracking Disclosure regulation project/2. code/zs"
	global logdir = "$repodir/code/LogFiles"
	global rawdir = "$repodir/data/raw"
	global basedir = "$repodir/data/base"
	global interdir = "$repodir/data/intermediate"
	global figdir = "$repodir/output/figures"
	global tabdir = "$repodir/output/tables"	
	
	* Start plain text log file with same name
	log using "$logdir/`fname'.txt", replace text

/**************
	Finding the Peak of Trends
	***************/
	use "$basedir/f_google", clear
	
	encode state, gen(st)
	gen state_fe = group(st)
	gen year_month_fe = group(time)
	local e "cluster(state_fe)" 
	local f "year_month_fe"
			
	* regressions with state and year month fixed effects, outputting residuals
	reghdfe fracking, `e' absorb(`f') residuals(residuals)
	bysort st: egen highest_residual = max(residuals)
	format highest_residual %10.0g
	
	* get the peak of the residuals
	gen peak = 1 if highest_residual - residuals < 0.001
	export delimited "$basedir/peak_googletrends1.csv", replace
	
	* output only state-month combination with peaks
	preserve 
		keep if peak == 1
		drop peak
		export delimited "$basedir/peak_googletrends2.csv", replace
	restore
	
	* get the upticks of google search trend
		gen se = _se[_cons]
		gen uptick_limit = 2*se // 2 times the standard errors from the fe regressions
		gen upticks = 1 if residuals >= uptick_limit
		* get first uptick
		preserve 
			keep if upticks == 1
			sort state time
			collapse (first) time upticks, by(state)
			rename upticks first_uptick
			save "$interdir/first_uptick", replace
		restore
		drop uptick_limit upticks
		* get bigger uptick (one half of the highest residual)
		gen uptick_limit = highest_residual / 2
		gen upticks = 1 if residuals >= uptick_limit
		* get the first big uptick
		preserve 
			keep if upticks == 1
			sort state time
			collapse (first) time upticks, by(state)
			rename upticks first_biguptick
			save "$interdir/first_biguptick", replace
		restore
		drop upticks uptick_limit
		
		merge 1:1 state time using "$interdir/first_uptick" 
		drop _merge
		merge 1:1 state time using "$interdir/first_biguptick"
		drop _merge
		rename time month
		merge m:1 state using "$basedir/disclosurerule_datePB.dta"
			keep if _merge == 3 // keep only disclosure states
			drop _merge
		* change date to month
		gen disclosure_month = mofd(time)
		format disclosure_month %tm
		drop time
		merge m:1 state using "$basedir/disclosurerule_dateUpdated.dta"
			keep if _merge == 3 // keep only disclosure states (get rid of Michigan)
			drop _merge
		* change disclosure beginning date to monthly date
		gen disclosure_start_month = mofd(time)
		format disclosure_start_month %tm
		drop time
		rename month time
		
		* make sure Michigan is not in the sample
		drop if state == "michigan"
		save "$basedir/ggsearch_dates", replace
		
/**************
	Summary Statistics 
	***************/
	use "$basedir/ggsearch_dates", clear
	* First Big Uptick and Legislative Start Date
	rename disclosure_start_month disc_time
	* generate first big uptick media coverage time to compare with disclosure time
	gen firstbiguptick_time = first_biguptick*time
	format firstbiguptick_time %tm
	* collapse to state level 
	collapse (max) disc_time firstbiguptick_time, by(state)
	gen before_state = 1 if disc_time <= firstbiguptick_time 
	replace before_state = 0 if before_state >=.
	bysort before_state: gen count = _N
	gen diff = firstbiguptick_time - disc_time
	egen diff_mean_total = mean(diff)
	collapse (mean) mean_diff = diff (median) median_diff = diff (first) count diff_mean_total, by(before_state)
	save "$tabdir/Summary Statistics (first big uptick (Google))", replace
	
	* generate summary statistics on the dates of the peaks/upticks/disclosure
	
	use "$basedir/ggsearch_dates", clear
	* keep only peak, disclosure rule month, first tick date
	rename disclosure_month disclosure
	rename disclosure_start_month disclosure_start
	keep if peak == 1 | first_uptick == 1 | first_biguptick == 1 | ///
			time == disclosure | time == disclosure_start
	* generate peak/uptick times
	foreach x in peak first_uptick first_biguptick {
		replace `x' = `x' * time
		format `x' %tm
	}
	collapse (max) peak first_uptick first_biguptick disclosure disclosure_start, by(state)
	order state disclosure

*** manually inspect the states where two or more dates overlap 
	* arkansas (move first uptick from 2010m8 to 2010m7)
	* colorado (move first uptick 1 month prior and first big uptick 1 month later)
	* mississippi (move first uptick back 2, first big uptick back 1)
	* montana (move first big uptick 1 month back)
	* oklahoma (move first uptick back 1)
	* wv (move disclosure start date back 1, first big uptick forward 1)
	
	gen peak_minus_disclosure = peak - disclosure
	gen first_uptick_minus_disclosure = first_uptick - disclosure
	gen first_biguptick_minus_disclosure = first_biguptick - disclosure
	export delimited "$tabdir/ggsearch_peakanduptick_table.csv", replace
	keep state disclosure peak peak_minus_disclosure
	export delimited "$tabdir/ggsearch_peak_table.csv", replace
	
/*** perform the changes specifies from the manual inspection above
	Update: Actually not changing the date might be better
	use "$basedir/ggsearch_dates", clear
	replace first_uptick = first_uptick[_n+1] if state == "arkansas"
	
	replace first_uptick = first_uptick[_n+1] if state == "colorado"
	replace first_biguptick = 1 if state == "colorado" & time == ym(2011, 12)
	replace first_biguptick = . if state == "colorado" & time == ym(2011, 11)
	
	replace first_uptick = first_uptick[_n+2] if state == "mississippi"
	replace first_biguptick = first_biguptick[_n+1] if state == "mississippi"
	
	replace first_biguptick = first_biguptick[_n+1] if state == "montana"
	
	replace first_uptick = first_uptick[_n+1] if state == "oklahoma"
	
	replace disclosure_start_month = disclosure_start_month - 1 if state == "westvirginia"
	replace first_biguptick = 1 if state == "westvirginia" & time == ym(2011, 9)
	replace first_biguptick = . if state == "westvirginia" & time == ym(2011, 8) 
	save "$basedir/ggsearch_dates", replace */
	
/**************
	Output Figures 
	***************/	
	
	* get plots of peak and uptick for fracking states 
	
	use "$basedir/ggsearch_dates", clear
	gen peak_fracking = fracking*peak
	gen first_uptick_fracking = fracking*first_uptick
	gen first_biguptick_fracking = fracking*first_biguptick
	gen disclosure_fracking = fracking if time == disclosure_month
	gen disclosure = 1 if time == disclosure_month
	gen disclosure_start_fracking = fracking if time == disclosure_start_month
	gen disclosure_start = 1 if time == disclosure_start_month
	
	lab var fracking "Google Search Intensity (Fracking)"
	
	lab var peak_fracking "Google Search Peak"
	lab var first_uptick_fracking "Google Search First Uptick"
	lab var first_biguptick_fracking "Google Search First Big Uptick"
	lab var disclosure_fracking "Disclosure Rule"
	lab var disclosure_start_fracking "Begining of Disclosure Legislativel Process"
	
	lab var peak "Google Search Peak"
	lab var disclosure "Disclosure Rule"
	lab var disclosure_start "Beginning of Disclosure Legislative Process"
	lab var first_uptick "Google Search First Uptick"
	lab var first_biguptick "Google Search First Big Uptick"

	xtset st time
	
**************************** Single Plots **********************************
* write function for plots
capture program drop plot_frackingtrend_disclosure
program plot_frackingtrend_disclosure
	args st time
	twoway ///
	(line fracking time, lcolor(black) lwidth(vthin)) ///
	(dropline disclosure_start_fracking time, msize(tiny) lcolor(midgreen) mcolor(midgreen) lpattern(shortdash)) ///
	(dropline disclosure_fracking time, msize(tiny) lcolor(dkgreen) mcolor(dkgreen) lpattern(shortdash_dot)) ///
	(dropline first_uptick_fracking time, msize(tiny) lcolor(ltblue) mcolor(ltblue) lpattern(longdash)) ///
	(dropline first_biguptick_fracking time, msize(tiny) lcolor(blue) mcolor(blue) lpattern(longdash_dot)) ///
	(dropline peak_fracking time, msize(tiny) lcolor(red) mcolor(red) lpattern(dash)) ///
	if state == "`st'" & time >= 600 & time <= `time', ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)`time', labsize(vsmall)) ///
	ylabel(0(100)100, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(11) ring(0) col(1) region(lwidth(none))) xtitle("") 
	graph export "$figdir/fracking_trend_series/ggsearch_peakanduptick_`st'_trend.pdf", replace
end
																	
plot_frackingtrend_disclosure "ohio" 648
plot_frackingtrend_disclosure "pennsylvania" 648
plot_frackingtrend_disclosure "texas" 672
plot_frackingtrend_disclosure "kansas" 672
plot_frackingtrend_disclosure "kentucky" 672
plot_frackingtrend_disclosure "louisiana" 672
plot_frackingtrend_disclosure "montana" 648
plot_frackingtrend_disclosure "newmexico" 648
plot_frackingtrend_disclosure "northdakota" 648
plot_frackingtrend_disclosure "oklahoma" 686
plot_frackingtrend_disclosure "utah" 660
plot_frackingtrend_disclosure "wyoming" 686
																				
plot_frackingtrend_disclosure "colorado" 660
plot_frackingtrend_disclosure "arkansas" 636
plot_frackingtrend_disclosure "mississippi" 648
plot_frackingtrend_disclosure "westvirginia" 660																																			
	
********************************************************************************
	* without the fracking trend
	*** OH
	twoway ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline first_uptick time, msize(vtiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick time, msize(vtiny) lcolor(blue) mcolor(blue)) ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	if state == "ohio" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(9) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_ohio.pdf", replace
	
	*** PA
	twoway ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline first_uptick time, msize(vtiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick time, msize(vtiny) lcolor(blue) mcolor(blue)) ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	if state == "pennsylvania" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(3) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_pennsylvania.pdf", replace
	
	*** TX
	twoway ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline first_uptick time, msize(vtiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick time, msize(vtiny) lcolor(blue) mcolor(blue)) ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	if state == "texas" & time >= 600 & time <= 660, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)660, angle(60)) ///
	ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(3) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_texas.pdf", replace
	
	*** CO 
	// Issue: same date for disclosure start month and Google Search First Uptick and First Big Uptick!!!

	lab var disclosure_start "Begining of Disclosure Legislativel Process + First (Big) Uptick"
	twoway ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	if state == "colorado" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(9) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_colorado.pdf", replace
	
	lab var disclosure_start "Begining of Disclosure Legislativel Process"
	****************************** 1x3 Plots ***********************************
	
	*** OH 
	foreach var in peak first_uptick first_biguptick {
		twoway ///
		(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
		(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
		(dropline `var' time, msize(vtiny) lcolor(red) mcolor(red)) ///
		if state == "ohio" & time >= 600 & time <= 648, ///
		graphregion(color(white)) bgcolor(white) ///
		xlabel(600(6)648, angle(60)) ///
		ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
		legend(size(tiny) pos(9) ring(0) col(1)) xtitle("") 
		graph export "$figdir/ggsearch_peakanduptick_ohio_`var'.pdf", replace
	}
	
	*** PA 
	foreach var in peak first_uptick first_biguptick {
		twoway ///
		(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
		(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
		(dropline `var' time, msize(vtiny) lcolor(red) mcolor(red)) ///
		if state == "pennsylvania" & time >= 600 & time <= 648, ///
		graphregion(color(white)) bgcolor(white) ///
		xlabel(600(6)648, angle(60)) ///
		ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
		legend(size(tiny) pos(9) ring(0) col(1)) xtitle("") 
		graph export "$figdir/ggsearch_peakanduptick_pennsylvania_`var'.pdf", replace
	}
	
	*** TX
	foreach var in peak first_uptick first_biguptick {
		twoway ///
		(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
		(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
		(dropline `var' time, msize(vtiny) lcolor(red) mcolor(red)) ///
		if state == "texas" & time >= 600 & time <= 660, ///
		graphregion(color(white)) bgcolor(white) ///
		xlabel(600(6)660, angle(60)) ///
		ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
		legend(size(tiny) pos(3) ring(0) col(1)) xtitle("") 
		graph export "$figdir/ggsearch_peakanduptick_texas_`var'.pdf", replace
	}
	
	*** CO
	lab var disclosure_start "Begining of Disclosure Legislativel Process + First (Big) Uptick"
	twoway ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	if state == "colorado" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(9) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_colorado_first_uptick.pdf", replace
	graph export "$figdir/ggsearch_peakanduptick_colorado_first_biguptick.pdf", replace

	twoway ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	if state == "colorado" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(9) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_colorado_peak.pdf", replace

	lab var disclosure_start "Begining of Disclosure Legislativel Process"
	
********************************* END ******************************************

capture log close
exit
