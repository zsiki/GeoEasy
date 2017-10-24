#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

# Copied from geo_easy.tcl!
#------------------------------------------------------------------------------
#
#   -- CenterWnd
#       this - handle to window
#
#   Center window on screen
#------------------------------------------------------------------------------
proc CenterWnd {this} {

    set g [split [winfo geometry $this] "x+"]
    set wthis [lindex $g 0]         ;# width of dialog
    set hthis [lindex $g 1]         ;# height of dialog
    set w [winfo screenwidth .]     ;# width of screen
    set h [winfo screenheight .]    ;# height of screen
    set x [expr {int(($w - $wthis) / 2.0)}]
    set y [expr {int(($h - $hthis) / 2.0)}]
    wm geometry $this "+${x}+${y}"
    update
}

#-------------------------------------------------------------------------------
#	-- main module for stanalone ComEasy application
#		do not use it if embending into GeoEasy
#-------------------------------------------------------------------------------
	global env
	global auto_path
	global tcl_platform
	global lastDir
	set home "."
	set lastDir $home
	if {[info exists tcl_platform(isWrapped)]} {
		set auto_path $home
		lappend auto_path lib/tcl8.3
		lappend auto_path lib/tk8.3
	} else {
		set auto_path [linsert $auto_path 0 $home]
	}

	if {[file isfile [file join $home com_easy.hun]] == 0 || \
			[file readable [file join $home com_easy.hun]] == 0} {
		tk_dialog .msg "Hiba" "Az uzenet fajlt (com_easy.hun) nem talalom" \
			error 0 OK
		exit
	}

	if {[catch {source [file join $home com_easy.hun]} msg] == 1} {
		tk_dialog .msg "Hiba" "Hiba az uzenet fajlban:\n$msg" error 0 OK
		exit
	}
	
	set w ""
	if {[info exists env(GEO_DEBUG)] && $env(GEO_DEBUG) == 1} {
		ComEasy .com
	} else {
		ComEasy .
	}
