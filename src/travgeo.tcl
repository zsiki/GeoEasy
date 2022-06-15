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

#	Collect point names interactively &
#	Calculate traversing or trigonometric line
#		coordinates are stored in all referenced geo data set
#	@param mode 0/1 traversing/trigonometric line
proc GeoTraverse {{mode 0}} {
	global geoEasyMsg
	global autoRefresh

	if {$mode == 0} {
		set slist [GetTraverse]
	} else {
		set slist [GetTraverse {39}]
	}
	if {[llength $slist] == 0} { return }
	if {[llength $slist] > 2} {
		if {$mode == 0} {
			CalcTraverse $slist
			set mode [geo_dialog .msg $geoEasyMsg(info) \
				$geoEasyMsg(trigLineToo) info \
				0 $geoEasyMsg(no) $geoEasyMsg(yes)]
		}
		if {$mode == 1} {
			CalcTrigLine $slist
		}
		if {$autoRefresh} {
			RefreshAll
		}
	} else {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noTra) \
			warning 0 OK
	}
}

#
#
#	Collect 3 or more traverse interactively &
#	Calculate traversing or trigonometric node
#		coordinates are stored in all referenced geo data set
#	@param mode 0/1 traversing/trigonometric line
proc GeoTraverseNode {{mode 0}} {
	global geoEasyMsg
	global decimals
	global autoRefresh

	# traverse node point number
	set node [GeoEntry $geoEasyMsg(numTra) $geoEasyMsg(nodeTra)]
	if {[string length $node] == 0} {return}
	set n 0
	# first calculate coordinates from free traverses
	while {[geo_dialog .msg $geoEasyMsg(info) \
				"[expr {$n + 1}] $geoEasyMsg(travLine)" info 0 OK \
				$geoEasyMsg(ende)] == 0} {
		if {$mode == 0} {
			set slist [GetTraverse {37 38} $node]
		} else {
			set slist [GetTraverse {39} $node]
		}
		if {[llength $slist] > 1} {
			set slists($n) $slist		;# save traverse
			if {$mode == 0} {
				set w [CalcTraverse $slist 1]	;# force free traverse
				if {[llength $w] < 3} { return }
				set t($n) [lindex $w 0]
				set c($n) [lrange $w 1 end]
			} else {
				set w [CalcTrigLine $slist 1]
				if {[llength $w] < 2} { return }
				set t($n) [lindex $w 0]
				set c($n) [lindex $w 1]
			}
			incr n
		} else {
			break
		}
	}
	if {$n == 0} {return}
	# calculate average for node
	set sx 0
	set sy 0
	set sz 0
	set st 0
	if {$mode == 0} {
		GeoLog $geoEasyMsg(menuCalTraNode)
		GeoLog1 $geoEasyMsg(headTraNode) 
	} else {
		GeoLog $geoEasyMsg(menuCalTrigNode)
		GeoLog1 $geoEasyMsg(headTrigNode) 
	}
	# weighted average (weight = 1 / (t * t)
	for {set i 0} {$i < $n} {incr i} {
		set st [expr {$st + 1.0 / $t($i) / $t($i)}]
		if {$mode == 0} {
			set sx [expr {$sx + [lindex $c($i) 0] / $t($i) / $t($i)}]
			set sy [expr {$sy + [lindex $c($i) 1] / $t($i) / $t($i)}]
			GeoLog1 [format \
				"%-10s %8.${decimals}f %12.${decimals}f %12.${decimals}f" \
				[lindex [lindex $slists($i) 0] 2] $t($i) \
				[lindex $c($i) 0] [lindex $c($i) 1]]
		} else {
			set sz [expr {$sz + $c($i) / $t($i) / $t($i)}]
			GeoLog1 [format \
				"%-10s %8.${decimals}f %12.${decimals}f" \
				[lindex [lindex $slists($i) 0] 2] $t($i) $c($i)]
		}
	}
	set w [focus]
	if {$w == ""} {
		set w .
	} else {
		set w [toplevel $w]
	}
	if {$mode == 0} {
		set sx [expr {$sx / $st}]
		set sy [expr {$sy / $st}]
		StoreCoord $node $sx $sy
		GeoLog1 [format "%-10s %8s %12.${decimals}f %12.${decimals}f" $node "" $sx $sy]
	} else {
		set sz [expr {$sz / $st}]
		StoreZ $node $sz
		GeoLog1 [format "%-10s %8s %12.${decimals}f" $node "" $sz]
	}
	# recalculate traverses
	for {set i 0} {$i < $n} {incr i} {
		if {$mode == 0} {
			CalcTraverse $slists($i)
		} else {
			CalcTrigLine $slists($i)
		}
	}
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	Collect data for traverse
#	@param codes coordinate codes to consider (e.g. 37 38 for traverse
#				39 for trigonometric line)
#	@param stopAt stop at the given point number, used for
#                traversing node
#	@return info list of traverse.
#	The returned list is a list of lists where each sublist
#	belongs to a point and contains {geo_set line point_name}
#	geo_set and line refers to the station record in data set
proc GetTraverse {{codes {37 38}} {stopAt ""}} {
	global geoEasyMsg

	set stations [lsort -dictionary [GetStations]]
	set startend [lsort -dictionary [GetGiven $codes]]
	set ret ""
	if {[llength $stations] < 1 || [llength $startend] < 1} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noTra) warning 0 OK
		return ""
	}
	set last 0
	while {$last == 0} {
		if {[llength $ret] == 0} {
			set pn [GeoListbox $startend 0 $geoEasyMsg(startTra) 1]
		} else {
			# find observed points from previous
			set lst [GetShootedPoints [lindex $ret end]]
			if {[llength $lst] > 0} {
				# remove points already used in traverse
				if {[llength $ret] > 1} {
					set l [lindex [lindex $ret \
						[expr {[llength $ret] - 2}]] end]
					set ind [lsearch -exact $lst $l]
					if {$ind != -1} {
						set lst [lreplace $lst $ind $ind]
					}
				}
				# add stations after the first to be able to start a
				# inserted traverse from occupied station
				if {[llength $ret] == 1} {
					foreach s $stations {
						if {[lsearch -exact $lst $s] == -1} {
							lappend lst $s
						}
					}
#					set lst [concat $lst $stations]
				}
				set lst [lsort -dictionary $lst]
				# select from observed
				if {$stopAt == ""} {
					set pn [GeoListbox $lst 0 $geoEasyMsg(nextTra) 1 1]
				} else {
					set pn [GeoListbox $lst 0 $geoEasyMsg(nextTra) 1]
				}
			} else {
				if {$stopAt == ""} {
					set pn [GeoListbox $stations 0 $geoEasyMsg(nextTra) 1 1]
				} else {
					set pn [GeoListbox $stations 0 $geoEasyMsg(nextTra) 1]
				}
			}
			if {[llength $pn] > 1} {
				set last 1
				set pn [lindex $pn 0]
			}
		}
		if {$pn == ""} {
			Beep
			return ""
		}
		set stlist [GetStation $pn]		;# check multiply occupied stations
		switch -exact [llength $stlist] {
			0 {
				set ref [list "" 0]
			}
			1 {
				set ref [lindex $stlist 0]
			}
			default {
                set vlist [InternalToShort $stlist]
				set vlist [lindex [GeoListbox $vlist {0 1} \
					$geoEasyMsg(lbTitle3) 1] 0]
				if {$vlist == ""} {
					Beep
					return ""
				}
                set ref [ShortToInternal $vlist]
			}
		}
		lappend ref $pn
		lappend ret $ref
		if {$pn == $stopAt} { set last 1 }
	}
	return $ret
}

