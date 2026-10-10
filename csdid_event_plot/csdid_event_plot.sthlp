{smcl}
{* *! version 0.1.0  11oct2026  Jerg Gutmann}{...}
{vieweralsosee "csdid" "help csdid"}{...}
{vieweralsosee "french_plot" "help french_plot"}{...}
{vieweralsosee "lpdid_plot" "help lpdid_plot"}{...}
{vieweralsosee "did2s_plot" "help did2s_plot"}{...}
{vieweralsosee "[G-2] graph twoway" "help twoway"}{...}
{vieweralsosee "[G-2] graph export" "help graph_export"}{...}
{viewerjumpto "Syntax" "csdid_event_plot##syntax"}{...}
{viewerjumpto "Description" "csdid_event_plot##description"}{...}
{viewerjumpto "Options" "csdid_event_plot##options"}{...}
{viewerjumpto "Examples" "csdid_event_plot##examples"}{...}
{viewerjumpto "Remarks" "csdid_event_plot##remarks"}{...}
{title:Title}

{phang}{bf:csdid_event_plot} {hline 2} Event-study plot after {cmd:csdid}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:csdid_event_plot} [{cmd:,} {it:options}]{p_end}

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Contents}
{synopt:{opt pre(#)}}earliest event time shown is {it:-#}; default is all{p_end}
{synopt:{opt post(#)}}latest event time shown is {it:#}; default is all{p_end}
{synopt:{opt avg}}add {cmd:Post_avg} of {cmd:estat event}{p_end}
{synopt:{opt avgp:re}}add {cmd:Pre_avg} of {cmd:estat event}{p_end}
{synopt:{opt avgv:alues}}print the values of the average lines{p_end}
{synopt:{opt noci}}no confidence intervals{p_end}
{synopt:{opt cib:ars}}confidence intervals as bars{p_end}
{synopt:{opt norm:alci}}pointwise normal intervals instead of those of {cmd:csdid}{p_end}
{synopt:{opt le:vel(# [#])}}one or two confidence levels; implies {opt normalci}{p_end}
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

{pstd}{cmd:csdid_event_plot} must be run directly after {helpb csdid}.
The command needs to know which coefficients of {cmd:second_stage()} are event-study coefficients; see {help csdid_event_plot##naming:Naming the coefficients}.{p_end}



{pstd}{cmd:csdid_event_plot} works with the event-study results of {helpb csdid}.
Run {cmd:csdid_event_plot} directly after {cmd:estat event}, or directly after {cmd:csdid}; then it calls {cmd:estat event} itself.{p_end}


{marker description}{...}
{title:Description}

{pstd}{cmd:csdid_event_plot} draws an event-study plot for a single event from the results of {cmd:estat event} after {cmd:csdid} (Callaway and Sant'Anna 2021).
It is the counterpart of {helpb french_plot}, {helpb lpdid_plot} and {helpb did2s_plot}.
All use the same layout, axis positions, defaults and options,
so that figures from different estimators can be compared directly.{p_end}

{pstd}Do not confuse it with {cmd:csdid_plot}, the plot command that comes with {cmd:csdid} itself; the two do not interfere.{p_end}

{pstd}{cmd:estat event} reports the dynamic effects in columns named {cmd:Tm}{it:k} ({it:k} periods before treatment) and {cmd:Tp}{it:k} ({it:k} periods after),
plus the averages {cmd:Pre_avg} and {cmd:Post_avg}.
{cmd:csdid_event_plot} reads the table {cmd:r(table)} of {cmd:estat event}.
Event time -{it:k} is plotted at -{it:k}, and event time {it:k} {ul:>} 0 at {it:k}, labelled {it:k}+1, as in the other commands.
Event time -1 ({cmd:Tm1}) is the baseline.
If {cmd:Tm1} is not in the table, the baseline is set to zero; see {help csdid_event_plot##norm:Normalisation at t-1}.
Event times without a column appear as gaps.{p_end}

{pstd}By default, the plot uses the standard errors, confidence intervals and p-values that {cmd:estat event} reports.
These are asymptotic and pointwise, also if {cmd:csdid} was run with {opt wboot}, because {cmd:estat event} always uses the asymptotic variance matrix.
The average lines are {cmd:Pre_avg} and {cmd:Post_avg} of {cmd:csdid}.{p_end}

{marker norm}{...}
{pstd}{bf:Normalisation at t-1.}
By default, {cmd:csdid} estimates pre-treatment effects with short gaps:
each pre-treatment effect compares period {it:t} with period {it:t}-1, so event time -1 is estimated and is not zero by construction.
In that case {cmd:csdid_event_plot} plots the estimate and prints a warning, because the coefficients are not normalised to zero at t-1.
The graph is still drawn, but the specification should be reconsidered.
With option {opt long2} in {cmd:csdid}, all pre-treatment effects use period -1 as the base; {cmd:Tm1} is then not estimated and the baseline is plotted as zero.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Contents}

{phang}{opt pre(#)} and {opt post(#)} restrict the plot to the event times -{it:#}, ..., -1 and 0, ..., {it:#}.
By default, all columns {cmd:Tm}{it:k} and {cmd:Tp}{it:k} of {cmd:r(table)} are plotted.
{opt pre(1)} shows only the baseline.
{cmd:pre(}{it:U}{cmd:)} corresponds to {cmd:placebo(}{it:U}-1{cmd:)} and {cmd:post(}{it:T}{cmd:)} to {cmd:effects(}{it:T}+1{cmd:)} in {helpb french_plot}.
Event times that were not estimated appear as gaps.{p_end}

{phang}{opt avg} adds {cmd:Post_avg} of {cmd:estat event}, the average of the post-treatment effects, as a dashed horizontal line over the post-treatment periods.
It is calculated by {cmd:csdid} from all post-treatment periods, also if fewer are shown with {opt post()}.{p_end}

{phang}{opt avgpre} adds {cmd:Pre_avg}, the average of the pre-treatment effects, as a dashed horizontal line.
It spans the periods from the earliest plotted period to -1 if {cmd:Tm1} is estimated, otherwise to -2.
It is calculated from all pre-treatment periods of {cmd:csdid}.{p_end}

{phang}{opt avgvalues} prints the value of each average line next to its end.
It requires {opt avg} or {opt avgpre}.
It sets {cmd:xscale(range())}, so do not also pass {cmd:xscale()}.{p_end}

{phang}{opt noci} suppresses the confidence intervals.{p_end}

{phang}{opt cibars} draws the confidence intervals as bars instead of a shaded area.{p_end}

{phang}{opt normalci} replaces the intervals of {cmd:estat event} with pointwise normal intervals,
{it:b} ± {it:z} × {it:se}, at the 95 percent level (the default level of {cmd:csdid}) unless {opt level()} is given.
Whenever the plotted intervals are not those of {cmd:estat event}, the command prints a note that says why.
By default, the plot uses the columns {cmd:ll} and {cmd:ul} of {cmd:r(table)}, which are pointwise intervals based on the asymptotic variance matrix, also after {opt wboot}.
The default p-values are those of {cmd:estat event}.{p_end}

{phang}{opt level(# [#])} sets the confidence level and implies {opt normalci}.
Without {opt level()} and {opt normalci}, the intervals are those of {cmd:estat event}, with the level used in {cmd:csdid}.
With two values, for example {cmd:level(90 95)}, the smaller level is drawn as a darker inner band
and the larger as a lighter outer band.
The p-values are then calculated from the estimate and the standard error using the normal distribution.{p_end}

{phang}{opt scale(#)} multiplies all plotted and reported estimates and standard errors by {it:#}.{p_end}

{phang}{opt pctof(#)} expresses all estimates in percent of {it:#}, for example of the baseline mean of the outcome.
It is equivalent to {cmd:scale(100/}{it:#}{cmd:)}.
{opt scale()} and {opt pctof()} cannot be combined.
Neither changes the p-values.{p_end}

{dlgtab:Statistics}

{phang}{opt pvalues} displays a table in the Results window.
It contains the estimate, standard error and p-value of {cmd:Post_avg} (average effect) and {cmd:Pre_avg} (average placebo), as reported by {cmd:estat event}.
In addition, it reports joint Wald tests that all plotted post-treatment and all plotted pre-treatment coefficients are zero.
They use {cmd:r(bb)} and {cmd:r(vv)} of {cmd:estat event}, and are only shown if these match {cmd:r(table)}.
This is not the case with wild bootstrap standard errors, because {cmd:r(vv)} then belongs to the asymptotic variance.{p_end}

{phang}{opt pnote} adds the p-value of the average effect and, if available, the p-value of the joint test of the pre-treatment coefficients
as a note below the plot.
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
{cmd:coefname} (column of {cmd:r(table)}), {cmd:b}, {cmd:se}, {cmd:lb}, {cmd:ub} and {cmd:p}.
With two levels, {cmd:lb} and {cmd:ub} belong to the larger level, and {cmd:lb_in} and {cmd:ub_in} to the smaller.
The data in memory are not changed.{p_end}

{phang}{opt export(filename)} saves the graph with {helpb graph export}.
The file type follows from the extension.
An existing file is replaced.{p_end}

{phang}{it:twoway_options} are all other options of {helpb twoway_options},
for example {cmd:name()}, {cmd:scheme()} or {cmd:title()}.{p_end}



{marker examples}{...}
{title:Examples}

{pstd}Load the example data of {cmd:csdid} and estimate all group-time effects{p_end}
{phang2}{stata "use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear":. use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear}{p_end}
{phang2}{stata "csdid lemp lpop, ivar(countyreal) time(year) gvar(first_treat) method(dripw)":. csdid lemp lpop, ivar(countyreal) time(year) gvar(first_treat) method(dripw)}{p_end}

{pstd}Aggregate to the event study; {cmd:csdid_plot} of the {cmd:csdid} package draws it and is kept under the name {cmd:csdid_own} for comparison. Then plot it with {cmd:csdid_event_plot}; the default short gaps estimate event time -1, so a warning is printed{p_end}
{phang2}{stata "estat event":. estat event}{p_end}
{phang2}{stata "csdid_plot, name(csdid_own, replace)":. csdid_plot, name(csdid_own, replace)}{p_end}
{phang2}{stata "csdid_event_plot, name(c1, replace)":. csdid_event_plot, name(c1, replace)}{p_end}

{pstd}The same, letting {cmd:csdid_event_plot} call {cmd:estat event}, with the average lines and their values{p_end}
{phang2}{stata "csdid_event_plot, avg avgpre avgvalues name(c2, replace)":. csdid_event_plot, avg avgpre avgvalues name(c2, replace)}{p_end}

{pstd}Normalise at t-1 with a universal base period (option {opt long2}); the baseline is then zero{p_end}
{phang2}{stata "csdid lemp lpop, ivar(countyreal) time(year) gvar(first_treat) method(dripw) long2":. csdid lemp lpop, ivar(countyreal) time(year) gvar(first_treat) method(dripw) long2}{p_end}
{phang2}{stata "csdid_event_plot, avg avgpre name(c3, replace)":. csdid_event_plot, avg avgpre name(c3, replace)}{p_end}

{pstd}After {opt wboot}, {cmd:estat event} still reports asymptotic intervals, and the plot shows these{p_end}
{phang2}{stata "csdid lemp lpop, ivar(countyreal) time(year) gvar(first_treat) method(dripw) wboot rseed(1) long2":. csdid lemp lpop, ivar(countyreal) time(year) gvar(first_treat) method(dripw) wboot rseed(1) long2}{p_end}
{phang2}{stata "csdid_event_plot, avg avgpre name(c4, replace)":. csdid_event_plot, avg avgpre name(c4, replace)}{p_end}

{pstd}Pointwise normal intervals instead, at the 90 and 95 percent levels, with shading and the baseline line{p_end}
{phang2}{stata "csdid_event_plot, level(90 95) shade vline name(c5, replace)":. csdid_event_plot, level(90 95) shade vline name(c5, replace)}{p_end}

{pstd}Display averages and joint tests in the Results window and as a note below the plot{p_end}
{phang2}{stata "csdid lemp lpop, ivar(countyreal) time(year) gvar(first_treat) method(dripw) long2":. csdid lemp lpop, ivar(countyreal) time(year) gvar(first_treat) method(dripw) long2}{p_end}
{phang2}{stata "csdid_event_plot, avg avgpre pvalues pnote name(c6, replace)":. csdid_event_plot, avg avgpre pvalues pnote name(c6, replace)}{p_end}

{pstd}Express the estimates in percent of a baseline mean of 12.5 and save the graph{p_end}
{phang2}{stata `"csdid_event_plot, pctof(12.5) avg export("event_study.png") name(c7, replace)"':. csdid_event_plot, pctof(12.5) avg export("event_study.png") name(c7, replace)}{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}Requires Stata 16 or newer and {cmd:csdid} (written for version 1.81, the version distributed at SSC).{p_end}

{pstd}{cmd:csdid_event_plot} reads {cmd:r()} of {cmd:estat event} when it is called directly afterwards, and the Results window states which source was used.
Any command that changes {cmd:r()} in between makes {cmd:csdid_event_plot} run {cmd:estat event} again with default options.
After the plot, {cmd:csdid_event_plot} returns the table, so that it can be called repeatedly with different options.
Other aggregations ({cmd:estat group}, {cmd:estat calendar}, {cmd:estat simple}) are not plotted.{p_end}

{pstd}The coefficients, standard errors, intervals and p-values are those of {cmd:estat event}.
The plot does not re-estimate anything.{p_end}

{pstd}This is a beta version. Please check the plotted values against the output of {cmd:estat event}.{p_end}


{title:Author}

{pstd}Jerg Gutmann{break}
{browse "https://github.com/jerggutmann/stata-tools"}{p_end}

{pstd}Licence: MIT, see {browse "https://github.com/jerggutmann/stata-tools/blob/main/LICENSE":LICENSE} in the repository.{p_end}

{title:Support and updates}

{pstd}Please report problems and suggestions at
{browse "https://github.com/jerggutmann/stata-tools/issues"}.
Re-run {cmd:net install csdid_event_plot, replace} to get the latest version.{p_end}


{title:Also see}

{psee}
Help: {help csdid} (if installed), {help did2s_plot} (if installed), {help french_plot} (if installed), {help lpdid_plot} (if installed), {help twoway_options}, {help graph_export}{p_end}

