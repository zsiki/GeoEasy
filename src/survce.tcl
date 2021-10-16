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

#	Read in SurvCE RW5 data file into memory
#	@param fn path to SurvCE rw5 file
#	@param fa internal name of dataset
#	@return 0 on success
proc SurvCe {fn fa} {
	global reg
	global geoLoaded
	global geoEasyMsg geoCodes

	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[string length $fa] == 0} {return -1}
	if {[catch {set f1 [open $fn r]}] != 0} {
		return -1	   ;# cannot open input file
	}
	set ${fa}_par [list [list 55 "rw5"]]
	set obuf ""			;# output buffer
	set lines 0			;# number of lines in output
	set src 0			;# input line number
	set ih ""			;# instrument height
	set th ""			;# target height
	set st_pn "NOT SET"	;# station number
	while {! [eof $f1]} {
		set obuf ""
		incr src
		if {[gets $f1 buf] == 0} continue
		set buflist [split [string trim $buf "\[ \t\];"] ","]
		switch -exact -- [lindex $buflist 0] {
			"JB" {
				# job record date, time
				foreach field [lrange $buflist 1 end] {
					switch -exact -- [string range $field 0 1] {
						"DT" { lappend ${fa}_par [list 51 [string range $field 2 end]]
						}
						"TM" { lappend ${fa}_par [list 52 [string range $field 2 end]]
						}
					}
				}
			}
			"MO" {
				# mode record
				foreach field [lrange $buflist 1 end] {
					switch -exact -- [string range $field 0 1] {
						"UN" { if {[string range $field 2 end] == 0} {
								set dist_mul 0.3048	;# feet
							}
						}
					}
				}
			}
			"LS" {
				# station and instrument height
				foreach field [lrange $buflist 1 end] {
					switch -exact -- [string range $field 0 1] {
						"HI" { set ih [string range $field 2 end]
						}
						"HR" { set th [string range $field 2 end]
						}
					}
				}
			}
			"OC" {
				# station
				set n ""
				set e ""
				set el ""
				set code ""
				set coord 0
				foreach field [lrange $buflist 1 end] {
					switch -exact -- [string range $field 0 1] {
						"OP" {
							set st_pn [string range $field 2 end]
							lappend obuf [list 2 $st_pn]
							GeoLog1 "$geoCodes(2): $st_pn"
							if {$ih != ""} {
								lappend obuf [list 3 $ih]
							}
						}
						"N " {
							set n [string range $field 2 end]
							incr coord
						}
						"E " {
							set e [string range $field 2 end]
							incr coord
						}
						"EL" {
							set el [string range $field 2 end]
							incr coord
						}
						"--" {
							set code [string range $field 2 end]
							lappend obuf [list 4 $code]
						}
					}
					if {$coord} {
						AddCoo $fa $st_pn $e $n $el $code
					}
				}
			}
			"SP" {
				# coordinate
				set n ""
				set e ""
				set el ""
				set code ""
				set coord 0
				foreach field [lrange $buflist 1 end] {
					switch -exact -- [string range $field 0 1] {
						"PN" {
							set st_pn [string range $field 2 end]
						}
						"N " {
							set n [string range $field 2 end]
							incr coord
						}
						"E " {
							set e [string range $field 2 end]
							incr coord
						}
						"EL" {
							set el [string range $field 2 end]
							incr coord
						}
						"--" {
							set code [string range $field 2 end]
						}
					}
					if {$coord} {
						AddCoo $fa $st_pn $e $n $el $code
					}
				}
			}
			"TR" -
			"SS" -
			"BD" -
			"BR" -
			"FD" -
			"FR" -
			"BK" {
				# observation
				foreach field [lrange $buflist 1 end] {
					switch -exact -- [string range $field 0 1] {
						"OP" { if {[string range $field 2 end] != $st_pn} {
								# TODO error
								continue	;# skip record
							}
						}
						"BP" -
						"FP" {
							lappend obuf [list 5 [string range $field 2 end]]
						}
						"AR" {
							lappend obuf [list 7 [Deg2Rad [string range $field 2 end]]]
						}
        				"BP" {
							lappend obuf [list 62 [string range $field 2 end]]
						}
						"BS" {
							lappend obuf [list 21 [Deg2Rad [string range $field 2 end]]]
						}
						"ZE" {
							lappend obuf [list 8 [Deg2Rad [string range $field 2 end]]]
						}
						"SD" {
							# TODO feet
							lappend obuf [list 9 [string range $field 2 end]]
						}
						"HD" {
							lappend obuf [list 11 [string range $field 2 end]]
						}
						"--" {
							set code [string range $field 2 end]
							lappend obuf [list 4 $code]
						}
					}
				}
                if {$th != ""} {
                    lappend obuf [list 6 $th]
                }
			}
		}
		if {[llength $obuf] == 0} { continue }
		# check numeric values
		foreach l $obuf {
			if {[lsearch -exact \
				{3 6 7 8 9 10 11 21 24 25 26 27 28 29 37 38 39 49} \
				[lindex $l 0]] != -1 && \
				[regexp $reg(2) [lindex $l 1]] == 0} {
				return $src
			}
		}
		set pn [GetVal 5 $obuf]
		set face2 0
		if {$pn != ""} {
			# check for face 2
			set li [expr {$lines - 1}]
			# look for the same point number in this station
			while {$li >= 0} {
				if {[string length [GetVal 2 [set ${fa}_geo($li)]]] != 0} {
					break
				}
				if {[GetVal {5} [set ${fa}_geo($li)]] == $pn} {
					set obuf1 [set ${fa}_geo($li)]
					set avgbuf [AvgFaces $obuf1 $obuf]
					if {[llength $avgbuf]} {
						set face2 1
					} else {
						GeoLog1 [format $geoEasyMsg(noface2) \
							[GetVal {5} $obuf]]
					}
					break
				}
				incr li -1
			}
		}
		if {$face2} {
			set ${fa}_geo($li) $avgbuf
		} else {
			# new first face
			set ${fa}_geo($lines) $obuf
			if {[info exists ${fa}_ref($pn)] == -1} {
				set ${fa}_ref($pn) $lines
			} else {
				lappend ${fa}_ref($pn) $lines
			}
			incr lines
		}
	}
	return 0
}
