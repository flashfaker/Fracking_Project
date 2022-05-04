// cleaning Water quality data for PFAs
// This version: May 2022
global dropbox = "C:\Users\zsong98\Dropbox\Fracking Disclosure regulation project"
cd "$dropbox\1. data\data for Zirui"

**********
* PFA *
**********

import delimited "station.csv", clear 

drop if monitoringlocationidentifier ==""
g monitoring = monitoringlocationidentifier

g CharacteristicsName = "PFAS"

*keep monitoring CharacteristicsName latitudemeasure longitudemeasure

duplicates tag monitoring, gen(flag)
drop if flag == 1 // only 2 duplicates, errors
drop flag
isid monitoring

save "PFAS_station.dta", replace

// import data results file
clear
import delimited "resultphyschem.csv"

// merge w/ station file
g monitoring = monitoringlocationidentifier
drop if monitoring ==""
merge m:1 monitoring using "PFAS_station.dta"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             6
        from master                         0  (_merge==1)
        from using                          6  (_merge==2)

    Matched                         1,814,155  (_merge==3)
    -----------------------------------------
*/

drop if _merge == 2

save "PFAS_full.dta", replace

// Basic Cleaning - keep only water observations
keep if activitymedianame=="Water"
* (0 observations deleted)

// cleaning resultmeasurevalue
replace resultmeasurevalue ="" if resultmeasurevalue=="-"
*(0 real changes made)

g resultmeasurevalue_string = resultmeasurevalue

replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="## (Censored)"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="**"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="*ND LOD=0."
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="*ND LOD=0.010"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="*Non-detect"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="*Not Reported"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="*Present <QL"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="BDL"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="NA"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="ND"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="NO RESULTS FOUND IN BENCH BOOK FOR SAMPLE"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="NOT FOUND IN BENCH BOOK"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="Not Detected"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="QC FAIL"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="QC FAILED"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="QC Failed"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="RESULTS NOT FOUND IN BENCH BOOK"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="VALUE NOT RECORDED"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="nd"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="non detect"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="~115"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="~125"
replace resultmeasurevalue ="" 			if resultmeasurevalue_string=="~250"

replace resultmeasurevalue ="0.110" 	if resultmeasurevalue_string=="*0.110"
replace resultmeasurevalue ="0.145" 	if resultmeasurevalue_string=="*0.145"
replace resultmeasurevalue ="0.163" 	if resultmeasurevalue_string=="*0.163"
replace resultmeasurevalue ="0.171" 	if resultmeasurevalue_string=="*0.171"
replace resultmeasurevalue ="0.174" 	if resultmeasurevalue_string=="*0.174"
replace resultmeasurevalue ="0.182" 	if resultmeasurevalue_string=="*0.182"
replace resultmeasurevalue ="0.189" 	if resultmeasurevalue_string=="*0.189"
replace resultmeasurevalue ="0.191" 	if resultmeasurevalue_string=="*0.191"
replace resultmeasurevalue ="0.203" 	if resultmeasurevalue_string=="*0.203"
replace resultmeasurevalue ="0.210" 	if resultmeasurevalue_string=="*0.210"
replace resultmeasurevalue ="0.226" 	if resultmeasurevalue_string=="*0.226"
replace resultmeasurevalue ="0.233" 	if resultmeasurevalue_string=="*0.233"
replace resultmeasurevalue ="0.235" 	if resultmeasurevalue_string=="*0.235"
replace resultmeasurevalue ="0.238" 	if resultmeasurevalue_string=="*0.238"
replace resultmeasurevalue ="0.241" 	if resultmeasurevalue_string=="*0.241"
replace resultmeasurevalue ="0.242" 	if resultmeasurevalue_string=="*0.242"
replace resultmeasurevalue ="0.242" 	if resultmeasurevalue_string=="*0.242"
replace resultmeasurevalue ="0.25"  	if resultmeasurevalue_string=="*0.25"
replace resultmeasurevalue ="0.253" 	if resultmeasurevalue_string=="*0.253"
replace resultmeasurevalue ="0.253" 	if resultmeasurevalue_string=="*0.253"
replace resultmeasurevalue ="0.259" 	if resultmeasurevalue_string=="*0.259"
replace resultmeasurevalue ="0.269" 	if resultmeasurevalue_string=="*0.269"
replace resultmeasurevalue ="0.274" 	if resultmeasurevalue_string=="*0.274"
replace resultmeasurevalue ="0.277" 	if resultmeasurevalue_string=="*0.277"
replace resultmeasurevalue ="0.277" 	if resultmeasurevalue_string=="*0.277"
replace resultmeasurevalue ="0.286" 	if resultmeasurevalue_string=="*0.286"
replace resultmeasurevalue ="0.287" 	if resultmeasurevalue_string=="*0.287"
replace resultmeasurevalue ="0.288" 	if resultmeasurevalue_string=="*0.288"
replace resultmeasurevalue ="0.293" 	if resultmeasurevalue_string=="*0.293"
replace resultmeasurevalue ="0.306" 	if resultmeasurevalue_string=="*0.306"
replace resultmeasurevalue ="0.310" 	if resultmeasurevalue_string=="*0.310"
replace resultmeasurevalue ="0.314" 	if resultmeasurevalue_string=="*0.314"
replace resultmeasurevalue ="0.316" 	if resultmeasurevalue_string=="*0.316"
replace resultmeasurevalue ="0.318" 	if resultmeasurevalue_string=="*0.318"
replace resultmeasurevalue ="0.322" 	if resultmeasurevalue_string=="*0.322"
replace resultmeasurevalue ="0.324" 	if resultmeasurevalue_string=="*0.324"
replace resultmeasurevalue ="0.327" 	if resultmeasurevalue_string=="*0.327"
replace resultmeasurevalue ="0.334" 	if resultmeasurevalue_string=="*0.334"
replace resultmeasurevalue ="0.337" 	if resultmeasurevalue_string=="*0.337"
replace resultmeasurevalue ="0.338" 	if resultmeasurevalue_string=="*0.338"
replace resultmeasurevalue ="0.340" 	if resultmeasurevalue_string=="*0.340"
replace resultmeasurevalue ="0.340" 	if resultmeasurevalue_string=="*0.340"
replace resultmeasurevalue ="0.341" 	if resultmeasurevalue_string=="*0.341"
replace resultmeasurevalue ="0.351" 	if resultmeasurevalue_string=="*0.351"
replace resultmeasurevalue ="0.359" 	if resultmeasurevalue_string=="*0.359"
replace resultmeasurevalue ="0.419" 	if resultmeasurevalue_string=="*0.419"
replace resultmeasurevalue ="0.450" 	if resultmeasurevalue_string=="*0.450"
replace resultmeasurevalue ="0.452" 	if resultmeasurevalue_string=="*0.452"
replace resultmeasurevalue ="0.8"   	if resultmeasurevalue_string=="*0.8"
replace resultmeasurevalue ="0.849" 	if resultmeasurevalue_string=="*0.849"
replace resultmeasurevalue ="1.0"   	if resultmeasurevalue_string=="*1.0  "
replace resultmeasurevalue ="1.19"  	if resultmeasurevalue_string=="*1.19"
replace resultmeasurevalue ="1.32"  	if resultmeasurevalue_string=="*1.32"
replace resultmeasurevalue ="1.34"		if resultmeasurevalue_string=="*1.34"
replace resultmeasurevalue ="1.4"		if resultmeasurevalue_string=="*1.4"	
replace resultmeasurevalue ="1.4"		if resultmeasurevalue_string=="*1.4"	
replace resultmeasurevalue ="1.41"		if resultmeasurevalue_string=="*1.41"
replace resultmeasurevalue ="1.47"		if resultmeasurevalue_string=="*1.47"
replace resultmeasurevalue ="1.48"		if resultmeasurevalue_string=="*1.48"
replace resultmeasurevalue ="1.48"		if resultmeasurevalue_string=="*1.48"
replace resultmeasurevalue ="1.48"		if resultmeasurevalue_string=="*1.48"
replace resultmeasurevalue ="1.48"		if resultmeasurevalue_string=="*1.48"
replace resultmeasurevalue ="1.49"		if resultmeasurevalue_string=="*1.49"
replace resultmeasurevalue ="1.50"		if resultmeasurevalue_string=="*1.50"
replace resultmeasurevalue ="1.514" 	if resultmeasurevalue_string=="*1.514"
replace resultmeasurevalue ="1.522" 	if resultmeasurevalue_string=="*1.522"
replace resultmeasurevalue ="1.55"		if resultmeasurevalue_string=="*1.55 "
replace resultmeasurevalue ="1.56"		if resultmeasurevalue_string=="*1.56"
replace resultmeasurevalue ="1.57"		if resultmeasurevalue_string=="*1.57"
replace resultmeasurevalue ="1.59"		if resultmeasurevalue_string=="*1.59"
replace resultmeasurevalue ="1.591" 	if resultmeasurevalue_string=="*1.591"
replace resultmeasurevalue ="1.611" 	if resultmeasurevalue_string=="*1.611"
replace resultmeasurevalue ="1.626" 	if resultmeasurevalue_string=="*1.626"
replace resultmeasurevalue ="1.627" 	if resultmeasurevalue_string=="*1.627"
replace resultmeasurevalue ="1.63"  	if resultmeasurevalue_string=="*1.63"
replace resultmeasurevalue ="1.648" 	if resultmeasurevalue_string=="*1.648"
replace resultmeasurevalue ="1.656" 	if resultmeasurevalue_string=="*1.656"
replace resultmeasurevalue ="1.67"		if resultmeasurevalue_string=="*1.67"
replace resultmeasurevalue ="1.678" 	if resultmeasurevalue_string=="*1.678"
replace resultmeasurevalue ="1.69"		if resultmeasurevalue_string=="*1.69"
replace resultmeasurevalue ="1.71"		if resultmeasurevalue_string=="*1.71"
replace resultmeasurevalue ="1.72"		if resultmeasurevalue_string=="*1.72"
replace resultmeasurevalue ="1.74"		if resultmeasurevalue_string=="*1.74"
replace resultmeasurevalue ="1.74"		if resultmeasurevalue_string=="*1.74"
replace resultmeasurevalue ="1.81"		if resultmeasurevalue_string=="*1.81"
replace resultmeasurevalue ="1.90"  	if resultmeasurevalue_string=="*1.90"
replace resultmeasurevalue ="1.95"  	if resultmeasurevalue_string=="*1.95"
replace resultmeasurevalue ="1.96"  	if resultmeasurevalue_string=="*1.96"
replace resultmeasurevalue ="1.99"  	if resultmeasurevalue_string=="*1.99"
replace resultmeasurevalue ="10"		if resultmeasurevalue_string=="*10"	
replace resultmeasurevalue ="10.9"		if resultmeasurevalue_string=="*10.9"
replace resultmeasurevalue ="108.0"		if resultmeasurevalue_string=="*108."
replace resultmeasurevalue ="11.5"		if resultmeasurevalue_string=="*11.5"
replace resultmeasurevalue ="11.5"		if resultmeasurevalue_string=="*11.5"
replace resultmeasurevalue ="1160"		if resultmeasurevalue_string=="*1160"
replace resultmeasurevalue ="13.9"		if resultmeasurevalue_string=="*13.9"
replace resultmeasurevalue ="130.0"		if resultmeasurevalue_string=="*130."
replace resultmeasurevalue ="149"		if resultmeasurevalue_string=="*149"	
replace resultmeasurevalue ="17.4"		if resultmeasurevalue_string=="*17.4"
replace resultmeasurevalue ="179.0"		if resultmeasurevalue_string=="*179."
replace resultmeasurevalue ="18.4"  	if resultmeasurevalue_string=="*18.4"
replace resultmeasurevalue ="2.01"  	if resultmeasurevalue_string=="*2.01"
replace resultmeasurevalue ="2.07"  	if resultmeasurevalue_string=="*2.07"
replace resultmeasurevalue ="2.10"  	if resultmeasurevalue_string=="*2.10"
replace resultmeasurevalue ="2.12"  	if resultmeasurevalue_string=="*2.12"
replace resultmeasurevalue ="2.16"  	if resultmeasurevalue_string=="*2.16"
replace resultmeasurevalue ="2.57"   	if resultmeasurevalue_string=="*2.57"
replace resultmeasurevalue ="21.5"   	if resultmeasurevalue_string=="*21.5"
replace resultmeasurevalue ="214.0"  	if resultmeasurevalue_string=="*214."
replace resultmeasurevalue ="217.0"  	if resultmeasurevalue_string=="*217."
replace resultmeasurevalue ="22.0"   	if resultmeasurevalue_string=="*22.0"
replace resultmeasurevalue ="22.2"   	if resultmeasurevalue_string=="*22.2"
replace resultmeasurevalue ="223"    	if resultmeasurevalue_string=="*223"
replace resultmeasurevalue ="227.0"  	if resultmeasurevalue_string=="*227."
replace resultmeasurevalue ="23.2"   	if resultmeasurevalue_string=="*23.2"
replace resultmeasurevalue ="23.5"   	if resultmeasurevalue_string=="*23.5"
replace resultmeasurevalue ="231.0"  	if resultmeasurevalue_string=="*231."
replace resultmeasurevalue ="24.1"   	if resultmeasurevalue_string=="*24.1"
replace resultmeasurevalue ="24.5"	 	if resultmeasurevalue_string=="*24.5"
replace resultmeasurevalue ="24.9"	 	if resultmeasurevalue_string=="*24.9"
replace resultmeasurevalue ="25.3"	 	if resultmeasurevalue_string=="*25.3"
replace resultmeasurevalue ="25.6"	 	if resultmeasurevalue_string=="*25.6"
replace resultmeasurevalue ="25.7"	 	if resultmeasurevalue_string=="*25.7"
replace resultmeasurevalue ="26.1"	 	if resultmeasurevalue_string=="*26.1"
replace resultmeasurevalue ="27.8"	 	if resultmeasurevalue_string=="*27.8"
replace resultmeasurevalue ="3.5"	 	if resultmeasurevalue_string=="*3.5"	
replace resultmeasurevalue ="3.5"	 	if resultmeasurevalue_string=="*3.5"	
replace resultmeasurevalue ="3.5"	 	if resultmeasurevalue_string=="*3.5"	
replace resultmeasurevalue ="3.6"	 	if resultmeasurevalue_string=="*3.6"	
replace resultmeasurevalue ="3.6"	 	if resultmeasurevalue_string=="*3.6"	
replace resultmeasurevalue ="3.8"	 	if resultmeasurevalue_string=="*3.8"	
replace resultmeasurevalue ="30.8"	 	if resultmeasurevalue_string=="*30.8"
replace resultmeasurevalue ="312.0"  	if resultmeasurevalue_string=="*312."
replace resultmeasurevalue ="4.6"    	if resultmeasurevalue_string=="*4.6"
replace resultmeasurevalue ="4.6"    	if resultmeasurevalue_string=="*4.6"
replace resultmeasurevalue ="4.6"    	if resultmeasurevalue_string=="*4.6"
replace resultmeasurevalue ="4.7"    	if resultmeasurevalue_string=="*4.7"
replace resultmeasurevalue ="4.8"    	if resultmeasurevalue_string=="*4.8"
replace resultmeasurevalue ="40.0"   	if resultmeasurevalue_string=="*40.0"
replace resultmeasurevalue ="44.3"   	if resultmeasurevalue_string=="*44.3"
replace resultmeasurevalue ="46.5"   	if resultmeasurevalue_string=="*46.5"
replace resultmeasurevalue ="48.2"   	if resultmeasurevalue_string=="*48.2"
replace resultmeasurevalue ="49.3"   	if resultmeasurevalue_string=="*49.3"
replace resultmeasurevalue ="49.9"   	if resultmeasurevalue_string=="*49.9"
replace resultmeasurevalue ="5.1"    	if resultmeasurevalue_string=="*5.1"
replace resultmeasurevalue ="5.4"    	if resultmeasurevalue_string=="*5.4"
replace resultmeasurevalue ="5.5"    	if resultmeasurevalue_string=="*5.5"
replace resultmeasurevalue ="5.6"    	if resultmeasurevalue_string=="*5.6"
replace resultmeasurevalue ="5.6"    	if resultmeasurevalue_string=="*5.6"
replace resultmeasurevalue ="52.7"   	if resultmeasurevalue_string=="*52.7"
replace resultmeasurevalue ="54.1"   	if resultmeasurevalue_string=="*54.1"
replace resultmeasurevalue ="54.8"   	if resultmeasurevalue_string=="*54.8"
replace resultmeasurevalue ="55.4"   	if resultmeasurevalue_string=="*55.4"
replace resultmeasurevalue ="56.9"   	if resultmeasurevalue_string=="*56.9"
replace resultmeasurevalue ="6"      	if resultmeasurevalue_string=="*6"
replace resultmeasurevalue ="6.0"    	if resultmeasurevalue_string=="*6.0"
replace resultmeasurevalue ="6.4"    	if resultmeasurevalue_string=="*6.4"
replace resultmeasurevalue ="61.6"   	if resultmeasurevalue_string=="*61.6"
replace resultmeasurevalue ="64.3"	 	if resultmeasurevalue_string=="*64.3"
replace resultmeasurevalue ="65.1"	 	if resultmeasurevalue_string=="*65.1"
replace resultmeasurevalue ="66.7"	 	if resultmeasurevalue_string=="*66.7"
replace resultmeasurevalue ="67.0"	 	if resultmeasurevalue_string=="*67.0"
replace resultmeasurevalue ="70.1"	 	if resultmeasurevalue_string=="*70.1"
replace resultmeasurevalue ="70.3"	 	if resultmeasurevalue_string=="*70.3"
replace resultmeasurevalue ="74.6"	 	if resultmeasurevalue_string=="*74.6"
replace resultmeasurevalue ="78.1"	 	if resultmeasurevalue_string=="*78.1"
replace resultmeasurevalue ="81.0"	 	if resultmeasurevalue_string=="*81.0"
replace resultmeasurevalue ="833.0"	 	if resultmeasurevalue_string=="*833."
replace resultmeasurevalue ="855.0"	 	if resultmeasurevalue_string=="*855."
replace resultmeasurevalue ="86.8"	 	if resultmeasurevalue_string=="*86.8"

replace resultmeasurevalue ="3.3"	 	if resultmeasurevalue_string=="*<3.3"
replace resultmeasurevalue ="1.0"	 	if resultmeasurevalue_string=="*>1.0"

