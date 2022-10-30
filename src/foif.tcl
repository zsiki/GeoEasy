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

#	Read in FOIF data files into memory
#	Input data format (field separator is comma), used fields marked by *
#	first character defines the recond type
#
#	    header record (first line)
#	        space
#	        file name *
#	        point count
#	        point count with deleted points
#	        year *
#	        month *
#	        day *
#	        hour *
#	        minute *
#	        second *
#	        target type
#	        distance measure mode
#	        prism type
#	        prism constant
#	        pressure
#	        temperature
#	        average elevation
#	        PPM
#	        orientation marker
#
#       Station (occupied point)
#           A
#           point number *
#           N *
#           E *
#           Z *
#           instrument height *
#           position mark
#           year
#           month
#           day
#           hour
#           minute
#           second
#
#       orientation point
#           B
#           point number *
#           instruction
#           N
#           E
#           Z
#
#       angle and distance measure
#           F/G
#           point number *
#           horizontal angle * (half second unit)
#           vertical angle * (half second unit)
#           horizontal distance
#           slope distance *
#           height difference
#           prism height *
#           N *
#           E *
#           Z *
#           measure status mark
#           position mark
#           year
#           month
#           day
#           hour
#           minute
#           second
#
#	@param fn path to FOIF file
#	@param fa internal name of dataset
#	@return 0 on success
proc Foif {fn fa} {
	global reg
	global geoEasyMsg
    global RO

	if {[string length $fa] == 0} {return -1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f1 [open $fn r]}] != 0} {
		return -1	;# cannot open input file
	}
	set ${fa}_par [list [list 55 "FOIF"]]
	set lines 0		;# number of lines in output
	set src 1		;# input line number
	set points 0	;# number of points in coord list
    # get header
    if {[gets $f1 header] == 0} { return }
    if {[string index $header 0] != " "} { return $src }    ;# invalid header
    set bl [split [string trim $header] ","]
	set ${fa}_par [list [list 51 "[lindex $bl 3]-[lindex $bl 4]-[lindex $bl 5]"]]
	set ${fa}_par [list [list 52 "[lindex $bl 6]:[lindex $bl 7]:[lindex $bl 8]"]]
    set prev_sd 0
    set prev_ha -1
    set prev_va -1
	while {! [eof $f1]} {
		incr src
		if {[gets $f1 buf] == 0} continue
		set bl [split [string trim $buf] ","]	;# comma separated
		set buflist ""
		foreach a $bl {
			lappend buflist [string trim $a]
		}
		set n [llength $buflist]
		
		if {$n == 0} { continue }   ;# empty line
		set obuf ""	;# output buffer
		switch -exact [lindex $buflist 0] {
            A {
                # station
                set pn [lindex $buflist 1]
                set x [lindex $buflist 2]
                set y [lindex $buflist 3]
                set z ""
                if {[string length [lindex $buflist 4]]} {
                    set z [lindex $buflist 4]
                }
                set ih [lindex $buflist 5]
                AddCoo $fa $pn $x $y $z
                lappend obuf [list 2 $pn]	;# station number
                lappend obuf [list 3 $ih]	;# instrument height
            }
            B -
            H {
                # orientation/reference target
                set pn [lindex $buflist 1]
                set x [lindex $buflist 3]
                set y [lindex $buflist 4]
                set z ""
                if {[string length [lindex $buflist 5]]} {
                    set z [lindex $buflist 5]
                }
                AddCoo $fa $pn $x $y $z
            }
            C -
            D -
            E {
                # orientation measure/orientaion result/orientation adjusment/
            }
            F -
            G {
                # angle and distance measurement
                set pn [lindex $buflist 1]
                set ha [expr {[lindex $buflist 2] / 2.0 / $RO}]
                set va [expr {[lindex $buflist 3] / 2.0 / $RO}]
                set sd [lindex $buflist 5]
                set th [lindex $buflist 7]
                set x [lindex $buflist 8]
                set y [lindex $buflist 9]
                set z ""
                if {[string length [lindex $buflist 10]]} {
                    set z [lindex $buflist 10]
                }
                AddCoo $fa $pn $x $y $z
                lappend obuf [list 5 $pn]
                lappend obuf [list 7 $ha]       ;# horizontal angle
                lappend obuf [list 8 $va]       ;# zenith angle
                if {$sd > 0.1 && ([expr {abs($sd - $prev_sd)}] > 0.1 || \
                    ([expr {abs($ha - $prev_ha)}] < 0.001 && 
                     [expr {abs($va - $prev_va)}] < 0.001))} {
                    # store distance if it changes or the same direction (3')
                    lappend obuf [list 9 $sd]   ;# slope distance
                }
                lappend obuf [list 6 $th]
                set prev_sd $sd
                set prev_ha $ha
                set prev_va $va
            }
		}

		if {[llength $obuf] > 1} {
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
            if {[string length [GetVal 5 $obuf]] > 0} { ;# observation record
                # average of two faces
                set li [expr {$lines - 1}]
                while {$li > 0} {
                    if {[string length \
                            [GetVal 2 [set ${fa}_geo($li)]]] != 0} {
                        break   ;# stop previous station record reached
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