#
#	Calculate traversing. slist is a list of lists where each sublist
#	belongs to a point and contains {geo_set line point_name}
#	geo_set and line refers to the station record in data set
#		coordinates are stored in all referenced geo data set
#	@param slist information for points in traverse, order is significant!
#	@param node 0/1 force free traverse calculation (for node)
#	@return length of the traverse.
proc CalcTraverse {stlist {node 0}} {
	global geoEasyMsg
	global decimals
	global PI PI2 PISEC PI2SEC RO

	set n [llength $stlist]
	if {$n < 3} {return 0}					;# at least 3 points must be
	set n1 [expr {$n - 1}]
	foreach st $stlist {
		if {[llength $st] == 3} {
			set geo [lindex $st 0]
			global ${geo}_geo
		}
	}
	# start and end point coordinates
	set startp [GetCoord [lindex [lindex $stlist 0] 2] {37 38}]
	set x(0) [GetVal 38 $startp]
	set y(0) [GetVal 37 $startp]
	set endp [GetCoord [lindex [lindex $stlist end] 2] {37 38}]
	set x($n1) [GetVal 38 $endp]
	set y($n1) [GetVal 37 $endp]
	if {$x(0) == "" || $y(0) == ""} {
		# no coord for startpoint
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noTraCoo) \
			warning 0 OK
		return 0
	}
	set free 0
	if {$node} {
		set free 1		;# force to calculate free traverse (for node)
		set x(n1) ""
		set y(n1) ""
	} elseif {$x($n1) == "" || $y($n1) == ""} {
		# no coordinate for endpoint
		if {[geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(freeTra) \
				warning 0 OK $geoEasyMsg(cancel)] != 0} {
			return 0
		}
		set free 1	;# free traverse
	}
