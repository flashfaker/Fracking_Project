***********
* Table 3 *
***********
global dropbox = "/Users/zsong98/Dropbox/Fracking Disclosure regulation project"
global datadir = "$dropbox/1. data"

// set output directory
cd "$dropbox/6. results/zs/Table 3 Placebo Test"

** 1
  * Treatment: HUC10s in treated states w/HF in the pre-disclosure period
    ** at least pre can include pre only and/or pre and post
	
  * Control: HUC10s, over treated HUC4s, w/o HF in the pre-disclosure period
    ** which may include only post or no pre and post
		** drop from the treatment sample observations before the first frack occurs within an HUC10
		** drop from the sample HUC10s with HF only in the post disclosure period

/**********
	New by Zirui (Modified Feb 17th, 2022)
	**********/

	* get the state names matched to fips code and mege with ggsearch peak csv.
	import excel "$dropbox/2. code/zs/data/base/state-geocodes-v2017.xlsx", sheet("CODES14") ///
	cellrange(C6:D70) firstrow clear
	rename (StateFIPS Name) (fipstate state)
	replace state = lower(state)
	replace state = subinstr(state, " ", "", .)
	drop if fipstate == "00"
	destring fipstate, replace
	sort fipstate
	merge 1:m state using "$dropbox/2. code/zs/data/base/peak_googletrends_state"
	* all merged
	drop if _merge != 3 
	drop _merge
	keep if peak == 1
	save "$dropbox/2. code/zs/data/base/ggpeak_withfipstate", replace
	
	* use start of the legislative process
	use "$dropbox/2. code/zs/data/base/disclosurerule_dateUpdated", clear
	rename time disc_start_time
	drop if state == "michigan"
	merge 1:1 state using "$dropbox/2. code/zs/data/base/ggpeak_withfipstate"
	rename time peak_time
	keep state disc_start_time fipstate peak_time
	save "$dropbox/2. code/zs/data/base/discandggpeak_time_withfipstate", replace
	
	* use disclosure rule mandate
	use "$dropbox/2. code/zs/data/base/disclosurerule_datePB", clear
	rename time disc_time
	drop if state == "michigan"
	merge 1:1 state using "$dropbox/2. code/zs/data/base/discandggpeak_time_withfipstate"
	keep state disc_start_time disc_time fipstate peak_time
	save "$dropbox/2. code/zs/data/base/discandggpeak_time_withfipstate", replace
	
	
/**********
	Summary Statistics of Disclosure Dates, Google Search
	**********/
	* keep only disclosure states for this summary statistic table
	keep if disc_time !=.
	gen disc_time_month = mofd(disc_start_time)
	drop disc_time 
	rename disc_time_month disc_time
	format disc_time %tm
	gen before_state = 1 if disc_time <= peak_time 
	replace before_state = 0 if before_state >=.
	bysort before_state: gen count = _N
	gen diff = peak_time - disc_time
	collapse (mean) mean_diff = diff (median) median_diff = diff (first) count, by(before_state)
	save "Summary Statistics", replace
	
