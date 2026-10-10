{smcl}
{* *! version 0.2.0  11oct2026  Jerg Gutmann}{...}
{vieweralsosee "lpdid" "help lpdid"}{...}
{vieweralsosee "lpdid_plot" "help lpdid_plot"}{...}
{vieweralsosee "[G-2] graph twoway" "help twoway"}{...}
{vieweralsosee "[G-2] graph export" "help graph_export"}{...}
{viewerjumpto "Syntax" "lpdid_plot##syntax"}{...}
{viewerjumpto "Description" "lpdid_plot##description"}{...}
{viewerjumpto "Options" "lpdid_plot##options"}{...}
{viewerjumpto "Examples" "lpdid_plot##examples"}{...}
{viewerjumpto "Remarks" "lpdid_plot##remarks"}{...}
{title:Title}

{phang}{bf:lpdid_plot} {hline 2} Event-study plot after {cmd:lpdid}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:lpdid_plot} [{cmd:,} {it:options}]{p_end}

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Contents}
{synopt:{opt pre(#)}}number of pre-treatment periods used in {cmd:lpdid}; default is all{p_end}
{synopt:{opt post(#)}}number of post-treatment periods used in {cmd:lpdid}; default is all{p_end}
{synopt:{opt showpre(#)}}plot only pre-treatment periods up to {it:#}{p_end}
{synopt:{opt showpost(#)}}plot only post-treatment periods up to {it:#}{p_end}
{synopt:{opt avg}}add the pooled post-treatment effect{p_end}
{synopt:{opt avgp:re}}add the pooled pre-treatment estimate{p_end}
{synopt:{opt avgv:alues}}print the values of the average lines{p_end}
{synopt:{opt noci}}no confidence intervals{p_end}
{synopt:{opt cib:ars}}confidence intervals as bars{p_end}
{synopt:{opt norm:alci}}normal-based instead of {cmd:lpdid} confidence intervals{p_end}
{synopt:{opt le:vel(# [#])}}one or two confidence levels; implies {opt normalci}{p_end}
{synopt:{opt sc:ale(#)}}multiply all estimates by {it:#}{p_end}
{synopt:{opt pct:of(#)}}express estimates in percent of {it:#}{p_end}

{syntab:Statistics}
{synopt:{opt pva:lues}}display a table of pooled estimates and p-values{p_end}
{synopt:{opt pno:te}}add pooled p-values as a note below the plot{p_end}
{synopt:{opt fmt(%fmt)}}number format; default is {cmd:%5.3f}{p_end}

{syntab:Appearance}
{synopt:{opt shade}}shade the post-treatment area{p_end}
{synopt:{opt shadec:olor(colorstyle)}}colour of the shading; default is {cmd:gs12}{p_end}
{synopt:{opt vline}}vertical line between baseline and first effect{p_end}
{synopt:{opt col:or(string)}}colour of the series; default is {cmd:0 114 178}{p_end}
{synopt:{opt avgc:olor(string)}}colour of the pooled post-treatment line{p_end}
{synopt:{opt precol:or(string)}}colour of the pooled pre-treatment line{p_end}
{synopt:{opt ms:ymbol(symbolstyle)}}marker symbol; default is {cmd:o}{p_end}
{synopt:{opt lpa:ttern(patternstyle)}}line pattern of the series{p_end}
{synopt:{opt lw:idth(linewidthstyle)}}line width of the series{p_end}
{synopt:{opt avgl:pattern(patternstyle)}}line pattern of the pooled post-treatment line{p_end}
{synopt:{opt prelp:attern(patternstyle)}}line pattern of the pooled pre-treatment line{p_end}
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

{pstd}{cmd:lpdid_plot} must be run directly after {helpb lpdid}.
The options {opt avg}, {opt avgpre}, {opt pvalues} and {opt pnote} need the pooled estimates, so run {cmd:lpdid} with option {opt pooled}.{p_end}


{marker description}{...}
{title:Description}

{pstd}{cmd:lpdid_plot} draws an event-study plot for a single event from the results of {cmd:lpdid}.
It is the counterpart of {helpb french_plot}, which does the same after {cmd:did_multiplegt_dyn}.
Both commands use the same layout, axis positions, defaults and options,
so that figures from the two estimators can be compared directly.{p_end}

{pstd}The baseline period is plotted at -1, {cmd:pre}{it:n} at -{it:n} and {cmd:tau}{it:k} at {it:k}, labelled {it:k}+1.
This is the position of placebo {it:l} at -({it:l}+1) and of effect {it:l} at {it:l}-1 in {helpb french_plot}.
The baseline is set to zero.
Periods that are missing in {cmd:e(results)} appear as gaps.{p_end}

{pstd}Optionally, the plot also shows the pooled post-treatment and pre-treatment estimates of {cmd:lpdid} as horizontal lines,
the corresponding p-values, and a shaded post-treatment area.
The command reads the results from {cmd:e()} and does not change them.
It can therefore be called repeatedly with different options.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Contents}

{phang}{opt pre(#)} and {opt post(#)} give the numbers of pre- and post-treatment periods.
By default, the windows stored by {cmd:lpdid} ({cmd:e(pre_window)} and {cmd:e(post_window)}) are used.
Specify the numbers of the {cmd:lpdid} command only if you want to override this.
{opt pre(1)} is allowed and shows only the baseline.
{cmd:pre(}{it:U}{cmd:)} corresponds to {cmd:placebo(}{it:U}-1{cmd:)}
and {cmd:post(}{it:T}-1{cmd:)} to {cmd:effects(}{it:T}{cmd:)}
in {helpb french_plot}.{p_end}

{phang}{opt showpre(#)} and {opt showpost(#)} restrict the plot to the pre-treatment periods {cmd:pre2}, ..., {cmd:pre}{it:#}
and the post-treatment periods {cmd:tau0}, ..., {cmd:tau}{it:#}.
The default is to plot all.
{opt showpre()} must be between 1 and {opt pre()}, and {opt showpost()} cannot exceed {opt post()}.{p_end}

{phang}{opt avg} adds the pooled post-treatment estimate, row 2 of {cmd:e(pooled_results)},
as a dashed horizontal line over the post-treatment periods.
It is calculated by {cmd:lpdid} from all post-treatment periods, also if fewer are shown with {opt showpost()}.{p_end}

{phang}{opt avgpre} adds the pooled pre-treatment estimate, row 1 of {cmd:e(pooled_results)},
as a dashed horizontal line over the pre-treatment periods.
It is calculated by {cmd:lpdid} from all pre-treatment periods, also if fewer are shown with {opt showpre()}.
At least one placebo ({opt showpre(2)} or more) must be plotted.{p_end}

{phang}{opt avgvalues} prints the value of each average line next to its end.
It requires {opt avg} or {opt avgpre}.
It sets {cmd:xscale(range())}, so do not also pass {cmd:xscale()}.{p_end}

{phang}{opt noci} suppresses the confidence intervals.{p_end}

{phang}{opt cibars} draws the confidence intervals as bars instead of a shaded area.{p_end}

{phang}{opt normalci} replaces the confidence intervals of {cmd:lpdid} with normal-based intervals,
{it:b} ± {it:z} × {it:se}.
By default, the plot uses the intervals stored in {cmd:e(results)} ({cmd:ci_low}, {cmd:ci_high}),
which have the level chosen in {cmd:lpdid} and are based on its t distribution.
The default p-values are also those of {cmd:lpdid}.
{opt normalci} is needed for exactly the same intervals as in {helpb french_plot}.{p_end}

{phang}{opt level(# [#])} sets the confidence level and implies {opt normalci}.
Without {opt level()} and {opt normalci}, the intervals are those of {cmd:lpdid}, with the level chosen there (default 95).
Whenever the plotted intervals are not those of {cmd:lpdid}, the command prints a note that says why.
With {opt normalci} alone, the level is 95, the default of {cmd:lpdid}; if you ran {cmd:lpdid} with {cmd:level()}, specify the same level here.
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
It contains the estimate, standard error and p-value of the pooled post-treatment estimate (average effect)
and of the pooled pre-treatment estimate (average placebo), both from {cmd:e(pooled_results)}.
If {cmd:lpdid} was run with {opt pretrend_test}, the p-value of its joint test that all pre-treatment coefficients are zero ({cmd:e(pretrend_p)}) is added.
The p-values are two-sided and based on the normal distribution.{p_end}

{phang}{opt pnote} adds the p-value of the pooled post-treatment estimate and, if available, the p-value of the joint pre-trend test
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
{opt avgcolor()} sets the colour of the pooled post-treatment line; the default is {opt color()}.
{opt precolor()} sets the colour of the pooled pre-treatment line; the default is {opt avgcolor()}.{p_end}

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
{cmd:coefname} (row name in {cmd:e(results)}), {cmd:b}, {cmd:se}, {cmd:lb}, {cmd:ub} and {cmd:p}.
With two levels, {cmd:lb} and {cmd:ub} belong to the larger level, and {cmd:lb_in} and {cmd:ub_in} to the smaller.
The data in memory are not changed.{p_end}

{phang}{opt export(filename)} saves the graph with {helpb graph export}.
The file type follows from the extension.
An existing file is replaced.{p_end}

{phang}{it:twoway_options} are all other options of {helpb twoway_options},
for example {cmd:name()}, {cmd:scheme()} or {cmd:title()}.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Load the example data of {cmd:lpdid}{p_end}
{phang2}{cmd:. use http://fmwww.bc.edu/repec/bocode/l/lpdidtestdata1.dta, clear}{p_end}

{pstd}Estimate five pre-treatment and ten post-treatment periods; {opt pooled} stores the pooled estimates (the graph of {cmd:lpdid} appears; the next line keeps it under the name {cmd:lpdid_own} for comparison with the plots below){p_end}
{phang2}{cmd:. lpdid Y, time(time) unit(unit) treat(treat) pre(5) post(10) pooled}{p_end}
{phang2}{cmd:. graph rename Graph lpdid_own, replace}{p_end}

{pstd}Plot them (same as {cmd:french_plot, effects(11) placebo(4)}){p_end}
{phang2}{cmd:. lpdid_plot, pre(5) post(10) name(l1, replace)}{p_end}

{pstd}Add the pooled estimates, with their values{p_end}
{phang2}{cmd:. lpdid_plot, pre(5) post(10) avg avgpre avgvalues name(l2, replace)}{p_end}

{pstd}Use normal-based intervals, for exact comparability with {cmd:french_plot}{p_end}
{phang2}{cmd:. lpdid_plot, pre(5) post(10) normalci name(l3, replace)}{p_end}

{pstd}Show the 90 and 95 percent confidence bands, shade the post-treatment area and add the baseline line{p_end}
{phang2}{cmd:. lpdid_plot, pre(5) post(10) level(90 95) shade vline name(l4, replace)}{p_end}

{pstd}Display the p-values in the Results window and as a note below the plot{p_end}
{phang2}{cmd:. lpdid_plot, pre(5) post(10) avg avgpre pvalues pnote name(l5, replace)}{p_end}

{pstd}Show only {cmd:pre2}, {cmd:pre3} and {cmd:tau0} to {cmd:tau2}{p_end}
{phang2}{cmd:. lpdid_plot, pre(5) post(10) showpre(3) showpost(2) name(l6, replace)}{p_end}

{pstd}Express the estimates in percent of a baseline mean of 12.5{p_end}
{phang2}{cmd:. lpdid_plot, pre(5) post(10) pctof(12.5) name(l7, replace)}{p_end}

{pstd}Change a caption and a legend label{p_end}
{phang2}{cmd:. lpdid_plot, pre(5) post(10) avg postcaption("after the reform") lblavg("mean effect") name(l8, replace)}{p_end}

{pstd}Save the graph{p_end}
{phang2}{cmd:. lpdid_plot, pre(5) post(10) avg export("event_study.png") name(l9, replace)}{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}Requires Stata 16 or newer.{p_end}

{pstd}The coefficients are read from {cmd:e(results)}, where {cmd:lpdid} stores them in rows named {cmd:pre}{it:n} and {cmd:tau}{it:k},
with the estimate in column 1 and the standard error in column 2.
The pooled estimates are read from {cmd:e(pooled_results)} (row 1: pre-treatment, row 2: post-treatment).
In current versions of {cmd:lpdid} this matrix exists only if {cmd:lpdid} was run with option {opt pooled} (or {opt pre_pooled()}, {opt post_pooled()}, {opt only_pooled}).
If you restrict the pooled windows there, the lines show those windows.
{cmd:pre1} is the omitted baseline and is plotted as zero.
By default, the confidence intervals and p-values are those stored by {cmd:lpdid} (columns {cmd:ci_low}, {cmd:ci_high} and {cmd:p}).
With {opt normalci} or {opt level()}, they are calculated from the estimate and the standard error using the normal distribution, as in {helpb french_plot}.{p_end}

{pstd}The joint test of the pre-treatment coefficients is only reported if {cmd:lpdid} was run with {opt pretrend_test}; it covers all pre-treatment coefficients, also if fewer are shown.
{cmd:lpdid} does not store a joint test of the post-treatment coefficients.{p_end}

{pstd}This is a beta version. Please check the plotted values against the output of {cmd:lpdid}.{p_end}


{title:Author}

{pstd}Jerg Gutmann{break}
{browse "https://github.com/jerggutmann/stata-tools"}{p_end}

{pstd}Licence: MIT, see {browse "https://github.com/jerggutmann/stata-tools/blob/main/LICENSE":LICENSE} in the repository.{p_end}

{title:Support and updates}

{pstd}Please report problems and suggestions at
{browse "https://github.com/jerggutmann/stata-tools/issues"}.
Re-run {cmd:net install lpdid_plot, replace} to get the latest version.{p_end}


{title:Also see}

{psee}
Help: {help lpdid} (if installed), {help french_plot} (if installed), {help twoway_options}, {help graph_export}{p_end}
