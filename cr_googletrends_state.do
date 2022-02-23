* create Google Search Trends for Hydraulic Fracturing Data
local fname cr_googletrends_state

/*******************************************************************************

Author: Zirui Song
Date Created: Dec 7th, 2021
Date Modified: Dec 7th, 2021

********************************************************************************/

/**************
	Basic Set-up
	***************/
	clear all
	set more off, permanently
	capture log close
	
	set scheme s2color
	
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
	Hydraulic Fracturing Trend
	***************/
	
	import delimited "$rawdir/HydraulicFracturing_Google/multiTimeline (1).csv", ///
	varnames(3) clear
	save "$interdir/hf_us", replace
	
	forval i = 2/19 {
		import delimited "$rawdir/HydraulicFracturing_Google/multiTimeline (`i').csv", ///
		varnames(3) clear
		merge 1:1 month using "$interdir/hf_us.dta"
			drop _merge
		save "$interdir/hf_us", replace
	}
	
	gen time = monthly(month, "YM")
	format time %tm
	drop month
	reshape long hydraulicfracturing, i(time) j(state) string
	
	sort state time 
	order state time
	label var hydraulicfracturing "Hydraulic Fracturing (Topic)"
	
	save "$basedir/hf_google", replace
	
	* several plots
	line hydraulicfracturing time, by(state, graphregion(fcolor(white))) xlabel(, angle(60))
	graph export "$figdir/hf_google.pdf", replace
	
/**************
	Hydraulic Fracturing Proppants Trend
	***************/	
	* Generate data set of Google search trends for "Hydraulic Fracturing Proppants" topic
	import delimited "$rawdir/HydraulicFracturingProppants_Google/multiTimeline (1).csv", ///
	varnames(3) clear
	save "$interdir/hfp_us", replace
	
	forval i = 2/19 {
		* get ride of states that have no obs
		if (`i' < 6 | (`i' > 9 & `i' < 14) | `i' > 16) {
			import delimited "$rawdir/HydraulicFracturingProppants_Google/multiTimeline (`i').csv", ///
			varnames(3) clear
			merge 1:1 month using "$interdir/hfp_us.dta", force
				drop _merge
			save "$interdir/hfp_us", replace
		}
	}
	
	gen time = monthly(month, "YM")
	format time %tm
	drop month
	reshape long hydraulicfracturingproppants, i(time) j(state) string
	sort state time 
	order state time
	label var hydraulicfracturingproppants "Hydraulic Fracturing Proppants (Topic)"
	* get state names to be full
	replace state = "arkansas" if state == "arka"
	replace state = "colorado" if state == "colo"
	replace state = "kansas" if state == "kans"
	replace state = "michigan" if state == "mich"
	replace state = "oklahoma" if state == "okla"
	replace state = "pennsylvania" if state == "penn"
	replace state = "texas" if state == "texa"
	replace state = "unitedstates" if state == "unit"
	replace state = "california" if state == "cali"
	replace state = "massachusetts" if state == "mass"
	replace state = "newyork" if state == "newy"
	
	save "$basedir/hfp_google", replace
	
	* several plots
	line hydraulicfracturingproppants time, by(state, graphregion(fcolor(white))) xlabel(, angle(60))
	graph export "$figdir/hfp_google.pdf", replace
	
/**************
	Fracking Trend
	***************/	
		
	import delimited "$rawdir/Fracking_Google/multiTimeline (1).csv", ///
	varnames(3) clear
	save "$interdir/f_us", replace
	
	forval i = 2/35 {
		import delimited "$rawdir/Fracking_Google/multiTimeline (`i').csv", ///
		varnames(3) clear
		merge 1:1 month using "$interdir/f_us.dta"
			drop _merge
		save "$interdir/f_us", replace
	}
	
	gen time = monthly(month, "YM")
	format time %tm
	drop month
	reshape long fracking, i(time) j(state) string
	
	sort state time 
	order state time
	label var fracking "Fracking (Term)"
	
	save "$basedir/f_google", replace
	
	* several plots
	line fracking time, by(state, graphregion(fcolor(white))) xlabel(, angle(60))
	graph export "$figdir/f_google.pdf", replace
	
********************************* END ******************************************

capture log close
exit
