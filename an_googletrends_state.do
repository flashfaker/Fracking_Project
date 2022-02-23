* Analyze Google Search Trends for Hydraulic Fracturing Data
local fname an_googletrends_state

/*******************************************************************************

Author: Zirui Song
Date Created: Dec 9th, 2021
Date Modified: Jan 4th, 2022

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
	Data Cleaning (Fracking)
	***************/
	use "$basedir/f_google", clear
	
	* generate california, new york, mass fracking search trends as reshaped to wide
	preserve 
		keep if state == "california" | state == "newyork" | state == "massachusetts"
		reshape wide fracking, i(time) j(state) string
		save "$basedir/googletrends_f_controlstates.dta", replace
	restore
	drop if state == "california" | state == "newyork" | state == "massachusetts" ///
	| state == "unitedstates"
	
	* generate a sub-dataset with the other neighboring states' ggtrend as controls
	preserve 
		keep if state == "alabama" | state == "arizona" | state == "delaware" | ///
				state == "idaho" | state == "indiana" | state == "kentucky" | ///
				state == "louisiana" | state == "maryland" | state == "minnesota" | ////
				state == "missouri" | state == "nebraska" | state == "nevada" | ///
				state == "newjersey" | state == "southdakota" | state == "tennessee" | ///
				state == "virginia" 
		save "$basedir/googletrends_f_neighboringstates.dta", replace
	restore
	drop if state == "alabama" | state == "arizona" | state == "delaware" | ///
			state == "idaho" | state == "indiana" | state == "kentucky" | ///
			state == "louisiana" | state == "maryland" | state == "minnesota" | ////
			state == "missouri" | state == "nebraska" | state == "nevada" | ///
			state == "newjersey" | state == "southdakota" | state == "tennessee" | ///
			state == "virginia" 
			
	joinby time using "$basedir/googletrends_f_controlstates.dta"
	encode state, gen(st)
	xtset st time
	
	* merge with disclosure date data by the 15 states
	merge m:1 state time using "$basedir/disclosurerule_date.dta"
	* generate disclosure date var
		gen disc = 1 if _merge == 3
		replace disc = 0 if _merge != 3
		drop _merge
		
	* generate disc proximity variable for regression
		* generate disc_time for each state
		gsort st -disc
		by st: gen disc_time = time[1]
		* replace disc as treatment (== 1 after disclosure rule, == 0 before disclosure rule)
		replace disc = 1 if time >= disc_time
		format disc_time %tm
		
		* generate monthly disc proximity variable (-12 or +24 months)
		forv x = 1(1)24 {
			bysort st (time): gen disc_plus_`x'months = 1 if (time-disc_time == `x')
			replace disc_plus_`x'months = 0 if disc_plus_`x'months >=.
		}
		forv x = 1(1)12 {
			bysort st (time): gen disc_minus_`x'months = 1 if (disc_time-time == `x')
			replace disc_minus_`x'months = 0 if disc_minus_`x'months >=.
		}
		bysort st (time): gen disc_minus_0months = 1 if (disc_time == time)
		replace disc_minus_0months = 0 if disc_minus_0months >=.
	
		* generate quarterly disc proximity variables (+- 8 quarters)
		forv x = 1/8 {
			local j = 3*`x'
			bysort st (time): gen disc_minus_`x'quarters = 1 if (disc_time-time <= `j' & disc_time-time+3 > `j')
			replace disc_minus_`x'quarters = 0 if disc_minus_`x'quarters >=.
			* generate mean of google search interest over time for the quarter
			bysort st: egen fracking_disc_minus_`x'quarters = mean(fracking) ///
					   if disc_minus_`x'quarters == 1 
			
			bysort st (time): gen disc_plus_`x'quarters = 1 if (time-disc_time < `j' & time-disc_time+3 >= `j')
			replace disc_plus_`x'quarters = 0 if disc_plus_`x'quarters >=.
			* generate mean of google search interest over time for the quarter
			bysort st: egen fracking_disc_plus_`x'quarters = mean(fracking) ///
					   if disc_plus_`x'quarters == 1
		} 
		
		* generate +8 or more quarters /or +24 or more months
		bysort st (time): gen disc_plus_8morequarters = 1 if (time - disc_time > 24)
		replace disc_plus_8morequarters = 0 if disc_plus_8morequarters >=.
		bysort st: egen fracking_disc_plus_8morequarters = mean(fracking) ///
				   if disc_plus_8morequarters == 1
		
		gen disc_plus_24moremonths = disc_plus_8morequarters
		gen fracking_disc_plus_24moremonths = fracking_disc_plus_8morequarters
		
																				
		// PIETRO ADDED THIS [136-144]
		* generate -8 or less quarters /or -12 or less months
		bysort st (time): gen disc_minus_8morequarters = 1 if (disc_time - time > 24)
		replace disc_minus_8morequarters = 0 if disc_minus_8morequarters >=.
		bysort st: egen fracking_disc_m_8morequarters = mean(fracking) ///
				   if disc_minus_8morequarters == 1

		bysort st (time): gen disc_minus_12moremonths = 1 if (disc_time - time > 12)
		replace disc_minus_12moremonths = 0 if disc_minus_12moremonths >=.
		bysort st: egen fracking_disc_m_12moremonths = mean(fracking) ///
				   if disc_minus_12moremonths == 1
		
	save "$basedir/fracking.dta", replace
	
	capture program drop clean_hf_hfp_data
	program define clean_hf_hfp_data