********************************************************************************
	use "$datadir/DISC_TEMP_2020 OCT 2021 DEF B.dta", clear
	rename StateCode fipstate
	destring fipstate, replace
	merge m:1 fipstate using "$dropbox/2. code/zs/data/base/discandggpeak_time_withfipstate", keepusing(disc_time disc_start_time peak_time)
		* 357,212 unmatched due to only 34 states in google search analysis (only fracking and adjacent states included)
		drop if _merge != 3
		drop _merge
		
	gen monthly = monthly(M_Y, "MY")
	format monthly %tm
	gen post_peak = 1 if peak_time <= monthly
	replace post_peak = 0 if post_peak >=.
	/* replace the post_disc dummy with the new set of disclosure */
	replace post_disc = 1 if disc_time <= monthly
	replace post_disc = 0 if disc_time >=.
	
	/* generate interactions 
		// generate earlier date (gg search peak or disclosure rule)
		egen earlier_date = rowmax(post_peak post_disc)
		egen later_date = rowmin(post_peak post_disc)*/
	
	* generate dummies (google search trend before/after effective date)
		* generate monthly disc_time
		gen disc_start_time_month = mofd(disc_start_time)
		format disc_start_time_month %tm
		
		sort fipstate date
		gen disc_before_ggpeak = 1 if disc_start_time_month <= peak_time
		replace disc_before_ggpeak = 0 if disc_before_ggpeak >=.
		
		gen disc_after_ggpeak = 1 if disc_start_time_month > peak_time & disc_start_time !=.
		replace disc_after_ggpeak = 0 if disc_after_ggpeak >=.
		
		* generate interaction between post_disc and before/after 
		gen post_disc_before = disc_before_ggpeak * post_disc
		gen post_disc_after = disc_after_ggpeak * post_disc
		gen post_peak_before = disc_before_ggpeak * post_peak
		gen post_peak_after = disc_after_ggpeak * post_peak
		
	save "$datadir/Table3_ZS", replace	
	
	
/**********
	Regressions
	**********/
	