replace resultmeasurevalue ="0.0020" 	if resultmeasurevalue_string=="< 0.0020"
replace resultmeasurevalue ="0.03" 		if resultmeasurevalue_string=="< 0.03"
replace resultmeasurevalue ="0.05" 		if resultmeasurevalue_string=="< 0.05"
replace resultmeasurevalue ="0.20" 		if resultmeasurevalue_string=="< 0.20"
replace resultmeasurevalue ="0.4" 		if resultmeasurevalue_string=="< 0.4"
replace resultmeasurevalue ="0.5" 		if resultmeasurevalue_string=="< 0.5"
replace resultmeasurevalue ="0.50" 		if resultmeasurevalue_string=="< 0.50"
replace resultmeasurevalue ="100" 		if resultmeasurevalue_string=="< 100"
replace resultmeasurevalue ="2.0"		if resultmeasurevalue_string=="< 2.0"
replace resultmeasurevalue ="20" 		if resultmeasurevalue_string=="< 20"
replace resultmeasurevalue ="0.01"		if resultmeasurevalue_string=="<.01"
replace resultmeasurevalue ="0.1" 		if resultmeasurevalue_string=="<.1"
replace resultmeasurevalue ="0.00050" 	if resultmeasurevalue_string=="<0.00050"
replace resultmeasurevalue ="0.0020" 	if resultmeasurevalue_string=="<0.0020"
replace resultmeasurevalue ="0.01" 		if resultmeasurevalue_string=="<0.01"
replace resultmeasurevalue ="0.03" 		if resultmeasurevalue_string=="<0.03"
replace resultmeasurevalue ="0.05" 		if resultmeasurevalue_string=="<0.05"
replace resultmeasurevalue ="0.06" 		if resultmeasurevalue_string=="<0.06"
replace resultmeasurevalue ="0.08" 		if resultmeasurevalue_string=="<0.08"
replace resultmeasurevalue ="0.1" 		if resultmeasurevalue_string=="<0.1"
replace resultmeasurevalue ="0.10" 		if resultmeasurevalue_string=="<0.10"
replace resultmeasurevalue ="0.2" 		if resultmeasurevalue_string=="<0.2"
replace resultmeasurevalue ="0.20"		if resultmeasurevalue_string=="<0.20"
replace resultmeasurevalue ="0.200" 	if resultmeasurevalue_string=="<0.200"
replace resultmeasurevalue ="0.4" 		if resultmeasurevalue_string=="<0.4"
replace resultmeasurevalue ="0.5" 		if resultmeasurevalue_string=="<0.5"
replace resultmeasurevalue ="0.50" 		if resultmeasurevalue_string=="<0.50"
replace resultmeasurevalue ="1" 		if resultmeasurevalue_string=="<1"
replace resultmeasurevalue ="1.0" 		if resultmeasurevalue_string=="<1.0"
replace resultmeasurevalue ="1.1" 		if resultmeasurevalue_string=="<1.1"
replace resultmeasurevalue ="1.2" 		if resultmeasurevalue_string=="<1.2"
replace resultmeasurevalue ="10" 		if resultmeasurevalue_string=="<10"
replace resultmeasurevalue ="10.0" 		if resultmeasurevalue_string=="<10.0"
replace resultmeasurevalue ="100" 		if resultmeasurevalue_string=="<100"
replace resultmeasurevalue ="116" 		if resultmeasurevalue_string=="<116"
replace resultmeasurevalue ="118" 		if resultmeasurevalue_string=="<118"
replace resultmeasurevalue ="121" 		if resultmeasurevalue_string=="<121"
replace resultmeasurevalue ="128" 		if resultmeasurevalue_string=="<128"
replace resultmeasurevalue ="132" 		if resultmeasurevalue_string=="<132"
replace resultmeasurevalue ="150" 		if resultmeasurevalue_string=="<150"
replace resultmeasurevalue ="164" 		if resultmeasurevalue_string=="<164"
replace resultmeasurevalue ="2" 		if resultmeasurevalue_string=="<2"
replace resultmeasurevalue ="2.0" 		if resultmeasurevalue_string=="<2.0"
replace resultmeasurevalue ="2.00" 		if resultmeasurevalue_string=="<2.00"
replace resultmeasurevalue ="20.0" 		if resultmeasurevalue_string=="<20.0"
replace resultmeasurevalue ="4.0" 		if resultmeasurevalue_string=="<4.0"
replace resultmeasurevalue ="4.00" 		if resultmeasurevalue_string=="<4.00"
replace resultmeasurevalue ="40.0" 		if resultmeasurevalue_string=="<40.0"
replace resultmeasurevalue ="5" 		if resultmeasurevalue_string=="<5"
replace resultmeasurevalue ="5.00" 		if resultmeasurevalue_string=="<5.00"
replace resultmeasurevalue ="50.0" 		if resultmeasurevalue_string=="<50.0"
replace resultmeasurevalue ="740" 		if resultmeasurevalue_string=="<740"
replace resultmeasurevalue ="1" 		if resultmeasurevalue_string=="*1.0"
replace resultmeasurevalue ="1.55" 		if resultmeasurevalue_string=="*1.55"
replace resultmeasurevalue ="15" 		if resultmeasurevalue_string=="=15"
replace resultmeasurevalue ="6" 		if resultmeasurevalue_string=="=6"

destring resultmeasurevalue, replace force
* (232,386 missing values generated): thoese with a string-character component are dropped, but the original values are stored in "resultmeasurevalue_string"

replace resultmeasuremeasureunitcode = ustrrtrim(resultmeasuremeasureunitcode)
replace resultmeasuremeasureunitcode = strltrim(resultmeasuremeasureunitcode)
					
// Cleaning Date
drop analysisstartdate activityenddate analysisstartdate activityenddate constructiondatetext
g year = substr(activitystartdate, 1, 4)
g month = substr(activitystartdate, 6, 2)
g day = substr(activitystartdate, 9, 2)

replace month = "jan" if month == "01"
replace month = "feb" if month == "02"
replace month = "mar" if month == "03"
replace month = "apr" if month == "04"
replace month = "may" if month == "05"
replace month = "jun" if month == "06"
replace month = "jul" if month == "07"
replace month = "aug" if month == "08"
replace month = "sep" if month == "09"
replace month = "oct" if month == "10"
replace month = "nov" if month == "11"
replace month = "dec" if month == "12"
g datadate = day + month + year
g date = date(datadate, "DMY")
format date %d

// Drop Non-Relevant Variables
drop activityendtimetime activityendtimetimezonecode activitydepthheightmeasuremeasur ///
resultdepthaltitudereferencepoin resultdepthheightmeasuremeasurev resultdepthheightmeasuremeasureu sampletissueanatomyname ///
activitydepthaltitudereferencepo activitytopdepthheightmeasuremea activitybottomdepthheightmeasure activityconductingorganizationte resultlaboratorycommenttext laboratoryname

drop verticalmeasuremeasureunitcode verticalaccuracymeasuremeasureun welldepthmeasuremeasureunitcode wellholedepthmeasuremeasureunitc // monitoringlocationdescriptiontex
drop horizontalcollectionmethodname verticalcollectionmethodname aquifername formationtypetext aquifertypename

// 1st temp file
compress
save "temp_1.dta", replace

use "temp_1.dta", clear

drop characteristicname

replace resultmeasurevalue =0.18 if resultmeasurevalue_string=="*0.18"
replace resultmeasurevalue =0.227 if resultmeasurevalue_string=="*0.227"
replace resultmeasurevalue =0.251 if resultmeasurevalue_string=="*0.251"
replace resultmeasurevalue =0.26 if resultmeasurevalue_string=="*0.26"
replace resultmeasurevalue =0.278 if resultmeasurevalue_string=="*0.278"
replace resultmeasurevalue =0.28 if resultmeasurevalue_string=="*0.28"
replace resultmeasurevalue =0.298 if resultmeasurevalue_string=="*0.298"
replace resultmeasurevalue =0.33 if resultmeasurevalue_string=="*0.33"
replace resultmeasurevalue =0.387 if resultmeasurevalue_string=="*0.387"
replace resultmeasurevalue =103 if resultmeasurevalue_string=="*103."
replace resultmeasurevalue =103 if resultmeasurevalue_string=="*103."
replace resultmeasurevalue =116 if resultmeasurevalue_string=="*116."
replace resultmeasurevalue =12.0 if resultmeasurevalue_string=="*12.0"
replace resultmeasurevalue =131 if resultmeasurevalue_string=="*131."
replace resultmeasurevalue =131 if resultmeasurevalue_string=="*131."
replace resultmeasurevalue =132 if resultmeasurevalue_string=="*132."
replace resultmeasurevalue =133 if resultmeasurevalue_string=="*133."
replace resultmeasurevalue =134 if resultmeasurevalue_string=="*134."
replace resultmeasurevalue =136 if resultmeasurevalue_string=="*136."
replace resultmeasurevalue =138 if resultmeasurevalue_string=="*138."
replace resultmeasurevalue =141 if resultmeasurevalue_string=="*141."
replace resultmeasurevalue =1430 if resultmeasurevalue_string=="*1430."
replace resultmeasurevalue =16.2 if resultmeasurevalue_string=="*16.2"
replace resultmeasurevalue =170 if resultmeasurevalue_string=="*170."
replace resultmeasurevalue =1750 if resultmeasurevalue_string=="*1750."
replace resultmeasurevalue =182 if resultmeasurevalue_string=="*182"
replace resultmeasurevalue =188 if resultmeasurevalue_string=="*188."
replace resultmeasurevalue =198 if resultmeasurevalue_string=="*198."
replace resultmeasurevalue =20.1 if resultmeasurevalue_string=="*20.1"
replace resultmeasurevalue =229 if resultmeasurevalue_string=="*229."
replace resultmeasurevalue =232 if resultmeasurevalue_string=="*232."
replace resultmeasurevalue =245 if resultmeasurevalue_string=="*245"
replace resultmeasurevalue =262 if resultmeasurevalue_string=="*262."
replace resultmeasurevalue =272 if resultmeasurevalue_string=="*272."
replace resultmeasurevalue =275 if resultmeasurevalue_string=="*275."
replace resultmeasurevalue =30.6 if resultmeasurevalue_string=="*30.6"
replace resultmeasurevalue =31.6 if resultmeasurevalue_string=="*31.6"
replace resultmeasurevalue =335 if resultmeasurevalue_string=="*335."
replace resultmeasurevalue =34.2 if resultmeasurevalue_string=="*34.2"
replace resultmeasurevalue =35.5 if resultmeasurevalue_string=="*35.5"
replace resultmeasurevalue =352 if resultmeasurevalue_string=="*352"
replace resultmeasurevalue =424 if resultmeasurevalue_string=="*424."
replace resultmeasurevalue =424 if resultmeasurevalue_string=="*424."
replace resultmeasurevalue =426 if resultmeasurevalue_string=="*426."
replace resultmeasurevalue =44.8 if resultmeasurevalue_string=="*44.8"
replace resultmeasurevalue =546 if resultmeasurevalue_string=="*546."
replace resultmeasurevalue =6060 if resultmeasurevalue_string=="*6060."
replace resultmeasurevalue =62.4 if resultmeasurevalue_string=="*62.4"
replace resultmeasurevalue =6660 if resultmeasurevalue_string=="*6660."
replace resultmeasurevalue =68.9 if resultmeasurevalue_string=="*68.9"
replace resultmeasurevalue =76.4 if resultmeasurevalue_string=="*76.4"
replace resultmeasurevalue =799 if resultmeasurevalue_string=="*799."
replace resultmeasurevalue =82.7 if resultmeasurevalue_string=="*82.7"
replace resultmeasurevalue =839 if resultmeasurevalue_string=="*839."
replace resultmeasurevalue =84.9 if resultmeasurevalue_string=="*84.9"
replace resultmeasurevalue =90.7 if resultmeasurevalue_string=="*90.7"
replace resultmeasurevalue =95.9 if resultmeasurevalue_string=="*95.9"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="0..016"
replace resultmeasurevalue =0.08 if resultmeasurevalue_string=="0.0.8"
replace resultmeasurevalue =1000 if resultmeasurevalue_string=="1,000"
replace resultmeasurevalue =1138 if resultmeasurevalue_string=="1,138"
replace resultmeasurevalue =1225 if resultmeasurevalue_string=="1,225"
replace resultmeasurevalue =1313 if resultmeasurevalue_string=="1,313"
replace resultmeasurevalue =1525 if resultmeasurevalue_string=="1,525"
replace resultmeasurevalue =1593 if resultmeasurevalue_string=="1,593"
replace resultmeasurevalue =1638 if resultmeasurevalue_string=="1,638"
replace resultmeasurevalue =1650 if resultmeasurevalue_string=="1,650"
replace resultmeasurevalue =2225 if resultmeasurevalue_string=="2,225"
replace resultmeasurevalue =3000 if resultmeasurevalue_string=="3,000"
replace resultmeasurevalue =3325 if resultmeasurevalue_string=="3,325"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.016 if resultmeasurevalue_string=="<0.016"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =0.11 if resultmeasurevalue_string=="<0.11"
replace resultmeasurevalue =2.50 if resultmeasurevalue_string=="<2.50"
replace resultmeasurevalue =2.50 if resultmeasurevalue_string=="<2.50"
replace resultmeasurevalue =2.50 if resultmeasurevalue_string=="<2.50"

