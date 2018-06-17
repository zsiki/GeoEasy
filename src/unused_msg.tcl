#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"
# look for unused messages
global env argc argv

set lang "eng"
set langs [list eng hun ger]
foreach arg $argv {
	if {[lsearch $langs $arg] > -1} {
		set lang $arg
	}
}
source "geo_easy.$lang"
# load all sources
set f [open GeoEasy.tcl r]
set src [read $f]
close $f
foreach i [lsort [array names geoEasyMsg]] {
	if {[string first "geoEasyMsg($i)" $src] == -1} {
		puts "unused message $i"
	}
}
