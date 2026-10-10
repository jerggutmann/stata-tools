*! did2s_plot 0.1.0  11oct2026  Jerg Gutmann
*! Event-study plot after did2s; same layout as french_plot and lpdid_plot
program define did2s_plot
	version 16
	syntax , [ EVENTVAR(string) SHIFT(integer 0) LEAD(string) LAG(string) ///
		PRE(integer -999) POST(integer -999) ///
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
	if "`e(cmd)'" != "did2s" {
		di as error "last estimates not found; run did2s first"
		exit 301
	}
	if "`eventvar'" == "" & "`lead'" == "" & "`lag'" == "" {
		di as error "specify eventvar() or lead() and/or lag()"
		exit 198
	}
	if "`eventvar'" != "" & ("`lead'" != "" | "`lag'" != "") {
		di as error "eventvar() cannot be combined with lead() or lag()"
		exit 198
	}
	if `pre' != -999 & `pre' < 1 {
		di as error "pre() must be at least 1"
		exit 198
	}
	if `post' != -999 & `post' < 0 {
		di as error "post() must be 0 or larger"
		exit 198
	}
	if "`ylab'" != "" & `tpos' == -99999 {
		di as error "if you set ylab() you must also set tpos()"
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

	* confidence intervals are normal-based (did2s reports z-based intervals)
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

	* ---- map the coefficients of e(b) to event time ----
	tempname B V
	matrix `B' = e(b)
	matrix `V' = e(V)
	local K = colsof(`B')
	local cn : colnames `B'

	* templates for lead()/lag(): split at "#"
	foreach w in lead lag {
		if "``w''" != "" {
			local p = strpos("``w''", "#")
			local rest = substr("``w''", `p' + 1, .)
			if `p' == 0 | strpos("`rest'", "#") > 0 {
				di as error "`w'() must contain exactly one #"
				exit 198
			}
			local `w'_a = substr("``w''", 1, `p' - 1)
			local `w'_b "`rest'"
			local `w'_re = subinstr("``w'_a'", ".", "\.", .)
		}
	}

	local M 0
	local j 0
	foreach nm of local cn {
		local ++j
		local omit 0
		local t = .
		if "`eventvar'" != "" {
			* factor-variable coefficients: <level>[b|o|bn|...].<eventvar>
			if regexm("`nm'", "^([0-9]+)(b|bn|o|bno|on|n)?\.") {
				local lev = regexs(1)
				local sfx = regexs(2)
				local rest = substr("`nm'", strpos("`nm'", ".") + 1, .)
				if "`rest'" == "`eventvar'" {
					local t = `lev' - `shift'
					if inlist("`sfx'", "b", "bn", "o", "bno", "on") local omit 1
				}
			}
		}
		else {
			local nm2 "`nm'"
			local om 0
			if substr("`nm'", 1, 2) == "o." {
				local nm2 = substr("`nm'", 3, .)
				local om 1
			}
			foreach w in lead lag {
				if "``w''" != "" & missing(`t') {
					if regexm("`nm2'", "^``w'_re'([0-9]+)") {
						local lev = regexs(1)
						if "`nm2'" == "``w'_a'`lev'``w'_b'" {
							local t = cond("`w'" == "lead", -`lev', `lev')
							local omit `om'
						}
					}
				}
			}
		}
		if !missing(`t') {
			local ++M
			local et_`M' = `t'
			local ec_`M' = `j'
			local eo_`M' = `omit'
			local en_`M' "`nm'"
		}
	}
	if `M' == 0 {
		di as error "no coefficient in e(b) matches the specification"
		exit 111
	}

	* span of the estimated coefficients; omitted/base categories outside it are dropped
	local tmin = .
	local tmax = .
	forvalues m = 1/`M' {
		if `eo_`m'' == 0 {
			local tmin = min(`tmin', `et_`m'')
			local tmax = max(`tmax', `et_`m'')
		}
	}
	if missing(`tmin') {
		di as error "no estimated (non-omitted) coefficient matches the specification"
		exit 111
	}
	forvalues m = 1/`M' {
		local tt = `et_`m''
		forvalues n = `=`m'+1'/`M' {
			if `et_`n'' == `tt' {
				di as error "event time `tt' is matched by more than one coefficient (`en_`m'', `en_`n'')"
				exit 198
			}
		}
		if `eo_`m'' == 1 & (`tt' < `tmin' | `tt' > `tmax') local eo_`m' 2
	}

	* window: pre(U) = earliest event time -U; post(T) = event times 0..T
	if `pre' == -999 local pre = max(1, -`tmin')
	if `post' == -999 {
		if `tmax' < 0 {
			di as error "no post-treatment coefficient found; specify post()"
			exit 198
		}
		local post = `tmax'
	}
	* same bookkeeping as french_plot and lpdid_plot
	local showplacebo = `pre' - 1
	local showeffects = `post' + 1

	* mapping table
	di as text _n "did2s_plot: coefficients used"
	di as text "{hline 62}"
	di as text %-30s "coefficient" %12s "event time" %-20s "  status"
	di as text "{hline 62}"
	local precols
	local postcols
	local npre 0
	local npost 0
	forvalues m = 1/`M' {
		local tt = `et_`m''
		local stat "estimated"
		if `eo_`m'' == 1 local stat "base (zero)"
		if `eo_`m'' == 2 local stat "base (not used)"
		if `tt' < -`pre' | `tt' > `post' local stat "not shown"
		di as text %-30s "`en_`m''" as result %12.0f `tt' as text %-20s "  `stat'"
		if "`stat'" == "estimated" {
			if `tt' <= -1 {
				local precols `precols' `ec_`m''
				local ++npre
			}
			else {
				local postcols `postcols' `ec_`m''
				local ++npost
			}
		}
	}
	di as text "{hline 62}"
	local base_est = 0
	forvalues m = 1/`M' {
		if `et_`m'' == -1 & `eo_`m'' == 0 local base_est = 1
	}
	if `base_est' == 0 {
		di as text "note: event time -1 is not estimated; plotted as zero baseline"
	}
	else {
		di as error "warning: event time -1 is estimated, i.e. the coefficients are not normalized to zero at t-1."
		di as error "         The plot shows the estimate as it is. Please reconsider the specification (the omitted reference period should be t-1)."
	}
	local xend = cond(`base_est', -1, -2)

	if "`avg'" != "" & `npost' == 0 {
		di as error "avg requires at least one estimated post-treatment coefficient in the window"
		exit 198
	}
	if "`avgpre'" != "" & `npre' == 0 {
		di as error "avgpre requires at least one estimated pre-treatment coefficient in the window"
		exit 198
	}

	* equal-weighted averages and joint Wald tests (unscaled), from e(b) and e(V)
	local bavg  = .
	local seavg = .
	local pavg  = .
	local bpre  = .
	local sepre = .
	local ppre  = .
	local jpre  = .
	local jpost = .
	tempname W mm vv
	if `npost' > 0 {
		matrix `W' = J(1, `K', 0)
		foreach c of local postcols {
			matrix `W'[1, `c'] = 1/`npost'
		}
		matrix `mm' = `W'*`B''
		matrix `vv' = `W'*`V'*`W''
		local bavg  = `mm'[1,1]
		local seavg = sqrt(`vv'[1,1])
		if `seavg' > 0 local pavg = 2*normal(-abs(`bavg'/`seavg'))
		local bavg  = `bavg'*`sc'
		local seavg = `seavg'*`sc'
		_did2s_plot_wald `B' `V' "`postcols'"
		local jpost = r(p)
		local cpost = r(chi2)
		local dpost = r(df)
	}
	if `npre' > 0 {
		matrix `W' = J(1, `K', 0)
		foreach c of local precols {
			matrix `W'[1, `c'] = 1/`npre'
		}
		matrix `mm' = `W'*`B''
		matrix `vv' = `W'*`V'*`W''
		local bpre  = `mm'[1,1]
		local sepre = sqrt(`vv'[1,1])
		if `sepre' > 0 local ppre = 2*normal(-abs(`bpre'/`sepre'))
		local bpre  = `bpre'*`sc'
		local sepre = `sepre'*`sc'
		if `npre' >= 2 {
			_did2s_plot_wald `B' `V' "`precols'"
			local jpre = r(p)
			local cpre = r(chi2)
			local dpre = r(df)
		}
	}
	if "`avg'" != "" | "`avgpre'" != "" | "`pvalues'" != "" {
		di as text "note: averages are equal-weighted means of the plotted coefficients, not the did2s average treatment effect"
	}

	if "`pvalues'" != "" {
		di as text _n "did2s_plot: summary of the plotted model"
		if `sc' != 1 di as text "(estimates multiplied by " as result `sc' as text ")"
		di as text "{hline 62}"
		di as text %-30s "" %10s "estimate" %10s "s.e." %10s "p-value"
		di as text "{hline 62}"
		if `npost' > 0 {
			local s1 : display string(`bavg', "`fmt'")
			local s2 : display string(`seavg', "`fmt'")
			local s3 : display string(`pavg', "`fmt'")
			di as text %-30s "Average effect" as result %10s "`s1'" %10s "`s2'" %10s "`s3'"
		}
		if `npre' >= 2 {
			local s1 : display string(`bpre', "`fmt'")
			local s2 : display string(`sepre', "`fmt'")
			local s3 : display string(`ppre', "`fmt'")
			di as text %-30s "Average placebo" as result %10s "`s1'" %10s "`s2'" %10s "`s3'"
		}
		di as text "{hline 62}"
		if `npre' >= 2 & !missing(`jpre') {
			local s1 : display string(`cpre', "%7.2f")
			local s2 : display string(`jpre', "`fmt'")
			di as text "Joint test, pre-treatment (`npre' coef.): chi2(" as result `dpre' as text ") = " as result "`s1'" as text ", p = " as result "`s2'"
		}
		if `npost' >= 2 & !missing(`jpost') {
			local s1 : display string(`cpost', "%7.2f")
			local s2 : display string(`jpost', "`fmt'")
			di as text "Joint test, post-treatment (`npost' coef.): chi2(" as result `dpost' as text ") = " as result "`s1'" as text ", p = " as result "`s2'"
		}
	}

	* ---- data for the plot ----
	preserve
	qui {
		clear
		set obs `=`pre' + 1 + `post''
		gen x = _n - `pre' - 1
		gen eventtime = x
		gen str8 type = cond(x <= -1, "placebo", "effect")
		gen str60 coef = ""
		gen b  = .
		gen se = .
		gen byte est = 0
		forvalues m = 1/`M' {
			local tt = `et_`m''
			if `tt' >= -`pre' & `tt' <= `post' & `eo_`m'' < 2 {
				local i = `tt' + `pre' + 1
				replace coef = "`en_`m''" in `i'
				if `eo_`m'' == 0 {
					replace b   = `sc'*`B'[1, `ec_`m''] in `i'
					replace se  = `sc'*sqrt(`V'[`ec_`m'', `ec_`m'']) in `i'
					replace est = 1 in `i'
				}
				else {
					replace b  = 0 in `i'
					replace se = 0 in `i'
				}
			}
		}
		* event time -1 without estimate: zero baseline
		replace type = "baseline" if x == -1 & est == 0
		replace b  = 0 if x == -1 & est == 0
		replace se = 0 if x == -1 & est == 0
		count if missing(b)
		local nmiss = r(N)
		gen lb = b - `z_out'*se
		gen ub = b + `z_out'*se
		if `nlev' == 2 {
			gen lb_in = b - `z_in'*se
			gen ub_in = b + `z_in'*se
		}
		gen p = 2*normal(-abs(b/se)) if se > 0 & !missing(se)
		drop est
	}
	if `nmiss' > 0 di as text "note: `nmiss' plotted event time(s) without coefficient; shown as gaps"
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
		local plots `plots' (pci `bpre' `xmin' `bpre' `xend', lcolor("`precolor'") lpattern(`prelpattern') lwidth(medthick))
		local ++k
		local order `order' `k' "`lblpre'"
		local plots `plots' (scatteri `bpre' `xmin', msymbol(circle_hollow) mcolor("`precolor'"))
		local plots `plots' (scatteri `bpre' `xend', msymbol(circle_hollow) mcolor("`precolor'"))
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
		if !missing(`jpre') {
			local s3 : display string(`jpre', "`fmt'")
			if "`nt'" != "" local nt "`nt'; "
			local nt "`nt'joint test of pre-treatment coefficients: p = `s3'"
		}
		if "`nt'" != "" local notecmd note("`nt'", size(small))
	}

	twoway `plots', xtitle("`xtitle'") ytitle("") xlabel(`xlab') `captions' `texts' `xsc' ///
		ylabel(`ylab', grid glcolor(gs14) glwidth(vthin)) ///
		`legend' `ytitlecmd' `notecmd' `options'

	if "`export'" != "" graph export "`export'", replace
	restore
end

* joint Wald test that the selected coefficients (columns) are all zero
program define _did2s_plot_wald, rclass
	args B V cols
	local n : word count `cols'
	tempname S bs Vs Vi q
	matrix `S' = J(`n', colsof(`B'), 0)
	local i 0
	foreach c of local cols {
		local ++i
		matrix `S'[`i', `c'] = 1
	}
	matrix `bs' = `S'*`B''
	matrix `Vs' = `S'*`V'*`S''
	matrix `Vi' = invsym(`Vs')
	matrix `q'  = `bs''*`Vi'*`bs'
	local df = `n' - diag0cnt(`Vi')
	return scalar chi2 = `q'[1,1]
	return scalar df   = `df'
	if `df' > 0 return scalar p = chi2tail(`df', `q'[1,1])
	else return scalar p = .
end
