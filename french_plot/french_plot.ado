*! french_plot 0.3.6  10oct2026  Jerg Gutmann
*! Event-study plot after did_multiplegt_dyn (single event)
program define french_plot
	version 16
	syntax , EFFects(integer) PLAcebo(integer) ///
		[ SHOWEFFects(integer -1) SHOWPLAcebo(integer -1) ///
		AVG AVGPre AVGValues PVAlues PNOte ///
		NOCI CIBars LEvel(string) CIOpacity(integer 20) ///
		SHADE SHADEColor(string) VLINE ///
		SCale(real 1) PCTof(real 0) ///
		COLor(string) AVGColor(string) PRECOLor(string) MSymbol(string) ///
		LPAttern(string) LWidth(string) AVGLPattern(string) PRELPattern(string) ///
		NOZero NOCAPtions PRECAPtion(string) POSTCAPtion(string) NOLEGend ///
		LBLDyn(string) LBLAvg(string) LBLPre(string) ///
		YTItle(string) XTItle(string) ylab(string) tpos(real -99999) ///
		FMT(string) SAVEData(string) EXPort(string) * ]

	* ---- checks and defaults ----
	if "`e(cmd)'" == "" {
		di as error "no estimation results found; run did_multiplegt_dyn first"
		exit 301
	}
	if `effects' < 1 {
		di as error "effects() must be at least 1"
		exit 198
	}
	if `placebo' < 0 {
		di as error "placebo() must be 0 or larger"
		exit 198
	}
	if `showeffects' < 0 local showeffects = `effects'
	if `showplacebo' < 0 local showplacebo = `placebo'
	if `showeffects' < 1 | `showeffects' > `effects' {
		di as error "showeffects() must be between 1 and effects()"
		exit 198
	}
	if `showplacebo' > `placebo' {
		di as error "showplacebo() cannot exceed placebo()"
		exit 198
	}
	if "`ylab'" != "" & `tpos' == -99999 {
		di as error "if you set ylab() you must also set tpos()"
		exit 198
	}
	if "`avgpre'" != "" & `showplacebo' < 1 {
		di as error "avgpre requires at least one placebo to be plotted"
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

	if "`level'" == "" {
		local level = c(level)
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

	* periods that were specified but could not be estimated show up as gaps in the plot
	local nmiss 0
	forvalues l = 1/`showeffects' {
		if missing(e(Effect_`l')) local ++nmiss
	}
	forvalues l = 1/`showplacebo' {
		if missing(e(Placebo_`l')) local ++nmiss
	}
	if `nmiss' > 0 di as text "note: `nmiss' plotted coefficient(s) not estimated; shown as gaps"

	* ---- summary statistics: average effect, pooled placebo, joint tests ----
	local bavg  = e(Av_tot_effect)*`sc'
	local seavg = e(se_avg_total_effect)*`sc'
	local pavg  = .
	if !missing(`bavg') & !missing(`seavg') {
		if `seavg' > 0 local pavg = 2*normal(-abs(`bavg'/`seavg'))
	}
	if "`avg'" != "" & missing(`bavg') {
		di as error "e(Av_tot_effect) not available"
		exit 198
	}
	local pjp = e(p_jointplacebo)
	local pje = e(p_jointeffects)

	local bpre  = .
	local sepre = .
	local ppre  = .
	if ("`avgpre'" != "" | "`pvalues'" != "") & `showplacebo' >= 1 {
		_french_plot_pp, maxpl(`showplacebo')
		local bpre  = r(b)*`sc'
		local sepre = r(se)*`sc'
		if !missing(`sepre') {
			if `sepre' > 0 local ppre = 2*normal(-abs(`bpre'/`sepre'))
		}
	}

	if "`pvalues'" != "" {
		local sb : display string(`bavg', "`fmt'")
		local ss : display string(`seavg', "`fmt'")
		local sp : display string(`pavg', "`fmt'")
		local pb : display string(`bpre', "`fmt'")
		local ps : display string(`sepre', "`fmt'")
		local pp : display string(`ppre', "`fmt'")
		di as text _n "french_plot: summary of the plotted model"
		if `sc' != 1 di as text "(estimates multiplied by " as result `sc' as text ")"
		di as text "{hline 62}"
		di as text %-30s "" %10s "estimate" %10s "s.e." %10s "p-value"
		di as text "{hline 62}"
		di as text %-30s "Average effect" as result %10s "`sb'" %10s "`ss'" %10s "`sp'"
		if `showplacebo' >= 1 {
			di as text %-30s "Pooled placebo" as result %10s "`pb'" %10s "`ps'" %10s "`pp'"
		}
		if !missing(`pje') {
			di as text %-30s "Joint test: all effects = 0" as result %30s string(`pje', "`fmt'")
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
		gen b  = .
		gen se = .
		local i = 0
		* x-axis: baseline at -1, placebo l at -(l+1), effect l at l-1 (as in es_plot)
		forvalues l = `showplacebo'(-1)1 {
			local ++i
			replace x         = -(`l' + 1)               in `i'
			replace eventtime = -(`l' + 1)               in `i'
			replace type      = "placebo"                in `i'
			replace b         = `sc'*e(Placebo_`l')      in `i'
			replace se        = `sc'*e(se_placebo_`l')   in `i'
		}
		local ++i
		replace x = -1 in `i'
		replace eventtime = -1 in `i'
		replace type = "baseline" in `i'
		replace b = 0  in `i'
		replace se = 0 in `i'
		forvalues l = 1/`showeffects' {
			local ++i
			replace x         = `l' - 1                  in `i'
			replace eventtime = `l'                      in `i'
			replace type      = "effect"                 in `i'
			replace b         = `sc'*e(Effect_`l')       in `i'
			replace se        = `sc'*e(se_effect_`l')    in `i'
		}
		gen lb = b - `z_out'*se
		gen ub = b + `z_out'*se
		if `nlev' == 2 {
			gen lb_in = b - `z_in'*se
			gen ub_in = b + `z_in'*se
		}
		gen p = 2*normal(-abs(b/se)) if se > 0 & !missing(se)
	}
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

* helper: pooled placebo = mean of Placebo_1..Placebo_maxpl in e(b), with SE from e(V)
program define _french_plot_pp, rclass
	version 16
	syntax , MAXpl(integer)
	tempname bb VV w bpl vpl
	matrix `bb' = e(b)
	matrix `VV' = e(V)
	local k = colsof(`bb')
	local cn : colnames `bb'
	matrix `w' = J(1,`k',0)
	local npl = 0
	forvalues c = 1/`k' {
		local nm : word `c' of `cn'
		if regexm("`nm'", "^[Pp]lacebo_?([0-9]+)$") {
			if real(regexs(1)) <= `maxpl' {
				matrix `w'[1,`c'] = 1
				local ++npl
			}
		}
	}
	if `npl' == 0 {
		di as error "no placebo coefficients found in e(b)"
		exit 198
	}
	matrix `w' = `w' / `npl'
	matrix `bpl' = `w' * `bb''
	matrix `vpl' = `w' * `VV' * `w''
	return scalar b  = `bpl'[1,1]
	return scalar se = sqrt(`vpl'[1,1])
	return scalar n  = `npl'
end
