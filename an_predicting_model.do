* Prediction Model
local fname an_predicting_model

/*******************************************************************************

Author: Zirui Song
Date Created: Dec 16th, 2021
Date Modified: Jan 6th, 2021

********************************************************************************/

/**************
	Basic Set-up
	***************/
	clear all
	set more off, permanently
	capture log close
	
	set scheme s2mono
	
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
	Data Cleaning for the Dependent Variables 
	***************/
	
	* clean and use voting data
		import delimited "$rawdir/voting data/house/2010_4_0_2.csv", varnames(1) clear
		drop if fips == "fips"
		destring fips, replace
		gen str5 fipscode = string(fips,"%05.0f")
		merge 1:1 fipscode using "$basedir/education by county.dta", keepusing(state)
			drop if _merge != 3
			drop _merge
		destring democratic republican, replace
		collapse (sum) democratic republican, by(state)
		gen democratic_house = 1 if democratic > republican
		replace democratic_house = 0 if democratic_house >=.
		save "$interdir/house.dta", replace
	
		import delimited "$rawdir/voting data/presidential/2008_0_0_2.csv", varnames(1) clear
		drop if fips == "fips"
		destring fips, replace
		gen str5 fipscode = string(fips,"%05.0f")
		merge 1:1 fipscode using "$basedir/education by county.dta", keepusing(state)
			drop if _merge != 3
			drop _merge
		destring barackhobama johnsmccainiii, replace
		collapse (sum) barackhobama johnsmccainiii, by(state)
		gen democratic_president = 1 if barackhobama > johnsmccainiii
		replace democratic_president = 0 if democratic_president >=.
		save "$interdir/president.dta", replace
	
		import delimited "$rawdir/voting data/senate/2010_3_0_2.csv", varnames(1) clear
		drop if fips == "fips"
		destring fips, replace
		gen str5 fipscode = string(fips,"%05.0f")
		* drop duplicates due to different classes
		duplicates drop fipscode, force
		merge 1:1 fipscode using "$basedir/education by county.dta", keepusing(state)
			drop if _merge != 3
			drop _merge
		destring democratic republican, replace
		collapse (sum) democratic republican, by(state)
		gen democratic_senate = 1 if democratic > republican
		replace democratic_senate = 0 if democratic_senate >=.
		save "$interdir/senate.dta", replace
		* senate data only cover 35 states
	
		merge 1:1 state using "$interdir/house.dta"
		drop _merge
		merge 1:1 state using "$interdir/president.dta"
		drop _merge
		keep if (state == "AR") | (state == "CO") | (state == "KS") | (state == "MI") | ///
				(state == "MT") | (state == "NM") | (state == "ND") | (state == "OH") | ///
				(state == "OK") | (state == "PA") | (state == "TX") | (state == "UT") | ///
				(state == "WV") | (state == "WY") | (state == "MS")	
		keep state democratic_*
		save "$interdir/voting.dta", replace
	
	* obtain income and employment rate data
		use "$basedir/BEA_inc_emp_pop.dta", clear
		* get the states
		replace geoname = subinstr(geoname, "*", "", 1)
		gen state = substr(geoname, -2, .)
		keep if (state == "AR") | (state == "CO") | (state == "KS") | (state == "MI") | ///
				(state == "MT") | (state == "NM") | (state == "ND") | (state == "OH") | ///
				(state == "OK") | (state == "PA") | (state == "TX") | (state == "UT") | ///
				(state == "WV") | (state == "WY") | (state == "MS")	
		* get the income per capita and employment rate in states
		collapse (sum) personalincome_thousandUSD population employment, by(state)
		gen income_per_capita = personalincome_thousandUSD / population
		gen employment_rate = employment / population
		save "$interdir/income_employment_bystate.dta", replace
		
	* education data
		use "$basedir/education by county.dta", clear
		keep if (state == "AR") | (state == "CO") | (state == "KS") | (state == "MI") | ///
				(state == "MT") | (state == "NM") | (state == "ND") | (state == "OH") | ///
				(state == "OK") | (state == "PA") | (state == "TX") | (state == "UT") | ///
				(state == "WV") | (state == "WY") | (state == "MS")
		* keep the state aggregates only
		keep if substr(fipscode, -3, .) == "000"
		* keep only 2000 benchmarks 
		keep state *2000
		save "$interdir/education_bystate.dta", replace
	
	* huc10 data
		use "$basedir/huc10_tempDISC_2020 OCT 2021.dta", clear
		* get the total areas of huc10s in acres
		collapse (sum) areaacres, by(states)
		
		* if huc10s cross states, then count all the areas in all states affiliated
		gen state1 = substr(states, 1, 2)
		gen state2 = substr(states, 4, 2)
		gen state3 = substr(states, 7, 2)
		replace state2 = state1 if state2 == ""
		replace state3 = state1 if (state 2 == state 1)
		
		* generate areas and get the maximum one for the final  
		forv x = 1(1)3 {
			bysort state`x': egen area`x' = total(areaacres)
		}
		egen area = rowmax(area1-area3)
		drop if strlen(states) > 2
		drop if strlen(states) == 0
		rename states state
		keep state area
		save "$interdir/huc10area_bystate.dta", replace
	
	* use google_fracking trend
		use "$basedir/f_google", clear
		
		merge m:1 state time using "$basedir/disclosurerule_date.dta"
		* generate disclosure date var
			gen disc = 1 if _merge == 3
			replace disc = 0 if _merge != 3
			drop _merge
		*keep only states in the sample
		replace state = "AR" if state == "arkansas"
		replace state = "CO" if state == "colorado"
		replace state = "KS" if state == "kansas"
		replace state = "MI" if state == "michigan"
		replace state = "MS" if state == "mississippi"
		replace state = "MT" if state == "montana"
		replace state = "NM" if state == "newmexico"
		replace state = "ND" if state == "northdakota"
		replace state = "OH" if state == "ohio"
		replace state = "OK" if state == "oklahoma"
		replace state = "PA" if state == "pennsylvania"
		replace state = "TX" if state == "texas"
		replace state = "UT" if state == "utah"
		replace state = "WV" if state == "westvirginia"
		replace state = "WY" if state == "wyoming"
		keep if strlen(state) == 2
		
		* generate disc_time for each state
			gsort st -disc
			by st: gen disc_time = time[1]
			format disc_time %tm
			
		/* generate fracking search trend benchmarked as the average of search intensity 
		for 12 months prior to the disclosure rule adoption in each state*/
			bysort st: gen disc_time_minus1 = 1 if (disc_time-time <= 12 & disc_time-time > 0)
			replace disc_time_minus1 = 0 if disc_time_minus1 >=.
			bysort st: egen ggsearch_disc_time_minus1 = mean(fracking) if disc_time_minus1 == 1

			bysort st: gen disc_time_minus2 = 1 if (disc_time-time <= 24 & disc_time-time > 12)
			replace disc_time_minus2 = 0 if disc_time_minus2 >=.
			bysort st: egen ggsearch_disc_time_minus2 = mean(fracking) if disc_time_minus2 == 1

			
			collapse (max) ggsearch_disc_time_minus1 ggsearch_disc_time_minus2 disc_time, by(state)
			
			save "$interdir/ggsearch_disc_time_minus1.dta", replace
		
		