replace resultmeasurevalue =10 if resultmeasurevalue_string=="=10"
replace resultmeasurevalue =10 if resultmeasurevalue_string=="=10"
replace resultmeasurevalue =10.40 if resultmeasurevalue_string=="=10.40"
replace resultmeasurevalue =10.70 if resultmeasurevalue_string=="=10.70"
replace resultmeasurevalue =10.90 if resultmeasurevalue_string=="=10.90"
replace resultmeasurevalue =100 if resultmeasurevalue_string=="=100"
replace resultmeasurevalue =100 if resultmeasurevalue_string=="=100"
replace resultmeasurevalue =100 if resultmeasurevalue_string=="=100"
replace resultmeasurevalue =101 if resultmeasurevalue_string=="=101"
replace resultmeasurevalue =105 if resultmeasurevalue_string=="=105"
replace resultmeasurevalue =106 if resultmeasurevalue_string=="=106"
replace resultmeasurevalue =108 if resultmeasurevalue_string=="=108"
replace resultmeasurevalue =109 if resultmeasurevalue_string=="=109"
replace resultmeasurevalue =11 if resultmeasurevalue_string=="=11"
replace resultmeasurevalue =11.20 if resultmeasurevalue_string=="=11.20"
replace resultmeasurevalue =11.30 if resultmeasurevalue_string=="=11.30"
replace resultmeasurevalue =11.30 if resultmeasurevalue_string=="=11.30"
replace resultmeasurevalue =11.50 if resultmeasurevalue_string=="=11.50"
replace resultmeasurevalue =115 if resultmeasurevalue_string=="=115"
replace resultmeasurevalue =12 if resultmeasurevalue_string=="=12"
replace resultmeasurevalue =12 if resultmeasurevalue_string=="=12"
replace resultmeasurevalue =12 if resultmeasurevalue_string=="=12"
replace resultmeasurevalue =12 if resultmeasurevalue_string=="=12"
replace resultmeasurevalue =12 if resultmeasurevalue_string=="=12"
replace resultmeasurevalue =12.40 if resultmeasurevalue_string=="=12.40"
replace resultmeasurevalue =122 if resultmeasurevalue_string=="=122"
replace resultmeasurevalue =125 if resultmeasurevalue_string=="=125"
replace resultmeasurevalue =13 if resultmeasurevalue_string=="=13"
replace resultmeasurevalue =13 if resultmeasurevalue_string=="=13"
replace resultmeasurevalue =13 if resultmeasurevalue_string=="=13"
replace resultmeasurevalue =13 if resultmeasurevalue_string=="=13"
replace resultmeasurevalue =13.30 if resultmeasurevalue_string=="=13.30"
replace resultmeasurevalue =13.50 if resultmeasurevalue_string=="=13.50"
replace resultmeasurevalue =13.60 if resultmeasurevalue_string=="=13.60"
replace resultmeasurevalue =13.80 if resultmeasurevalue_string=="=13.80"
replace resultmeasurevalue =14 if resultmeasurevalue_string=="=14"
replace resultmeasurevalue =14 if resultmeasurevalue_string=="=14"
replace resultmeasurevalue =14.20 if resultmeasurevalue_string=="=14.20"
replace resultmeasurevalue =14.30 if resultmeasurevalue_string=="=14.30"
replace resultmeasurevalue =14.60 if resultmeasurevalue_string=="=14.60"
replace resultmeasurevalue =14.70 if resultmeasurevalue_string=="=14.70"
replace resultmeasurevalue =14.90 if resultmeasurevalue_string=="=14.90"
replace resultmeasurevalue =147 if resultmeasurevalue_string=="=147"
replace resultmeasurevalue =148 if resultmeasurevalue_string=="=148"
replace resultmeasurevalue =15.10 if resultmeasurevalue_string=="=15.10"
replace resultmeasurevalue =15.40 if resultmeasurevalue_string=="=15.40"
replace resultmeasurevalue =15.60 if resultmeasurevalue_string=="=15.60"
replace resultmeasurevalue =15.90 if resultmeasurevalue_string=="=15.90"
replace resultmeasurevalue =16 if resultmeasurevalue_string=="=16"
replace resultmeasurevalue =16 if resultmeasurevalue_string=="=16"
replace resultmeasurevalue =16.50 if resultmeasurevalue_string=="=16.50"
replace resultmeasurevalue =16.50 if resultmeasurevalue_string=="=16.50"
replace resultmeasurevalue =16.50 if resultmeasurevalue_string=="=16.50"
replace resultmeasurevalue =16.70 if resultmeasurevalue_string=="=16.70"
replace resultmeasurevalue =164 if resultmeasurevalue_string=="=164"
replace resultmeasurevalue =166 if resultmeasurevalue_string=="=166"
replace resultmeasurevalue =17 if resultmeasurevalue_string=="=17"
replace resultmeasurevalue =17 if resultmeasurevalue_string=="=17"
replace resultmeasurevalue =17 if resultmeasurevalue_string=="=17"
replace resultmeasurevalue =17.30 if resultmeasurevalue_string=="=17.30"
replace resultmeasurevalue =17.30 if resultmeasurevalue_string=="=17.30"
replace resultmeasurevalue =17.50 if resultmeasurevalue_string=="=17.50"
replace resultmeasurevalue =17.60 if resultmeasurevalue_string=="=17.60"
replace resultmeasurevalue =17.60 if resultmeasurevalue_string=="=17.60"
replace resultmeasurevalue =17.70 if resultmeasurevalue_string=="=17.70"
replace resultmeasurevalue =17.80 if resultmeasurevalue_string=="=17.80"
replace resultmeasurevalue =18 if resultmeasurevalue_string=="=18"
replace resultmeasurevalue =18.70 if resultmeasurevalue_string=="=18.70"
replace resultmeasurevalue =18.80 if resultmeasurevalue_string=="=18.80"
replace resultmeasurevalue =18.90 if resultmeasurevalue_string=="=18.90"
replace resultmeasurevalue =18.90 if resultmeasurevalue_string=="=18.90"
replace resultmeasurevalue =18.90 if resultmeasurevalue_string=="=18.90"
replace resultmeasurevalue =186 if resultmeasurevalue_string=="=186"
replace resultmeasurevalue =19 if resultmeasurevalue_string=="=19"
replace resultmeasurevalue =19 if resultmeasurevalue_string=="=19"
replace resultmeasurevalue =19.10 if resultmeasurevalue_string=="=19.10"
replace resultmeasurevalue =19.20 if resultmeasurevalue_string=="=19.20"
replace resultmeasurevalue =19.30 if resultmeasurevalue_string=="=19.30"
replace resultmeasurevalue =19.30 if resultmeasurevalue_string=="=19.30"
replace resultmeasurevalue =19.30 if resultmeasurevalue_string=="=19.30"
replace resultmeasurevalue =19.60 if resultmeasurevalue_string=="=19.60"
replace resultmeasurevalue =19.60 if resultmeasurevalue_string=="=19.60"
replace resultmeasurevalue =19.70 if resultmeasurevalue_string=="=19.70"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20 if resultmeasurevalue_string=="=20"
replace resultmeasurevalue =20.10 if resultmeasurevalue_string=="=20.10"
replace resultmeasurevalue =20.40 if resultmeasurevalue_string=="=20.40"
replace resultmeasurevalue =20.50 if resultmeasurevalue_string=="=20.50"
replace resultmeasurevalue =20.50 if resultmeasurevalue_string=="=20.50"
replace resultmeasurevalue =20.60 if resultmeasurevalue_string=="=20.60"
replace resultmeasurevalue =20.70 if resultmeasurevalue_string=="=20.70"
replace resultmeasurevalue =20.80 if resultmeasurevalue_string=="=20.80"
replace resultmeasurevalue =200 if resultmeasurevalue_string=="=200"
replace resultmeasurevalue =201 if resultmeasurevalue_string=="=201"
replace resultmeasurevalue =21 if resultmeasurevalue_string=="=21"
replace resultmeasurevalue =21 if resultmeasurevalue_string=="=21"
replace resultmeasurevalue =21 if resultmeasurevalue_string=="=21"
replace resultmeasurevalue =21.30 if resultmeasurevalue_string=="=21.30"
replace resultmeasurevalue =21.40 if resultmeasurevalue_string=="=21.40"
replace resultmeasurevalue =210 if resultmeasurevalue_string=="=210"
replace resultmeasurevalue =216 if resultmeasurevalue_string=="=216"
replace resultmeasurevalue =22.40 if resultmeasurevalue_string=="=22.40"
replace resultmeasurevalue =22.60 if resultmeasurevalue_string=="=22.60"
replace resultmeasurevalue =22.70 if resultmeasurevalue_string=="=22.70"
replace resultmeasurevalue =22.80 if resultmeasurevalue_string=="=22.80"
replace resultmeasurevalue =22.80 if resultmeasurevalue_string=="=22.80"
replace resultmeasurevalue =220 if resultmeasurevalue_string=="=220"
replace resultmeasurevalue =23 if resultmeasurevalue_string=="=23"
replace resultmeasurevalue =23.10 if resultmeasurevalue_string=="=23.10"
replace resultmeasurevalue =23.30 if resultmeasurevalue_string=="=23.30"
replace resultmeasurevalue =23.60 if resultmeasurevalue_string=="=23.60"
replace resultmeasurevalue =23.70 if resultmeasurevalue_string=="=23.70"
replace resultmeasurevalue =23.70 if resultmeasurevalue_string=="=23.70"
replace resultmeasurevalue =23.80 if resultmeasurevalue_string=="=23.80"
replace resultmeasurevalue =24.20 if resultmeasurevalue_string=="=24.20"
replace resultmeasurevalue =24.60 if resultmeasurevalue_string=="=24.60"
replace resultmeasurevalue =24.90 if resultmeasurevalue_string=="=24.90"
replace resultmeasurevalue =25.70 if resultmeasurevalue_string=="=25.70"
replace resultmeasurevalue =26 if resultmeasurevalue_string=="=26"
replace resultmeasurevalue =26.20 if resultmeasurevalue_string=="=26.20"
replace resultmeasurevalue =26.40 if resultmeasurevalue_string=="=26.40"
replace resultmeasurevalue =27.30 if resultmeasurevalue_string=="=27.30"
replace resultmeasurevalue =27.60 if resultmeasurevalue_string=="=27.60"
replace resultmeasurevalue =28.40 if resultmeasurevalue_string=="=28.40"
replace resultmeasurevalue =28.50 if resultmeasurevalue_string=="=28.50"
replace resultmeasurevalue =28.60 if resultmeasurevalue_string=="=28.60"
replace resultmeasurevalue =280 if resultmeasurevalue_string=="=280"
replace resultmeasurevalue =280 if resultmeasurevalue_string=="=280"
replace resultmeasurevalue =280 if resultmeasurevalue_string=="=280"
replace resultmeasurevalue =29.30 if resultmeasurevalue_string=="=29.30"
replace resultmeasurevalue =29.50 if resultmeasurevalue_string=="=29.50"
replace resultmeasurevalue =29.50 if resultmeasurevalue_string=="=29.50"
replace resultmeasurevalue =29.70 if resultmeasurevalue_string=="=29.70"
replace resultmeasurevalue =3 if resultmeasurevalue_string=="=3"
replace resultmeasurevalue =3 if resultmeasurevalue_string=="=3"
replace resultmeasurevalue =3 if resultmeasurevalue_string=="=3"
replace resultmeasurevalue =3.06 if resultmeasurevalue_string=="=3.06"
replace resultmeasurevalue =3.50 if resultmeasurevalue_string=="=3.50"
replace resultmeasurevalue =3.74 if resultmeasurevalue_string=="=3.74"
replace resultmeasurevalue =30.80 if resultmeasurevalue_string=="=30.80"
replace resultmeasurevalue =30.90 if resultmeasurevalue_string=="=30.90"
replace resultmeasurevalue =31.40 if resultmeasurevalue_string=="=31.40"
replace resultmeasurevalue =31.70 if resultmeasurevalue_string=="=31.70"
replace resultmeasurevalue =33.70 if resultmeasurevalue_string=="=33.70"
replace resultmeasurevalue =33.90 if resultmeasurevalue_string=="=33.90"
replace resultmeasurevalue =34.40 if resultmeasurevalue_string=="=34.40"
replace resultmeasurevalue =35.50 if resultmeasurevalue_string=="=35.50"
replace resultmeasurevalue =36.10 if resultmeasurevalue_string=="=36.10"
replace resultmeasurevalue =36.70 if resultmeasurevalue_string=="=36.70"
replace resultmeasurevalue =37 if resultmeasurevalue_string=="=37"
replace resultmeasurevalue =37 if resultmeasurevalue_string=="=37"
replace resultmeasurevalue =38.30 if resultmeasurevalue_string=="=38.30"
replace resultmeasurevalue =38.40 if resultmeasurevalue_string=="=38.40"
replace resultmeasurevalue =38.70 if resultmeasurevalue_string=="=38.70"
replace resultmeasurevalue =38.80 if resultmeasurevalue_string=="=38.80"
replace resultmeasurevalue =39.30 if resultmeasurevalue_string=="=39.30"
replace resultmeasurevalue =4 if resultmeasurevalue_string=="=4"
replace resultmeasurevalue =4 if resultmeasurevalue_string=="=4"
replace resultmeasurevalue =4.27 if resultmeasurevalue_string=="=4.27"
replace resultmeasurevalue =4.37 if resultmeasurevalue_string=="=4.37"
replace resultmeasurevalue =4.45 if resultmeasurevalue_string=="=4.45"
replace resultmeasurevalue =4.51 if resultmeasurevalue_string=="=4.51"
replace resultmeasurevalue =4.64 if resultmeasurevalue_string=="=4.64"
replace resultmeasurevalue =4.64 if resultmeasurevalue_string=="=4.64"
replace resultmeasurevalue =4.80 if resultmeasurevalue_string=="=4.80"
replace resultmeasurevalue =4.80 if resultmeasurevalue_string=="=4.80"
replace resultmeasurevalue =4.85 if resultmeasurevalue_string=="=4.85"
replace resultmeasurevalue =40.30 if resultmeasurevalue_string=="=40.30"
replace resultmeasurevalue =41.50 if resultmeasurevalue_string=="=41.50"
replace resultmeasurevalue =41.80 if resultmeasurevalue_string=="=41.80"
replace resultmeasurevalue =42 if resultmeasurevalue_string=="=42"
replace resultmeasurevalue =42.30 if resultmeasurevalue_string=="=42.30"
replace resultmeasurevalue =42.80 if resultmeasurevalue_string=="=42.80"
replace resultmeasurevalue =43.40 if resultmeasurevalue_string=="=43.40"
replace resultmeasurevalue =44 if resultmeasurevalue_string=="=44"
replace resultmeasurevalue =45.30 if resultmeasurevalue_string=="=45.30"
replace resultmeasurevalue =46.20 if resultmeasurevalue_string=="=46.20"
replace resultmeasurevalue =5.20 if resultmeasurevalue_string=="=5.20"
replace resultmeasurevalue =5.21 if resultmeasurevalue_string=="=5.21"
replace resultmeasurevalue =5.30 if resultmeasurevalue_string=="=5.30"
replace resultmeasurevalue =5.53 if resultmeasurevalue_string=="=5.53"
replace resultmeasurevalue =5.54 if resultmeasurevalue_string=="=5.54"
replace resultmeasurevalue =5.67 if resultmeasurevalue_string=="=5.67"
replace resultmeasurevalue =5.80 if resultmeasurevalue_string=="=5.80"
replace resultmeasurevalue =50 if resultmeasurevalue_string=="=50"
replace resultmeasurevalue =51.50 if resultmeasurevalue_string=="=51.50"
replace resultmeasurevalue =51.60 if resultmeasurevalue_string=="=51.60"
replace resultmeasurevalue =52.10 if resultmeasurevalue_string=="=52.10"
replace resultmeasurevalue =52.60 if resultmeasurevalue_string=="=52.60"
replace resultmeasurevalue =53.20 if resultmeasurevalue_string=="=53.20"
replace resultmeasurevalue =54.10 if resultmeasurevalue_string=="=54.10"
replace resultmeasurevalue =54.40 if resultmeasurevalue_string=="=54.40"
replace resultmeasurevalue =55 if resultmeasurevalue_string=="=55"
replace resultmeasurevalue =56.50 if resultmeasurevalue_string=="=56.50"
replace resultmeasurevalue =57.10 if resultmeasurevalue_string=="=57.10"
replace resultmeasurevalue =57.40 if resultmeasurevalue_string=="=57.40"
replace resultmeasurevalue =57.90 if resultmeasurevalue_string=="=57.90"
replace resultmeasurevalue =58 if resultmeasurevalue_string=="=58"
replace resultmeasurevalue =6.03 if resultmeasurevalue_string=="=6.03"
replace resultmeasurevalue =6.14 if resultmeasurevalue_string=="=6.14"
replace resultmeasurevalue =6.30 if resultmeasurevalue_string=="=6.30"
replace resultmeasurevalue =6.36 if resultmeasurevalue_string=="=6.36"
replace resultmeasurevalue =6.36 if resultmeasurevalue_string=="=6.36"
replace resultmeasurevalue =6.54 if resultmeasurevalue_string=="=6.54"
replace resultmeasurevalue =6.76 if resultmeasurevalue_string=="=6.76"
replace resultmeasurevalue =6.98 if resultmeasurevalue_string=="=6.98"
replace resultmeasurevalue =60.90 if resultmeasurevalue_string=="=60.90"
replace resultmeasurevalue =61.10 if resultmeasurevalue_string=="=61.10"
replace resultmeasurevalue =61.40 if resultmeasurevalue_string=="=61.40"
replace resultmeasurevalue =61.70 if resultmeasurevalue_string=="=61.70"
replace resultmeasurevalue =63.50 if resultmeasurevalue_string=="=63.50"
replace resultmeasurevalue =63.70 if resultmeasurevalue_string=="=63.70"
replace resultmeasurevalue =65.90 if resultmeasurevalue_string=="=65.90"
replace resultmeasurevalue =67.80 if resultmeasurevalue_string=="=67.80"
replace resultmeasurevalue =68.70 if resultmeasurevalue_string=="=68.70"
replace resultmeasurevalue =7 if resultmeasurevalue_string=="=7"
replace resultmeasurevalue =7 if resultmeasurevalue_string=="=7"
replace resultmeasurevalue =7.04 if resultmeasurevalue_string=="=7.04"
replace resultmeasurevalue =7.12 if resultmeasurevalue_string=="=7.12"
replace resultmeasurevalue =7.28 if resultmeasurevalue_string=="=7.28"
replace resultmeasurevalue =7.30 if resultmeasurevalue_string=="=7.30"
replace resultmeasurevalue =7.34 if resultmeasurevalue_string=="=7.34"
replace resultmeasurevalue =7.63 if resultmeasurevalue_string=="=7.63"
replace resultmeasurevalue =7.74 if resultmeasurevalue_string=="=7.74"
replace resultmeasurevalue =7.87 if resultmeasurevalue_string=="=7.87"
replace resultmeasurevalue =70 if resultmeasurevalue_string=="=70"
replace resultmeasurevalue =70 if resultmeasurevalue_string=="=70"
replace resultmeasurevalue =70 if resultmeasurevalue_string=="=70"
replace resultmeasurevalue =72.20 if resultmeasurevalue_string=="=72.20"
replace resultmeasurevalue =730 if resultmeasurevalue_string=="=730"
replace resultmeasurevalue =74.20 if resultmeasurevalue_string=="=74.20"
replace resultmeasurevalue =74.30 if resultmeasurevalue_string=="=74.30"
replace resultmeasurevalue =74.80 if resultmeasurevalue_string=="=74.80"
replace resultmeasurevalue =77 if resultmeasurevalue_string=="=77"
replace resultmeasurevalue =773 if resultmeasurevalue_string=="=773"
replace resultmeasurevalue =8 if resultmeasurevalue_string=="=8"
replace resultmeasurevalue =8 if resultmeasurevalue_string=="=8"
replace resultmeasurevalue =8.07 if resultmeasurevalue_string=="=8.07"
replace resultmeasurevalue =8.10 if resultmeasurevalue_string=="=8.10"
replace resultmeasurevalue =8.20 if resultmeasurevalue_string=="=8.20"
replace resultmeasurevalue =8.60 if resultmeasurevalue_string=="=8.60"
replace resultmeasurevalue =8.75 if resultmeasurevalue_string=="=8.75"
replace resultmeasurevalue =8.87 if resultmeasurevalue_string=="=8.87"
replace resultmeasurevalue =8.87 if resultmeasurevalue_string=="=8.87"
replace resultmeasurevalue =8.88 if resultmeasurevalue_string=="=8.88"
replace resultmeasurevalue =8.91 if resultmeasurevalue_string=="=8.91"
replace resultmeasurevalue =80 if resultmeasurevalue_string=="=80"
replace resultmeasurevalue =85.50 if resultmeasurevalue_string=="=85.50"
replace resultmeasurevalue =87.30 if resultmeasurevalue_string=="=87.30"
replace resultmeasurevalue =9 if resultmeasurevalue_string=="=9"
replace resultmeasurevalue =9.02 if resultmeasurevalue_string=="=9.02"
replace resultmeasurevalue =9.23 if resultmeasurevalue_string=="=9.23"
replace resultmeasurevalue =9.27 if resultmeasurevalue_string=="=9.27"
replace resultmeasurevalue =9.31 if resultmeasurevalue_string=="=9.31"
replace resultmeasurevalue =9.33 if resultmeasurevalue_string=="=9.33"
replace resultmeasurevalue =9.52 if resultmeasurevalue_string=="=9.52"
replace resultmeasurevalue =9.52 if resultmeasurevalue_string=="=9.52"
replace resultmeasurevalue =9.53 if resultmeasurevalue_string=="=9.53"
replace resultmeasurevalue =9.77 if resultmeasurevalue_string=="=9.77"
replace resultmeasurevalue =9.80 if resultmeasurevalue_string=="=9.80"
replace resultmeasurevalue =90 if resultmeasurevalue_string=="=90"
replace resultmeasurevalue =91.20 if resultmeasurevalue_string=="=91.20"
replace resultmeasurevalue =92.70 if resultmeasurevalue_string=="=92.70"
replace resultmeasurevalue =97.20 if resultmeasurevalue_string=="=97.20"
replace resultmeasurevalue =97.80 if resultmeasurevalue_string=="=97.80"
replace resultmeasurevalue =99.20 if resultmeasurevalue_string=="=99.20"
replace resultmeasurevalue =99.20 if resultmeasurevalue_string=="=99.20"

// Cleaning MonitoringLocationTypeName
rename monitoringlocationtypename  MonitoringLocationTypeName
g first_4 =substr(MonitoringLocationTypeName,1,6)

replace MonitoringLocationTypeName = "Surface Water - O" if MonitoringLocationTypeName=="Ocean"
replace MonitoringLocationTypeName = "Surface Water - O" if MonitoringLocationTypeName=="Ocean: Coastal"

replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Canal Drainage"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Canal Irrigation"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Canal Transport"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="River/Stream"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="River/Stream Ephemeral"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="River/Stream Intermittent"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="River/Stream Perennial"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="River/stream Effluent-Dominated"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Riverine Impoundment"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Stream"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Stream: Canal"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Stream: Ditch"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Stream: Tidal stream"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Channelized Stream"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Estuary" 

replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Estuarine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Estuarine-Scrub-Shrub"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Lacustrine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine-Forested"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine-Moss-Lichen"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine-Shrub-Scrub"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Riverine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Undifferentiated"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Constructed Wetland"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Lacustrine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine Pond"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Riverine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Undifferentiated"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Seep"

replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Great Lake"
replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Lake"
replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Lake, Reservoir, Impoundment"
replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Reservoir"
replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Pond-Stormwater"
replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Pond-Stock"

replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Collector or Ranney type well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Hyporheic-zone well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Test hole not completed as a well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Aggregate groundwater use"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Collector or Ranney type well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Hyporheic-zone well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Interconnected wells"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Multiple wells"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Test hole not completed as a well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Cave"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Groundwater drain"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Tunnel, shaft, or mine"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Unsaturated zone"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Industrial"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Municipal Sewage (POTW)"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Other"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Privately Owned Non-industrial"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Public Water Supply (PWS)"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Cistern"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Combined sewer"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Diversion"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Outfall"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Septic system"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Waste injection well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Wastewater land application"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Wastewater sewer"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Water-distribution system"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Water-use establishment"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Cave"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Other-Ground Water"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Borehole"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Pipe, Unspecified Source"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Spring"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Other-Ground Water"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Pipe, Unspecified Source"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Cave"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Groundwater drain"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Tunnel, shaft, or mine"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Aggregate groundwater use"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="CERCLA Superfund Site"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Industrial"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Municipal Sewage (POTW)"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Other"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Privately Owned Non-industrial"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Public Water Supply (PWS)"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Cistern"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Combined sewer"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Diversion"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Outfall"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Pavement"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Storm sewer"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Waste injection well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Wastewater land application"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Wastewater sewer"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Water-distribution system"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Water-use establishment"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Mine/Mine Discharge"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Mine/Mine Discharge Tailings Pile"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Mine/Mine Discharge Tailings Pile"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Mine/Mine Discharge Waste Rock Pile"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Constructed Tunnel"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Mine Pit"

