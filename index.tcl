#!/bin/sh
# the next line restarts using tcl \
exec tclsh "$0" "$@"
global argv
#set names {adjgeo.tcl animate.tcl calcgeo.tcl dxfgeo.tcl sdr.tcl \
#		geodimet.tcl graphgeo.tcl helpgeo.tcl lbgeo.tcl leica.tcl \
#		loadgeo.tcl maskgeo.tcl profigeo.tcl soc.tcl sokia.tcl travgeo.tcl \
#		transgeo.tcl printgeo.tcl sentinel.tcl \
#		topcon.tcl nikon.tcl trimble.tcl}
	eval auto_mkindex . $argv
