* Prediction Model for Water Quality Measurement Before and After 
local fname an_predict_wq_monitoring

/*******************************************************************************

Author: Zirui Song
Date Created: Apr 23th, 2022
Date Modified: May 4th, 2022

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
	Get number of measurements per 5km distance bins for Figure S5 
	***************/	

*** import and clean distance data
	use "$datadir/data for Zirui/distances_upstream_computed.dta", clear
	* generate smallest upstream well distance for each ID_geo (monitoring station)
	collapse (min) distance_geodesic, by(ID_geo)
	* generate 0-5km, 0-10km, 0-15km, ..., 0-30km bins
	forv d = 5(5)30 {
		gen dist_bin_0to`d'km = 1 if distance_geodesic <= `d'
		replace dist_bin_0to`d'km = 0 if dist_bin_0to`d'km == .
	}
	save "$interdir/monitorstation_mindist.dta", replace
	
*** merge with water quality measurement sample	
	use "$datadir/DISC_TEMP_2020 OCT 2021 DEF B.dta", clear // water quality sample

	// drop missing wq obs.
	drop if log_t_t_Value_clean2 ==.
	// define estimation sample
	keep if Treated_ ==1 & m_cum_well_huc4_H_D == 1
	merge m:1 ID_geo using "$interdir/monitorstation_mindist.dta"

*** tab-out frequencies by distance bins into latex tables 
	* All Ions
	tabstat dist_bin_0to5km-dist_bin_0to30km, stats(sum)
	* Chloride
	keep if CharacteristicName == "Chloride"
	tabstat dist_bin_0to5km-dist_bin_0to30km, stats(sum)	

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

	// disc dates 
	// Based on the location of the WQS: 
	// All the dates have been moved to the 1st day of the month [the dataset has been collapsed at the huc10-year-month level]
	g disc_date       = "01feb2013" if STATE==1 // arkansas
	replace disc_date = "01apr2012" if STATE==2 // Colorado
	replace disc_date = "01dec2013" if STATE==3 // Kansas
	replace disc_date = "01mar2015" if STATE==4 // Kentucky
	replace disc_date = "01oct2011" if STATE==5 // Louisiana
	replace disc_date = "01mar2013" if STATE==6 // Mississippi
	replace disc_date = "01aug2011" if STATE==7 // Montana
	replace disc_date = "01feb2012" if STATE==8 // New Mexico
	replace disc_date = "01apr2012" if STATE==9 // North Dakota
	replace disc_date = "01sep2012" if STATE==10 // Ohio
	replace disc_date = "01jan2013" if STATE==11 // Oklahoma
	replace disc_date = "01apr2012" if STATE==12 // Pennsylvania
	replace disc_date = "01feb2012" if STATE==13 // Texas
	replace disc_date = "01nov2012" if STATE==14 // Utah
	replace disc_date = "01aug2011" if STATE==15 // West Virginia
	replace disc_date = "01aug2010" if STATE==16 // Wyoming
	tostring STATE, replace

	g disc_date_d = date(disc_date, "DMY")
	format disc_date_d %d

	// re-define treated HUC10s
	bysort huc10_s: egen T_HUC10_balanced1_3M = max(T_HUC10_balanced1_ALL)

	// re-define the date for the wq obs.
	gen date = "01" + date_string_month + date_string_year
	g date_d = date(date, "DMY")
	format date_d %d

	g post_disc = 1 if date_d>disc_date_d // it does not matter if we put > OR >=
	replace post_disc = 0 if post_disc ==.

	drop state_fe
	egen state_fe = group(STATE)
	egen huc10_state = group(huc10_s STATE)

	g huc8_s = substr(huc10_s,1,8)
	egen huc10_fe = group(huc10_s)
	egen huc8_fe = group(huc8_s)
	egen state_year_month_fe = group(STATE date_string_year date_string_month)
	egen huc8_year_month_fe = group(STATE huc8_s date_string_year date_string_month)
	egen huc10_s_month = group(STATE huc10_s date_string_month)

	
**************************** Robustness for Disclosure *************************