replace MonitoringLocationTypeName = "Groundwater" if first_4=="Facili"
replace MonitoringLocationTypeName = "Groundwater" if first_4=="Mine/M"

replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="Atmosphere"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="BEACH Program Site-Estuary"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="BEACH Program Site-Lake"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="BEACH Program Site-Ocean"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="BEACH Program Site-River/Stream"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="Aggregate surface-water-use"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="Other-Surface Water"

replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land Flood Plain"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land Runoff"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land: Excavation"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land: Outcrop"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land: Shore"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land: Sinkhole"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land: Soil hole"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Landfill"

// Drop Water Body Sources that Cannot be Assigned to any of the Category
drop if MonitoringLocationTypeName=="Leachate-SamplePoint"
drop if MonitoringLocationTypeName=="Combined Sewer"
drop if MonitoringLocationTypeName=="Gallery"
drop if MonitoringLocationTypeName=="Leachate-Lysimeter"
drop if MonitoringLocationTypeName=="Spigot / Faucet"
drop if MonitoringLocationTypeName=="Waste Pit"
drop if MonitoringLocationTypeName=="Waste Sewer"
drop if MonitoringLocationTypeName=="Pond-Anchialine"
drop if MonitoringLocationTypeName=="Pond-Wastewater" 
drop if MonitoringLocationTypeName=="Storm Sewer" 
drop if MonitoringLocationTypeName=="Floodwater Urban" 
drop if MonitoringLocationTypeName=="Floodwater non-Urban"

bysort MonitoringLocationTypeName: tab activitymediasubdivisionname

replace MonitoringLocationTypeName = "Groundwater" if activitymediasubdivisionname=="Groundwater"
replace MonitoringLocationTypeName = "Groundwater" if activitymediasubdivisionname=="Ground Water"
replace MonitoringLocationTypeName = "Surface Water - W" if activitymediasubdivisionname=="Wet Fall Material"

drop if MonitoringLocationTypeName == "Surface Water - R" & activitymediasubdivisionname=="Industrial Effluent" 
drop if MonitoringLocationTypeName == "Surface Water - R" & activitymediasubdivisionname=="Industrial Waste" 
drop if MonitoringLocationTypeName == "Surface Water - R" & activitymediasubdivisionname=="Municipal Waste" 
drop if MonitoringLocationTypeName == "Surface Water - R" & activitymediasubdivisionname=="Wastewater Treatment Plant Effluent" 

bysort MonitoringLocationTypeName: tab activitymediasubdivisionname

replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="" // Checked that the replacement makes sense. Only relevant for state == 16 [Idaho], Additional information confirms it is surface-water

/*
tab samplecollectionmethodmethodname if MonitoringLocationTypeName ==""  // & Ch =="Chloride"
   SampleCollectionMethod/MethodName |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
       Automated Surface Water Sampling |      3,931       52.20       52.20
          Manual Surface Water Sampling |      3,600       47.80      100.00
----------------------------------------+-----------------------------------
                                  Total |      7,531      100.00
*/

// Cleaning Date and Monitoring Station ID
capture drop year month day
tostring date, generate(date_string) force usedisplayformat
g year = substr(date_string, 6, 4)  // no missing
g month = substr(date_string, 3, 3)  // no missing
g day = substr(date_string, 1, 2)  // no missing

tostring latitudemeasure, gen(lat_s) force
tostring longitudemeasure, gen(long_s) force
g ID_geo = lat_s + long_s // no missing
g state_county_ID = statecode + countycode  // 11,388 missing

// Generate a Flag Marking Observations with ResultDetectionConditionText!=""

	* rename resultdetectionconditiontext
	rename detectionquantitationlimittypena DQLM_M_Type_name // not used at the moment
	rename detectionquantitationlimitmeasur DQLM_M_Value // not used at the moment

rename resultdetectionconditiontext ResultDetectionConditionText
g ResultDetectionConditionText_D = 1 if ResultDetectionConditionText!=""
replace ResultDetectionConditionText_D = 0 if ResultDetectionConditionText_D ==.

// Cleaning ResultDetectionConditionText [variable used to create the three alternative measurement versions]
g ResultDetectionConditionText_ = ResultDetectionConditionText

// To "NA"
replace ResultDetectionConditionText_ = "NA" if ResultDetectionConditionText=="**"
replace ResultDetectionConditionText_ = "NA" if ResultDetectionConditionText=="*OS"
replace ResultDetectionConditionText_ = "NA" if ResultDetectionConditionText=="300(A)"
replace ResultDetectionConditionText_ = "NA" if ResultDetectionConditionText=="300(A)0"

			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="NA"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="RESULTS NOT FOUND IN BENCH BOOK"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="VALUE NOT RECORDED"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="0.0.8"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="300(A)"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="300(A)0"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="NO RESULTS FOUND IN BENCH BOOK FOR SAMPLE"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="NOT FOUND IN BENCH BOOK"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="QC FAIL"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="QC FAILED"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="QC Failed"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="## (Censored)"
			replace ResultDetectionConditionText_ = "NA" if resultmeasurevalue_string=="**"

