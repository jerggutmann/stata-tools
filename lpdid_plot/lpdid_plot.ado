*! lpdid_plot 0.2.0  11oct2026  Jerg Gutmann
*! Event-study plot after lpdid; same layout as french_plot
program define lpdid_plot
	version 16
	syntax , [ PRE(integer -999) POST(integer -999) ///
		SHOWPRE(integer -1) SHOWPOST(integer -1) ///
		AVG AVGPre AVGValues PVAlues PNOte ///
		NOCI CIBars NORMalci LEvel(string) CIOpacity(integer 20) ///
		SHADE SHADEColor(string) VLINE ///
		SCale(real 1) PCTof(real 0) ///
		COLor(string) AVGColor(string) PRECOLor(string) MSymbol(string) ///
		LPAttern(string) LWidth(string) AVGLPattern(string) PRELPattern(string) ///
		NOZero NOCAPtions PRECAPtion(string) POSTCAPtion(string) NOLEGend ///
		LBLDyn(string) LBLAvg(string) LBLPre(string) ///
		YTItle(string) XTItle(string) ylab(string) tpos(real -99999) ///
		FMT(string) SAVEData(string) EXPort(string) * ]

	* ---- checks and defaults ----
	tempname R P
	cap matrix `R' = e(results)
	if _rc {
		di as error "last estimates not found; run lpdid first"
		exit 301
	}
	* pre() and post() default to the windows stored by lpdid
	if `pre' == -999 {
		local pre = e(pre_window)
		if missing(`pre') {
			di as error "e(pre_window) not found; specify pre()"
			exit 198
		}
	}
	else if `pre' < 1 {
		di as error "pre() must be at least 1"
		exit 198
	}
	if `post' == -999 {
		local post = e(post_window)
		if missing(`post') {
			di as error "e(post_window) not found; specify post()"
			exit 198
		}
	}
	else if `post' < 0 {
		di as error "post() must be 0 or larger"
		exit 198
	}
	if `showpre' < 0 local showpre = `pre'
	if `showpost' < 0 local showpost = `post'
	if `showpre' < 1 | `showpre' > `pre' {
		di as error "showpre() must be between 1 and pre()"
		exit 198
	}
	if `showpost' > `post' {
		di as error "showpost() cannot exceed post()"
		exit 198
	}
	* same bookkeeping as french_plot: pre(U) = baseline + U-1 placebos, post(T) = T+1 effects
	local showplacebo = `showpre' - 1
	local showeffects = `showpost' + 1
	if "`ylab'" != "" & `tpos' == -99999 {
		di as error "if you set ylab() you must also set tpos()"
		exit 198
	}
	if "`avgpre'" != "" & `showpre' < 2 {
		di as error "avgpre requires showpre() of at least 2"
		exit 198
	}
	if "`avgvalues'" != "" & "`avg'" == "" & "`avgpre'" == "" {
		di as error "avgvalues requires avg and/or avgpre"
		exit 198
	}
	if ("`shade'" != "" | "`vline'" != "") & "`ylab'" != "" {
		di as error "shade and vline cannot be combined with ylab()"
		exit 198
	}
	if `pctof' != 0 & `scale' != 1 {
		di as error "specify either scale() or pctof(), not both"
		exit 198
	}
	local sc = `scale'
	if `pctof' != 0 local sc = 100/`pctof'

	* confidence intervals: lpdid's own (default) unless normalci or level() is given
	local usel 1
	if "`normalci'" != "" | "`level'" != "" local usel 0
	local ccl = colnumb(`R', "ci_low")
	local cch = colnumb(`R', "ci_high")
	local ccp = colnumb(`R', "p")
	local cireason
	if "`normalci'" != "" {
		local cireason "normalci specified"
	}
	else if "`level'" != "" {
		local cireason "level() specified"
	}
	if `usel' & (`ccl' >= . | `cch' >= .) {
		local cireason "e(results) has no ci_low/ci_high"
		local usel 0
	}
	* normal intervals without level(): 95, the default level of lpdid
	if "`level'" == "" {
		local level = 95
	}
	else {
		cap numlist "`level'", min(1) max(2) range(>0 <100) sort
		if _rc {
			di as error "level() must contain one or two numbers between 0 and 100"
			exit 198
		}
		local level `r(numlist)'
	}
	local nlev : word count `level'
	local lev_in  : word 1 of `level'
	local lev_out : word `nlev' of `level'
	local z_out = invnormal(1 - (100 - `lev_out')/200)
	local z_in  = invnormal(1 - (100 - `lev_in')/200)
	if !`usel' & "`noci'" == "" {
		local lvtxt = cond(`nlev' == 2, "`lev_in'/`lev_out'% levels", "`lev_out'% level")
		di as text "note: confidence intervals are b +/- z*se at the `lvtxt' and not those of lpdid (`cireason')"
	}

	if "`color'" == "" local color "0 114 178"
	if "`avgcolor'" == "" local avgcolor "`color'"
	if "`precolor'" == "" local precolor "`avgcolor'"
	if "`shadecolor'" == "" local shadecolor "gs12"
	if "`msymbol'" == "" local msymbol o
	if "`avglpattern'" == "" local avglpattern dash
	if "`prelpattern'" == "" local prelpattern shortdash
	if "`lbldyn'" == "" local lbldyn "dynamic effect"
	if "`lblavg'" == "" local lblavg "average effect"
	if "`lblpre'" == "" local lblpre "average placebo"
	if "`precaption'" == "" local precaption "pre-treatment"
	if "`postcaption'" == "" local postcaption "post-treatment"
	if "`fmt'" == "" local fmt "%5.3f"

	* pooled estimates are taken from lpdid (row 1: pre, row 2: post)
	cap matrix `P' = e(pooled_results)
	local haspool = (_rc == 0)
	if `haspool' {
		if rowsof(`P') < 2 | colsof(`P') < 2 local haspool 0
	}
	if !`haspool' & ("`avg'" != "" | "`avgpre'" != "" | "`pvalues'" != "" | "`pnote'" != "") {
		di as error "e(pooled_results) not available; run lpdid with option pooled"
		exit 198
	}
	local bavg  = .
	local seavg = .
	local pavg  = .
	local bpre  = .
	local sepre = .
	local ppre  = .
	if `haspool' {
		local bavg  = `P'[2,1]*`sc'
		local seavg = `P'[2,2]*`sc'
		local bpre  = `P'[1,1]*`sc'
		local sepre = `P'[1,2]*`sc'
		if !missing(`bavg') & !missing(`seavg') {
			if `seavg' > 0 local pavg = 2*normal(-abs(`bavg'/`seavg'))
		}
		if !missing(`bpre') & !missing(`sepre') {
			if `sepre' > 0 local ppre = 2*normal(-abs(`bpre'/`sepre'))
		}
	}
	if `haspool' & `usel' {
		local cpp = colnumb(`P', "p")
		if `cpp' < . {
			if !missing(`P'[2,`cpp']) local pavg = `P'[2,`cpp']
			if !missing(`P'[1,`cpp']) local ppre = `P'[1,`cpp']
		}
	}
	if "`avg'" != "" & missing(`bavg') {
		di as error "pooled post-treatment estimate not available in e(pooled_results)"
		exit 198
	}
	if "`avgpre'" != "" & missing(`bpre') {
		di as error "pooled pre-treatment estimate not available in e(pooled_results)"
		exit 198
	}
	if `showpre' < `pre' & ("`avgpre'" != "" | "`pvalues'" != "") {
		di as text "note: average placebo of lpdid uses all pre-treatment periods, not only those shown"
	}
	if `showpost' < `post' & ("`avg'" != "" | "`pvalues'" != "") {
		di as text "note: average effect of lpdid uses all post-treatment periods, not only those shown"
	}

	* joint pre-trend test, only if lpdid was run with pretrend_test
	local pjp = .
	if !missing(e(pretrend_p)) local pjp = e(pretrend_p)
	if !missing(`pjp') & `showpre' < `pre' & ("`pvalues'" != "" | "`pnote'" != "") {
		di as text "note: joint placebo test of lpdid uses all pre-treatment coefficients, not only those shown"
	}

	if "`pvalues'" != "" {
		local sb : display string(`bavg', "`fmt'")
		local ss : display string(`seavg', "`fmt'")
		local sp : display string(`pavg', "`fmt'")
		local pb : display string(`bpre', "`fmt'")
		local ps : display string(`sepre', "`fmt'")
		local pp : display string(`ppre', "`fmt'")
		di as text _n "lpdid_plot: summary of the plotted model"
		if `sc' != 1 di as text "(estimates multiplied by " as result `sc' as text ")"
		di as text "{hline 62}"
		di as text %-30s "" %10s "estimate" %10s "s.e." %10s "p-value"
		di as text "{hline 62}"
		di as text %-30s "Average effect" as result %10s "`sb'" %10s "`ss'" %10s "`sp'"
		if `pre' >= 2 {
			di as text %-30s "Average placebo" as result %10s "`pb'" %10s "`ps'" %10s "`pp'"
		}
		if !missing(`pjp') {
			di as text %-30s "Joint test: all placebos = 0" as result %30s string(`pjp', "`fmt'")
		}
		di as text "{hline 62}"
	}

	* ---- data for the plot ----
	preserve
	qui {
		clear
		set obs `=`showplacebo' + 1 + `showeffects''
		gen x         = .
		gen eventtime = .
		gen str8 type = ""
		gen str8 coefname = ""
		gen b  = .
		gen se = .
		gen double lpl = .
		gen double lph = .
		gen double lpp = .
		local i = 0
		* x-axis: baseline at -1, pre n at -n, tau k at k (identical to french_plot)
		forvalues n = `showpre'(-1)2 {
			local ++i
			replace x          = -`n'             in `i'
			replace eventtime  = -`n'             in `i'
			replace type       = "placebo"        in `i'
			replace coefname  = "pre`n'"         in `i'
			local r = rownumb(`R', "pre`n'")
			if `r' < . {
				replace b  = `sc'*`R'[`r',1] in `i'
				replace se = `sc'*`R'[`r',2] in `i'
				if `usel' {
					replace lpl = `sc'*`R'[`r',`ccl'] in `i'
					replace lph = `sc'*`R'[`r',`cch'] in `i'
					if `ccp' < . replace lpp = `R'[`r',`ccp'] in `i'
				}
			}
		}
		local ++i
		replace x = -1 in `i'
		replace eventtime = -1 in `i'
		replace type = "baseline" in `i'
		replace coefname = "pre1" in `i'
		replace b = 0  in `i'
		replace se = 0 in `i'
		replace lpl = 0 in `i'
		replace lph = 0 in `i'
		forvalues k = 0/`showpost' {
			local ++i
			replace x          = `k'              in `i'
			replace eventtime  = `k' + 1          in `i'
			replace type       = "effect"         in `i'
			replace coefname  = "tau`k'"         in `i'
			local r = rownumb(`R', "tau`k'")
			if `r' < . {
				replace b  = `sc'*`R'[`r',1] in `i'
				replace se = `sc'*`R'[`r',2] in `i'
				if `usel' {
					replace lpl = `sc'*`R'[`r',`ccl'] in `i'
					replace lph = `sc'*`R'[`r',`cch'] in `i'
					if `ccp' < . replace lpp = `R'[`r',`ccp'] in `i'
				}
			}
		}
		count if missing(b)
		local nmiss = r(N)
		if `usel' {
			gen lb = lpl
			gen ub = lph
			gen p = lpp
			if `ccp' >= . replace p = 2*normal(-abs(b/se)) if se > 0 & !missing(se)
		}
		else {
			gen lb = b - `z_out'*se
			gen ub = b + `z_out'*se
			if `nlev' == 2 {
				gen lb_in = b - `z_in'*se
				gen ub_in = b + `z_in'*se
			}
			gen p = 2*normal(-abs(b/se)) if se > 0 & !missing(se)
		}
		drop lpl lph lpp
	}
	if `nmiss' > 0 di as text "note: `nmiss' plotted event time(s) have no estimate; shown as gaps"
	if "`savedata'" != "" {
		qui save "`savedata'", replace
		di as text "plotted data saved to `savedata'"
	}

	* ---- axis geometry ----
	local x0   = 0
	local x1   = `showeffects' - 1
	local xmin = -(`showplacebo' + 1)
	local tx1  = -(`showplacebo' + 2)/2
	local tx2  = (`showeffects' - 1)/2

	local xlab
	forvalues k = `=`showplacebo'+1'(-1)1 {
		local xlab `xlab' `=-`k'' "-`k'"
	}
	forvalues k = 1/`showeffects' {
		local xlab `xlab' `=`k'-1' "`k'"
	}

	* tidy y-range from the plotted data; also used for shading and the vertical line
	local lov lb
	local hiv ub
	if "`noci'" != "" {
		local lov b
		local hiv b
	}
	qui summ `lov', meanonly
	local lo = r(min)
	qui summ `hiv', meanonly
	local hi = r(max)
	local yv
	if "`avg'" != "" local yv `yv' `bavg'
	if "`avgpre'" != "" local yv `yv' `bpre'
	foreach v of local yv {
		if !missing(`v') {
			local lo = min(`lo', `v')
			local hi = max(`hi', `v')
		}
	}
	local lo = min(`lo', 0)
	local hi = max(`hi', 0)
	local rng  = `hi' - `lo'
	local base = 10^(floor(log10(`rng'/6)))
	local step = `base'
	foreach m in 1 2 2.5 5 10 {
		local cand = `base'*`m'
		if `rng'/`cand' <= 8 {
			local step = `cand'
			continue, break
		}
	}
	local lo2 = floor(`lo'/`step')*`step'
	local hi2 = ceil(`hi'/`step')*`step'
	if "`ylab'" == "" {
		local ylab `lo2'(`step')`hi2'
		local tpos = `hi2' + `step'/4
	}

	* ---- plot layers; k counts them so that legend indices stay correct ----
	local plots
	local k 0
	if "`shade'" != "" {
		qui {
			local n0 = _N
			set obs `=`n0' + 2'
			gen shx  = .
			gen shlo = .
			gen shhi = .
			replace shx  = -0.5          in `=`n0'+1'
			replace shx  = `x1' + 0.5    in `=`n0'+2'
			replace shlo = `lo2'         in `=`n0'+1'/`=`n0'+2'
			replace shhi = `hi2'         in `=`n0'+1'/`=`n0'+2'
		}
		local plots `plots' (rarea shhi shlo shx, color("`shadecolor'%45") lcolor("`shadecolor'%0"))
		local ++k
	}
	if "`vline'" != "" {
		local plots `plots' (pci `lo2' -0.5 `hi2' -0.5, lcolor(gs8) lpattern(dash))
		local ++k
	}
	if "`noci'" == "" {
		if "`cibars'" != "" {
			local plots `plots' (rcap ub lb x, lcolor("`color'"))
			local ++k
			if `nlev' == 2 {
				local plots `plots' (rcap ub_in lb_in x, lcolor("`color'") lwidth(thick))
				local ++k
			}
		}
		else {
			local plots `plots' (rarea ub lb x, color("`color'%`ciopacity'") lcolor("`color'%0"))
			local ++k
			if `nlev' == 2 {
				local op = min(2*`ciopacity', 100)
				local plots `plots' (rarea ub_in lb_in x, color("`color'%`op'") lcolor("`color'%0"))
				local ++k
			}
		}
	}
	local lopts
	if "`lpattern'" != "" local lopts `lopts' lpattern(`lpattern')
	if "`lwidth'" != "" local lopts `lopts' lwidth(`lwidth')
	local plots `plots' (connected b x, msymbol(`msymbol') mcolor("`color'") lcolor("`color'") `lopts')
	local ++k
	local order `k' "`lbldyn'"
	if "`nozero'" == "" {
		local plots `plots' (pci 0 `xmin' 0 `x1', lcolor(gs8) lpattern(solid))
		local ++k
	}
	local texts
	local xsc
	if "`avg'" != "" {
		local plots `plots' (pci `bavg' `x0' `bavg' `x1', lcolor("`avgcolor'") lpattern(`avglpattern') lwidth(medthick))
		local ++k
		local order `order' `k' "`lblavg'"
		local plots `plots' (scatteri `bavg' `x0', msymbol(circle_hollow) mcolor("`avgcolor'"))
		local plots `plots' (scatteri `bavg' `x1', msymbol(circle_hollow) mcolor("`avgcolor'"))
		local k = `k' + 2
		if "`avgvalues'" != "" {
			local s : display string(`bavg', "`fmt'")
			local texts `texts' text(`bavg' `=`x1'+0.2' "`s'", place(e) size(small) color("`avgcolor'"))
			local xsc xscale(range(`=`xmin'-0.5' `=`x1'+1.5'))
		}
	}
	if "`avgpre'" != "" {
		local plots `plots' (pci `bpre' `xmin' `bpre' -2, lcolor("`precolor'") lpattern(`prelpattern') lwidth(medthick))
		local ++k
		local order `order' `k' "`lblpre'"
		local plots `plots' (scatteri `bpre' `xmin', msymbol(circle_hollow) mcolor("`precolor'"))
		local plots `plots' (scatteri `bpre' -2, msymbol(circle_hollow) mcolor("`precolor'"))
		local k = `k' + 2
		if "`avgvalues'" != "" {
			local s : display string(`bpre', "`fmt'")
			local texts `texts' text(`bpre' `=`xmin'-0.2' "`s'", place(w) size(small) color("`precolor'"))
			local xsc xscale(range(`=`xmin'-1.5' `=`x1'+1.5'))
		}
	}

	local legend legend(off)
	if ("`avg'" != "" | "`avgpre'" != "") & "`nolegend'" == "" {
		local legend legend(order(`order') rows(1) position(6))
	}
	local captions
	if "`nocaptions'" == "" {
		local captions text(`tpos' `tx1' "`precaption'", size(small)) text(`tpos' `tx2' "`postcaption'", size(small))
	}
	local ytitlecmd
	if "`ytitle'" != "" local ytitlecmd title("`ytitle'", position(9) size(medium))

	* optional note under the plot with p-values
	local notecmd
	if "`pnote'" != "" {
		local nt
		if !missing(`pavg') {
			local s1 : display string(`bavg', "`fmt'")
			local s2 : display string(`pavg', "`fmt'")
			local nt "Average effect: `s1' (p = `s2')"
		}
		if !missing(`pjp') {
			local s3 : display string(`pjp', "`fmt'")
			if "`nt'" != "" local nt "`nt'; "
			local nt "`nt'joint placebo test: p = `s3'"
		}
		if "`nt'" != "" local notecmd note("`nt'", size(small))
	}

	twoway `plots', xtitle("`xtitle'") ytitle("") xlabel(`xlab') `captions' `texts' `xsc' ///
		ylabel(`ylab', grid glcolor(gs14) glwidth(vthin)) ///
		`legend' `ytitlecmd' `notecmd' `options'

	if "`export'" != "" graph export "`export'", replace
	restore
end
