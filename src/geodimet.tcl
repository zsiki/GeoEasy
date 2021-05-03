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

#	Read in geodimeter data files into memory
#   @param fn name of geodimeter file
#	@return 0 on success
proc Geodimeter {fn} {
	global reg
	global geoLoaded
	global PI PI2 RO
	global geoEasyMsg geoCodes
	global maxColl maxIndex

	set fa [GeoSetName $fn]
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[string length $fa] == 0} {return -1}
	if {[catch {set f1 [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	set obuf ""				;# output buffer
	set lines 0				;# number of lines in output
	set src 0				;# input line number
	set points 0			;# number of points in coord list
	set pcode ""
	set hz {}
	set v {}

	while {! [eof $f1]} {
		incr src
		if {[gets $f1 buf] == 0} continue
		regsub "\[ 	\]*" $buf "" buf	;# remove spaces & tabs
		set buflist [split [string trim $buf] "="]
		set n [llength $buflist]
		if {$n == 0} continue		;# empty line
		if {$n != 2} {
			close $f1
			return $src
		}
		set code [lindex $buflist 0]
		set val [lindex $buflist 1]
		# check numeric values
		if {[lsearch -exact {3 6 7 8 9 10 11 21 24 25 26 27 28 29 37 38 39 49} \
				$code] != -1 && [regexp $reg(2) $val] == 0} {
			return $src  ;# error in input
		}
		# remove the same code if it was given before
		if {$code != 2 && $code != 62 && $code != 5} {;# not a start of a new p
			set obuf [DelVal $code $obuf]
		}
		switch -exact $code {
			0 -
			51 -
			52 -
			53 -
			55 { lappend ${fa}_par [list $code $val]}
			1 {}
			2 -
			5 -
			62 {
				# start a new station or target
				if {[llength $obuf] > 0} {
					if {[llength $hz]} {
						# average direction
						set w [avg $hz]
						if {[llength $hz] > 1} {
							foreach h $hz {
								set coll [expr {$w - $h}]
								GeoLog1 [format "%-10s %10s kollimacio" \
									[string range $pno 0 9] [ANG $coll]]
								if {[expr {abs($coll)}] > [expr {$maxColl / $RO}]} {
									GeoLog1 "$geoEasyMsg(faces) $geoEasyMsg(error): $pno $geoCodes(7)"
								}
							}
						}
						lappend obuf "7 $w"
					}
					if {[llength $v]} {
						# average zenith
						set w [avg $v]
						if {[llength $v] > 1} {
							foreach h $v {
								set ind [expr {$w - $h}]
								GeoLog1 [format "%-10s %10s index" \
									[string range $pno 0 9] [ANG $ind]]
								if {[expr {abs($ind)}] > [expr {$maxIndex / $RO}]} {
									# too large error > 6'
									GeoLog1 "$geoEasyMsg(faces) $geoEasyMsg(error): $pno $geoCodes(8)"
								}
							}
						}
						lappend obuf "8 $w"
					}
					if {[llength $obuf] > 1 || [GetVal 2 $obuf] != ""} {
						set ${fa}_geo($lines) $obuf
						if {[info exists ${fa}_ref($pno)] == -1} {
							set ${fa}_ref($pno) $lines
						} else {
							lappend ${fa}_ref($pno) $lines
						}
						incr lines
					}
					set pcode ""
				}
				set obuf [list $buflist]
				set pno [lindex $buflist 1]
				set hz {}
				set v {}
				if {$code == 2} {
					GeoLog1 "$geoCodes(2) $pno"
				}
			}
			7 -
			21 -
			24 {
				# direction in face left
				set w [Deg2Rad [lindex $buflist 1]]
				if {$w == -1} { return $src }
				lappend hz $w
			}
			17 {
				# direction in face right
				set w [Deg2Rad [lindex $buflist 1]]
				if {$w == -1} { return $src }
				if {$w > $PI} {
					set w [expr {$w - $PI}]
				} else {
					set w [expr {$w + $PI}]
				}
				lappend hz [expr {$w}]
			}
			8 -
			25 {
				# zenith angle in face left
				set w [Deg2Rad [lindex $buflist 1]]
				if {$w == -1} { return $src }
				lappend v $w
			}
			18 {
				# zenith angle inface right
				set w [Deg2Rad [lindex $buflist 1]]
				if {$w == -1} { return $src }
				set w [expr {$PI2 - $w}]
				lappend v $w
			}
			3 {
				if {[GetVal 2 $obuf] == ""} {	;# not a station record
					set st_index [expr {$lines - 1}]
					while {$st_index >= 0 && \
							[GetVal 2 [set ${fa}_geo($st_index)]] == ""} {
						incr st_index -1
					}
					if {$st_index >= 0} {
						lappend ${fa}_geo($st_index) $buflist
					}
				} else {
					lappend obuf $buflist
				}
			}
			4 {
				lappend obuf $buflist
				set pcode [lindex $buflist 1]
			}
			6 -
			10 {
				lappend obuf $buflist
			}
			9 -
			11 {
				if {$val > 0.001} {
					lappend obuf $buflist
				}
			}
			23 {
				if {[string index $val 2] != 1 || \
					[string index $val 3] != 2} {
					tk_dialog .msg $geoEasyMsg(error) \
						$geoEasyMsg(units) error 0 OK
					return $src  ;# error in input
				}
			}
			37 -
			38 -
			39 {
				# coordinates
				if {[info exists ${fa}_coo($pno)] == 0} {
					set ${fa}_coo($pno) [list [list 5 $pno]]
					incr points
					if {$pcode != ""} {
						lappend ${fa}_coo($pno) [list 4 $pcode]
					}
				}
				#	store only the first occurance of coord
				if {[lsearch -glob [set ${fa}_coo($pno)] "$code *"] == -1} {
					lappend ${fa}_coo($pno) $buflist
				} else {
					tk_dialog .msg $geoEasyMsg(warning) \
						"$geoEasyMsg(dblPn): $pno ($fn:$src)" warning 0 OK
				}
			}
			default {
				# nop
			}
		}
	}
	# process last buffer
	if {[llength $obuf] > 0} {
		if {[llength $hz]} {
			# average direction
			set w [avg $hz]
			if {[llength $hz] > 1} {
				foreach h $hz {
					set coll [expr {$w - $h}]
					GeoLog1 [format "%-10s %10s kollimacio" \
						[string range $pno 0 9] [ANG $coll]]
					if {[expr {abs($coll)}] > [expr {$maxColl / $RO}]} {
						GeoLog1 "$geoEasyMsg(faces) $geoEasyMsg(error): $pno $geoCodes(7)"
					}
				}
			}
			lappend obuf "7 $w"
		}
		if {[llength $v]} {
			# average zenith
			set w [avg $v]
			if {[llength $v] > 1} {
				foreach h $v {
					set ind [expr {$w - $h}]
					GeoLog1 [format "%-10s %10s index" \
						[string range $pno 0 9] [ANG $ind]]
					if {[expr {abs($ind)}] > [expr {$maxIndex / $RO}]} {
						# too large error > 6'
						GeoLog1 "$geoEasyMsg(faces) $geoEasyMsg(error): $pno $geoCodes(8)"
					}
				}
			}
			lappend obuf "8 $w"
		}
		if {[llength $obuf] > 1 || [GetVal 2 $obuf] != ""} {
			set ${fa}_geo($lines) $obuf
			if {[info exists ${fa}_ref($pno)] == -1} {
				set ${fa}_ref($pno) $lines
			} else {
				lappend ${fa}_ref($pno) $lines
			}
		}
	}
	close $f1
	return 0
}

#
#	Save coordinates into Geodimeter are file
#	@param fn geo data set name
#	@param rn output file name (.are)
proc SaveAre {fn rn} {
	global geoEasyMsg
	global geoLoaded
	global ${fn}_coo
	global decimals
	
	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	set f [open $rn w]
	set skipped ""
	# go through coordinates
	foreach pn [lsort -dictionary [array names ${fn}_coo]] {
		set x [GetVal {38} [set ${fn}_coo($pn)]]
		set y [GetVal {37} [set ${fn}_coo($pn)]]
		set z [GetVal {39} [set ${fn}_coo($pn)]]
		if {[string length $x] || [string length $y] || [string length $z]} {
			puts $f [format "5=%s" $pn]
			if {[string length $x]} { puts $f "38=[format "%.${decimals}f" $x]"}
			if {[string length $y]} { puts $f "37=[format "%.${decimals}f" $y]"}
			if {[string length $z]} { puts $f "39=[format "%.${decimals}f" $z]"}
		}
	}
	close $f
	return 0
}

#
#       Read in geodat124 data files into memory
#		dat file format:
#	"1,2=6001 3=1.580 "
#	"2,4=JEL 5=6002 6=1.590 7=289.2244 8=90.2016 9=21.471 "
#	"3,4=KER 5=6001 6=1.500 7=149.4940 8=89.5136 9=6.146 "
#	@param fn name of geodimeter file
#	@return 0 on success
proc Geodat124 {fn} {

	# set the name of temperary job file
	set oname [file rootname $fn].job
	# open input file
	if {[catch {set f1 [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	# open output file (job)
	if {[catch {set fo [open $oname w]}] != 0} {
			return -1		;# cannot open output file
	}
	while {! [eof $f1]} {
		if {[gets $f1 buf] == 0} continue
		# remove leading/trailing " & space and leading row number
		set buf [string trim $buf " \""]
		set buflist [split $buf ","]
		if {[llength $buflist] > 1} { set buf [lindex $buflist 1] }
		# spit on spaces
		set buflist [split $buf " "]
		# write out in geodimeter format
		foreach item $buflist {
			# format code=value ?
			if {[string first "=" $item] == -1} { continue }
			# skip special 4=---- item
			if {[string first "----" $item] > -1} { continue }
			puts $fo $item
		}
	}
	close $f1
	close $fo
	# load the temperary job file
	set res [Geodimeter $oname]
	catch {file delete $oname}
	return $res
}

#
#
#       Convert GeoEasy data set to geodimeter job/are format
#	(bridge to GHMF2)
#	Only 2, 3, 5, 21, 6, 7, 8, 9, 11, 37, 38, 39 codes are exported
#	Meters and dms (ddd.mmss)
#	@param fn geo data set name
#	@param rn output file name (.job)
#	@return 0 on success
proc SaveJob {fn rn} {
	global PI PI2 RO R PISEC PI2SEC FOOT2M
	global reg
	global decimals
	global geoEasyMsg
	global geoLoaded
	global ${fn}_coo ${fn}_geo

	set fn1 [file rootname $rn]
	append fn1 ".job"
	set f1 [open $fn1 "w"]
	set fn2 [file rootname $rn]
	append fn2 ".are"
	set f2 [open $fn2 "w"]
	set i 0
	while {[info exists ${fn}_geo($i)]} {
		set buf [set ${fn}_geo($i)]
		set ap [GetVal 2 $buf]
		if {[string length $ap] > 0} {
			# station rec
			puts $f1 "2=$ap"
			foreach code {3 6 4} {
				set val [GetVal $code $buf]
				if {[string length $val] > 0} {
					if {[lsearch {3 6} $code] != -1} {
						set val [format "%.${decimals}f" $val]
					}
					puts $f1 "$code=$val"
				}
			}
		} else {
			# observation rec
			foreach code {5 62 4 6 9 10 11} {
				set val [GetVal $code $buf]
				if {[string length $val] > 0} {
					if {[lsearch {6 9 10 11} $code] != -1} {
						set val [format "%.${decimals}f" $val]
					}
					puts $f1 "$code=$val"
				}
			}
			foreach code {7 21 8} {
				if {[GetVal $code $buf] != ""} {
					set d [string trim [ANG [GetVal $code $buf]]]
					set a ""; set deg ""; set min ""; set sec ""
					# change from ddd-mm-ss to ddd.mmss
					regexp "^(\[0-9\]+)-(\[0-9\]\[0-9\])-(\[0-9\]\[0-9\])$" \
						$d a deg min sec
					puts $f1 "$code=$deg.$min$sec"
				}
			}
		}
		incr i
	}
	foreach pn [lsort -dictionary [array names ${fn}_coo]] {
		set buf [set ${fn}_coo($pn)]
		foreach code {5 37 38 39} {
			if {[GetVal $code $buf] != ""} {
				puts $f2 "$code=[GetVal $code $buf]"
			}
		}
	}

	close $f1
	close $f2
	return 0
}
