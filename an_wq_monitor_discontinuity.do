* Test whether monitoring stations tend to stop monitoring after fracking activity
local fname an_wq_monitor_discontinuity

/*******************************************************************************

Author: Zirui Song
Date Created: May 18th, 2022
Date Modified: May 23th, 2022

********************************************************************************/

/**************
	Basic Set-up
	***************/
	clear all
	set more off, permanently
	capture log close
	
	* Set local directory
	* notice that repodir path for Mac/Windows might differ
	global dropdir = "/Users/zsong98/Dropbox/Fracking Disclosure regulation project"
	global repodir = "$dropdir/2. code/zs"
	global logdir = "$repodir//code/LogFiles"
	* data from 1. data folder in Dropbox share
	global datadir = "$dropdir/1. data"
	global rawdir = "$repodir/data/raw"
	global basedir = "$repodir/data/base"
	global interdir = "$repodir/data/intermediate"
	global figdir = "$repodir/output/figures"
	global tabdir = "$repodir/output/tables"	
	
	* Start plain text log file with same name
	log using "$logdir/`fname'.txt", replace text
	
/**************
	Import Water Measurement Data
	***************/
	*** function to read-in state abbreviation, distance to fracking well for event-study plots
capture program drop wq_measurment_eventplot
program define wq_measurment_eventplot
	args st dist
	use "$datadir/DISC_TEMP_2020 OCT 2021 DEF B_ALL_STATES.dta", clear // water quality sample
	* poke at the problem with only state specified
	if "`st'"== "pa" {
		keep if StateCode == "42"
	} 
	else if "`st'" == "tx" {
		keep if StateCode == "48"
	}
	
	// drop missing wq obs.
	drop if log_t_t_Value_clean2 ==.

	keep StateCode CountyCode state_county_ID huc10_s date_string ID_geo
	gen date = date(date_string, "DMY")
	gen month = mofd(date)
	format month %tm
	* collapse data to be monitorid-year-month with dummy variable indicating whether 
	* there is reading or not in the given month
	duplicates drop ID_geo month, force
	egen monitor_id = group(ID_geo)
	keep ID_geo monitor_id month 
	xtset monitor_id month
	* fillin missing dates (no measurement) to balance panel
	tsfill, full
	gen measure = 1 if ID_geo != ""
	replace measure = 0 if measure == .
	bysort monitor_id (ID_geo): replace ID_geo = ID_geo[_N]
	
	tempfile wq_`st'
	save `wq_`st''
	
/**************
	Import Monitoring Station Spudding Well Distance Data
	***************/
	use "$datadir/data for Zirui/distances_upstream_computed.dta", clear

*** by ID_geo, obtain the spud dates of the wells that are at risk 
	* keep only upstream spudding wells with distances smaller than 15km
	keep if upstream_len == 1
	keep if distance_geodesic <= `dist' 
	* generate the year and month of spud date
	gen month_frack = mofd(spud_date_augmented)
	keep ID_geo month_frack 
	format month_frack %tm
	* collapse by ID_geo year month 
	gduplicates drop
	* reshape data to wide such that one ID_geo has multiple at-risk fracking dates
	* generate counter variable for number of fracks in the given ID_geo
	bysort ID_geo (month_frack): gen count = _n
	reshape wide month_frack, i(ID_geo) j(count)
	
	* now merge ID_geo onto the water quality measurements data
	merge 1:m ID_geo using "`wq_`st''"
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                        32,947
        from master                     4,964  (_merge==1)
        from using                     27,983  (_merge==2)

    Matched                            15,783  (_merge==3)
    -----------------------------------------
	_merge == 1 due to data not from PA 
	_merge == 2 due to monitoring station having no fracking activities (upstream)
	and 15km proximity 
*/
	keep if _merge == 3
	drop _merge 
	order monitor_id ID_geo month 
	gsort monitor_id month 
	
