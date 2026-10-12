{smcl}
{* *! version 0.1.0  11oct2026  Jerg Gutmann}{...}
{vieweralsosee "did_multiplegt_dyn" "help did_multiplegt_dyn"}{...}
{vieweralsosee "dcdh_plot" "help dcdh_plot"}{...}
{vieweralsosee "[G-2] graph twoway" "help twoway"}{...}
{vieweralsosee "[G-2] graph export" "help graph_export"}{...}
{vieweralsosee "[R] estimates store" "help estimates_store"}{...}
{viewerjumpto "Syntax" "dcdh_compare##syntax"}{...}
{viewerjumpto "Description" "dcdh_compare##description"}{...}
{viewerjumpto "Options" "dcdh_compare##options"}{...}
{viewerjumpto "Examples" "dcdh_compare##examples"}{...}
{viewerjumpto "Stored results" "dcdh_compare##results"}{...}
{viewerjumpto "Remarks" "dcdh_compare##remarks"}{...}
{title:Title}

{phang}{bf:dcdh_compare} {hline 2} Two {cmd:did_multiplegt_dyn} models in one event-study plot


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:dcdh_compare}
{cmd:(}{it:Y G T D} [{it:if}] [{it:in}] [{cmd:,} {it:did_options}]{cmd:)}
{cmd:(}{it:Y G T D} [{it:if}] [{it:in}] [{cmd:,} {it:did_options}]{cmd:)}
[{cmd:,} {it:plot_options}]{p_end}

{p 8 17 2}{cmd:dcdh_compare}{cmd:,} {opt redraw} [{it:plot_options}]{p_end}

{pstd}Each pair of parentheses contains a complete {helpb did_multiplegt_dyn} specification:
everything you would type after {cmd:did_multiplegt_dyn}.
The two models may differ in any respect (outcome, treatment, sample, controls, options).
{it:did_options} are the options of {cmd:did_multiplegt_dyn}; they belong to one model only and stay inside its parentheses.
{it:plot_options} after the last comma control the joint plot and apply to both models; they are listed below.{p_end}

