#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"
# check language dependent message files of GeoEasy and ComEasy
set base eng				;# language to compare others to
# add here more languages after translation
set langs [list $base hun ger rus cze]
foreach lang $langs {
	source geo_easy.$lang
	# GeoEasy messages
	set f [open ${lang}.txt w]
	foreach i [lsort [array names geoEasyMsg]] { puts $f $i }
	close $f
	unset geoEasyMsg
	if {$base != $lang} {
		catch "exec diff ${base}.txt ${lang}.txt > ${base}_${lang}.txt"
	}
	# GeoEasy codes
	set f [open ${lang}_code.txt w]
	foreach i [lsort [array names geoCodes]] { puts $f $i }
	close $f
	unset geoCodes
	if {$base != $lang} {
		catch "exec diff ${base}_code.txt ${lang}_code.txt > ${base}_${lang}_code.txt"
	}
}
foreach lang $langs {
	source com_easy.$lang
	set f [open ${lang}.txt w]
	foreach i [lsort [array names comEasyMsg]] { puts $f $i }
	close $f
	unset comEasyMsg
	if {$base != $lang} {
		catch "exec diff ${base}.txt ${lang}.txt > c${base}_${lang}.txt"
	}
}
foreach lang $langs {
	file delete ${lang}.txt
	file delete ${lang}_code.txt
}
