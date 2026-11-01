*! did2s_plot 0.3.3  12oct2026  Jerg Gutmann
*! Event-study plot after did2s; same layout as dcdh_plot and lpdid_plot; optional post-treatment block and standard-deviation units
program define did2s_plot
	version 16
	syntax , [ EVENTVAR(string) SHIFT(integer 0) LEAD(string) LAG(string) AFTER(string) NAFter(integer -999) ///
		PRE(integer -999) POST(integer -999) ///
		AVG AVGPre AVGAfter AVGValues PVAlues PNOte ///
		NOCI CIBars NORMalci LEvel(string) CIOpacity(integer 20) ///
		SHADE SHADEColor(string) VLINE ///
		SCale(real 1) PCTof(real 0) SDOF(string) WIThin Y(varname) TREATment(varname) ID(varname) TIME(varname) SDIF(string asis) ///
		COLor(string) AVGColor(string) PRECOLor(string) AFTERCOLor(string) MSymbol(string) ///
		LPAttern(string) LWidth(string) AVGLPattern(string) PRELPattern(string) AFTERLPattern(string) ///
		NOZero NOCAPtions PRECAPtion(string) POSTCAPtion(string) AFTERCAPtion(string) NOLEGend ///
		LBLDyn(string) LBLAvg(string) LBLPre(string) LBLAfter(string) ///
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
	if "`after'" != "" & "`eventvar'" != "" {
		di as error "after() cannot be combined with eventvar(); it requires the dummy-variable templates lead() and/or lag()"
		exit 198
	}
	if "`after'" != "" & "`lead'" == "" & "`lag'" == "" {
		di as error "after() requires lead() and/or lag()"
		exit 198
	}
	if "`after'" == "" & (`nafter' != -999 | "`avgafter'" != "") {
		di as error "nafter() and avgafter require after()"
		exit 198
	}
	if `nafter' != -999 & `nafter' < 1 {
		di as error "nafter() must be at least 1"
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
	if "`avgvalues'" != "" & "`nolegend'" != "" & "`after'" != "" {
		di as error "avgvalues cannot be combined with nolegend when after() is used; the values are shown in the legend"
		exit 198
	}
	if "`ylab'" != "" & `tpos' == -99999 {
		di as error "if you set ylab() you must also set tpos()"
		exit 198
	}
	if "`avgvalues'" != "" & "`avg'" == "" & "`avgpre'" == "" & "`avgafter'" == "" {
		di as error "avgvalues requires avg, avgpre and/or avgafter"
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
	if "`sdof'" != "" {
		if !inlist("`sdof'", "sample", "untreated", "nyt") {
			di as error "sdof() must be sample, untreated or nyt"
			exit 198
		}
		if `pctof' != 0 | `scale' != 1 {
			di as error "sdof() cannot be combined with scale() or pctof()"
			exit 198
		}
		if ("`sdof'" == "nyt" | "`within'" != "") & ("`id'" == "" | "`time'" == "") {
			di as error "sdof(nyt) and within require id() and time()"
			exit 198
		}
	}
	else if "`within'" != "" {
		di as error "within requires sdof()"
		exit 198
	}
	if "`sdof'" == "" & ("`y'`treatment'`id'`time'" != "" | `"`sdif'"' != "") {
		di as error "y(), treatment(), id(), time() and sdif() are only used with sdof()"
		exit 198
	}
	local sc = `scale'
	if `pctof' != 0 local sc = 100/`pctof'
	if "`sdof'" != "" {
		local sdopts mode(`sdof') `within'
		if "`y'" != "" local sdopts `sdopts' y(`y')
		if "`treatment'" != "" local sdopts `sdopts' treat(`treatment')
		if "`id'" != "" local sdopts `sdopts' id(`id')
		if "`time'" != "" local sdopts `sdopts' time(`time')
		if `"`sdif'"' != "" local sdopts `sdopts' sdif(`sdif')
		_did2s_plot_sd, `sdopts'
		local sdv = r(sd)
		local sdn = r(N)
		local sdy "`r(yvar)'"
		local sdw = r(weighted)
		local sc = 1/`sdv'
		local sdtxt = cond("`sdof'" == "sample", "all observations of the did2s sample", ///
			cond("`sdof'" == "untreated", "the untreated observations (treatment = 0) of the did2s sample", ///
			"the never- and not-yet-treated observations of the did2s sample"))
		di as text "note: estimates are divided by the standard deviation of `sdy' in `sdtxt'"
		if `"`sdif'"' != "" di as text `"      restricted by sdif(): `sdif'"'
		if "`within'" != "" di as text "      after removing unit and time means (within standard deviation)"
		di as text "      standard deviation = " as result %9.4g `sdv' as text ", N = " as result `sdn'
		if `sdw' == 1 di as text "      did2s used weights; the standard deviation is unweighted"
	}

	* confidence intervals are normal-based (did2s displays z-based intervals but does not store them)
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
	if "`noci'" == "" {
		local lvtxt = cond(`nlev' == 2, "`lev_in'/`lev_out'% levels", "`lev_out'% level")
		di as text "note: confidence intervals are b +/- z*se at the `lvtxt' (did2s does not store its intervals;"
		di as text "      they are identical to the displayed ones at the same level, computed from e(b) and e(V))"
	}

	if "`color'" == "" local color "0 114 178"
	if "`avgcolor'" == "" local avgcolor "`color'"
	if "`precolor'" == "" local precolor "`avgcolor'"
	if "`shadecolor'" == "" local shadecolor "gs12"
	if "`msymbol'" == "" local msymbol o
	if "`avglpattern'" == "" local avglpattern dash
	if "`prelpattern'" == "" local prelpattern shortdash
	if "`aftercolor'" == "" local aftercolor "`avgcolor'"
	if "`afterlpattern'" == "" local afterlpattern longdash_dot
	if "`lbldyn'" == "" local lbldyn "dynamic effect"
	if "`lblavg'" == "" local lblavg "average effect"
	if "`lblpre'" == "" local lblpre "average placebo"
	if "`lblafter'" == "" local lblafter "average post-treatment effect"
	if "`precaption'" == "" local precaption "pre-treatment"
	if "`postcaption'" == "" local postcaption = cond("`after'" != "", "treatment", "post-treatment")
	if "`aftercaption'" == "" local aftercaption "post-treatment"
	if "`fmt'" == "" local fmt "%5.3f"

	* ---- map the coefficients of e(b) to event time ----
	tempname B V
	matrix `B' = e(b)
	matrix `V' = e(V)
	local K = colsof(`B')
	local cn : colnames `B'

	* templates for lead()/lag(): split at "#"
	foreach w in lead lag after {
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
		local kd 0
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
			foreach w in lead lag after {
				if "``w''" != "" & missing(`t') {
					if regexm("`nm2'", "^``w'_re'([0-9]+)") {
						local lev = regexs(1)
						if "`nm2'" == "``w'_a'`lev'``w'_b'" {
							local t = cond("`w'" == "lead", -`lev', `lev')
							local omit `om'
							if "`w'" == "after" local kd 1
						}
					}
				}
			}
			* after(): P0 is not a post-treatment period
			if `kd' == 1 & `t' < 1 local t = .
		}
		if !missing(`t') {
			local ++M
			local et_`M' = `t'
			local ec_`M' = `j'
			local eo_`M' = `omit'
			local ek_`M' = `kd'
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
	local amax = .
	forvalues m = 1/`M' {
		if `eo_`m'' == 0 {
			if `ek_`m'' == 0 {
				local tmin = min(`tmin', `et_`m'')
				local tmax = max(`tmax', `et_`m'')
			}
			else {
				local amax = max(`amax', `et_`m'')
			}
		}
	}
	if missing(`tmin') {
		di as error "no estimated (non-omitted) coefficient matches the specification"
		exit 111
	}
	if "`after'" != "" & missing(`amax') {
		di as error "no estimated (non-omitted) coefficient matches after()"
		exit 111
	}
	forvalues m = 1/`M' {
		local tt = `et_`m''
		forvalues n = `=`m'+1'/`M' {
			if `et_`n'' == `tt' & `ek_`n'' == `ek_`m'' {
				di as error "event time `tt' is matched by more than one coefficient (`en_`m'', `en_`n'')"
				exit 198
			}
		}
		if `eo_`m'' == 1 & `ek_`m'' == 0 & (`tt' < `tmin' | `tt' > `tmax') local eo_`m' 2
		if `eo_`m'' == 1 & `ek_`m'' == 1 & `tt' > `amax' local eo_`m' 2
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
	* same bookkeeping as dcdh_plot and lpdid_plot
	local showplacebo = `pre' - 1
	local showeffects = `post' + 1
	* after(): post-treatment periods 1..nA (default: all matched)
	local nA 0
	if "`after'" != "" {
		local nA = `amax'
		if `nafter' != -999 local nA = `nafter'
	}

	* mapping table
	di as text _n "did2s_plot: coefficients used"
	di as text "{hline 78}"
	di as text %-30s "coefficient" %12s "event time" %-16s "  block" %-20s "  status"
	di as text "{hline 78}"
	local blpost = cond("`after'" != "", "treatment", "post-treatment")
	local precols
	local postcols
	local aftercols
	local npre 0
	local npost 0
	local nafe 0
	forvalues m = 1/`M' {
		local tt = `et_`m''
		local stat "estimated"
		if `eo_`m'' == 1 local stat "base (zero)"
		if `eo_`m'' == 2 local stat "base (not used)"
		if `ek_`m'' == 0 & (`tt' < -`pre' | `tt' > `post') local stat "not shown"
		if `ek_`m'' == 1 & `tt' > `nA' local stat "not shown"
		local ts "`tt'"
		local bl "pre-treatment"
		if `ek_`m'' == 1 {
			local ts "+`tt'"
			local bl "post-treatment"
		}
		else if `tt' >= 0 {
			local bl "`blpost'"
		}
		if `eo_`m'' != 2 di as text %-30s "`en_`m''" as result %12s "`ts'" as text %-16s "  `bl'" %-20s "  `stat'"
		if "`stat'" == "estimated" {
			if `ek_`m'' == 1 {
				local aftercols `aftercols' `ec_`m''
				local ++nafe
			}
			else if `tt' <= -1 {
				local precols `precols' `ec_`m''
				local ++npre
			}
			else {
				local postcols `postcols' `ec_`m''
				local ++npost
			}
		}
	}
	di as text "{hline 78}"
	local base_est = 0
	forvalues m = 1/`M' {
		if `et_`m'' == -1 & `eo_`m'' == 0 & `ek_`m'' == 0 local base_est = 1
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
		di as error "avg requires at least one estimated `blpost' coefficient in the window"
		exit 198
	}
	if "`avgafter'" != "" & `nafe' == 0 {
		di as error "avgafter requires at least one estimated post-treatment coefficient in the window"
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
	local bafter  = .
	local seafter = .
	local pafter  = .
	local jafter  = .
	tempname W mm vv
	if `nafe' > 0 {
		matrix `W' = J(1, `K', 0)
		foreach c of local aftercols {
			matrix `W'[1, `c'] = 1/`nafe'
		}
		matrix `mm' = `W'*`B''
		matrix `vv' = `W'*`V'*`W''
		local bafter  = `mm'[1,1]
		local seafter = sqrt(`vv'[1,1])
		if `seafter' > 0 local pafter = 2*normal(-abs(`bafter'/`seafter'))
		local bafter  = `bafter'*`sc'
		local seafter = `seafter'*`sc'
		_did2s_plot_wald `B' `V' "`aftercols'"
		local jafter = r(p)
	}
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
	if "`avg'" != "" | "`avgpre'" != "" | "`avgafter'" != "" | "`pvalues'" != "" {
		di as text "note: averages are equal-weighted means of the plotted coefficients, not the did2s average treatment effect"
	}

	if "`pvalues'" != "" {
		di as text _n "did2s_plot: summary of the plotted model"
		if "`sdof'" != "" di as text "(estimates in standard deviations of the outcome)"
		else if `sc' != 1 di as text "(estimates multiplied by " as result `sc' as text ")"
		di as text "{hline 62}"
		di as text %-30s "" %10s "estimate" %10s "s.e." %10s "p-value"
		di as text "{hline 62}"
		local lavg  "Average effect"
		local ljoint "Joint test: all effects = 0"
		if `nA' > 0 {
			local lavg  "Average effect: treatment"
			local ljoint "Joint test: treatment = 0"
		}
		if `npost' > 0 {
			local s1 : display string(`bavg', "`fmt'")
			local s2 : display string(`seavg', "`fmt'")
			local s3 : display string(`pavg', "`fmt'")
			di as text %-30s "`lavg'" as result %10s "`s1'" %10s "`s2'" %10s "`s3'"
		}
		if `nafe' > 0 {
			local s1 : display string(`bafter', "`fmt'")
			local s2 : display string(`seafter', "`fmt'")
			local s3 : display string(`pafter', "`fmt'")
			di as text %-30s "Average effect: post-treatment" as result %10s "`s1'" %10s "`s2'" %10s "`s3'"
		}
		if `npre' >= 2 {
			local s1 : display string(`bpre', "`fmt'")
			local s2 : display string(`sepre', "`fmt'")
			local s3 : display string(`ppre', "`fmt'")
			di as text %-30s "Average placebo" as result %10s "`s1'" %10s "`s2'" %10s "`s3'"
		}
		if !missing(`jpost') di as text %-30s "`ljoint'" as result %30s string(`jpost', "`fmt'")
		if !missing(`jafter') di as text %-30s "Joint test: post-treatment = 0" as result %30s string(`jafter', "`fmt'")
		if !missing(`jpre') di as text %-30s "Joint test: all placebos = 0" as result %30s string(`jpre', "`fmt'")
		di as text "{hline 62}"
	}

	* ---- data for the plot ----
	preserve
	qui {
		clear
		set obs `=`pre' + 1 + `post' + `nA''
		gen x = _n - `pre' - 1
		gen eventtime = cond(x >= 0, x + 1, x)
		gen str8 type = cond(x <= -1, "placebo", "effect")
		if `nA' > 0 {
			replace eventtime = x - `post' if x > `post'
			replace type = "after" if x > `post'
		}
		gen str60 coefname = ""
		gen b  = .
		gen se = .
		gen byte est = 0
		forvalues m = 1/`M' {
			local tt = `et_`m''
			local i = .
			if `ek_`m'' == 0 & `tt' >= -`pre' & `tt' <= `post' local i = `tt' + `pre' + 1
			if `ek_`m'' == 1 & `tt' >= 1 & `tt' <= `nA' local i = `pre' + 1 + `post' + `tt'
			if !missing(`i') & `eo_`m'' < 2 {
				replace coefname = "`en_`m''" in `i'
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
	if `nmiss' > 0 di as text "note: `nmiss' plotted event time(s) have no estimate; shown as gaps"
	if "`savedata'" != "" {
		qui save "`savedata'", replace
		di as text "plotted data saved to `savedata'"
	}
	* empty row at x = post+0.5 breaks lines and bands between the two blocks
	if `nA' > 0 {
		qui set obs `=_N + 1'
		qui replace x = `post' + 0.5 in `=_N'
		qui sort x
	}

	* ---- axis geometry ----
	local x0   = 0
	local x1   = `showeffects' - 1
	local xmax = `x1'
	local xa0  = `x1' + 1
	local tx3  = .
	if `nA' > 0 {
		local xmax = `x1' + `nA'
		local tx3  = (`xa0' + `xmax')/2
	}
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
	forvalues k = 1/`nA' {
		local xlab `xlab' `=`x1'+`k'' "+`k'"
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
	if "`avgafter'" != "" local yv `yv' `bafter'
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
		if `nA' > 0 {
			local plots `plots' (pci `lo2' `=`x1'+0.5' `hi2' `=`x1'+0.5', lcolor(gs8) lpattern(dash))
			local ++k
		}
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
		local plots `plots' (pci 0 `xmin' 0 `xmax', lcolor(gs8) lpattern(solid))
		local ++k
	}
	local texts
	local xsc
	if "`avg'" != "" {
		local plots `plots' (pci `bavg' `x0' `bavg' `x1', lcolor("`avgcolor'") lpattern(`avglpattern') lwidth(medthick))
		local ++k
		local lab "`lblavg'"
		if "`avgvalues'" != "" & `nA' > 0 {
			local s : display string(`bavg', "`fmt'")
			local lab "`lab' (`s')"
		}
		local order `order' `k' "`lab'"
		local plots `plots' (scatteri `bavg' `x0', msymbol(circle_hollow) mcolor("`avgcolor'"))
		local plots `plots' (scatteri `bavg' `x1', msymbol(circle_hollow) mcolor("`avgcolor'"))
		local k = `k' + 2
		if "`avgvalues'" != "" & `nA' == 0 {
			local s : display string(`bavg', "`fmt'")
			local texts `texts' text(`bavg' `=`x1'+0.2' "`s'", place(e) size(small) color("`avgcolor'"))
		}
	}
	if "`avgafter'" != "" {
		local plots `plots' (pci `bafter' `xa0' `bafter' `xmax', lcolor("`aftercolor'") lpattern(`afterlpattern') lwidth(medthick))
		local ++k
		local lab "`lblafter'"
		if "`avgvalues'" != "" {
			local s : display string(`bafter', "`fmt'")
			local lab "`lab' (`s')"
		}
		local order `order' `k' "`lab'"
		local plots `plots' (scatteri `bafter' `xa0', msymbol(circle_hollow) mcolor("`aftercolor'"))
		local plots `plots' (scatteri `bafter' `xmax', msymbol(circle_hollow) mcolor("`aftercolor'"))
		local k = `k' + 2
	}
	if "`avgpre'" != "" {
		local plots `plots' (pci `bpre' `xmin' `bpre' `xend', lcolor("`precolor'") lpattern(`prelpattern') lwidth(medthick))
		local ++k
		local lab "`lblpre'"
		if "`avgvalues'" != "" & `nA' > 0 {
			local s : display string(`bpre', "`fmt'")
			local lab "`lab' (`s')"
		}
		local order `order' `k' "`lab'"
		local plots `plots' (scatteri `bpre' `xmin', msymbol(circle_hollow) mcolor("`precolor'"))
		local plots `plots' (scatteri `bpre' `xend', msymbol(circle_hollow) mcolor("`precolor'"))
		local k = `k' + 2
		if "`avgvalues'" != "" & `nA' == 0 {
			local s : display string(`bpre', "`fmt'")
			local texts `texts' text(`bpre' `=`xmin'-0.2' "`s'", place(w) size(small) color("`precolor'"))
		}
	}
	if "`avgvalues'" != "" & `nA' == 0 {
		local xl = `xmin' - 0.5
		if "`avgpre'" != "" local xl = `xmin' - 1.5
		local xsc xscale(range(`xl' `=`xmax'+1.5'))
	}

	local legend legend(off)
	if ("`avg'" != "" | "`avgpre'" != "" | "`avgafter'" != "") & "`nolegend'" == "" {
		local legend legend(order(`order') rows(`=1 + (`nA' > 0)') position(6))
	}
	local captions
	if "`nocaptions'" == "" {
		local captions text(`tpos' `tx1' "`precaption'", size(small)) text(`tpos' `tx2' "`postcaption'", size(small))
		if `nA' > 0 local captions `captions' text(`tpos' `tx3' "`aftercaption'", size(small))
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
		if !missing(`pafter') {
			local s1 : display string(`bafter', "`fmt'")
			local s2 : display string(`pafter', "`fmt'")
			if "`nt'" != "" local nt "`nt'; average post-treatment effect: `s1' (p = `s2')"
			else local nt "Average post-treatment effect: `s1' (p = `s2')"
		}
		if !missing(`jpre') {
			local s3 : display string(`jpre', "`fmt'")
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

* standard deviation of the did2s outcome in the selected sample (data in memory are not changed)
program define _did2s_plot_sd, rclass
	syntax , MODE(string) [ Y(string) TREAT(string) ID(string) TIME(string) WITHIN SDIF(string asis) ]
	local cl `"`e(cmdline)'"'
	local yv "`y'"
	if "`yv'" == "" gettoken yv : cl, parse(" ,")
	capture confirm numeric variable `yv'
	if _rc {
		di as error "outcome variable `yv' of did2s not found; sdof() needs the data used by did2s (or specify y())"
		exit 111
	}
	if regexm(`"`cl'"', "(^|[ ,])unit[(]") {
		di as error "sdof() cannot be used if did2s was run with unit(): did2s then replaces the outcome in memory"
		exit 198
	}
	local yname "`yv'"
	local wt = regexm(`"`cl'"', "[[][aipf]w[a-z]* *=")
	if "`mode'" != "sample" {
		local tv "`treat'"
		if "`tv'" == "" {
			if !regexm(`"`cl'"', "(^|[ ,])[Tt][Rr][Ee][Aa][Tt][A-Za-z]*[(]([^)]+)[)]") {
				di as error "treatment() not found in e(cmdline); specify treatment()"
				exit 111
			}
			local tv = strtrim(regexs(2))
		}
		capture confirm numeric variable `tv'
		if _rc {
			di as error "treatment variable `tv' of did2s not found"
			exit 111
		}
	}
	preserve
	qui keep if e(sample)
	if `"`sdif'"' != "" {
		capture qui keep if (`sdif')
		if _rc {
			di as error `"sdif() is not a valid condition: `sdif'"'
			exit 198
		}
	}
	if "`mode'" == "untreated" {
		qui keep if `tv' == 0
	}
	if "`mode'" == "nyt" {
		tempvar first
		qui bysort `id': egen double `first' = min(cond(`tv' == 1, `time', .))
		qui keep if `tv' == 0 & (`time' < `first' | missing(`first'))
	}
	if "`within'" != "" {
		* remove unit and time means alternately until they vanish (exact also in unbalanced panels);
		* no estimation command is used, so the results of did2s in e() stay untouched
		tempvar res m1 m2
		qui gen double `res' = `yv'
		local diff = 1
		local it = 0
		while `diff' > 1e-10 & `it' < 5000 {
			local ++it
			qui bysort `id': egen double `m1' = mean(`res')
			qui replace `res' = `res' - `m1'
			qui bysort `time': egen double `m2' = mean(`res')
			qui replace `res' = `res' - `m2'
			qui summarize `m1', meanonly
			local diff = max(abs(r(min)), abs(r(max)))
			qui summarize `m2', meanonly
			local diff = max(`diff', abs(r(min)), abs(r(max)))
			if missing(`diff') local diff = 0
			drop `m1' `m2'
		}
		if `diff' > 1e-10 {
			di as error "within: unit and time means did not converge"
			exit 430
		}
		local yv `res'
	}
	qui summarize `yv'
	if r(N) < 2 | missing(r(sd)) | r(sd) <= 0 {
		di as error "the standard deviation of `yname' in the selected sample is zero or cannot be computed"
		exit 498
	}
	return scalar sd = r(sd)
	return scalar N = r(N)
	return scalar weighted = `wt'
	return local yvar "`yname'"
end
