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

#	Load GeoZseni gjk file
#
#       Read in GeoZseni data files into memory
#       Processed record types
#			AP - station record
#			AP,point number,code,ih,date,note,?,?,?,?
#			AM - orientation
#			AM,point number,code,th,hzI,hzII,hz,zI,zII,z,dI,dII,d
#			RM - detail point
#			RM,point number,code,th,hzI,hzII,hz,zI,zII,z,dI,dII,d
#	@param fn path to GeoZseni gjk file
#	@param fa internal name of dataset
#	@return 0 on success
proc GeoZseni {fn fa} {
	global reg

	if {[string length $fa] == 0} {return 1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f1 [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	set obuf ""				;# output buffer
	set lines 0				;# number of lines in output
	set src 0				;# input line number
	set jm 0				;# default signal height
	set ${fa}_par [list [list 0 "GeoZseni import"]]
	incr src
	gets $f1 buf			;# check first record
	if {[string compare $buf "GJK,2"] != 0} {
		return -1
	}
	while {! [eof $f1]} {
		incr src
		if {[gets $f1 buf] == 0} continue
		set buflist [split $buf ","]
		set rectype [lindex $buflist 0]
		switch -exact $rectype {
			AP {
				if {[llength $buflist] < 2} {
					return $scr
				}
				# point number
				set pn [lindex $buflist 1]
				set obuf ""
				lappend obuf [list 2 $pn]
				# point code
				set w [lindex $buflist 2]
				if {[string length $w]} {
					lappend obuf [list 4 $w]
				}
				# station height
				set w [lindex $buflist 3]
				if {[string length $w] > 0} {
					# check numeric value
					if {[regexp $reg(2) $w] == 0} { return $src }
					lappend obuf [list 3 $w]
				}
				if {[string length [GetVal 51 [set ${fa}_par]]] == 0 && \
					[string length [lindex $buflist 4]]} {
					lappend ${fa}_par [list 51 [lindex $buflist 4]]
				}
				if {[string length [GetVal 53 [set ${fa}_par]]] == 0 && \
					[string length [lindex $buflist 5]]} {
					lappend ${fa}_par [list 53 [lindex $buflist 5]]
				}
			}
			RM {
				if {[llength $buflist] < 2} {
					return $src
				}
				# point number
				set pn [lindex $buflist 1]
				set obuf ""
				lappend obuf [list 5 $pn]
				# point code
				set w [lindex $buflist 2]
				if {[string length $w]} {
					lappend obuf [list 4 $w]
				}
				# signal height
				set w [lindex $buflist 3]
				if {[string length $w]} {
					lappend obuf [list 6 $w]
				}
				# horizontal angle
				set w [lindex $buflist 6]
				if {[string length $w]} {
					set w [Deg2Rad $w]
					if {$w == "?"} { return $src }
					lappend obuf [list 7 $w]
				}
				# vertical angle
				set w [lindex $buflist 9]
				if {[string length $w]} {
					set w [Deg2Rad $w]
					if {$w == "?"} { return $src }
					lappend obuf [list 8 $w]
				}
				# slope distance
				set w [lindex $buflist 12]
				if {[string length $w]} {
					if {[regexp $reg(2) $w] == 0} { return $src }
					lappend obuf [list 9 $w]
				}
			}
			AM {
				if {[llength $buflist] < 2} {
					return $src
				}
				# point number
				set pn [lindex $buflist 1]
				set obuf ""
				lappend obuf [list 62 $pn]
				# point code
				set w [lindex $buflist 2]
				if {[string length $w]} {
					lappend obuf [list 4 $w]
				}
				# signal height
				set w [lindex $buflist 3]
				if {[string length $w]} {
					lappend obuf [list 6 $w]
				}
				# horizontal angle
				set w [lindex $buflist 6]
				if {[string length $w]} {
					set w [Deg2Rad $w]
					if {$w == "?"} { return $src }
					lappend obuf [list 21 $w]
				}
				# vertical angle
				set w [lindex $buflist 9]
				if {[string length $w]} {
					set w [Deg2Rad $w]
					if {$w == "?"} { return $src }
					lappend obuf [list 8 $w]
				}
				# slope distance
				set w [lindex $buflist 12]
				if {[string length $w]} {
					if {[regexp $reg(2) $w] == 0} { return $src }
					lappend obuf [list 9 $w]
				}
			}
		}
		if {$rectype == "AP" || $rectype == "RM" || $rectype == "AM"} {
			# check numeric values
			foreach l $obuf {
				if {[lsearch -exact \
						{3 6 7 8 9 10 11 21 24 25 26 27 28 29 37 38 39 49} \
						[lindex $l 0]] != -1 && \
						[regexp $reg(2) [lindex $l 1]] == 0} {
					return $src
				}
			}
			set ${fa}_geo($lines) $obuf
			if {[info exists ${fa}_ref($pn)] == -1} {
				set ${fs}_ref($pn) $lines
			} else {
				lappend ${fa}_ref($pn) $lines
			}
			incr lines
		}
	}
	close $f1
	return 0
}
