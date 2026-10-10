*! csdid_event_plot 0.1.0  11oct2026  Jerg Gutmann
*! Event-study plot after csdid (estat event); same layout as french_plot, lpdid_plot and did2s_plot
program define csdid_event_plot, rclass
	version 16
	syntax , [ PRE(integer -999) POST(integer -999) ///
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

	* ---- source: results of estat event (kept in r()) or a fresh call of estat event ----
	tempname T BB VV
	local rcmd "`r(cmd)'"
	local ragg "`r(agg)'"
	cap matrix `T' = r(table)
	local rt = _rc
	cap matrix `BB' = r(bb)
	cap matrix `VV' = r(vv)
	if "`rcmd'" == "estat" & "`ragg'" == "event" & `rt' == 0 {
		di as text "csdid_event_plot: using the results of the preceding estat event"
	}
	else {
		di as text "csdid_event_plot: running estat event"
		if "`e(cmd)'" != "csdid" {
			di as error "last estimates not found; run csdid first"
			exit 301
		}
		cap qui estat event
		if _rc {
			di as error "estat event failed after csdid; run estat event manually to see the error"
			exit 198
		}
		cap matrix `T' = r(table)
		if _rc {
			di as error "r(table) not found after estat event"
			exit 301
		}
		cap matrix `BB' = r(bb)
		cap matrix `VV' = r(vv)
	}
	local ctb = rownumb(`T', "b")
	local cse = rownumb(`T', "se")
	local cpv = rownumb(`T', "pvalue")
	local cll = rownumb(`T', "ll")
	local cul = rownumb(`T', "ul")
	if `ctb' >= . | `cse' >= . {
		di as error "r(table) has no rows b and se"
		exit 198
	}

	* ---- checks and defaults ----
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

	* confidence intervals: those of csdid (estat event) unless normalci or level() is given
	local usel 1
	if "`normalci'" != "" | "`level'" != "" local usel 0
	if `usel' & (`cll' >= . | `cul' >= .) {
		local usel 0
	}
	local cireason
	if "`normalci'" != "" {
		local cireason "normalci specified"
	}
	else if "`level'" != "" {
		local cireason "level() specified"
	}
	if `cll' >= . | `cul' >= . {
		local cireason "r(table) has no ll/ul"
	}
	* normal intervals without level(): 95, the default level of csdid
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
		di as text "note: confidence intervals are b +/- z*se at the `lvtxt' and not those of estat event (`cireason')"
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

	* ---- event-time columns of r(table): Tm# (before treatment), Tp# (from treatment on) ----
	local cn : colnames `T'
	local M 0
	local j 0
	local cpa = .
	local cpb = .
	foreach nm of local cn {
		local ++j
		if "`nm'" == "Post_avg" local cpa = `j'
		if "`nm'" == "Pre_avg" local cpb = `j'
		if regexm("`nm'", "^T(m|p)([0-9]+)$") {
			local sgn = regexs(1)
			local kk  = real(regexs(2))
			local ++M
			local et_`M' = cond("`sgn'" == "m", -`kk', `kk')
			local ec_`M' = `j'
			local en_`M' "`nm'"
		}
	}
	if `M' == 0 {
		di as error "no event-time columns (Tm#, Tp#) found in r(table)"
		exit 111
	}
	local tmin = .
	local tmax = .
	local base_est 0
	forvalues m = 1/`M' {
		local tmin = min(`tmin', `et_`m'')
		local tmax = max(`tmax', `et_`m'')
		if `et_`m'' == -1 local base_est 1
	}
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

	if `base_est' == 0 {
		di as text "note: event time -1 is not estimated; plotted as zero baseline"
	}
	else {
		di as error "warning: event time -1 is estimated, i.e. the coefficients are not normalized to zero at t-1."
		di as error "         With csdid's default (short gaps) each pre-treatment effect uses the previous period as base. Option long2 in csdid"
		di as error "         uses period t-1 as universal base; please reconsider the specification."
	}
	local xend = cond(`base_est', -1, -2)

	* ---- averages of csdid (Pre_avg, Post_avg) ----
	local bavg  = .
	local seavg = .
	local pavg  = .
	local bpre  = .
	local sepre = .
	local ppre  = .
	if `cpa' < . {
		local bavg  = `T'[`ctb', `cpa']*`sc'
		local seavg = `T'[`cse', `cpa']*`sc'
		if `cpv' < . local pavg = `T'[`cpv', `cpa']
	}
	if `cpb' < . {
		local bpre  = `T'[`ctb', `cpb']*`sc'
		local sepre = `T'[`cse', `cpb']*`sc'
		if `cpv' < . local ppre = `T'[`cpv', `cpb']
	}
	if "`avg'" != "" & missing(`bavg') {
		di as error "Post_avg not available in r(table)"
		exit 198
	}
	if "`avgpre'" != "" & missing(`bpre') {
		di as error "Pre_avg not available in r(table)"
		exit 198
	}
	if `pre' < max(1, -`tmin') & ("`avgpre'" != "" | "`pvalues'" != "") {
		di as text "note: average placebo (Pre_avg) of csdid uses all pre-treatment periods, not only those shown"
	}
	if `post' < `tmax' & ("`avg'" != "" | "`pvalues'" != "") {
		di as text "note: average effect (Post_avg) of csdid uses all post-treatment periods, not only those shown"
	}

	* ---- joint Wald tests from r(bb) and r(vv), only if they match r(table) ----
	local jpre  = .
	local jpost = .
	local jok 0
	cap confirm matrix `VV'
	local c1 = _rc
	cap confirm matrix `BB'
	if !_rc & !`c1' {
		if rowsof(`VV') == `M' & colsof(`BB') == `M' {
			local jok 1
			forvalues m = 1/`M' {
				local dd = abs(sqrt(`VV'[`m',`m']) - `T'[`cse', `ec_`m''])
				local db = abs(`BB'[1,`m'] - `T'[`ctb', `ec_`m''])
				if `dd' > 1e-6 | `db' > 1e-6 local jok 0
			}
		}
	}
	if `jok' {
		local pcols
		local qcols
		local npc 0
		local nqc 0
		forvalues m = 1/`M' {
			if `et_`m'' >= -`pre' & `et_`m'' <= -1 {
				local pcols `pcols' `m'
				local ++npc
			}
			if `et_`m'' >= 0 & `et_`m'' <= `post' {
				local qcols `qcols' `m'
				local ++nqc
			}
		}
		if `npc' >= 2 {
			_csdid_event_plot_wald `BB' `VV' "`pcols'"
			local jpre = r(p)
		}
		if `nqc' >= 2 {
			_csdid_event_plot_wald `BB' `VV' "`qcols'"
			local jpost = r(p)
		}
	}
	else if "`pvalues'" != "" | "`pnote'" != "" {
		di as text "note: joint tests not available (r(bb), r(vv) missing or inconsistent with r(table), e.g. with wild bootstrap)"
	}

	if "`pvalues'" != "" {
		local sb : display string(`bavg', "`fmt'")
		local ss : display string(`seavg', "`fmt'")
		local sp : display string(`pavg', "`fmt'")
		local pb : display string(`bpre', "`fmt'")
		local ps : display string(`sepre', "`fmt'")
		local pp : display string(`ppre', "`fmt'")
		di as text _n "csdid_event_plot: summary of the plotted model"
		if `sc' != 1 di as text "(estimates multiplied by " as result `sc' as text ")"
		di as text "{hline 62}"
		di as text %-30s "" %10s "estimate" %10s "s.e." %10s "p-value"
		di as text "{hline 62}"
		if !missing(`bavg') di as text %-30s "Average effect" as result %10s "`sb'" %10s "`ss'" %10s "`sp'"
		if !missing(`bpre') di as text %-30s "Average placebo" as result %10s "`pb'" %10s "`ps'" %10s "`pp'"
		if !missing(`jpost') di as text %-30s "Joint test: all effects = 0" as result %30s string(`jpost', "`fmt'")
		if !missing(`jpre') di as text %-30s "Joint test: all placebos = 0" as result %30s string(`jpre', "`fmt'")
		di as text "{hline 62}"
	}

	* ---- data for the plot ----
	preserve
	qui {
		clear
		set obs `=`pre' + 1 + `post''
		gen x = _n - `pre' - 1
		gen eventtime = cond(x >= 0, x + 1, x)
		gen str8 type = cond(x <= -1, "placebo", "effect")
		gen str12 coefname = ""
		gen b  = .
		gen se = .
		gen double lpl = .
		gen double lph = .
		gen double lpp = .
		forvalues m = 1/`M' {
			local tt = `et_`m''
			if `tt' >= -`pre' & `tt' <= `post' {
				local i = `tt' + `pre' + 1
				local c = `ec_`m''
				replace coefname = "`en_`m''" in `i'
				replace b  = `sc'*`T'[`ctb', `c'] in `i'
				replace se = `sc'*`T'[`cse', `c'] in `i'
				if `usel' {
					replace lpl = `sc'*`T'[`cll', `c'] in `i'
					replace lph = `sc'*`T'[`cul', `c'] in `i'
				}
				if `cpv' < . replace lpp = `T'[`cpv', `c'] in `i'
			}
		}
		* event time -1 without estimate: zero baseline
		replace type = "baseline" if x == -1 & missing(b)
		replace b   = 0 if x == -1 & type == "baseline"
		replace se  = 0 if x == -1 & type == "baseline"
		replace lpl = 0 if x == -1 & type == "baseline"
		replace lph = 0 if x == -1 & type == "baseline"
		count if missing(b)
		local nmiss = r(N)
		if `usel' {
			gen lb = lpl
			gen ub = lph
			gen p = lpp
			if `cpv' >= . replace p = 2*normal(-abs(b/se)) if se > 0 & !missing(se)
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
			local nt "`nt'joint placebo test: p = `s3'"
		}
		if "`nt'" != "" local notecmd note("`nt'", size(small))
	}

	twoway `plots', xtitle("`xtitle'") ytitle("") xlabel(`xlab') `captions' `texts' `xsc' ///
		ylabel(`ylab', grid glcolor(gs14) glwidth(vthin)) ///
		`legend' `ytitlecmd' `notecmd' `options'

	if "`export'" != "" graph export "`export'", replace
	restore

	* pass the estat event results on, so that csdid_event_plot can be called repeatedly
	return local cmd "estat"
	return local agg "event"
	return matrix table = `T'
	cap return matrix bb = `BB'
	cap return matrix vv = `VV'
end

* joint Wald test that the selected coefficients (positions in r(bb)) are all zero
program define _csdid_event_plot_wald, rclass
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
