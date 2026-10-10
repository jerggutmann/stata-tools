*! cname_std_add 0.2.0  09oct2026  Jerg Gutmann
* Adds a new spelling to the personal dictionary cname_std_extra.csv (read automatically by cname_std)
program define cname_std_add
    version 16.0
    syntax anything(equalok) [, FILE(string) FORCE]
    gettoken variant rest : anything
    local standard = strtrim(`"`rest'"')
    local variant = strtrim(`"`variant'"')
    if `"`variant'"' == "" | `"`standard'"' == "" {
        display as error `"syntax: cname_std_add "spelling" "standard name" [, file() force]"'
        exit 198
    }
    local standard : subinstr local standard `"""' "", all
    local standard = strtrim(`"`standard'"')
    if strpos(`"`variant'`standard'"', ";") {
        display as error "semicolons are not allowed in spellings"
        exit 198
    }

    * the standard name must exist in the dictionary (typo protection)
    if "`force'" == "" & !inlist(`"`standard'"', "[keep]") {
        capture findfile cname_std_dict.csv
        if _rc {
            display as error "dictionary file cname_std_dict.csv not found in the ado path"
            exit 601
        }
        tempname fr
        local known 0
        quietly frame create `fr'
        frame `fr' {
            quietly import delimited using `"`r(fn)'"', delimiter(";") varnames(1) stringcols(_all) bindquote(nobind) encoding("utf-8") clear
            quietly count if standard == `"`standard'"'
            local known = r(N) > 0
        }
        frame drop `fr'
        if !`known' {
            display as error `"standard name "`standard'" is not used in cname_std_dict.csv; check spelling or use option force"'
            exit 198
        }
    }

    if `"`file'"' == "" local file `"`c(sysdir_personal)'cname_std_extra.csv"'
    capture confirm file `"`file'"'
    local isnew = _rc != 0
    tempname fh
    file open `fh' using `"`file'"', write text append
    if `isnew' file write `fh' "variant;standard;note;group;alt" _n
    file write `fh' `"`variant';`standard';user;;"' _n
    file close `fh'
    display as text `"added to `file': "' as result `"`variant' -> `standard'"'
end
