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

#	Read in Leica idex data file into memory
#	@param fn name of leica idex file
#	@return 0 on success
proc Idex {fn} {
	global reg
	global geoLoaded
	global PI PI2
	global geoEasyMsg geoCodes

	set fa [GeoSetName $fn]
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[string length $fa] == 0} {return -1}
	if {[catch {set f1 [open $fn r]}] != 0} {
		return -1       ;# cannot open input file
	}
	set ${fa}_par ""
	set obuf ""             ;# output buffer
	set lines 0				;# number of lines in output
	set src 0				;# input line number
	set header 0			;# not in header
	set units 0
	set project 0
	set database 0			;# not in database section
	set points 0
	set theminfo 0
	set annotations 0
	set meteo 0
	set theodolite 0
	set instruments 0
	set configs 0
	set setup 0
	set slope 0

	while {! [eof $f1]} {
		incr src
		if {[gets $f1 buf] == 0} continue
		set buf [string trim $buf "\[ \t\];"]
		switch -regexp -- $buf {
			"^HEADER" { set header 1 }
			"^UNITS" { set units 1}
			"^END UNITS" { set units 0}
			"^END HEADER" { set header 0}
			"^PROJECT" { set project 1}
			"^END PROJECT" {set project 0}
			"^DATABASE" { set database 1}
			"^POINTS" { set points 1}
			"^END POINTS" { set points 0}
			"^THEMINFO" { set theminfo 1}
			"^END THEMINFO" { set theminfo 0}
			"^ANNOTATIONS" { set annotations 1}
			"^END ANNOTATIONS" { set annotations 0}
			"^END DATABASE" { set database 0}
			"^METEO" { set meteo 1}
			"^END METEO" { set meteo 0}
			"^THEODOLITE" { set theodolite 1}
			"^END THEODOLITE" { set theodolite 0}
			"^INSTRUMENTS" { set instruments 1}
			"^END INSTRUMENTS" { set instruments 0}
			"^SETUP" { set setup 1; set obuf ""}
			"^SLOPE" { set slope 1}
			"^END SLOPE" { set slope 0}
			"^END SETUP" {
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
				if {[info exists ${fa}_ref($pno)] == -1} {
					set ${fa}_ref($pno) $lines
				} else {
					lappend ${fa}_ref($pno) $lines
				}
				incr lines
				set obuf ""
				set setup 0
			}
			"^OPERATOR" {
				if {$header && $project} {
					while {[regsub -all "\[ \t\]\[ \t\]" $buf " " buf]} { }
					set buflist [split $buf " \t"]
					lappend ${fa}_par [list 53 [lindex $buf 1]]
				}
			}
			"^CREATION_DATE" {
				if {$header && $project} {
					while {[regsub -all "\[ \t\]\[ \t\]" $buf " " buf]} { }
					set buflist [split $buf " /\t"]
					lappend ${fa}_par [list 51 [lindex $buflist 1]]
					lappend ${fa}_par [list 52 [lindex $buflist 2]]
				}
			}
			"^ANGULAR" {
				if {$header && $units} {
					while {[regsub -all "\[ \t\]\[ \t\]" $buf " " buf]} { }
					set buflist [split $buf " \t"]
					if {[lindex $buf 1] != "DMS"} {
						tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(units) error 0 OK
						return $src
					}
				}
			}
			"^LINEAR" {
				if {$header && $units} {
					while {[regsub -all "\[ \t\]\[ \t\]" $buf " " buf]} { }
					set buflist [split $buf " \t"]
					if {[lindex $buf 1] != "METRE"} {
						tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(units) error 0 OK
						return $src
					}
				}
			}
			"^STN_ID" {
				if {$theodolite && $setup} {
					while {[regsub -all "\[ \t\]\[ \t\]" $buf " " buf]} { }
					set buflist [split $buf " \t"]
					set pno [string trim [lindex $buflist 1] \"]
					lappend obuf [list 2 $pno]
					GeoLog1 "$geoCodes(2): $pno"
				}
			}
			"^INST_HT" {
				if {$theodolite && $setup} {
					while {[regsub -all "\[ \t\]\[ \t\]" $buf " " buf]} { }
					set buflist [split $buf " \t"]
					lappend obuf [list 3 [lindex $buflist 1]]
				}
			}
			default {
				# remove all white spaces
				while {[regsub -all "\[ \t\]" $buf "" buf]} { }
				set buflist [split $buf ","]
				set pno [string trim [lindex $buflist 1] \"]
				if {$database && $points && ! $theminfo && ! $annotations} {
					if {[info exists ${fa}_coo($pno)] == 0} {
						# new point
						set ${fa}_coo($pno) [list [list 5 $pno]]
					}
					if {[lindex $buflist 2] != "" && \
						[GetVal {38} [set ${fa}_coo($pno)]] == ""} {
						# new east
						set val [lindex $buflist 2]
						if {[regexp $reg(2) $val] == 0} {
							return $src
						}
						lappend  ${fa}_coo($pno) [list 38 $val]
					}
					if {[lindex $buflist 3] != "" && \
						[GetVal {37} [set ${fa}_coo($pno)]] == ""} {
						# new north
						set val [lindex $buflist 3]
						if {[regexp $reg(2) $val] == 0} {
							return $src
						}
						lappend  ${fa}_coo($pno) [list 37 $val]
					}
					if {[lindex $buflist 4] != "" && \
						[GetVal {39} [set ${fa}_coo($pno)]] == ""} {
						# new z
						set val [lindex $buflist 4]
						if {[regexp $reg(2) $val] == 0} {
							return $src
						}
						lappend  ${fa}_coo($pno) [list 39 $val]
					}
					set pcode [string trim [lindex $buflist 5] \"]
					if {$pcode != "" && \
						[GetVal {4} [set ${fa}_coo($pno)]] == ""} {
						lappend  ${fa}_coo($pno) \
							[list 4 $pcode]
					}
				} elseif {$theodolite && $instruments} {
					set iname [string trim [lindex $buflist 0] \"]
					lappend ${fa}_par [list 55 "$iname [lindex $buflist 1]"]
				} elseif {$theodolite & $slope} {
					set pno [string trim [lindex $buflist 1] \"]
					set obuf ""
					lappend obuf [list 5 $pno]
					set hz [Deg2Rad [lindex $buflist 3]]
					set vz [Deg2Rad [lindex $buflist 4]]
					if {[regexp $reg(2) $hz] == 0 || \
							[regexp $reg(2) $vz] == 0} {
						return $src
					}
					lappend obuf [list 7 $hz]
					lappend obuf [list 8 $vz]
					set dist [lindex $buflist 5]
					if {$dist > 0.001} {
						if {[regexp $reg(2) $dist] == 0} { return $src}
						lappend obuf [list 9 $dist]
					}
					set th [lindex $buflist 6]
					if {$th != 0} {
						if {[regexp $reg(2) $th] == 0} { return $src}
						lappend obuf [list 6 $th]
					}
					# check face2
					set face2 0
					if {[string length [GetVal 2 $obuf]] == 0} {
						set li [expr {$lines - 1}]
						# look for the same point number in this station
						while {$li> 0} {
							if {[string length [GetVal 2 [set ${fa}_geo($li)]]] != 0} {
								break
							}
							if {[GetVal {5 62} [set ${fa}_geo($li)]] == $pno} {
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
						if {[info exists ${fa}_ref($pno)] == -1} {
							set ${fa}_ref($pno) $lines
						} else {
							lappend ${fa}_ref($pno) $lines
						}
						incr lines
					}
				}
			}
		}
	}
	close $f1
	# copy point codes from coord list to observations
	foreach i [lsort -integer [array names ${fa}_geo]] {
		set pn [GetVal {5 62} [set ${fa}_geo($i)]]
		if {[string length $pn]} {
			set c [GetCoord2 $pn {4} $fa]
			if {[llength $c]} {
				lappend ${fa}_geo($i) [list 4 [GetVal 4 $c]]
			}
		}
	}
	return 0
}
