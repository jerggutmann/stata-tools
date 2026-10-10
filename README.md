# stata-tools

Small Stata programs by Jerg Gutmann. Each package lives in its own folder and is installed with `net install` from that folder. All packages are released under the MIT licence, see [Licence](#licence).

## Contents

| Package | Purpose |
|---|---|
| [`french_plot`](#french_plot) | event-study plot after `did_multiplegt_dyn` |
| [`lpdid_plot`](#lpdid_plot) | event-study plot after `lpdid`, same layout as `french_plot` |
| [`did2s_plot`](#did2s_plot) | event-study plot after `did2s`, same layout as `french_plot` |
| [`cname_std`](#cname_std) | standardize spellings of country names |

## french_plot

Version 0.3.7 (beta). Package folder: [`french_plot/`](french_plot/).

Event-study plot after `did_multiplegt_dyn` (one event). Shows the dynamic effects and placebos with confidence intervals, and optionally the average total effect, the pooled placebo, p-values and more.

**This is a beta version and has not been extensively tested. Please check results against the `did_multiplegt_dyn` output and report problems via GitHub issues.**

### Installation

```stata
net install french_plot, from("https://raw.githubusercontent.com/jerggutmann/stata-tools/main/french_plot/") replace
```

Re-run the same line to update. Remove with `ado uninstall french_plot`.

### Usage

Specify `effects()` and `placebo()` exactly as in the estimation command:

```stata
did_multiplegt_dyn y id t d, effects(5) placebo(3) cluster(id)
french_plot, effects(5) placebo(3) avg avgpre pvalues shade export("event_study.png")
```

### Options

**Required**

| Option | Effect |
|---|---|
| `effects(#)`, `placebo(#)` | number of periods estimated |

**What to plot**

| Option | Effect |
|---|---|
| `showeffects(#)`, `showplacebo(#)` | plot only the first # effects / placebos |
| `avg` | average total effect as dashed line over the post-treatment periods |
| `avgpre` | pooled placebo (mean of the plotted placebos) as dashed line over the pre-treatment periods |
| `avgvalues` | print the value of the average line(s) at their ends |
| `noci`, `cibars` | no intervals / intervals as bars instead of a shaded area |
| `level(# [#])` | confidence level, default 95 as in `did_multiplegt_dyn`, which does not store its intervals (they are recalculated as b ± z·se); `level(90 95)` draws a darker inner and a lighter outer band |
| `scale(#)`, `pctof(#)` | multiply estimates by #; express estimates in percent of # (e.g. a baseline mean) |

**Statistics**

| Option | Effect |
|---|---|
| `pvalues` | table with estimates and p-values (average effect, pooled placebo, joint tests) in the Results window |
| `pnote` | average-effect p-value and joint placebo test p-value as a note below the plot |
| `fmt(%5.3f)` | number format |

**Appearance**

| Option | Effect |
|---|---|
| `shade`, `shadecolor()` | shade the post-treatment area |
| `vline` | vertical dashed line between baseline and first effect |
| `color("R G B")`, `avgcolor()`, `precolor()` | colours of the series, the average line, the placebo line |
| `msymbol()`, `lpattern()`, `lwidth()` | marker and line style of the main series |
| `avglpattern()`, `prelpattern()` | line patterns of the two average lines |
| `ciopacity(#)` | opacity of the shaded interval in percent |
| `nozero`, `nocaptions`, `nolegend` | drop zero line / captions / legend |
| `precaption()`, `postcaption()` | text of the "pre-treatment" / "post-treatment" captions |
| `lbldyn()`, `lblavg()`, `lblpre()` | legend labels |
| `ytitle()`, `xtitle()` | axis titles (none by default) |
| `ylab()`, `tpos()` | manual y-axis labels and caption position (`ylab()` requires `tpos()`) |

**Output**

| Option | Effect |
|---|---|
| `savedata(file)` | save the plotted data (`x`, `eventtime`, `type`, `b`, `se`, `lb`, `ub`, `p`) as a `.dta` file |
| `export(file)` | save the graph via `graph export` |

Periods that could not be estimated appear as gaps. `shade` and `vline` cannot be combined with `ylab()`. Any other option is passed to `twoway`. Details: `help french_plot`.

## lpdid_plot

Version 0.1.1 (beta). Package folder: [`lpdid_plot/`](lpdid_plot/).

Event-study plot after `lpdid` (Busch and Girardi). Counterpart of `french_plot` with the same layout, axis positions, defaults and options, so that figures from `lpdid` and `did_multiplegt_dyn` are directly comparable. Baseline at -1, `pre n` at -n, `tau k` at k (labelled k+1).

**This is a beta version and has not been extensively tested. Please check results against the `lpdid` output and report problems via GitHub issues.**

### Installation

```stata
net install lpdid_plot, from("https://raw.githubusercontent.com/jerggutmann/stata-tools/main/lpdid_plot/") replace
```

Re-run the same line to update. Remove with `ado uninstall lpdid_plot`.

### Usage

Specify `pre()` and `post()` exactly as in `lpdid`:

```stata
use http://fmwww.bc.edu/repec/bocode/l/lpdidtestdata1.dta, clear
lpdid Y, time(time) unit(unit) treat(treat) pre(5) post(10) pooled
lpdid_plot, pre(5) post(10) avg avgpre pvalues shade export("event_study.png")
```

`pre(U)` and `post(T-1)` correspond to `placebo(U-1)` and `effects(T)` in `french_plot`. The pooled lines and p-values (`avg`, `avgpre`, `pvalues`, `pnote`) come from `e(pooled_results)`, which `lpdid` stores only with its option `pooled`. Confidence intervals and p-values are those stored by `lpdid` (t-based); `normalci` or `level()` switches to normal-based ones, identical to `french_plot`. All other options are identical to `french_plot` (see above), except `showpre()`/`showpost()` instead of `showplacebo()`/`showeffects()` and `savedata()` with the additional variable `lpdidname`. There are no joint tests. Details: `help lpdid_plot`.

## did2s_plot

Version 0.1.0 (beta). Package folder: [`did2s_plot/`](did2s_plot/).

Event-study plot after `did2s` (Butts and Gardner; two-stage difference-in-differences). Counterpart of `french_plot` and `lpdid_plot` with the same layout, axis positions, defaults and options. Because `did2s` leaves the definition of the treatment variables to the user, `did2s_plot` identifies the event-study coefficients by name (see below).

**This is a beta version. Please check results against the `did2s` output and report problems via GitHub issues.**

### Installation

```stata
net install did2s_plot, from("https://raw.githubusercontent.com/jerggutmann/stata-tools/main/did2s_plot/") replace
```

Re-run the same line to update. Remove with `ado uninstall did2s_plot`.

### Usage

With an event-time factor variable in `second_stage()` (example from the help of `did2s`):

```stata
use https://github.com/kylebutts/did2s_stata/raw/main/data/df_hom.dta, clear
gen rel_year_shift = rel_year + 20
replace rel_year_shift = 100 if rel_year_shift == .
did2s dep_var, first_stage(i.state i.year) second_stage(ib100.rel_year_shift) treatment(treat) cluster(state)
did2s_plot, eventvar(rel_year_shift) shift(20) pre(5) post(10) avg avgpre pvalues shade
```

`eventvar()` names the factor variable; level `v` is event time `v - shift()`. Base levels outside the estimated range (here the never-treated group 100) are ignored. With dummy variables, name patterns are used instead: `lead(F#_treat) lag(L#_treat)` (`F3_treat` is event time -3, `L0_treat` is event time 0). A table of the coefficients used is shown in the Results window.

Event time -1 is the baseline and plotted as zero if it is the omitted reference period. If the regression estimates it, the estimate is plotted and a warning says that the coefficients are not normalized at t-1 (as in the `did2s` help example); leaving out the dummy for t-1 avoids this. Factor variable and dummies cannot be combined. `avg` and `avgpre` are unweighted means of the plotted coefficients (not the `did2s` average treatment effect); `pvalues` and `pnote` also report joint Wald tests from `e(V)`. Confidence intervals are normal-based, as in `did2s`; `level(90 95)` draws two bands. `pre()`/`post()` limit the plotted event times. All other options are identical to `french_plot` (see above), except that `savedata()` adds the variable `coef`. Details: `help did2s_plot`.

## cname_std

Version 0.2.2 (beta). Package folder: [`cname_std/`](cname_std/).

Standardizes the spelling of country names in a string variable (`cname` by default). A dictionary of about 2,000 spellings (English, German, French, Spanish, plus the spellings known from `kountry` and an own list) is matched ignoring case, accents, punctuation and spaces. Names that are not found are only trimmed and capitalized and are reported, so the dictionary can be extended step by step.

**This is a beta version. Please report problems via GitHub issues.**

### Installation

```stata
net install cname_std, from("https://raw.githubusercontent.com/jerggutmann/stata-tools/main/cname_std/") replace
```

Re-run the same line to update the dictionary. Remove with `ado uninstall cname_std`.

### Usage

```stata
cname_std                                // overwrite cname in place
cname_std, new marker                    // result in cname_new, flag in cname_new_marker
cname_std, varname(country) new(iso_name)
cname_std, alt(germany ussr)             // switch historical conventions
cname_std_add "Netherlands, The" "Netherlands"   // add a spelling to your personal dictionary
```

`marker` is 0 (recognized, unchanged), 1 (changed), 2 (not recognized, only cleaned) or 3 (ambiguous, not standardized, e.g. "Kongo" or "Virgin Islands"). Filter on 2 to find spellings that belong in the dictionary.

### Conventions

The command standardizes spellings and does not merge entries. West Germany is Germany, the USSR is Russia, Czechoslovakia is Czechia; North/South Korea, Vietnam and Yemen and East Germany keep separate names; Serbia, Montenegro, Serbia and Montenegro and Yugoslavia are separate; Great Britain, England, Wales and the United Kingdom are separate (a note is shown if "Great Britain" occurs). Plain "Korea" is South Korea. The complete list and all options are in `help cname_std`.

### Adding spellings

Edit `cname_std/cname_std_dict.csv` (columns `variant;standard;note;group;alt`, semicolon-separated, UTF-8) and open a pull request, or use `cname_std_add` for a personal dictionary that survives updates. The smoke test is `cname_std/test/cname_std_test.do`.

## Licence

MIT, see [`LICENSE`](LICENSE). The licence applies to all packages in this repository unless a folder states otherwise. Each help file refers to it as well.
