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

#	Read in Sokkia (sdr) data files into memory
#	Input data format (34 different record types)
#	@param fn path to sokkia sdr file
#	@param fa internal name for dataset
#	@return 0 on success
proc Sdr {fn fa} {
	global geoLoaded
	global PI2
	global coord
	global reg
	global angleUnit distanceUnit coordOrder angleDirection
	global geoEasyMsg geoCodes

	if {[string length $fa] == 0} {return -1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f1 [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	set lines 0				;# number of lines in output
	set src 0				;# input line number
	set points 0			;# number of points in coord list
	set code ""
	# default angle unit 1 DEG
	set angleUnit 1
	# default distance unit 1 meter
	set distanceUnit 1
	# default co-ordinate order 2 EN
	set coordOrder 2
	# default direction clockwise
	set angleDirection 1
	# default point number length 4 SDR2x
	set pnLength 4
	# default target height
	set targetHeight ""
	set pn ""
	set stpn ""

	while {! [eof $f1]} {
		incr src
		if {[gets $f1 buf] == 0} continue
		set n [string length $buf]
		if {$n == 0} continue		;# empty line

		set obuf ""					;# output buffer
		set face2 0
		switch -exact [string range $buf 0 1] {
			"00" {	;# head record
				if {[string range $buf 4 8] == "SDR33"} {
					set pnLength 16
				}
				set un [string length $buf]
				if {$un < 47} {
					set ${fa}_par [list [list 0 [string range $buf 4 8]] \
						[list 51 [string range $buf 24 32]] \
						[list 52 [string range $buf 34 38]]]
				} else {	;# patch for ruide
					set ${fa}_par [list [list 0 [string range $buf 4 8]] \
						[list 51 [string range $buf 24 33]] \
						[list 52 [string range $buf 35 39]]]
				}
				# take the last 6 digit for units (RUIDE)
				set units [string range $buf [expr {$un - 6}] $un]
				# angle unit 1 DEG 2 GON 3 MILL
				set angleUnit [string range $units 0 0]
				# distance unit 1 meter 2 feet
				set distanceUnit [string range $units 1 1]
				# co-ordinate order 1 NE 2 EN
				set coordOrder [string range $units 4 4]
				# clockwise, counter clockwise
				set angleDirection [string range $units 5 5]
			}
			"01" {	;# instrument record
                if {[string first "Ruide R2" $buf] > -1} {
                    # special hack for Ruide SDR
                    set pnLength 16
                }
			}
			"02" {	;# station record
				if {$pnLength == 16} {
					# station name
					set stpn [string trim [GetSdrField $buf 4 16]]
					# station height
					set v [GetSdrField $buf 68 16 GetSdrDist]
					set code [GetSdrField $buf 84 16]
					set start 20
					set len 16
				} else {
					# station name
					set stpn [GetSdrField $buf 4 4]
					# station height
					set v [GetSdrField $buf 38 10 GetSdrDist]
					set code [GetSdrField $buf 48 16]
					set start 8
					set len 10
				}
                # remove leading zeros
                regsub "^0*(\[1-9\]\[0-9\]*)$" [string trim $stpn] \\1 stpn
                if {$stpn == ""} { set stpn "0" }
                lappend obuf [list 2 $stpn]
                GeoLog1 "$geoCodes(2): $stpn"
                if {[string length $v]} {
                    lappend obuf [list 3 $v]
                }
                set pn $stpn    ;# for ref update
				# station co-ordinates
				SdrCoo $fa $buf $stpn $code $start $len 
			}
			"03" {	;# target height
				if {$pnLength == 16} {
					set targetHeight [GetSdrField $buf 4 16 GetSdrDist]
				} else {
					set targetHeight [GetSdrField $buf 4 10 GetSdrDist]
				}
			}
			"04" {	;# collimation
			}
			"05" {	;# atmosphere
			}
			"06" {	;# scale
			}
			"07" {	;# orientation
			}
			"08" {	;# co-ordinate
				if {$pnLength == 16} {
					set pn [GetSdrField $buf 4 16]
					set code [GetSdrField $buf 68 16]
					set start 20	;# start of 1st coord
					set len 16		;# length of coordinate value
				} else {
					set pn [string trim [string range $buf 4 7]]
					set code [GetSdrField $buf 38 16]
					set start 8		;# start of 1st coord
					set len 10		;# length of coordinate value
				}
				SdrCoo $fa $buf $pn $code $start $len 
			}
			"09" {	;# observation
				set sourceCode [string range $buf 2 3]
				# face1 and face2 records only
				if {$sourceCode == "F1" || $sourceCode == "F2"} {
					if {$pnLength == 16} {
						if {[GetSdrField $buf 4 16] != $stpn} {
							# add missing station record
							set stpn [GetSdrField $buf 4 16]
							set ${fa}_geo($lines) [list [list 2 $stpn]]
							GeoLog1 "$geoCodes(2): $stpn"
							if {[info exists ${fa}_ref($pn)] == -1} {
								set ${fa}_ref($pn) $lines
							} else {
								lappend ${fa}_ref($pn) $lines
							}
							incr lines
						}
						set pn [GetSdrField $buf 20 16]
						# remove leading zeros
						regsub "^0*(\[1-9\]\[0-9\]*)$" [string trim $pn] \\1 pn
						if {$pn == ""} { set pn "0" } 
						lappend obuf [list 5 $pn]
						# slope distance
						set v [GetSdrField $buf 36 16 GetSdrDist]
						if {[string length $v]} {
							lappend obuf [list 9 $v]
						}
						# zenit angle
						set v [GetSdrField $buf 52 16 GetSdrVa]
						if {[string length $v]} {
							lappend obuf [list 8 $v]
						}
						# horizontal angle
						set v [GetSdrField $buf 68 16 GetSdrHa]
						if {[string length $v]} {
							lappend obuf [list 7 $v]
						}
						# point code
						set code [GetSdrField $buf 84 16]
						if {[string length $code]} {
							lappend obuf [list 4 $code]
						}
					} else {
						if {[GetSdrField $buf 4 4] != $stpn} {
							# add missing station record
							set stpn [GetSdrField $buf 4 4]
							set ${fa}_geo($lines) [list [list 2 $stpn]]
							GeoLog1 "$geoCodes(2): $stpn"
							if {[info exists ${fa}_ref($pn)] == -1} {
								set ${fa}_ref($stpn) $lines
							} else {
								lappend ${fa}_ref($stpn) $lines
							}
							incr lines
						}
						set pn [GetSdrField $buf 8 4]
						lappend obuf [list 5 $pn]
						# slope distance
						set v [GetSdrField $buf 12 10 GetSdrDist]
						if {[string length $v]} {
							lappend obuf [list 9 $v]
						}
						# zenit angle
						set v [GetSdrField $buf 22 10 GetSdrVa]
						if {[string length $v]} {
							lappend obuf [list 8 $v]
						}
						# horizontal angle
						set v [GetSdrField $buf 32 10 GetSdrHa]
						if {[string length $v]} {
							lappend obuf [list 7 $v]
						}
						# point code
						set code [GetSdrField $buf 42 16]
						if {[string length $code]} {
							lappend obuf [list 4 $code]
						}
					}
					if {$targetHeight != ""} {
						lappend obuf [list 6 $targetHeight]
					}
				}
			}
			"10" {	;# job
				# point id type alphanum/num VERY IMPORTANT
				if {[string range $buf 20 20] == "1"} {
					set pnLength 16
				} else {
					set pnLength 4
				}
			}
			"11" {	;# reduced observation
			}
			"12" {	;# iranysorozat
			}
			"13" {	;# remark
                # TODO Ruide has observation here
			}
		}
		if {[llength $obuf] > 0} {
			foreach l $obuf {
				if {[lsearch -exact \
						{3 6 7 8 9 10 11 21 24 25 26 27 28 29 37 38 39 49} \
						[lindex $l 0]] != -1 && \
						[regexp $reg(2) [lindex $l 1]] == 0} {
					return $src
				}
			}
			set face2 0
			if {[string length [GetVal 5 $obuf]] > 0} {
				# average of two faces
				set li [expr {$lines - 1}]
				while {$li > 0} {
					if {[string length \
							[GetVal 2 [set ${fa}_geo($li)]]] != 0} {
						break
					}
					if {[GetVal 5 [set ${fa}_geo($li)]] == $pn} {
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
			}
			if {$face2} {
				#store average for 2 faces
				set ${fa}_geo($li) $avgbuf
			} else {
				set ${fa}_geo($lines) $obuf
				if {[info exists ${fa}_ref($pn)] == -1} {
					set ${fa}_ref($pn) $lines
				} else {
					lappend ${fa}_ref($pn) $lines
				}
				incr lines
			}
		}
	}
	close $f1
	return 0
}

#
#	Read in coordinates from Sokkia sdr file and store it in coo array
#	@param fa data set name
#	@param buf processed input line
#	@param pn point number/name
#	@param start start of first coordinate
#	@param len length of coordinate field
proc SdrCoo {fa buf pn code start len} {
	global geoEasyMsg
	global angleUnit distanceUnit coordOrder angleDirection

	if {$code == "...."} {
		set code ""
	}
	if {$coordOrder == 1} {	;# N E order
		set y [GetSdrField $buf $start $len GetSdrDist]
		incr start $len
		set x [GetSdrField $buf $start $len GetSdrDist]
	} else {	;# E N order
		set x [GetSdrField $buf $start $len GetSdrDist]
		incr start $len
		set y [GetSdrField $buf $start $len GetSdrDist]
	}
	incr start $len
	set z [GetSdrField $buf $start $len GetSdrDist]
	if {([string length $x] && [string length $y]) || [string length $z]} {
		AddCoo $fa $pn $x $y $z $code
	}
}

#
#	Get distance in meters
#	@param dist distance or coordinate to manipulate
#	@param distanceUnit 1 meter, 2 foot
#	@return distance in meters
proc GetSdrDist {dist} {
	global distanceUnit
	global FOOT2M
# 1 foot = 0.3048 meter
	if {$distanceUnit == 2} {
		set dist [expr {$dist * $FOOT2M}]
	}
	return $dist
}

#
#	Get horizontal angle in randian and clockwise direction
#	@param angle angle to manipulate
#	@return horizontal angle in randian and clockwise direction
proc GetSdrHa {angle} {
	global PI2
	global angleUnit angleDirection

	if {$angleUnit == 1} {
		set angle [D2Rad $angle]					;# horiz. angle in degree
	} elseif {$angleUnit == 2} {
		set angle [Gon2Rad $angle]					;# horiz. angle in Gon
	} else {
		# mills TODO
		return ""
	}
	if {$angleDirection == 2} {
		# change left hand angle to right hand angle
		set angle [expr {$PI2 - $angle}]
	}
	return $angle
}

#
#	Get vertical angle in randian and zenit direction
#	@param angle angle to manipulate
#	@param angleUnit 1 DMS, 2 GON, 3 vonas
#	@return vertical angle in randian and zenit direction
proc GetSdrVa {angle} {
	global PI2
	global angleUnit

	if {$angleUnit == 1} {
		set angle [D2Rad $angle]					;# vert. angle in degree
	} elseif {$angleUnit == 2} {
		set angle [Gon2Rad $angle]					;# vert. angle in Gon
	} else {
		# mills TODO
		return ""
	}
	return $angle
}

#
#   Change angle from degree to radian
#	@param deg angle in degree and decimals (like 12.97734527)
#	@return angle in radian
proc D2Rad {d} {
	global PI
	return [expr {$d / 180.0 * $PI}]
}

#
#	Get numeric field value
#	@param buf input line
#	@param start start position of field
#	@param len length of field
#	@param valproc proc to evaluate field
#	@return numeric field value or empty string
proc GetSdrField {buf start len {valproc ""}} {

	set val [string trim [string range $buf $start [expr {$start + $len -1}]]]
	if {[string length $val] > 0 && [string length $valproc] > 0} {
		if {[catch {set val [eval $valproc $val]}]} { set val "" }
	}
	return $val
}

#
#	Save coordinates into Sokkia sdr33 format
#	@param fn geo data set name
#	@param rn output file name (.sdr)
proc SaveSdr {fn rn} {
	global geoEasyMsg
	global geoLoaded

    set in [GetInternalName $fn]
	global ${in}_coo

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $in]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	set f [open $rn w]
	set skipped ""
	set line 0
	#output header record
	set dt [clock format [clock seconds] -format "%d-%b-%y %H:%M"]
	puts $f "00NMSDR33               $dt 113121"
	
	puts $f [format "10NM%-16s121111" [string range [file rootname [file tail $rn]] 0 15]]
	# go through coordinates
	foreach pn [array names ${in}_coo] {
		incr line
		set x [GetVal {38} [set ${in}_coo($pn)]]
		set y [GetVal {37} [set ${in}_coo($pn)]]
		set z [GetVal {39} [set ${in}_coo($pn)]]
		if {[string length $x] || [string length $y] || [string length $z]} {
			puts -nonewline $f "08NM"
			if {[string length $pn] > 16} {
				set pn [string range $pn 0 15]
			}
			puts -nonewline $f [format "%16s" $pn]
			if {[string length $x]} {
				set xs [string range [format "%.16f" $x] 0 15]
			} else { set xs [format "%16s" " "] }
			puts -nonewline $f $xs
			if {[string length $y]} {
				set ys [string range [format "%.16f" $y] 0 15]
			} else { set ys [format "%16s" " "] }
			puts -nonewline $f $ys
			if {[string length $z]} {
				set zs [string range [format "%.16f" $z] 0 15]
			} else { set zs [format "%16s" " "] }
			puts -nonewline $f $zs
			puts $f [format "%16s" " "]	;# description
		}
	}
	close $f
	return 0
}
