{smcl}
{* *! version 0.2.2  10oct2026  Jerg Gutmann}{...}
{vieweralsosee "cname_std_add" "help cname_std_add"}{...}
{vieweralsosee "kountry" "help kountry"}{...}
{viewerjumpto "Syntax" "cname_std##syntax"}{...}
{viewerjumpto "Description" "cname_std##description"}{...}
{viewerjumpto "Options" "cname_std##options"}{...}
{viewerjumpto "Examples" "cname_std##examples"}{...}
{viewerjumpto "Remarks" "cname_std##remarks"}{...}
{viewerjumpto "Modifying the dictionary" "cname_std##dictionary"}{...}
{viewerjumpto "Conventions" "cname_std##conventions"}{...}
{viewerjumpto "Stored results" "cname_std##results"}{...}
{title:Title}

{phang}{bf:cname_std} {hline 2} Standardize spellings of country names


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:cname_std} [{cmd:,} {it:options}]{p_end}

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Variables}
{synopt:{opt var:name(varname)}}standardize {it:varname} instead of {cmd:cname}{p_end}
{synopt:{opt new}[{cmd:(}{it:newvar}{cmd:)}]}write the result to {cmd:cname_new} or {it:newvar}; source stays unchanged{p_end}
{synopt:{opt replace}}overwrite an existing target variable{p_end}

{syntab:Standardization}
{synopt:{opt alt(groups)}}switch the convention of one or more groups, e.g. {cmd:germany ussr}{p_end}
{synopt:{opt noproper}}do not capitalize names that are not recognized{p_end}
{synopt:{opt extra(filename)}}read an additional dictionary{p_end}

{syntab:Output}
{synopt:{opt mark:er}}create {it:target}{cmd:_marker} (0 unchanged, 1 changed, 2 not recognized, 3 ambiguous){p_end}
{synopt:{opt qui:et}}suppress the report{p_end}
{synoptline}
{p2colreset}{...}

{p 8 17 2}{cmd:cname_std_add} {cmd:"}{it:spelling}{cmd:"} {cmd:"}{it:standard name}{cmd:"}
[{cmd:,} {opt file(filename)} {opt force}]{p_end}