#
#	collect measurements in traverse
#
	set prevpn ""
	for {set i 0} {$i < $n} {incr i} {
		set i1 [expr {$i + 1}]
		set i_1 [expr {$i - 1}]
		set st [lindex $stlist $i]
		set actpn [lindex $st 2]
		set geo [lindex $st 0]
		set ref [lindex $st 1]

		if {$i1 < $n} {
			set nextpn [lindex [lindex $stlist $i1] 2]
		}

		upvar #0 ${geo}_geo($ref) buf
		if {$i == 0} {
			if {[info exists buf]} {	;# first point is station
				set beta(0) [GetVal 101 $buf]
			} else {
				set beta(0) ""
			}
			if {$beta(0) == ""} {			;# no orientation on start
				if {[geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(firstTra) \
						warning 0 OK $geoEasyMsg(cancel)] != 0} {
					return 0
				}
			}
			set prev 1							;# no prev point for the startp
		} else {
			set prev 0
		}
		if {$i1 == $n} {
			if {[info exists buf]} {	;# last point is station
				set beta($i) [GetVal 101 $buf]
			} else {
				set beta($i) ""
			}
			if {! $free && \
			    $beta(0) != "" && $beta($i) == ""} {	;# no orientation on end
				if {[geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(lastTra) \
						warning 0 OK $geoEasyMsg(cancel)] != 0} {
					return 0
				}
			}
			set next 1							;# no next point for the endp
		} else {
			set next 0
		}
		incr ref
		set prevvals ""
		set nextvals ""
		while {1} {
			upvar #0 ${geo}_geo($ref) buf
			if {[info exists buf] == 0 && ($i == 0 || $i1 == $n)} {
				break	;# start and endpoint need not be a station
			}
			if {[info exists buf] == 0 || [GetVal 2 $buf] != ""} {
				if {$i == 0 || $i1 == $n} { break }	;# start and endpoint need not be a station
				geo_dialog .msg $geoEasyMsg(warning) \
					"$geoEasyMsg(angTra) [lindex [lindex $stlist $i] 2]" \
					warning 0 OK
				return 0					 ;# next station or end of data set
			}
			set pn [GetVal {5 62} $buf]
			if {$prev == 0 && $pn == $prevpn} {
				# get horiz dist and horiz angle
				set prevvals [TraVals $buf]
				incr prev
			}
			if {$next == 0 && $pn == $nextpn} {
				# get horiz dist and horiz angle
				set nextvals [TraVals $buf]
				incr next
			}
			if {$prev && $next} {
				break		;# both neighbouring points found
			}
			incr ref
		}
		if {$i == 0} {
			if {$beta(0) != "" && [llength $nextvals] && [lindex $nextvals 0] != ""} {	;# there was orientation on first
				set beta(0) [expr {$beta(0) + [lindex $nextvals 0]}]
			} else {
				set beta(0) ""
			}
		} elseif {$i1 == $n} {
			if {$beta($i) != "" && $beta(0) != "" && [llength $prevvals]} {
				# there was orientation on last and first
				set beta($i) [expr {$PI2 - ($beta($i) + [lindex $prevvals 0])}]
			} else {
				set beta($i) ""
			}
		} else {
			set beta($i) [expr {[lindex $nextvals 0] - [lindex $prevvals 0]}]
		}
		if {$beta($i) != ""} {
			while {$beta($i) > $PI2} {
				set beta($i) [expr {$beta($i) - $PI2}]
			}
			while {$beta($i) < 0} {
				set beta($i) [expr {$beta($i) + $PI2}]
			}
		}
		set prevdi [lindex $prevvals 1]
		set nextdi [lindex $nextvals 1]
		if {$prevdi != ""} {	;# distance from previous to act
			if {[info exists t($i)]} {
				# save distance for output
				set t1($i) $prevdi
				set t2($i) $t($i)
				set t($i) [expr {($t($i) + $prevdi) / 2.0}]
			} else {
				set t($i) $prevdi
			}
		} elseif {$i > 0 && [info exists t($i)] == 0} {
			geo_dialog .msg $geoEasyMsg(warning) \
				"$geoEasyMsg(distTra) $prevpn" warning 0 OK
			return 0
		}
		if {$nextdi != ""} {
			set t($i1) $nextdi
		}
		set prevpn $actpn
	}
# calculate angles in senconds from now !!!!
	for {set i 0} {$i < $n} {incr i} {
		if {$beta($i) != ""} {
			set beta($i) [expr {round([Rad2Sec $beta($i)])}]
		}
	}
	if {$node} { set beta($n1) "" }
#	calculate sum of betas if we have both orientation
	if {$beta(0) != "" && $beta($n1) != ""} {
		set sumbeta 0
		for {set i 0} {$i < $n} {incr i} {
			set sumbeta [expr {$sumbeta + $beta($i)}]
		}
		# calculate angle error
		set dbeta [expr {$n1 * $PISEC - $sumbeta}]
		while {$dbeta > $PISEC} {
			set dbeta [expr {$dbeta - $PI2SEC}]
		}
		while {$dbeta < [expr {-$PISEC}]} {
			set dbeta [expr {$dbeta + $PI2SEC}]
		}
	} else {
		set sumbeta 0
		set dbeta 0
	}