// To "Detection Limit"
replace ResultDetectionConditionText_ = "0.286" if ResultDetectionConditionText=="*0.286"
replace ResultDetectionConditionText_ = "0.287" if ResultDetectionConditionText=="*0.287"
replace ResultDetectionConditionText_ = "0.340" if ResultDetectionConditionText=="*0.340"
replace ResultDetectionConditionText_ = "0.351" if ResultDetectionConditionText=="*0.351"
replace ResultDetectionConditionText_ = "103"   if ResultDetectionConditionText=="*103."
replace ResultDetectionConditionText_ = "11.5"  if ResultDetectionConditionText=="*11.5"
replace ResultDetectionConditionText_ = "116"   if ResultDetectionConditionText=="*116."
replace ResultDetectionConditionText_ = "12"    if ResultDetectionConditionText=="*12.0"
replace ResultDetectionConditionText_ = "131"   if ResultDetectionConditionText=="*131."
replace ResultDetectionConditionText_ = "132"   if ResultDetectionConditionText=="*132."
replace ResultDetectionConditionText_ = "133"   if ResultDetectionConditionText=="*133."
replace ResultDetectionConditionText_ = "134"   if ResultDetectionConditionText=="*134."
replace ResultDetectionConditionText_ = "136"   if ResultDetectionConditionText=="*136."
replace ResultDetectionConditionText_ = "138"   if ResultDetectionConditionText=="*138."
replace ResultDetectionConditionText_ = "141"   if ResultDetectionConditionText=="*141."
replace ResultDetectionConditionText_ = "1430"  if ResultDetectionConditionText=="*1430."
replace ResultDetectionConditionText_ = "16.2"  if ResultDetectionConditionText=="*16.2"
replace ResultDetectionConditionText_ = "170"   if ResultDetectionConditionText=="*170."
replace ResultDetectionConditionText_ = "1750"  if ResultDetectionConditionText=="*1750."
replace ResultDetectionConditionText_ = "182"   if ResultDetectionConditionText=="*182"
replace ResultDetectionConditionText_ = "188"   if ResultDetectionConditionText=="*188."
replace ResultDetectionConditionText_ = "198"   if ResultDetectionConditionText=="*198."
replace ResultDetectionConditionText_ = "20.1"  if ResultDetectionConditionText=="*20.1"
replace ResultDetectionConditionText_ = "21.5"  if ResultDetectionConditionText=="*21.5"
replace ResultDetectionConditionText_ = "229" 	if ResultDetectionConditionText=="*229."
replace ResultDetectionConditionText_ = "232" 	if ResultDetectionConditionText=="*232."
replace ResultDetectionConditionText_ = "245" 	if ResultDetectionConditionText=="*245"
replace ResultDetectionConditionText_ = "262" 	if ResultDetectionConditionText=="*262."
replace ResultDetectionConditionText_ = "272" 	if ResultDetectionConditionText=="*272."
replace ResultDetectionConditionText_ = "275" 	if ResultDetectionConditionText=="*275."
replace ResultDetectionConditionText_ = "3.5" 	if ResultDetectionConditionText=="*3.5"
replace ResultDetectionConditionText_ = "3.6" 	if ResultDetectionConditionText=="*3.6"
replace ResultDetectionConditionText_ = "3.8" 	if ResultDetectionConditionText=="*3.8"
replace ResultDetectionConditionText_ = "30.6"  if ResultDetectionConditionText=="*30.6"
replace ResultDetectionConditionText_ = "31.6"  if ResultDetectionConditionText=="*31.6"
replace ResultDetectionConditionText_ = "335"   if ResultDetectionConditionText=="*335."
replace ResultDetectionConditionText_ = "34.2"  if ResultDetectionConditionText=="*34.2"
replace ResultDetectionConditionText_ = "35.5"  if ResultDetectionConditionText=="*35.5"
replace ResultDetectionConditionText_ = "352" 	if ResultDetectionConditionText=="*352"
replace ResultDetectionConditionText_ = "4.6" 	if ResultDetectionConditionText=="*4.6"
replace ResultDetectionConditionText_ = "4.7" 	if ResultDetectionConditionText=="*4.7"
replace ResultDetectionConditionText_ = "40.0"  if ResultDetectionConditionText=="*40.0"
replace ResultDetectionConditionText_ = "424"   if ResultDetectionConditionText=="*424."
replace ResultDetectionConditionText_ = "426"   if ResultDetectionConditionText=="*426."
replace ResultDetectionConditionText_ = "44.8"  if ResultDetectionConditionText=="*44.8"
replace ResultDetectionConditionText_ = "5.1"   if ResultDetectionConditionText=="*5.1"
replace ResultDetectionConditionText_ = "5.4"   if ResultDetectionConditionText=="*5.4"
replace ResultDetectionConditionText_ = "5.5"   if ResultDetectionConditionText=="*5.5"
replace ResultDetectionConditionText_ = "5.6"   if ResultDetectionConditionText=="*5.6"
replace ResultDetectionConditionText_ = "546"   if ResultDetectionConditionText=="*546."
replace ResultDetectionConditionText_ = "6060"  if ResultDetectionConditionText=="*6060."
replace ResultDetectionConditionText_ = "62.4"  if ResultDetectionConditionText=="*62.4"
replace ResultDetectionConditionText_ = "6660"  if ResultDetectionConditionText=="*6660."
replace ResultDetectionConditionText_ = "68.9"  if ResultDetectionConditionText=="*68.9"
replace ResultDetectionConditionText_ = "76.4"  if ResultDetectionConditionText=="*76.4"
replace ResultDetectionConditionText_ = "799"   if ResultDetectionConditionText=="*799."
replace ResultDetectionConditionText_ = "82.7"  if ResultDetectionConditionText=="*82.7"
replace ResultDetectionConditionText_ = "839"   if ResultDetectionConditionText=="*839."
replace ResultDetectionConditionText_ = "84.9"  if ResultDetectionConditionText=="*84.9"
replace ResultDetectionConditionText_ = "90.7"  if ResultDetectionConditionText=="*90.7"
replace ResultDetectionConditionText_ = "95.9"  if ResultDetectionConditionText=="*95.9"
replace ResultDetectionConditionText_ = "0.4"   if ResultDetectionConditionText=="< 0.4"
replace ResultDetectionConditionText_ = "50"    if ResultDetectionConditionText=="< 50"
replace ResultDetectionConditionText_ = "0.01"  if ResultDetectionConditionText=="<.01"
replace ResultDetectionConditionText_ = "0.02"  if ResultDetectionConditionText=="<0.02"
replace ResultDetectionConditionText_ = "1"     if ResultDetectionConditionText=="<1.0"
replace ResultDetectionConditionText_ = "10"    if ResultDetectionConditionText=="<10"
replace ResultDetectionConditionText_ = "2"     if ResultDetectionConditionText=="<2.00"
replace ResultDetectionConditionText_ = "20"    if ResultDetectionConditionText=="<20.0"
replace ResultDetectionConditionText_ = "1000" 	if ResultDetectionConditionText=="1,000"
replace ResultDetectionConditionText_ = "1138" 	if ResultDetectionConditionText=="1,138"
replace ResultDetectionConditionText_ = "1225" 	if ResultDetectionConditionText=="1,225"
replace ResultDetectionConditionText_ = "1313" 	if ResultDetectionConditionText=="1,313"
replace ResultDetectionConditionText_ = "1525" 	if ResultDetectionConditionText=="1,525"
replace ResultDetectionConditionText_ = "1593" 	if ResultDetectionConditionText=="1,593"
replace ResultDetectionConditionText_ = "1638" 	if ResultDetectionConditionText=="1,638"
replace ResultDetectionConditionText_ = "2225" 	if ResultDetectionConditionText=="2,225"
replace ResultDetectionConditionText_ = "3000" 	if ResultDetectionConditionText=="3,000"
replace ResultDetectionConditionText_ = "3325" 	if ResultDetectionConditionText=="3,325"
replace ResultDetectionConditionText_ = "115"   if ResultDetectionConditionText=="~115"
replace ResultDetectionConditionText_ = "125"   if ResultDetectionConditionText=="~125"
replace ResultDetectionConditionText_ = "0.1"   if ResultDetectionConditionText=="<0.01"
replace ResultDetectionConditionText_ = "1650"  if ResultDetectionConditionText=="1,650"
replace ResultDetectionConditionText_ ="10"   	if ResultDetectionConditionText== "1.0E+001"
replace ResultDetectionConditionText_ ="11"   	if ResultDetectionConditionText== "1.1E+001"
replace ResultDetectionConditionText_ ="1100" 	if ResultDetectionConditionText== "1.1E+003"
replace ResultDetectionConditionText_ ="12"   	if ResultDetectionConditionText== "1.2E+001"
replace ResultDetectionConditionText_ ="120"  	if ResultDetectionConditionText== "1.2E+002"
replace ResultDetectionConditionText_ ="13"   	if ResultDetectionConditionText== "1.3E+001"
replace ResultDetectionConditionText_ ="14"   	if ResultDetectionConditionText== "1.4E+001"
replace ResultDetectionConditionText_ ="1400" 	if ResultDetectionConditionText== "1.4E+003"
replace ResultDetectionConditionText_ ="15"   	if ResultDetectionConditionText== "1.5E+001"
replace ResultDetectionConditionText_ ="16"   	if ResultDetectionConditionText=="1.6E+001"
replace ResultDetectionConditionText_ ="1600" 	if ResultDetectionConditionText=="1.6E+003"
replace ResultDetectionConditionText_ ="17"   	if ResultDetectionConditionText=="1.7E+001"
replace ResultDetectionConditionText_ ="18"   	if ResultDetectionConditionText=="1.8E+001"
replace ResultDetectionConditionText_ ="19"   	if ResultDetectionConditionText=="1.9E+001"
replace ResultDetectionConditionText_ ="20"   	if ResultDetectionConditionText=="2.0E+001"
replace ResultDetectionConditionText_ ="21"   	if ResultDetectionConditionText=="2.1E+001"
replace ResultDetectionConditionText_ ="22"   	if ResultDetectionConditionText=="2.2E+001"
replace ResultDetectionConditionText_ ="23"   	if ResultDetectionConditionText=="2.3E+001"
replace ResultDetectionConditionText_ ="24"   	if ResultDetectionConditionText== "2.4E+001"
replace ResultDetectionConditionText_ ="25"   	if ResultDetectionConditionText== "2.5E+001"
replace ResultDetectionConditionText_ ="26"   	if ResultDetectionConditionText== "2.6E+001"
replace ResultDetectionConditionText_ ="27"   	if ResultDetectionConditionText== "2.7E+001"
replace ResultDetectionConditionText_ ="28"   	if ResultDetectionConditionText== "2.8E+001"
replace ResultDetectionConditionText_ ="29"   	if ResultDetectionConditionText== "2.9E+001"
replace ResultDetectionConditionText_ ="30"   	if ResultDetectionConditionText== "3.0E+001"
replace ResultDetectionConditionText_ ="31"   	if ResultDetectionConditionText== "3.1E+001"
replace ResultDetectionConditionText_ ="3100" 	if ResultDetectionConditionText== "3.1E+003"
replace ResultDetectionConditionText_ ="32"   	if ResultDetectionConditionText=="3.2E+001"
replace ResultDetectionConditionText_ ="33"   	if ResultDetectionConditionText=="3.3E+001"
replace ResultDetectionConditionText_ ="34"   	if ResultDetectionConditionText=="3.4E+001"
replace ResultDetectionConditionText_ ="35"   	if ResultDetectionConditionText=="3.5E+001"
replace ResultDetectionConditionText_ ="36"   	if ResultDetectionConditionText=="3.6E+001"
replace ResultDetectionConditionText_ ="38"   	if ResultDetectionConditionText=="3.8E+001"
replace ResultDetectionConditionText_ ="39"   	if ResultDetectionConditionText=="3.9E+001"
replace ResultDetectionConditionText_ ="4.1"  	if ResultDetectionConditionText=="4.0999999999999996E+000"
replace ResultDetectionConditionText_ ="40"   	if ResultDetectionConditionText=="4.0E+001"
replace ResultDetectionConditionText_ ="41"   	if ResultDetectionConditionText=="4.1E+001"
replace ResultDetectionConditionText_ ="42"   	if ResultDetectionConditionText=="4.2E+001"
replace ResultDetectionConditionText_ ="43"   	if ResultDetectionConditionText=="4.3E+001"
replace ResultDetectionConditionText_ ="45"   	if ResultDetectionConditionText=="4.5E+001"
replace ResultDetectionConditionText_ ="47"   	if ResultDetectionConditionText=="4.7E+001"
replace ResultDetectionConditionText_ ="48"   	if ResultDetectionConditionText=="4.8E+001"
replace ResultDetectionConditionText_ ="49"   	if ResultDetectionConditionText=="4.9E+001"
replace ResultDetectionConditionText_ ="5"    	if ResultDetectionConditionText=="5.0E+000"
replace ResultDetectionConditionText_ ="50"   	if ResultDetectionConditionText=="5.0E+001"
replace ResultDetectionConditionText_ ="52"   	if ResultDetectionConditionText=="5.2E+001"
replace ResultDetectionConditionText_ ="53"   	if ResultDetectionConditionText=="5.3E+001"
replace ResultDetectionConditionText_ ="54"   	if ResultDetectionConditionText=="5.4E+001"
replace ResultDetectionConditionText_ ="58"   	if ResultDetectionConditionText=="5.8E+001"
replace ResultDetectionConditionText_ ="60"   	if ResultDetectionConditionText=="6.0E+001"
replace ResultDetectionConditionText_ ="600"  	if ResultDetectionConditionText=="6.0E+002"
replace ResultDetectionConditionText_ ="62"   	if ResultDetectionConditionText=="6.2E+001"
replace ResultDetectionConditionText_ ="63"   	if ResultDetectionConditionText=="6.3E+001"
replace ResultDetectionConditionText_ ="6.4"  	if ResultDetectionConditionText=="6.4000000000000004E+000"
replace ResultDetectionConditionText_ ="6.6"  	if ResultDetectionConditionText=="6.5999999999999996E+000"
replace ResultDetectionConditionText_ ="7"    	if ResultDetectionConditionText=="6.9000000000000004E+000"
replace ResultDetectionConditionText_ ="71"   	if ResultDetectionConditionText=="7.1E+001"
replace ResultDetectionConditionText_ ="73"   	if ResultDetectionConditionText=="7.3E+001"
replace ResultDetectionConditionText_ ="79"   	if ResultDetectionConditionText=="7.9E+001"
replace ResultDetectionConditionText_ ="8.2"  	if ResultDetectionConditionText=="8.1999999999999993E+000"
replace ResultDetectionConditionText_ ="8.5"  	if ResultDetectionConditionText=="8.5E+000"
replace ResultDetectionConditionText_ ="9.7"  	if ResultDetectionConditionText=="9.6999999999999993E+000"
replace ResultDetectionConditionText_ ="98"   	if ResultDetectionConditionText=="9.8E+001"

			replace ResultDetectionConditionText_="0.110" 	if resultmeasurevalue_string=="*0.110"
			replace ResultDetectionConditionText_="0.145" 	if resultmeasurevalue_string=="*0.145"
			replace ResultDetectionConditionText_="0.163" 	if resultmeasurevalue_string=="*0.163"
			replace ResultDetectionConditionText_="0.171" 	if resultmeasurevalue_string=="*0.171"
			replace ResultDetectionConditionText_="0.174" 	if resultmeasurevalue_string=="*0.174"
			replace ResultDetectionConditionText_="0.182" 	if resultmeasurevalue_string=="*0.182"
			replace ResultDetectionConditionText_="0.189" 	if resultmeasurevalue_string=="*0.189"
			replace ResultDetectionConditionText_="0.191" 	if resultmeasurevalue_string=="*0.191"
			replace ResultDetectionConditionText_="0.203" 	if resultmeasurevalue_string=="*0.203"
			replace ResultDetectionConditionText_="0.210" 	if resultmeasurevalue_string=="*0.210"
			replace ResultDetectionConditionText_="0.226" 	if resultmeasurevalue_string=="*0.226"
			replace ResultDetectionConditionText_="0.233" 	if resultmeasurevalue_string=="*0.233"
			replace ResultDetectionConditionText_="0.235" 	if resultmeasurevalue_string=="*0.235"
			replace ResultDetectionConditionText_="0.238" 	if resultmeasurevalue_string=="*0.238"
			replace ResultDetectionConditionText_="0.241" 	if resultmeasurevalue_string=="*0.241"
			replace ResultDetectionConditionText_="0.242" 	if resultmeasurevalue_string=="*0.242"
			replace ResultDetectionConditionText_="0.242" 	if resultmeasurevalue_string=="*0.242"
			replace ResultDetectionConditionText_="0.25"  	if resultmeasurevalue_string=="*0.25"
			replace ResultDetectionConditionText_="0.253" 	if resultmeasurevalue_string=="*0.253"
			replace ResultDetectionConditionText_="0.253" 	if resultmeasurevalue_string=="*0.253"
			replace ResultDetectionConditionText_="0.259" 	if resultmeasurevalue_string=="*0.259"
			replace ResultDetectionConditionText_="0.269" 	if resultmeasurevalue_string=="*0.269"
			replace ResultDetectionConditionText_="0.274" 	if resultmeasurevalue_string=="*0.274"
			replace ResultDetectionConditionText_="0.277" 	if resultmeasurevalue_string=="*0.277"
			replace ResultDetectionConditionText_="0.277" 	if resultmeasurevalue_string=="*0.277"
			replace ResultDetectionConditionText_="0.286" 	if resultmeasurevalue_string=="*0.286"
			replace ResultDetectionConditionText_="0.287" 	if resultmeasurevalue_string=="*0.287"
			replace ResultDetectionConditionText_="0.288" 	if resultmeasurevalue_string=="*0.288"
			replace ResultDetectionConditionText_="0.293" 	if resultmeasurevalue_string=="*0.293"
			replace ResultDetectionConditionText_="0.306" 	if resultmeasurevalue_string=="*0.306"
			replace ResultDetectionConditionText_="0.310" 	if resultmeasurevalue_string=="*0.310"
			replace ResultDetectionConditionText_="0.314" 	if resultmeasurevalue_string=="*0.314"
			replace ResultDetectionConditionText_="0.316" 	if resultmeasurevalue_string=="*0.316"
			replace ResultDetectionConditionText_="0.318" 	if resultmeasurevalue_string=="*0.318"
			replace ResultDetectionConditionText_="0.322" 	if resultmeasurevalue_string=="*0.322"
			replace ResultDetectionConditionText_="0.324" 	if resultmeasurevalue_string=="*0.324"
			replace ResultDetectionConditionText_="0.327" 	if resultmeasurevalue_string=="*0.327"
			replace ResultDetectionConditionText_="0.334" 	if resultmeasurevalue_string=="*0.334"
			replace ResultDetectionConditionText_="0.337" 	if resultmeasurevalue_string=="*0.337"
			replace ResultDetectionConditionText_="0.338" 	if resultmeasurevalue_string=="*0.338"
			replace ResultDetectionConditionText_="0.340" 	if resultmeasurevalue_string=="*0.340"
			replace ResultDetectionConditionText_="0.340" 	if resultmeasurevalue_string=="*0.340"
			replace ResultDetectionConditionText_="0.341" 	if resultmeasurevalue_string=="*0.341"
			replace ResultDetectionConditionText_="0.351" 	if resultmeasurevalue_string=="*0.351"
			replace ResultDetectionConditionText_="0.359" 	if resultmeasurevalue_string=="*0.359"
			replace ResultDetectionConditionText_="0.419" 	if resultmeasurevalue_string=="*0.419"
			replace ResultDetectionConditionText_="0.450" 	if resultmeasurevalue_string=="*0.450"
			replace ResultDetectionConditionText_="0.452" 	if resultmeasurevalue_string=="*0.452"
			replace ResultDetectionConditionText_="0.8"   	if resultmeasurevalue_string=="*0.8"
			replace ResultDetectionConditionText_="0.849" 	if resultmeasurevalue_string=="*0.849"
			replace ResultDetectionConditionText_="1.0"   	if resultmeasurevalue_string=="*1.0  "
			replace ResultDetectionConditionText_="1.19"  	if resultmeasurevalue_string=="*1.19"
			replace ResultDetectionConditionText_="1.32"  	if resultmeasurevalue_string=="*1.32"
			replace ResultDetectionConditionText_="1.34"	if resultmeasurevalue_string=="*1.34"
			replace ResultDetectionConditionText_="1.4"		if resultmeasurevalue_string=="*1.4"	
			replace ResultDetectionConditionText_="1.4"		if resultmeasurevalue_string=="*1.4"	
			replace ResultDetectionConditionText_="1.41"	if resultmeasurevalue_string=="*1.41"
			replace ResultDetectionConditionText_="1.47"	if resultmeasurevalue_string=="*1.47"
			replace ResultDetectionConditionText_="1.48"	if resultmeasurevalue_string=="*1.48"
			replace ResultDetectionConditionText_="1.48"	if resultmeasurevalue_string=="*1.48"
			replace ResultDetectionConditionText_="1.48"	if resultmeasurevalue_string=="*1.48"
			replace ResultDetectionConditionText_="1.48"	if resultmeasurevalue_string=="*1.48"
			replace ResultDetectionConditionText_="1.49"	if resultmeasurevalue_string=="*1.49"
			replace ResultDetectionConditionText_="1.50"	if resultmeasurevalue_string=="*1.50"
			replace ResultDetectionConditionText_="1.514" 	if resultmeasurevalue_string=="*1.514"
			replace ResultDetectionConditionText_="1.522" 	if resultmeasurevalue_string=="*1.522"
			replace ResultDetectionConditionText_="1.55"	if resultmeasurevalue_string=="*1.55 "
			replace ResultDetectionConditionText_="1.56"	if resultmeasurevalue_string=="*1.56"
			replace ResultDetectionConditionText_="1.57"	if resultmeasurevalue_string=="*1.57"
			replace ResultDetectionConditionText_="1.59"	if resultmeasurevalue_string=="*1.59"
			replace ResultDetectionConditionText_="1.591" 	if resultmeasurevalue_string=="*1.591"
			replace ResultDetectionConditionText_="1.611" 	if resultmeasurevalue_string=="*1.611"
			replace ResultDetectionConditionText_="1.626" 	if resultmeasurevalue_string=="*1.626"
			replace ResultDetectionConditionText_="1.627" 	if resultmeasurevalue_string=="*1.627"
			replace ResultDetectionConditionText_="1.63"  	if resultmeasurevalue_string=="*1.63"
			replace ResultDetectionConditionText_="1.648" 	if resultmeasurevalue_string=="*1.648"
			replace ResultDetectionConditionText_="1.656" 	if resultmeasurevalue_string=="*1.656"
			replace ResultDetectionConditionText_="1.67"	if resultmeasurevalue_string=="*1.67"
			replace ResultDetectionConditionText_="1.678" 	if resultmeasurevalue_string=="*1.678"
			replace ResultDetectionConditionText_="1.69"	if resultmeasurevalue_string=="*1.69"
			replace ResultDetectionConditionText_="1.71"	if resultmeasurevalue_string=="*1.71"
			replace ResultDetectionConditionText_="1.72"	if resultmeasurevalue_string=="*1.72"
			replace ResultDetectionConditionText_="1.74"	if resultmeasurevalue_string=="*1.74"
			replace ResultDetectionConditionText_="1.74"	if resultmeasurevalue_string=="*1.74"
			replace ResultDetectionConditionText_="1.81"	if resultmeasurevalue_string=="*1.81"
			replace ResultDetectionConditionText_="1.90"  	if resultmeasurevalue_string=="*1.90"
			replace ResultDetectionConditionText_="1.95"  	if resultmeasurevalue_string=="*1.95"
			replace ResultDetectionConditionText_="1.96"  	if resultmeasurevalue_string=="*1.96"
			replace ResultDetectionConditionText_="1.99"  	if resultmeasurevalue_string=="*1.99"
			replace ResultDetectionConditionText_="10"		if resultmeasurevalue_string=="*10"	
			replace ResultDetectionConditionText_="10.9"	if resultmeasurevalue_string=="*10.9"
			replace ResultDetectionConditionText_="108.0"	if resultmeasurevalue_string=="*108."
			replace ResultDetectionConditionText_="11.5"	if resultmeasurevalue_string=="*11.5"
			replace ResultDetectionConditionText_="11.5"	if resultmeasurevalue_string=="*11.5"
			replace ResultDetectionConditionText_="1160"	if resultmeasurevalue_string=="*1160"
			replace ResultDetectionConditionText_="13.9"	if resultmeasurevalue_string=="*13.9"
			replace ResultDetectionConditionText_="130.0"	if resultmeasurevalue_string=="*130."
			replace ResultDetectionConditionText_="149"		if resultmeasurevalue_string=="*149"	
			replace ResultDetectionConditionText_="17.4"	if resultmeasurevalue_string=="*17.4"
			replace ResultDetectionConditionText_="179.0"	if resultmeasurevalue_string=="*179."
			replace ResultDetectionConditionText_="18.4"  	if resultmeasurevalue_string=="*18.4"
			replace ResultDetectionConditionText_="2.01"  	if resultmeasurevalue_string=="*2.01"
			replace ResultDetectionConditionText_="2.07"  	if resultmeasurevalue_string=="*2.07"
			replace ResultDetectionConditionText_="2.10"  	if resultmeasurevalue_string=="*2.10"
			replace ResultDetectionConditionText_="2.12"  	if resultmeasurevalue_string=="*2.12"
			replace ResultDetectionConditionText_="2.16"  	if resultmeasurevalue_string=="*2.16"
			replace ResultDetectionConditionText_="2.57"   	if resultmeasurevalue_string=="*2.57"
			replace ResultDetectionConditionText_="21.5"   	if resultmeasurevalue_string=="*21.5"
			replace ResultDetectionConditionText_="214.0"  	if resultmeasurevalue_string=="*214."
			replace ResultDetectionConditionText_="217.0"  	if resultmeasurevalue_string=="*217."
			replace ResultDetectionConditionText_="22.0"   	if resultmeasurevalue_string=="*22.0"
			replace ResultDetectionConditionText_="22.2"   	if resultmeasurevalue_string=="*22.2"
			replace ResultDetectionConditionText_="223"    	if resultmeasurevalue_string=="*223"
			replace ResultDetectionConditionText_="227.0"  	if resultmeasurevalue_string=="*227."
			replace ResultDetectionConditionText_="23.2"   	if resultmeasurevalue_string=="*23.2"
			replace ResultDetectionConditionText_="23.5"   	if resultmeasurevalue_string=="*23.5"
			replace ResultDetectionConditionText_="231.0"  	if resultmeasurevalue_string=="*231."
			replace ResultDetectionConditionText_="24.1"   	if resultmeasurevalue_string=="*24.1"
			replace ResultDetectionConditionText_="24.5"	if resultmeasurevalue_string=="*24.5"
			replace ResultDetectionConditionText_="24.9"	if resultmeasurevalue_string=="*24.9"
			replace ResultDetectionConditionText_="25.3"	if resultmeasurevalue_string=="*25.3"
			replace ResultDetectionConditionText_="25.6"	if resultmeasurevalue_string=="*25.6"
			replace ResultDetectionConditionText_="25.7"	if resultmeasurevalue_string=="*25.7"
			replace ResultDetectionConditionText_="26.1"	if resultmeasurevalue_string=="*26.1"
			replace ResultDetectionConditionText_="27.8"	if resultmeasurevalue_string=="*27.8"
			replace ResultDetectionConditionText_="3.5"	 	if resultmeasurevalue_string=="*3.5"	
			replace ResultDetectionConditionText_="3.5"	 	if resultmeasurevalue_string=="*3.5"	
			replace ResultDetectionConditionText_="3.5"	 	if resultmeasurevalue_string=="*3.5"	
			replace ResultDetectionConditionText_="3.6"	 	if resultmeasurevalue_string=="*3.6"	
			replace ResultDetectionConditionText_="3.6"	 	if resultmeasurevalue_string=="*3.6"	
			replace ResultDetectionConditionText_="3.8"	 	if resultmeasurevalue_string=="*3.8"	
			replace ResultDetectionConditionText_="30.8"	if resultmeasurevalue_string=="*30.8"
			replace ResultDetectionConditionText_="312.0"  	if resultmeasurevalue_string=="*312."
			replace ResultDetectionConditionText_="4.6"    	if resultmeasurevalue_string=="*4.6"
			replace ResultDetectionConditionText_="4.6"    	if resultmeasurevalue_string=="*4.6"
			replace ResultDetectionConditionText_="4.6"    	if resultmeasurevalue_string=="*4.6"
			replace ResultDetectionConditionText_="4.7"    	if resultmeasurevalue_string=="*4.7"
			replace ResultDetectionConditionText_="4.8"    	if resultmeasurevalue_string=="*4.8"
			replace ResultDetectionConditionText_="40.0"   	if resultmeasurevalue_string=="*40.0"
			replace ResultDetectionConditionText_="44.3"   	if resultmeasurevalue_string=="*44.3"
			replace ResultDetectionConditionText_="46.5"   	if resultmeasurevalue_string=="*46.5"
			replace ResultDetectionConditionText_="48.2"   	if resultmeasurevalue_string=="*48.2"
			replace ResultDetectionConditionText_="49.3"   	if resultmeasurevalue_string=="*49.3"
			replace ResultDetectionConditionText_="49.9"   	if resultmeasurevalue_string=="*49.9"
			replace ResultDetectionConditionText_="5.1"    	if resultmeasurevalue_string=="*5.1"
			replace ResultDetectionConditionText_="5.4"    	if resultmeasurevalue_string=="*5.4"
			replace ResultDetectionConditionText_="5.5"    	if resultmeasurevalue_string=="*5.5"
			replace ResultDetectionConditionText_="5.6"    	if resultmeasurevalue_string=="*5.6"
			replace ResultDetectionConditionText_="5.6"    	if resultmeasurevalue_string=="*5.6"
			replace ResultDetectionConditionText_="52.7"   	if resultmeasurevalue_string=="*52.7"
			replace ResultDetectionConditionText_="54.1"   	if resultmeasurevalue_string=="*54.1"
			replace ResultDetectionConditionText_="54.8"   	if resultmeasurevalue_string=="*54.8"
			replace ResultDetectionConditionText_="55.4"   	if resultmeasurevalue_string=="*55.4"
			replace ResultDetectionConditionText_="56.9"   	if resultmeasurevalue_string=="*56.9"
			replace ResultDetectionConditionText_="6"      	if resultmeasurevalue_string=="*6"
			replace ResultDetectionConditionText_="6.0"    	if resultmeasurevalue_string=="*6.0"
			replace ResultDetectionConditionText_="6.4"    	if resultmeasurevalue_string=="*6.4"
			replace ResultDetectionConditionText_="61.6"   	if resultmeasurevalue_string=="*61.6"
			replace ResultDetectionConditionText_="64.3"	if resultmeasurevalue_string=="*64.3"
			replace ResultDetectionConditionText_="65.1"	if resultmeasurevalue_string=="*65.1"
			replace ResultDetectionConditionText_="66.7"	if resultmeasurevalue_string=="*66.7"
			replace ResultDetectionConditionText_="67.0"	if resultmeasurevalue_string=="*67.0"
			replace ResultDetectionConditionText_="70.1"	if resultmeasurevalue_string=="*70.1"
			replace ResultDetectionConditionText_="70.3"	if resultmeasurevalue_string=="*70.3"
			replace ResultDetectionConditionText_="74.6"	if resultmeasurevalue_string=="*74.6"
			replace ResultDetectionConditionText_="78.1"	if resultmeasurevalue_string=="*78.1"
			replace ResultDetectionConditionText_="81.0"	if resultmeasurevalue_string=="*81.0"
			replace ResultDetectionConditionText_="833.0"	if resultmeasurevalue_string=="*833."
			replace ResultDetectionConditionText_="855.0"	if resultmeasurevalue_string=="*855."
			replace ResultDetectionConditionText_="86.8"	if resultmeasurevalue_string=="*86.8"
			replace ResultDetectionConditionText_="3.3"	 	if resultmeasurevalue_string=="*<3.3"
			replace ResultDetectionConditionText_="1.0"	 	if resultmeasurevalue_string=="*>1.0"
			replace ResultDetectionConditionText_="0.0020"  if resultmeasurevalue_string=="< 0.0020"
			replace ResultDetectionConditionText_="0.03"    if resultmeasurevalue_string=="< 0.03"
			replace ResultDetectionConditionText_="0.05"    if resultmeasurevalue_string=="< 0.05"
			replace ResultDetectionConditionText_="0.20"    if resultmeasurevalue_string=="< 0.20"
			replace ResultDetectionConditionText_="0.4"     if resultmeasurevalue_string=="< 0.4"
			replace ResultDetectionConditionText_="0.5"     if resultmeasurevalue_string=="< 0.5"
			replace ResultDetectionConditionText_="0.50"    if resultmeasurevalue_string=="< 0.50"
			replace ResultDetectionConditionText_="100"     if resultmeasurevalue_string=="< 100"
			replace ResultDetectionConditionText_="2.0"     if resultmeasurevalue_string=="< 2.0"
			replace ResultDetectionConditionText_="20"      if resultmeasurevalue_string=="< 20"
			replace ResultDetectionConditionText_="0.01"    if resultmeasurevalue_string=="<.01"
			replace ResultDetectionConditionText_="0.1"     if resultmeasurevalue_string=="<.1"
			replace ResultDetectionConditionText_="0.00050" if resultmeasurevalue_string=="<0.00050"
			replace ResultDetectionConditionText_="0.0020"  if resultmeasurevalue_string=="<0.0020"
			replace ResultDetectionConditionText_="0.01" 	if resultmeasurevalue_string=="<0.01"
			replace ResultDetectionConditionText_="0.03" 	if resultmeasurevalue_string=="<0.03"
			replace ResultDetectionConditionText_="0.05" 	if resultmeasurevalue_string=="<0.05"
			replace ResultDetectionConditionText_="0.06" 	if resultmeasurevalue_string=="<0.06"
			replace ResultDetectionConditionText_="0.08" 	if resultmeasurevalue_string=="<0.08"
			replace ResultDetectionConditionText_="0.1"     if resultmeasurevalue_string=="<0.1"
			replace ResultDetectionConditionText_="0.10"    if resultmeasurevalue_string=="<0.10"
			replace ResultDetectionConditionText_="0.2"     if resultmeasurevalue_string=="<0.2"
			replace ResultDetectionConditionText_="0.20"    if resultmeasurevalue_string=="<0.20"
			replace ResultDetectionConditionText_="0.200"   if resultmeasurevalue_string=="<0.200"
			replace ResultDetectionConditionText_="0.4"     if resultmeasurevalue_string=="<0.4"
			replace ResultDetectionConditionText_="0.5"     if resultmeasurevalue_string=="<0.5"
			replace ResultDetectionConditionText_="0.50"    if resultmeasurevalue_string=="<0.50"
			replace ResultDetectionConditionText_="1"       if resultmeasurevalue_string=="<1"
			replace ResultDetectionConditionText_="1.0" 	if resultmeasurevalue_string=="<1.0"
			replace ResultDetectionConditionText_="1.1" 	if resultmeasurevalue_string=="<1.1"
			replace ResultDetectionConditionText_="1.2" 	if resultmeasurevalue_string=="<1.2"
			replace ResultDetectionConditionText_="10"      if resultmeasurevalue_string=="<10"
			replace ResultDetectionConditionText_="10.0"    if resultmeasurevalue_string=="<10.0"
			replace ResultDetectionConditionText_="100" 	if resultmeasurevalue_string=="<100"
			replace ResultDetectionConditionText_="116" 	if resultmeasurevalue_string=="<116"
			replace ResultDetectionConditionText_="118" 	if resultmeasurevalue_string=="<118"
			replace ResultDetectionConditionText_="121" 	if resultmeasurevalue_string=="<121"
			replace ResultDetectionConditionText_="128" 	if resultmeasurevalue_string=="<128"
			replace ResultDetectionConditionText_="132" 	if resultmeasurevalue_string=="<132"
			replace ResultDetectionConditionText_="150" 	if resultmeasurevalue_string=="<150"
			replace ResultDetectionConditionText_="164" 	if resultmeasurevalue_string=="<164"
			replace ResultDetectionConditionText_="2"       if resultmeasurevalue_string=="<2"
			replace ResultDetectionConditionText_="2.0"     if resultmeasurevalue_string=="<2.0"
			replace ResultDetectionConditionText_="2.00"    if resultmeasurevalue_string=="<2.00"
			replace ResultDetectionConditionText_="20.0"    if resultmeasurevalue_string=="<20.0"
			replace ResultDetectionConditionText_="4.0"     if resultmeasurevalue_string=="<4.0"
			replace ResultDetectionConditionText_="4.00"    if resultmeasurevalue_string=="<4.00"
			replace ResultDetectionConditionText_="40.0"    if resultmeasurevalue_string=="<40.0"
			replace ResultDetectionConditionText_="5"       if resultmeasurevalue_string=="<5"
			replace ResultDetectionConditionText_="5.00"    if resultmeasurevalue_string=="<5.00"
			replace ResultDetectionConditionText_="50.0"    if resultmeasurevalue_string=="<50.0"
			replace ResultDetectionConditionText_="740"     if resultmeasurevalue_string=="<740"
			replace ResultDetectionConditionText_="1"       if resultmeasurevalue_string=="*1.0"
			replace ResultDetectionConditionText_="1.55"    if resultmeasurevalue_string=="*1.55"
			replace ResultDetectionConditionText_="15"      if resultmeasurevalue_string=="=15"
			replace ResultDetectionConditionText_="6"       if resultmeasurevalue_string=="=6"