/**************
	Data Cleaning (Hydraulic Fracturing)
	***************/
	use "$basedir/hf_google", clear
	
	* generate california, new york, mass fracking search trends as reshaped to wide
	preserve 
		keep if state == "california" | state == "newyork" | state == "massachusetts"
		reshape wide hydraulicfracturing, i(time) j(state) string
		save "$basedir/googletrends_hf_controlstates.dta", replace
	restore
	* drop the coast/control states
	drop if state == "california" | state == "newyork" | state == "massachusetts" ///
	| state == "unitedstates"
	
	joinby time using "$basedir/googletrends_hf_controlstates.dta"
	encode state, gen(st)
	xtset st time
	
	* merge with disclosure date data by the 15 states
	merge m:1 state time using "$basedir/disclosurerule_date.dta"
	* generate disclosure date var
		gen disc = 1 if _merge == 3
		replace disc = 0 if _merge != 3
		drop _merge
		
	/* plot california, ny, and mass trends for desciptive stats
	foreach x of varlist hydraulicfracturingcalifornia-hydraulicfracturingnewyork {
		scatter `x' time, msymbol(x)
		graph export "$figdir/`x'.png", replace
	}*/

	* generate disc proximity variable for regression
		* generate disc_time for each state
		gsort st -disc
		by st: gen disc_time = time[1]
		* replace disc as treatment (== 1 after disclosure rule, == 0 before disclosure rule)
		replace disc = 1 if time >= disc_time
		format disc_time %tm
		
		* generate disc proximity variable
		forv x = 3(3)24 {
			bysort st: gen disc_minus_`x'months = 1 if (disc_time-time <= `x' & disc_time-time+3 > `x')
			replace disc_minus_`x'months = 0 if disc_minus_`x'months >=.
			/* generate sum of google search interest over time for the time horizon
			bysort st: egen ggtrend_hf_before_`x'months = sum(hydraulicfracturing) ///
					   if before_`x'months == 1*/
			
			bysort st: gen disc_plus_`x'months = 1 if (time-disc_time < `x' & time-disc_time+3 >= `x')
			replace disc_plus_`x'months = 0 if disc_plus_`x'months >=.
			/*bysort st: egen ggtrend_hf_after_`x'months = sum(hydraulicfracturing) ///
					   if after_`x'months == 1*/
		}
		
	save "$basedir/hydraulicfracturing.dta", replace
	
/**************
	Data Cleaning (Hydraulic Fracturing Proppants)
	***************/
	use "$basedir/hfp_google", clear
	
	* generate california, new york, mass hydraulic fracturing proppants search trends as reshaped to wide
	rename *hydraulicfracturingproppants* *hfproppants*
	preserve 
		keep if state == "california" | state == "newyork" | state == "massachusetts"
		reshape wide hfproppants, i(time) j(state) string
		save "$basedir/googletrends_hfp_controlstates.dta", replace
	restore
	* drop the coast/control states
	drop if state == "california" | state == "newyork" | state == "massachusetts" ///
	| state == "unitedstates"
	
	joinby time using "$basedir/googletrends_hfp_controlstates.dta"
	encode state, gen(st)
	xtset st time
	
	* merge with disclosure date data by the 15 states
	merge m:1 state time using "$basedir/disclosurerule_date.dta"
	* generate disclosure date var
		gen disc = 1 if _merge == 3
		replace disc = 0 if _merge != 3
		drop _merge
		
	/* plot california, ny, and mass trends for desciptive stats
	foreach x of varlist hfproppantscalifornia-hfproppantsnewyork {
		scatter `x' time, msymbol(x)
		graph export "$figdir/`x'.png", replace
	}*/

	* generate disc proximity variable for regression
		* generate disc_time for each state
		gsort st -disc
		by st: gen disc_time = time[1]
		* replace disc as treatment (== 1 after disclosure rule, == 0 before disclosure rule)
		replace disc = 1 if time >= disc_time
		format disc_time %tm 
		
		* generate disc proximity variable
		* generate disc proximity variable
		forv x = 3(3)24 {
			bysort st: gen disc_minus_`x'months = 1 if (disc_time-time <= `x' & disc_time-time+3 > `x')
			replace disc_minus_`x'months = 0 if disc_minus_`x'months >=.
			/* generate sum of google search interest over time for the time horizon
			bysort st: egen ggtrend_hfp_before_`x'months = sum(hfproppants) ///
					   if before_`x'months == 1*/
			
			bysort st: gen disc_plus_`x'months = 1 if (time-disc_time < `x' & time-disc_time+3 >= `x')
			replace disc_plus_`x'months = 0 if disc_plus_`x'months >=.
			/*bysort st: egen ggtrend_hfp_after_`x'months = sum(hfproppants) ///
					   if after_`x'months == 1*/
		}
		
	save "$basedir/hfproppants.dta", replace 
	