# angle corrections
	set w 0
	for {set i 0} {$i < $n} {incr i} {
		set vbeta($i) [expr {round($dbeta / $n)}]
		incr w $vbeta($i)
	}
	# kenyszer kerekites!
	set i 0
	set dbeta [expr {round($dbeta)}]
	while {$w < $dbeta} {
		incr vbeta($i)
		incr i
		incr w
		if {$i >= $n} {set i 0}
	}
	while {$w > $dbeta} {
		incr vbeta($i) -1
		incr i
		incr w -1
		if {$i >= $n} {set i 0}
	}
#	calculate bearings and dx & dy for sides
	set delta(0) 0
	set sumdx 0
	set sumdy 0
	set sumt 0
	for {set i 1} {$i < $n} {incr i} {
		set j [expr {$i - 1}]
		if {$j == 0} {
			if {$beta($j) != ""} {
				set d [expr {$delta($j) + $beta($j) + $vbeta($j)}]
			} else {
			# find orientation for first side "beillesztett"
				set d 0
				set sumdx 0
				set sumdy 0
				for {set k 1} {$k < $n} {incr k} {
					set dx($k) [expr {$t($k) * sin($d / $RO)}]
					set dy($k) [expr {$t($k) * cos($d / $RO)}]
					set sumdx [expr {$sumdx + $dx($k)}]
					set sumdy [expr {$sumdy + $dy($k)}]
					if {$k < $n1} {
						set d [expr {$d + $beta($k) - $PISEC}]
					}
				}
				set d [Rad2Sec [expr {[Bearing $x($n1) $y($n1) $x(0) $y(0)] - \
					[Bearing $sumdx $sumdy 0 0]}]]
				set sumdx 0
				set sumdy 0
			}
		} else {
			set d [expr {$delta($j) + $beta($j) + $vbeta($j) - $PISEC}]
		}
		while {$d < 0} {
			set d [expr {$d + $PI2SEC}]
		}
		while {$d > $PI2SEC} {
			set d [expr {$d - $PI2SEC}]
		}
		set delta($i) $d
		set dx($i) [expr {$t($i) * sin($d / $RO)}]
		set dy($i) [expr {$t($i) * cos($d / $RO)}]
		set sumdx [expr {$sumdx + $dx($i)}]
		set sumdy [expr {$sumdy + $dy($i)}]
		set sumt [expr {$sumt + $t($i)}]
	}
#	calculate dx & dy error
	if {$free} {
		set ddx 0	;# free traverse
		set ddy 0
		set ddist 0
	} else {
		set ddx [expr {$x($n1) - $x(0) - $sumdx}]
		set ddy [expr {$y($n1) - $y(0) - $sumdy}]
		set ddist [expr {hypot($ddx, $ddy)}]	;# linear error
	}

#	calculate final coords
	set wx [expr {$ddx / $sumt}]
	set wy [expr {$ddy / $sumt}]
	for {set i 1} {$i < $n} {incr i} {
		set i1 [expr {$i - 1}]
		set vx($i) [expr {$t($i) * $wx}]
		set vy($i) [expr {$t($i) * $wy}]
		set x($i) [expr {$x($i1) + $dx($i) + $vx($i)}]
		set y($i) [expr {$y($i1) + $dy($i) + $vy($i)}]
	}