local S ""california" "massachusetts" "newyork""
foreach s of local S {
	* use google_fracking trend
		use "$basedir/f_google", clear
		
		* generate disclosure date var
			gen disc = 1 if time ==tm(2012m1)
			replace disc = 0 if disc ==.		
		
			keep if state == "`s'"
		
		* generate disc_time for each state
			gsort st -disc
			by st: gen disc_time = time[1]
			format disc_time %tm
			
		/* generate fracking search trend benchmarked as the average of search intensity 
		for 12 months prior to the disclosure rule adoption in each state*/
			bysort st: gen disc_time_minus1 = 1 if (disc_time-time <= 12 & disc_time-time > 0)
			replace disc_time_minus1 = 0 if disc_time_minus1 >=.
			bysort st: egen ggsearch_minus1`s' = mean(fracking) if disc_time_minus1 == 1

			bysort st: gen disc_time_minus2 = 1 if (disc_time-time <= 24 & disc_time-time > 12)
			replace disc_time_minus2 = 0 if disc_time_minus2 >=.
			bysort st: egen ggsearch_minus2`s' = mean(fracking) if disc_time_minus2 == 1

			
			collapse (max) ggsearch_minus1`s' ggsearch_minus2`s' disc_time, by(state)
			
			g ID = 1
			
			save "$interdir/ggsearch_disc_time_minus1`s'.dta", replace
			
			use "$basedir/f_google", clear

}


		
/**************
	Merge Everything Tother 
	***************/
	use "$interdir/ggsearch_disc_time_minus1.dta", clear
	merge 1:1 state using "$interdir/income_employment_bystate.dta"
	drop _merge
	merge 1:1 state using "$interdir/education_bystate.dta"
	drop _merge
	merge 1:1 state using "$interdir/huc10area_bystate.dta"
	drop _merge
	merge 1:1 state using "$interdir/voting.dta"
	* drop states of michigan as not in sample
	drop if _merge == 1
	drop _merge

	g ID = 1
	local s california
	merge m:1 ID using "$interdir/ggsearch_disc_time_minus1`s'.dta"
	drop _merge
	local s massachusetts
	merge m:1 ID using "$interdir/ggsearch_disc_time_minus1`s'.dta"
	drop _merge
	local s newyork
	merge m:1 ID using "$interdir/ggsearch_disc_time_minus1`s'.dta"
	drop _merge

	
	
