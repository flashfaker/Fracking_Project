* Prediction Model for Water Quality Measurement Before and After 
local fname an_predict_wq_monitoring_02

/*******************************************************************************

Synapse: Water Quality Measurement Project based on the May 9th Meeting with 
Christian and Pietro (Start off with descriptive, explorative analysis, later
try some specifications)

Author: Zirui Song
Date Created: Apr 23th, 2022
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
	use "$datadir/DISC_TEMP_2020 OCT 2021 DEF B_ALL_STATES.dta", clear // water quality sample

	// drop missing wq obs.
	drop if log_t_t_Value_clean2 ==.

	// define estimation sample
	keep if Treated_ ==1 & m_cum_well_huc4_H_D == 1

	// number of reading by huc10-year-month
	bysort huc10_s date_string_year date_string_month: g number_reading = _N
	replace number_reading = 0 if number_reading==.

	bysort huc10_s date_string_year date_string_month: gen ok = 1 if date_string_month==date_string_month[_n+1]
	keep if ok==.

	keep StateCode CountyCode state_county_ID huc10_s date_string_year date_string_month T_HUC10_balanced1_ALL number_reading

	fillin huc10_s date_string_year date_string_month

	g OBS = 1 if _fillin == 0
	replace OBS = 0 if _fillin==1
	replace number_reading = 0 if number_reading==.

	egen state_fe = group(StateCode)
	bysort huc10_s: egen STATE =max(state_fe)
	* fill in missing state and county fips code
	destring StateCode CountyCode, replace
	bysort huc10_s: egen fipstate = max(StateCode)
	bysort huc10_s: egen fipscounty = max(CountyCode)

	
********************************* END ******************************************

capture log close
exit