#	output results
#	headers
	GeoLog1
	if {$beta(0) == ""} {
		set travtype $geoEasyMsg(tra1)
	} else {
		if {$beta($n1) == ""} {
			if {$free} {
				set travtype $geoEasyMsg(tra4)
			} else {
				set travtype $geoEasyMsg(tra2)
			}
		} else {
			set travtype $geoEasyMsg(tra3)
		}
	}
	GeoLog "$geoEasyMsg(menuCalTra) $travtype"
	GeoLog1 $geoEasyMsg(head1Tra)
	GeoLog1 $geoEasyMsg(head2Tra)
	GeoLog1 $geoEasyMsg(head3Tra)
	for {set i 0} {$i < $n} {incr i} {
		set pcode [string range [GetPCode [lindex [lindex $stlist $i] 2] 1] 0 9]
		if {[info exists t1($i)]} { set t_1 [format "%8.${decimals}f" $t1($i)] } else { set t_1 "-" } 
		if {[info exists t2($i)]} { set t_2 [format "%8.${decimals}f" $t2($i)] } else { set t_2 "-" } 
		GeoLog1  [format "           %11s %8s" [ANG [expr {$delta($i) / $RO}]] $t_1]
		if {$i > 0} {
			if {$beta($i) == ""} {
				GeoLog1 [format "%-10s %10s %8.${decimals}f %8.${decimals}f %8.${decimals}f %10.${decimals}f %10.${decimals}f" \
					[lindex [lindex $stlist $i] 2] "" $t($i) \
					$dx($i) $dy($i) [expr {$dx($i) + $vx($i)}] \
					[expr {$dy($i) + $vy($i)}]]
			} else {
				GeoLog1 [format "%-10s %11s %8.${decimals}f %8.${decimals}f %8.${decimals}f %10.${decimals}f %10.${decimals}f" \
					[lindex [lindex $stlist $i] 2] [ANG [expr {$beta($i) / $RO}]] $t($i) \
					$dx($i) $dy($i) [expr {$dx($i) + $vx($i)}] \
					[expr {$dy($i) + $vy($i)}]]
			}
		} else {
			if {$beta($i) == ""} {
				GeoLog1 [format "%-10s %11s" \
					[lindex [lindex $stlist $i] 2] ""]
			} else {
				GeoLog1 [format "%-10s %11s" \
					[lindex [lindex $stlist $i] 2] [ANG [expr {$beta($i) / $RO}]]]
			}
		}
		if {$i > 0} {
			if {$free} {
				set w1 "-"
				set w2 "-"
			} else {
				set w1 [format "%8.${decimals}f" $vx($i)]
				set w2 [format "%8.${decimals}f" $vy($i)]
			}
			if {$beta(0) == "" || $beta($n1) == ""} {
				GeoLog1 [format \
					"%-10s %11s %8s %8s %8s %10.${decimals}f %10.${decimals}f" \
					$pcode "" $t_2 $w1 $w2 $x($i) $y($i)]
			} else {
				GeoLog1 [format \
					"%-10s %11s %8s %8.${decimals}f %8.${decimals}f %10.${decimals}f %10.${decimals}f" \
					$pcode [ANG [expr {$vbeta($i) / $RO}]] $t_2 $vx($i) $vy($i) $x($i) $y($i)]
			}
		} else {
			if {$beta(0) == "" || $beta($n1) == ""} {
				GeoLog1 [format \
					"%-10s %10s                            %10.${decimals}f %10.${decimals}f" \
					$pcode "" $x($i) $y($i)]
			} else {
				GeoLog1 [format \
					"%-10s %11s                            %10.${decimals}f %10.${decimals}f" \
					$pcode [ANG [expr {$vbeta($i) / $RO}]] $x($i) $y($i)]
			}
		}
	}
	GeoLog1
	if {$beta(0) == "" || $beta($n1) == ""} {
		GeoLog1 [format \
			"           %10s                            %10.${decimals}f %10.${decimals}f" \
			"" [expr {$x($n1) - $x(0)}] [expr {$y($n1) - $y(0)}]]
		GeoLog1 [format "           %10s %8.${decimals}f %8.${decimals}f %8.${decimals}f" \
			"" $sumt $sumdx $sumdy]
		GeoLog1
		if {! $free} {
			GeoLog1 [format "           %10s          %8.${decimals}f %8.${decimals}f" "" $ddx $ddy]
		}
	} else {
		GeoLog1 [format "          %11s                            %10.${decimals}f %10.${decimals}f" \
			[ANG 0] [expr {$x($n1) - $x(0)}] [expr {$y($n1) - $y(0)}]]
		GeoLog1 [format "          %11s %8.${decimals}f %8.${decimals}f %8.${decimals}f" \
			[ANG [expr {$sumbeta / $RO}]] $sumt $sumdx $sumdy]
		GeoLog1 [format "          %11s" \
			[ANG [expr {$n1 * $PI}]]]
		GeoLog1 [format "          %11s          %8.${decimals}f %8.${decimals}f" \
			[ANG [expr {$dbeta / $RO}]] $ddx $ddy]
	}
	if {! $free} {
		GeoLog1 [format "                                   %8.${decimals}f" $ddist]
	}
	# error limits
	GeoLog1
	if {! $free} {
		GeoLog1 $geoEasyMsg(error1Tra)
	}
	if {$free} {
		# free traverse do not write error limits
	} elseif {$beta(0) == ""} {
	# beillesztett
		GeoLog1 "$geoEasyMsg(error2Tra)        -\
			[format "%8d" [expr {int(0.8 * (6 + 1.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error3Tra)        -\
			[format "%8d" [expr {int(1.25 * 0.8 * (6 + 1.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error4Tra)        -\
			[format "%8d" [expr {int(0.8 * (10 + 2.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error5Tra)        -\
			[format "%8d" [expr {int(1.25 * 0.8 * (10 + 2.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error6Tra)        -\
			[format "%8d" [expr {int(0.8 * (14 + 3.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error7Tra)        -\
			[format "%8d" [expr {int(1.25 * 0.8 *  (14 + 3.5 * $sumt / 100.0))}]]"
	} elseif {$beta($n1) == ""} {
	# egyik vegen tajekozott
		GeoLog1 "$geoEasyMsg(error2Tra)        -\
			[format "%8d" [expr {int(1.2 * (6 + 1.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error3Tra)        -\
			[format "%8d" [expr {int(1.25 * 1.2 * (6 + 1.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error4Tra)        -\
			[format "%8d" [expr {int(1.2 * (10 + 2.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error5Tra)        -\
			[format "%8d" [expr {int(1.25 * 1.2 * (10 + 2.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error6Tra)        -\
			[format "%8d" [expr {int(1.2 * (14 + 3.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error7Tra)        -\
			[format "%8d" [expr {int(1.25 * 1.2 *  (14 + 3.5 * $sumt / 100.0))}]]"
	} else {
	# closed line traverse
		GeoLog1 "$geoEasyMsg(error2Tra) \
			[format "%8d" [expr {int(40 + 2 * $n)}]] \
			[format "%8d" [expr {int(6 + 1.5 * $sumt / 100.0)}]]"
		GeoLog1 "$geoEasyMsg(error3Tra) \
			[format "%8d" [expr {55 + 2 * $n}]] \
			[format "%8d" [expr {int(1.25 * (6 + 1.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error4Tra) \
			[format "%8d" [expr {int(55 + 2.5 * $n)}]] \
			[format "%8d" [expr {int(10 + 2.5 * $sumt / 100.0)}]]"
		GeoLog1 "$geoEasyMsg(error5Tra) \
			[format "%8d" [expr {int(75 + 2 * $n)}]] \
			[format "%8d" [expr {int(1.25 * (10 + 2.5 * $sumt / 100.0))}]]"
		GeoLog1 "$geoEasyMsg(error6Tra) \
			[format "%8d" [expr {int(70 + 3.5 * $n)}]] \
			[format "%8d" [expr {int(14 + 3.5 * $sumt / 100.0)}]]"
		GeoLog1 "$geoEasyMsg(error7Tra) \
			[format "%8d" [expr {int(90 + 3 * $n)}]] \
			[format "%8d" [expr {int(1.25 * (14 + 3.5 * $sumt / 100.0))}]]"
	}
	# check error limits 2 * (10 + 10 * length[km]) & 2 * (28" + n * 2)"
	set store 0
	# store coordinates if not node
	if {$store == 0 && $node == 0} {
		set last [expr {$n - 1}]
		if {$free} { incr last}
		for {set i 1} {$i < $last} {incr i} {
			StoreCoord [lindex [lindex $stlist $i] 2] $x($i) $y($i)
		}
	}
	return [list $sumt $x($n1) $y($n1)]
}

