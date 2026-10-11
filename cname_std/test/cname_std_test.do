* Smoke test for cname_std. Run from this test folder; the package files are in the parent folder.
* Every assert should pass silently; the last line prints "all tests passed".
clear all
set more off
adopath ++ ".."

* ---- test data (observation number = position in the list below)
input str60 cname
"  Deutschland "
"West Germany"
"Korea"
"Korea, Dem. Rep."
"Kongo"
"Virgin Islands"
"Virgin Islands (U.S.)"
"the BAHAMAS"
"Czechoslovakia"
"Serbia and Montenegro"
"Réunion"
"Corée du Sud"
"Gaza Strip and West Bank"
"England"
"Great Britain"
"atlantis"
"No Answer"
"USSR"
"North Vietnam"
""
end
save _t.dta, replace

* ---- 1. default: in place, no replace needed, marker
cname_std, marker
assert cname[1]  == "Germany"
assert cname[2]  == "Germany"
assert cname[3]  == "Korea, South"
assert cname[4]  == "Korea, North"
assert cname[5]  == "Kongo"
assert cname[6]  == "Virgin Islands"
assert cname[7]  == "US Virgin Islands"
assert cname[8]  == "Bahamas"
assert cname[9]  == "Czechia"
assert cname[10] == "Serbia and Montenegro"
assert cname[11] == "Reunion"
assert cname[12] == "Korea, South"
assert cname[13] == "Palestinian Territories"
assert cname[14] == "England"
assert cname[15] == "Great Britain"
assert cname[16] == "Atlantis"
assert cname[17] == ""
assert cname[18] == "Russia"
assert cname[19] == "Vietnam, North"
assert cname[20] == ""
assert cname_marker[5]  == 3
assert cname_marker[6]  == 3
assert cname_marker[16] == 2
assert cname_marker[3]  == 1
assert cname_marker[20] == 0
assert r(N_greatbritain) == 1
assert r(N_ambiguous) == 2
* a second run changes nothing; only 2 and 3 remain flagged
cname_std, marker replace
assert cname_marker[3] == 0 & cname_marker[16] == 2 & cname_marker[5] == 3

* ---- 2. new: source stays, result in cname_new, marker named after it
use _t.dta, clear
cname_std, new marker
assert cname[2] == "West Germany"
assert cname_new[2] == "Germany"
assert cname_new_marker[2] == 1
capture noisily cname_std, new
assert _rc == 110
cname_std, new replace
cname_std, new(c2)
assert c2[3] == "Korea, South"

* ---- 3. varname(): result goes to cname, source stays
use _t.dta, clear
rename cname raw
cname_std, varname(raw)
assert raw[2] == "West Germany"
assert cname[2] == "Germany"
capture noisily cname_std, varname(raw)
assert _rc == 110
cname_std, varname(raw) replace new(std2) marker
assert std2[2] == "Germany" & std2_marker[2] == 1

* ---- 4. alt(): several conventions at once
use _t.dta, clear
cname_std, alt(germany ussr czechoslovakia vietnam)
assert cname[2]  == "Germany, West"
assert cname[1]  == "Germany"
assert cname[18] == "USSR"
assert cname[9]  == "Czechoslovakia"
assert cname[19] == "Vietnam"
capture noisily cname_std, alt(nonsense)
assert _rc == 198

* ---- 5. errors
use _t.dta, clear
rename cname other
capture noisily cname_std
assert _rc == 111
capture noisily cname_std, varname(nothere)
assert _rc == 111

* ---- 6. personal additions (written to a scratch file, not to PERSONAL)
use _t.dta, clear
cname_std_add "Atlantis" "Greece", file("_extra.csv")
cname_std, extra("_extra.csv")
assert cname[16] == "Greece"
capture noisily cname_std_add "Foo" "Not A Country", file("_extra.csv")
assert _rc == 198

erase _t.dta
erase _extra.csv
display as result "all tests passed"
