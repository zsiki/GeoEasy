#!/bin/sh
# the next line restarts using tcl \
exec tclsh "$0" "$@"
global argv
	eval auto_mkindex . $argv