#
#	Get horizontal distance and direction in traverse
#	@param buf buffer to process
#	@return list of angle and horizontal distance
proc TraVals {buf} {
	global geoEasyMsg

	set di [GetVal 11 $buf]			;# horizontal distance
	set va ""
	if {$di == ""} {
		set di [GetVal 9 $buf]		;# slope distance
		set va [GetVal 8 $buf]		;# vertical angle
	}
	# reduce distance to horizont, mean see level and proj plan
	if {$di != ""} { set di [GetRedDist $di $va] }
	set angle [GetVal {7 21} $buf]
	if {$angle == ""} {
        geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(angTra) warning 0 OK
		return ""
	}
	return [list $angle $di]
}

#
#	Collect point names interactively &
#	Calculate trigonometric line
#		coordinates are stored in all referenced geo data set
proc GeoTrigLine {} {
	global geoEasyMsg
	global autorefresh

	set slist [GetTraverse {39}]
	if {[llength $slist] > 2} {
		CalcTrigLine $slist
		if {$autoRefresh} {
			RefreshAll
		}
	} else {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noTra) \
			warning 0 OK
	}
}

#
#
#	Calculate trigonometric line. slist is a list of lists where each sublist
#	belongs to a point and contains {geo_set line point_name}
#	geo_set and line refers to the station record in data set
#		coordinates are stored in all referenced geo data set
#	@param slist information for points in traverse, order is significant!
#	@param node 0/1 0 simple line/node (no coordinate storing)
#	@return the length of line and endpoint height as a list.
proc CalcTrigLine {stlist {node 0}} {
	global geoEasyMsg
	global decimals

	set n [llength $stlist]
	set n_1 [expr {$n - 1}]
	if {$n < 3} {return}					;# at least 3 points must be
	foreach st $stlist {
		set geo [lindex $st 0]
		global ${geo}_geo
	}
#
#	collect measurements in trigonometric line
#
	for {set i 0} {$i < $n} {incr i} {
		set i1 [expr {$i + 1}]
		set i_1 [expr {$i - 1}]
		set st [lindex $stlist $i]
		set actpn [lindex $st 2]
		set geo [lindex $st 0]
		set ref [lindex $st 1]
		if {$i1 < $n} {
			set nextpn [lindex [lindex $stlist $i1] 2]
		} else {
			set nextpn ""
		}
		if {$i_1 >= 0} {
			set prevpn [lindex [lindex $stlist $i_1] 2]
		} else {
			set prevpn ""
		}
#		get station instrument height
		upvar #0 ${geo}_geo($ref) st_buf
		if {[info exists st_buf]} {
			set st_height($i) [GetVal {3 6} $st_buf]
		}
		if {$i == 0 || $i == $n_1} {
			set z($i) [GetVal 39 [GetCoord $actpn 39]]
		}

		incr ref								;# 1st point after station
		set next 0
		set prev 0
		while {1} {
			upvar #0 ${geo}_geo($ref) buf
			if {[info exists buf] == 0 || [GetVal 2 $buf] != ""} {
				break	;# next station or end of geo data set
			}
			set pn [GetVal {5 62} $buf]
			if {$i > 0 && $pn == $prevpn} {
				set w [GetHd $actpn $st_buf $prevpn $buf];# get height diff
				if {$w != ""} {
					set hd_1($i_1) [lindex $w 0]
					set d_1($i_1) [lindex $w 1]
					incr prev
				}
			}
			if {$i < $n && $pn == $nextpn} {
				set w [GetHd $actpn $st_buf $nextpn $buf];# get height diff
				if {$w != ""} {
					set hd_2($i) [lindex $w 0]
					set d_2($i) [lindex $w 1]
					incr next
				}
			}
			if {($prev || $i == 0) && ($next || $i == $n_1)} {
				break		;# both neighbouring points found
			}
			incr ref
		}
	}
	if {$node == 0 && ([info exists z(0)] == 0 || $z(0) == "")} {
		GeoLog1 $geoEasyMsg(miszTri)
		geo_dialog .msg $geoEasyMsg(warning) \
			$geoEasyMsg(miszTri) warning 0 OK
		return
	}
	set free 0	;# flag free trigonometric line
	if {$node == 1} {
		# force free line calculation
		set free 1
		if {[info exists z($n_1)]} { set z($n_1) "" }
	} elseif {[info exists z($n_1)] == 0 || $z($n_1) == ""} {
		set free 1	;# free trigonometric line
		if {[geo_dialog .msg $geoEasyMsg(warning) \
			$geoEasyMsg(freeTri) warning 0 OK $geoEasyMsg(cancel)] == 1} {
			return
		}
	}
#	calculate sum of height differences
	set sumh 0
	set sumd2 0
	set sumd 0
	for {set i 0} {$i < $n_1} {incr i} {
		set hd 0
		set n_hd 0
		set dd 0
		# backward height diff
		if {[info exists hd_1($i)]} {
			set hd [expr {$hd - $hd_1($i)}]
			set dd [expr {$dd + $d_1($i)}]
			incr n_hd
		}
		# forward height diff
		if {[info exists hd_2($i)]} {
			set hd [expr {$hd + $hd_2($i)}]
			set dd [expr {$dd + $d_2($i)}]
			incr n_hd
		}
		if {$n_hd == 0} {
			geo_dialog .msg $geoEasyMsg(warning) \
				$geoEasyMsg(dzTri) warning 0 OK
			return
		}
		# average back and forward
		set hd_0($i) [expr {$hd / $n_hd}]
		set d_0($i) [expr {$dd / $n_hd}]
		set sumh [expr {$sumh + $hd_0($i)}]
		set sumd2 [expr {$sumd2 + $d_0($i) * $d_0($i)}]
		set sumd [expr {$sumd + $d_0($i)}]
	}
#	calculate height error
	if {$free} {
		set herr 0
		set herr_m 0
	} else {
		set herr [expr {($z($n_1) - $z(0)) - $sumh}]
		set herr_m [expr {$herr / $sumd2}]			;# correction factor
	}
#	calculate final heights
	for {set i 1} {$i < $n_1} {incr i} {
		set i1 [expr {$i - 1}]
		set z($i) \
			[expr {$z($i1) + $hd_0($i1) + $herr_m * $d_0($i1) * $d_0($i1)}]
	}
	if {$free} {	;# no height for last point
		set i1 [expr {$n_1 - 1}]
		set z($n_1) [expr {$z($i1) + $hd_0($i1)}]
	}
#	output results
#	headers
	GeoLog1
	GeoLog $geoEasyMsg(menuCalTrig)
	GeoLog1 $geoEasyMsg(head1Trig)
	GeoLog1 $geoEasyMsg(head2Trig)
	GeoLog1
	for {set i 0} {$i < $n} {incr i} {
		# point name & height
		GeoLog1 [format "%-10s                                             \
			%8.${decimals}f" [lindex [lindex $stlist $i] 2] $z($i)]
		if {$i < $n_1} {
			if {[info exists hd_2($i)]} {
				set w1 [format "%8.${decimals}f" $hd_2($i)]
			} else {
				set w1 "-"
			}
			if {[info exists hd_1($i)]} {
				set w2 [format "%8.${decimals}f" $hd_1($i)]
			} else {
				set w2 "-"
			}
			# no correction in free line
			if {$free} {
				set w3 "-"
			} else {
				set w3 [format "%8.${decimals}f" [expr {$herr_m * $d_0($i) * $d_0($i)}]]
			}
			GeoLog1 [format "%-10s %8.${decimals}f %8s %8s %8.${decimals}f %8s" \
				[string range [GetPCode [lindex [lindex $stlist $i] 2] 1] 0 9] \
				$d_0($i) $w1 $w2 $hd_0($i) $w3]
		} else {
			if {$free} {
				set w1 " "
			} else {
				set w1 [format "%8.${decimals}f" $herr]
			}
			GeoLog1
			GeoLog1 [format "%-10s %8.${decimals}f                   %8.${decimals}f %8s %8.${decimals}f" \
				"" $sumd $sumh $w1 [expr {$z($n_1) - $z(0)}]]
			GeoLog1
			if {! $free} {
				GeoLog1 "$geoEasyMsg(errorTri) \
					[format "%.${decimals}f" \
					[expr {16.0 * $sumd /1000.0 / sqrt($n) / 100.0}]]"
			}
			GeoLog1
		}
	}
	# check error limit 32 * length / sqrt(n)
	set store 0
	if {[expr {abs($herr)}] > [expr {16.0 * $sumd / 1000.0 / sqrt($n) / 100.0}]} {
		set store [geo_dialog .msg $geoEasyMsg(warning) \
			$geoEasyMsg(limTrig) warning 1 OK $geoEasyMsg(cancel)]
	}
	# store coordinates if not node calculation
	if {$store == 0 && $node == 0} {
		set last [expr {$n - 1}]
		if {$free} { incr last}
		for {set i 1} {$i < $last} {incr i} {
			StoreZ [lindex [lindex $stlist $i] 2] $z($i)
		}
	}
	return [list $sumd $z($n_1)]
}

