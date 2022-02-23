* Analyze Google Search Trends (find the peak)
local fname an_02_googletrends_state

/*******************************************************************************

* obtain the peaks and upticks of google search trend

Author: Zirui Song
Date Created: Feb 7th, 2022
Date Modified: Feb 23rd, 2022

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
	Output Tables/Figures
	***************/
	
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
	gen peak_minus_disclosure = peak - disclosure
	gen first_uptick_minus_disclosure = first_uptick - disclosure
	gen first_biguptick_minus_disclosure = first_biguptick - disclosure
	export delimited "$tabdir/ggsearch_peakanduptick_table.csv", replace
	keep state disclosure peak peak_minus_disclosure
	export delimited "$tabdir/ggsearch_peak_table.csv", replace
		
	* get plots of peak and uptick for fracking states 
	
	use "$basedir/ggsearch_dates", clear
	gen peak_fracking = fracking*peak
	gen first_uptick_fracking = fracking*first_uptick
	gen first_biguptick_fracking = fracking*first_biguptick
	gen disclosure_fracking = fracking if time == disclosure_month
	gen disclosure = 1 if time == disclosure_month
	gen disclosure_start_fracking = fracking if time == disclosure_start_month
	gen disclosure_start = 1 if time == disclosure_start_month
	
	lab var fracking "Fracking Search Trend"
	
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
	
	//(dropline firstbiguptick_fracking time, lcolor(blue) mcolor(blue))

	xtset st time
	
/**************
	Output Figures 
	***************/	
	
	**************************** Single Plots **********************************
	*** OH
	twoway ///
	(line fracking time, lcolor(black)) ///
	(dropline peak_fracking time, msize(tiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure_fracking time, msize(tiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start_fracking time, msize(tiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline first_uptick_fracking time, msize(tiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick_fracking time, msize(tiny) lcolor(blue) mcolor(blue)) ///
	if state == "ohio" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(100)100, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(9) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_ohio_trend.pdf", replace
	
	*** PA
	twoway ///
	(line fracking time, lcolor(black)) ///
	(dropline peak_fracking time, msize(tiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure_fracking time, msize(tiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start_fracking time, msize(tiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline first_uptick_fracking time, msize(tiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick_fracking time, msize(tiny) lcolor(blue) mcolor(blue)) ///
	if state == "pennsylvania" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(100)100, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(10) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_pennsylvania_trend.pdf", replace
	
	*** TX
	twoway ///
	(line fracking time, lcolor(black)) ///
	(dropline peak_fracking time, msize(tiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure_fracking time, msize(tiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start_fracking time, msize(tiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline first_uptick_fracking time, msize(tiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick_fracking time, msize(tiny) lcolor(blue) mcolor(blue)) ///
	if state == "texas" & time >= 600 & time <= 660, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)660, angle(60)) ///
	ylabel(0(100)100, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(10) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_texas_trend.pdf", replace
	
	*** CO 
	// Issue: same date for disclosure start month and Google Search First Uptick and First Big Uptick!!!

	lab var disclosure_start_fracking "Begining of Disclosure Legislativel Process + First (Big) Uptick"
	twoway ///
	(line fracking time, lcolor(black)) ///
	(dropline peak_fracking time, msize(tiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure_fracking time, msize(tiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start_fracking time, msize(tiny) lcolor(midgreen) mcolor(midgreen)) ///
	if state == "colorado" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(100)100, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(10) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_colorado_trend.pdf", replace
	
	lab var disclosure_start_fracking "Begining of Disclosure Legislativel Process"
********************************************************************************
	* without the fracking trend
	*** OH
	twoway ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline first_uptick time, msize(vtiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick time, msize(vtiny) lcolor(blue) mcolor(blue)) ///
	if state == "ohio" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(9) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_ohio.pdf", replace
	
	*** PA
	twoway ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline first_uptick time, msize(vtiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick time, msize(vtiny) lcolor(blue) mcolor(blue)) ///
	if state == "pennsylvania" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(3) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_pennsylvania.pdf", replace
	
	*** TX
	twoway ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
	(dropline first_uptick time, msize(vtiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick time, msize(vtiny) lcolor(blue) mcolor(blue)) ///
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
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
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
		(dropline `var' time, msize(vtiny) lcolor(red) mcolor(red)) ///
		(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
		(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
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
		(dropline `var' time, msize(vtiny) lcolor(red) mcolor(red)) ///
		(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
		(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
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
		(dropline `var' time, msize(vtiny) lcolor(red) mcolor(red)) ///
		(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
		(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
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
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
	if state == "colorado" & time >= 600 & time <= 648, ///
	graphregion(color(white)) bgcolor(white) ///
	xlabel(600(6)648, angle(60)) ///
	ylabel(0(1)1, noticks nolab) yscale(lstyle(none)) ///
	legend(size(tiny) pos(9) ring(0) col(1)) xtitle("") 
	graph export "$figdir/ggsearch_peakanduptick_colorado_first_uptick.pdf", replace
	graph export "$figdir/ggsearch_peakanduptick_colorado_first_biguptick.pdf", replace

	twoway ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(midgreen)) ///
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