/**************
	Regression Results
	***************/	
	
	/*foreach y in fracking hydraulicfracturing hfproppants {
	
		use "$basedir/`y'.dta", clear
		
		gen state_fe = group(st)
		gen year_month_fe = group(time)
		
		local e "cluster(state_fe)" 
		local f "state_fe year_month_fe"
		
		* simply reg without controls for california, newyork, and mass
		reghdfe `y' disc, `e' absorb(`f')
		outreg2 using "$tabdir/disclosure_on_`y'", excel replace
		reghdfe disc `y', `e' absorb(`f')
		outreg2 using "$tabdir/`y'_on_disclosure", excel replace
			
		* reg disclosure rule of each 15 states on fracking trends of the 18 states
		reghdfe disc `y' `y'cali `y'mass `y'newyork, `e' absorb(`f')
		outreg2 using "$tabdir/`y'_on_disclosure_wcontrols", excel replace
		reghdfe `y' disc `y'cali `y'mass `y'newyork, `e' absorb(`f')
		outreg2 using "$tabdir/disclosure_on_`y'_wcontrols", excel replace

		* regression on 
		reghdfe `y' before_3months-after_24months, `e' absorb(`f')
	}*/
	end

/**************
	Regression Results
	***************/	
	
/***************************** Monthly Regressions ******************************/
	
	capture program drop monthly_regressions
	program define monthly_regressions
	forv i = 1/2 {
	
		* Monthly Regressions 
		use "$basedir/fracking.dta", clear
		drop *quarters
		
		drop disc_minus_`i'months
		
		gen state_fe = group(st)
		gen year_month_fe = group(time)
		local e "cluster(state_fe)" 
		local f "year_month_fe"
		local g "year_month_fe state_fe"
			
		* regressions with no neighboring states
		reghdfe fracking disc_minus_* disc_plus_*, `e' absorb(`f') 
		outreg2 using "$tabdir/ggtrend_fracking_monthlydummies1_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace
			
		reghdfe fracking disc_minus_* disc_plus_*, `e' absorb(`g') 
		outreg2 using "$tabdir/ggtrend_fracking_monthlydummies2_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace
		
		reghdfe fracking frackingcali frackingnewyork frackingmass disc_minus_* disc_plus_*, `e' absorb(`g') 
		outreg2 using "$tabdir/ggtrend_fracking_monthlydummies3_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace

		* regressions with neighboring states
		append using "$basedir/googletrends_f_neighboringstates.dta"
		drop st	
		encode state, gen(st)
		replace state_fe = group(st)
		replace year_month_fe = group(time)
		
		reghdfe fracking disc_minus_* disc_plus_*, `e' absorb(`f') 
		outreg2 using "$tabdir/ggtrend_fracking_monthlydummies4_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace
			
		reghdfe fracking disc_minus_* disc_plus_*, `e' absorb(`g') 
		outreg2 using "$tabdir/ggtrend_fracking_monthlydummies5_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace
		
		reghdfe fracking frackingcali frackingnewyork frackingmass disc_minus_* disc_plus_*, `e' absorb(`g') 
		outreg2 using "$tabdir/ggtrend_fracking_monthlydummies6_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace
	}
	end
		* import Excel file for graph
	capture program drop monthly_plots_1
	program define monthly_plots_1
		forv j = 1/6 {
			import delimited using "$tabdir/ggtrend_fracking_monthlydummies`j'_1.txt", clear
			
			if (`j' != 3 & `j' != 6) {
				drop in 1/3
				drop in 79/83
				replace v1 = "base" in 77
			} 
			else {
				drop in 1/9
				drop in 79/83 
				replace v1 = "base" in 77
			}
			
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
			gen time = -1 if v1 == "se_base" | v1 == "base"
			replace time = 0 if v1 == "disc_minus_0months" | v1 == "se_disc_minus_0months"
			replace time = 25 if v1 == "disc_plus_24moremonths" | v1 == "se_disc_plus_24moremonths"
			replace time = -13 if v1 == "disc_m_12moremonths" | v1 == "se_disc_m_12moremonths"
			
			forv x = 1/24 {
				if `x' < 10 {
					replace time = -`x' if substr(v1, -13, .) == "minus_`x'months"
					replace time = `x' if substr(v1, -12, .) == "plus_`x'months"
				} 
				else {
					replace time = -`x' if substr(v1, -14, .) == "minus_`x'months"
					replace time = `x' if substr(v1, -13, .) == "plus_`x'months" 
				}
			}
			
			replace v1 = "disc" if v1 == "base"
			replace v1 = substr(v1, 1, 2)
			reshape wide v2, i(time) j(v1) string
			rename v2di coef
			rename v2se se
			
			g int_down = coef - invnormal(0.025)*se
			g int_up = coef + invnormal(0.025)*se	
			
			twoway (line coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)) /// 
					(line int_down time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black))  ///
					(line int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black)), ///
					ylabel(#10, labsize(small) nogrid) ytick(#10)  ///
					yscale(r(-0.4(.1).4)) ///
					ytitle("Google Search Intensity", size(small) height(5))  ///
					yline(0, lstyle(foreground)) ///
					xline(-1, lcolor(ebg) lwidth(vvvthick)) ///
					xtitle("Time (Months)", size(small)) ///
					xlabel(-13 "<-12" -8 "-8" -4 "-4" 0 "0" ///
					4 "4" 8 "8" 12 "12" 16 "16" 20 "20" 25 ">24") ///
					legend(off) scheme(sj) ysize(2.8) xsize(4.2) graphregion(c(white) fcolor(white))
					graph display, ysize(2.8) xsize(4.2)
					graph export "$figdir/fracking_ggtrend_24months`j'_1.pdf", replace
		}
	end

	capture program drop monthly_plots_2
	program define monthly_plots_2
		forv j = 1/6 {
			import delimited using "$tabdir/ggtrend_fracking_monthlydummies`j'_2.txt", clear
			
			if (`j' != 3 & `j' != 6) {
				drop in 1/3
				drop in 79/83
				replace v1 = "base" in 77
			} 
			else {
				drop in 1/9
				drop in 79/83 
				replace v1 = "base" in 77
			}
			
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
			gen time = -2 if v1 == "se_base" | v1 == "base"
			replace time = 0 if v1 == "disc_minus_0months" | v1 == "se_disc_minus_0months"
			replace time = 25 if v1 == "disc_plus_24moremonths" | v1 == "se_disc_plus_24moremonths"
			replace time = -13 if v1 == "disc_m_12moremonths" | v1 == "se_disc_m_12moremonths"
			
			forv x = 1/24 {
				if `x' < 10 {
					replace time = -`x' if substr(v1, -13, .) == "minus_`x'months"
					replace time = `x' if substr(v1, -12, .) == "plus_`x'months"
				} 
				else {
					replace time = -`x' if substr(v1, -14, .) == "minus_`x'months"
					replace time = `x' if substr(v1, -13, .) == "plus_`x'months" 
				}
			}
			
			replace v1 = "disc" if v1 == "base"
			replace v1 = substr(v1, 1, 2)
			reshape wide v2, i(time) j(v1) string
			rename v2di coef
			rename v2se se
			
			g int_down = coef - invnormal(0.025)*se
			g int_up = coef + invnormal(0.025)*se	
			
			twoway (line coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)) /// 
					(line int_down time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black))  ///
					(line int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black)), ///
					ylabel(#10, labsize(small) nogrid) ytick(#10)  ///
					yscale(r(-0.4(.1).4)) ///
					ytitle("Google Search Intensity", size(small) height(5))  ///
					yline(0, lstyle(foreground)) ///
					xline(-2, lcolor(ebg) lwidth(vvvthick)) ///
					xtitle("Time (Months)", size(small)) ///
					xlabel(-13 "<-12" -8 "-8" -4 "-4" 0 "0" ///
					4 "4" 8 "8" 12 "12" 16 "16" 20 "20" 25 ">24") ///
					legend(off) scheme(sj) ysize(2.8) xsize(4.2) graphregion(c(white) fcolor(white))
					graph display, ysize(2.8) xsize(4.2)
					graph export "$figdir/fracking_ggtrend_24months`j'_2.pdf", replace
		}
	end
	
