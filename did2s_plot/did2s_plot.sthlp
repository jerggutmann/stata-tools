{smcl}
{* *! version 0.1.1  11oct2026  Jerg Gutmann}{...}
{vieweralsosee "did2s" "help did2s"}{...}
{vieweralsosee "french_plot" "help french_plot"}{...}
{vieweralsosee "lpdid_plot" "help lpdid_plot"}{...}
{vieweralsosee "[G-2] graph twoway" "help twoway"}{...}
{vieweralsosee "[G-2] graph export" "help graph_export"}{...}
{viewerjumpto "Syntax" "did2s_plot##syntax"}{...}
{viewerjumpto "Description" "did2s_plot##description"}{...}
{viewerjumpto "Options" "did2s_plot##options"}{...}
{viewerjumpto "Examples" "did2s_plot##examples"}{...}
{viewerjumpto "Remarks" "did2s_plot##remarks"}{...}
{title:Title}

{phang}{bf:did2s_plot} {hline 2} Event-study plot after {cmd:did2s}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:did2s_plot,} {opt eventvar(varname)} [{opt shift(#)} {it:options}]{p_end}
{p 8 17 2}{cmd:did2s_plot,} {opt lead(template)} {opt lag(template)} [{it:options}]{p_end}

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Event-time variables (one of the two forms)}
{synopt:{opt eventvar(varname)}}event-time factor variable used in {cmd:second_stage()}{p_end}
{synopt:{opt shift(#)}}value of {it:varname} that corresponds to event time 0; default is {cmd:0}{p_end}
{synopt:{opt lead(template)}}name pattern of lead dummies, for example {cmd:F#_treat}{p_end}
{synopt:{opt lag(template)}}name pattern of lag dummies, for example {cmd:L#_treat}{p_end}

{syntab:Contents}
{synopt:{opt pre(#)}}earliest event time shown is {it:-#}; default is all{p_end}
{synopt:{opt post(#)}}latest event time shown is {it:#}; default is all{p_end}
{synopt:{opt avg}}add the average of the plotted post-treatment coefficients{p_end}
{synopt:{opt avgp:re}}add the average of the plotted pre-treatment coefficients{p_end}
{synopt:{opt avgv:alues}}print the values of the average lines{p_end}
{synopt:{opt noci}}no confidence intervals{p_end}
{synopt:{opt cib:ars}}confidence intervals as bars{p_end}
{synopt:{opt norm:alci}}accepted for compatibility with the other plot commands; no effect{p_end}
{synopt:{opt le:vel(# [#])}}one or two confidence levels{p_end}
{synopt:{opt sc:ale(#)}}multiply all estimates by {it:#}{p_end}
{synopt:{opt pct:of(#)}}express estimates in percent of {it:#}{p_end}

{syntab:Statistics}
{synopt:{opt pva:lues}}display a table of averages, p-values and joint tests{p_end}
{synopt:{opt pno:te}}add p-values as a note below the plot{p_end}
{synopt:{opt fmt(%fmt)}}number format; default is {cmd:%5.3f}{p_end}

{syntab:Appearance}
{synopt:{opt shade}}shade the post-treatment area{p_end}
{synopt:{opt shadec:olor(colorstyle)}}colour of the shading; default is {cmd:gs12}{p_end}
{synopt:{opt vline}}vertical line between baseline and first effect{p_end}
{synopt:{opt col:or(string)}}colour of the series; default is {cmd:0 114 178}{p_end}
{synopt:{opt avgc:olor(string)}}colour of the post-treatment average line{p_end}
{synopt:{opt precol:or(string)}}colour of the pre-treatment average line{p_end}
{synopt:{opt ms:ymbol(symbolstyle)}}marker symbol; default is {cmd:o}{p_end}
{synopt:{opt lpa:ttern(patternstyle)}}line pattern of the series{p_end}
{synopt:{opt lw:idth(linewidthstyle)}}line width of the series{p_end}
{synopt:{opt avgl:pattern(patternstyle)}}line pattern of the post-treatment average line{p_end}
{synopt:{opt prelp:attern(patternstyle)}}line pattern of the pre-treatment average line{p_end}
{synopt:{opt cio:pacity(#)}}opacity of the confidence bands in percent; default is {cmd:20}{p_end}
{synopt:{opt noz:ero}}no zero line{p_end}
{synopt:{opt nocap:tions}}no pre-/post-treatment captions{p_end}
{synopt:{opt precap:tion(string)}}text of the pre-treatment caption{p_end}
{synopt:{opt postcap:tion(string)}}text of the post-treatment caption{p_end}
{synopt:{opt noleg:end}}no legend{p_end}
{synopt:{opt lbld:yn(string)}}legend label of the dynamic effects{p_end}
{synopt:{opt lbla:vg(string)}}legend label of the average effect{p_end}
{synopt:{opt lblp:re(string)}}legend label of the average placebo{p_end}
{synopt:{opt yti:tle(string)}}title left of the y-axis; default is none{p_end}
{synopt:{opt xti:tle(string)}}title of the x-axis; default is none{p_end}
{synopt:{opt ylab(rule)}}y-axis labels; requires {opt tpos()}{p_end}
{synopt:{opt tpos(#)}}y-position of the captions{p_end}

{syntab:Output}
{synopt:{opt saved:ata(filename)}}save the plotted data{p_end}
{synopt:{opt exp:ort(filename)}}save the graph{p_end}
{synopt:{it:twoway_options}}other options of {helpb twoway_options}{p_end}
{synoptline}
{p2colreset}{...}

{pstd}{cmd:did2s_plot} must be run directly after {helpb did2s}.
The command needs to know which coefficients of {cmd:second_stage()} are event-study coefficients; see {help did2s_plot##naming:Naming the coefficients}.{p_end}


{marker description}{...}
{title:Description}

{pstd}{cmd:did2s_plot} draws an event-study plot for a single event from the results of {cmd:did2s} (Gardner 2021; Butts and Gardner 2022).
It is the counterpart of {helpb french_plot} and {helpb lpdid_plot}.
All three commands use the same layout, axis positions, defaults and options,
so that figures from the different estimators can be compared directly.{p_end}

{pstd}In {cmd:did2s}, the user defines the treatment variables in {cmd:second_stage()}.
{cmd:did2s_plot} therefore identifies the event-study coefficients by name; see below.
It reads {cmd:e(b)} and {cmd:e(V)} and does not change them.{p_end}

{pstd}Event times -2 and earlier are plotted at their value as placebo coefficients.
Event time {it:k} {ul:>} 0 is plotted at {it:k} and labelled {it:k}+1, as {cmd:tau}{it:k} in {helpb lpdid_plot}.
Event time -1 is the baseline, plotted at -1.
If your regression estimates a coefficient for event time -1, it is plotted as estimated.
If event time -1 is the omitted base category (or has no coefficient), the baseline is set to zero.
Event times without a coefficient appear as gaps.{p_end}

{marker naming}{...}
{pstd}{bf:Naming the coefficients.}
There are two ways to tell {cmd:did2s_plot} which coefficients to use.
In both, a table of the coefficients and their event times is shown in the Results window.{p_end}

{phang2}1. {opt eventvar(varname)}: {cmd:second_stage()} contains one factor variable, for example {cmd:ib100.rel_year_shift}.
Its levels are non-negative integers, so event times that are negative must be shifted.
Level {it:v} corresponds to event time {it:v} - {opt shift()}.
Omitted and base levels (for example {cmd:100b.}) are recognised.
A base level outside the range of the estimated levels, such as a never-treated group coded 100, is ignored.
A base level inside that range is plotted as zero.{p_end}

{phang2}2. {opt lead(template)} and {opt lag(template)}: {cmd:second_stage()} contains dummy variables.
The templates describe their names, with {cmd:#} for the number.
With {cmd:lead(F#_treat) lag(L#_treat)}, the variable {cmd:F3_treat} is event time -3 and {cmd:L2_treat} is event time 2;
{cmd:L0_treat} is event time 0.
Either option can be used alone, but at least one is required.
The templates may contain letters, digits, underscores and periods.
Neither form can be combined with the other.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Event-time variables}

{phang}{opt eventvar(varname)} and {opt shift(#)} specify the factor variable as described under {help did2s_plot##naming:Naming the coefficients}.
Only coefficients named {it:level}{cmd:.}{it:varname} (with the usual {cmd:b}, {cmd:o} or {cmd:n} suffix after the level) are used.
Example: if you generated {cmd:rel_year_shift = rel_year + 20}, specify {cmd:shift(20)}.{p_end}

{phang}{opt lead(template)} and {opt lag(template)} specify the names of lead and lag dummies, see above.{p_end}

{dlgtab:Contents}

{phang}{opt pre(#)} and {opt post(#)} restrict the plot to the event times -{it:#}, ..., -1 and 0, ..., {it:#}.
By default, all matched coefficients are plotted.
{opt pre(1)} shows only the baseline.
{cmd:pre(}{it:U}{cmd:)} corresponds to {cmd:placebo(}{it:U}-1{cmd:)} and {cmd:post(}{it:T}{cmd:)} to {cmd:effects(}{it:T}+1{cmd:)} in {helpb french_plot}.
If you ask for more periods than were estimated, the missing ones appear as gaps.{p_end}

{phang}{opt avg} adds the average of the plotted post-treatment coefficients as a dashed horizontal line over the post-treatment periods.
The average is unweighted; its standard error is computed from {cmd:e(V)}.
It is {it:not} the average treatment effect of {cmd:did2s} (for example from a static model), which weights the treated observations.{p_end}

{phang}{opt avgpre} adds the unweighted average of the plotted pre-treatment coefficients as a dashed horizontal line.
It spans the periods from the earliest plotted period to -1 if event time -1 is estimated, otherwise to -2.
At least one estimated pre-treatment coefficient must be plotted.{p_end}

{phang}{opt avgvalues} prints the value of each average line next to its end.
It requires {opt avg} or {opt avgpre}.
It sets {cmd:xscale(range())}, so do not also pass {cmd:xscale()}.{p_end}

{phang}{opt noci} suppresses the confidence intervals.{p_end}

{phang}{opt cibars} draws the confidence intervals as bars instead of a shaded area.{p_end}

{phang}{opt normalci} is accepted so that the same command line works for all plot commands.
It has no effect here, because the intervals are always normal-based.{p_end}

{phang}{opt level(# [#])} sets the confidence level; the default is {cmd:c(level)}.
The intervals are {it:b} ± {it:z} × {it:se}, as displayed by {cmd:did2s}, which does not store them.
The command prints a note to this effect on every call without {opt noci}.
With two values, for example {cmd:level(90 95)}, the smaller level is drawn as a darker inner band
and the larger as a lighter outer band.{p_end}

{phang}{opt scale(#)} multiplies all plotted and reported estimates and standard errors by {it:#}.{p_end}

{phang}{opt pctof(#)} expresses all estimates in percent of {it:#}, for example of the baseline mean of the outcome.
It is equivalent to {cmd:scale(100/}{it:#}{cmd:)}.
{opt scale()} and {opt pctof()} cannot be combined.
Neither changes the p-values.{p_end}

{dlgtab:Statistics}

{phang}{opt pvalues} displays a table in the Results window.
It contains the estimate, standard error and p-value of the average of the post-treatment coefficients and of the pre-treatment coefficients
(the latter if at least two are plotted).
In addition, it reports joint Wald tests that all plotted pre-treatment coefficients, and all plotted post-treatment coefficients, are zero.
They use the full covariance matrix {cmd:e(V)} of the coefficients and are shown as p-values only.
Omitted, base and zero-baseline periods are not part of the tests.
The p-values are two-sided; the averages use the normal distribution.{p_end}

{phang}{opt pnote} adds the p-value of the average post-treatment effect and the p-value of the joint test of the pre-treatment coefficients
(pre-trend test, if at least two are plotted) as a note below the plot.
It uses the {cmd:note()} option of the graph, so do not also pass {cmd:note()}.{p_end}

{phang}{opt fmt(%fmt)} sets the number format of the values and p-values.
The default is {cmd:%5.3f}.{p_end}

{dlgtab:Appearance}

{phang}{opt shade} shades the post-treatment area.
{opt shadecolor()} changes the colour; the default is {cmd:gs12}.
The shading and {opt vline} follow the automatically chosen y-axis,
so neither can be combined with {opt ylab()}.{p_end}

{phang}{opt vline} draws a vertical dashed line between the baseline and the first effect.{p_end}

{phang}{opt color(string)} sets the colour of the series and of the confidence intervals.
Give an RGB triple in quotes, as in {cmd:color("0 114 178")}, which is the default.
{opt avgcolor()} sets the colour of the post-treatment average line; the default is {opt color()}.
{opt precolor()} sets the colour of the pre-treatment average line; the default is {opt avgcolor()}.{p_end}

{phang}{opt msymbol()}, {opt lpattern()} and {opt lwidth()}
set the marker symbol, line pattern and line width of the series.
{opt avglpattern()} and {opt prelpattern()} set the line patterns of the two average lines;
the defaults are {cmd:dash} and {cmd:shortdash}.{p_end}

{phang}{opt ciopacity(#)} sets the opacity of the confidence band in percent.
The default is 20.
With two levels, the inner band is drawn with twice this opacity, up to 100.{p_end}

{phang}{opt nozero} suppresses the horizontal line at zero.{p_end}

{phang}{opt nocaptions} suppresses the captions "pre-treatment" and "post-treatment".
{opt precaption()} and {opt postcaption()} change their text.
Unless you set {opt tpos()}, the captions are placed just above the top y-axis label.{p_end}

{phang}{opt nolegend} suppresses the legend.
A legend is only drawn if {opt avg} or {opt avgpre} is specified.
{opt lbldyn()}, {opt lblavg()} and {opt lblpre()} change the legend labels of the dynamic effects,
the average effect and the average placebo.{p_end}

{phang}{opt ytitle(string)} and {opt xtitle(string)} add titles to the axes.
By default, neither axis has a title.{p_end}

{phang}{opt ylab(rule)} sets the y-axis labels, for example {cmd:ylab(-1(.5)1)}.
It requires {opt tpos(#)}, the y-position of the captions.
By default, a rounded range is chosen automatically.
It covers the estimates, the intervals, the average lines and zero.{p_end}

{dlgtab:Output}

{phang}{opt savedata(filename)} saves the plotted data as a Stata dataset.
It contains the variables {cmd:x} (position in the plot), {cmd:eventtime} (as labelled on the x-axis),
{cmd:type} ({cmd:placebo}, {cmd:baseline} or {cmd:effect}),
{cmd:coefname} (name of the coefficient in {cmd:e(b)}), {cmd:b}, {cmd:se}, {cmd:lb}, {cmd:ub} and {cmd:p}.
With two levels, {cmd:lb} and {cmd:ub} belong to the larger level, and {cmd:lb_in} and {cmd:ub_in} to the smaller.
The data in memory are not changed.{p_end}

{phang}{opt export(filename)} saves the graph with {helpb graph export}.
The file type follows from the extension.
An existing file is replaced.{p_end}

{phang}{it:twoway_options} are all other options of {helpb twoway_options},
for example {cmd:name()}, {cmd:scheme()} or {cmd:title()}.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Load the example data of {cmd:did2s}{p_end}
{phang2}{stata "use https://github.com/kylebutts/did2s_stata/raw/main/data/df_hom.dta, clear":. use https://github.com/kylebutts/did2s_stata/raw/main/data/df_hom.dta, clear}{p_end}

{pstd}Event-study model from the help of {cmd:did2s}: shift the relative years to non-negative values and code never-treated units as 100{p_end}
{phang2}{stata "gen rel_year_shift = rel_year + 20":. gen rel_year_shift = rel_year + 20}{p_end}
{phang2}{stata "replace rel_year_shift = 100 if rel_year_shift == .":. replace rel_year_shift = 100 if rel_year_shift == .}{p_end}
{phang2}{stata "did2s dep_var, first_stage(i.state i.year) second_stage(ib100.rel_year_shift) treatment(treat) cluster(state)":. did2s dep_var, first_stage(i.state i.year) second_stage(ib100.rel_year_shift) treatment(treat) cluster(state)}{p_end}

{pstd}Plot all coefficients; event time = level minus 20.
Here event time -1 is estimated, so {cmd:did2s_plot} prints a warning (see Remarks){p_end}
{phang2}{stata "did2s_plot, eventvar(rel_year_shift) shift(20) name(d1, replace)":. did2s_plot, eventvar(rel_year_shift) shift(20) name(d1, replace)}{p_end}

{pstd}Show five pre-treatment periods and ten post-treatment periods, with the average lines and their values{p_end}
{phang2}{stata "did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) avg avgpre avgvalues name(d2, replace)":. did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) avg avgpre avgvalues name(d2, replace)}{p_end}

{pstd}Show the 90 and 95 percent confidence bands, shade the post-treatment area and add the baseline line{p_end}
{phang2}{stata "did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) level(90 95) shade vline name(d3, replace)":. did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) level(90 95) shade vline name(d3, replace)}{p_end}

{pstd}Display averages and joint tests in the Results window and as a note below the plot{p_end}
{phang2}{stata "did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) avg avgpre pvalues pnote name(d4, replace)":. did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) avg avgpre pvalues pnote name(d4, replace)}{p_end}

{pstd}Express the estimates in percent of a baseline mean of 12.5{p_end}
{phang2}{stata "did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) pctof(12.5) name(d5, replace)":. did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) pctof(12.5) name(d5, replace)}{p_end}

{pstd}Save the graph{p_end}
{phang2}{stata `"did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) avg export("event_study.png") name(d6, replace)"':. did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) avg export("event_study.png") name(d6, replace)}{p_end}

{pstd}The same model with dummy variables instead of the factor variable.
Leave out the dummy for event time -1 ({cmd:F1_treat}), so that t-1 is the reference period and no warning appears.
The two loops cannot be run by clicking; copy them into the Command window or a do-file{p_end}
{phang2}{cmd:. forvalues k = 2/20 {c -(}}{p_end}
{phang3}{cmd:. gen F`k'_treat = (rel_year_shift == 20 - `k')}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{cmd:. forvalues k = 0/20 {c -(}}{p_end}
{phang3}{cmd:. gen L`k'_treat = (rel_year_shift == 20 + `k')}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{stata "did2s dep_var, first_stage(i.state i.year) second_stage(F*_treat L*_treat) treatment(treat) cluster(state)":. did2s dep_var, first_stage(i.state i.year) second_stage(F*_treat L*_treat) treatment(treat) cluster(state)}{p_end}
{phang2}{stata "did2s_plot, lead(F#_treat) lag(L#_treat) pre(5) post(10) avg avgpre name(d7, replace)":. did2s_plot, lead(F#_treat) lag(L#_treat) pre(5) post(10) avg avgpre name(d7, replace)}{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}Requires Stata 16 or newer.{p_end}

{pstd}The estimates and standard errors are read from {cmd:e(b)} and {cmd:e(V)}.
Confidence intervals are normal-based, like those of {cmd:did2s}, and p-values are calculated from the estimate and the standard error using the normal distribution.
They are therefore comparable to {helpb french_plot}.
Base and omitted categories have a coefficient of zero and a standard error of zero.{p_end}

{pstd}{bf:Normalisation at t-1.}
Event-study estimates are only comparable to those of {cmd:french_plot} and {cmd:lpdid_plot} if the reference period is event time -1.
If your regression estimates a coefficient for event time -1, {cmd:did2s_plot} plots it as estimated and prints a warning,
because the coefficients are then not normalised to zero at t-1.
The graph is still drawn, but the specification should be reconsidered.
With dummy variables, leave out the dummy for event time -1 (for example {cmd:F1_treat}); the baseline is then plotted as zero.
With a factor variable, make event time -1 the base level, for example with {cmd:ib}{it:#}{cmd:.}, and make sure that never-treated observations are handled as in your model.
The factor-variable form and the dummy form cannot be combined in one call.{p_end}

{pstd}The averages and joint tests refer only to the coefficients that are plotted.
Changing {opt pre()} or {opt post()} changes them.{p_end}

{pstd}The first treated period is event time 0 and is labelled 1 on the x-axis, as in {helpb french_plot} and {helpb lpdid_plot}.
In the example data, {cmd:rel_year} is 0 in the first treated year.{p_end}

{pstd}This is a beta version. Please check the plotted values against the output of {cmd:did2s}.{p_end}


{title:Author}

{pstd}Jerg Gutmann{break}
{browse "https://github.com/jerggutmann/stata-tools"}{p_end}

{pstd}Licence: MIT, see {browse "https://github.com/jerggutmann/stata-tools/blob/main/LICENSE":LICENSE} in the repository.{p_end}

{title:Support and updates}

{pstd}Please report problems and suggestions at
{browse "https://github.com/jerggutmann/stata-tools/issues"}.
Re-run {cmd:net install did2s_plot, replace} to get the latest version.{p_end}


{title:Also see}

{psee}
Help: {help did2s} (if installed), {help french_plot} (if installed), {help lpdid_plot} (if installed), {help twoway_options}, {help graph_export}{p_end}