// To "Non-Detected"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="Not Detected"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="ND"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*NOT DETECTED  "
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Non-detect"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Non-detect    "
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Not Detected"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Not Detected  "
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Not detected  "
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="non detect"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*NON-DETECT"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*NOT DETECTED"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Non-detect."
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Not detected"

			replace ResultDetectionConditionText_ = "Not Detected" if resultmeasurevalue_string=="ND"
			replace ResultDetectionConditionText_ = "Not Detected" if resultmeasurevalue_string=="*ND LOD=0.010"
			replace ResultDetectionConditionText_ = "Not Detected" if resultmeasurevalue_string=="*Non-detect"
			replace ResultDetectionConditionText_ = "Not Detected" if resultmeasurevalue_string=="non detect"
			replace ResultDetectionConditionText_ = "Not Detected" if resultmeasurevalue_string=="Not Detected"
			replace ResultDetectionConditionText_ = "Not Detected" if resultmeasurevalue_string=="nd"
			replace ResultDetectionConditionText_ = "Not Detected" if resultmeasurevalue_string=="*Not Detected"

// To "Present Above Quantification Limit"
replace ResultDetectionConditionText_ = "Present Above Quantification Limit" if ResultDetectionConditionText=="Present Above Quantification Limit"
replace ResultDetectionConditionText_ = "Present Above Quantification Limit" if ResultDetectionConditionText=="*Present >QL"

// To "Present Below Quantification Limit"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="Present Below Quantification Limit"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="*Present"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="*Present <QL"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="*Present <QL   "
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="BDL"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="*Present <QL."

replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="Below Detection Limit"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="Below Method Detection Limit"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="Below Reporting Limit"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="Below Sample-specific Detect Limit"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="Between Inst Detect and Quant Limit"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="Not Detected at Detection Limit"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="Not Detected at Reporting Limit"

			replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if resultmeasurevalue_string=="*Present <QL"
			replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if resultmeasurevalue_string=="BDL"

// To "Not Reported"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="Not Reported"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NO DATA FOUND IN BENCH BOOK"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NO RESULTS FOUND IN BENCH BOOK"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NOT FOUND IN BENCH BOOK"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NO"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NR"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="*SP"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NRP"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="RESULTS NOT FOUND IN BENCH BOOK"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="SEE COMMENT"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="VALUE NOT RECORDED"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="Detected Not Quantified"

			replace ResultDetectionConditionText_ = "Not Reported" if resultmeasurevalue_string=="*Not Reported"
			replace ResultDetectionConditionText_ = "Not Reported" if resultmeasurevalue_string=="Not Reported"
			replace ResultDetectionConditionText_ = "Not Reported" if resultmeasurevalue_string=="NO"
			replace ResultDetectionConditionText_ = "Not Reported" if resultmeasurevalue_string=="NO DATA FOUND IN BENCH BOOK"
			replace ResultDetectionConditionText_ = "Not Reported" if resultmeasurevalue_string=="NO DATA FOUND IN BENCH BOOK COMPLETED RESULT W/O DATA"
			replace ResultDetectionConditionText_ = "Not Reported" if resultmeasurevalue_string=="NO RESULTS FOUND IN BENCH BOOK"
			replace ResultDetectionConditionText_ = "Not Reported" if resultmeasurevalue_string=="NO RESULTS IN BENCHBOOK."
			replace ResultDetectionConditionText_ = "Not Reported" if resultmeasurevalue_string=="NR"
			replace ResultDetectionConditionText_ = "Not Reported" if resultmeasurevalue_string=="NRP"

g check_NR = substr(ResultDetectionConditionText_, 1, 7)
*br ResultDetectionConditionText_ if check_NR=="NO DATA"
*br ResultDetectionConditionText_ if check_NR=="NO RESU"
replace ResultDetectionConditionText_ = "Not Reported" if check_NR=="NO DATA" 
replace ResultDetectionConditionText_ = "Not Reported" if check_NR=="NO RESU"
drop check_NR

drop if ResultDetectionConditionText_ =="Value Decensored"
drop if resultmeasurevalue_string =="#VALUE!"
drop if resultmeasurevalue_string =="*OS"
drop if resultmeasurevalue_string =="*SP"
drop if resultmeasurevalue_string =="x"
drop if resultmeasurevalue_string =="~115"
drop if resultmeasurevalue_string =="~125"
drop if resultmeasurevalue_string =="~250"
drop if resultmeasurevalue_string =="SEE COMMENT"
drop if resultmeasurevalue_string =="SEE COMMENT"

tab ResultDetectionConditionText_

/*
br ResultDetectionConditionText ResultDetectionConditionText_ resultmeasurevalue_string resultmeasurevalue if ResultDetectionConditionText_=="" & resultmeasurevalue_string!="" & resultmeasurevalue !=.
*/
// ok

/*
br ResultDetectionConditionText ResultDetectionConditionText_ resultmeasurevalue_string resultmeasurevalue if ResultDetectionConditionText_=="" & resultmeasurevalue_string!="" & resultmeasurevalue ==.
*/
// ok

// Generate ResultDetectionConditionValue, i.e., variable that takes the value of the detection limit if available 
g ResultDetectionConditionValue = ResultDetectionConditionText_ if ResultDetectionConditionText_!="NA" & ///
ResultDetectionConditionText_!="Not Detected" & ///
ResultDetectionConditionText_!="Not Reported" & ///
ResultDetectionConditionText_!="Present Above Quantification Limit"  & ///
ResultDetectionConditionText_!="Present Below Quantification Limit"  & ///
ResultDetectionConditionText_!="Systematic Contamination" & ///
(Ch =="Barium" | Ch =="Bromide" | Ch =="Chloride" | Ch =="Strontium")

destring ResultDetectionConditionValue, replace

replace ResultDetectionConditionValue = ResultDetectionConditionValue / 2

// Generate the Three Alternative Measurement Versions
rename resultmeasurevalue ResultMeasureValue

	** Option 1
	g ResultMeasureValue_clean1 = ResultMeasureValue // original measurement variable
	* to missing
	replace ResultMeasureValue_clean1 =. if ResultDetectionConditionText_!=""

	** Option 2
	g ResultMeasureValue_clean2 = ResultMeasureValue // original measurement variable
	* to the limit
	replace ResultMeasureValue_clean2 = ResultDetectionConditionValue if ResultDetectionConditionText_!="NA" & ///
	ResultDetectionConditionText_!="Not Detected" & ///
	ResultDetectionConditionText_!="Not Reported" & ///
	ResultDetectionConditionText_!="Present Above Quantification Limit" & ///
	ResultDetectionConditionText_!="Present Below Quantification Limit" & ///
	ResultDetectionConditionText_!="Systematic Contamination" & ///
	ResultDetectionConditionText_!=""
	* to zero
	replace ResultMeasureValue_clean2 = 0 if ResultDetectionConditionText_=="Not Detected"
	* to missing
	replace ResultMeasureValue_clean2 = . if ResultDetectionConditionText_!="" & ///
	(ResultDetectionConditionText_=="NA" | ///
	ResultDetectionConditionText_=="Not Reported"  & ///
	ResultDetectionConditionText_=="Present Above Quantification Limit"  | ///
	ResultDetectionConditionText_=="Present Below Quantification Limit"  | ///
	ResultDetectionConditionText_=="Systematic Contamination")

	** Option 3
	g ResultMeasureValue_clean3 = ResultMeasureValue // original measurement variable
	* to the limit
	replace ResultMeasureValue_clean3 = ResultDetectionConditionValue if ResultDetectionConditionText_!="NA" & ///
	ResultDetectionConditionText_!="Not Detected" & ///
	ResultDetectionConditionText_!="Not Reported" & ///
	ResultDetectionConditionText_!="Present Above Quantification Limit" & ///
	ResultDetectionConditionText_!="Present Below Quantification Limit" & ///
	ResultDetectionConditionText_!="Systematic Contamination" & ///
	ResultDetectionConditionText_!=""
	* to zero
	replace ResultMeasureValue_clean3 = 0 if ResultDetectionConditionText_=="Not Detected"
	replace ResultMeasureValue_clean3 = 0 if ResultDetectionConditionText_=="Present Below Quantification Limit"
	* to missing
	replace ResultMeasureValue_clean3 = . if ResultDetectionConditionText_!="" & ///
	(ResultDetectionConditionText_=="NA" | ///
	ResultDetectionConditionText_=="Not Reported" | ///
	ResultDetectionConditionText_=="Present Above Quantification Limit" | ///
	ResultDetectionConditionText_=="Systematic Contamination")

**********************
*** Further checks ***
**********************

* 1 // Check ResultSampleFractionText [filtered/unfiltered]

tab resultsamplefractiontext

drop if resultsamplefractiontext =="Bed Sediment"
drop if resultsamplefractiontext =="Suspended"
drop if resultsamplefractiontext =="Acid Soluble"
drop if resultsamplefractiontext =="Extractable"
drop if resultsamplefractiontext =="Settleable"
drop if resultsamplefractiontext =="Fixed"
drop if resultsamplefractiontext =="Comb Available"

replace resultmeasuremeasureunitcode ="ug/l" if activitystartdate=="2013-11-13" & monitoringlocationidentifier=="21OHIO_WQX-301184" & CharacteristicsName=="Barium" // & ResultMeasureMeasureUnitCode=="mg/kg"
replace resultmeasuremeasureunitcode ="ug/l" if activitystartdate=="2013-11-13" & monitoringlocationidentifier=="21OHIO_WQX-301183" & CharacteristicsName=="Barium" // & ResultMeasureMeasureUnitCode=="mg/kg"
replace resultmeasuremeasureunitcode ="ug/l" if activitystartdate=="2013-11-13" & monitoringlocationidentifier=="21OHIO_WQX-301182" & CharacteristicsName=="Barium" // & ResultMeasureMeasureUnitCode=="mg/kg"
replace resultmeasuremeasureunitcode ="ug/l" if activitystartdate=="2013-11-13" & monitoringlocationidentifier=="21OHIO_WQX-N03S51" & CharacteristicsName=="Barium" // & ResultMeasureMeasureUnitCode=="mg/kg"

* 2 // Check ActivityTypeCode [routine/non-routine/other]
tab activitytypecode

					duplicates tag CharacteristicsName MonitoringLocationTypeName monitoringlocationidentifier activitystartdate, gen(FLAG)																			
					g activitytypecode_s = substr(activitytypecode,1,35)
					tab activitytypecode_s if FLAG >0

					drop if FLAG >0 & activitytypecode_s=="Quality Control Field Replicate Msr"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Field Sample Equipm"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Lab Sample Equipmen"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Blind Duplic"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Equipment Bl"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Field Blank"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Field Replic"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Field Spike"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Inter-lab Sp"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Lab Blank"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Lab Duplicat"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Lab Matrix S"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Lab Spike"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Lab Split"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Other"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Reagent Blan"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Reference Ma"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Reference Sa"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Trip Blank"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Lab Duplicat"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Lab Matrix S"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Lab Spike"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Lab Split"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Other"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Reagent Blan"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Reference Ma"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Reference Sa"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Trip Blank"
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Lab Control "
					drop if FLAG >0 & activitytypecode_s=="Quality Control Sample-Spike Soluti"

* 3 // Check hydrologiccondition & hydrologicevent [conditions/event]
tab hydrologiccondition // no observations to be dropped
tab hydrologicevent // no observations to be dropped

* 5 // Check resultstatusidentifier [Final, preliminary, accepted]
tab resultstatusidentifier

drop if resultstatusidentifier == "Rejected"
drop if resultstatusidentifier == "Unreviewed"

* 6 // Check usgspcode code
tab usgspcode // and link to the manual code

drop if usgspcode ==1008
drop if usgspcode ==1376
drop if usgspcode ==29820
drop if usgspcode ==34805
drop if usgspcode ==34965
drop if usgspcode ==35040
drop if usgspcode ==30305
drop if usgspcode ==62951

************************************
*** Convert Measurements to mg/l ***
************************************

rename resultmeasuremeasureunitcode ResultMeasureMeasureUnitCode
tab ResultMeasureMeasureUnitCode if Ch =="Barium" | ///
									 Ch =="Bromide" | ///
									 Ch =="Chloride" | ///
									 Ch =="Strontium"
/*
ResultMeasu |
re/MeasureU |
    nitCode |      Freq.     Percent        Cum.
------------+-----------------------------------
      count |          4        0.00        0.00 [dropped]
       mg/L |      7,531        0.99        1.00 [default]
      mg/kg |      1,469        0.19        1.19
       mg/l |    499,716       66.01       67.20 [default]
      mg/m2 |        304        0.04       67.24 [dropped]
        ppm |      2,773        0.37       67.60 [default]
      ueq/L |      2,242        0.30       67.90 [OK]
       ug/g |          3        0.00       67.90 [OK]
       ug/l |    243,016       32.10      100.00 [OK]
------------+-----------------------------------
      Total |    757,058      100.00*/

replace ResultMeasureMeasureUnitCode = "ug/l" if Ch =="Barium" // OK ! [actually all strontium observations are in ug/l even if in mg/l]
replace ResultMeasureMeasureUnitCode = "ug/l" if Ch =="Bromide" & ResultMeasureValue_clean2>=5 // [actually all strontium observations are in ug/l even if in mg/l if value > 5]
replace ResultMeasureMeasureUnitCode = "ug/l" if Ch =="Strontium" // OK ! [actually all strontium observations are in ug/l even if in mg/l]
*replace ResultMeasureMeasureUnitCode = "ug/l" if Ch =="Chloride"

