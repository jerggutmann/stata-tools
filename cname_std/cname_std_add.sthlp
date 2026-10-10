{smcl}
{* *! version 0.2.2  10oct2026  Jerg Gutmann}{...}
{vieweralsosee "cname_std" "help cname_std"}{...}
{viewerjumpto "Syntax" "cname_std_add##syntax"}{...}
{viewerjumpto "Description" "cname_std_add##description"}{...}
{viewerjumpto "Options" "cname_std_add##options"}{...}
{viewerjumpto "Examples" "cname_std_add##examples"}{...}
{title:Title}

{phang}{bf:cname_std_add} {hline 2} Add a spelling to the dictionary of {helpb cname_std}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:cname_std_add} {cmd:"}{it:spelling}{cmd:"} {cmd:"}{it:standard name}{cmd:"}
[{cmd:,} {it:options}]{p_end}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt file(filename)}}write to {it:filename} instead of the personal dictionary{p_end}
{synopt:{opt force}}accept a standard name that is not yet in the dictionary{p_end}
{synoptline}
{p2colreset}{...}

{pstd}Both arguments must be enclosed in double quotes.{p_end}


{marker description}{...}
{title:Description}

{pstd}{cmd:cname_std_add} appends one line to the file {cmd:cname_std_extra.csv} in your PERSONAL directory
({cmd:. sysdir} shows where it is). The file is created if it does not exist.
{helpb cname_std} reads it automatically, so the spelling is standardized from the next run on.
The file is not touched when the package is updated.{p_end}

{pstd}{it:standard name} must already be used in the package dictionary, which protects against typos.
The special value {cmd:[keep]} marks the spelling as ambiguous: it is then left unchanged and reported.
The spelling is compared in normalized form (case, accents, punctuation and blanks are ignored).{p_end}


{marker options}{...}
{title:Options}

{phang}{opt file(filename)} writes the line to {it:filename}, for example a copy of the dictionary for one project
that you later pass to {helpb cname_std} with {opt extra()}.
The file is created with a header line if it does not exist.{p_end}

{phang}{opt force} allows a standard name that does not appear in the dictionary yet.{p_end}


{marker examples}{...}
{title:Examples}

{phang2}{cmd:. cname_std_add "Netherlands, The" "Netherlands"}{p_end}
{phang2}{cmd:. cname_std_add "Kongo" "[keep]"}{p_end}
{phang2}{cmd:. cname_std_add "Atlantis" "Greece", file("my_dictionary.csv")}{p_end}


{title:Author}

{pstd}Jerg Gutmann{break}
{browse "https://github.com/jerggutmann/stata-tools"}{p_end}

{pstd}Licence: MIT, see {browse "https://github.com/jerggutmann/stata-tools/blob/main/LICENSE":LICENSE} in the repository.{p_end}


{title:Also see}

{psee}
Help: {help cname_std}{p_end}
