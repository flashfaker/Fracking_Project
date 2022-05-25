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
	global dropdir = "/Users/zsong/Dropbox/Fracking Disclosure regulation project"
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
	Define at-risk monitor station
	***************/
*** import and clean distance data （collapsing by api10 (well))
	use "$datadir/data for Zirui/distances_upstream_computed.dta", clear
	* keep only good upstream wells (downstream monitoring station)
	keep if upstream_len == 1
	keep if distance_geodesic <= 15
	* obtain only at-risk monitors
	duplicates drop ID_geo, force
	keep ID_geo
	save "$interdir/at_risk_monitors.dta", replace
/**************
	Import Water Measurement Data
	***************/
	use "$datadir/DISC_TEMP_2020 OCT 2021 DEF B_ALL_STATES.dta", clear // water quality sample

	// drop missing wq obs.
	drop if log_t_t_Value_clean2 ==.
	
	// define estimation sample
	keep if Treated_ ==1 & m_cum_well_huc4_H_D == 1
	
	// joinby with distance data to get api10 (well) distance for each ID_geo
	fmerge m:1 ID_geo using "$interdir/at_risk_monitors.dta"
		drop if _merge == 2
		gen at_risk = 1 if _merge == 3
		replace at_risk = 0 if _merge == 1
	/* keep only dates close (spud date within 1 year of monitoring date)
	drop if abs(date-spud_date_augmented) > 360 */
	
	// number of reading by huc10-year-month
	bysort huc10_s date_string_year date_string_month: g number_reading = _N
	replace number_reading = 0 if number_reading==.

	bysort huc10_s date_string_year date_string_month: gen ok = 1 if date_string_month==date_string_month[_n+1]
	keep if ok==.

	// merge with well count data
	rename date_string_month date_string_monthM
	merge 1:1 huc10_s date_string_year date_string_monthM using "$datadir/ENTRY_TEMP_2020 OCT 2021.dta", force gen(_merge_entry)
	drop if _merge_entry==2
	
	replace Ttot_well_c_dH= 0 if Ttot_well_c_dH==.
	rename date_string_monthM date_string_month
	keep StateCode CountyCode state_county_ID huc8_s huc10_s ID_geo date_string_year date_string_month T_HUC10_balanced1_ALL number_reading Ttot_well_c_dH at_risk

	fillin huc10_s date_string_year date_string_month

	g OBS = 1 if _fillin == 0
	replace OBS = 0 if _fillin==1
	replace number_reading = 0 if number_reading==.

	replace date_string_month = "1" if date_string_month == "jan"
	replace date_string_month = "2" if date_string_month == "feb"
	replace date_string_month = "3" if date_string_month == "mar"
	replace date_string_month = "4" if date_string_month == "apr"
	replace date_string_month = "5" if date_string_month == "may"
	replace date_string_month = "6" if date_string_month == "jun"				
	replace date_string_month = "7" if date_string_month == "jul"
	replace date_string_month = "8" if date_string_month == "aug"
	replace date_string_month = "9" if date_string_month == "sep"
	replace date_string_month = "10" if date_string_month == "oct"				
	replace date_string_month = "11" if date_string_month == "nov"
	replace date_string_month = "12" if date_string_month == "dec"							
	destring date_string_year date_string_month, replace
	gen month = ym(date_string_year, date_string_month)
	format month %tm
	
	drop state_county_ID date_string_month date_string_year _fillin CountyCode
	* generate huc10 ID and treated dummy
	egen huc10 = group(huc10_s)
	bysort huc10: egen treated = max(T_HUC10_balanced1_ALL)
	destring StateCode, replace 
	* generate state and huc8 IDs
	bysort huc10: egen state = max(StateCode)
	bysort huc10 (huc8_s): replace huc8_s = huc8_s[_N]
	egen huc8 = group(huc8_s)
	* generate well_well count within huc10
	bysort huc10: egen well_count = max(Ttot_well_c_dH)
	* order and label variables
	order state huc8 huc10 treated month OBS number_reading well_count at_risk
	lab var treated "Treated HUC10"
	lab var at_risk "At-risk Monitoring Stations (downstream, within 15km of spudding)"
	gsort state huc8 huc10 month
	save "$interdir/monthly_wq_measurement_with_wlct", replace
	
		
