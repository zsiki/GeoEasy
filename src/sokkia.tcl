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

#	Read in Sokia (set 4) data files into memory
#	Input data format (10 different record types, field separator is comma)
#	1 instrument record
#		record identifier (A)
#		instrument type
#		instrument id
#		SET ROM version
#		EDM ROM version
#		checksum
#
#	2 station record
#		record identifier (M)
#		date (yy.m.d)
#		station number
#		station mark
#		station height
#		temperature
#		air pressure
#		Northing or Easting
#		Easting or Northing
#		Elevation
#		unit of distance (0 meter 1 foot)
#		unit of temperature and air pressure 0 C/mbar 1 C/Hgmm 2 F/mbar
#			3 F/Hgmm 4 F/Hginch
#		refraction	0 none 1 k=0.142 2 k=0.20
#		prizm constant
#		unit of angle 0 360 degree 1 Gon
#		resolution of angle 0 1sec 1 5sec
#		start of vertical angle 0 zenit 1 vertical 2 horizontal
#		compensation of vertical angle 0 off 1 on
#		vertical circle indexing 0 automatic 1 manual
#		horizotal circle indexing 0 automatic 1 manual
#		coordinate order 0 north/east 1 east/north
#		always 0
#		checksum
#
#	3 observation
#		point number
#		record identifier (Ea)
#		status 4 digit
#			1st unit of distance 0 meter 1 foot
#			2nd unit of angle 0 360degree 1 Gon
#			3rd vertical angle 0 zenit 1 vertical 2 horizontal
#			4th horizontal angle 0 left 1 right 2 multiplier
#		point mark
#		signal height
#		ppm
#		slope distance
#		vertical angle
#		horizontal angle
#		checksum
#
#	4 observation (offset)
#		point number
#		record identifier (Ea)
#		status 4 digit
#			1st unit of distance 0 meter 1 foot
#			2nd unit of angle 0 360degree 1 Gon
#			3rd vertical angle 0 zenit 1 vertical 2 horizontal
#			4th horizontal angle 0 left 1 right 2 multiplier
#		point mark (point code)
#		signal height
#		ppm
#		direction of prizm 0 right 1 left 2 behind 3 in front
#		offset distance (horizontal)
#		slope distance
#		vertical angle
#		horizontal angle
#		checksum
#
#	5 observation (reference)
#		point number
#		record identifier (Ee)
#		status 4 digit
#			1st unit of distance 0 meter 1 foot
#			2nd unit of angle 0 360degree 1 Gon
#			3rd vertical angle 0 zenit 1 vertical 2 horizontal
#			4th horizontal angle 0 left 1 right 2 multiplier
#		point mark (point code)
#		signal height
#		ppm
#		vertical angle
#		horizontal angle
#		tilt angle in x direction
#		tilt angle in y direction
#		checksum
#
#	6 coordinates
#		point number
#		record identifier (Ed)
#		status 4 digit
#			1st unit of distance 0 meter 1 foot
#			2nd unit of angle 0 360degree 1 Gon
#			3rd vertical angle 0 zenit 1 vertical 2 horizontal
#			4th horizontal angle 0 left 1 right 2 multiplier
#		point mark
#		signal height
#		ppm
#		North or East
#		East or North
#		Elevation
#		checksum
#
#	7 observation+coordinates
#		point number
#		record identifier (Eh)
#		status 4 digit
#			1st unit of distance 0 meter 1 foot
#			2nd unit of angle 0 360degree 1 Gon
#			3rd vertical angle 0 zenit 1 vertical 2 horizontal
#			4th horizontal angle 0 left 1 right 2 multiplier
#		point mark
#		signal height
#		ppm
#		North or East
#		East or North
#		Elevation
#		slope distance
#		vertical angle
#		horizontal angle
#		checksum
#
#	8 note
#		record identifier (N)
#		note
#		checksum
#
#	9 manual input coordinates
#		point number
#		record identifier (Fd)
#		status 4 digit
#			1st unit of distance 0 meter 1 foot
#			2nd unit of angle 0 360degree 1 Gon
#			3rd vertical angle 0 zenit 1 vertical 2 horizontal
#			4th horizontal angle 0 left 1 right 2 multiplier
#		point mark
#		empty
#		empty
#		North or East
#		East or North
#		Elevation
#		checksum
#
#	@param fn path to input file
#	@param fa internal name of dataset
#	@return 0 on success
proc Sokia {fn fa} {
	global geoLoaded geoEasyMsg geoCodes
	global PI2
	global coord
	global reg

	set c_order 1
	if {[string length $fa] == 0} {return -1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f1 [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	set lines 0				;# number of lines in output
	set src 0				;# input line number
	set points 0			;# number of points in coord list
	set pcode ""
	set ${fa}_par ""
	while {! [eof $f1]} {
		incr src
		if {[gets $f1 buf] == 0} continue
		set buflist [split [string trim $buf] ","]	;# comma separated
		set n [llength $buflist]
		if {$n == 0} continue		;# empty line

		set obuf ""					;# output buffer
		if {[lindex $buflist 0] == "A"} {
			# instrument record
			if {[string length [GetVal 55 [set ${fa}_par]]] == 0} {
				lappend ${fa}_par \
					[list 55 "[lindex $buflist 1] [lindex $buflist 2]"]
			}
		} elseif {[lindex $buflist 0] == "N"} {
			# note record nothing to do
		
		} elseif {[lindex $buflist 0] == "C"} {
			# feature codes nothing to do
		
		} elseif {[lindex $buflist 0] == "M"} {
			# station record
			set pn [lindex $buflist 2]
			if {[string length [GetVal 51 [set ${fa}_par]]] == 0} {
				lappend ${fa}_par [list 51 [lindex $buflist 1]]
			}
			lappend obuf [list 2 $pn]					;# station name
			GeoLog1 "$geoCodes(2): $pn"
			lappend obuf [list 3 [lindex $buflist 4]]	;# instrument height
			lappend obuf [list 56 [lindex $buflist 5]]	;# temperature
			lappend obuf [list 74 [lindex $buflist 6]]	;# air pressure
			set c_order [lindex $buflist 20]
			if {$c_order} {				;# coordinate order E,N
				set x [lindex $buflist 7]
				set y [lindex $buflist 8]
			} else {					;# coordinate order N,E
				set y [lindex $buflist 7]
				set x [lindex $buflist 8]
			}
			set z [lindex $buflist 9]
			if {$x != 0 || $y != 0} {
				AddCoo $fa $pn $x $y $z $pcode
			}
		} elseif {[lindex $buflist 1] == "Ea"} {
			if {[llength $buflist] > 10} {
				# offset present, but slope distance and horizontal angle
				# corrected
				set buflist [lrange $buflist 0 5]
				lappend buflist [lindex $buflist 8]		;# slope dist.
				lappend buflist [lindex $buflist 9]		;# zenith angle
				lappend buflist [lindex $buflist 10]	;# horiz. angle
				lappend buflist [lindex $buflist 11]	;# checksum
			}
			# distance horizontal angle, vertical angle
			set pn [lindex $buflist 0]
			set state [lindex $buflist 2]
			# store point code if filled (not ?)
			set pcode [lindex $buflist 3]
			if {$pcode != "?"} {
				lappend obuf [list 4 $pcode]
			}
			lappend obuf [list 5 $pn]					;# station name
			lappend obuf [list 6 [lindex $buflist 4]]	;# signal height
			lappend obuf [list 9 [lindex $buflist 6]]	;# slope distance
			# vertical angle
			set w [GetVa [lindex $buflist 7] $state]
			if {$w == -1} { return $src }
			lappend obuf [list 8 $w]
			# horiz. angle
			set w [GetHa [lindex $buflist 8] $state]
			if {$w == -1} { return $src }
			lappend obuf [list 7 $w]

		} elseif {[lindex $buflist 1] == "Ee"} {
			# horizontal angle, vertical angle
			set pn [lindex $buflist 0]
			set state [lindex $buflist 2]
			# store point code if filled (not ?)
			set pcode [lindex $buflist 3]
			if {$pcode != "?"} {
				lappend obuf [list 4 $pcode]
			}
			lappend obuf [list 5 $pn]				;# point name
			lappend obuf [list 6 [lindex $buflist 4]]	;# signal height
			# vertical angle
			set w [GetVa [lindex $buflist 6] $state]
			if {$w == -1} { return $src }
			lappend obuf [list 8 $w]
			# horiz. angle
			set w [GetHa [lindex $buflist 7] $state]
			if {$w == -1} { return $src }
			lappend obuf [list 7 $w]

		} elseif {[lindex $buflist 1] == "Ed" || [lindex $buflist 1] == "Fd"} {
			# coordinate record
			set pn [lindex $buflist 0]
			set state [lindex $buflist 2]
			# store point code if filled (not ?)
			set pcode [lindex $buflist 3]
			if {$c_order} {				;# coordinate order E,N
				set x [lindex $buflist 6]
				set y [lindex $buflist 7]
			} else {					;# coordinate order N,E
				set y [lindex $buflist 6]
				set x [lindex $buflist 7]
			}
			set z [lindex $buflist 8]
			AddCoo $fa $pn $x $y $z $pcode
		} elseif {[lindex $buflist 1] == "Eh"} {
			# observations and coordinates
			set pn [lindex $buflist 0]
			set state [lindex $buflist 2]
			# store point code if filled (not ?)
			set pcode [lindex $buflist 3]
			if {$pcode != "?"} {
				lappend obuf [list 4 $pcode]
			}
			lappend obuf [list 5 $pn]				;# station name
			lappend obuf [list 6 [lindex $buflist 4]]	;# signal height
			lappend obuf [list 9 [lindex $buflist 9]]	;# slope distance
			# vertical angle
			set w [GetVa [lindex $buflist 10] $state]
			if {$w == -1} { return $src }
			lappend obuf [list 8 $w]
			# horiz. angle
			set w [GetHa [lindex $buflist 11] $state]
			if {$w == -1} { return $src }
			lappend obuf [list 7 $w]
			if {$c_order} {				;# coordinate order E,N
				set x [lindex $buflist 6]
				set y [lindex $buflist 7]
			} else {					;# coordinate order N,E
				set y [lindex $buflist 6]
				set x [lindex $buflist 7]
			}
			set z [lindex $buflist 8]
			AddCoo $fa $pn $x $y $z $pcode
		}
		if {[llength $obuf] > 1 || [GetVal 2 $obuf] != ""} {
			# check numeric values
			foreach l $obuf {
				if {[lsearch -exact \
						{3 6 7 8 9 10 11 21 24 25 26 27 28 29 37 38 39 49} \
						[lindex $l 0]] != -1 && \
						[regexp $reg(2) [lindex $l 1]] == 0} {
					return $src
				}
			}
			set face2 0
			set pnum [GetVal {5 62} $obuf]
			if {$pnum == ""} {
				#GeoLog1 [format "%-10s" [string range [GetVal 2 $obuf] 0 9]]
			} else {
				set li [expr {$lines - 1}]
				# look for the same point number in this station
				while {$li> 0} {
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
		}
	}
	close $f1
	return 0
}

#
#	Convert Gorn to radian
#	@param a angle to convert from Gon to radian
#	@return angle in radian
proc Gon2Rad {a} {
	global PI

	return [expr {$a / 200.0 * $PI}]
}

#
#	Get horizontal angle in randian and clockwise direction
#	@param angle angle to manipulate
#	@param state unit and direction
#	@return horizontal angle in randian and clockwise direction
proc GetHa {angle state} {
	global PI2

	if {[string index $state 1] == "0"} {
		set angle [Deg2Rad $angle]					;# horiz. angle in degree
	} else {
		set angle [Gon2Rad $angle]					;# horiz. angle in Gon
	}
	if {[string index $state 3] == "1"} {
		# change left hand angle to right hand angle
		set angle [expr {$PI2 - $angle}]
	}
	return $angle
}

#
#	Get vertical angle in randian and zenit direction
#	@param angle angle to manipulate
#	@param state unit and direction
#	@return vertical angle in randian and zenit direction
proc GetVa {angle state} {
	global PI2

	if {[string index $state 1] == "0"} {
		set angle [Deg2Rad $angle]					;# vert. angle in degree
	} else {
		set angle [Gon2Rad $angle]					;# vert. angle in Gon
	}
	# change angle to zenith
	switch -exact [string index $state 2] {
		0 {
			# zenit angle do nothing
		}
		1 {
			# vertical, horizontal = 0
			set va [expr {$PI / 2.0 - $va}] 
			if {$va < 0} { set va [expr {$va + 2.0 * $PI}] }
		}
		2 {
			# angle from horizont + up, - down
			set va [expr {$PI / 2.0 - $va}] 
		}
	}
	return $angle
}

#
#	Add coordinates to actual _coo array;
#		coords are not overwritten except previous value is 0
#	@param f name of geo data set
#	@param pn point name
#	@param x,y,z coordinates (xy and z optional)
#	@pcode point code
proc AddCoo {f pn x y {z ""} {pcode "?"}} {
	global ${f}_coo

	if {![info exists ${f}_coo($pn)]} {
		set ${f}_coo($pn) ""
		lappend ${f}_coo($pn) [list 5 $pn]
	}
	upvar #0 ${f}_coo($pn) coo_rec
	set prevx [GetVal {38 138} $coo_rec]
	if {$x != "" && ($prevx == "" || $prevx == 0)} {
		set coo_rec [DelVal {38 138} $coo_rec]
		lappend coo_rec [list 38 $x]
	}
	set prevy [GetVal {37 137} $coo_rec]
	if {$y != "" && ($prevy == "" || $prevy == 0)} {
		set coo_rec [DelVal {37 137} $coo_rec]
		lappend coo_rec [list 37 $y]
	}
	set prevz [GetVal {39 139} $coo_rec]
	if {$z != "" && ($prevz == "" || $prevz == 0)} {
		set coo_rec [DelVal {39 139} $coo_rec]
		lappend coo_rec [list 39 $z]
	}
	if {$pcode != "?" && $pcode != ""} {
		set coo_rec [DelVal {4} $coo_rec]
		lappend coo_rec [list 4 $pcode]
	}
	return 0
}

#
#	Save coordinates into Sokia SET 4 format
#	@param fn geo data set name
#	@param rn output file name (.scr)
#	@return 0 on success
proc SaveScr {fn rn} {
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
	# go through coordinates
	foreach pn [array names ${in}_coo] {
		set x [GetVal {38} [set ${in}_coo($pn)]]
		set y [GetVal {37} [set ${in}_coo($pn)]]
		set z [GetVal {39} [set ${in}_coo($pn)]]
		if {[string length $x] || [string length $y] || [string length $z]} {
			if {[catch {set buf [format "%d,Ed,0000,?,0.0,0," $pn]}]} {
				# non numeric point name
				append skipped "$pn "
				continue
			} else {
				if {[string length $x]} {
					append buf [format "%.3f," $x]
				} else {
					append buf "0.000,"
				}
				if {[string length $y]} {
					append buf [format "%.3f," $y]
				} else {
					append buf "0.000,"
				}
				if {[string length $z]} {
					append buf [format "%.3f," $z]
				} else {
					append buf "0.000,"
				}
			}
			set cs [checksum $buf]
			puts $f "$buf$cs"
		}
	}
	if {[string length $skipped]} {
		geo_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(nonNumPn) $skipped" \
			warning 0 OK
	}
	close $f
	return 0
}

#
#	Get Sokkia checksum for buf. Second complement of the sum of ascii codes
#	@param buf calculate scr checksum
#	@return checksum
proc checksum {buf} {

	set sum 0
	set n [string length $buf]
	for {set i 0} {$i < $n} {incr i} {
		scan [string index $buf $i] "%c" c
		incr sum $c
	}
	set sum [expr {-1 * $sum}]
	set res [format "%X" $sum]
	set m [string length $res]
	return [string range $res [expr {$m - 2}] [expr {$m -  1}]]
}
