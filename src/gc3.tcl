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

#	Import GeoCalc3 measure file (.gmj)
#	Rows in file consist of 14 field separated by coma (,)
#	Fields:
#		1 - unique id for each row
#		2 - point number
#		3 - horizontal angle
#		4 - zenith angle?
#		5 - slope distance
#		6 - horizontal distance
#		7 - height difference
#		8 - point code
#		9 - instrument height
#		10- target height
#		11- reduced distance (skipped)
#		12- station code1
#		13- station code2
#		14- station/target code (-1=station, -2=observed point)
#
#	TWO FACES NOT SUPPORTED!!!
#	@param fn file name of GeoCalc gmj file
#	@param fo name of output file without extension
#	@return 0 on success
proc GeoCalc {fn {fo ""}} {
	global geoLoaded
	global reg
	global geoEasyMsg

	set fa [GeoSetName $fn]
	if {[string length $fa] == 0} {return 1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f1 [open $fn r]}] != 0} {
		return -1		;# cannot open input file
	}
	set lines 0			;# number of lines in output
	set lineno 0		;# line number in input

	while {! [eof $f1]} {
		incr lineno
		if {[gets $f1 buf] == 0} { continue }
		set buflist [split [string trim $buf] ","]  ;# comma separated
		set n [llength $buflist]
		if {$n == 0} { continue }
		if {$n != 14} {       ;# missing field
			close $f1
			return $lineno  ;# error in input
		}
		set obuf ""                 ;# output buffer
		set pn [string trim [lindex $buflist 1]]
		if {$pn == ""} {
			close $f1
			return $lineno
		}
		if {[lindex $buflist 13] == -1} {
			# station record
			lappend obuf [list 2 $pn]	;# station name
			set ih [string trim [lindex $buflist 8]]
			if {[string length $ih] && $ih != 0} {
				lappend obuf [list 3 $ih]	;# station height
			}
			set c1 [string trim [lindex $buflist 11]]
			set c2 [string trim [lindex $buflist 12]]
			set c "$c1/$c2"
			if {$c != "/"} {
				lappend obuf [list 4 $c]	;# point code
			}
			# check numeric values

		} elseif {[lindex $buflist 13] == -2} {
			# observation record
			lappend obuf [list 5 $pn]	;# target name
			set ha [string trim [lindex $buflist 2]]
			if {[string length $ha]} {
				lappend obuf [list 7 [Deg2Rad $ha]]
			}
			set za [string trim [lindex $buflist 3]]
			if {[string length $za]} {
				lappend obuf [list 8 [Deg2Rad $za]]
			}
			set sd [string trim [lindex $buflist 4]]
			if {[string length $sd]} {
				lappend obuf [list 9 $sd]
			}
			set hd [string trim [lindex $buflist 5]]
			# store horizontal distance if no slope distance or zenith
			if {[string length $hd] && ($sd == "" || $za == "")} {
				lappend obuf [list 11 $hd]
			}
			set dm [string trim [lindex $buflist 6]]
			# store height diff if no slope distance or zenith
			if {[string length $dm] && ($sd == "" || $za == "")} {
				lappend obuf [list 10 $hd]
			}
			set c [string trim [lindex $buflist 7]]
			if {[string length $c]} {
				lappend obuf [list 4 $c]
			}
			set th [string trim [lindex $buflist 9]]
			if {[string length $th]} {
				lappend obuf [list 6 $th]
			}
		} else {
			close $f1
			return $lineno  ;# error in input
		}
		foreach l $obuf {
			if {[lsearch -exact \
					{3 6 7 8 9 10 11 21 24 25 26 27 28 29 37 38 39 49} \
					[lindex $l 0]] != -1 && \
					[regexp $reg(2) [lindex $l 1]] == 0} {
				return $lineno
			}
		}
		set ${fa}_geo($lines) $obuf
		if {[info exists ${fa}_ref($pn)] == -1} {
			set ${fa}_ref($pn) $lines
		} else {
			lappend ${fa}_ref($pn) $lines
		}
		incr lines
	}
	close $f1
	return 0
}