#
#	Calculate height difference & distance beetwen pn and target in buf or
#	empty string in case of error
#	Distance calculated from coordinates is prefered but measured
#	distances are used if no horizontal coordinates for points
#	@param st station name
#	@param st_buf station record in geo data set
#	@param tg target name
#	@param tg_buf target record in geo data set
#	@return list of height difference and distance
proc GetHd {st st_buf tg tg_buf} {
	global projRed avgH stdAngle stdDist1 stdDist2 refr

	if {[info exists st_buf] == 0 || [info exists tg_buf] == 0} {
		return ""
	}
	# calculate distance from coordinates if posssible
	set st_co [GetCoord $st {37 38}]
	set tg_co [GetCoord $tg {37 38}]
	set z [GetVal 8 $tg_buf]			;# zenit angle
	set dm [GetVal 10 $tg_buf]			;# height diff
	set st_h [GetVal {3 6} $st_buf]
	set tg_h [GetVal 6 $tg_buf]
	if {($z == "" || $st_h == "" || $tg_h == "") && $dm == ""} {
		return ""		;# no zenith angle or station or target height
	}
	if {[llength $st_co] > 0 && [llength $tg_co] > 0} {
		set dx [expr {[GetVal 37 $st_co] - [GetVal 37 $tg_co]}]
		set dy [expr {[GetVal 38 $st_co] - [GetVal 38 $tg_co]}]
		set d [expr {sqrt($dx * $dx + $dy * $dy)}]
	} else {
		# try horizontal distance
		set d [GetVal 11 $tg_buf]
		if {$d == ""} {
			set d [GetVal 9 $tg_buf]	;# slope dist.
			if {$d == ""} {return ""}
			if {$z != ""} {
				set d [expr {$d * sin($z)}]
			} else {
				set d [expr {sqrt($d*$d - $dm*$dm)}]
			}
		}
	}
	if {$dm != ""} {
		set hd $dm
		if {$refr && $d > 400} {
			set hd [expr {$hd + [GetRefr $d]}]
		}
	} else {
		set hd [expr {$d / tan($z) + $st_h - $tg_h}]
		if {$refr && $d > 400} {
			set hd [expr {$hd + [GetRefr $d]}]
		}
	}
	return [list $hd $d]
}

#
#	Select traversing and/or trigonometric line mode
#	@return 0 for none, 1 for traversing, 2 for trigonometric line,
#		3 for both
proc TravDia {} {
	global geoEasyMsg
	global travC trigC

	set w [focus]
	if {$w == ""} { set w "." }
	set this .travdia
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}
	if {[info exists travC] == 0} {set travC 0}
	if {[info exists trigC] == 0} {set trigC 0}

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(menuGraCal)
	wm protocol $this WM_DELETE_WINDOW "destroy $this"
	wm protocol $this WM_SAVE_YOURSELF "destroy $this"
	wm resizable $this 0 0
	wm transient $this $w
	catch {wm attribute $this -topmost}

	checkbutton $this.trav -text $geoEasyMsg(travChk) -variable travC -relief flat
	checkbutton $this.trig -text $geoEasyMsg(trigChk) -variable trigC -relief flat
	button $this.exit -text $geoEasyMsg(ok) -command "destroy $this"

	pack $this.trav $this.trig -side top -anchor w
	pack $this.exit -side top
	tkwait visibility $this
	CenterWnd $this
	grab set $this
	tkwait window $this
	return [expr {$travC + $trigC * 2}]
}
