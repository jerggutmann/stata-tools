*! cname_std 0.2.2  10oct2026  Jerg Gutmann
*! Standardizes spellings of country names using the dictionary cname_std_dict.csv
program define cname_std, rclass
    version 16.0
    syntax [, VARname(name) REPLACE QUIet EXTRA(string) ALT(string) NOPROPER MARKer *]

    * new / new(name) is parsed by hand because Stata cannot tell "new" from "new()"
    local donew 0
    local newname ""
    local opt = strtrim(`"`options'"')
    if `"`opt'"' != "" {
        if regexm(`"`opt'"', "^[nN][eE][wW]$") {
            local donew 1
        }
        else if regexm(`"`opt'"', "^[nN][eE][wW][ ]*\(([^)]*)\)$") {
            local donew 1
            local newname = strtrim(regexs(1))
        }
        else {
            display as error `"option `opt' not allowed"'
            exit 198
        }
    }

    * source variable
    local src = cond("`varname'" == "", "cname", "`varname'")
    capture unab _full : `src'
    if _rc | "`_full'" != "`src'" {
        display as error "variable `src' not found"
        exit 111
    }
    capture confirm string variable `src'
    if _rc {
        display as error "variable `src' must be a string variable"
        exit 109
    }

    * target variable
    local inplace 0
    if "`newname'" != "" {
        local tgt "`newname'"
    }
    else if `donew' {
        local tgt "cname_new"
    }
    else if "`src'" != "cname" {
        local tgt "cname"
    }
    else {
        local tgt "`src'"
    }
    capture confirm name `tgt'
    if _rc {
        display as error "`tgt' is not a valid variable name"
        exit 198
    }
    if "`tgt'" == "`src'" {
        local inplace 1
        if `donew' & "`replace'" == "" {
            display as error "new variable would overwrite `src'; use option replace"
            exit 110
        }
    }
    else {
        capture unab _t : `tgt'
        if !_rc & "`_t'" == "`tgt'" & "`replace'" == "" {
            display as error "variable `tgt' already defined; use option replace"
            exit 110
        }
    }

    * marker variable: <target>_marker
    local mname ""
    if "`marker'" != "" {
        local mname "`tgt'_marker"
        capture confirm name `mname'
        if _rc {
            display as error "`mname' is not a valid variable name"
            exit 198
        }
        capture unab _m : `mname'
        if !_rc & "`_m'" == "`mname'" & "`replace'" == "" {
            display as error "variable `mname' already defined; use option replace"
            exit 110
        }
    }

    * dictionary files: package dictionary, patterns, optional personal file, optional extra()
    capture findfile cname_std_dict.csv
    if _rc {
        display as error "dictionary file cname_std_dict.csv not found in the ado path"
        exit 601
    }
    local dictfile `"`r(fn)'"'
    capture findfile cname_std_patterns.csv
    local patfile = cond(_rc, "", `"`r(fn)'"')
    capture findfile cname_std_extra.csv
    local personal = cond(_rc, "", `"`r(fn)'"')
    if `"`extra'"' != "" confirm file `"`extra'"'

    tempname fr fp
    tempvar cl key lnk hit std mt out chg
    local rc 0
    local baddict 0
    capture noisily {
        quietly frame create `fr'
        frame `fr' {
            tempfile t2 t3
            local have2 0
            local have3 0
            if `"`personal'"' != "" {
                _cname_std_load `"`personal'"' 2
                quietly save `"`t2'"'
                local have2 1
            }
            if `"`extra'"' != "" {
                _cname_std_load `"`extra'"' 3
                quietly save `"`t3'"'
                local have3 1
            }
            _cname_std_load `"`dictfile'"' 1
            if `have2' quietly append using `"`t2'"'
            if `have3' quietly append using `"`t3'"'

            * alternative conventions: rows of a group use their alternative standard name
            foreach g of local alt {
                quietly count if group == "`g'" & alt != ""
                if r(N) == 0 {
                    display as error `"alt(): unknown group `g'"'
                    quietly levelsof group if group != "" & alt != "", local(groups) clean
                    display as error "available groups: `groups'"
                    exit 198
                }
                quietly replace standard = alt if group == "`g'" & alt != ""
            }

            * every standard name also matches itself (lowest priority, [keep] excluded)
            quietly {
                generate long _id = _n
                expand 2 if !inlist(standard, "", "[keep]")
                bysort _id: replace variant = standard if _n == 2 & _N == 2
                bysort _id: replace prio = 0 if _n == 2 & _N == 2
            }
            _cname_std_key ckey variant
            quietly {
                drop if ckey == ""
                bysort ckey prio (standard): generate byte bad = standard[1] != standard[_N]
                count if bad
            }
            if r(N) {
                display as error "dictionary contains one spelling with different standard names:"
                list variant standard prio if bad, noobs sepby(ckey)
                local baddict 1
            }
            * later files take precedence
            quietly {
                bysort ckey (prio): keep if _n == _N
                keep ckey standard
                rename standard cstd
            }
        }

        quietly frame create `fp'
        local np 0
        if `"`patfile'"' != "" {
            frame `fp' {
                quietly import delimited using `"`patfile'"', delimiter(";") varnames(1) stringcols(_all) bindquote(nobind) encoding("utf-8") clear
                local np = _N
                forvalues i = 1/`np' {
                    local pat`i' = pattern[`i']
                    local pstd`i' = standard[`i']
                }
            }
        }

        _cname_std_clean `cl' `src' `noproper'
        _cname_std_key `key' `cl'
        quietly frlink m:1 `key', frame(`fr' ckey) generate(`lnk')
        quietly frget `std' = cstd, from(`lnk')
        quietly generate byte `hit' = !missing(`lnk') & `key' != ""
        quietly drop `lnk'

        * wildcard-like rules (regular expressions on the key) for spellings not in the dictionary
        forvalues i = 1/`np' {
            quietly generate byte `mt' = !`hit' & `key' != "" & ustrregexm(`key', `"`pat`i''"')
            quietly replace `std' = `"`pstd`i''"' if `mt'
            quietly replace `hit' = 1 if `mt'
            quietly drop `mt'
        }
    }
    local rc = _rc
    capture frame drop `fr'
    capture frame drop `fp'
    if `rc' == 0 & `baddict' local rc 498
    if `rc' exit `rc'

    * [keep] = ambiguous spelling, deliberately not standardized
    tempvar amb
    quietly generate byte `amb' = `hit' & `std' == "[keep]"
    quietly replace `hit' = 0 if `amb'

    quietly generate str244 `out' = `cl'
    quietly replace `out' = `std' if `hit'
    quietly count if `key' != ""
    local nnonblank = r(N)
    quietly count if `hit'
    local nhit = r(N)
    quietly count if `amb'
    local namb = r(N)
    quietly generate byte `chg' = `out' != `src' & `key' != ""
    quietly count if `chg'
    local nchg = r(N)
    quietly count if `hit' & `std' == "Great Britain"
    local ngb = r(N)

    if `inplace' {
        quietly replace `src' = `out' if `key' != ""
    }
    else {
        if "`replace'" != "" capture drop `tgt'
        quietly generate `tgt' = `src'
        quietly replace `tgt' = `out' if `key' != ""
        capture quietly compress `tgt'
        quietly order `tgt', after(`src')
        label variable `tgt' "`src', standardized spelling (cname_std)"
    }

    if "`mname'" != "" {
        if "`replace'" != "" capture drop `mname'
        quietly generate byte `mname' = `chg'
        quietly replace `mname' = 2 if !`hit' & !`amb' & `key' != ""
        quietly replace `mname' = 3 if `amb'
        label variable `mname' "`tgt': 0 unchanged, 1 changed, 2 not recognized, 3 ambiguous (cname_std)"
    }

    local unmatched ""
    local ambiguous ""
    capture quietly levelsof `cl' if !`hit' & !`amb' & `key' != "", local(unmatched)
    capture quietly levelsof `cl' if `amb', local(ambiguous)
    local nunm = `nnonblank' - `nhit' - `namb'

    if `ngb' > 0 {
        display as text "note: " as result `ngb' as text " observations are 'Great Britain'. They are NOT merged into 'United Kingdom'."
    }
    if "`quiet'" == "" {
        display as text "cname_std: " as result `nhit' as text " of " as result `nnonblank' ///
            as text " non-empty observations recognized, " as result `nchg' as text " changed" ///
            as text " -> " as result "`tgt'"
        if `namb' > 0 {
            display as text "ambiguous, not standardized (check by hand):"
            foreach u of local ambiguous {
                display as text `"   `u'"'
            }
        }
        if `nunm' > 0 {
            display as text "not recognized (only trimmed/capitalized; add them with cname_std_add):"
            local k 0
            foreach u of local unmatched {
                local ++k
                if `k' <= 100 display as text `"   `u'"'
            }
            if `k' > 100 display as text "   ... (" (`k' - 100) " more, see r(unmatched))"
        }
    }

    return scalar N_recognized = `nhit'
    return scalar N_changed = `nchg'
    return scalar N_ambiguous = `namb'
    return scalar N_greatbritain = `ngb'
    return scalar N_unmatched = `nunm'
    return local unmatched `"`unmatched'"'
    return local ambiguous `"`ambiguous'"'
    return local varname "`tgt'"
