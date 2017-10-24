#!/bin/sh
# the next line restarts using wish \
exec prowish83 "$0" "$@"
# GeoEasy angol, nemet es magyar uzenetfile osszehasonlitasa
source geo_easy.hun
set f [open hun.txt w]
foreach i [lsort [array names geoEasyMsg]] { puts $f $i }
close $f
unset geoEasyMsg
source geo_easy.eng
set f [open eng.txt w]
foreach i [lsort [array names geoEasyMsg]] { puts $f $i }
close $f
catch "exec diff hun.txt eng.txt > hun_eng.txt"
unset geoEasyMsg
source geo_easy.ger
set f [open ger.txt w]
foreach i [lsort [array names geoEasyMsg]] { puts $f $i }
close $f
catch "exec diff hun.txt ger.txt > hun_ger.txt"
# ComEasy angol, nemet es magyar uzenetfile osszehasonlitasa
source com_easy.hun
set f [open hun.txt w]
foreach i [lsort [array names comEasyMsg]] { puts $f $i }
close $f
unset comEasyMsg
source com_easy.eng
set f [open eng.txt w]
foreach i [lsort [array names comEasyMsg]] { puts $f $i }
close $f
catch "exec diff hun.txt eng.txt > chun_eng.txt"
unset comEasyMsg
source com_easy.ger
set f [open ger.txt w]
foreach i [lsort [array names comEasyMsg]] { puts $f $i }
close $f
catch "exec diff hun.txt ger.txt > chun_ger.txt"
file delete hun.txt eng.txt ger.txt
exit