/**************
	Run Event Study Regressions 
	***************/
	* generate eventtimes w.r.t. fracking activities (
	local i = 0
	foreach x of varlist month_frack* {
		local i = `i' + 1
		gen eventtime`i' = month - `x'
	}
	* define eventtime to be the smallest eventtime (in absolute term) among all defined above (make
	* sense as we care about the nearest fracking activity)
	* minimum of all positive value, maximum of all negative value 

	gen eventtime_pos = 10000 
	foreach x of varlist eventtime* {
		replace eventtime_pos = `x' if `x' >= 0 & `x' < eventtime_pos
	}
	
	gen eventtime_neg = -10000 
	foreach x of varlist eventtime* {
		replace eventtime_neg = `x' if `x' < 0 & `x' > eventtime_neg
	}

	order monitor_id ID_geo month *_pos *_neg
	* 1. keep only measurement within 12month period
	keep if eventtime_pos <= 12 | eventtime_neg >= -12
	replace eventtime_pos = . if eventtime_pos == 10000 //this is because missing value is treated as infinity
	replace eventtime_neg = . if eventtime_neg == -10000
	* 2. now we have the closest positive and negative (prior+after) date for each monitor-month obs
	* 3. generate eventtimes to be the closest positive eventtime within 12 months (if not, get negative)
	gen eventtime = eventtime_pos
	replace eventtime = eventtime_neg if eventtime_pos > 12
	
	* event study regressions 
	gen event = eventtime + 12
	
	reghdfe measure i(1/11 13/24)bn.event, cluster(monitor_id) absorb(monitor_id month)
	outreg2 using "$tabdir/wq_measurement_around_fracking_pa.xls", ///
	bracket bdec (5) sdec(5) wide replace
	* plots
	import delimited using "$tabdir/wq_measurement_around_fracking_pa.txt", clear
		drop in 1/3
		drop in 49/53
		replace v1 = "base" in 47

		replace v1 = "se_" +  v1[_n-1] if v1=="" & v1[_n-1]!=""
			
		forval i = 1/2  {
			replace v`i' = subinstr(v`i', "]", "",.) 
			replace v`i' = subinstr(v`i', "[", "",.) 
			replace v`i' = "" if v`i' == "-" 
			replace v`i' = subinstr(v`i', "*", "",.) 
		}	
			
		destring v2, replace
		replace v2 = 0 if v1 == "base"
		replace v2 = 0 if v1 == "se_base"
			
		*gen time for reshape 
		gen time = 1 if v1 == "1bn.event" | v1 == "se_1bn.event"
		replace time = 12 if v1 == "base" | v1 == "se_base"
		forv x = 1/24 {
			if `x' < 10 {
				replace time = `x' if substr(v1, -7, .) == "`x'.event"
			} 
			else {
				replace time = `x' if substr(v1, -8, .) == "`x'.event"
			}
		}
		replace time = time - 12
		
		forv i = 1(2)47 {
			replace v1 = "base" in `i'
		}
		replace v1 = substr(v1, 1, 2)
		reshape wide v2, i(time) j(v1) string
		rename v2ba coef
		rename v2se se
		* multiply by 100 for percentage points 
		replace coef = coef*100
		replace se = se*100
			
		g int_down = coef - invnormal(0.025)*se
		g int_up = coef + invnormal(0.025)*se	
			
		twoway (scatter coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)) /// 
				(rspike int_down int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black))  ///
				(rcap int_down int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black)) ///
				(scatter coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)), ///
				ylabel(#10, labsize(small) nogrid) ytick(#10)  ///
				yscale(r(-0.4(.1).4)) ///
				ytitle("Measurement Frequency(%)", size(small) height(5))  ///
				yline(0, lstyle(foreground)) ///
				xline(0, lcolor(ebg) lwidth(vvvthick)) ///
				xtitle("Time (Months)", size(small)) ///
				legend(off) scheme(sj) ysize(2.8) xsize(4.2) graphregion(c(white) fcolor(white))
		graph display, ysize(2.8) xsize(4.2)
		graph export "$figdir/wq_measurment_eventplot_`st'_`dist'km.pdf", replace
	
end
	wq_measurment_eventplot "pa" "15"
	wq_measurment_eventplot "pa" "10"
	wq_measurment_eventplot "pa" "5"
	wq_measurment_eventplot "tx" "15"
	wq_measurment_eventplot "tx" "10"
	wq_measurment_eventplot "tx" "5"
	
********************************* END ******************************************

capture log close
exit