/**************
	Merge with Well Count Data
	***************/
	rename date_string_month date_string_monthM
	merge 1:1 huc10_s date_string_year date_string_monthM using "$datadir/ENTRY_TEMP_2020 OCT 2021.dta", force gen(_merge_entry)
	drop if _merge_entry==2
	
	replace Ttot_well_c_dH= 0 if Ttot_well_c_dH==.
	
	save "$basedir/water_measurement_main_data_20220426.xdta", replace
	
	* original tables by Pietro
	reghdfe OBS c.post_disc#c.T_HUC10_balanced1_3M, cluster(huc10_state) absorb(huc10_state state_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/Table_B8.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M) bracket bdec (5) sdec(5) replace addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, State*Month*Year FE, Yes, HUC10*Month FE, Yes)
	reghdfe OBS c.post_disc#c.T_HUC10_balanced1_3M, cluster(huc10_state) absorb(huc10_state huc8_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/Table_B8.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, HUC8*Month*Year FE, Yes, HUC10*Month FE, Yes)

	reghdfe number_reading c.post_disc#c.T_HUC10_balanced1_3M, cluster(huc10_state) absorb(huc10_state state_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/Table_B8.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, State*Month*Year FE, Yes, HUC10*Month FE, Yes)
	reghdfe number_reading c.post_disc#c.T_HUC10_balanced1_3M, cluster(huc10_state) absorb(huc10_state huc8_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/Table_B8.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, HUC8*Month*Year FE, Yes, HUC10*Month FE, Yes)

	reghdfe OBS c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH, cluster(huc10_state) absorb(huc10_state state_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/Table_B8.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, State*Month*Year FE, Yes, HUC10*Month FE, Yes)
	reghdfe OBS c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH, cluster(huc10_state) absorb(huc10_state huc8_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/Table_B8.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, HUC8*Month*Year FE, Yes, HUC10*Month FE, Yes)

	reghdfe number_reading c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH, cluster(huc10_state) absorb(huc10_state state_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/Table_B8.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, State*Month*Year FE, Yes, HUC10*Month FE, Yes)
	reghdfe number_reading c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH, cluster(huc10_state) absorb(huc10_state huc8_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/Table_B8.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, HUC8*Month*Year FE, Yes, HUC10*Month FE, Yes)
	
/**************
	Merge with County Characteristics Data
	***************/
	
*** education and voting data
	import delimited "$rawdir/voting data/house/2010_4_0_2.csv", varnames(1) clear
	drop if fips == "fips"
	destring fips, replace
	gen str5 fipscode = string(fips,"%05.0f")
	merge 1:1 fipscode using "$basedir/education by county.dta"
		drop if _merge != 3
		drop _merge
	destring democratic republican, replace
	gen democratic_house = 1 if democratic > republican
	replace democratic_house = 0 if democratic_house == .
	destring totalvote, replace
	gen democratic_ratio = democratic / totalvote
	keep democratic_house democratic_ratio *_2013_2017 fips
	save "$interdir/education_voting_county.dta", replace
	
	use "$basedir/water_measurement_main_data_20220426.dta", clear
	gen fips = 1000*fipstate + fipscounty
	merge m:1 fips using "$interdir/education_voting_county.dta"
		drop if _merge != 3
		drop _merge
		
	local county_covariates "high_school_2013_2017 high_school_only_2013_2017 college_2013_2017 democratic_house"
	foreach var of local county_covariates {
		gen `var'_int = `var'*post_disc*T_HUC10_balanced1_3M
	}
	
*** Interactions with Education and House Data
	local county_covariates_interactions "high_school_2013_2017_int high_school_only_2013_2017_int college_2013_2017_int democratic_house_int"
	
	reghdfe OBS c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions' `county_covariates', cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_robustness_voting_education.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions') bracket bdec (5) sdec(5) replace addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe OBS c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions' `county_covariates', cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_robustness_voting_education.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions') bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)

	reghdfe number_reading c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions', cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_robustness_voting_education.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions') bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe number_reading c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions', cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_robustness_voting_education.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions') bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)

	reghdfe OBS c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates_interactions', cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_robustness_voting_education.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions' Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe OBS c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates_interactions', cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_robustness_voting_education.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions' Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)

	reghdfe number_reading c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates_interactions', cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_robustness_voting_education.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions' Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe number_reading c.post_disc#c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates_interactions', cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_robustness_voting_education.xls", keep(c.post_disc#c.T_HUC10_balanced1_3M `county_covariates_interactions' Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)