/**************
	Three Outcome Variables (with OLS results)
	***************/
	
	lab var ggsearch_disc_time_minus1 "Average Google Search Intensity 1 year before Disclosure Rule"
	lab var income_per_capita "Income Per Capita"
	lab var employment_rate "Employment Rate"
	lab var area "Total Area (Well) in Square Acres"
	lab var democratic_house "Democratic House"
	lab var democratic_president "Democratic President"
	
	* 1. benchmarked on the first adoption date of disclosure rule
		egen first_disc_time = min(disc_time)
		format first_disc_time %tm
		gen disc_time_diff = disc_time - first_disc_time
		* drop the benchmark state of Wyoming
		drop if state == "WY"
		reg disc_time_diff ggsearch_disc_time_minus1 ///
		income_per_capita-college_2000 area democratic_house democratic_president
		estimates store model1
		
	* 2. benchmarked on the GasLand movie of Jan. 2010
		gen gasland_time =  monthly("Jan2010","MY")
		format gasland_time %tm
		gen disc_time_diff1 = disc_time - gasland_time
		reg disc_time_diff1 ggsearch_disc_time_minus1 ///
		income_per_capita-college_2000 area democratic_house democratic_president
		estimates store model2
		
	* 3. benchmarked on the time fracking starts
		gen fracking_time = monthly("Dec2016","MY")
		format fracking_time %tm
		gen disc_time_diff2 = disc_time - fracking_time
		reg disc_time_diff2 ggsearch_disc_time_minus1 ///
		income_per_capita-college_2000 area democratic_house democratic_president
		estimates store model3
		
	* output table
	esttab model1 model2 model3 using "$tabdir/prediction_model", ///
	label replace html r2 p
********************************* END ******************************************


																				// PIETRO ADDED THIS [300-339]

																				reg disc_time_diff1 ggsearch_disc_time_minus1 	
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide replace
																				reg disc_time_diff1 ggsearch_disc_time_minus1 income_per_capita
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append
																				reg disc_time_diff1 ggsearch_disc_time_minus1 college_2000
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append
																				reg disc_time_diff1 ggsearch_disc_time_minus1 democratic_house
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append
																				reg disc_time_diff1 ggsearch_disc_time_minus1 income_per_capita college_2000 democratic_house
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append
																				
																				reg disc_time_diff1 ggsearch_disc_time_minus2 	
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append
																				reg disc_time_diff1 ggsearch_disc_time_minus2 income_per_capita
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append
																				reg disc_time_diff1 ggsearch_disc_time_minus2 college_2000
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append
																				reg disc_time_diff1 ggsearch_disc_time_minus2 democratic_house
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append
																				reg disc_time_diff1 ggsearch_disc_time_minus2 income_per_capita college_2000 democratic_house
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append
																				
																				reg disc_time_diff1 ggsearch_disc_time_minus1 ggsearch_disc_time_minus2
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append
																				reg disc_time_diff1 ggsearch_disc_time_minus1 ggsearch_disc_time_minus2 income_per_capita college_2000 democratic_house
																				outreg2 using "$tabdir/prediction_disc_dates.xls", ///
																				bracket bdec (4) sdec(4) wide append

capture log close
exit