/**************
	Exploratory Analysis 
	***************/
*** raw trends of water measurement (mean)?
	// average OBS/number reading per month by treated/non-treated HUC10s
preserve
	collapse (mean) OBS number_reading, by(treated month)
	reshape wide OBS number_reading, i(month) j(treated)
	lab var OBS0 "Non-Treated HUC10s"
	lab var number_reading0 "Non-Treated HUC10s"
	lab var OBS1 "Treated HUC10s"
	lab var number_reading1 "Treated HUC10s"	
	
	tsset month
	* drop zero values
	drop if OBS0 == 0
	twoway (tsline OBS0) || (tsline OBS1), yscale(r(0(.05).3)) ///
			ytitle("Share of HUC10 with Water Measurement", size(small) height(5))  ///
			xtitle("Time (Months)", size(small)) ///
			tlabel(2006m1 2008m1 2010m1 2012m1 2014m1 2016m1 2018m1)  ///
			legend(rows(1)) ysize(2.8) xsize(4.2) graphregion(c(white) fcolor(white))
	graph export "$figdir/OBS_trends_bytreatedHUC10s.pdf", replace
	
	twoway (tsline number_reading0) || (tsline number_reading1), yscale(r(0(.05).3)) ///
			ytitle("Average Number of Readings Per HUC10", size(small) height(5))  ///
			xtitle("Time (Months)", size(small)) ///
			tlabel(2006m1 2008m1 2010m1 2012m1 2014m1 2016m1 2018m1)  ///
			legend(rows(1)) ysize(2.8) xsize(4.2) graphregion(c(white) fcolor(white))
	graph export "$figdir/number_reading_trends_bytreatedHUC10s.pdf", replace
restore
	
/**************
	Regression (HUC10 with/without fracking) 
	***************/	

*** HUC10 with/without fracking
	* get year 
	gen date = dofm(month)
	gen year = year(date)
	egen year_fe = group(year)
	egen state_fe = group(state)
	egen huc8_fe = group(huc8)
	egen state_year_fe = group(state year)
	
capture program drop regressions
program define regressions
	args var
	reghdfe OBS `var', cluster(state_fe) absorb(state_fe year_fe)
	outreg2 using "$tabdir/wq_measurement_`var'.xls", bracket bdec (5) sdec(5) wide replace
	reghdfe number_reading `var', cluster(state_fe) absorb(state_fe year_fe)
	outreg2 using "$tabdir/wq_measurement_`var'.xls", bracket bdec (5) sdec(5) wide append
	reghdfe OBS `var', cluster(huc8_fe) absorb(huc8_fe year_fe)
	outreg2 using "$tabdir/wq_measurement_`var'.xls", bracket bdec (5) sdec(5) wide append
	reghdfe number_reading `var', cluster(huc8) absorb(huc8_fe year_fe)
	outreg2 using "$tabdir/wq_measurement_`var'.xls", bracket bdec (5) sdec(5) wide append
	reghdfe OBS `var', cluster(state_fe) absorb(state_year_fe)
	outreg2 using "$tabdir/wq_measurement_`var'.xls", bracket bdec (5) sdec(5) wide append
	reghdfe number_reading `var', cluster(state_fe) absorb(state_year_fe)
	outreg2 using "$tabdir/wq_measurement_`var'.xls", bracket bdec (5) sdec(5) wide append
end
	regressions "treated"
	
*** well count regressions 
	regressions "well_count"
	* hyperbolic sine transform
	gen well_count_ihs = asinh(well_count)
	regressions "well_count_ihs"
	
********************************* END ******************************************

capture log close
exit
