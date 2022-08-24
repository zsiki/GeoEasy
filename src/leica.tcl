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

#
#       Read in leica (gsi) data files into memory
#		station start marked with code block
# 41....+00000002 42....+00000100 43....+00001500 44....+target height 45....+date/time
# or
# 41....+00000021 42....+00000100 43....+00001500 (MS60)
# station start   station number  instrument height
# change in target heigth are marked code block to
# 41....+00000003 42....+00001546 - target height
#
# or 84/85/86 code can be used to mark station record
# code blocks mustnot be used this case
# lines started with ! are skipped
# @param fn name of leica (wild) file
# @param fa internal name of dataset
# @param fo name of output file without extension
# @return 0 on success
proc Leica {fn fa {fo ""}} {
	global geoLoaded
	global PI2 PI
	global reg
	global geoEasyMsg geoCodes
	global FOOT2M

	set codeblock 0			;# no codeblock found
	if {[string length $fa] == 0} {return 1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f1 [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	set lines 0				;# number of lines in output
	set points 0			;# number of points in coord list
	set st_code 0			;# station start code == 2
	set st_pn ""			;# station number
	set lineno 0			;# line number in input
	set pcode ""
	set ${fa}_par [list [list 55 leica]]
	while {! [eof $f1]} {
		incr lineno
		if {[gets $f1 buf] == 0} { continue }
		if {[string index $buf 0] == "!" || \
			[string index $buf 0] == "\x03" } { continue }
		# remove "*" in case of 16 digit input file
		if {[string index $buf 0] == "*"} {
			set buf [string range $buf 1 [expr {[string length $buf] - 1}]]
			set offset 22
		} else {
			set offset 14
		}
		set buflen [string length $buf]
		set pos 0
		set buflist ""
		while {$pos < $buflen} {
			lappend buflist [string range $buf $pos [expr {$pos + 5}]]
			set w [string index $buf [expr {$pos + 6}]]
			lappend buflist $w
			lappend buflist [string range $buf [expr {$pos + 7}] \
				[expr {$pos + $offset}]]
			set pos [expr {$pos + $offset + 2}]
			if {$pos < $buflen && \
				[string index $buf [expr {$pos-1}]] != " " || \
				[string first $w "+-"] == -1 } {
				close $f1
				return $lineno	;# error in input
			}
		}
#		regsub -all {\+} $buf " + " buf	;# separate + with spaces
#		regsub -all {\-} $buf " - " buf	;# separate - with spaces
#		set buflist [split [string trim $buf] " "]	;# space separated
		set n [llength $buflist]
		if {$n == 0} { continue }	;# empty line

		set obuf ""					;# output buffer
		set x 0					;# target coordinates
		set y 0
		set z 0
		set x_set 0				;# markers for found coords
		set y_set 0
		set z_set 0
		set station_x 0			;# station coordinates
		set station_y 0
		set station_z 0
		set station_x_set 0				;# markers for found coords
		set station_y_set 0
		set station_z_set 0
        set pcode ""
		for {set i 0} {$i < $n} {incr i 3} {
			set i2 [expr {$i + 2}]
			set w [lindex $buflist $i]
			set code [string range $w 0 1]
			set sign [lindex $buflist [expr {$i + 1}]]
			set v [lindex $buflist $i2]
			regsub {^0+} [string trim $v] "" val	;# leading zeros and spaces
			if {[string length $val] == 0} {set val 0}
			if {[string index $val 0] == "."} {set val "0$val"}
			# check numeric values
			if {[lsearch -exact {21 22 31 32 33 43 81 82 83 84 85 86 87 88} \
					$code] != -1 && [regexp $reg(2) $val] == 0} {
				# patch for smart station conversion! skip coords with ----
				if {[lsearch -exact {81 82 83} $code] != -1 && \
					[regexp -- "\-$" $val]} { continue }
				close $f1
				return $lineno	;# error in input
			}
			# unit for val 0 meter (3 tizedes)  1 feet (3 tizedes)
			#              2 gon 3 decimal_degree 4 DMS 5 mil (6400)
			#              6 meter (4 tizedes) 7 feet (4 tizedes)
			#              8 meter (5 tizedes)
			set unit [string index $w end]
			# check units only for these if no decimal point is in the value
			if {[lsearch -exact {21 22 31 32 33 43 44 81 82 83 84 85 86 87 88} \
					$code] != -1 && [string first "." $val] == -1} {
				if {[regexp -- "^\[1-9\]\[0-9\]*$|^0$" $val] != 0} {
					switch -exact -- $unit {
						. -
						0 { set val [expr {$val / 1000.0}] }
						1 { set val [expr {$val / 1000.0 *  $FOOT2M}] }
						2 { set val [Gon2Rad [expr {$val / 100000.0}]] }
						3 { set val [expr {$val / 10000.0 / 180.0 * $PI}] }
						4 { set m [string length $v]
							set angle "[string range $v 0 [expr {$m - 6}]].[string range $v [expr {$m - 5}] end]"
							set val [Deg2Rad $angle]
							}
						5 { set val [expr {$val / 6400.0 * $PI2}] }
						6 { set val [expr {$val / 10000.0}] }
						7 { set val [expr {$val / 10000.0 *  $FOOT2M}] }
						8 { set val [expr {$val / 100000.0}] }
						default { geo_dialog .msg $geoEasyMsg(error) \
								$geoEasyMsg(units) error 0 OK
								close $f1
								return $lineno
						}
					}
				} else {
					set val 0
					geo_dialog .msg $geoEasyMsg(error) \
							$geoEasyMsg(wrongval) error 0 OK
					close $f1
					return $lineno
				}
			}
			switch -glob $code {
				"11" {	;# point number
					set pn $val
					lappend obuf [list 5 $val]
				}
				"21" {	;# horizontal angle
					lappend obuf [list 7 $val]
				}
				"22" {	;# zenith angle
					lappend obuf [list 8 $val]
				}
				"31" {	;# slope distance
					if {$val > 0} {
						lappend obuf [list 9 $val]
					}
				}
				"32" {	;# horizontal distance
					if {$val > 0} {
						lappend obuf [list 11 $val]
					}
				}
				"33" {	;# vertical distance
					if {$val != 0} {	;# not measured ?
						set dm $val
						if {$sign == "-"} {set dm [expr {-$dm}]}
						lappend obuf [list 120 $dm]
					}
				}
				"41" {	;# station code == 2 or 21 (MS60)
					if {$val == 2 || $val == 21} {
						set st_code 2
						set codeblock 1
						if {[info exists defH]} { unset defH }
					} elseif {[regexp "^\\?\.*\[1-4\]$" $val]} {
						# levelling field book
						close $f1
						#   remove memory structures
						foreach a "${fa}_geo ${fa}_ref ${fa}_coo ${fa}_par" {
							catch "unset $a"
						}
						return [LeicaDNA $fn $fa $fo]
					}
				}
				"42" {	;# station number
					if {$st_code == 2} {
						set pn $val
						set st_pn $val
						lappend obuf [list 2 $val]
						GeoLog1 "$geoCodes(2): $st_pn"
					}
					# date
					if {$st_code == 1} {
						set ${fa}_par [DelVal 51 [set ${fa}_par]]
						lappend ${fa}_par [list 51 $val]
					}
					# target height
					if {$st_code == 3} {
						if {[string first "." $val] == -1} {
							if {$val != 0} {
								catch {set defH [expr {$val / 1000.0}]}
							} else {
								unset defH
							}
						} else {
							if {$val != 0} {
								set defH $val
							} else {
								unset defH
							}
						}
					}
				}
				"43" {	;# instrument height
					if {$st_code == 2} {
						set h $val
						if {$sign == "-"} {set h [expr {-$h}]}
						lappend obuf [list 3 $h]
					}
				}
				"44" {	;# target height
					if {$st_code == 2} {
						set defH $val
						if {$sign == "-"} {set defH [expr {-$defH}]}
					}
				}
				"45" {	;# date/time
					if {$st_code == 2} {
						lappend ${fa}_par [list 51 $val]
					}
				}
				"5*" {
				}
				"71" {	;# first remark
					set pcode [string trim $val]
					#lappend obuf [list 4 $pcode]
				}
                "72" -
                "73" -
                "74" -
                "75" -
                "76" -
                "77" -
                "78" -
                "79" {  ;# further remarks
                    #lappend obuf [list [expr {$code + 100}] [string trim $val]]
                    append pcode ":" $val
                }
				"81" {
					set x_set 1
					set x $val
					if {$sign == "-"} {set x [expr {-$x}]}
				}
				"82" {
					set y_set 1
					set y $val
					if {$sign == "-"} {set y [expr {-$y}]}
				}
				"83" {
					set z_set 1
					set z $val
					if {$sign == "-"} {set z [expr {-$z}]}
				}
				"84" {
					set station_x_set 1
					set station_x $val
					if {$sign == "-"} {set station_x [expr {-$station_x}]}
				}
				"85" {
					set station_y_set 1
					set station_y $val
					if {$sign == "-"} {set station_y [expr {-$station_y}]}
				}
				"86" {
					set station_z_set 1
					set station_z $val
					if {$sign == "-"} {set station_z [expr {-$station_z}]}
				}
				"87" {	;# reflector height
					set H $val
					if {$sign == "-"} {set H [expr {-$H}]}
					lappend obuf [list 6 $H]
				}
				"88" {	;# station height
					set h $val
					if {$sign == "-"} {set h [expr {-$h}]}
					
					lappend obuf [list 3 $h]
				}
			}
		}
		if {[GetVal 2 $obuf] == "" && [GetVal 6 $obuf] == "" && \
			[info exists defH]} {
			# add default target height
			lappend obuf [list 6 $defH]
		}
        if {[string length $pcode] != 0} {
            lappend obuf [list 4 $pcode]
        }
		if {$x_set != 0 && $y_set != 0 && $z_set != 0} {
			AddCoo $fa $pn $x $y $z $pcode
		} elseif {$x_set != 0 && $y_set != 0} {
			AddCoo $fa $pn $x $y "" $pcode
		} elseif {$z_set != 0} {
			AddCoo $fa $pn "" "" $z $pcode
		}
		if {$station_x_set != 0 && $station_y_set != 0 && $station_z_set != 0} {
			AddCoo $fa $pn $station_x $station_y $station_z
		} elseif {$station_x_set != 0 && $station_y_set != 0} {
			AddCoo $fa $pn $station_x $station_y
		} elseif {$station_z_set != 0} {
			AddCoo $fa $pn "" "" $station_z
		}
		# check for new style station
		# station record must contain 88 code (station height)
		# and no codeblock before
		if {$codeblock == 0 && [string length [GetVal 5 $obuf]] != 0 && \
				$station_x_set && $station_y_set} {
			set st_pn [GetVal 5 $obuf]
			# remove observations and point number
			set obuf [DelVal {5 6 7 8 9 10 11} $obuf]
			lappend obuf [list 2 $st_pn]
			GeoLog1 "$geoCodes(2): $st_pn"
		} elseif {$codeblock == 1 && [string length [GetVal 5 $obuf]] != 0 && \
				[string length [GetVal 3 $obuf]] != 0} {
			# remove station heigth if code block present
			set obuf [DelVal 3 $obuf]
		}
		if {[llength $obuf] > 1 || [string length [GetVal 2 $obuf]] != 0} {
			# check numeric values
			foreach l $obuf {
				if {[lsearch -exact \
						{3 6 7 8 9 10 11 21 24 25 26 27 28 29 37 38 39 49} \
						[lindex $l 0]] != -1 && \
						[regexp $reg(2) [lindex $l 1]] == 0} {
					close $f1
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
					if {[GetVal {5 62} [set ${fa}_geo($li)]] == $pnum} {
						# really second face?
						set obuf1 [set ${fa}_geo($li)]
						set avgbuf ""
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
			set code 0
		}
	}
	close $f1
	return 0
}

#
#	Calculate average values for two faces
#	return the average or an empty list if index error > 6' or
#	collimation erro > 6' or distance difference > 0.1m
#	@param f1 values from first face
#	@param f2 values from second face
#	@return average values
proc AvgFaces {f1 f2} {
	global PI PI2 RO
	global geoEasyMsg geoCodes
	global maxColl maxIndex
	global loadHeader
	# check zenith angle to select face 1
	set z1 [GetVal 8 $f1]
	set z2 [GetVal 8 $f2]
	if {([string length $z1] != 0 && $z1 > $PI) || \
			([string length $z2] != 0 && $z2 < $PI)} {
		# exchange faces
		set w $f1; set f1 $f2; set f2 $w
		# exchange zenith angles
		set w $z1; set z1 $z2; set z2 $w
	}
	# get repeat count of observations
	set n1 [GetVal 112 $f1]
	if {$n1 == ""} { set n1 1 }
	set n2 [GetVal 112 $f2]
	if {$n2 == ""} { set n2 1 }
	set indexError 0
	set collimationError 0
	set dt 0
	set z ""
	set indexError 0
	if {[string length $z1] != 0 && [string length $z2] != 0} {
		# index error
		set indexError [expr {($PI2 - $z1 - $z2) / 2.0}]
		if {[expr {abs($indexError)}] <= [expr {$maxIndex / $RO}]} {	;# two faces OK
			# atlagolt ertekeke szamanak tarolasa es figyelembe vetele az atlagolasnal
			set z [expr {($z1 * $n1 + ($PI2 - $z2) * $n2) / ($n1 + $n2)}]
			set n [expr {$n1 + $n2}]
		} elseif {[expr {abs($z1 - $z2)}] <= [expr {$maxIndex / $RO}]} {
			# observations in same face
			set indexError [expr {($z2 - $z1) / 2.0}]
			set z [expr {($z1 * $n1 + $z2 * $n2) / ($n1 + $n2)}]
			set n [expr {$n1 + $n2}]
			if {$z > $PI} { set z [expr {$PI2 - $z}]}
		} else {
			GeoLog1 "$geoEasyMsg(faces) $geoEasyMsg(error): [GetVal {5 62} $f1] $geoCodes(8)"
			return ""
		}
	} elseif {[string length $z1] != 0} {
		set z $z1
		set n 1
	} elseif {[string length $z2] != 0} {
		set z [expr {$PI2 - $z2}]
		set n 1
	}
	if {[string length $z] != 0} {
		set f1 [DelVal {8 112} $f1]
		lappend f1 [list 8 $z]
		lappend f1 [list 112 $n]
	}
	# horizontal angle
	set h1 [GetVal {7 21} $f1]
	set h2 [GetVal {7 21} $f2]
	set h ""
	set collimationError 0
	if {[string length $h1] != 0 && [string length $h2] != 0} {
		if {[expr {abs($h2 - $h1)}] <= [expr {$maxColl / $RO}]} {
			# same face, suppose first face
			set h [expr {($h1 * $n1 + $h2 * $n2) / ($n1 + $n2)}]
			set n [expr {$n1 + $n2}]
			set collimationError [expr {($h2 - $h1) / 2.0}]
		} elseif {[expr {abs(abs($h2 - $h1) - $PI2)}] <= [expr {$maxColl / $RO}]} {
			# same face near 0 and 360
			if {$h1 < $h2} {
				set h1 [expr {$h1 + $PI2}]
			} else {
				set h2 [expr {$h2 + $PI2}]
			}
			set h [expr {($h1 * $n1 + $h2 * $n2) / ($n1 + $n2)}]
			set n [expr {$n1 + $n2}]
			set collimationError [expr {($h2 - $h1) / 2.0}]
		} else {
			if {$h1 > $h2} {
				# collimation error
				set collimationError [expr {($h2 - $h1 + $PI) / 2.0}]
				set h [expr {($h1 * $n1 + ($h2 + $PI) * $n2) / ($n1 + $n2)}]
				set n [expr {$n1 + $n2}]
			} else {
				# collimation error
				set collimationError [expr {($h2 - $h1 - $PI) / 2.0}]
				set h [expr {($h1 * $n1 + ($h2 - $PI) * $n2) / ($n1 + $n2)}]
				set n [expr {$n1 + $n2}]
			}
			if {[expr {abs($collimationError)}] > [expr {$maxColl / $RO}]} {
				# too large error > 6'
				GeoLog1 "$geoEasyMsg(faces) $geoEasyMsg(error): [GetVal {5 62} $f1] $geoCodes(7)"
				return ""
			}
		}
		while {$h < 0} {set h [expr {$h + $PI2}]}
		while {$h > $PI2} {set h [expr {$h - $PI2}]}
	} elseif {[string length $h1] != 0} {
		set h $h1
		set n 1
	} elseif {[string length $h2] != 0} {
		if {$h2 > $PI} {
			set h [expr {$h2 - $PI}]
			set n 1
		} else {
			set h [expr {$h2 + $PI}]
			set n 1
		}
	}
	if {[string length $h] != 0} {
		set f1 [DelVal {7 21 112} $f1]
		lappend f1 [list 7 $h]
		lappend f1 [list 112 $n]
	}
	# slope distance
	set t1 [GetVal 9 $f1]
	set t2 [GetVal 9 $f2]
	set t ""
	set dt 0
	if {[string length $t1] != 0 && $t1 > 0.001 && \
			[string length $t2] != 0 && $t2 > 0.001} {
		set dt [expr {abs($t2 - $t1)}]
		if {$dt > 0.1} {	;# too large diff > 0.1 m
			GeoLog1 "$geoEasyMsg(faces) $geoEasyMsg(error): [GetVal {5 62} $f1] $geoCodes(9)"
			return ""
		}
		set t [expr {($t1 * $n1 + $t2 * $n2) / ($n1 + $n2)}]
		set n [expr {$n1 + $n2}]
	} elseif {[string length $t1] != 0 && $t1 > 0.001} {
		set t $t1
		set n 1
	} elseif {[string length $t2] != 0 && $t2 > 0.001} {
		set t $t2
		set n 1
	}
	if {[string length $t] != 0} {
		set f1 [DelVal {9 112} $f1]
		lappend f1 [list 9 $t]
		lappend f1 [list 112 $n]
	}
	# horizontal distance
	set t1 [GetVal 11 $f1]
	set t2 [GetVal 11 $f2]
	set t ""
	set dt1 0
	if {[string length $t1] != 0 && $t1 > 0.001 && \
			[string length $t2] != 0 && $t2 > 0.001} {
		set dt1 [expr {abs($t2 - $t1)}]
		if {$dt1 > 0.1} {	;# too large diff > 0.1 m
			GeoLog1 "$geoEasyMsg(faces) $geoEasyMsg(error): [GetVal {5 62} $f1] $geoCodes(11)"
			return ""
		}
		set t [expr {($t1 * $n1 + $t2 * $n2) / ($n1 + $n2)}]
		set n [expr {$n1 + $n2}]
	} elseif {[string length $t1] != 0 && $t1 > 0.001} {
		set t $t1
		set n 1
	} elseif {[string length $t2] != 0 && $t2 > 0.001} {
		set t $t2
		set n 1
	}
	if {[string length $t] != 0} {
		set f1 [DelVal {11 112} $f1]
		lappend f1 [list 11 $t] 
		lappend f1 [list 112 $n] 
	}
	# target height
	set j1 [GetVal 6 $f1]
	set j2 [GetVal 6 $f2]
	set j ""
	set dj 0
	if {[string length $j1] != 0 && $j1 > 0.001 && \
			[string length $j2] != 0 && $j2 > 0.001} {
		set dj [expr {abs($j2 - $j1)}]
		if {$dj > 0.01} {	;# too large diff > 0.01 m
			GeoLog1 "$geoEasyMsg(faces) $geoEasyMsg(error): [GetVal {5 62} $f1] $geoCodes(6)"
			return ""
		}
		set j [expr {($j1 * $n1 + $j2 * $n2) / ($n1 + $n2)}]
		set n [expr {$n1 + $n2}]
	} elseif {[string length $j1] != 0 && $t1 > 0.001} {
		set j $j1
		set n 1
	} elseif {[string length $j2] != 0 && $t2 > 0.001} {
		set j $j2
		set n 1
	}
	if {[string length $j] != 0} {
		set f1 [DelVal {6 112} $f1]
		lappend f1 [list 6 $j] 
		lappend f1 [list 112 $n] 
	}

	if {$loadHeader == 0} {
		set loadHeader 1
		GeoLog1 $geoEasyMsg(face2)
		GeoLog1 $geoEasyMsg(face3)
	}
	GeoLog1 [format "%-10s %11s %11s %6.4f %6.3f" \
		[string range [GetVal {5 62} $f1] 0 9] \
		[ANG $collimationError] [ANG $indexError] $dt $dj]
	return $f1
}

#
#	Save coordinates into Leica format 8 byte
#	Only filled coordinates are sent
#	Space is added to the end of the line for TC1010
#	@param fn geo data set name
#	@param rn output file name (.gsi)
#	@param wl word length 8 (old) or 16 (new)
#	@return 0 on success
proc SaveGsi {fn rn {wl 8}} {
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
	set line 0
	# go through coordinates
	foreach pn [lsort -dictionary [array names ${in}_coo]] {
		set x [GetVal {38} [set ${in}_coo($pn)]]
		set y [GetVal {37} [set ${in}_coo($pn)]]
		set z [GetVal {39} [set ${in}_coo($pn)]]
		# at least one coordinate is filled?
		if {[string length $x] || [string length $y] || [string length $z]} {
			incr line
			# write point number
			if {[string length $pn] > $wl} {
				set pn [string range $pn 0 [expr {$wl - 1}]]
			}
			if {$wl > 8} {
				puts -nonewline $f "*"
			}
			puts -nonewline $f [format "11%04d+%0${wl}s " $line $pn]
			# x or y filled?
			if {[string length $x] || [string length $y]} {
				if {[string length $x]} {
					set xs [expr {int(abs($x) * 1000)}]
					set xs \
					[string range $xs [expr {[string length $xs] - $wl}] end]
				} else { set xs 0 }
				puts -nonewline $f [format "81..10%s%0${wl}d " \
					[signCh $x] $xs]
				if {[string length $y]} {
					set ys [expr {int(abs($y) * 1000)}]
					set ys \
					[string range $ys [expr {[string length $ys] - $wl}] end]
				} else { set ys 0 }
				puts -nonewline $f [format "82..10%s%0${wl}d " \
					[signCh $y] $ys]
			}
			if {[string length $z]} {
				set zs [expr {int(abs($z) * 1000)}]
				set zs [string range $zs [expr {[string length $zs] - $wl}] end]
				puts -nonewline $f [format "83..10%s%0${wl}d " \
					[signCh $z] $zs]
			}
			puts $f ""
		}
	}
	close $f
	return 0
}

#
#	Read leica DNA GSI file
#	@param fn path to leica (wild) file
#	@param fa internal name of dataset
#	@param fo name of output file without extension
#	@return 0 on success
proc LeicaDNA {fn fa {fo ""}} {
	global geoLoaded
	global PI2 PI
	global reg
	global geoEasyMsg
	global FOOT2M

	set codeblock 0			;# no codeblock found
	if {[string length $fa] == 0} {return 1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	set lineno 0			;# line number in input
	set start_set 0
	set start_pn ""
	set end_pn ""
	set start_z ""
	set end_z ""
	set mode 0
	set li 0
	set f1 0
	set b1 0
	set f2 0
	set b2 0
	set dist 0
	set ${fa}_par [list [list 55 leica]]
	while {! [eof $f]} {
		incr lineno
		if {[gets $f buf] == 0} { continue }
		if {[string index $buf 0] == "!" || \
			[string index $buf 0] == "\x03" } { continue }
		# remove "*" in case of 16 digit input file
		if {[string index $buf 0] == "*"} {
			set buf [string range $buf 1 [expr {[string length $buf] - 1}]]
			set offset 22
		} else {
			set offset 14
		}
		set buflen [string length $buf]
		set pos 0
		set buflist ""
		set obuf ""					;# output buffer
		while {$pos < $buflen} {
			lappend buflist [string range $buf $pos [expr {$pos + 5}]]
			set w [string index $buf [expr {$pos + 6}]]
			lappend buflist $w
			lappend buflist [string range $buf [expr {$pos + 7}] \
				[expr {$pos + $offset}]]
			set pos [expr {$pos + $offset + 2}]
			if {$pos < $buflen && \
				[string index $buf [expr {$pos-1}]] != " " || \
				[string first $w "+-"] == -1 } {
				close $f
				return $lineno	;# error in input
			}
		}
		set n [llength $buflist]
		if {$n == 0} { continue }	;# empty line

		for {set i 0} {$i < $n} {incr i 3} {
			set i2 [expr {$i + 2}]
			set w [lindex $buflist $i]
			if {([string index $w 3] == "." && \
				[string index $w 2] != ".") || \
				[regexp "^33\[1256\]" $w]} {
					# long code nnn
					set code [string range $w 0 2]
			} else {
					# short code nn
					set code [string range $w 0 1]
			}
			set sign [lindex $buflist [expr {$i + 1}]]
			set v [lindex $buflist $i2]
			regsub {^0+} [string trim $v] "" val	;# leading zeros and spaces
			if {[string length $val] == 0} {set val 0}
			if {[string index $val 0] == "."} {set val "0$val"}
			# check numeric values
			if {[lsearch -exact {32 331 332 335 336} \
					$code] != -1 && [regexp $reg(2) $val] == 0} {
				# patch for smart station conversiona! skip coords with ----
				close $f
				return $lineno	;# error in input
			}
			# unit for val 0 meter (3 tizedes)  1 foot (3 tizedes)
			#              6 meter (4 tizedes) 7 feet (4 tizedes)
			#              8 meter (5 tizedes)
			set unit [string index $w end]
			# check units only for these
			if {[lsearch -exact {32 331 332 335 336 83} \
					$code] != -1} {
				switch -exact -- $unit {
					. -
					0 { set val [expr {$val / 1000.0}] }
					1 { set val [expr {$val / 1000.0 *  $FOOT2M}] }
					6 { set val [expr {$val / 10000.0}] }
					7 { set val [expr {$val / 10000.0 *  $FOOT2M}] }
					8 { set val [expr {$val / 100000.0}] }
					default { geo_dialog .msg $geoEasyMsg(error) \
							$geoEasyMsg(units) error 0 OK
							close $f
							return $lineno
					}
				}
			}
			switch -glob $code {
				"41" {	;# start new line == ?
					if {$start_set} {
						# store previous levelling line
						set ${fa}_geo($li) [list [list 2 $start_pn]]
						if {[info exists ${fa}_ref($start_pn)] == -1} {
							set ${fa}_ref($start_pn) $li
						} else {
							lappend ${fa}_ref($start_pn) $li
						}
						incr li
						switch $mode {
								1 -
								3 { set dm [expr {$b1 - $f1}] }
								2 -
								4 { set dm [expr {($b1 - $f1 + $b2 - $f2) / 2.0}]
									set dist [expr {$dist / 2.0}]
								}
						}
						set ${fa}_geo($li) [list [list 5 $end_pn] [list 11 $dist] [list 120 $dm]]
						if {[info exists ${fa}_ref($end_pn)] == -1} {
							set ${fa}_ref($end_pn) $li
						} else {
							lappend ${fa}_ref($end_pn) $li
						}
						incr li
						if {$start_z != "" && $start_z != 0} {
							AddCoo $fa $start_pn "" "" $start_z
						}
						if {$end_z != "" && $end_z != 0} {
							AddCoo $fa $end_pn "" "" $end_z
						}
						set f1 0
						set b1 0
						set f2 0
						set b2 0
						set dist 0
						set start_pn ""
						set start_z ""
						set end_pn ""
						set end_z ""
					}
					if {[regexp "^\\?\.*\[1-4\]$" $val]} {
						set start_pn ""
						set start_z ""
						set end_pn ""
						set end_z ""
						set dist 0
						set start_set 1
						set mode [string index $val end]
					}
				}
				"11" {	;# point number
					if {$start_pn == ""} {
						set start_pn $val
					} else {
						set end_pn $val
					}
				}
				"32" {	;# horizontal distance
					set dist [expr {$dist + $val}]
				}
				"331" {	;# backsight reading B1
					set b1 [expr {$b1 + $val}]
				}
				"332" {	;# foresight reading F1
					set f1 [expr {$f1 + $val}]
				}
				"335" {	;# backsight reading B2
					set b2 [expr {$b2 + $val}]
				}
				"336" {	;# foresight reading F2
					set f2 [expr {$f2 + $val}]
				}
				"83" {
					if {$end_pn == ""} {
						set start_z $val
						if {$sign == "-"} {set start_z [expr {-$start_z}]}
					} else {
						set end_z $val
						if {$sign == "-"} {set end_z [expr {-$end_z}]}
					}
				}
			}
		}
	}
	if {$start_set} {
		# store previous levelling line
		set ${fa}_geo($li) [list [list 2 $start_pn]]
		if {[info exists ${fa}_ref($start_pn)] == -1} {
			set ${fa}_ref($start_pn) $li
		} else {
			lappend ${fa}_ref($start_pn) $li
		}
		incr li
		switch -exact $mode {
				1 -
				3 { set dm [expr {$b1 - $f1}] }
				2 -
				4 { set dm [expr {($b1 - $f1 + $b2 - $f2) / 2.0}]
					set dist [expr {$dist / 2.0}]
				}
		}
		set ${fa}_geo($li) [list [list 5 $end_pn] [list 11 $dist] [list 120 $dm]]
		if {[info exists ${fa}_ref($end_pn)] == -1} {
			set ${fa}_ref($end_pn) $li
		} else {
			lappend ${fa}_ref($end_pn) $li
		}
		incr li
		if {$start_z != 0} {
			AddCoo $fa $start_pn "" "" $start_z
		}
		if {$end_z != 0} {
			AddCoo $fa $end_pn "" "" $end_z
		}
	}
	close $f
	return 0
}
