#
# Copyright (C) 2017 Zoltan Siki siki1958 (at) gmail (dot) com
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#	Display html document in browser
#	@param doc name of html file to open in browser
#	@param topic position in html file (for example #load)
proc GeoHelp {{doc "sugo.html"} {topic ""}} {
	global geoEasyMsg
	global comEasyMsg
	global browser
	global tcl_platform
	global home

	set helpdir [file join $home help]
	set helpdir1 [file join $home comhelp]
	set htmlfile [file join $helpdir $doc]
	if {![file exists $htmlfile]} {
		set htmlfile [file join $helpdir1 $doc]
	}
	if {[file exists $htmlfile]} {
		if {[string length $topic]} {
			append htmlfile $topic
		}
		if {[ShellExec "$htmlfile"]} {
			if {[info exists geoEasyMsg]} {
				tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(browser) \
					warning 0 OK
			} else {
				tk_dialog .msg $comEasyMsg(warning) $comEasyMsg(browser) \
					warning 0 OK
			}
		}
	} else {
		if {[info exists geoEasyMsg]} {
			tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(helpfile) \
				warning 0 OK
		} else {
			tk_dialog .msg $comEasyMsg(warning) $comEasyMsg(helpfile) \
				warning 0 OK
		}
	}
}

#
#	Display About dialog box
proc GeoAbout {} {
	global geoEasyMsg
	global geoModules
	global tcl_platform
	global build_date
	global home

	if {! [info exists build_date]} {
		source $home/build_date.tcl
	}
	if {! [info exists build_date]} {
		set build_date "?"
	}
	set w [focus]
	if {$w == ""} { set w "." }
	set bmdir [file join $home bitmaps]
	catch {destroy .about}
	toplevel .about -class Dialog
	wm title .about $geoEasyMsg(menuHelpAbout)
	wm resizable .about 0 0
	wm transient .about $w
	if {[lsearch -exact [image names] about] == -1} {
		image create photo about -file [file join $bmdir about.gif]
	}
	label .about.l -image about
	label .about.t1 -text $geoEasyMsg(mainTitle)
	if {$tcl_platform(platform) == "unix"} {
		set n "GeoEasy"
	} else {
		set n "GeoEasy.exe"
	}
	if {[file exist $n]} {
		set s [file size $n]
	}
	label .about.t11 -text "(built $build_date)"
	label .about.t2 -text $geoEasyMsg(digikom)
	label .about.t3 -text $geoEasyMsg(about1)
	label .about.t4 -text $geoEasyMsg(about2)
	label .about.t5 -text "$geoEasyMsg(modules) [join $geoModules]"
	label .about.t6 -text $geoEasyMsg(opensource)
	grid .about.l -column 0 -row 0 -rowspan 4
	grid .about.t1 -column 1 -row 0
	grid .about.t11 -column 1 -row 1
	grid .about.t2 -column 1 -row 2
	grid .about.t3 -column 1 -row 3
	grid .about.t4 -column 1 -row 4
	grid .about.t5 -column 1 -row 5
	grid .about.t6 -column 1 -row 6
	button .about.ok -text $geoEasyMsg(ok) -command "destroy .about"
	grid .about.ok -row 7 -column 0 -columnspan 2
	tkwait visibility .about
	CenterWnd .about
	grab set .about
}