************************ Measurement VS Fracking Activity **********************	
	
/**************
	Measurement and Fracking Intensity
	***************/
	
*** tabout measurement intensity for treated and untreated HUC10s
	reghdfe OBS c.T_HUC10_balanced1_3M, cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s.xls", keep(c.T_HUC10_balanced1_3M) bracket bdec (5) sdec(5) replace addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe OBS c.T_HUC10_balanced1_3M, cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s.xls", keep(c.T_HUC10_balanced1_3M) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)

	reghdfe number_reading c.T_HUC10_balanced1_3M, cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s.xls", keep(c.T_HUC10_balanced1_3M) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe number_reading c.T_HUC10_balanced1_3M, cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s.xls", keep(c.T_HUC10_balanced1_3M) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)
	
	* account for well counts
	reghdfe OBS c.T_HUC10_balanced1_3M Ttot_well_c_dH, cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s.xls", keep(c.T_HUC10_balanced1_3M Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe OBS c.T_HUC10_balanced1_3M Ttot_well_c_dH, cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s.xls", keep(c.T_HUC10_balanced1_3M Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)

	reghdfe number_reading c.T_HUC10_balanced1_3M Ttot_well_c_dH, cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s.xls", keep(c.T_HUC10_balanced1_3M Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe number_reading c.T_HUC10_balanced1_3M Ttot_well_c_dH, cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s.xls", keep(c.T_HUC10_balanced1_3M Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)
	
*** tabout measurement intensity for treated and untreated HUC10s (controlling for county characteristics)
	reghdfe OBS c.T_HUC10_balanced1_3M `county_covariates', cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s_education_voting.xls", keep(c.T_HUC10_balanced1_3M `county_covariates') bracket bdec (5) sdec(5) replace addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe OBS c.T_HUC10_balanced1_3M `county_covariates', cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s_education_voting.xls", keep(c.T_HUC10_balanced1_3M `county_covariates') bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)

	reghdfe number_reading c.T_HUC10_balanced1_3M `county_covariates', cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s_education_voting.xls", keep(c.T_HUC10_balanced1_3M `county_covariates') bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe number_reading c.T_HUC10_balanced1_3M `county_covariates', cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s_education_voting.xls", keep(c.T_HUC10_balanced1_3M `county_covariates') bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)
	
	* account for well counts
	reghdfe OBS c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates', cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s_education_voting.xls", keep(c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates') bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe OBS c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates', cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s_education_voting.xls", keep(c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates') bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)

	reghdfe number_reading c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates', cluster(state_fe) absorb(state_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s_education_voting.xls", keep(c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates') bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, State*Month*Year FE, Yes)
	reghdfe number_reading c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates', cluster(huc8_fe) absorb(huc8_year_month_fe)
	outreg2 using "$tabdir/water_measurement_treatedhuc10s_education_voting.xls", keep(c.T_HUC10_balanced1_3M Ttot_well_c_dH `county_covariates') bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC8*Month*Year FE, Yes)
	
*** measurement intensity w.r.t well counts 	
	reghdfe OBS Ttot_well_c_dH, cluster(huc10_state) absorb(huc10_state state_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/water_measurement_well_counts.xls", keep(Ttot_well_c_dH) bracket bdec (5) sdec(5) replace addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, State*Month*Year FE, Yes, HUC10*Month FE, Yes)
	reghdfe OBS Ttot_well_c_dH, cluster(huc10_state) absorb(huc10_state huc8_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/water_measurement_well_counts.xls", keep(Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, HUC8*Month*Year FE, Yes, HUC10*Month FE, Yes)

	reghdfe number_reading Ttot_well_c_dH, cluster(huc10_state) absorb(huc10_state state_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/water_measurement_well_counts.xls", keep(Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, State*Month*Year FE, Yes, HUC10*Month FE, Yes)
	reghdfe number_reading Ttot_well_c_dH, cluster(huc10_state) absorb(huc10_state huc8_year_month_fe huc10_s_month)
	outreg2 using "$tabdir/water_measurement_well_counts.xls", keep(Ttot_well_c_dH) bracket bdec (5) sdec(5) append addtext(Treated Sample, HUC10s with HF in pre, HUC10 FE, Yes, HUC8*Month*Year FE, Yes, HUC10*Month FE, Yes)
********************************* END ******************************************

capture log close
exit
