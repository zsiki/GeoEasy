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

#	Load trimble data set
#	Note: Free station observation blocks are skipped
# Trimble M5 format
#	Record length 119 byte + CR LF
#	Positional fields with separator (|), spaces are significant
#
#	Column
#	1-6     Format type "For M5" or "For_M5"
#	8-10    Type identifier1 for address
#	12-16   Memory address of data line
#	18-20   Type identifier2 (PIn - point info, TI - text info, TO, n=0-9)
#			PI - Point identification, TI - Text information
#	22-48   Information block
#	50-51   Type identifier3
#	53-66   Block3 value
#	68-71	Unit block3
#	73-74   Type identifier4
#	76-89   Block4 value
#	91-94	Unit block4
#	96-97   Type identifier5
#	99-112	Block5 value
#	114-117 Unit block5
#	119     Blank field in case of error
#
#	Angle units: gon, deg, DMS, mil, grad
#	Distance, coordinate units: m, ft
#	Pressure units: Torr, hPa, inHg
#	Temperature units: C, F
#
#	Type identifiers handled:
#	01 - instrument type
#	02 - instrument ID
#	03 - software version
#	04 - language
#	05 - coordsys (1:XY, 2:YX, 3:NE)
#	06 - order of coords (1:YX/XY/EN, 2:XY/YX/NE)
#	20 - position I
#	21 - position C
#	22 - position P
#	HD - horizontal distance
#	Hz - horizontal direction
#	h  - height difference
#	ih - instrument height
#	PI - point identifier
#	SD - slope distance
#	th - reflector height
#	V1 - zenith angle
#	V3 - height angle (magassagi szog)
#	X  - X coordinate
#	x  - x coordinate local
#	Y  - Y coordinate
#	y  - y coordinate local
#	Z  - Z coordinate
#	@param fn path to input file
#	@param fa internal name of dataset
#	@return non-zero on error
proc TrimbleM5 {fn fa} {
	global geoLoaded geoEasyMsg geoCodes
	global FOOT2M PI PI2
	global reg
	global loadHeader

	if {[string length $fa] == 0} {return -1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f1 [open $fn r]}] != 0} {
		return -1       ;# cannot open input file
	}
	set lines 0             ;# number of lines in output
	set src 0               ;# input line number
	set points 0            ;# number of points in coord list
	set pIndex 15			;# point number position in 2nd value block
	set cIndex 10			;# code position in 2nd value block
	set iIndex 0			;# info position in 2nd value block
	set instr ""			;# instrument name
	set ih ""				;# instrument height
	set th ""				;# target height
	set blk ""				;# last block KN STAT/UN STAT/INPUT
	set orientation 0
	set ${fa}_par [list [list 0 "Trimble M5"]]

	while {! [eof $f1]} {
		incr src
		set pn ""
		set code ""
		set obuf ""
		set obs 0
		set coords 0
		set x ""
		set y ""
		set z ""
		if {[gets $f1 buf] == 0 || [string trim $buf] == "" || \
			[regexp "^END" $buf] } { continue }

		# check format field
		set recFormat [string range $buf 0 5]
		if {[string compare $recFormat "For M5"] != 0 &&
			[string compare $recFormat "For_M5"] != 0} {
			close $f1
			return $src
		}
		# type of block 2
		set b2 [string range $buf 17 18]
		if {[string compare $b2 "PI"] == 0} {
			# point identification
			set pn [string trim [ \
				string range $buf [expr {21 + $pIndex}] [expr {32 + $pIndex}]]]
			set code [string trim [ \
				string range $buf [expr {21 + $cIndex}] [expr {25 + $cIndex}]]]
			set info [string trim [ \
				string range $buf [expr {21 + $iIndex}] [expr {27 + $cIndex}]]]
			if {[string length $code]} {
				lappend obuf [list 4 $code]
			}
		} elseif {[string compare $b2 "TI"] == 0} {
			# text information
			set pn ""
			set info [string trim [string range $buf 21 47]]
			if {[regexp "^\[KU\]N STAT$" $info]} {
				set orientation 1
				set blk $info
			} elseif {[string length $info]} {
				set orientation 0
				if {$info == "POLAR"} { set blk $info}
			}
		}
		# process block 3-5
		set pos 49	;# start of 3rd block
		for {set i 0} {$i < 3} {incr i} {
			set type [string trim [string range $buf $pos [expr {$pos + 1}]]]
			set value [string trim [ \
				string range $buf [expr {$pos + 3}] [expr {$pos + 16}]] " \t"]
			set unit [string tolower [string trim [ \
				string range $buf [expr {$pos + 18}] [expr {$pos + 21}]]]]
			switch -exact $type {
				"01" {
					set instr $value
				}
				"02" {
					set wbuf [set ${fa}_par]
					DelVal 55 $wbuf
					lappend $wbuf [list 55 "$instr $value"]
					set ${fa}_par $wbuf
				}
				"20" {
					set iIndex [expr {$value - 1}]	;# info pos in 2nd block
				}
				"21" {
					set cIndex [expr {$value - 1}]	;# code pos in 2nd block
				}
				"22" {
					set pIndex [expr {$value -1}]	;# pnum. pos. in 2nd block
				}
				SD {
					if {$unit == "ft"} {
						set value [format "%.3f" [expr {$value * $FOOT2M}]]
					}
					if {$value > 0.001} {
						lappend obuf [list 9 $value]
						set obs 1	;# observation record
					}
				}
				HD {
					if {$unit == "ft"} {
						set value [format "%.3f" [expr {$value * $FOOT2M}]]
					}	
					if {$value > 0.001} {
						lappend obuf [list 11 $value]
						set obs 1	;# observation record
					}
				}
				h {
					if {$unit == "ft"} {
						set value [format "%.3f" [expr {$value * $FOOT2M}]]
					}	
					lappend obuf [list 10 $value]
					set obs 1	;# observation record
				}
				ih {
					if {$unit == "ft"} {
						set value [format "%.3f" [expr {$value * $FOOT2M}]]
					}
					set ih $value
					if {$lines} {
						set li [expr {$lines - 1}]
					} else {
						set li 0
					}
					if {$lines && [GetVal 2 [set ${fa}_geo($li)]] != ""} {
					# replace instrument height in previous station record
						set tmp [DelVal 3 [set ${fa}_geo($li)]]
						lappend tmp [list 3 $value]
						set ${fa}_geo($li) $tmp
					}
				}
				th {
					if {$unit == "ft"} {
						set value [format "%.3f" [expr {$value * $FOOT2M}]]
					}	
					set th $value
#					lappend obuf [list 6 $value]
				}
				Hz {
					switch -exact $unit {
						dms {
							set value [Deg2Rad $value]
						}
						gon {
							set value [Gon2Rad $value]
						}
						deg {
							set value [expr {$value / 180.0 * $PI}]
						}
						default {
							close $f1
							return $src
						}
					}
					lappend obuf [list 7 $value]
					set obs 1	;# observation record
				}
				V1 {
					switch -exact $unit {
						dms {
							set value [Deg2Rad $value]
						}
						gon {
							set value [Gon2Rad $value]
						}
						deg {
							set value [expr {$value / 180.0 * $PI}]
						}
						default {
							close $f1
							return $src
						}
					}
					lappend obuf [list 8 $value]
					set obs 1	;# observation record
				}
				V3 {
					switch -exact $unit {
						dms {
							set value [Deg2Rad $value]
						}
						gon {
							set value [Gon2Rad $value]
						}
						deg {
							set value [expr {$value / 180.0 * $PI}]
						}
						default {
							close $f1
							return $src
						}
					}
					set value [expr {$PI / 2 - $value}]
					set obs 1	;# observation record
					while {$value  < 0} {
						set value [expr {$value + $PI2}]
					}
					lappend obuf [list 8 $value]
				}
                N_ -
				X {
					if {$unit == "ft"} {
						set value [format "%.3f" [expr {$value * $FOOT2M}]]
					}	
					set x $value
					set coords 1	;# coordinate record
				}
                E_ -
				Y {
					if {$unit == "ft"} {
						set value [format "%.3f" [expr {$value * $FOOT2M}]]
					}	
					set y $value
					set coords 1	;# coordinate record
				}
                Z_ -
				Z {
					if {$unit == "ft"} {
						set value [format "%.3f" [expr {$value * $FOOT2M}]]
					}	
					set z $value
					set coords 1	;# coordinate record
				}
			}
			incr pos 23
		}
		if {$obs && [string length $pn] && \
			(! [regexp "^\[ABCDEFGHIJ\]$" $code] || $blk == "POLAR")} {
			if {[string length $th]} {
				lappend obuf [list 6 $th]	;# add last target height
			}
			# check numeric values
			foreach l $obuf {
				if {[lsearch -exact \
						{3 6 7 8 9 10 11 21 24 25 26 27 28 29 37 38 39 49} \
						[lindex $l 0]] != -1 && \
						[regexp $reg(2) [lindex $l 1]] == 0} {
					return $src
				}
			}
			set obuf [linsert $obuf 0 [list 5 $pn]]
			set face2 0
			# check for face 2
			set li [expr {$lines - 1}]
			# look for the same point number in this station
			while {$li >= 0} {
				if {[string length [GetVal 2 [set ${fa}_geo($li)]]] != 0} {
					break
				}
				if {[GetVal {5 62} [set ${fa}_geo($li)]] == $pn} {
					# really second face?
					set obuf1 [set ${fa}_geo($li)]
					set avgbuf [AvgFaces $obuf1 $obuf]
					if {[llength $avgbuf]} {
						set face2 1
					} else {
						GeoLog1 [format $geoEasyMsg(noface2) \
							[GetVal {5 62} $obuf]]
					}
					break
				}
				incr li -1
			}
			if {$face2} {
				#store average for 2 faces
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
		} elseif {$code == "S" && [string length $pn]} {
			set obuf [list [list 2 $pn]]
			GeoLog1 "$geoCodes(2): $pn"
			if {[string length $ih]} {
				lappend obuf [list 3 $ih]
				set ih ""
			}
			if {$orientation} {
				lappend obuf [list 101 0]
			}
			set ${fa}_geo($lines) $obuf
			if {[info exists ${fa}_ref($pn)] == -1} {
				set ${fa}_ref($pn) $lines
			} else {
				lappend ${fa}_ref($pn) $lines
			}
			if {$coords} {
				AddCoo $fa $pn $y $x $z $code
			}
			incr lines
		} 
		if {$coords  && [string length $pn]} {
			AddCoo $fa $pn $y $x $z $code
		}
	}
	close $f1
	return 0
}
