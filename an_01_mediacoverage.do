* Analyze Google Search Trends (find the peak)
local fname an_01_mediacoverage

/*******************************************************************************

* obtain the peaks and upticks of google search trend

Author: Zirui Song
Date Created: Feb 5th, 2022
Date Modified: Feb 24th, 2022

********************************************************************************/

/**************
	Basic Set-up
	***************/
	clear all
	set more off, permanently
	capture log close
	
	* Set local directory
	* notice that repodir path for Mac/Windows might differ
	global dropbox = "/Users/zsong/Dropbox/Fracking Disclosure regulation project"
	global repodir = "$dropbox/2. code/zs"
	global logdir = "$repodir/code/LogFiles"
	global rawdir = "$repodir/data/raw"
	global basedir = "$repodir/data/base"
	global interdir = "$repodir/data/intermediate"
	global figdir = "$repodir/output/figures"
	global tabdir = "$repodir/output/tables"	
	
	* Start plain text log file with same name
	log using "$logdir/`fname'.txt", replace text

/**************
	Finding the Uptick/Peak of Media Coverage
	***************/
	use "$dropbox/1. data/data for Zirui/media/Article Level Dataset", clear
	* generate counts of newspaper coverage of "fracking" in state-month combination
	collapse (count) v1, by(state monthly_date)

	egen st = group(state)
	xtset st monthly_date
	replace state = lower(state)
	replace state = subinstr(state, " ", "", .)
	
	tsfill, full
	rename v1 media_count
	replace media_count = 0 if media_count >=.
	
	reghdfe media_count, cluster(st) absorb(monthly_date) residuals(residuals)
	bysort st: egen highest_residual = max(residuals)
	format highest_residual %10.0g
	
	bysort st (state): replace state = state[_N] if missing(state)
	* merge to get disclosure states
	merge m:1 state using "$basedir/disclosurerule_datePB.dta"
	keep if _merge == 3 // keep only disclosure states
	drop if state == "michigan"
	drop _merge
	// generate monthly disclosure date
	gen disclosure_month = mofd(time)
	format disclosure_month %tm
	drop time
	rename monthly_date time
	
	* get the peak of the residuals
	gen peak = 1 if highest_residual - residuals < 0.00001
	replace peak = . if state == "arkansas"
	replace peak = 1 if state == "arkansas" & time == ym(2012, 10) // first media coverage in arkansas
	export delimited "$basedir/peak_mediacoverage.csv", replace
	
	* get the upticks of google search trend
		gen se = _se[_cons]
		gen uptick_limit = 2*se // 2 times the standard errors from the fe regressions
		gen upticks = 1 if residuals >= uptick_limit
		* get first uptick
		* manually get first uptick for arkansas, kentucky, mississippi, montana (first
		* time that there is media coverage)
		replace upticks = 1 if state == "arkansas" & time == ym(2012, 10)
		replace upticks = 1 if state == "kentucky" & time == ym(2015, 1)
		replace upticks = 1 if state == "mississippi" & time == ym(2012, 3)
		replace upticks = 1 if state == "montana" & time == ym(2011, 7)
		preserve 
			keep if upticks == 1
			sort state time
			collapse (first) time upticks, by(state)
			rename upticks first_uptick
			save "$interdir/first_uptick_media", replace
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
			* manually fix uptick time for arkansas as arksansas only has two 
			* media coverage counts in the entire period...
			replace time = ym(2012, 11) if state == "arkansas"
			save "$interdir/first_biguptick_media", replace
		restore
		drop upticks uptick_limit
	
		merge 1:1 state time using "$interdir/first_uptick_media" 
		drop _merge
		merge 1:1 state time using "$interdir/first_biguptick_media"
		drop _merge
		
		rename time month
		merge m:1 state using "$basedir/disclosurerule_dateUpdated.dta"
		drop _merge
		gen disclosure_start_month = mofd(time)
		format disclosure_start_month %tm 
		drop time
		rename month time
		
		gen disclosure = 1 if time == disclosure_month
		gen disclosure_start = 1 if time == disclosure_start_month
		save "$basedir/mediacoverage_dates", replace
		