{synoptset 26 tabbed}{...}
{synopthdr:plot_options}
{synoptline}
{syntab:Contents}
{synopt:{opt redraw}}plot the stored results again without re-estimating{p_end}
{synopt:{opt showeff:ects(#)}}plot only the first {it:#} effects{p_end}
{synopt:{opt showpla:cebo(#)}}plot only the first {it:#} placebos{p_end}
{synopt:{opt avg}}add the average total effect of each model{p_end}
{synopt:{opt avgp:re}}add the average placebo of each model{p_end}
{synopt:{opt avgv:alues}}print the values of the average lines{p_end}
{synopt:{opt noci}}no confidence intervals{p_end}
{synopt:{opt norm:alci}}accepted for compatibility with the other plot commands; no effect{p_end}
{synopt:{opt cib:ars}}confidence intervals as bars{p_end}
{synopt:{opt le:vel(# [#])}}one or two confidence levels{p_end}
{synopt:{opt sc:ale(# [#])}}multiply the estimates by {it:#}; one value per model or one for both{p_end}
{synopt:{opt pct:of(# [#])}}express estimates in percent of {it:#}; one value per model or one for both{p_end}

{syntab:Statistics}
{synopt:{opt pva:lues}}display a table of estimates and p-values for each model{p_end}
{synopt:{opt pno:te}}add p-values as a note below the plot{p_end}
{synopt:{opt fmt(%fmt)}}number format; default is {cmd:%5.3f}{p_end}

{syntab:Appearance}
{synopt:{opt lbl1(string)}, {opt lbl2(string)}}names of the models; default {cmd:model 1}, {cmd:model 2}{p_end}
{synopt:{opt color1(string)}, {opt color2(string)}}colors; default {cmd:0 114 178} and {cmd:213 94 0}{p_end}
{synopt:{opt msymbol1()}, {opt msymbol2()}}marker symbols; default {cmd:o} and {cmd:d}{p_end}
{synopt:{opt shade}}shade the post-treatment area{p_end}
{synopt:{opt shadec:olor(colorstyle)}}color of the shading; default is {cmd:gs12}{p_end}
{synopt:{opt vline}}vertical line between baseline and first effect{p_end}
{synopt:{opt lpa:ttern(patternstyle)}}line pattern of both series{p_end}
{synopt:{opt lw:idth(linewidthstyle)}}line width of both series{p_end}
{synopt:{opt avgl:pattern(patternstyle)}}line pattern of the average effect lines{p_end}
{synopt:{opt prelp:attern(patternstyle)}}line pattern of the average placebo lines{p_end}
{synopt:{opt cio:pacity(#)}}opacity of the confidence bands in percent; default is {cmd:20}{p_end}
{synopt:{opt noz:ero}}no zero line{p_end}
{synopt:{opt nocap:tions}}no pre-/post-treatment captions{p_end}
{synopt:{opt precap:tion(string)}}text of the pre-treatment caption{p_end}
{synopt:{opt postcap:tion(string)}}text of the post-treatment caption{p_end}
{synopt:{opt noleg:end}}no legend{p_end}
{synopt:{opt lbla:vg(string)}}legend label of the average effects{p_end}
{synopt:{opt lblp:re(string)}}legend label of the average placebos{p_end}
{synopt:{opt yti:tle(string)}}title left of the y-axis; default is none{p_end}
{synopt:{opt xti:tle(string)}}title of the x-axis; default is none{p_end}
{synopt:{opt ylab(rule)}}y-axis labels; requires {opt tpos()}{p_end}
{synopt:{opt tpos(#)}}y-position of the captions{p_end}

{syntab:Output}
{synopt:{opt stub(name)}}prefix of the names of graphs and stored estimates; default is {cmd:dc}{p_end}
{synopt:{opt name(name[, replace])}}name of the joint graph; default is {it:stub}{cmd:_compare}{p_end}
{synopt:{opt saved:ata(filename)}}save the plotted data{p_end}
{synopt:{opt exp:ort(filename)}}save the joint graph{p_end}
{synopt:{it:twoway_options}}other options of {helpb twoway_options}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}{cmd:dcdh_compare} estimates two models with {helpb did_multiplegt_dyn} and draws their event studies in one plot.
The plot has the layout and options of {helpb dcdh_plot}:
the baseline period is at -1, placebo {it:l} at -({it:l}+1) and effect {it:l} at {it:l}-1, labeled {it:l}.
Each model has its own color and marker; a legend identifies them.{p_end}

{pstd}The output of both estimations appears in the Results window.
The graphs that {cmd:did_multiplegt_dyn} draws itself are kept under the names {it:stub}{cmd:_m1} and {it:stub}{cmd:_m2},
so that they can be compared with the joint graph ({it:stub}{cmd:_compare}).
The results of both models are stored with {helpb estimates store} under the same names.
After the command, the results of model 1 are active.{p_end}

{pstd}The plot covers the longer of the two event-time ranges.
If one model has fewer effects or placebos, they are simply not drawn for that model, and a note says so.
The automatic y-axis covers the intervals and average lines of both models and zero.{p_end}


{marker options}{...}
{title:Options}

{pstd}All {it:plot_options} have the same meaning as the options of {helpb dcdh_plot}, except those listed here.
{cmd:effects()} and {cmd:placebo()} of {cmd:dcdh_plot} are not needed; they are part of each model specification.{p_end}

{dlgtab:Contents}

{phang}{opt redraw} draws the joint graph again from the results stored by the last call of {cmd:dcdh_compare} (with the same {opt stub()}),
without estimating the models again.
This makes it quick to change the options of the graph.
Model specifications in parentheses are ignored with {opt redraw} (a note says so); both models enter unchanged.
To change a model, run {cmd:dcdh_compare} with both models again.
If the stored results are not found, the command stops with an error.
The labels {opt lbl1()} and {opt lbl2()} and the {cmd:ci_level()} of the models are kept from the original call unless you specify them again.{p_end}

{phang}{opt showeffects(#)} and {opt showplacebo(#)} limit the plot for both models to the first {it:#} effects or placebos.
By default, the plot covers all effects and placebos of the model with more of them.
A model with fewer effects or placebos than {it:#} is drawn with the ones it has.{p_end}

{phang}{opt avg} and {opt avgpre} add the average total effect and the average placebo of each model, in the color of the model.
The line of a model covers only the periods plotted for that model.
If a model has no average total effect (for example with {cmd:trends_lin}), its line is omitted and a note says so;
its place in the legend is left empty.{p_end}

{phang}{opt avgvalues} prints the values of the average lines next to their ends.
It requires {opt avg} or {opt avgpre}.
If the lines of the two models are close, the values are moved apart vertically.
It sets {cmd:xscale(range())}, so do not also pass {cmd:xscale()}.{p_end}

{phang}{opt noci} suppresses the confidence intervals.{p_end}

{phang}{opt normalci} is accepted so that the same command line works for all plot commands.
It has no effect here, because the intervals are always normal-based.{p_end}

{phang}{opt cibars} draws the confidence intervals as bars instead of a shaded area.
The two models are then shifted slightly to the left and right so that their bars do not overlap.
The saved data ({opt savedata()}) contain the unshifted positions.{p_end}

{phang}{opt level(# [#])} sets the confidence level.
{cmd:did_multiplegt_dyn} does not store its confidence intervals, so {cmd:dcdh_compare} calculates them as {it:b} ± {it:z} × {it:se}.
By default, the level is the {cmd:ci_level()} of the two models (95 unless specified there),
so the intervals are identical to those displayed by {cmd:did_multiplegt_dyn}; a note says so.
If the two models use different {cmd:ci_level()}, specify {opt level()}.
If the plotted level differs from that of the models, a note says that the intervals are not those displayed by {cmd:did_multiplegt_dyn}.{p_end}

{phang}{opt scale(# [#])} and {opt pctof(# [#])} rescale the estimates.
With one value, it applies to both models; with two values, the first applies to model 1 and the second to model 2.
This allows, for example, to express two different outcomes in standard deviations of each outcome
or in percent of their own baseline means.{p_end}

{dlgtab:Statistics}

{phang}{opt pvalues} displays the table of {helpb dcdh_plot} once for each model.{p_end}

{phang}{opt pnote} adds one line per model below the plot,
with the average effect, its p-value and the p-value of the joint placebo test.
It uses the {cmd:note()} option of the graph, so do not also pass {cmd:note()}.{p_end}

{phang}{opt fmt(%fmt)} sets the number format of the values and p-values.
The default is {cmd:%5.3f}.
The p-values are two-sided and based on the normal distribution.{p_end}

{pstd}{cmd:dcdh_compare} does not test whether the two models differ.
The models can be specified freely (different samples, outcomes or treatments),
so a valid test of their difference depends on the application.{p_end}

{dlgtab:Appearance}

{phang}{opt lbl1()} and {opt lbl2()} name the models in the legend, in the tables and in the note.{p_end}

{phang}{opt color1()}, {opt color2()}, {opt msymbol1()} and {opt msymbol2()} set the color and marker of each model.
Give colors as RGB triples in quotes, as in {cmd:color1("0 114 178")}.{p_end}

{phang}{opt shade} shades the post-treatment area.
{opt shadecolor()} changes the color; the default is {cmd:gs12}.
The shading and {opt vline} follow the automatically chosen y-axis,
so neither can be combined with {opt ylab()}.{p_end}

{phang}{opt vline} draws a vertical dashed line between the baseline and the first effect.{p_end}

{phang}{opt lpattern()} and {opt lwidth()} set the line pattern and line width of the series of both models.
{opt avglpattern()} and {opt prelpattern()} set the line patterns of the average effect lines and the average placebo lines;
the defaults are {cmd:dash} and {cmd:shortdash}.{p_end}

{phang}{opt ciopacity(#)} sets the opacity of the confidence bands in percent.
The default is 20.
With two levels, the inner band is drawn with twice this opacity, up to 100.
The bands of the two models overlap and remain visible.{p_end}

{phang}{opt nozero} suppresses the horizontal line at zero.{p_end}

{phang}{opt nocaptions} suppresses the captions "pre-treatment" and "post-treatment".
{opt precaption()} and {opt postcaption()} change their text.
Unless you set {opt tpos()}, the captions are placed just above the top y-axis label.{p_end}

{phang}{opt ytitle(string)} and {opt xtitle(string)} add titles to the axes.
By default, neither axis has a title.{p_end}

{phang}{opt ylab(rule)} sets the y-axis labels, for example {cmd:ylab(-1(.5)1)}.
It requires {opt tpos(#)}, the y-position of the captions.
By default, a rounded range is chosen automatically.
It covers the estimates, the intervals, the average lines of both models and zero.{p_end}

{phang}{opt nolegend} suppresses the legend.
Unlike in {cmd:dcdh_plot}, the legend is always drawn otherwise.
It has one column per model.{p_end}

{dlgtab:Output}

{phang}{opt stub(name)} sets the prefix of the names under which the graphs of {cmd:did_multiplegt_dyn}, the joint graph and the stored estimates are kept.
The default is {cmd:dc}, giving {cmd:dc_m1}, {cmd:dc_m2} and {cmd:dc_compare}.
Existing graphs and stored estimates with these names are replaced.
If a model is specified with {cmd:graph_off}, there is no graph of that model to keep.{p_end}

{phang}{opt name()} names the joint graph, overriding {it:stub}{cmd:_compare}.{p_end}

{phang}{opt savedata(filename)} saves the plotted data as in {cmd:dcdh_plot},
with the additional variable {cmd:model} (1 or 2).
The variables are {cmd:x}, {cmd:eventtime}, {cmd:type}, {cmd:coefname}, {cmd:b}, {cmd:se}, {cmd:lb}, {cmd:ub} and {cmd:p};
with two levels, {cmd:lb} and {cmd:ub} belong to the larger level, and {cmd:lb_in} and {cmd:ub_in} to the smaller.
The data in memory are not changed.{p_end}

{phang}{opt export(filename)} saves the joint graph with {helpb graph export}.
The file type follows from the extension.
An existing file is replaced.{p_end}

{phang}{it:twoway_options} are all other options of {helpb twoway_options}, for example {cmd:scheme()} or {cmd:title()}.
{cmd:name()} is set by {opt name()} above.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Install {cmd:did_multiplegt_dyn} and load its example data{p_end}
{phang2}{stata "ssc install did_multiplegt_dyn":. ssc install did_multiplegt_dyn}{p_end}
{phang2}{stata "net get did_multiplegt_dyn":. net get did_multiplegt_dyn}{p_end}
{phang2}{stata "use favara_imbs_did_multiplegt_dyn.dta, clear":. use favara_imbs_did_multiplegt_dyn.dta, clear}{p_end}

{pstd}Specify the models and the legend labels as global macros.
Model 1 uses all not-yet-switchers as controls (the default), model 2 only never-switchers{p_end}
{phang2}{stata "global mod1 Dl_vloans_b county year inter_bra, effects(8) placebo(3) cluster(state_n)":. global mod1 Dl_vloans_b county year inter_bra, effects(8) placebo(3) cluster(state_n)}{p_end}
{phang2}{stata "global mod2 $mod1 only_never_switchers":. global mod2 $mod1 only_never_switchers}{p_end}
{phang2}{stata `"global lab1 lbl1("not-yet-switchers") lbl2("never-switchers")"':. global lab1 lbl1("not-yet-switchers") lbl2("never-switchers")}{p_end}

{pstd}Effects of banking deregulations on loan volume, estimated with both control groups.
Each call of {cmd:dcdh_compare} runs both estimations.
The graphs of {cmd:did_multiplegt_dyn} are kept as {cmd:dc_m1} and {cmd:dc_m2}, the joint graph as {cmd:dc_compare}{p_end}
{phang2}{stata "dcdh_compare ($mod1) ($mod2), $lab1":. dcdh_compare ($mod1) ($mod2), $lab1}{p_end}

{pstd}The same with the average lines and their values, the p-values, and other names for the graphs and estimates{p_end}
{phang2}{stata "dcdh_compare ($mod1) ($mod2), $lab1 avg avgpre avgvalues pvalues pnote stub(dc2)":. dcdh_compare ($mod1) ($mod2), $lab1 avg avgpre avgvalues pvalues pnote stub(dc2)}{p_end}

{pstd}Intervals as bars at the 90 and 95 percent levels, with shading and the baseline line{p_end}
{phang2}{stata "dcdh_compare ($mod1) ($mod2), $lab1 cibars level(90 95) shade vline stub(dc3)":. dcdh_compare ($mod1) ($mod2), $lab1 cibars level(90 95) shade vline stub(dc3)}{p_end}

{pstd}Change only the graph, without estimating again: the stored results of the first example are plotted with the average lines and shading{p_end}
{phang2}{stata "dcdh_compare, redraw avg avgpre shade":. dcdh_compare, redraw avg avgpre shade}{p_end}

{pstd}Two outcomes, loan volume and house prices (the third example of the help of {cmd:did_multiplegt_dyn}).
Their scales differ a lot (the standard deviation of {cmd:Dl_hpi} is about a tenth of that of {cmd:Dl_vloans_b}),
so both are expressed in standard deviations of their outcome with {opt scale()}, one value per model{p_end}
{phang2}{stata "quietly summarize Dl_vloans_b":. quietly summarize Dl_vloans_b}{p_end}
{phang2}{stata "global sd1 = 1/r(sd)":. global sd1 = 1/r(sd)}{p_end}
{phang2}{stata "quietly summarize Dl_hpi":. quietly summarize Dl_hpi}{p_end}
{phang2}{stata "global sd2 = 1/r(sd)":. global sd2 = 1/r(sd)}{p_end}
{phang2}{stata "global mod3 Dl_hpi county year inter_bra, effects(8) placebo(3) cluster(state_n)":. global mod3 Dl_hpi county year inter_bra, effects(8) placebo(3) cluster(state_n)}{p_end}
{phang2}{stata `"global lab2 lbl1("loan volume") lbl2("house prices") ytitle("standard deviations")"':. global lab2 lbl1("loan volume") lbl2("house prices") ytitle("standard deviations")}{p_end}
{phang2}{stata "dcdh_compare ($mod1) ($mod3), $lab2 scale($sd1 $sd2) avg stub(dc4)":. dcdh_compare ($mod1) ($mod3), $lab2 scale($sd1 $sd2) avg stub(dc4)}{p_end}

{pstd}Switch to the stored results of model 2 of the first example{p_end}
{phang2}{stata "estimates restore dc_m2":. estimates restore dc_m2}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}{cmd:dcdh_compare} stores the following in {cmd:r()}:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(est1)}, {cmd:r(est2)}}names of the stored estimates of model 1 and model 2{p_end}
{synopt:{cmd:r(graph1)}, {cmd:r(graph2)}}names of the graphs of {cmd:did_multiplegt_dyn} (if drawn){p_end}
{synopt:{cmd:r(level)}}plotted confidence level(s){p_end}
{p2colreset}{...}

{pstd}The results of model 1 are active in {cmd:e()}; both models are stored with {helpb estimates store}.{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}Requires Stata 16 or newer. The estimation command {cmd:did_multiplegt_dyn} must be installed. It may require further packages, as documented by its authors.{p_end}

{pstd}The options {cmd:by()} and {cmd:by_path()} of {cmd:did_multiplegt_dyn} are not supported, because they produce several sets of estimates per model.{p_end}

{pstd}The effects and placebos are read from {cmd:e(Effect_}{it:l}{cmd:)}, {cmd:e(se_effect_}{it:l}{cmd:)},
{cmd:e(Placebo_}{it:l}{cmd:)} and {cmd:e(se_placebo_}{it:l}{cmd:)} of each model, as in {helpb dcdh_plot}.
The p-values of the average effect and the average placebo are calculated from the estimate and the standard error using the normal distribution;
the joint p-values are those stored by {cmd:did_multiplegt_dyn}.{p_end}

{pstd}This is a beta version. Please check the plotted values against the output of {cmd:did_multiplegt_dyn}.{p_end}


{title:Author}

{pstd}Jerg Gutmann{break}
{browse "https://github.com/jerggutmann/stata-tools"}{p_end}

{pstd}License: MIT, see {browse "https://github.com/jerggutmann/stata-tools/blob/main/LICENSE":LICENSE} in the repository.{p_end}

{title:Support and updates}

{pstd}Please report problems and suggestions at
{browse "https://github.com/jerggutmann/stata-tools/issues"}.
Re-run {cmd:net install dcdh_compare, replace} to get the latest version.{p_end}

{title:Also see}

{psee}
Help: {help did_multiplegt_dyn} (if installed), {help dcdh_plot} (if installed), {help estimates_store}, {help twoway_options}, {help graph_export}{p_end}