local Ys ""ResultMeasureValue" "ResultMeasureValue_clean1" "ResultMeasureValue_clean2" "ResultMeasureValue_clean3"" // chech if the distributions are reasonable. Potential problem with the missing values
foreach y of local Ys {

replace `y' = `y'/1000   	 if ResultMeasureMeasureUnitCode == "ug/l"
replace `y' = `y'/1000   	 if ResultMeasureMeasureUnitCode == "ug/kg"
replace `y' = `y'/1000    	 if ResultMeasureMeasureUnitCode == "ppb"
replace `y' = `y'*35/1000    if ResultMeasureMeasureUnitCode == "ueq/L"
replace `y' = `y'        	 if ResultMeasureMeasureUnitCode == "ug/g"

// non-relevant ResultMeasureMeasureUnitCode given the considered chemicals
drop if ResultMeasureMeasureUnitCode=="#/100 gal"
drop if ResultMeasureMeasureUnitCode=="Mole/l"
drop if ResultMeasureMeasureUnitCode=="mmol/L"
drop if ResultMeasureMeasureUnitCode=="NTU"
drop if ResultMeasureMeasureUnitCode=="MPN"
drop if ResultMeasureMeasureUnitCode=="S/m"
drop if ResultMeasureMeasureUnitCode=="cm3/g @STP"
drop if ResultMeasureMeasureUnitCode=="deg C"
drop if ResultMeasureMeasureUnitCode=="kgal"
drop if ResultMeasureMeasureUnitCode=="mS/cm"
drop if ResultMeasureMeasureUnitCode=="mV"
drop if ResultMeasureMeasureUnitCode=="meq/L"
drop if ResultMeasureMeasureUnitCode=="mg/l CaCO3"
drop if ResultMeasureMeasureUnitCode=="nu"
drop if ResultMeasureMeasureUnitCode=="psi"
drop if ResultMeasureMeasureUnitCode=="uS/cm"
drop if ResultMeasureMeasureUnitCode=="umol"
drop if ResultMeasureMeasureUnitCode=="count"
drop if ResultMeasureMeasureUnitCode=="mg/m2"
drop if ResultMeasureMeasureUnitCode=="mg/kg"

}

// further cleaning
drop projectidentifier
drop sampleaquifer samplecollectionmethodmethodname
drop samplecollectionequipmentname
drop statisticalbasecode resultvaluetypename
drop measurequalifiercode
drop resultweightbasistext resulttimebasistext resulttemperaturebasistext resultparticlesizebasistext
drop monitoringlocationname
drop subjecttaxonomicname resultanalyticalmethodmethodiden
drop drainageareameasuremeasurevalue drainageareameasuremeasureunitco contributingdrainageareameasurem v11
drop sourcemapscalenumeric horizontalaccuracymeasuremeasure v16 horizontalcoordinatereferencesys verticalmeasuremeasurevalue 
drop verticalaccuracymeasuremeasureva verticalcoordinatereferencesyste countrycode
drop welldepthmeasuremeasurevalue wellholedepthmeasuremeasurevalue
drop _merge first_4

// 2st temp file
compress
save "temp_2 B.dta", replace 

use "temp_2 B.dta", clear
sort ResultMeasureValue_clean2
br Ch MonitoringLocationTypeName monitoring ID_geo date ResultMeasureValue_clean2 ResultMeasureMeasureUnitCode if Ch =="Strontium" & ResultMeasureValue_clean2!=. & (MonitoringLocationTypeName=="Surface Water" | MonitoringLocationTypeName=="Surface Water - L" | MonitoringLocationTypeName=="Surface Water - R")
// missing values are in ug/l
br Ch MonitoringLocationTypeName monitoring ID_geo date ResultMeasureValue_clean2 ResultMeasureMeasureUnitCode if Ch =="Barium" & ResultMeasureValue_clean2!=. & (MonitoringLocationTypeName=="Surface Water" | MonitoringLocationTypeName=="Surface Water - L" | MonitoringLocationTypeName=="Surface Water - R")
// missing values are in ug/l
br Ch MonitoringLocationTypeName monitoring ID_geo date ResultMeasureValue_clean2 ResultMeasureMeasureUnitCode if Ch =="Bromide" & ResultMeasureValue_clean2!=. & (MonitoringLocationTypeName=="Surface Water" | MonitoringLocationTypeName=="Surface Water - L" | MonitoringLocationTypeName=="Surface Water - R")
// missing values are in ug/l
br Ch MonitoringLocationTypeName monitoring ID_geo date ResultMeasureValue_clean2 ResultMeasureMeasureUnitCode if Ch =="Chloride" & ResultMeasureValue_clean2!=. & (MonitoringLocationTypeName=="Surface Water" | MonitoringLocationTypeName=="Surface Water - L" | MonitoringLocationTypeName=="Surface Water - R")
// missing values are in mg/l

bysort CharacteristicsName: su  ResultMeasureValue_clean2 if MonitoringLocationTypeName=="Surface Water" | MonitoringLocationTypeName=="Surface Water - L" | MonitoringLocationTypeName=="Surface Water - R", d

use "temp_2 B.dta", clear

// Append Harte Research Institute & IEERWU data [already cleaned and w/ the same key variables]
*rename CharacteristicsName CharacteristicName 
rename date_string datadate_s

rename latitudemeasure latitude
rename longitudemeasure longitude

append using "$dropbox\1. data\water_data_updated\hydrodesktop\Hydro.dta" // no problem here re unit of measurements

replace CharacteristicsName = CharacteristicName if CharacteristicsName =="" & CharacteristicName!=""
drop CharacteristicName
drop if latitude ==.
drop if longitude ==.

// Create Water Measurements at the CharacteristicName MonitoringLocationTypeName ID_geo year month day Level
rename ResultMeasureValue Value
rename ResultMeasureValue_clean1 Value_clean1 
rename ResultMeasureValue_clean2 Value_clean2 
rename ResultMeasureValue_clean3 Value_clean3 

local Ys ""Value" "Value_clean1" "Value_clean2" "Value_clean3""
foreach y of local Ys {
bysort Ch MonitoringLocationTypeName ID_geo date: egen median_geo_`y' = median(`y')
bysort Ch MonitoringLocationTypeName ID_geo date: egen mean_geo_`y' = mean(`y')
bysort Ch MonitoringLocationTypeName ID_geo date: egen max_geo_`y' = max(`y')
bysort Ch MonitoringLocationTypeName ID_geo date: egen min_geo_`y' = min(`y')
}

// Collapse data at the CharacteristicName MonitoringLocationTypeName ID_geo year month day Level
bysort Ch MonitoringLocationTypeName ID_geo date: gen ok_ID_geo = 1 if date==date[_n+1] // equivalent to collapse
keep if ok_ID_geo ==.

g TYPE = "Groundwater" if MonitoringLocationTypeName=="Groundwater"
replace TYPE = "Surfacewater" if TYPE=="" 
destring year, replace
compress

cd "$dropbox\1. data\water_data_updated\"

save "water_quality_data_daily_wqs_buffer_new_OCT_2021_id_geo B.dta", replace

	// Files w/ Monitoring Stations linked to HUC10s // QGIS ASSIGNEMENT
	import delimited "monitors_huc10_linking.csv", clear // 372,668 out of 373,838 monitors. The missing ones are out of the US
	drop tnmid metasource sourcedata sourceorig x y sourcefeat loaddate gnis_id hutype humod shape_leng shape_area
	tostring huc10, gen(huc10_s)
	g lenght_huc10 = length(huc10_s)
	replace huc10_s = "0" + huc10_s if lenght_huc10==9
	drop lenght_huc10
	compress
	rename characteri CharacteristicName 
	bysort Ch monitoring: g ok = 1 if monitoring == monitoring[_n+1]
	keep if ok ==. // (74 observations deleted)
	save "huc10_wqs_final.dta", replace

use "water_quality_data_daily_wqs_buffer_new_OCT_2021_id_geo B.dta", clear

// Drop non-Relevant Chemicals & Water Body Sources
drop if MonitoringLocationTypeName=="LAND"
drop if MonitoringLocationTypeName=="Surface Water - W"
drop if MonitoringLocationTypeName=="Surface Water - O"

// Drop obs. before 2005
drop if year <=2005
tostring year, gen(year_string)

drop if date >=d(01jan2020) // no weather data after this date

// Import HUC10s Assignment
rename CharacteristicsName CharacteristicName
merge m:1 Ch monitoring using "huc10_wqs_final.dta", gen(_merge_huc10)
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       483,705
        from master                   161,542  (_merge_huc10==1)
        from using                    322,163  (_merge_huc10==2)

    Matched                            57,050  (_merge_huc10==3)
    -----------------------------------------

*/

* DIG INTO THE NON-MERGIN ONES:
*	- missing coordinates
*	- non-readable coordinates
*	- other issues in the QGIS

tab statecode if _merge_huc10 == 1 &  MonitoringLocationTypeName!="Groundwater"
count if _merge_huc10 == 1 &  MonitoringLocationTypeName!="Groundwater"
*  2,547

/*

  StateCode |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,199        1.27        1.27
          2 |         97        0.10        1.37
          4 |      1,504        1.59        2.95
          5 |        548        0.58        3.53
          6 |      4,714        4.97        8.51
          8 |      1,003        1.06        9.57
          9 |        428        0.45       10.02
         10 |        164        0.17       10.19
         11 |         27        0.03       10.22
         12 |      4,285        4.52       14.74
         13 |      1,209        1.28       16.02
         15 |        106        0.11       16.13
         16 |        511        0.54       16.67
         17 |      4,504        4.75       21.42
         18 |      2,409        2.54       23.96
         19 |      6,020        6.35       30.32
         20 |      4,205        4.44       34.76
         21 |        471        0.50       35.25
         22 |      8,169        8.62       43.87
         23 |        546        0.58       44.45
         24 |      2,711        2.86       47.31
         25 |        378        0.40       47.71
         26 |      1,004        1.06       48.77
         27 |      8,909        9.40       58.17
         28 |        714        0.75       58.92
         29 |      1,629        1.72       60.64
         30 |        761        0.80       61.45
         31 |      1,044        1.10       62.55
         32 |        405        0.43       62.98
         33 |         50        0.05       63.03
         34 |      8,725        9.21       72.24
         35 |        834        0.88       73.12
         36 |      5,394        5.69       78.81
         37 |      5,470        5.77       84.58
         38 |        384        0.41       84.99
         39 |        622        0.66       85.64
         40 |        616        0.65       86.29
         41 |      3,014        3.18       89.47
         42 |      1,636        1.73       91.20
         44 |         27        0.03       91.23
         45 |        579        0.61       91.84
         46 |        549        0.58       92.42
         47 |        584        0.62       93.04
         48 |      2,154        2.27       95.31
         49 |        871        0.92       96.23
         50 |         47        0.05       96.28
         51 |        548        0.58       96.86
         53 |      1,331        1.40       98.26
         54 |        152        0.16       98.42
         55 |      1,173        1.24       99.66
         56 |        119        0.13       99.78
         72 |        204        0.22      100.00
------------+-----------------------------------
      Total |     94,757      100.00

*/

replace statecode =2 if states=="AK" & statecode ==.
replace statecode =2 if states=="AK,CN" & statecode ==.
replace statecode =1 if states=="AL" & statecode ==.
replace statecode =1 if states=="AL,FL" & statecode ==.
replace statecode =1 if states=="AL,FL,GA" & statecode ==.
replace statecode =1 if states=="AL,GA" & statecode ==.
replace statecode =1 if states=="AL,GA,TN" & statecode ==.
replace statecode =1 if states=="AL,MS" & statecode ==.
replace statecode =1 if states=="AL,MS,TN" & statecode ==.
replace statecode =1 if states=="AL,TN" & statecode ==.
replace statecode =5 if states=="AR" & statecode ==.
replace statecode =5 if states=="AR,LA" & statecode ==.
replace statecode =5 if states=="AR,LA,MS" & statecode ==.
replace statecode =5 if states=="AR,LA,TX" & statecode ==.
replace statecode =5 if states=="AR,MO" & statecode ==.
replace statecode =5 if states=="AR,MO,OK" & statecode ==.
replace statecode =5 if states=="AR,MS" & statecode ==.
replace statecode =5 if states=="AR,MS,TN" & statecode ==.
replace statecode =5 if states=="AR,OK" & statecode ==.
replace statecode =5 if states=="AR,TN" & statecode ==.
replace statecode =5 if states=="AR,TX" & statecode ==.
replace statecode =4 if states=="AZ" & statecode ==.
replace statecode =4 if states=="AZ,CA" & statecode ==.
replace statecode =4 if states=="AZ,CA,MX" & statecode ==.
replace statecode =4 if states=="AZ,CA,NV" & statecode ==.
replace statecode =4 if states=="AZ,CO,NM,UT" & statecode ==.
replace statecode =4 if states=="AZ,MX" & statecode ==.
replace statecode =4 if states=="AZ,MX,NM" & statecode ==.
replace statecode =4 if states=="AZ,NM" & statecode ==.
replace statecode =4 if states=="AZ,NV" & statecode ==.
replace statecode =4 if states=="AZ,NV,UT" & statecode ==.
replace statecode =4 if states=="AZ,UT" & statecode ==.
replace statecode =6 if states=="CA" & statecode ==.
replace statecode =6 if states=="CA,MX" & statecode ==.
replace statecode =6 if states=="CA,NV" & statecode ==.
replace statecode =6 if states=="CA,NV,OR" & statecode ==.
replace statecode =6 if states=="CA,OR" & statecode ==.
replace statecode =16 if states=="CN,ID" & statecode ==.
replace statecode =16 if states=="CN,ID,MT" & statecode ==.
replace statecode =16 if states=="CN,ID,WA" & statecode ==.
replace statecode =23 if states=="CN,ME" & statecode ==.
replace statecode =23 if states=="CN,ME,NH" & statecode ==.
replace statecode =26 if states=="CN,MI" & statecode ==.
replace statecode =26 if states=="CN,MI,MN" & statecode ==.
replace statecode =26 if states=="CN,MI,MN,WI" & statecode ==.
replace statecode =26 if states=="CN,MI,NY,OH,PA" & statecode ==.
replace statecode =26 if states=="CN,MI,OH,PA" & statecode ==.
replace statecode =27 if states=="CN,MN" & statecode ==.
replace statecode =27 if states=="CN,MN,ND" & statecode ==.
replace statecode =27 if states=="CN,MT" & statecode ==.
replace statecode =30 if states=="CN,MT,ND" & statecode ==.
replace statecode =38 if states=="CN,ND" & statecode ==.
replace statecode =33 if states=="CN,NH,VT" & statecode ==.
replace statecode =36 if states=="CN,NY" & statecode ==.
replace statecode =36 if states=="CN,NY,VT" & statecode ==.
replace statecode =50 if states=="CN,VT" & statecode ==.
replace statecode =53 if states=="CN,WA" & statecode ==.
replace statecode =8 if states=="CO" & statecode ==.
replace statecode =8 if states=="CO,KS" & statecode ==.
replace statecode =8 if states=="CO,KS,NE" & statecode ==.
replace statecode =8 if states=="CO,KS,OK" & statecode ==.
replace statecode =8 if states=="CO,NE" & statecode ==.
replace statecode =8 if states=="CO,NM" & statecode ==.
replace statecode =8 if states=="CO,NM,OK" & statecode ==.
replace statecode =8 if states=="CO,OK" & statecode ==.
replace statecode =8 if states=="CO,UT" & statecode ==.
replace statecode =8 if states=="CO,UT,WY" & statecode ==.
replace statecode =8 if states=="CO,WY" & statecode ==.
replace statecode =9 if states=="CT" & statecode ==.
replace statecode =9 if states=="CT,MA" & statecode ==.
replace statecode =9 if states=="CT,MA,NY" & statecode ==.
replace statecode =9 if states=="CT,MA,RI" & statecode ==.
replace statecode =9 if states=="CT,NY" & statecode ==.
replace statecode =9 if states=="CT,NY,RI" & statecode ==.
replace statecode =9 if states=="CT,RI" & statecode ==.
replace statecode =11 if states=="DC,MD" & statecode ==.
replace statecode =11 if states=="DC,MD,VA" & statecode ==.
replace statecode =10 if states=="DE" & statecode ==.
replace statecode =10 if states=="DE,MD" & statecode ==.
replace statecode =10 if states=="DE,MD,NJ,VA" & statecode ==.
replace statecode =10 if states=="DE,MD,PA" & statecode ==.
replace statecode =10 if states=="DE,NJ" & statecode ==.
replace statecode =10 if states=="DE,NJ,PA" & statecode ==.
replace statecode =10 if states=="DE,PA" & statecode ==.
replace statecode =12 if states=="FL" & statecode ==.
replace statecode =12 if states=="FL,GA" & statecode ==.
replace statecode =13 if states=="GA" & statecode ==.
replace statecode =13 if states=="GA,NC" & statecode ==.
replace statecode =13 if states=="GA,NC,SC" & statecode ==.
replace statecode =13 if states=="GA,NC,TN" & statecode ==.
replace statecode =13 if states=="GA,SC" & statecode ==.		
replace statecode =13 if states=="GA,TN" & statecode ==.
replace statecode =15 if states=="HI" & statecode ==.
replace statecode =19 if states=="IA" & statecode ==.
replace statecode =19 if states=="IA,IL" & statecode ==.
replace statecode =19 if states=="IA,IL,MO" & statecode ==.
replace statecode =19 if states=="IA,IL,WI" & statecode ==.
replace statecode =19 if states=="IA,MN" & statecode ==.
replace statecode =19 if states=="IA,MN,SD" & statecode ==.
replace statecode =19 if states=="IA,MN,WI" & statecode ==.
replace statecode =19 if states=="IA,MO" & statecode ==.
replace statecode =19 if states=="IA,MO,NE" & statecode ==.
replace statecode =19 if states=="IA,NE" & statecode ==.
replace statecode =19 if states=="IA,NE,SD" & statecode ==.
replace statecode =19 if states=="IA,SD" & statecode ==.
replace statecode =19 if states=="IA,WI" & statecode ==.
replace statecode =16 if states=="ID" & statecode ==.
replace statecode =16 if states=="ID,MT" & statecode ==.
replace statecode =16 if states=="ID,MT,WY" & statecode ==.
replace statecode =16 if states=="ID,NV" & statecode ==.
replace statecode =16 if states=="ID,NV,UT" & statecode ==.
replace statecode =16 if states=="ID,OR" & statecode ==.
replace statecode =16 if states=="ID,UT" & statecode ==.
replace statecode =16 if states=="ID,UT,WY" & statecode ==.
replace statecode =16 if states=="ID,WA" & statecode ==.
replace statecode =16 if states=="ID,WY" & statecode ==.
replace statecode =17 if states=="IL" & statecode ==.
replace statecode =17 if states=="IL,IN" & statecode ==.
replace statecode =17 if states=="IL,IN,KY" & statecode ==.
replace statecode =17 if states=="IL,IN,MI,WI" & statecode ==.
replace statecode =17 if states=="IL,KY" & statecode ==.
replace statecode =17 if states=="IL,KY,MO" & statecode ==.
replace statecode =17 if states=="IL,MO" & statecode ==.	
replace statecode =17 if states=="IL,WI" & statecode ==.
replace statecode =18 if states=="IN" & statecode ==.
replace statecode =18 if states=="IN,KY" & statecode ==.
replace statecode =18 if states=="IN,KY,OH" & statecode ==.
replace statecode =18 if states=="IN,MI" & statecode ==.
replace statecode =18 if states=="IN,MI,OH" & statecode ==.
replace statecode =18 if states=="IN,OH" & statecode ==.
replace statecode =20 if states=="KS" & statecode ==.
replace statecode =20 if states=="KS,MO" & statecode ==.
replace statecode =20 if states=="KS,MO,NE" & statecode ==.
replace statecode =20 if states=="KS,MO,OK" & statecode ==.
replace statecode =20 if states=="KS,NE" & statecode ==.
replace statecode =20 if states=="KS,OK" & statecode ==.
replace statecode =21 if states=="KY" & statecode ==.
replace statecode =21 if states=="KY,MO" & statecode ==.
replace statecode =21 if states=="KY,OH" & statecode ==.
replace statecode =21 if states=="KY,OH,WV" & statecode ==.
replace statecode =21 if states=="KY,TN" & statecode ==.
replace statecode =21 if states=="KY,TN,VA" & statecode ==.
replace statecode =21 if states=="KY,VA" & statecode ==.
replace statecode =21 if states=="KY,VA,WV" & statecode ==.
replace statecode =21 if states=="KY,WV" & statecode ==.
replace statecode =22 if states=="LA" & statecode ==.
replace statecode =22 if states=="LA,MS" & statecode ==.
replace statecode =22 if states=="LA,TX" & statecode ==.
replace statecode =25 if states=="MA" & statecode ==.
replace statecode =25 if states=="MA,ME,NH" & statecode ==.
replace statecode =25 if states=="MA,NH" & statecode ==.
replace statecode =25 if states=="MA,NH,VT" & statecode ==.
replace statecode =25 if states=="MA,NY" & statecode ==.
replace statecode =25 if states=="MA,NY,VT" & statecode ==.	
replace statecode =25 if states=="MA,RI" & statecode ==.
replace statecode =25 if states=="MA,VT" & statecode ==.
replace statecode =24 if states=="MD" & statecode ==.
replace statecode =24 if states=="MD,PA" & statecode ==.
replace statecode =24 if states=="MD,PA,WV" & statecode ==.
replace statecode =24 if states=="MD,VA" & statecode ==.
replace statecode =24 if states=="MD,VA,WV" & statecode ==.
replace statecode =24 if states=="MD,WV" & statecode ==.
replace statecode =23 if states=="ME" & statecode ==.
replace statecode =23 if states=="ME,NH" & statecode ==.
replace statecode =26 if states=="MI" & statecode ==.
replace statecode =26 if states=="MI,OH" & statecode ==.
replace statecode =26 if states=="MI,WI" & statecode ==.
replace statecode =27 if states=="MN" & statecode ==.
replace statecode =27 if states=="MN,ND" & statecode ==.
replace statecode =27 if states=="MN,ND,SD" & statecode ==.
replace statecode =27 if states=="MN,SD" & statecode ==.
replace statecode =27 if states=="MN,WI" & statecode ==.
replace statecode =29 if states=="MO" & statecode ==.
replace statecode =29 if states=="MO,NE" & statecode ==.
replace statecode =29 if states=="MO,OK" & statecode ==.
replace statecode =29 if states=="MO,TN" & statecode ==.
replace statecode =28 if states=="MS" & statecode ==.
replace statecode =28 if states=="MS,TN" & statecode ==.
replace statecode =30 if states=="MT" & statecode ==.
replace statecode =30 if states=="MT,ND" & statecode ==.
replace statecode =30 if states=="MT,ND,SD" & statecode ==.
replace statecode =30 if states=="MT,SD" & statecode ==.
replace statecode =30 if states=="MT,SD,WY" & statecode ==.
replace statecode =30 if states=="MT,WY" & statecode ==.
replace statecode =35 if states=="MX,NM" & statecode ==.
replace statecode =35 if states=="MX,NM,TX" & statecode ==.
replace statecode =48 if states=="MX,TX" & statecode ==.
replace statecode =37 if states=="NC" & statecode ==.
replace statecode =37 if states=="NC,SC" & statecode ==.
replace statecode =37 if states=="NC,TN" & statecode ==.
replace statecode =37 if states=="NC,TN,VA" & statecode ==.
replace statecode =37 if states=="NC,VA" & statecode ==.
replace statecode =38 if states=="ND" & statecode ==.
replace statecode =38 if states=="ND,SD" & statecode ==.
replace statecode =31 if states=="NE" & statecode ==.
replace statecode =31 if states=="NE,SD" & statecode ==.
replace statecode =31 if states=="NE,SD,WY" & statecode ==.
replace statecode =31 if states=="NE,WY" & statecode ==.
replace statecode =33 if states=="NH" & statecode ==.
replace statecode =33 if states=="NH,VT" & statecode ==.
replace statecode =34 if states=="NJ" & statecode ==.
replace statecode =34 if states=="NJ,NY" & statecode ==.
replace statecode =34 if states=="NJ,NY,PA" & statecode ==.
replace statecode =34 if states=="NJ,PA" & statecode ==.
replace statecode =35 if states=="NM" & statecode ==.
replace statecode =35 if states=="NM,OK" & statecode ==.
replace statecode =35 if states=="NM,OK,TX" & statecode ==.
replace statecode =35 if states=="NM,TX" & statecode ==.
replace statecode =32 if states=="NV" & statecode ==.
replace statecode =32 if states=="NV,OR" & statecode ==.	
replace statecode =32 if states=="NV,UT" & statecode ==.
replace statecode =36 if states=="NY" & statecode ==.
replace statecode =42 if states=="NY,PA" & statecode ==.
replace statecode =36 if states=="NY,RI" & statecode ==.
replace statecode =36 if states=="NY,VT" & statecode ==.
replace statecode =39 if states=="OH" & statecode ==.
replace statecode =39 if states=="OH,PA" & statecode ==.
replace statecode =39 if states=="OH,PA,WV" & statecode ==.
replace statecode =39 if states=="OH,WV" & statecode ==.
replace statecode =40 if states=="OK" & statecode ==.
replace statecode =40 if states=="OK,TX" & statecode ==.
replace statecode =41 if states=="OR" & statecode ==.
replace statecode =41 if states=="OR,WA" & statecode ==.
replace statecode =42 if states=="PA" & statecode ==.
replace statecode =42 if states=="PA,WV" & statecode ==.
replace statecode =44 if states=="RI" & statecode ==.
replace statecode =45 if states=="SC" & statecode ==.
replace statecode =46 if states=="SD" & statecode ==.
replace statecode =46 if states=="SD,WY" & statecode ==.
replace statecode =47 if states=="TN" & statecode ==.
replace statecode =47 if states=="TN,VA" & statecode ==.
replace statecode =48 if states=="TX" & statecode ==.
replace statecode =49 if states=="UT" & statecode ==.
replace statecode =49 if states=="UT,WY" & statecode ==.
replace statecode =51 if states=="VA" & statecode ==.
replace statecode =51 if states=="VA,WV" & statecode ==.
replace statecode =50 if states=="VT" & statecode ==.
replace statecode =53 if states=="WA" & statecode ==.
replace statecode =55 if states=="WI" & statecode ==.
replace statecode =54 if states=="WV" & statecode ==.
replace statecode =56 if states=="WY" & statecode ==.