/**************
	Summary Statistic for the Peak Media Coverage
	***************/
	use "$basedir/mediacoverage_dates", clear 
	rename disclosure_start_month disc_time
	* generate peak media coverage time to compare with disclosure time
	gen peak_time = peak*time
	format peak_time %tm
	* collapse to state level 
	collapse (max) disc_time peak_time, by(state)
	gen before_state = 1 if disc_time <= peak_time 
	replace before_state = 0 if before_state >=.
	bysort before_state: gen count = _N
	gen diff = peak_time - disc_time
	collapse (mean) mean_diff = diff (median) median_diff = diff (first) count, by(before_state)
	save "$tabdir/Summary Statistics (Media)", replace
	
	* First Big Uptick and Legislative Start Date
	use "$basedir/mediacoverage_dates", clear 
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
	save "$tabdir/Summary Statistics (first big uptick (Media))", replace
	
	use "$basedir/mediacoverage_dates", clear 
	* summary statistics in table 
	* keep only peak, disclosure rule month, first tick date
	keep if peak == 1 | first_uptick == 1 | first_biguptick == 1 | disclosure == 1 | disclosure_start == 1
	* replace arkansas first_biguptick (regression analysis not reasonable)	
	* generate peak/uptick times
	foreach x in peak first_uptick first_biguptick disclosure disclosure_start {
		replace `x' = `x' * time
		format `x' %tm
	}
	collapse (max) peak first_uptick first_biguptick disclosure disclosure_start, by(state)
	order state disclosure
	gen peak_minus_disclosure = peak - disclosure
	gen first_uptick_minus_disclosure = first_uptick - disclosure
	gen first_biguptick_minus_disclosure = first_biguptick - disclosure
	export delimited "$tabdir/mediacoverage_peakanduptick_table.csv", replace
/**************
	Plots
	***************/	
		
	* get plots of peak and uptick for fracking states 
	use "$basedir/mediacoverage_dates", clear 
	
	lab var peak "Media Coverage Peak"
	lab var disclosure "Disclosure Rule"
	lab var disclosure_start "Start of Disclosure Legislative Process"
	lab var first_uptick "Media Coverage First Uptick"
	lab var first_biguptick "Media Coverage First Big Uptick"
	lab var state "Newspaper HQ State"

	xtset st time
	
	*** OH
	twoway ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(mgreen)) ///
	(dropline first_uptick time, msize(vtiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick time, msize(vtiny) lcolor(blue) mcolor(blue)) ///
	if state == "ohio" & time > 600 & time <= 660, ///
	graphregion(color(white)) bgcolor(white) yscale(lstyle(none)) ///
	xlabel(600(6)660, angle(60)) ylabel(0(1)1, noticks nolab) ///
	legend(size(tiny) pos(4) ring(0) col(1)) xtitle("") 
	graph export "$figdir/mediacoverage_peakanduptick_ohio.pdf", replace
	
	*** PA
	twoway ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(mgreen)) ///
	(dropline first_uptick time, msize(vtiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick time, msize(vtiny) lcolor(blue) mcolor(blue)) ///
	if state == "pennsylvania" & time > 559 & time <= 683, ///
	graphregion(color(white)) bgcolor(white) yscale(lstyle(none)) ///
	xlabel(559(12)683, angle(60)) ylabel(0(1)1, noticks nolab) ///
	legend(size(tiny) pos(4) ring(0) col(1)) xtitle("") 
	graph export "$figdir/mediacoverage_peakanduptick_pennsylvania.pdf", replace
	
	*** TX
	twoway ///
	(dropline peak time, msize(vtiny) lcolor(red) mcolor(red)) ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(mgreen)) ///
	(dropline first_uptick time, msize(vtiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick time, msize(vtiny) lcolor(blue) mcolor(blue)) ///
	if state == "texas" & time > 559 & time <= 683, ///
	graphregion(color(white)) bgcolor(white) yscale(lstyle(none)) ///
	xlabel(559(12)683, angle(60)) ylabel(0(1)1, noticks nolab) ///
	legend(size(tiny) pos(4) ring(0) col(1)) xtitle("") 
	graph export "$figdir/mediacoverage_peakanduptick_texas.pdf", replace
	
	*** CO 
	* peak and first big uptick coincide, so keep only first big uptick 
	lab var first_biguptick "Media Coverage Peak and First Big Uptick"
	twoway ///
	(dropline disclosure time, msize(vtiny) lcolor(dkgreen) mcolor(dkgreen)) ///
	(dropline disclosure_start time, msize(vtiny) lcolor(midgreen) mcolor(mgreen)) ///
	(dropline first_uptick time, msize(vtiny) lcolor(ltblue) mcolor(ltblue)) ///
	(dropline first_biguptick time, msize(vtiny) lcolor(blue) mcolor(blue)) ///
	if state == "colorado" & time > 559 & time <= 683, ///
	graphregion(color(white)) bgcolor(white) yscale(lstyle(none)) ///
	xlabel(559(12)683, angle(60)) ylabel(0(1)1, noticks nolab) ///
	legend(size(tiny) pos(4) ring(0) col(1)) xtitle("") 
	graph export "$figdir/mediacoverage_peakanduptick_colorado.pdf", replace
	lab var first_biguptick "Media Coverage First Big Uptick"
	
********************************* END ******************************************

capture log close
exit
