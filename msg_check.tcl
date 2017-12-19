#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"
# check language dependent message files of GeoEasy and ComEasy
set base eng				;# language to compare others to
set langs [list $base hun]	;# add here more languages after transation
foreach lang $langs {
	source geo_easy.$lang
	set f [open ${lang}.txt w]
	foreach i [lsort [array names geoEasyMsg]] { puts $f $i }
	close $f
	unset geoEasyMsg
	if {$base != $lang} {
		catch "exec diff ${base}.txt ${lang}.txt > ${base}_${lang}.txt"
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
}