keep if _merge_huc10==3
drop _merge_huc10
codebook statecode

// create HUC10s Variables 
g huc8_s = substr(huc10_s,1,8)
g huc6_s = substr(huc10_s,1,6)
g huc4_s = substr(huc10_s,1,4)
destring huc8_s, gen(huc8)
destring huc6_s, gen(huc6)
destring huc4_s, gen(huc4)
egen group_HUC4 = group(huc4_s)

// Import Weather Data
merge m:1 monitoring Ch date using "id_geo_weather_data_OCT 2021 DEF.dta", gen(_merge_weather) // monitoring IDs for the USGS/STORET, geo coordinates for the HD
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                     1,711,334
        from master                       173  (_merge_weather==1)
        from using                  1,711,161  (_merge_weather==2)

    Matched                            56,877  (_merge_weather==3)
    -----------------------------------------

*/

drop if _merge_weather==2

merge m:1 monitoring Ch date using "id_geo_weather_data_OCT 2021_missing monitors II.dta", gen(_merge_weather_II) update // monitoring IDs for the USGS/STORET, geo coordinates for the HD
/*    

    Result                      Number of obs
    -----------------------------------------
    Not matched                        61,191
        from master                    57,050  (_merge_weather_II==1)
        from using                      4,141  (_merge_weather_II==2)

    Matched                                 0
        not updated                         0  (_merge_weather_II==3)
        missing updated                     0  (_merge_weather_II==4)
        nonmissing conflict                 0  (_merge_weather_II==5)
    -----------------------------------------

*/

drop if _merge_weather_II == 2

local X ""prec" "tMax" "tMin" "cum_prec_2days" "cum_prec_3days"" 
foreach x of local X {

bysort huc10_s date: egen mean_`x' = mean(`x')
replace `x' = mean_`x' if `x' ==.
drop mean_`x'
bysort huc8_s date: egen mean_`x' = mean(`x')
replace `x' = mean_`x' if `x' ==.
drop mean_`x'

bysort huc10_s year month: egen mean_`x' = mean(`x')
replace `x' = mean_`x' if `x' ==.
drop mean_`x'
bysort huc8_s year month: egen mean_`x' = mean(`x')
replace `x' = mean_`x' if `x' ==.
drop mean_`x'

}
codebook prec

// Define Indicator Variable for the Chemicals
egen group_items = group(CharacteristicName)

// Cleaning
rename areaacres areaacres_huc10
rename areasqkm areasqkm_huc10

drop activitymediasubdivisionname activitystartdate hydrologicevent huceightdigitcode _merge* ///
activitystarttimetime activitystarttimetimezonecode hydrologiccondition Value ResultMeasureMeasureUnitCode ///
resultstatusidentifier usgspcode DQLM_M_Type_name DQLM_M_Value ok

compress

// Generate Weather Variables
g log_prec = log(1+prec)
g log_cum_prec_2days = log(1+cum_prec_2days)
g log_cum_prec_3days = log(1+cum_prec_3days)
g log_precB = log(0.01 +prec)
g log_cum_prec_2daysB = log(0.01 +cum_prec_2days)
g log_cum_prec_3daysB = log(0.01 +cum_prec_3days)

g T_mean = (tMin + tMax)/2
g T_mean_D_5_groups = 0 if T_mean<=-10 & T_mean!=.
replace T_mean_D_5_groups = 1 if T_mean>-10 & T_mean<=3
replace T_mean_D_5_groups = 2 if T_mean>3 & T_mean<=15
replace T_mean_D_5_groups = 3 if T_mean>15 & T_mean<=25
replace T_mean_D_5_groups = 4 if T_mean>25 & T_mean!=.
g T_mean_D_4_groups = 0 if T_mean<=3 & T_mean!=.
replace T_mean_D_4_groups = 1 if T_mean>3 & T_mean<=15
replace T_mean_D_4_groups = 2 if T_mean>15 & T_mean<=25
replace T_mean_D_4_groups = 3 if T_mean>25 & T_mean!=.

g snow = 1 if cum_prec_3days>0.5 & T_mean<=3 & T_mean!=. & cum_prec_3days!=.
replace snow = 0 if snow ==.
g snowB = 1 if cum_prec_3days>1.5 & T_mean<=3 & T_mean!=. & cum_prec_3days!=.
replace snowB = 0 if snowB ==.

// Truncating & Winsorizing
// replace mean_Value = mean_Value*1000 // to ug/L [microgram per liter]  // DEL LATER
replace mean_geo_Value = mean_geo_Value*1000 // to ug/L [microgram per liter]
// replace mean_Value_clean1 = mean_Value_clean1*1000 // to ug/L [microgram per liter] // DEL LATER
replace mean_geo_Value_clean1 = mean_geo_Value_clean1*1000 // to ug/L [microgram per liter]
// replace mean_Value_clean2 = mean_Value_clean2*1000 // to ug/L [microgram per liter] // DEL LATER
replace mean_geo_Value_clean2 = mean_geo_Value_clean2*1000 // to ug/L [microgram per liter]
// replace mean_Value_clean3 = mean_Value_clean3*1000 // to ug/L [microgram per liter] // DEL LATER
replace mean_geo_Value_clean3 = mean_geo_Value_clean3*1000 // to ug/L [microgram per liter]

bysort CharacteristicName: su  mean_geo_Value_clean2 if MonitoringLocationTypeName=="Surface Water" | MonitoringLocationTypeName=="Surface Water - L" | MonitoringLocationTypeName=="Surface Water - R", d

// locals for the truncation and winsorization
global items ""Barium" "Bromide" "Chloride" "Strontium""
local T ""Surfacewater""
local var ""mean_geo_Value" "mean_geo_Value_clean1" "mean_geo_Value_clean2" "mean_geo_Value_clean3""

foreach v of local var {
g log_`v' = log(1 + `v')
g log_no_`v' = log(`v')
}
//

foreach v of local var {
g t1_`v' =.
g t5_`v' =.
g log_t1_`v' =.
g log_t5_`v' =.

g log_t1_no_`v' =.
g log_t5_no_`v' =.

g w1_`v' =.
g w5_`v' =.
g log_w1_`v' =.
g log_w5_`v' =.

g log_w1_no_`v' =.
g log_w5_no_`v' =.
}
//

// Truncation by HUC4
foreach k of global items {
foreach v of local var {
forval  w =1/219 {

sum log_`v' if CharacteristicName == "`k'" & group_HUC4==`w', d
replace log_t5_`v' = log_`v' if CharacteristicName == "`k'" & group_HUC4==`w' & log_`v'<=r(p99)

}
}
}
//

// relabelling of the key variables
rename log_t5_mean_geo_Value_clean1   log_t_t_Value_clean1
rename log_t5_mean_geo_Value_clean2   log_t_t_Value_clean2
rename log_t5_mean_geo_Value_clean3   log_t_t_Value_clean3

// generate fixed effects
tostring date, gen(date_string) force usedisplayformat

g date_string_month = substr(date_string, 3, 3)
g date_string_year = substr(date_string, 6, 4)
g date_string_day = substr(date_string, 1, 2)

egen ID_geo_feN = group(ID_geo MonitoringLocationTypeName)
egen year_fe = group(date_string_year)
egen month_year_fe = group(date_string_month date_string_year)

rename statecode StateCode
egen state_fe = group(StateCode)
egen state_year_fe = group(StateCode date_string_year)
egen state_month_fe = group(StateCode date_string_month)
egen state_month_year_fe = group(StateCode date_string_month date_string_year)

egen huc4_fe = group(huc4_s)
egen huc4_year_fe = group(huc4_s date_string_year)
egen huc4_month_fe = group(huc4_s date_string_month)
egen huc4_year_month_fe = group(huc4_s date_string_month date_string_year)

egen huc8_fe = group(huc8_s)
egen huc8_year_fe = group(huc8_s date_string_year)
egen huc8_month_fe = group(huc8_s date_string_month)
egen huc8_year_month_fe = group(huc8_s date_string_month date_string_year)

egen huc10_fe = group(huc10_s)
egen huc10_year_fe = group(huc10_s date_string_year)
egen huc10_month_fe = group(huc10_s date_string_month)
egen huc10_year_month_fe = group(huc10_s date_string_month date_string_year)

egen county_fe = group(state_county_ID)
egen county_year_fe = group(state_county_ID date_string_year)
egen county_month_fe = group(state_county_ID date_string_month)
egen county_year_month_fe = group(state_county_ID date_string_month date_string_year)

compress
save "WQS_DAILY__id_geo_cleaned B.dta", replace

cd "$dropbox\1. data\water_data_updated\"
use "WQS_DAILY__id_geo_cleaned B.dta", clear // use "WQS_DAILY__id_geo_cleaned.dta", clear // from the water quality paper

drop if MonitoringLocationTypeName=="Groundwater" | MonitoringLocationTypeName=="Surface Water - O"

codebook date if Ch == "Barium" // [03jan2006,31dec2019]
codebook date if Ch == "Bromide" // [01jan2006,30dec2019] 
codebook date if Ch == "Chloride" //  [01jan2006,31dec2019]
codebook date if Ch == "Strontium" // [03jan2006,30dec2019]

keep if date>d(01dec2015)

rename organizationidentifier OrganizationIdentifier
rename activitytypecode ActivityTypeCode
rename monitoringlocationidentifier MonitoringLocationIdentifier
rename resultsamplefractiontext ResultSampleFractionText
rename providername ProviderName
rename latitude LatitudeMeasure
rename longitude LongitudeMeasure
rename countycode CountyCode
drop ok
save "WQS_DAILY__id_geo_cleaned_2016_2020 B.dta", replace

							use "JAN/WQS_DAILY__id_geo_cleaned.dta", clear // use "WQS_DAILY__id_geo_cleaned.dta", clear // from the water quality paper
							drop if MonitoringLocationTypeName=="Groundwater" | MonitoringLocationTypeName=="Surface Water - O"
							codebook date if Ch == "Barium" //  [03jan2006,30dec2015]  
							codebook date if Ch == "Bromide" // [01jan2006,30dec2015]
							codebook date if Ch == "Chloride" //  [01jan2006,13dec2016] 
							codebook date if Ch == "Strontium" // [04jan2006,30dec2015]
							keep if date<=d(01dec2015)
							save "WQS_DAILY__id_geo_cleaned_2006_2016.dta", replace

clear
use "WQS_DAILY__id_geo_cleaned_2006_2016.dta"
							
destring StateCode, replace
destring CountyCode, replace
destring state_county_ID, replace

rename log_t5_mean_geo_Value_clean1   log_t_t_Value_clean1
rename log_t5_mean_geo_Value_clean3   log_t_t_Value_clean3

append using "WQS_DAILY__id_geo_cleaned_2016_2020 B.dta"

replace hydrodeskt = 1 if DATA_SOURCE_HydroD !=""

drop ResultDetectionConditionText ///
DetectionQuantitationLimitMeasur ///
ok ///
ResultDetectionConditionText_D ///
ResultDetectionConditionText_ ///
ResultDetectionConditionValue ///
datadate_s datadate ///
SiteName_HydroD	SiteID_HydroD SiteCode_HydroD VariableID_HydroD VariableCode_HydroD Organization_HydroD ///
SourceDescription_HydroD DATA_SOURCE_HydroD FLAG1 FLAG2 mean_DataValue_HydroD median_DataValue_HydroD min_DataValue_HydroD ///
max_DataValue_HydroD flag
drop _merge_weather areaacres_huc10 areasqkm_huc10 huc10_s1
drop v3 v4 data_sourc statefp statens affgeoid geoid stusps name_2 lsad aland awater
drop organizationformalname activityidentifier activitymedianame resultmeasurevalue_string states name dateNum

// ID_geo issue
drop ID_geo ID_geo_feN id_geo
g ID_geo = lat_s + long_s
egen ID_geo_feN = group(ID_geo MonitoringLocationTypeName)
compress
drop latitudeme longitudem 
drop statecode countycode
drop  ActivityTypeCode Value CountryCode

drop shape_leng shape_area

replace gridNumber = gridnumber if gridNumber  ==. & gridnumber!=.
replace gridnumber = gridNumber if gridnumber  ==. & gridNumber!=.
drop gridnumber

save "WQS_DAILY__id_geo_cleaned_OCT 2021 B.dta", replace