********************************************************************************
	use "$datadir/Table3_ZS", clear
	// regressions with disc_before_ggpeak and disc_after_ggpeak 
	
	capture program drop two_variable_regression 
	program define two_variable_regression
	args var1 var2 ions namesuffix
	local treatment 1
	local errors ""cluster(huc10_state)""
	local items `ions'
	local Ys ""log_t_t_Value_clean2""
	local fe ""ID_geo_feN""
	foreach y of local Ys {
	foreach p of local treatment {
	foreach k of local items {
	foreach f of local fe {
	foreach e of local errors {

		reghdfe `y' c.`var1'#c.T_HUC10_balanced`p'_`k' c.`var2'#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_fe huc8_month_fe)
			outreg2 using Tab3_`ions'_`var1'and`var2'_`namesuffix'.xls, /// * location of the file
			keep(c.`var1'#c.T_HUC10_balanced`p'_`k' c.`var2'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) replace ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
		reghdfe `y' c.`var1'#c.T_HUC10_balanced`p'_`k' c.`var2'#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_fe)
			outreg2 using Tab3_`ions'_`var1'and`var2'_`namesuffix'.xls, /// * location of the file
			keep(c.`var1'#c.T_HUC10_balanced`p'_`k' c.`var2'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display file 
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) append ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

	}
	}
	}
	}
	}
	end

	capture program drop one_variable_regression
	program define one_variable_regression
	args var1 ions namesuffix
	local treatment 1
	local errors ""cluster(huc10_state)""
	local items `ions'
	local Ys ""log_t_t_Value_clean2""
	local fe ""ID_geo_feN""
	foreach y of local Ys {
	foreach p of local treatment {
	foreach k of local items {
	foreach f of local fe {
	foreach e of local errors {

		reghdfe `y' c.`var1'#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_fe huc8_month_fe)
			outreg2 using Tab3_`ions'_`var1'_`namesuffix'.xls, /// * location of the file
			keep(c.`var1'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) replace ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
		reghdfe `y' c.`var1'#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_fe)
			outreg2 using Tab3_`ions'_`var1'_`namesuffix'.xls, /// * location of the file
			keep(c.`var1'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display file 
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) append ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

	}
	}
	}
	}
	}
	end
	
* all 
	capture program drop two_variable_regression_all
	program define two_variable_regression_all
	args var1 var2 namesuffix
	local errors ""cluster(huc10_state)""
	local Ys ""log_t_t_Value_clean2""
	local fe ""ID_geo_feNCha""
	local k ALL
	local p 1
	foreach y of local Ys {
	foreach f of local fe {
	foreach e of local errors {

		reghdfe `y' c.`var1'#c.T_HUC10_balanced`p'_`k' c.`var2'#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_feCha huc8_month_feCha)
			outreg2 using Tab3_`k'_`var1'and`var2'_`namesuffix'.xls, /// * location of the file
			keep(c.`var1'#c.T_HUC10_balanced`p'_`k' c.`var2'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) replace ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
		reghdfe `y' c.`var1'#c.T_HUC10_balanced`p'_`k' c.`var2'#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_feCha)
			outreg2 using Tab3_`k'_`var1'and`var2'_`namesuffix'.xls, /// * location of the file
			keep(c.`var1'#c.T_HUC10_balanced`p'_`k' c.`var2'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) append ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

	}
	}
	}
	end
	
	capture program drop one_variable_regression_all
	program define one_variable_regression_all
	args var1 namesuffix
	local errors ""cluster(huc10_state)""
	local Ys ""log_t_t_Value_clean2""
	local fe ""ID_geo_feNCha""
	local k ALL
	local p 1
	foreach y of local Ys {
	foreach f of local fe {
	foreach e of local errors {

		reghdfe `y' c.`var1'#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_feCha huc8_month_feCha)
			outreg2 using Tab3_`k'_`var1'_`namesuffix'.xls, /// * location of the file
			keep(c.`var1'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) replace ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
		reghdfe `y' c.`var1'#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_feCha)
			outreg2 using Tab3_`k'_`var1'_`namesuffix'.xls, /// * location of the file
			keep(c.`var1'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) append ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

	}
	}
	}
	end

********************************************************************************
	// Full Sample Regressions 
	two_variable_regression "post_disc_before" "post_disc_after" "3" "full"
	two_variable_regression_all "post_disc_before" "post_disc_after" "full"
	//two_variable_regression "post_disc" "post_peak" "3" "full"
	//two_variable_regression_all "post_disc" "post_peak" "full"

	local treatment 1
	local errors ""cluster(huc10_state)""
	local items 3
	local Ys ""log_t_t_Value_clean2""
	local fe ""ID_geo_feN""
	foreach y of local Ys {
	foreach p of local treatment {
	foreach k of local items {
	foreach f of local fe {
	foreach e of local errors {

		reghdfe `y' c.post_disc_before#c.T_HUC10_balanced`p'_`k' ///
					c.post_disc_after#c.T_HUC10_balanced`p'_`k' ///
					c.post_peak_before#c.T_HUC10_balanced`p'_`k' ///
					c.post_peak_after#c.T_HUC10_balanced`p'_`k' ///
					log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_fe huc8_month_fe)
			outreg2 using Tab3_3_horserace_full.xls, /// * location of the file
			keep(c.post_disc_before#c.T_HUC10_balanced`p'_`k' c.post_disc_after#c.T_HUC10_balanced`p'_`k' c.post_peak_before#c.T_HUC10_balanced`p'_`k' c.post_peak_after#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) replace ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
		reghdfe `y' c.post_disc_before#c.T_HUC10_balanced`p'_`k' ///
					c.post_disc_after#c.T_HUC10_balanced`p'_`k' ///
					c.post_peak_before#c.T_HUC10_balanced`p'_`k' ///
					c.post_peak_after#c.T_HUC10_balanced`p'_`k' ///  
					log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_fe)
			outreg2 using Tab3_3_horserace_full.xls, /// * location of the file
			keep(c.post_disc_before#c.T_HUC10_balanced`p'_`k' c.post_disc_after#c.T_HUC10_balanced`p'_`k' c.post_peak_before#c.T_HUC10_balanced`p'_`k' c.post_peak_after#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) append ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

	}
	}
	}
	}
	}
	
	local errors ""cluster(huc10_state)""
	local Ys ""log_t_t_Value_clean2""
	local fe ""ID_geo_feNCha""
	local k ALL
	local p 1
	foreach y of local Ys {
	foreach f of local fe {
	foreach e of local errors {

		reghdfe `y' c.post_disc_before#c.T_HUC10_balanced`p'_`k' ///
					c.post_disc_after#c.T_HUC10_balanced`p'_`k' ///
					c.post_peak_before#c.T_HUC10_balanced`p'_`k' ///
					c.post_peak_after#c.T_HUC10_balanced`p'_`k' ///
					log_cum_prec_3days c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_feCha huc8_month_feCha)
			outreg2 using Tab3_`k'_horserace_full.xls, /// * location of the file
			keep(c.post_disc_before#c.T_HUC10_balanced`p'_`k' c.post_disc_after#c.T_HUC10_balanced`p'_`k' c.post_peak_before#c.T_HUC10_balanced`p'_`k' c.post_peak_after#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) replace ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
		reghdfe `y' c.post_disc_before#c.T_HUC10_balanced`p'_`k' ///
					c.post_disc_after#c.T_HUC10_balanced`p'_`k' ///
					c.post_peak_before#c.T_HUC10_balanced`p'_`k' ///
					c.post_peak_after#c.T_HUC10_balanced`p'_`k' /// 
					log_cum_prec_3days c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_feCha)
			outreg2 using Tab3_`k'_horserace_full.xls, /// * location of the file
			keep(c.post_disc_before#c.T_HUC10_balanced`p'_`k' c.post_disc_after#c.T_HUC10_balanced`p'_`k' c.post_peak_before#c.T_HUC10_balanced`p'_`k' c.post_peak_after#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display
			title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
			bracket bdec (4) sdec(4) append ///
			addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

	}
	}
	}
	