/***************************** Quarterly Regressions ******************************/	
	
	capture program drop clean_quarterly_data
	program define clean_quarterly_data
	use "$basedir/fracking.dta", clear
	drop *months
		/* drop (within disclosure states) the trends outside of the 24-month interval
		* Note that for +/-8 quarters, we have only 48 months instead of 49 as in 
		* months case because of the fact that disclosure rule adoption date is 
		* included in the sample as the first quarter
		drop if (disc_time - time > 24 | time - disc_time > 23)*/
	
	gen day=dofm(time)
	format day %td
	gen quarter=qofd(day)
	format quarter %tq
	
	bysort quarter: egen frackingcalifornia1 = mean(frackingcalifornia)
	bysort quarter:	egen frackingnewyork1 = mean(frackingnewyork)
	bysort quarter: egen frackingmassachusetts1 = mean(frackingmassachusetts)
		drop frackingcalifornia frackingnewyork frackingmassachusetts
		rename (frackingcalifornia1 frackingnewyork1 frackingmassachusetts1) ///
		   (frackingcalifornia frackingnewyork frackingmassachusetts)
		   
	egen fracking_gg = rowtotal(fracking_*)
	/* drop duplicaes of fracking search trends (because there are three currently
	per quarter*/
	forv x = 1(1)8 {
		bysort state disc_plus_`x'quarters (time): gen n = _n if disc_plus_`x'quarters == 1
		drop if n == 1 | n == 3
		drop n
		bysort state disc_minus_`x'quarters (time): gen n = _n if disc_minus_`x'quarters == 1
		drop if n == 1 | n == 3
		drop n
	}
	
	/* keep the first monthly date as the benchmark >8 quarters dummies
	bysort state disc_plus_8morequarters (time): gen n = _n if disc_plus_8morequarters == 1
	keep if n == 1 | n >=. 
	drop n */
	
	save "$interdir/quarterly_fracking_gg.dta", replace
	
	end
	
	// PIETRO ADDED THIS [454-457]
	// this way and with the above addition, we estimate the coefficients relative to the quarters leading up to the mandates

	capture program drop quarterly_regressions
	program define quarterly_regressions
	forval i = 1/4 {

	use "$interdir/quarterly_fracking_gg.dta", clear
	
	drop disc_minus_`i'quarters 
	
	gen state_fe = group(st)
	gen year_quarter_fe = group(quarter)
	local e "cluster(state_fe)" 												// given the very limited number of clusters, I would use robust standards errors as a check//
	local f "year_quarter_fe"
	local g "year_quarter_fe state_fe"
	
	* regressions with no neighboring states
		reghdfe fracking_gg disc_plus_* disc_minus_*, `e' absorb(`f') 
		outreg2 using "$tabdir/ggtrend_fracking_quarterlydummies1_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace
			
		reghdfe fracking_gg disc_plus_* disc_minus_*, `e' absorb(`g') 
		outreg2 using "$tabdir/ggtrend_fracking_quarterlydummies2_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace
		
		reghdfe fracking_gg frackingcali frackingnewyork frackingmass ///
		disc_plus_* disc_minus_*, `e' absorb(`g') 
		outreg2 using "$tabdir/ggtrend_fracking_quarterlydummies3_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace

	* regressions with neighboring states
		use "$basedir/googletrends_f_neighboringstates.dta", clear
			gen day=dofm(time)
			format day %td
			gen quarter=qofd(day)
			format quarter %tq
			collapse (mean) fracking_gg=fracking, by(state quarter)
			save "$basedir/googletrends_f_neighboringstates_quarterly.dta", replace
		
		use "$interdir/quarterly_fracking_gg.dta", clear
		append using "$basedir/googletrends_f_neighboringstates_quarterly.dta"
		
		drop time fracking
		
		drop disc_minus_`i'quarters 
		
		drop st	
		encode state, gen(st)
		gen state_fe = group(st)
		gen year_quarter_fe = group(quarter)
		local e "cluster(state_fe)" 
		local f "year_quarter_fe"
		local g "year_quarter_fe state_fe"
		reghdfe fracking_gg disc_plus_* disc_minus_*, `e' absorb(`f') 
		outreg2 using "$tabdir/ggtrend_fracking_quarterlydummies4_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace
			
		reghdfe fracking_gg disc_plus_* disc_minus_*, `e' absorb(`g') 
		outreg2 using "$tabdir/ggtrend_fracking_quarterlydummies5_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace
		
		reghdfe fracking_gg frackingcali frackingnewyork frackingmass ///
		disc_plus_* disc_minus_*, `e' absorb(`g') 
		outreg2 using "$tabdir/ggtrend_fracking_quarterlydummies6_`i'.xls", ///
		bracket bdec (5) sdec(5) wide replace
	}
	end
		// PIETRO COMMENT: to be updated based on the new variables

		* import Excel file for graph
			
	capture program drop quarterly_plots_1
	program define quarterly_plots_1
		forv j = 1/6 {
			import delimited using "$tabdir/ggtrend_fracking_quarterlydummies`j'_1.txt", clear
			
			if (`j' != 3 & `j' != 6) {
				drop in 1/3
				drop in 37/41
				replace v1 = "base" in 35
			} 
			else {
				drop in 1/9
				drop in 37/41
				replace v1 = "base" in 35
			}
			
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
			gen time = 0 if v1 == "se_base" | v1 == "base"
			replace time = -1 if substr(v1, -15, .) == "minus_2quarters"

			replace time = -2 if substr(v1, -15, .) == "minus_3quarters"
			replace time = -3 if substr(v1, -15, .) == "minus_4quarters"
			replace time = -4 if substr(v1, -15, .) == "minus_5quarters"
			replace time = -5 if substr(v1, -15, .) == "minus_6quarters"
			replace time = -6 if substr(v1, -15, .) == "minus_7quarters"
			replace time = -7 if substr(v1, -15, .) == "minus_8quarters"
			replace time = -8 if substr(v1, -19, .) == "minus_8morequarters"
			replace time = 1 if substr(v1, -14, .) == "plus_1quarters"
			replace time = 2 if substr(v1, -14, .) == "plus_2quarters"
			replace time = 3 if substr(v1, -14, .) == "plus_3quarters"
			replace time = 4 if substr(v1, -14, .) == "plus_4quarters"
			replace time = 5 if substr(v1, -14, .) == "plus_5quarters"
			replace time = 6 if substr(v1, -14, .) == "plus_6quarters"
			replace time = 7 if substr(v1, -14, .) == "plus_7quarters"
			replace time = 8 if substr(v1, -14, .) == "plus_8quarters"
			replace time = 9 if substr(v1, -18, .) == "plus_8morequarters"


			replace v1 = "disc" if v1 == "base"
			replace v1 = substr(v1, 1, 2)
			reshape wide v2, i(time) j(v1) string
			rename v2di coef
			rename v2se se
			
			g int_down = coef - invnormal(0.025)*se
			g int_up = coef + invnormal(0.025)*se	
			
			twoway (scatter coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)) /// 
					(rspike int_down int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black))  ///
					(rcap int_down int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black)) ///
					(scatter coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)), ///
					ylabel(#10, labsize(small) nogrid) ytick(#10)  ///
					yscale(r(-0.4(.1).4)) ///
					ytitle("Google Search Intensity", size(small) height(5))  ///
					yline(0, lstyle(foreground)) ///
					xline(0, lcolor(ebg) lwidth(vvvthick)) ///
					xtitle("Time (Quarters)", size(small)) ///
					xlabel(-8 "<=-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" ///
					0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 ">8") ///
					legend(off) scheme(sj) ysize(2.8) xsize(4.2) graphregion(c(white) fcolor(white))
					graph display, ysize(2.8) xsize(4.2)
					graph export "$figdir/fracking_ggtrend_8quarters`j'_1.pdf", replace
		}
	end
	
	capture program drop quarterly_plots_2
	program define quarterly_plots_2
		forv j = 1/6 {
			import delimited using "$tabdir/ggtrend_fracking_quarterlydummies`j'_2.txt", clear
			
			if (`j' != 3 & `j' != 6) {
				drop in 1/3
				drop in 37/41
				replace v1 = "base" in 35
			} 
			else {
				drop in 1/9
				drop in 37/41
				replace v1 = "base" in 35
			}
			
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
			gen time = -1 if v1 == "se_base" | v1 == "base"
			replace time = 0 if substr(v1, -15, .) == "minus_1quarters"
			*replace time = -1 if substr(v1, -15, .) == "minus_2quarters"	
			replace time = -2 if substr(v1, -15, .) == "minus_3quarters"
			replace time = -3 if substr(v1, -15, .) == "minus_4quarters"
			replace time = -4 if substr(v1, -15, .) == "minus_5quarters"
			replace time = -5 if substr(v1, -15, .) == "minus_6quarters"
			replace time = -6 if substr(v1, -15, .) == "minus_7quarters"
			replace time = -7 if substr(v1, -15, .) == "minus_8quarters"
			replace time = -8 if substr(v1, -19, .) == "minus_8morequarters"
			replace time = 1 if substr(v1, -14, .) == "plus_1quarters"
			replace time = 2 if substr(v1, -14, .) == "plus_2quarters"
			replace time = 3 if substr(v1, -14, .) == "plus_3quarters"
			replace time = 4 if substr(v1, -14, .) == "plus_4quarters"
			replace time = 5 if substr(v1, -14, .) == "plus_5quarters"
			replace time = 6 if substr(v1, -14, .) == "plus_6quarters"
			replace time = 7 if substr(v1, -14, .) == "plus_7quarters"
			replace time = 8 if substr(v1, -14, .) == "plus_8quarters"
			replace time = 9 if substr(v1, -18, .) == "plus_8morequarters"


			replace v1 = "disc" if v1 == "base"
			replace v1 = substr(v1, 1, 2)
			reshape wide v2, i(time) j(v1) string
			rename v2di coef
			rename v2se se
			
			g int_down = coef - invnormal(0.025)*se
			g int_up = coef + invnormal(0.025)*se	
			
			twoway (scatter coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)) /// 
					(rspike int_down int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black))  ///
					(rcap int_down int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black)) ///
					(scatter coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)), ///
					ylabel(#10, labsize(small) nogrid) ytick(#10)  ///
					yscale(r(-0.4(.1).4)) ///
					ytitle("Google Search Intensity", size(small) height(5))  ///
					yline(0, lstyle(foreground)) ///
					xline(-1, lcolor(ebg) lwidth(vvvthick)) ///
					xtitle("Time (Quarters)", size(small)) ///
					xlabel(-8 "<=-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" ///
					0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 ">8") ///
					legend(off) scheme(sj) ysize(2.8) xsize(4.2) graphregion(c(white) fcolor(white))
					graph display, ysize(2.8) xsize(4.2)
					graph export "$figdir/fracking_ggtrend_8quarters`j'_2.pdf", replace
		}
	end
	
	capture program drop quarterly_plots_3
	program define quarterly_plots_3
		forv j = 1/6 {
			import delimited using "$tabdir/ggtrend_fracking_quarterlydummies`j'_3.txt", clear
			
			if (`j' != 3 & `j' != 6) {
				drop in 1/3
				drop in 37/41
				replace v1 = "base" in 35
			} 
			else {
				drop in 1/9
				drop in 37/41
				replace v1 = "base" in 35
			}
			
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
			gen time = -2 if v1 == "se_base" | v1 == "base"
			replace time = 0 if substr(v1, -15, .) == "minus_1quarters"
			replace time = -1 if substr(v1, -15, .) == "minus_2quarters"	
			*replace time = -2 if substr(v1, -15, .) == "minus_3quarters"
			replace time = -3 if substr(v1, -15, .) == "minus_4quarters"
			replace time = -4 if substr(v1, -15, .) == "minus_5quarters"
			replace time = -5 if substr(v1, -15, .) == "minus_6quarters"
			replace time = -6 if substr(v1, -15, .) == "minus_7quarters"
			replace time = -7 if substr(v1, -15, .) == "minus_8quarters"
			replace time = -8 if substr(v1, -19, .) == "minus_8morequarters"
			replace time = 1 if substr(v1, -14, .) == "plus_1quarters"
			replace time = 2 if substr(v1, -14, .) == "plus_2quarters"
			replace time = 3 if substr(v1, -14, .) == "plus_3quarters"
			replace time = 4 if substr(v1, -14, .) == "plus_4quarters"
			replace time = 5 if substr(v1, -14, .) == "plus_5quarters"
			replace time = 6 if substr(v1, -14, .) == "plus_6quarters"
			replace time = 7 if substr(v1, -14, .) == "plus_7quarters"
			replace time = 8 if substr(v1, -14, .) == "plus_8quarters"
			replace time = 9 if substr(v1, -18, .) == "plus_8morequarters"


			replace v1 = "disc" if v1 == "base"
			replace v1 = substr(v1, 1, 2)
			reshape wide v2, i(time) j(v1) string
			rename v2di coef
			rename v2se se
			
			g int_down = coef - invnormal(0.025)*se
			g int_up = coef + invnormal(0.025)*se	
			
			twoway (scatter coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)) /// 
					(rspike int_down int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black))  ///
					(rcap int_down int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black)) ///
					(scatter coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)), ///
					ylabel(#10, labsize(small) nogrid) ytick(#10)  ///
					yscale(r(-0.4(.1).4)) ///
					ytitle("Google Search Intensity", size(small) height(5))  ///
					yline(0, lstyle(foreground)) ///
					xline(-2, lcolor(ebg) lwidth(vvvthick)) ///
					xtitle("Time (Quarters)", size(small)) ///
					xlabel(-8 "<=-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" ///
					0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 ">8") ///
					legend(off) scheme(sj) ysize(2.8) xsize(4.2) graphregion(c(white) fcolor(white))
					graph display, ysize(2.8) xsize(4.2)
					graph export "$figdir/fracking_ggtrend_8quarters`j'_3.pdf", replace
		}
	end
	
	capture program drop quarterly_plots_4
	program define quarterly_plots_4
		forv j = 1/6 {
			import delimited using "$tabdir/ggtrend_fracking_quarterlydummies`j'_4.txt", clear
			
			if (`j' != 3 & `j' != 6) {
				drop in 1/3
				drop in 37/41
				replace v1 = "base" in 35
			} 
			else {
				drop in 1/9
				drop in 37/41
				replace v1 = "base" in 35
			}
			
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
			gen time = -3 if v1 == "se_base" | v1 == "base"
			replace time = 0 if substr(v1, -15, .) == "minus_1quarters"
			replace time = -1 if substr(v1, -15, .) == "minus_2quarters"	
			replace time = -2 if substr(v1, -15, .) == "minus_3quarters"
			*replace time = -3 if substr(v1, -15, .) == "minus_4quarters"
			replace time = -4 if substr(v1, -15, .) == "minus_5quarters"
			replace time = -5 if substr(v1, -15, .) == "minus_6quarters"
			replace time = -6 if substr(v1, -15, .) == "minus_7quarters"
			replace time = -7 if substr(v1, -15, .) == "minus_8quarters"
			replace time = -8 if substr(v1, -19, .) == "minus_8morequarters"
			replace time = 1 if substr(v1, -14, .) == "plus_1quarters"
			replace time = 2 if substr(v1, -14, .) == "plus_2quarters"
			replace time = 3 if substr(v1, -14, .) == "plus_3quarters"
			replace time = 4 if substr(v1, -14, .) == "plus_4quarters"
			replace time = 5 if substr(v1, -14, .) == "plus_5quarters"
			replace time = 6 if substr(v1, -14, .) == "plus_6quarters"
			replace time = 7 if substr(v1, -14, .) == "plus_7quarters"
			replace time = 8 if substr(v1, -14, .) == "plus_8quarters"
			replace time = 9 if substr(v1, -18, .) == "plus_8morequarters"


			replace v1 = "disc" if v1 == "base"
			replace v1 = substr(v1, 1, 2)
			reshape wide v2, i(time) j(v1) string
			rename v2di coef
			rename v2se se
			
			g int_down = coef - invnormal(0.025)*se
			g int_up = coef + invnormal(0.025)*se	
			
			twoway (scatter coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)) /// 
					(rspike int_down int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black))  ///
					(rcap int_down int_up time, sort msize(thin) mlwidth(thin) lwidth(thin) mcolor(black)) ///
					(scatter coef time, sort lc(black) lp(shortdash) msize(thin) mfcolor(white) mlcolor(black) mlwidth(thin) msymbol(circle)), ///
					ylabel(#10, labsize(small) nogrid) ytick(#10)  ///
					yscale(r(-0.4(.1).4)) ///
					ytitle("Google Search Intensity", size(small) height(5))  ///
					yline(0, lstyle(foreground)) ///
					xline(-3, lcolor(ebg) lwidth(vvvthick)) ///
					xtitle("Time (Quarters)", size(small)) ///
					xlabel(-8 "<=-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" ///
					0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 ">8") ///
					legend(off) scheme(sj) ysize(2.8) xsize(4.2) graphregion(c(white) fcolor(white))
					graph display, ysize(2.8) xsize(4.2)
					graph export "$figdir/fracking_ggtrend_8quarters`j'_4.pdf", replace
		}
	end
	quarterly_regressions
	*quarterly_plots_1
	*quarterly_plots_2
	quarterly_plots_3
	quarterly_plots_4
	
	*monthly_regressions
	*monthly_plots_1
	*monthly_plots_2
	
			
********************************* END ******************************************

capture log close
exit