{pstd}{cmd:cname_std_add} is described in {help cname_std_add} and in the section
{help cname_std##dictionary:Modifying the dictionary}.{p_end}


{marker description}{...}
{title:Description}

{pstd}{cmd:cname_std} standardizes the spelling of country names in a string variable, by default {cmd:cname}.
It first cleans each entry (unusual blanks and a leading "The" removed, trimmed, proper case).
It then looks the entry up in a dictionary of about 2,000 known spellings
and replaces each recognized entry by one standard name.
Entries that are not in the dictionary are only cleaned and are listed after the run.{p_end}

{pstd}Spellings are compared in a normalized form: case, accents, punctuation, spaces and "the" are ignored.
"Bahamas, The", "the bahamas" and "BAHAMAS" are therefore the same spelling.{p_end}

{pstd}By default the entries of {cmd:cname} are overwritten in place.
The command only standardizes spellings. It does not merge countries, see {help cname_std##conventions:Conventions}.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Variables}

{phang}{opt varname(varname)} standardizes {it:varname} instead of {cmd:cname}.
The result is written to a new variable {cmd:cname}; {it:varname} stays unchanged.
The command stops with an error if the variable does not exist.{p_end}

{phang}{opt new} writes the result to a new variable {cmd:cname_new} and leaves the source variable unchanged.
{opt new(newvar)} chooses the name of the new variable.
{opt new} can be combined with {opt varname()}.{p_end}

{phang}{opt replace} allows overwriting an existing target variable.
It is not needed for the default, which overwrites {cmd:cname} in place.{p_end}

{dlgtab:Standardization}

{phang}{opt alt(groups)} switches the convention of one or more groups of the dictionary.
Several groups are separated by blanks, e.g. {cmd:alt(germany ussr)}.
The groups are:{p_end}

{p2colset 9 26 28 2}{...}
{p2col:{cmd:germany}}West Germany stays "Germany, West" instead of "Germany"{p_end}
{p2col:{cmd:ussr}}USSR stays "USSR" instead of "Russia"{p_end}
{p2col:{cmd:czechoslovakia}}Czechoslovakia stays "Czechoslovakia" instead of "Czechia"{p_end}
{p2col:{cmd:vietnam}}North and South Vietnam both become "Vietnam"{p_end}
{p2col:{cmd:yemen}}North and South Yemen both become "Yemen"{p_end}
{p2colreset}{...}

{phang}{opt noproper} skips the proper-case step for names that are not recognized.
They are still trimmed.{p_end}

{phang}{opt extra(filename)} reads an additional dictionary in the same format as {cmd:cname_std_dict.csv}.
Its entries take precedence over everything else.{p_end}

{dlgtab:Output}

{phang}{opt marker} creates the variable {it:target}{cmd:_marker}, where {it:target} is the variable that holds the result.
The default is {cmd:cname_marker}; with {opt new} it is {cmd:cname_new_marker}.
The values are:{p_end}

{p2colset 9 17 19 2}{...}
{p2col:0}recognized and unchanged (or empty){p_end}
{p2col:1}changed{p_end}
{p2col:2}not recognized, only cleaned{p_end}
{p2col:3}ambiguous, deliberately not standardized{p_end}
{p2colreset}{...}

{pstd}Entries with value 2 are the spellings to add to the dictionary.
{opt replace} also overwrites an existing marker variable.{p_end}

{phang}{opt quiet} suppresses the report.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}A small dataset with three spellings{p_end}
{phang2}{cmd:. set obs 3}{p_end}
{phang2}{cmd:. generate cname = "Deutschland" in 1}{p_end}
{phang2}{cmd:. replace cname = "Korea, Rep." in 2}{p_end}
{phang2}{cmd:. replace cname = "Atlantis" in 3}{p_end}

{pstd}Standardize {cmd:cname} in place{p_end}
{phang2}{cmd:. cname_std}{p_end}

{pstd}Keep the original, write the result to {cmd:cname_new} and flag every entry{p_end}
{phang2}{cmd:. cname_std, new marker}{p_end}

{pstd}List the spellings that are not yet in the dictionary{p_end}
{phang2}{cmd:. list cname if cname_new_marker == 2}{p_end}

{pstd}Standardize the variable {cmd:country} into a new variable {cmd:country_std}{p_end}
{phang2}{cmd:. cname_std, varname(country) new(country_std)}{p_end}

{pstd}Keep West Germany and the USSR as separate entries{p_end}
{phang2}{cmd:. cname_std, alt(germany ussr)}{p_end}

{pstd}Teach the command a new spelling, then run it again{p_end}
{phang2}{cmd:. cname_std_add "Netherlands, The" "Netherlands"}{p_end}
{phang2}{cmd:. cname_std}{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}Requires Stata 16 or newer (frames).{p_end}

{pstd}The idea of a spelling dictionary follows {cmd:kountry} by Rafal Raciborski (available from SSC).
The dictionary combines the spellings of {cmd:kountry} with an own list
and German, French and Spanish names.
{cmd:cname_std} does not convert between country codes, for that use {cmd:kountry}.{p_end}

{pstd}The two sections below describe how to extend the dictionary and which conventions it follows.{p_end}


{marker dictionary}{...}
{title:Modifying the dictionary}

{pstd}A spelling that {cmd:cname_std} does not know stays unchanged (apart from cleaning)
and is listed in the report and in {cmd:r(unmatched)}.
You can teach the command new spellings in three ways.{p_end}

{phang}1. {bf:Your own dictionary.}
{cmd:cname_std_add "Netherlands, The" "Netherlands"} appends one line to the file {cmd:cname_std_extra.csv}
in your PERSONAL directory ({cmd:. sysdir} shows where it is).
{cmd:cname_std} reads this file automatically, and it is not overwritten when you update the package.
The standard name must already exist in the dictionary, otherwise the command stops (option {opt force} overrides this).
{opt file()} writes to another file instead.{p_end}

{phang}2. {bf:A dictionary file for one project.}
Create a file in the format below and pass it with {opt extra(filename)}.{p_end}

{phang}3. {bf:The package dictionary.}
Add a line to {cmd:cname_std_dict.csv} in the GitHub repository and send a pull request,
so that everybody gets the new spelling with the next update.{p_end}

{pstd}Entries of {cmd:extra()} override your PERSONAL file, and both override the package dictionary.
If one file contains the same spelling with two different standard names, the command stops with error 498.{p_end}

{pstd}{bf:File format.} Dictionary files are plain text (UTF-8) with a semicolon as separator and one line per spelling.
The first line is a header.{p_end}

{p2colset 9 20 22 2}{...}
{p2col:{it:variant}}the spelling as it appears in your data{p_end}
{p2col:{it:standard}}the standard name. Each standard name also matches itself.
An empty standard sets the entry to missing (e.g. "No Answer").
The value {cmd:[keep]} marks an ambiguous spelling (e.g. "Kongo", "Virgin Islands") that is not standardized
and gets marker value 3.{p_end}
{p2col:{it:note}}free text, ignored{p_end}
{p2col:{it:group}, {it:alt}}used by {opt alt()}: rows with a {it:group} use the name in {it:alt} when that group is switched.
Leave empty in your own files.{p_end}
{p2colreset}{...}

{pstd}Files for {opt extra()} and {cmd:cname_std_extra.csv} need only the columns {it:variant} and {it:standard}.{p_end}

{pstd}A few pattern rules for broken spellings (regular expressions on the normalized spelling,
e.g. mangled accents in "Cote d'Ivoire") are in {cmd:cname_std_patterns.csv}.
They apply only to spellings that are not found in the dictionary.{p_end}


{marker conventions}{...}
{title:Conventions}

{pstd}{cmd:cname_std} standardizes spellings; it does not merge or aggregate entries
(no Hong Kong into China, no Palestinian Territories into Israel).
Where a spelling stands for a state that changed its name or form, these conventions apply:{p_end}

{phang}1. {bf:Historical continuity.}
West Germany is "Germany", the USSR and the Russian Federation are "Russia",
Czechoslovakia and the Czech Republic are "Czechia".
Switch off with {opt alt(germany ussr czechoslovakia)}.{p_end}

{phang}2. {bf:Entities that split or unified keep separate names.}
"Germany, East", "Korea, North", "Korea, South", "Vietnam, North", "Vietnam, South",
"Yemen, North" and "Yemen, South", besides "Vietnam" and "Yemen" for the unified states.
Switch off for Vietnam and Yemen with {opt alt(vietnam yemen)}.{p_end}

{phang}3. {bf:Former Yugoslavia.}
"Serbia", "Serbia and Montenegro", "Montenegro" and "Yugoslavia" are four separate entries.
Plain "Yugoslavia" and "Yugoslavia, FR (Serbia/Montenegro)" are "Yugoslavia".{p_end}

{phang}4. {bf:Current official names.}
"Turkiye" (not Turkey), "Eswatini" (not Swaziland), "Czechia", "Timor-Leste", "Cote d'Ivoire", "Myanmar".
"North Macedonia" is also used for plain "Macedonia", which is not used for the region.{p_end}

{phang}5. {bf:Defaults without further information.}
"Korea" is "Korea, South", "Israel/Palestine" is "Israel", "China Republic" is "Taiwan", "BRN" is "Brunei".
Gaza, West Bank and all their combinations are "Palestinian Territories" (not a recognized state).{p_end}

{phang}6. {bf:Ambiguous spellings are not standardized.}
"Kongo" (both Congos) and "Virgin Islands" (US or British) stay as they are.
They get marker value 3 and are reported in {cmd:r(ambiguous)}.
The US territory is "US Virgin Islands".{p_end}

{phang}7. {bf:United Kingdom.}
"England", "Wales", "England and Wales", "Scotland", "Northern Ireland", "Great Britain" and "United Kingdom"
are separate entries and none is merged into another.
A note is displayed if "Great Britain" occurs in the data.{p_end}

{phang}8. {bf:Languages.}
Names in English, German, French and Spanish are recognized.
Regions and aggregates ("Africa", "OECD Members") are not part of the dictionary; they are only cleaned.{p_end}


{marker results}{...}
{title:Stored results}

{pstd}{cmd:cname_std} stores the following in {cmd:r()}:{p_end}

{synoptset 22 tabbed}{...}
{syntab:Scalars}
{synopt:{cmd:r(N_recognized)}}observations with a recognized name{p_end}
{synopt:{cmd:r(N_changed)}}observations whose entry changed{p_end}
{synopt:{cmd:r(N_ambiguous)}}observations with an ambiguous name{p_end}
{synopt:{cmd:r(N_greatbritain)}}observations "Great Britain"{p_end}
{synopt:{cmd:r(N_unmatched)}}non-empty observations not found in the dictionary{p_end}

{syntab:Macros}
{synopt:{cmd:r(unmatched)}}distinct unrecognized names{p_end}
{synopt:{cmd:r(ambiguous)}}distinct ambiguous names{p_end}
{synopt:{cmd:r(varname)}}name of the variable that holds the result{p_end}
{p2colreset}{...}


{title:Author}

{pstd}Jerg Gutmann{break}
{browse "https://github.com/jerggutmann/stata-tools"}{p_end}

{pstd}Licence: MIT, see {browse "https://github.com/jerggutmann/stata-tools/blob/main/LICENSE":LICENSE} in the repository.{p_end}

{title:Support and updates}

{pstd}This is a beta version. Please report problems and missing spellings at
{browse "https://github.com/jerggutmann/stata-tools/issues"}.
Re-run {cmd:net install cname_std, replace} to get the latest dictionary.{p_end}


{title:Also see}

{psee}
Help: {help cname_std_add}, {help kountry} (if installed){p_end}
