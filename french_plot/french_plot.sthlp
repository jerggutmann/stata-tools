{smcl}
{* *! version 0.3.8  11oct2026  Jerg Gutmann}{...}
{vieweralsosee "did_multiplegt_dyn" "help did_multiplegt_dyn"}{...}
{vieweralsosee "[G-2] graph twoway" "help twoway"}{...}
{vieweralsosee "[G-2] graph export" "help graph_export"}{...}
{viewerjumpto "Syntax" "french_plot##syntax"}{...}
{viewerjumpto "Description" "french_plot##description"}{...}
{viewerjumpto "Options" "french_plot##options"}{...}
{viewerjumpto "Examples" "french_plot##examples"}{...}
{viewerjumpto "Remarks" "french_plot##remarks"}{...}
{title:Title}

{phang}{bf:french_plot} {hline 2} Event-study plot after {cmd:did_multiplegt_dyn}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:french_plot} [{cmd:,} {it:options}]{p_end}

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Contents}
{synopt:{opt eff:ects(#)}}number of effects estimated; default is all{p_end}
{synopt:{opt pla:cebo(#)}}number of placebos estimated; default is all{p_end}
{synopt:{opt showeff:ects(#)}}plot only the first {it:#} effects{p_end}
{synopt:{opt showpla:cebo(#)}}plot only the first {it:#} placebos{p_end}
{synopt:{opt avg}}add the average total effect{p_end}
{synopt:{opt avgp:re}}add the average placebo{p_end}
{synopt:{opt avgv:alues}}print the values of the average lines{p_end}
{synopt:{opt noci}}no confidence intervals{p_end}
{synopt:{opt norm:alci}}accepted for compatibility with the other plot commands; no effect{p_end}
{synopt:{opt cib:ars}}confidence intervals as bars{p_end}
{synopt:{opt le:vel(# [#])}}one or two confidence levels{p_end}
{synopt:{opt sc:ale(#)}}multiply all estimates by {it:#}{p_end}
{synopt:{opt pct:of(#)}}express estimates in percent of {it:#}{p_end}

{syntab:Statistics}
{synopt:{opt pva:lues}}display a table of estimates and p-values{p_end}
{synopt:{opt pno:te}}add p-values as a note below the plot{p_end}
{synopt:{opt fmt(%fmt)}}number format; default is {cmd:%5.3f}{p_end}

{syntab:Appearance}
{synopt:{opt shade}}shade the post-treatment area{p_end}
{synopt:{opt shadec:olor(colorstyle)}}colour of the shading; default is {cmd:gs12}{p_end}
{synopt:{opt vline}}vertical line between baseline and first effect{p_end}
{synopt:{opt col:or(string)}}colour of the series; default is {cmd:0 114 178}{p_end}
{synopt:{opt avgc:olor(string)}}colour of the average effect line{p_end}
{synopt:{opt precol:or(string)}}colour of the average placebo line{p_end}
{synopt:{opt ms:ymbol(symbolstyle)}}marker symbol; default is {cmd:o}{p_end}
{synopt:{opt lpa:ttern(patternstyle)}}line pattern of the series{p_end}
{synopt:{opt lw:idth(linewidthstyle)}}line width of the series{p_end}
{synopt:{opt avgl:pattern(patternstyle)}}line pattern of the average effect line{p_end}
{synopt:{opt prelp:attern(patternstyle)}}line pattern of the average placebo line{p_end}
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

{pstd}{cmd:french_plot} must be run directly after {helpb did_multiplegt_dyn}.{p_end}


{marker description}{...}
{title:Description}

{pstd}{cmd:french_plot} draws an event-study plot for a single event from the results of {cmd:did_multiplegt_dyn}.
It shows the dynamic effects and the placebos with confidence intervals.
The baseline period is plotted at -1, placebo {it:l} at -({it:l}+1) and effect {it:l} at {it:l}-1, labelled {it:l}.
Periods that could not be estimated appear as gaps.{p_end}

{pstd}Optionally, the plot also shows the average total effect and the average placebo as horizontal lines,
the corresponding p-values, and a shaded post-treatment area.
The plot does not compare two events.{p_end}

{pstd}The command reads the results from {cmd:e()} and does not change them.
It can therefore be called repeatedly with different options.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Contents}

{phang}{opt effects(#)} and {opt placebo(#)} give the number of effects and placebos.
By default, all effects and placebos stored by {cmd:did_multiplegt_dyn} ({cmd:e(effects)} and {cmd:e(placebo)}) are used.
Specify the numbers of the {cmd:did_multiplegt_dyn} command only if you want to override this.
{opt placebo(0)} is allowed.
A period that could not be estimated is shown as a gap, and a note reports how many.{p_end}

{phang}{opt showeffects(#)} and {opt showplacebo(#)} plot only the first {it:#} effects or placebos.
The default is to plot all.
{opt showeffects()} must be between 1 and {opt effects()}, and {opt showplacebo()} cannot exceed {opt placebo()}.{p_end}

{phang}{opt avg} adds the average total effect, {cmd:e(Av_tot_effect)},
as a dashed horizontal line over the post-treatment periods.
It is based on all estimated effects, also if fewer are shown with {opt showeffects()}.{p_end}

{phang}{opt avgpre} adds the average placebo as a dashed horizontal line over the pre-treatment periods.
The average placebo is the simple mean of the plotted placebo coefficients.
Its standard error is calculated from {cmd:e(V)}.
At least one placebo must be plotted.{p_end}

{phang}{opt avgvalues} prints the value of each average line next to its end.
It requires {opt avg} or {opt avgpre}.
It sets {cmd:xscale(range())}, so do not also pass {cmd:xscale()}.{p_end}

{phang}{opt noci} suppresses the confidence intervals.{p_end}

{phang}{opt cibars} draws the confidence intervals as bars instead of a shaded area.{p_end}

{phang}{opt normalci} is accepted so that the same command line works for all plot commands.
It has no effect here, because the intervals are always normal-based.{p_end}

{phang}{opt level(# [#])} sets the confidence level.
The default is 95, the default of {cmd:did_multiplegt_dyn}.
{cmd:did_multiplegt_dyn} does not store its confidence intervals in {cmd:e()}, so {cmd:french_plot} calculates them as {it:b} ± {it:z} × {it:se} from the stored standard errors.
At the default level this reproduces the intervals displayed by {cmd:did_multiplegt_dyn}.
If you ran {cmd:did_multiplegt_dyn} with {cmd:ci_level()}, specify the same level here.
Whenever the plotted intervals are not those displayed by the estimator, the command prints a note.
Here it does so on every call without {opt noci}.
With two values, for example {cmd:level(90 95)}, the smaller level is drawn as a darker inner band
and the larger as a lighter outer band.{p_end}

{phang}{opt scale(#)} multiplies all plotted and reported estimates and standard errors by {it:#}.{p_end}

{phang}{opt pctof(#)} expresses all estimates in percent of {it:#}, for example of the baseline mean of the outcome.
It is equivalent to {cmd:scale(100/}{it:#}{cmd:)}.
{opt scale()} and {opt pctof()} cannot be combined.
Neither changes the p-values.{p_end}

{dlgtab:Statistics}

{phang}{opt pvalues} displays a table in the Results window.
It contains the estimate, standard error and p-value of the average effect and of the average placebo,
and the p-values of the joint tests that all effects and all placebos are zero.
The joint tests are taken from {cmd:e(p_jointeffects)} and {cmd:e(p_jointplacebo)} and are shown if available.
The p-values are two-sided and based on the normal distribution.{p_end}

{phang}{opt pnote} adds the p-value of the average effect and the p-value of the joint placebo test
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
{opt avgcolor()} sets the colour of the average effect line; the default is {opt color()}.
{opt precolor()} sets the colour of the average placebo line; the default is {opt avgcolor()}.{p_end}

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
{cmd:type} ({cmd:placebo}, {cmd:baseline} or {cmd:effect}), {cmd:coefname} (name of the coefficient in {cmd:e()}), {cmd:b}, {cmd:se}, {cmd:lb}, {cmd:ub} and {cmd:p}.
With two levels, {cmd:lb} and {cmd:ub} belong to the larger level, and {cmd:lb_in} and {cmd:ub_in} to the smaller.
The data in memory are not changed.{p_end}

{phang}{opt export(filename)} saves the graph with {helpb graph export}.
The file type follows from the extension.
An existing file is replaced.{p_end}

{phang}{it:twoway_options} are all other options of {helpb twoway_options},
for example {cmd:name()}, {cmd:scheme()} or {cmd:title()}.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Load the example data of {cmd:did_multiplegt_dyn}{p_end}
{phang2}{cmd:. ssc install did_multiplegt_dyn}{p_end}
{phang2}{cmd:. net get did_multiplegt_dyn}{p_end}
{phang2}{cmd:. use favara_imbs_did_multiplegt_dyn.dta, clear}{p_end}

{pstd}Estimate eight effects and three placebos of banking deregulations on loan volume{p_end}
{phang2}{cmd:. did_multiplegt_dyn Dl_vloans_b county year inter_bra, effects(8) placebo(3) cluster(state_n)}{p_end}

{pstd}Plot them{p_end}
{phang2}{cmd:. french_plot, effects(8) placebo(3)}{p_end}

{pstd}Add the average effect and the average placebo, with their values{p_end}
{phang2}{cmd:. french_plot, effects(8) placebo(3) avg avgpre avgvalues}{p_end}

{pstd}Show the 90 and 95 percent confidence bands, shade the post-treatment area and add the baseline line{p_end}
{phang2}{cmd:. french_plot, effects(8) placebo(3) level(90 95) shade vline}{p_end}

{pstd}Display the p-values in the Results window and as a note below the plot{p_end}
{phang2}{cmd:. french_plot, effects(8) placebo(3) avg pvalues pnote}{p_end}

{pstd}Show only the first three effects and the first two placebos{p_end}
{phang2}{cmd:. french_plot, effects(8) placebo(3) showeffects(3) showplacebo(2)}{p_end}

{pstd}Express the estimates in percent of a baseline mean of 12.5{p_end}
{phang2}{cmd:. french_plot, effects(8) placebo(3) pctof(12.5)}{p_end}

{pstd}Change a caption and a legend label{p_end}
{phang2}{cmd:. french_plot, effects(8) placebo(3) avg postcaption("after the reform") lblavg("mean effect")}{p_end}

{pstd}Save the graph{p_end}
{phang2}{cmd:. french_plot, effects(8) placebo(3) avg export("event_study.png")}{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}Requires Stata 16 or newer.{p_end}

{pstd}The average placebo relies on the coefficient names that {cmd:did_multiplegt_dyn} stores in {cmd:e(b)},
for example {cmd:Placebo_1}.
The effects and placebos are read from {cmd:e(Effect_}{it:l}{cmd:)}, {cmd:e(se_effect_}{it:l}{cmd:)},
{cmd:e(Placebo_}{it:l}{cmd:)} and {cmd:e(se_placebo_}{it:l}{cmd:)}.{p_end}

{pstd}Standard errors, effects and placebos are those stored by {cmd:did_multiplegt_dyn}.
Its confidence intervals are not stored, so they are recalculated from the standard errors under the normal distribution (see {opt level()}).
This is a deviation from using the displayed output and is therefore announced by a note.
The p-values of the average effect and the average placebo are also calculated from the estimate and the standard error using the normal distribution.
The joint p-values are those stored by {cmd:did_multiplegt_dyn}.{p_end}

{pstd}This is a beta version. Please check the plotted values against the output of {cmd:did_multiplegt_dyn}.{p_end}


{title:Author}

{pstd}Jerg Gutmann{break}
{browse "https://github.com/jerggutmann/stata-tools"}{p_end}

{pstd}Licence: MIT, see {browse "https://github.com/jerggutmann/stata-tools/blob/main/LICENSE":LICENSE} in the repository.{p_end}

{title:Support and updates}

{pstd}Please report problems and suggestions at
{browse "https://github.com/jerggutmann/stata-tools/issues"}.
Re-run {cmd:net install french_plot, replace} to get the latest version.{p_end}


{title:Also see}

{psee}
Help: {help did_multiplegt_dyn} (if installed), {help twoway_options}, {help graph_export}{p_end}