end

* reads one dictionary file into the current frame: variant, standard, group, alt, prio
* (an empty standard means: set the entry to missing)
program define _cname_std_load
    version 16.0
    args file prio
    quietly import delimited using `"`file'"', delimiter(";") varnames(1) stringcols(_all) bindquote(nobind) encoding("utf-8") clear
    quietly describe, varlist
    local vl `r(varlist)'
    if `: word count `vl'' < 2 {
        display as error `"`file' needs at least two columns (variant;standard)"'
        exit 198
    }
    local v1 : word 1 of `vl'
    local v2 : word 2 of `vl'
    quietly {
        capture rename `v1' variant
        capture rename `v2' standard
        foreach v in group alt {
            capture confirm variable `v'
            if _rc generate str1 `v' = ""
        }
        keep variant standard group alt
        replace variant = strtrim(variant)
        replace standard = strtrim(standard)
        drop if variant == "" & standard == ""
        generate byte prio = `prio'
    }
end

* cleans a spelling: unusual blanks, leading "The", mojibake prefix, trim; then proper case
program define _cname_std_clean
    version 16.0
    args cl src noproper
    quietly {
        generate str244 `cl' = ustrregexra(`src', "\s+", " ")
        replace `cl' = ustrregexra(`cl', "^(ï¿½)?Â ", "")
        replace `cl' = ustrregexra(`cl', "(?i)^the ", "")
        replace `cl' = ustrtrim(`cl')
        if "`noproper'" == "" replace `cl' = ustrtitle(`cl', "en")
    }
end

* canonical form of a spelling: lower case, no accents, no punctuation, no spaces, no "the"
program define _cname_std_key
    version 16.0
    args key src
    quietly {
        generate str244 `key' = ustrlower(`src')
        replace `key' = ustrnormalize(`key', "nfd")
        replace `key' = ustrregexra(`key', "\p{M}", "")
        replace `key' = ustrregexra(`key', "&", " and ")
        replace `key' = ustrregexra(`key', "[^a-z0-9]+", " ")
        replace `key' = " " + `key' + " "
        replace `key' = ustrregexra(`key', "\bthe\b", " ")
        replace `key' = ustrregexra(`key', "\s+", "")
    }
end
