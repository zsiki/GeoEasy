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

#	Read in Nikon data files into memory
#	Input data format (2 different record types, field separator is comma)
#
#	Record format, coma separated
#		Storage state (1 before deletion)
#		Data type
#			0 - direction and distance
#			1 - co-ordinates from observation
#			2 - co-ordinates manual input
#			3 - co-ordinates uploaded
#		Units (2 bytes)
#			1st byte M/F/N meter/US foot/foot
#			2nd byte D/G/M DMS/Gon/Vonas
#		Point number
#		Slope distance/X co-ordinate
#		Direction/Y co-ordinate
#		Zenit angle/Z co-ordinate
#		Signal height (only for 0 data type)
#
#		Stations start must be marked by data type 2
#		e.g. 1,2,MD,point_number-instrument_height,x,y,z (x,y,z is optional)
#	@param fn name of nikon file
#	@return 0 on success
proc Nikon {fn} {
	global reg
	global geoEasyMsg

	set fa [GeoSetName $fn]
	if {[string length $fa] == 0} {return -1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f1 [open $fn r]}] != 0} {
		return -1	;# cannot open input file
	}
	set ${fa}_par [list [list 55 Nikon]]
	set lines 0		;# number of lines in output
	set src 0		;# input line number
	set points 0	;# number of points in coord list
	while {! [eof $f1]} {
		incr src
		if {[gets $f1 buf] == 0} continue
		set bl [split [string trim $buf] ","]	;# comma separated
		set buflist ""
		foreach a $bl {
			lappend buflist [string trim $a]
		}
		set n [llength $buflist]
		;# empty line or deleted record
		if {$n == 0 || [lindex $buflist 0] != 1} { continue }
		set obuf ""	;# output buffer
		switch -exact [lindex $buflist 1] {
			0 {
				# direction & distance
				set pn [lindex $buflist 3]
				lappend obuf [list 5 $pn]	;# point number
				switch -exact [string range [lindex $buflist 2] 0 0]  {
					"M" {	;# meter
						# slope distance
						if {[lindex $buflist 4] > 0} {
							lappend obuf [list 9 [lindex $buflist 4]]
						}
						# signal height
						if {[lindex $buflist 7] != 0} {
							lappend obuf [list 6 [lindex $buflist 7]]
						}
					}
					"F" {	;# US foot
					}
					"N" {	;# foot
					}
				}
				switch -exact [string range [lindex $buflist 2] 1 1]  {
					"D" {	;# DMS
						# horizontal direction
						lappend obuf [list 7 [Deg2Rad [lindex $buflist 5]]]
						# zenit direction
						lappend obuf [list 8 [Deg2Rad [lindex $buflist 6]]]
					}
					"G" {	;# GON
						# horizontal direction
						lappend obuf [list 7 [Gon2Rad [lindex $buflist 5]]]
						# zenit direction
						lappend obuf [list 8 [Gon2Rad [lindex $buflist 6]]]
					}
					"M" {	;# vonas
					}
				}
			}
			1 -
			2 -
			3 {	# new point or station
				set pn [lindex $buflist 3]
				if {[lindex $buflist 1] == 2} {
					# instrument height is after point number e.g. 123-1.40
					# for horizontal observations 123-
					set l [split $pn "-"]
					if {[llength $l] > 1} {
						set pn [lindex $l 0]
						set sh [lindex $l end]
						if {[llength $l] > 2} { set sh "-$sh" }
						lappend obuf [list 2 $pn]	;# station point number
						if {[string length $sh]} {
							lappend obuf [list 3 $sh]	;# instrument height
						}
					}
				}
				# store coordinates
				switch -exact [string range [lindex $buflist 2] 0 0] {
					"M" {	;# meter
						if {[llength $buflist] > 5} {
							set x [lindex $buflist 4]
							set y [lindex $buflist 5]
							set z ""
							if {[llength $buflist] > 6 && \
								[lindex $buflist 6] > 0} {
								set z [lindex $buflist 6]
							}
							AddCoo $fa $pn $x $y $z
						}
					}
					"N" {}
					"F" {}
				}
			}
		}

		if {[llength $obuf] > 1 || [GetVal 2 $obuf] != ""} {
			# check numerc values
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
				set ${fa}_ref($pn) $lines
			} else {
				lappend ${fa}_ref($pn) $lines
			}
			incr lines
		}
	}
	close $f1
	return 0
}

#
#	Save coordinates into Nikon DTM 300 format
#	@param fn geo set name
#	@oaram rn output file name (.nik)
proc SaveNikon {fn rn} {
	global geoEasyMsg
	global geoLoaded
	global ${fn}_coo

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8		;# geo data set not loaded
		}
	} else {
		return 0
	}
	set f [open $rn w]
	puts $f "A,01,Cks,"
	# go through coordinates
	foreach pn [array names ${fn}_coo] {
		set x [GetVal {38} [set ${fn}_coo($pn)]]
		set y [GetVal {37} [set ${fn}_coo($pn)]]
		set z [GetVal {39} [set ${fn}_coo($pn)]]
		if {[string length $x] || [string length $y] || [string length $z]} {
			set buf "G,[string range $pn 0 11],"
			if {[string length $x] == 0} { set x 0.0 }
			append buf [format "%11.3f," $x]
			if {[string length $y] == 0} { set y 0.0 }
			append buf [format "%11.3f," $y]
			if {[string length $z] == 0} { set z 0.0 }
			append buf [format "%11.3f," $z]
			puts $f $buf
		}
	}
	puts $f "Z,Cks,"
	close $f
	return 0
}
