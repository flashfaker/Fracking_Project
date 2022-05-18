* Test whether monitoring stations tend to stop monitoring after fracking activity
local fname an_wq_monitor_discontinuity

/*******************************************************************************

Author: Zirui Song
Date Created: May 18th, 2022
Date Modified: May 18th, 2022

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
	use "$datadir/DISC_TEMP_2020 OCT 2021 DEF B_ALL_STATES.dta", clear // water quality sample

	* poke at the problem with only PA
	keep if StateCode == "42"
	
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
	
	tempfile wq_pa
	save `wq_pa'
/**************
	Import Monitoring Station Spudding Well Distance Data
	***************/
	use "$datadir/data for Zirui/distances_upstream_computed.dta", clear

*** by ID_geo, obtain the spud dates of the wells that are at risk 
	* keep only upstream spudding wells with distances smaller than 15km
	keep if upstream_len == 1
	keep if distance_geodesic <= 15 
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
	merge 1:m ID_geo using "`wq_pa'"
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
********************************* END ******************************************

capture log close
exit
