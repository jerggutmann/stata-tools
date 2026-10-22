*! dcdh_compare 0.2.0  23oct2026  Jerg Gutmann
*! Runs two did_multiplegt_dyn models and plots both event studies in the layout of dcdh_plot
program define dcdh_compare, rclass
	version 16

	* ---- split the call into model 1, model 2 and the plot options ----
	local synerr "syntax: dcdh_compare (Y G T D [if] [in] [, options]) (Y G T D [if] [in] [, options]) [, plot_options]"
	local hasmodels = substr(strtrim(`"`0'"'), 1, 1) == "("
	local rest `"`0'"'
	if `hasmodels' {
		gettoken m1 rest : rest, match(par1)
		gettoken m2 rest : rest, match(par2)
		if "`par2'" != "(" | `"`m1'"' == "" | `"`m2'"' == "" {
			di as error "`synerr'"
			exit 198
		}
		* options of the two models that dcdh_compare needs to know
		forvalues k = 1/2 {
			gettoken spec mopts : m`k', parse(",") bind
			local hasopt`k' = `"`mopts'"' != ""
			local 0 `"`mopts'"'
			syntax [, ci_level(real 95) graph_off by(string) by_path(string) *]
			if `"`by'"' != "" | `"`by_path'"' != "" {
				di as error "model `k': by() and by_path() are not supported, because they produce several sets of estimates"
				exit 198
			}
			local cil`k' = `ci_level'
			local goff`k' "`graph_off'"
		}
	}

	local 0 `"`rest'"'
	syntax [, REDRAW FAST SHOWEFFects(integer -1) SHOWPLAcebo(integer -1) ///
		AVG AVGPre AVGValues PVAlues PNOte ///
		NOCI CIBars NORMalci LEvel(string) CIOpacity(integer 20) ///
		SHADE SHADEColor(string) VLINE ///
		SCale(numlist max=2) PCTof(numlist max=2 >0) ///
		color1(string) color2(string) msymbol1(string) msymbol2(string) ///
		LPAttern(string) LWidth(string) AVGLPattern(string) PRELPattern(string) ///
		NOZero NOCAPtions PRECAPtion(string) POSTCAPtion(string) NOLEGend ///
		lbl1(string) lbl2(string) LBLAvg(string) LBLPre(string) ///
		YTItle(string) XTItle(string) ylab(string) tpos(real -99999) ///
		FMT(string) SAVEData(string) EXPort(string) STUB(name) NAME(string) * ]

	* ---- checks and defaults ----
	if "`redraw'" == "" & !`hasmodels' {
		di as error "`synerr'"
		di as error "or, to redraw stored results: dcdh_compare, redraw [plot_options]"
		exit 198
	}
	if "`redraw'" != "" & `hasmodels' {
		di as text "note: with redraw, the models in parentheses are ignored and the stored results are plotted"
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
	if "`scale'" != "" & "`pctof'" != "" {
		di as error "specify either scale() or pctof(), not both"
		exit 198
	}
	if `showeffects' == 0 {
		di as error "showeffects() must be at least 1"
		exit 198
	}

	* one value applies to both models, two values to model 1 and model 2
	local sc1 = 1
	local sc2 = 1
	foreach opt in scale pctof {
		if "``opt''" != "" {
			local v1 : word 1 of ``opt''
			local nv : word count ``opt''
			local v2 : word `nv' of ``opt''
			if "`opt'" == "scale" {
				local sc1 = `v1'
				local sc2 = `v2'
			}
			else {
				local sc1 = 100/`v1'
				local sc2 = 100/`v2'
			}
		}
	}

	if "`stub'" == "" local stub dc
	if "`color1'" == "" local color1 "0 114 178"
	if "`color2'" == "" local color2 "213 94 0"
	if "`msymbol1'" == "" local msymbol1 o
	if "`msymbol2'" == "" local msymbol2 d
	if "`avglpattern'" == "" local avglpattern dash
	if "`prelpattern'" == "" local prelpattern shortdash
	if "`lblavg'" == "" local lblavg "average effect"
	if "`lblpre'" == "" local lblpre "average placebo"
	if "`shadecolor'" == "" local shadecolor "gs12"
	if "`precaption'" == "" local precaption "pre-treatment"
	if "`postcaption'" == "" local postcaption "post-treatment"
	if "`fmt'" == "" local fmt "%5.3f"

	* ---- fast: add graph_off to every model that does not have it ----
	if "`fast'" != "" & "`redraw'" != "" {
		di as text "note: fast has no effect with redraw, because nothing is estimated"
	}
	if "`fast'" != "" & "`redraw'" == "" {
		forvalues k = 1/2 {
			if "`goff`k''" == "" {
				local sep = cond(`hasopt`k'', "", ",")
				local m`k' `"`m`k''`sep' graph_off"'
				local goff`k' "graph_off"
			}
		}
	}

	* ---- estimate both models; keep their graphs and results ----
	if "`redraw'" == "" {
		forvalues k = 1/2 {
			local hdr "dcdh_compare: model `k'"
			if `"`lbl`k''"' != "" local hdr `"`hdr' (`lbl`k'')"'
			di as text _n "{hline}" _n `"`hdr'"' _n "{hline}"
			did_multiplegt_dyn `m`k''
			if "`e(cmd)'" != "did_multiplegt_dyn" {
				di as error "model `k': did_multiplegt_dyn did not leave its results in e()"
				exit 301
			}
			if "`goff`k''" == "" {
				cap graph rename Graph `stub'_m`k', replace
			}
			* settings needed by redraw travel with the stored results
			_dcdh_compare_tag, cil(`cil`k'') goff(`goff`k'') lbl(`"`lbl`k''"')
			estimates store `stub'_m`k'
		}
		di as text "{hline}"
	}

	* ---- read both models from the stored results ----
	tempname R1 R2
	forvalues k = 1/2 {
		cap qui estimates restore `stub'_m`k'
		if _rc {
			di as error "stored results `stub'_m`k' not found; run dcdh_compare with both models first"
			exit 111
		}
		if "`e(cmd)'" != "did_multiplegt_dyn" {
			di as error "stored results `stub'_m`k' are not from did_multiplegt_dyn"
			exit 301
		}
		local cil`k' = 95
		if "`e(dc_cil)'" != "" local cil`k' = `e(dc_cil)'
		local goff`k' "`e(dc_goff)'"
		if `"`lbl`k''"' == "" local lbl`k' `"`e(dc_lbl)'"'
		if `"`lbl`k''"' == "" local lbl`k' "model `k'"

		local E`k' : word count `e(effects)'
		local P`k' : word count `e(placebo)'
		if `E`k'' < 1 {
			di as error "model `k': no effects found in e(effects)"
			exit 198
		}
		local ne`k' = cond(`showeffects' < 0, `E`k'', min(`showeffects', `E`k''))
		local np`k' = cond(`showplacebo' < 0, `P`k'', min(`showplacebo', `P`k''))

		* rows: event time, type (1 placebo, 0 baseline, 2 effect), estimate, standard error
		matrix `R`k'' = J(`np`k'' + 1 + `ne`k'', 4, .)
		local i 0
		forvalues l = `np`k''(-1)1 {
			local ++i
			matrix `R`k''[`i',1] = -(`l' + 1)
			matrix `R`k''[`i',2] = 1
			matrix `R`k''[`i',3] = e(Placebo_`l')
			matrix `R`k''[`i',4] = e(se_placebo_`l')
		}
		local ++i
		matrix `R`k''[`i',1] = -1
		matrix `R`k''[`i',2] = 0
		matrix `R`k''[`i',3] = 0
		matrix `R`k''[`i',4] = 0
		forvalues l = 1/`ne`k'' {
			local ++i
			matrix `R`k''[`i',1] = `l'
			matrix `R`k''[`i',2] = 2
			matrix `R`k''[`i',3] = e(Effect_`l')
			matrix `R`k''[`i',4] = e(se_effect_`l')
		}

		local bavg`k'  = e(Av_tot_effect)*`sc`k''
		local seavg`k' = e(se_avg_total_effect)*`sc`k''
		local pavg`k'  = .
		if !missing(`bavg`k'') & !missing(`seavg`k'') {
			if `seavg`k'' > 0 local pavg`k' = 2*normal(-abs(`bavg`k''/`seavg`k''))
		}
		local pje`k' = e(p_jointeffects)
		local pjp`k' = e(p_jointplacebo)
		local bpre`k'  = .
		local sepre`k' = .
		local ppre`k'  = .
		if `np`k'' >= 1 {
			_dcdh_compare_pp, maxpl(`np`k'')
			local bpre`k'  = r(b)*`sc`k''
			local sepre`k' = r(se)*`sc`k''
			if !missing(`sepre`k'') {
				if `sepre`k'' > 0 local ppre`k' = 2*normal(-abs(`bpre`k''/`sepre`k''))
			}
		}
	}

	* confidence level: by default the ci_level() of the models (95 unless specified there)
	local levsrc estimator
	if "`level'" == "" {
		if `cil1' != `cil2' {
			di as error "the two models use different ci_level(); specify level()"
			exit 198
		}
		local level = `cil1'
	}
	else {
		cap numlist "`level'", min(1) max(2) range(>0 <100) sort
		if _rc {
			di as error "level() must contain one or two numbers between 0 and 100"
			exit 198
		}
		local level `r(numlist)'
		local levsrc user
		if `: word count `level'' == 1 {
			if `level' == `cil1' & `level' == `cil2' local levsrc estimator
		}
	}
	local nlev : word count `level'
	local lev_in  : word 1 of `level'
	local lev_out : word `nlev' of `level'
	local z_out = invnormal(1 - (100 - `lev_out')/200)
	local z_in  = invnormal(1 - (100 - `lev_in')/200)

	* common plot window: the longer of the two models unless set by the user
	local SE = max(`E1', `E2')
	local SP = max(`P1', `P2')
	if `showeffects' > 0 {
		if `showeffects' > `SE' {
			di as error "showeffects() exceeds the number of effects estimated"
			exit 198
		}
		local SE = `showeffects'
	}
	if `showplacebo' >= 0 {
		if `showplacebo' > `SP' {
			di as error "showplacebo() exceeds the number of placebos estimated"
			exit 198
		}
		local SP = `showplacebo'
	}
	if "`avgpre'" != "" & `SP' < 1 {
		di as error "avgpre requires at least one placebo to be plotted"
		exit 198
	}
	forvalues k = 1/2 {
		if "`avg'" != "" & missing(`bavg`k'') {
			di as text "note: model `k' has no average total effect (e(Av_tot_effect) is missing); its average line is omitted"
		}
		if `E`k'' < `SE' | `P`k'' < `SP' {
			di as text "note: model `k' has fewer effects or placebos than the plot window; the missing ones are not drawn"
		}
	}

	if "`noci'" == "" {
		local lvtxt = cond(`nlev' == 2, "`lev_in'/`lev_out'% levels", "`lev_out'% level")
		if "`levsrc'" == "estimator" {
			di as text "note: confidence intervals are b +/- z*se at the `lvtxt' (ci_level() of the models);"
			di as text "      they are identical to those displayed by did_multiplegt_dyn"
		}
		else {
			di as text "note: confidence intervals are b +/- z*se at the `lvtxt' and not those displayed by did_multiplegt_dyn (level() specified)"
		}
	}

	* ---- summary tables, one per model ----
	if "`pvalues'" != "" {
		forvalues k = 1/2 {
			local sb : display string(`bavg`k'', "`fmt'")
			local ss : display string(`seavg`k'', "`fmt'")
			local sp : display string(`pavg`k'', "`fmt'")
			local pb : display string(`bpre`k'', "`fmt'")
			local ps : display string(`sepre`k'', "`fmt'")
			local pp : display string(`ppre`k'', "`fmt'")
			di as text _n "dcdh_compare: summary of model `k' (`lbl`k'')"
			if `sc`k'' != 1 di as text "(estimates multiplied by " as result `sc`k'' as text ")"
			di as text "{hline 62}"
			di as text %-30s "" %10s "estimate" %10s "s.e." %10s "p-value"
			di as text "{hline 62}"
			di as text %-30s "Average effect" as result %10s "`sb'" %10s "`ss'" %10s "`sp'"
			if `np`k'' >= 1 {
				di as text %-30s "Average placebo" as result %10s "`pb'" %10s "`ps'" %10s "`pp'"
			}
			if !missing(`pje`k'') {
				di as text %-30s "Joint test: all effects = 0" as result %30s string(`pje`k'', "`fmt'")
			}
			if !missing(`pjp`k'') {
				di as text %-30s "Joint test: all placebos = 0" as result %30s string(`pjp`k'', "`fmt'")
			}
			di as text "{hline 62}"
		}
	}

	* ---- data for the plot ----
	preserve
	qui {
		clear
		local n1 = rowsof(`R1')
		local n2 = rowsof(`R2')
		set obs `=`n1' + `n2''
		gen byte model = cond(_n <= `n1', 1, 2)
		gen eventtime = .
		gen b  = .
		gen se = .
		gen byte tcode = .
		forvalues k = 1/2 {
			local off = cond(`k' == 1, 0, `n1')
			forvalues i = 1/`n`k'' {
				local r = `off' + `i'
				replace eventtime = `R`k''[`i',1] in `r'
				replace tcode     = `R`k''[`i',2] in `r'
				replace b         = `R`k''[`i',3]*`sc`k'' in `r'
				replace se        = `R`k''[`i',4]*`sc`k'' in `r'
			}
		}
		drop if tcode == 1 & -eventtime - 1 > `SP'
		drop if tcode == 2 & eventtime > `SE'
		gen str8 type = cond(tcode == 1, "placebo", cond(tcode == 2, "effect", "baseline"))
		gen str12 coefname = ""
		replace coefname = "Placebo_" + string(-eventtime - 1) if tcode == 1
		replace coefname = "Effect_" + string(eventtime) if tcode == 2
		gen x = cond(eventtime > 0, eventtime - 1, eventtime)
		gen lb = b - `z_out'*se
		gen ub = b + `z_out'*se
		if `nlev' == 2 {
			gen lb_in = b - `z_in'*se
			gen ub_in = b + `z_in'*se
		}
		gen p = 2*normal(-abs(b/se)) if se > 0 & !missing(se)
		drop tcode
		order model x eventtime type coefname b se
		sort model x
	}
	if "`savedata'" != "" {
		qui save "`savedata'", replace
		di as text "plotted data saved to `savedata'"
	}

	* with bars, the two models are shifted slightly so that they do not overlap
	qui gen xp = x
	if "`cibars'" != "" {
		qui replace xp = x - 0.12 if model == 1
		qui replace xp = x + 0.12 if model == 2
	}

	* ---- axis geometry (as in dcdh_plot) ----
	local x0   = 0
	local x1   = `SE' - 1
	local xmin = -(`SP' + 1)
	local tx1  = -(`SP' + 2)/2
	local tx2  = (`SE' - 1)/2

	local xlab
	forvalues k = `=`SP'+1'(-1)1 {
		local xlab `xlab' `=-`k'' "-`k'"
	}
	forvalues k = 1/`SE' {
		local xlab `xlab' `=`k'-1' "`k'"
	}

	* y-range covers the intervals and average lines of both models and zero
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
	forvalues k = 1/2 {
		if "`avg'" != "" local yv `yv' `bavg`k''
		if "`avgpre'" != "" & `np`k'' >= 1 local yv `yv' `bpre`k''
	}
	foreach v of local yv {
		if !missing(`v') {
			local lo = min(`lo', `v')
			local hi = max(`hi', `v')
		}
	}
	local lo = min(`lo', 0)
	local hi = max(`hi', 0)
	local rng  = `hi' - `lo'
	if `rng' <= 0 local rng = 1
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
		forvalues m = 1/2 {
			if "`cibars'" != "" {
				local plots `plots' (rcap ub lb xp if model == `m', lcolor("`color`m''"))
				local ++k
				if `nlev' == 2 {
					local plots `plots' (rcap ub_in lb_in xp if model == `m', lcolor("`color`m''") lwidth(thick))
					local ++k
				}
			}
			else {
				local plots `plots' (rarea ub lb xp if model == `m', color("`color`m''%`ciopacity'") lcolor("`color`m''%0"))
				local ++k
				if `nlev' == 2 {
					local op = min(2*`ciopacity', 100)
					local plots `plots' (rarea ub_in lb_in xp if model == `m', color("`color`m''%`op'") lcolor("`color`m''%0"))
					local ++k
				}
			}
		}
	}
	local lopts
	if "`lpattern'" != "" local lopts `lopts' lpattern(`lpattern')
	if "`lwidth'" != "" local lopts `lopts' lwidth(`lwidth')
	local order
	forvalues m = 1/2 {
		local plots `plots' (connected b xp if model == `m', msymbol(`msymbol`m'') mcolor("`color`m''") lcolor("`color`m''") `lopts')
		local ++k
		local order `order' `k' `"`lbl`m''"'
	}
	if "`nozero'" == "" {
		local plots `plots' (pci 0 `xmin' 0 `x1', lcolor(gs8) lpattern(solid))
		local ++k
	}

	* average values: when both lines are close, the labels are moved apart
	local texts
	local xsc
	local pl1 e
	local pl2 e
	local pp1 w
	local pp2 w
	local gap = (`hi2' - `lo2')/15
	if !missing(`bavg1') & !missing(`bavg2') & abs(`bavg1' - `bavg2') < `gap' {
		local pl1 = cond(`bavg1' >= `bavg2', "ne", "se")
		local pl2 = cond(`bavg1' >= `bavg2', "se", "ne")
	}
	if !missing(`bpre1') & !missing(`bpre2') & abs(`bpre1' - `bpre2') < `gap' {
		local pp1 = cond(`bpre1' >= `bpre2', "nw", "sw")
		local pp2 = cond(`bpre1' >= `bpre2', "sw", "nw")
	}
	if "`avg'" != "" {
		forvalues m = 1/2 {
			if !missing(`bavg`m'') {
				local xe = `ne`m'' - 1
				local plots `plots' (pci `bavg`m'' `x0' `bavg`m'' `xe', lcolor("`color`m''") lpattern(`avglpattern') lwidth(medthick))
				local ++k
				local order `order' `k' `"`lblavg' (`lbl`m'')"'
				local plots `plots' (scatteri `bavg`m'' `x0', msymbol(circle_hollow) mcolor("`color`m''"))
				local plots `plots' (scatteri `bavg`m'' `xe', msymbol(circle_hollow) mcolor("`color`m''"))
				local k = `k' + 2
				if "`avgvalues'" != "" {
					local s : display string(`bavg`m'', "`fmt'")
					local texts `texts' text(`bavg`m'' `=`xe'+0.2' "`s'", place(`pl`m'') size(small) color("`color`m''"))
					local xsc xscale(range(`=`xmin'-0.5' `=`x1'+1.5'))
				}
			}
			else local order `order' - " "
		}
	}
	if "`avgpre'" != "" {
		forvalues m = 1/2 {
			if !missing(`bpre`m'') {
				local xs = -(`np`m'' + 1)
				local plots `plots' (pci `bpre`m'' `xs' `bpre`m'' -2, lcolor("`color`m''") lpattern(`prelpattern') lwidth(medthick))
				local ++k
				local order `order' `k' `"`lblpre' (`lbl`m'')"'
				local plots `plots' (scatteri `bpre`m'' `xs', msymbol(circle_hollow) mcolor("`color`m''"))
				local plots `plots' (scatteri `bpre`m'' -2, msymbol(circle_hollow) mcolor("`color`m''"))
				local k = `k' + 2
				if "`avgvalues'" != "" {
					local s : display string(`bpre`m'', "`fmt'")
					local texts `texts' text(`bpre`m'' `=`xs'-0.2' "`s'", place(`pp`m'') size(small) color("`color`m''"))
					local xsc xscale(range(`=`xmin'-1.5' `=`x1'+1.5'))
				}
			}
			else local order `order' - " "
		}
	}

	* the legend is needed to tell the models apart; one column per model
	local legend legend(order(`order') cols(2) position(6))
	if "`nolegend'" != "" local legend legend(off)
	local captions
	if "`nocaptions'" == "" {
		local captions text(`tpos' `tx1' "`precaption'", size(small)) text(`tpos' `tx2' "`postcaption'", size(small))
	}
	local ytitlecmd
	if "`ytitle'" != "" local ytitlecmd title("`ytitle'", position(9) size(medium))

	* optional note under the plot with p-values, one line per model
	local notecmd
	if "`pnote'" != "" {
		local nlines
		forvalues m = 1/2 {
			local nt
			if !missing(`pavg`m'') {
				local s1 : display string(`bavg`m'', "`fmt'")
				local s2 : display string(`pavg`m'', "`fmt'")
				local nt "average effect: `s1' (p = `s2')"
			}
			if !missing(`pjp`m'') {
				local s3 : display string(`pjp`m'', "`fmt'")
				if "`nt'" != "" local nt "`nt'; "
				local nt "`nt'joint placebo test: p = `s3'"
			}
			if "`nt'" != "" local nlines `"`nlines' "`lbl`m'': `nt'""'
		}
		if `"`nlines'"' != "" local notecmd note(`nlines', size(small))
	}

	local namecmd name(`stub'_compare, replace)
	if `"`name'"' != "" local namecmd name(`name')

	twoway `plots', xtitle("`xtitle'") ytitle("") xlabel(`xlab') `captions' `texts' `xsc' ///
		ylabel(`ylab', grid glcolor(gs14) glwidth(vthin)) ///
		`legend' `ytitlecmd' `notecmd' `namecmd' `options'

	if "`export'" != "" graph export "`export'", replace
	restore

	* results of model 1 are active again; both models stay stored
	qui estimates restore `stub'_m1
	di as text "results stored as " as result "`stub'_m1" as text " and " as result "`stub'_m2" ///
		as text "; active: " as result "`stub'_m1"

	return local est1 "`stub'_m1"
	return local est2 "`stub'_m2"
	if "`goff1'" == "" return local graph1 "`stub'_m1"
	if "`goff2'" == "" return local graph2 "`stub'_m2"
	return local level "`level'"
end

* helper: average placebo = mean of Placebo_1..Placebo_maxpl in e(b), with SE from e(V)
program define _dcdh_compare_pp, rclass
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
		return scalar b  = .
		return scalar se = .
		return scalar n  = 0
		exit
	}
	matrix `w' = `w' / `npl'
	matrix `bpl' = `w' * `bb''
	matrix `vpl' = `w' * `VV' * `w''
	return scalar b  = `bpl'[1,1]
	return scalar se = sqrt(`vpl'[1,1])
	return scalar n  = `npl'
end

* helper: adds the settings of dcdh_compare to the results of did_multiplegt_dyn
program define _dcdh_compare_tag, eclass
	version 16
	syntax , cil(real) [goff(string) lbl(string asis)]
	ereturn local dc_cil "`cil'"
	ereturn local dc_goff "`goff'"
	ereturn local dc_lbl `lbl'
end