********************************************************************************
	// sub-sample regressions
	// horseracing with sub-samples by before/after peak
		* disclosure before google trend sample
		use "$datadir/Table3_ZS", clear
		* disclosure before peak sub-sample
		drop if disc_after_ggpeak == 1
		one_variable_regression post_disc 3 before
		one_variable_regression_all post_disc before
		two_variable_regression post_disc post_peak 3 before
		two_variable_regression_all post_disc post_peak before
		
		* disclosure after google trend sample
		use "$datadir/Table3_ZS", clear
		* disclosure after peak sub-sample
		drop if disc_before_ggpeak == 1
		one_variable_regression post_disc 3 after
		one_variable_regression_all post_disc after
		two_variable_regression post_disc post_peak 3 after
		two_variable_regression_all post_disc post_peak after






********************************************************************************
	// regressions with post_peak only
/*
local treatment 1
local errors ""cluster(huc10_state)""
local items 3 
local Ys ""log_t_t_Value_clean2""
local fe ""ID_geo_feN""
foreach y of local Ys {
foreach p of local treatment {
foreach k of local items {
foreach f of local fe {
foreach e of local errors {

	reghdfe `y' c.post_peak#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_fe huc8_month_fe)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_ggpeak.xls, /// * location of the file
		keep(c.post_peak#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) replace ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
	reghdfe `y' c.post_peak#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_fe)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_ggpeak.xls, /// * location of the file
		keep(c.post_peak#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display file 
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) append ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

}
}
}
}
}

// Stacked regression
// SUR
local errors ""cluster(huc10_state)""
local Ys ""log_t_t_Value_clean2""
local fe ""ID_geo_feNCha""
local k ALL
local p 1
foreach y of local Ys {
foreach f of local fe {
foreach e of local errors {

	reghdfe `y' c.post_peak#c.T_HUC10_balanced`p'_`k' c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_feCha huc8_month_feCha)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_ggpeak.xls, /// * location of the file
		keep(c.post_peak#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) replace ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
	reghdfe `y' c.post_peak#c.T_HUC10_balanced`p'_`k' c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_feCha)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_ggpeak.xls, /// * location of the file
		keep(c.post_peak#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) append ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

}
}
}

	// regressions with post_disc and post_peak
	
local treatment 1
local errors ""cluster(huc10_state)""
local items 3 
local Ys ""log_t_t_Value_clean2""
local fe ""ID_geo_feN""
foreach y of local Ys {
foreach p of local treatment {
foreach k of local items {
foreach f of local fe {
foreach e of local errors {

	reghdfe `y' c.post_disc#c.T_HUC10_balanced`p'_`k' c.post_peak#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_fe huc8_month_fe)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_ggpeakanddisc.xls, /// * location of the file
		keep(c.post_disc#c.T_HUC10_balanced`p'_`k' c.post_peak#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) replace ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
	reghdfe `y' c.post_disc#c.T_HUC10_balanced`p'_`k' c.post_peak#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_fe)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_ggpeakanddisc.xls, /// * location of the file
		keep(c.post_disc#c.T_HUC10_balanced`p'_`k' c.post_peak#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display file 
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) append ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

}
}
}
}
}

// Stacked regression
// SUR
local errors ""cluster(huc10_state)""
local Ys ""log_t_t_Value_clean2""
local fe ""ID_geo_feNCha""
local k ALL
local p 1
foreach y of local Ys {
foreach f of local fe {
foreach e of local errors {

	reghdfe `y' c.post_disc#c.T_HUC10_balanced`p'_`k' c.post_peak#c.T_HUC10_balanced`p'_`k' c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_feCha huc8_month_feCha)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_ggpeakanddisc.xls, /// * location of the file
		keep(c.post_disc#c.T_HUC10_balanced`p'_`k' c.post_peak#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) replace ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
	reghdfe `y' c.post_disc#c.T_HUC10_balanced`p'_`k' c.post_peak#c.T_HUC10_balanced`p'_`k' c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_feCha)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_ggpeakanddisc.xls, /// * location of the file
		keep(c.post_disc#c.T_HUC10_balanced`p'_`k' c.post_peak#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) append ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

}
}
}

	// regressions with earlier_date/later_date (whichever disclosure/search peak date comes earlier is used) only

foreach x in earlier_date later_date {
	
local treatment 1
local errors ""cluster(huc10_state)""
local items 3 
local Ys ""log_t_t_Value_clean2""
local fe ""ID_geo_feN""
foreach y of local Ys {
foreach p of local treatment {
foreach k of local items {
foreach f of local fe {
foreach e of local errors {

	reghdfe `y' c.`x'#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_fe huc8_month_fe)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_`x'.xls, /// * location of the file
		keep(c.`x'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) replace ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
	reghdfe `y' c.`x'#c.T_HUC10_balanced`p'_`k' log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_fe)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_`x'.xls, /// * location of the file
		keep(c.`x'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display file 
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) append ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

}
}
}
}
}

// Stacked regression
// SUR
local errors ""cluster(huc10_state)""
local Ys ""log_t_t_Value_clean2""
local fe ""ID_geo_feNCha""
local k ALL
local p 1
foreach y of local Ys {
foreach f of local fe {
foreach e of local errors {

	reghdfe `y' c.`x'#c.T_HUC10_balanced`p'_`k' c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1,  `e' absorb(`f' state_month_year_feCha huc8_month_feCha)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_`x'.xls, /// * location of the file
		keep(c.`x'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display 
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) replace ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, State*Month*Year FE, Yes, HUC8*Month FE, Yes)
	reghdfe `y' c.`x'#c.T_HUC10_balanced`p'_`k' c.log_cum_prec_3days#i.group_items i.T_mean_D_5_groups#i.group_items if  T_HUC10_only_post ==0 & Treated_state == 1 & m_cum_well_huc4_H_D == 1, `e' absorb(`f' huc8_year_month_feCha)
		outreg2 using Tab3_`y'_`k'_`p'_`e'`f'_pre_`x'.xls, /// * location of the file
		keep(c.`x'#c.T_HUC10_balanced`p'_`k') /// * Variables you want to display
		title ("ATE - `k' - `y'") ctitle("HF at least in Pre Disclosure period") ///
		bracket bdec (4) sdec(4) append ///
		addtext(Treated Sample, HUC10s with HF at least in pre, Control Sample, HUC10s with no HF in pre, Note, No HUC10 with HF only in post, Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

}
}
}

}
*/
