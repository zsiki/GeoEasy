#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"
# look for unused messages
global env argc argv

if {[llength $argv] > 2} {
	puts "Usage: unused_msg.tcl \[prog\] \[lang\]"
	exit
}
set lang "eng"
set langs [list eng hun ger rus cze es]
set prog "geo"
set prog1 "Geo"
set progs [list geo com]
foreach arg $argv {
	if {[lsearch $langs $arg] > -1} {
		set lang $arg
	} elseif {[lsearch $progs $arg] > -1} {
		set prog $arg
		set prog1 "[string toupper [string range $prog 0 0]][string range $prog 1 end]"
	}
}
source "i18n/${prog}_easy.$lang"
# load all sources
set f [open "${prog1}Easy.tcl" r]
set src [read $f]
close $f
foreach i [lsort [array names "${prog}EasyMsg"]] {
	if {[string first "${prog}EasyMsg($i)" $src] == -1} {
		puts "unused message $i"
	}
}
