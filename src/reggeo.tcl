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

#	Main proc for different regression calculation (line, plane)
#	Started from menu
#	@param regindex index of regression type
proc GeoReg {regindex} {
	global reglist
	global geoEasyMsg geoCodes
	global reg

#	select points for regression
	if {$regindex == 0} {
		# linear regression
		set plist [lsort -dictionary [GetGiven {37 38}]]
		if {[llength $plist] >= 2} {
			set rplist [GeoListbox $plist {0} $geoEasyMsg(lbTitle1) -2]
			if {[llength $rplist] >= 2} {
				LinRegXY $rplist [lindex $reglist 0]
			}
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewCoord) error 0 OK
		}
	} elseif {$regindex == 1} {
		# parallel lines
		set plist [lsort -dictionary [GetGiven {37 38}]]
		if {[llength $plist] >= 4} {
			set rplist [GeoListbox $plist {0} $geoEasyMsg(lbTitle1) -2]
			# remove used points
			foreach r $rplist {
				set plist [lsearch -all -inline -not -exact $plist $r]
			}
			set pplist [GeoListbox $plist {0} $geoEasyMsg(lbTitle1) -2]
			ParLin $rplist $pplist
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewCoord) error 0 OK
		}
	} elseif {$regindex == 2} {
		# circle
		set plist [lsort -dictionary [GetGiven {37 38}]]
		if {[llength $plist] > 2} {
			set rplist [GeoListbox $plist {0} $geoEasyMsg(lbTitle1) -3]
			if {[llength $rplist] >= 3} {
				set r [GeoEntry "$geoCodes(64):" $geoCodes(64) $geoEasyMsg(unknown)]
				regsub "^\[     \]*" $r "" r    ;# remove leading spaces/tabs
				regsub "\[  \]*$" $r "" r       ;# remove trailing spaces/tabs
				if {[regexp $reg(2) $r] == 0} {
					set r ""
				}
				if {$r == ""} {
					CircleReg $rplist
				} else {
					CircleRegR $rplist $r
				}
			}
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewCoord) error 0 OK
		}

	} elseif {$regindex >= 3 && $regindex <= 8} {
		# regression plane
		set plist [lsort -dictionary [GetGiven {37 38 39}]]
		if {[llength $plist] >= 3} {
			set rplist [GeoListbox $plist {0} $geoEasyMsg(lbTitle1) -3]
			if {[llength $rplist] >= 3} {
				switch -exact -- $regindex {
					3 { PlaneRegYXZ $rplist }
					4 { PlaneHReg $rplist }
					5 { LinRegXY $rplist [lindex $reglist 5]}
					6 { 
						set r [GeoEntry "$geoCodes(64):" $geoCodes(64) $geoEasyMsg(unknown)]
						regsub "^\[     \]*" $r "" r    ;# remove leading spaces/tabs
						regsub "\[  \]*$" $r "" r       ;# remove trailing spaces/tabs
						if {[regexp $reg(2) $r] == 0} {
							set r ""
						}
						if {$r == ""} {
							SphereReg $rplist		;# sphere
						} else {
							SphereRegR $rplist $r	;# sphere with known radius
						}
					}
					7 { Line3DReg $rplist }
					8 { ParabReg $rplist }
				}
			}
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewCoord) error 0 OK
		}
	}
}

#	Main proc for different regression calculation (line, plane)
#	Started from toolbar
#	@param plist
proc GeoReg1 {plist} {
	global reglist
	global geoEasyMsg geoCodes
	global reg

#	select regression type
	set regtype [GeoListbox $reglist {0 1 2 3 4} $geoEasyMsg(lbReg) 1]
	set regindex [lsearch -exact $reglist [lindex $regtype 0]]
#	check points for regression
	set rplist ""
	set nop ""
	if {$regindex >= 0 && $regindex <= 2} {
		# 2D regression
		foreach pn $plist {
			if {[llength [GetCoord $pn {37 38}]] > 0} {
				lappend rplist $pn
			} else {
				set nop "$nop $pn"	;# drop point
			}
		}
		if {[string length $nop] > 0} {
			tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(pointsDropped) \
				warning 0 OK
		}
		if {[llength $rplist] >= 2 && $regindex == 0} {
			LinRegXY $rplist [lindex $reglist 2]	;# 2D line
		} elseif {$regindex == 1} {
			# nop for paralel lines TODO
		} elseif {[llength $rplist] > 2 && $regindex == 2} {
			set r [GeoEntry "$geoCodes(64):" $geoCodes(64) $geoEasyMsg(unknown)]
			regsub "^\[     \]*" $r "" r    ;# remove leading spaces/tabs
			regsub "\[  \]*$" $r "" r       ;# remove trailing spaces/tabs
			if {[regexp $reg(2) $r] == 0} {
				set r ""
			}
			if {$r == ""} {
				CircleReg $rplist
			} else {
				CircleRegR $rplist $r
			}
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewCoord) error 0 OK
		}
	} elseif {$regindex >= 3 && $regindex <= 7} {
		# 3D regression
		foreach pn $plist {
			if {[llength [GetCoord $pn {37 38 39}]] > 0} {
				lappend rplist $pn
			} else {
				set nop "$nop $pn"	;# drop point
			}
		}
		if {[string length $nop] > 0} {
			tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(pointsDropped) \
				warning 0 OK
		}
		if {[llength $rplist] >= 3 && $regindex == 3} {
			PlaneRegYXZ $rplist		;# general plane
		} elseif {[llength $rplist] >= 1 && $regindex == 4} {
			PlaneHReg $rplist		;# horizontal plane
		} elseif {[llength $rplist] >= 2 && $regindex == 5} {
			LinRegXY $rplist [lindex $reglist 5]	;# vertical plane
		} elseif {[llength $rplist] >= 4 && $regindex == 6} {
			set r [GeoEntry "$geoCodes(64):" $geoCodes(64) $geoEasyMsg(unknown)]
			regsub "^\[     \]*" $r "" r    ;# remove leading spaces/tabs
			regsub "\[  \]*$" $r "" r       ;# remove trailing spaces/tabs
			if {[regexp $reg(2) $r] == 0} {
				set r ""
			}
			if {$r == ""} {
				SphereReg $rplist		;# sphere
			} else {
				SphereRegR $rplist $r	;# sphere with known radius
			}
		} elseif {[llength $rplist] >= 4 && $regindex == 7} {
			Line3DReg $rplist		;# 3D line
		} elseif {[llength $rplist] >= 5 && $regindex == 8} {
			ParabReg $rplist		;# TODO not tested, not enabled
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewCoord) error 0 OK
		}
	}
}

#		
#	Calculate linear regression, first coordinates are not changed
#	output result to result window
#	OBSOLATE not called
#	@param plist list of point numbers to use
proc LinRegX {plist} {
	global decimals
	global geoEasyMsg
	global reglist
	
#	calculate weight point
	set xs 0
	set ys 0
	set n [expr {double([llength $plist])}]
	set i 0
#	sum for weight point
	foreach pn $plist {
		set coords [GetCoord $pn {37 38}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set xs [expr {$xs + $x($i)}]
		set ys [expr {$ys + $y($i)}]
		incr i
	}
	set xs [expr {$xs / $n}]
	set ys [expr {$ys / $n}]
	set kszi_eta 0
	set kszi_2 0
	set eta_2 0
	set swap_xy 0
	for {set i 0} {$i < $n} {incr i} {
		set kszi [expr {double($y($i) - $ys)}]
		set eta [expr {double($x($i) - $xs)}]
		set kszi_eta [expr {$kszi_eta + $kszi * $eta}]
		set kszi_2 [expr {$kszi_2 + $kszi * $kszi}]
		set eta_2 [expr {$eta_2 + $eta * $eta}]
	}
	# check for vertical line
	if {[catch {set m [expr {$kszi_eta / $kszi_2}]}]} {
		tk_dialog .msg "Hiba" $geoEasyMsg(linreg) error 0 OK
		exit
	}
	set b [expr {$xs - $m * $ys}]
	GeoLog1
	GeoLog [lindex $reglist 0]
	GeoLog1 [format $geoEasyMsg(head0LinRegX) $m [format "%+.${decimals}f" $b]]
	# report angle to axis
	GeoLog1 "$geoEasyMsg(hAngleReg) [DMS [expr {atan($m)}]]"
	# report correlation
	set correlation [expr {$kszi_eta / ($n - 1.0) / \
		sqrt($eta_2 / ($n - 1.)) / sqrt($kszi_2 / ($n - 1.))}]
	GeoLog1 "$geoEasyMsg(correlation) [format "%.${decimals}f" $correlation]"
	GeoLog1
	GeoLog1 $geoEasyMsg(head1LinRegX)
	#	list residuals
	set sdx2 0
	for {set i 0} {$i < $n} {incr i} {
		set dx [expr {($m * $y($i) + $b) - $x($i)}]
		set sdx2 [expr {$sdx2 + $dx * $dx}]
		GeoLog1 [format \
			"%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) $dx]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdx2 / $n)}]]
}

#
#
#	Calculate linear regression, second coordinates are not changed
#	output result to result window
#	OBSOLATE not called
#	@param plist list of point numbers to use
proc LinRegY {plist} {
	global decimals
	global geoEasyMsg
	global reglist
	
#	calculate weight point
	set xs 0
	set ys 0
	set n [expr {double([llength $plist])}]
	set i 0
#	sum for weight point
	foreach pn $plist {
		set coords [GetCoord $pn {37 38}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set xs [expr {$xs + $x($i)}]
		set ys [expr {$ys + $y($i)}]
		incr i
	}
	set xs [expr {$xs / $n}]
	set ys [expr {$ys / $n}]
	set kszi_eta 0
	set eta_2 0
	set kszi_2 0
	for {set i 0} {$i < $n} {incr i} {
		set kszi [expr {double($y($i) - $ys)}]
		set eta [expr {double($x($i) - $xs)}]
		set kszi_eta [expr {$kszi_eta + $kszi * $eta}]
		set eta_2 [expr {$eta_2 + $eta * $eta}]
		set kszi_2 [expr {$kszi_2 + $kszi * $kszi}]
	}
	# check for vertical line
	if {[catch {set m [expr {$kszi_eta / $eta_2}]}]} {
		tk_dialog .msg "Hiba" $geoEasyMsg(linreg) error 0 OK
		exit
	} else {
		set b [expr {$ys - $m * $xs}]
	}
	GeoLog1
	GeoLog [lindex $reglist 1]
	GeoLog1 [format $geoEasyMsg(head0LinRegY) $m [format "%+.${decimals}f" $b]]
	GeoLog1 "$geoEasyMsg(vAngleReg) [DMS [expr {atan($m)}]]"
	# report correlation
	set correlation [expr {$kszi_eta / ($n - 1.0) / \
		sqrt($eta_2 / ($n - 1.)) / sqrt($kszi_2 / ($n - 1.))}]
	GeoLog1 "$geoEasyMsg(correlation) [format "%.${decimals}f" $correlation]"
	GeoLog1
	GeoLog1 $geoEasyMsg(head1LinRegY)
	#	list residuals
	set sdy2 0
	for {set i 0} {$i < $n} {incr i} {
		set dy [expr {($m * $x($i) + $b) - $y($i)}]
		set sdy2 [expr {$sdy2 + $dy * $dy}]
		GeoLog1 [format \
			"%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) $dy]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdy2 / $n)}]]
}

#
#	Calculate regression plane only z coords are changed
#	output result to result window
#	OBSOLATE not called
#	@param plist list of point numbers to use
proc PlaneReg {plist} {
	global decimals
	global geoEasyMsg
	global PI PI2
	global reglist
	
#	calculate weight point
	set xs 0
	set ys 0
	set zs 0
	set n [expr {double([llength $plist])}]
	set i 0
#	sum for weight point
	foreach pn $plist {
		set coords [GetCoord $pn {37 38 39}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set z($i) [GetVal 39 $coords]
		set xs [expr {$xs + $x($i)}]
		set ys [expr {$ys + $y($i)}]
		set zs [expr {$zs + $z($i)}]
		incr i
	}
	set xs [expr {$xs / $n}]
	set ys [expr {$ys / $n}]
	set zs [expr {$zs / $n}]
	set kszi_eta 0
	set kszi_2 0
	set eta_2 0
	set kszi_zeta 0
	set eta_zeta 0
	for {set i 0} {$i < $n} {incr i} {
		set kszi [expr {$y($i) - $ys}]
		set eta [expr {$x($i) - $xs}]
		set zeta [expr {$z($i) - $zs}]
		set kszi_eta [expr {$kszi_eta + $kszi * $eta}]
		set kszi_zeta [expr {$kszi_zeta + $kszi * $zeta}]
		set eta_zeta [expr {$eta_zeta + $eta * $zeta}]
		set kszi_2 [expr {$kszi_2 + $kszi * $kszi}]
		set eta_2 [expr {$eta_2 + $eta * $eta}]
	}
	# solve reduced equation for a1 a2
	set det [expr {double($kszi_2 * $eta_2 - $kszi_eta * $kszi_eta)}]
	set deta1 [expr {-$kszi_zeta * $eta_2 + $eta_zeta * $kszi_eta}]
	set deta2 [expr {-$kszi_2 * $eta_zeta + $kszi_eta * $kszi_zeta}]
	if {[catch {set a1 [expr {-$deta1 / $det}]}]} {
		tk_dialog .msg "Hiba" $geoEasyMsg(planreg) error 0 OK
		exit
	}
	if {[catch {set a2 [expr {-$deta2 / $det}]}]} {
		tk_dialog .msg "Hiba" $geoEasyMsg(planreg) error 0 OK
		exit
	}
	set a0 [expr {$zs - $a1 * $ys - $a2 * $xs}]
	GeoLog1
	GeoLog [lindex $reglist 5]
	GeoLog1 [format $geoEasyMsg(head0PlaneReg) [format "%+.${decimals}f" $a0] $a1 $a2]
#	slope angle and direction
	set dir [Bearing $a1 $a2 0 0]
#	while {$dir < 0} { set dir [expr {$dir + $PI2}]}
	set ang [expr {atan(sqrt($a1*$a1+$a2*$a2))}]
	GeoLog1 [format $geoEasyMsg(head00PlaneReg) [DMS $dir] [DMS $ang]]
	GeoLog1
	GeoLog1 $geoEasyMsg(head1PlaneReg)
	set sdz2 0
#	list residuals
	for {set i 0} {$i < $n} {incr i} {
		set dz [expr {($a0 + $a1 * $y($i) + $a2 * $x($i)) - $z($i)}]
		set sdz2 [expr {$sdz2 + $dz * $dz}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) $z($i) $dz]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdz2 / $n)}]]
}

#		
#	Calculate linear regression, x & y coordinates are changed
#	output result to result window
#	It is used to calculate vertical plane too
#	@param plist list of point numbers to use
#	@param title title for log (2D line/Vertical plane)
proc LinRegXY {plist title} {
	global decimals
	global geoEasyMsg
	global PI
	
#	calculate weight point
	set xs 0
	set ys 0
	set n [expr {double([llength $plist])}]
	set i 0
#	sum for weight point
	foreach pn $plist {
		set coords [GetCoord $pn {37 38}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set xs [expr {$xs + $x($i)}]
		set ys [expr {$ys + $y($i)}]
		incr i
	}
	set xs [expr {$xs / $n}]
	set ys [expr {$ys / $n}]
	set kszi_eta 0
	set kszi_2 0
	set eta_2 0
	for {set i 0} {$i < $n} {incr i} {
		set kszi [expr {$y($i) - $ys}]
		set eta [expr {$x($i) - $xs}]
		set kszi_eta [expr {$kszi_eta + $kszi * $eta}]
		set kszi_2 [expr {$kszi_2 + $kszi * $kszi}]
		set eta_2 [expr {$eta_2 + $eta * $eta}]
	}
	if {[catch { \
		set fi [expr {0.5 * atan2(2.0 * $kszi_eta, ($kszi_2 - $eta_2))}]}]} {
		tk_dialog .msg "Hiba" $geoEasyMsg(linreg) error 0 OK
		exit
	}
	set m [expr {tan($fi)}]
	set b [expr {$xs - $m * $ys}]

	GeoLog1
	GeoLog $title
	GeoLog1 [format $geoEasyMsg(head0LinRegX) $m [format %+.${decimals}f $b]]
	GeoLog1 "$geoEasyMsg(hAngleReg) [DMS $fi]"
	# report correlation
	set correlation [expr {$kszi_eta / ($n - 1.0) / \
		sqrt($eta_2 / ($n - 1.)) / sqrt($kszi_2 / ($n - 1.))}]
	GeoLog1 "$geoEasyMsg(correlation) [format %.${decimals}f $correlation]"
	GeoLog1
	GeoLog1 $geoEasyMsg(head2LinReg)
#	list residuals
	set sdt2 0
	for {set i 0} {$i < $n} {incr i} {
		set v [expr {($y($i) - $ys) * sin($fi) - \
			($x($i) - $xs) * cos($fi)}]
		set dy [expr {-1 * $v * sin($fi)}]
		set dx [expr {$v * cos($fi)}]
		set dt [expr {hypot($dy, $dx)}]
		set sdt2 [expr {$sdt2 + $dt * $dt}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) $dy $dx $dt]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdt2 / $n)}]]
}

#
#	Calculatate best fit circle, direct formula
#		r^2 = (x-x0)^2 + (y - y0)^2
#	y0, x0 and r are unknowns
#	@param plist list of point numbers to use
proc CircleReg {plist} {
	global geoEasyMsg
	global decimals
	global reglist

	set n [expr {double([llength $plist])}]
	set i 0
	set sx 0
	set sy 0
	set sxy 0
	set sx2 0
	set sy2 0
	set l0 0
	set l1 0
	set l2 0
	# set offset to first point to avoid rounding errors
	set pn [lindex $plist 0]
	set coords [GetCoord $pn {37 38}]
	set x_offs [GetVal 37 $coords]
	set y_offs [GetVal 38 $coords]
	#	coords of points
	foreach pn $plist {
		set coords [GetCoord $pn {37 38}]
		set x($i) [expr {[GetVal 37 $coords] - $x_offs}]
		set y($i) [expr {[GetVal 38 $coords] - $y_offs}]
		set x2 [expr {$x($i) * $x($i)}]
		set y2 [expr {$y($i) * $y($i)}]
		set sx [expr {$sx + $x($i)}]
		set sy [expr {$sy + $y($i)}]
		set sxy [expr {$sxy + $x($i) * $y($i)}]
		set sx2 [expr {$sx2 + $x2}]
		set sy2 [expr {$sy2 + $y2}]
		set l0 [expr {$l0 + $x($i) * ($x2 + $y2)}]
		set l1 [expr {$l1 + $y($i) * ($x2 + $y2)}]
		set l2 [expr {$l2 + $x2 + $y2}]
		incr i
	}
	# set up normal equatiion
	set a(0,0) $sx2
	set a(0,1) $sxy
	set a(0,2) $sx
	set a(1,0) $sxy
	set a(1,1) $sy2
	set a(1,2) $sy
	set a(2,0) $sx
	set a(2,1) $sy
	set a(2,2) $n
	set b(0) [expr {-$l0}]
	set b(1) [expr {-$l1}]
	set b(2) [expr {-$l2}]
	GaussElimination a b 3
	set x0e [expr {-0.5 * $b(0)}]
	set y0e [expr {-0.5 * $b(1)}]
	set x0e_offs [expr {$x0e + $x_offs}]
	set y0e_offs [expr {$y0e + $y_offs}]
	set re [expr {sqrt(($b(0) * $b(0) + $b(1) * $b(1)) / 4.0 - $b(2))}]
	GeoLog1
	GeoLog [lindex $reglist 2]
	GeoLog1 [format $geoEasyMsg(head0CircleReg) [format %.${decimals}f $y0e_offs] [format %.${decimals}f $x0e_offs] [format %.${decimals}f $re]]
	GeoLog1
	GeoLog1 $geoEasyMsg(head1CircleReg)
	set sdr2 0
	for {set i 0} {$i < $n} {incr i} {
		set delta [Bearing $y0e $x0e $y($i) $x($i)]
		set dr [expr {$re - [Distance $y0e $x0e $y($i) $x($i)]}]
		set sdr2 [expr {$sdr2 + $dr * $dr}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] \
			[expr {$y($i) + $y_offs}] [expr {$x($i) + $x_offs}] \
			[expr {$y0e + $re * sin($delta) - $y($i)}] \
			[expr {$x0e + $re * cos($delta) - $x($i)}] $dr]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdr2 / $n)}]]
}

#
#	Calculatate best fit circle, iteration is used
#		y = y0 + r * sin(delta)
#		x = x0 + r * cos(delta)
#	y0, x0 and r are unknowns (deltas are estimated)
#	@param plist list of point numbers to use
proc CircleRegOld {plist} {
	global geoEasyMsg
	global decimals
	global reglist
	global maxIteration epsReg

	set n [expr {double([llength $plist])}]
	set i 0
#	coords of points
	foreach pn $plist {
		set coords [GetCoord $pn {37 38}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		incr i
	}
#	circle on three points (approximate value)
	set circ [Circle3P $y(0) $x(0) $y(1) $x(1) $y(2) $x(2)]
	set y0e [lindex $circ 0]
	set x0e [lindex $circ 1]
	set re [lindex $circ 2]
	set iteration 0
	while 1 {
		incr iteration
		set sumyo 0
		set sumxo 0
		set sumsin 0
		set sumcos 0
		set sumyx 0
		# relative coordinates to center of circle
		for {set i 0} {$i < $n} {incr i} {
			set yo($i) [expr {$y($i) - $y0e}]
			set xo($i) [expr {$x($i) - $x0e}]
			set delta [Bearing 0 0 $yo($i) $xo($i)]
			set sumyo [expr {$sumyo + $yo($i)}]
			set sumxo [expr {$sumxo + $xo($i)}]
			set sumsin [expr {$sumsin + sin($delta)}]
			set sumcos [expr {$sumcos + cos($delta)}]
			set sumyx [expr {$sumyx + $yo($i) * sin($delta) + $xo($i) * cos($delta)}]
		}
		# set up normal equation
		set a(0,0) $n
		set a(0,1) 0
		set a(0,2) $sumsin
		set a(1,0) 0
		set a(1,1) $n
		set a(1,2) $sumcos
		set a(2,0) $sumsin
		set a(2,1) $sumcos
		set a(2,2) $n
		set b(0) $sumyo
		set b(1) $sumxo
		set b(2) $sumyx
		GaussElimination a b 3
		set y0e [expr {$y0e + $b(0)}]
		set x0e [expr {$x0e + $b(1)}]
		set re $b(2)
		if {[expr {abs($b(0))}] < $epsReg && [expr {abs($b(1))}] < $epsReg &&
			[expr {abs($b(2) - $re)}] < $epsReg || $iteration > $maxIteration} {
			break
		}
	}
	GeoLog1
	GeoLog [lindex $reglist 2]
	GeoLog1 [format $geoEasyMsg(head0CircleReg) [format %.${decimals}f $y0e] [format %.${decimals}f $x0e] [format %.${decimals}f $re]]
	if {$iteration > $maxIteration} {
		GeoLog1 [format $geoEasyMsg(head2CircleReg) $maxIteration $epsReg]
	}
	GeoLog1
	GeoLog1 $geoEasyMsg(head1CircleReg)
	set sdr2 0
	for {set i 0} {$i < $n} {incr i} {
		set delta [Bearing $y0e $x0e $y($i) $x($i)]
		set dr [expr {$re - [Distance $y0e $x0e $y($i) $x($i)]}]
		set sdr2 [expr {$sdr2 + $dr * $dr}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) \
			[expr {$y0e + $re * sin($delta) - $y($i)}] \
			[expr {$x0e + $re * cos($delta) - $x($i)}] $dr]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdr2 / $n)}]]
}

#
#	Calculatate best fit circle with given radius, iteration is used
#		y = y0 + r * sin(delta)
#		x = x0 + r * cos(delta)
#	y0, x0 are unknowns (deltas are estimated)
#	@param plist list of point numbers to use
#	@param r given radius
proc CircleRegR {plist r} {
	global geoEasyMsg
	global decimals
	global reglist
	global maxIteration epsReg

	set n [expr {double([llength $plist])}]
	set i 0
#	coords of points
	foreach pn $plist {
		set coords [GetCoord $pn {37 38}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		incr i
	}
#	circle on three points (approximate value)
	set circ [Circle3P $y(0) $x(0) $y(1) $x(1) $y(2) $x(2)]
	set y0e [lindex $circ 0]
	set x0e [lindex $circ 1]
	set iteration 0
	while 1 {
		incr iteration
		set sumsin 0
		set sumcos 0
		# relative coordinates to center of circle
		for {set i 0} {$i < $n} {incr i} {
			set yo($i) [expr {$y($i) - $y0e}]
			set xo($i) [expr {$x($i) - $x0e}]
			set delta [Bearing 0 0 $yo($i) $xo($i)]
			set sumsin [expr {$sumsin + $yo($i) - $r * sin($delta)}]
			set sumcos [expr {$sumcos + $xo($i) - $r * cos($delta)}]
		}
		set dy0 [expr {$sumsin / $n}]
		set dx0 [expr {$sumcos / $n}]
		set y0e [expr {$y0e + $dy0}]
		set x0e [expr {$x0e + $dx0}]
		if {[expr {abs($dy0)}] < $epsReg && [expr {abs($dx0)}] < $epsReg || \
			$iteration > $maxIteration} {
			break
		}
	}
	GeoLog1
	GeoLog "[lindex $reglist 2] $geoEasyMsg(fixedRadius)"
	GeoLog1 [format $geoEasyMsg(head0CircleReg) [format %.${decimals}f $y0e] [format %.${decimals}f $x0e] [format %.${decimals}f $r]]
	if {$iteration > $maxIteration} {
		GeoLog1 [format $geoEasyMsg(head2CircleReg) $maxIteration $epsReg]
	}
	GeoLog1
	GeoLog1 $geoEasyMsg(head1CircleReg)
	set sdr2 0
	for {set i 0} {$i < $n} {incr i} {
		set delta [Bearing $y0e $x0e $y($i) $x($i)]
		set dr [expr {$r - [Distance $y0e $x0e $y($i) $x($i)]}]
		set sdr2 [expr {$sdr2 + $dr * $dr}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) \
			[expr {$y0e + $r * sin($delta) - $y($i)}] \
			[expr {$x0e + $r * cos($delta) - $x($i)}] $dr]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdr2 / $n)}]]
}

#
#	Calculatate best fit sphere, direct formula
#		r^2 = (x-x0)^2 + (y - y0)^2 + (z - z0)^2
#	y0, x0, z0 and r are unknowns
#	@param plist list of point numbers to use
proc SphereReg {plist} {
	global geoEasyMsg
	global decimals
	global reglist

	set n [expr {double([llength $plist])}]
	set i 0
	set sx 0
	set sy 0
	set sz 0
	set sxy 0
	set sxz 0
	set syz 0
	set sx2 0
	set sy2 0
	set sz2 0
	set l0 0
	set l1 0
	set l2 0
	set l3 0
#	coords of points
	foreach pn $plist {
		set coords [GetCoord $pn {37 38}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set z($i) [GetVal 39 $coords]
		set x2 [expr {$x($i) * $x($i)}]
		set y2 [expr {$y($i) * $y($i)}]
		set z2 [expr {$z($i) * $z($i)}]
		set sx [expr {$sx + $x($i)}]
		set sy [expr {$sy + $y($i)}]
		set sz [expr {$sz + $z($i)}]
		set sxy [expr {$sxy + $x($i) * $y($i)}]
		set sxz [expr {$sxz + $x($i) * $z($i)}]
		set syz [expr {$syz + $y($i) * $z($i)}]
		set sx2 [expr {$sx2 + $x2}]
		set sy2 [expr {$sy2 + $y2}]
		set sz2 [expr {$sz2 + $z2}]
		set l0 [expr {$l0 + $x($i) * ($x2 + $y2 + $z2)}]
		set l1 [expr {$l1 + $y($i) * ($x2 + $y2 + $z2)}]
		set l2 [expr {$l2 + $z($i) * ($x2 + $y2 + $z2)}]
		set l3 [expr {$l3 + $x2 + $y2 + $z2}]
		incr i
	}
	# set up normal equatiion
	set a(0,0) $sx2
	set a(0,1) $sxy
	set a(0,2) $sxz
	set a(0,3) $sx
	set a(1,0) $sxy
	set a(1,1) $sy2
	set a(1,2) $syz
	set a(1,3) $sy
	set a(2,0) $sxz
	set a(2,1) $syz
	set a(2,2) $sz2
	set a(2,3) $sz
	set a(3,0) $sx
	set a(3,1) $sy
	set a(3,2) $sz
	set a(3,3) $n
	set b(0) [expr {-$l0}]
	set b(1) [expr {-$l1}]
	set b(2) [expr {-$l2}]
	set b(3) [expr {-$l3}]
	GaussElimination a b 4
	set x0e [expr {-0.5 * $b(0)}]
	set y0e [expr {-0.5 * $b(1)}]
	set z0e [expr {-0.5 * $b(2)}]
	set re [expr {sqrt(($b(0) * $b(0) + $b(1) * $b(1) + $b(2) * $b(2)) / 4.0 - $b(3))}]
	GeoLog1
	GeoLog1 $geoEasyMsg(head1SphereReg)
	set sdr2 0
	for {set i 0} {$i < $n} {incr i} {
		set yo [expr {$y($i) - $y0e}]
		set xo [expr {$x($i) - $x0e}]
		set zo [expr {$z($i) - $z0e}]
		set delta [Bearing 0 0 $yo $xo]
		set alfa [expr {atan2($zo, [Distance 0 0 $yo $xo])}]
		set dr [expr {$re - [Distance3d $y0e $x0e $z0e $y($i) $x($i) $z($i)]}]
		set sdr2 [expr {$sdr2 + $dr * $dr}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) $z($i) \
			[expr {$y0e + $re * cos($alfa) * sin($delta) - $y($i)}] \
			[expr {$x0e + $re * cos($alfa) * cos($delta) - $x($i)}] \
			[expr {$z0e + $re * sin($alfa) - $z($i)}] $dr]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdr2 / $n)}]]
}

#
#	Calculatate best fit sphere, iteration is used
#		y = y0 + r * cos(alfa) * sin(delta)
#		x = x0 + r * cos(alfa) * cos(delta)
#		z = z0 + r * sin(alfa)
#	y0, x0, z0 and r are unknowns (alfa, delta is calculated?)
#	@param plist list of point numbers to use
proc SphereRegOld {plist} {
	global geoEasyMsg
	global decimals
	global reglist
	global maxIteration epsReg

	set n [expr {double([llength $plist])}]
	set i 0
	set sx 0
	set sy 0
	set sz 0
#	coords of points
	foreach pn $plist {
		set coords [GetCoord $pn {37 38 39}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set z($i) [GetVal 39 $coords]
		set sx [expr {$sx + $x($i)}]
		set sy [expr {$sy + $y($i)}]
		set sz [expr {$sz + $z($i)}]
		incr i
	}
#	approximate center is the weight point
	set y0e [expr {$sy / $n}]
	set x0e [expr {$sx / $n}]
	set z0e [expr {$sz / $n}]
	set re [Distance3d $y0e $x0e $z0e $x(0) $y(0) $z(0)]
	set iteration 0
	while 1 {
		incr iteration
		set sumcossin 0
		set sumcoscos 0
		set sumsin 0
		set sumb0 0
		set sumb1 0
		set sumb2 0
		set sumb3 0
		# relative coordinates to center of sphere
		for {set i 0} {$i < $n} {incr i} {
			set yo($i) [expr {$y($i) - $y0e}]
			set xo($i) [expr {$x($i) - $x0e}]
			set zo($i) [expr {$z($i) - $z0e}]
			set delta [Bearing 0 0 $yo($i) $xo($i)]
			set alfa [expr {atan2($zo($i), [Distance 0 0 $yo($i) $xo($i)])}]
			set w1 [expr {cos($alfa) * sin($delta)}]
			set w2 [expr {cos($alfa) * cos($delta)}]
			set w3 [expr {sin($alfa)}]
			set sumcossin [expr {$sumcossin + $w1}]
			set sumcoscos [expr {$sumcoscos + $w2}]
			set sumsin [expr {$sumsin + $w3}]
			set v1 [expr {$yo($i) - $re * $w1}]
			set v2 [expr {$xo($i) - $re * $w2}]
			set v3 [expr {$zo($i) - $re * $w3}]
			set sumb0 [expr {$sumb0 + $v1}]
			set sumb1 [expr {$sumb1 + $v2}]
			set sumb2 [expr {$sumb2 + $v3}]
			set sumb3 [expr {$sumb3 + $w1 * $v1 + $w2 * $v2 + $w3 * $v3}]
		}
		# set up normal equation
		set a(0,0) $n
		set a(0,1) 0
		set a(0,2) 0
		set a(0,3) $sumcossin
		set a(1,0) 0
		set a(1,1) $n
		set a(1,2) 0
		set a(1,3) $sumcoscos
		set a(2,0) 0
		set a(2,1) 0
		set a(2,2) $n
		set a(2,3) $sumsin
		set a(3,0) $a(0,3)
		set a(3,1) $a(1,3)
		set a(3,2) $a(2,3)
		set a(3,3) $n
		set b(0) $sumb0
		set b(1) $sumb1
		set b(2) $sumb2
		set b(3) $sumb3
		GaussElimination a b 4
		if {[expr {abs($b(0))}] < $epsReg && [expr {abs($b(1))}] < $epsReg && \
			[expr {abs($b(2))}] < $epsReg && \
			[expr {abs($b(3))}] < $epsReg || $iteration > $maxIteration} {
				break
		}
		set y0e [expr {$y0e + $b(0)}]
		set x0e [expr {$x0e + $b(1)}]
		set z0e [expr {$z0e + $b(2)}]
		set re [expr {$re + $b(3)}]
	}
	GeoLog1
	GeoLog [lindex $reglist 6]
	GeoLog1 [format $geoEasyMsg(head0SphereReg) [format %.${decimals}f $y0e] [format %.${decimals}f $x0e] [format %.${decimals}f $z0e] [format %.${decimals}f $re]]
	if {$iteration > $maxIteration} {
		GeoLog1 [format $geoEasyMsg(head2CircleReg) $maxIteration $epsReg]
	}
	GeoLog1
	GeoLog1 $geoEasyMsg(head1SphereReg)
	set sdr2 0
	for {set i 0} {$i < $n} {incr i} {
		set delta [Bearing 0 0 $yo($i) $xo($i)]
		set alfa [expr {atan2($zo($i), [Distance 0 0 $yo($i) $xo($i)])}]
		set dr [expr {$re - [Distance3d $y0e $x0e $z0e $y($i) $x($i) $z($i)]}]
		set sdr2 [expr {$sdr2 + $dr * $dr}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) $z($i) \
			[expr {$y0e + $re * cos($alfa) * sin($delta) - $y($i)}] \
			[expr {$x0e + $re * cos($alfa) * cos($delta) - $x($i)}] \
			[expr {$z0e + $re * sin($alfa) - $z($i)}] $dr]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdr2 / $n)}]]
}

#
#	Calculatate best fit sphere with given radius, iteration is used
#		y = y0 + r * cos(alfa) * sin(delta)
#		x = x0 + r * cos(alfa) * cos(delta)
#		z = z0 + r * sin(alfa)
#	y0, x0, z0 are unknowns (alfa, delta is calculated?)
#	@param plist list of point numbers to use
#	@param r the given radius
proc SphereRegR {plist r} {
	global geoEasyMsg
	global decimals
	global reglist
	global maxIteration epsReg

	set n [expr {double([llength $plist])}]
	set i 0
	set sx 0
	set sy 0
	set sz 0
#	coords of points
	foreach pn $plist {
		set coords [GetCoord $pn {37 38 39}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set z($i) [GetVal 39 $coords]
		set sx [expr {$sx + $x($i)}]
		set sy [expr {$sy + $y($i)}]
		set sz [expr {$sz + $z($i)}]
		incr i
	}
#	approximate center is the weight point
	set y0e [expr {$sy / $n}]
	set x0e [expr {$sx / $n}]
	set z0e [expr {$sz / $n}]
	#set re [Distance3d $y0e $x0e $z0e $x(0) $y(0) $z(0)]
	set iteration 0
	while 1 {
		incr iteration
		set sumcossin 0
		set sumcoscos 0
		set sumsin 0
		# relative coordinates to center of sphere
		for {set i 0} {$i < $n} {incr i} {
			set yo($i) [expr {$y($i) - $y0e}]
			set xo($i) [expr {$x($i) - $x0e}]
			set zo($i) [expr {$z($i) - $z0e}]
			set delta [Bearing 0 0 $yo($i) $xo($i)]
			set alfa [expr {atan2($zo($i), [Distance 0 0 $yo($i) $xo($i)])}]
			set w1 [expr {$yo($i) - $r * cos($alfa) * sin($delta)}]
			set w2 [expr {$xo($i) - $r * cos($alfa) * cos($delta)}]
			set w3 [expr {$zo($i) - $r * sin($alfa)}]
			set sumcossin [expr {$sumcossin + $w1}]
			set sumcoscos [expr {$sumcoscos + $w2}]
			set sumsin [expr {$sumsin + $w3}]
		}
		# set up normal equation
		set dy0 [expr {$sumcossin / $n}]
		set dx0 [expr {$sumcoscos / $n}]
		set dz0 [expr {$sumsin / $n}]
		if {[expr {abs($dy0)}] < $epsReg && [expr {abs($dx0)}] < $epsReg && \
			[expr {abs($dz0)}] < $epsReg || $iteration > $maxIteration} {
				break
		}
		set y0e [expr {$y0e + $dy0}]
		set x0e [expr {$x0e + $dx0}]
		set z0e [expr {$z0e + $dz0}]
	}
	GeoLog1
	GeoLog "[lindex $reglist 6] $geoEasyMsg(fixedRadius)"
	GeoLog1 [format $geoEasyMsg(head0SphereReg) [format %.${decimals}f $y0e] [format %.${decimals}f $x0e] [format %.${decimals}f $z0e] [format %.${decimals}f $r]]
	if {$iteration > $maxIteration} {
		GeoLog1 [format $geoEasyMsg(head2CircleReg) $maxIteration $epsReg]
	}
	GeoLog1
	GeoLog1 $geoEasyMsg(head1SphereReg)
	set sdr2 0
	for {set i 0} {$i < $n} {incr i} {
		set delta [Bearing 0 0 $yo($i) $xo($i)]
		set alfa [expr {atan2($zo($i), [Distance 0 0 $yo($i) $xo($i)])}]
		set dr [expr {$r - [Distance3d $y0e $x0e $z0e $y($i) $x($i) $z($i)]}]
		set sdr2 [expr {$sdr2 + $dr * $dr}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) $z($i) \
			[expr {$y0e + $r * cos($alfa) * sin($delta) - $y($i)}] \
			[expr {$x0e + $r * cos($alfa) * cos($delta) - $x($i)}] \
			[expr {$z0e + $r * sin($alfa) - $z($i)}] $dr]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdr2 / $n)}]]
}

#
#	3D regression line, iteration
#	@param plist list of point numbers to use
proc Line3DReg {plist} {
	global geoEasyMsg
	global decimals
	global reglist
	global maxIteration epsReg

	set n [expr {double([llength $plist])}]
#	coords of points
	set i 0
	set sx 0
	set sy 0
	set sz 0
	foreach pn $plist {
		set coords [GetCoord $pn {37 38 39}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set z($i) [GetVal 39 $coords]
		set sx [expr {$sx + $x($i)}]
		set sy [expr {$sy + $y($i)}]
		set sz [expr {$sz + $z($i)}]
		incr i
	}
	# weight point, line goes through
	set x0 [expr {$sx / $n}]
	set y0 [expr {$sy / $n}]
	set z0 [expr {$sz / $n}]
	# move origin to weightpoint
	for {set i 0} {$i < $n} {incr i} {
		set x($i) [expr {$x($i) - $x0}]
		set y($i) [expr {$y($i) - $y0}]
		set z($i) [expr {$z($i) - $z0}]
	}
	# approximate direction of line (unit vector)
	set s 0
	set i -1
	set n1 [expr {$n - 1}]
	while {$i < $n1 && [expr {abs($s)}] < $epsReg} {
		incr i
		set s [expr {sqrt($y($i) * $y($i) + $x($i) * $x($i) + $z($i) * $z($i))}]
	}
	set ae [expr {$y($i) / $s}]
	set be [expr {$x($i) / $s}]
	set ce [expr {$z($i) / $s}]
	set iteration 0
	while 1 {
		incr iteration
		set exitloop 1
		set stx 0
		set sty 0
		set stz 0
		set st2 0
		for {set i 0} {$i < $n} {incr i} {
			set t [expr {($ae * $y($i) + $be * $x($i) + $ce * $z($i)) / ($ae * $ae + $be * $be + $ce * $ce)}]
			set stx [expr {$stx + $t * $x($i)}]
			set sty [expr {$sty + $t * $y($i)}]
			set stz [expr {$stz + $t * $z($i)}]
			set st2 [expr {$st2 + $t * $t}]
		}
		set a [expr {$sty / $st2}]
		set b [expr {$stx / $st2}]
		set c [expr {$stz / $st2}]
		if {[expr {abs($a - $ae)}] < $epsReg &&
			[expr {abs($b - $be)}] < $epsReg &&
			[expr {abs($c - $ce)}] < $epsReg ||
			$iteration > $maxIteration} { break }
		set ae $a
		set be $b
		set ce $c
	}
	GeoLog1
	GeoLog [lindex $reglist 7]
	GeoLog1 [format $geoEasyMsg(head0Line3DReg) [format %.${decimals}f $y0] $a [format %.${decimals}f $x0] $b [format %.${decimals}f $z0] $c]
	if {$iteration > $maxIteration} {
		GeoLog1 [format $geoEasyMsg(head2CircleReg) $maxIteration $epsReg]
	}
	GeoLog1
	GeoLog1 $geoEasyMsg(head1Line3DReg)
	set sd2 0
	for {set i 0} {$i < $n} {incr i} {
		set t [expr {($a * $y($i) + $b * $x($i) + $c * $z($i)) / ($a * $a + $b * $b + $c * $c)}]
		set dy [expr {$a * $t - $y($i)}]
		set dx [expr {$b * $t - $x($i)}]
		set dz [expr {$c * $t - $z($i)}]
		set sd2 [expr {$sd2 + $dy * $dy + $dx * $dx + $dz * $dz}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] [expr {$y($i) + $y0}] [expr {$x($i) + $x0}] [expr {$z($i) + $z0}]\
			$dy $dx $dz [Distance3d 0 0 0 $dy $dx $dz]]
	}
	GeoLog1
	GeoLog1 [format "RMS %.${decimals}f" [expr {sqrt($sd2 / $n)}]]
}

#
#	3D regression line, iteration
#	OBSOLATE
#	@param plist list of point numbers to use
proc Line3DRegOld {plist} {
	global geoEasyMsg
	global decimals
	global reglist
	global maxIteration epsReg

	set n [expr {double([llength $plist])}]
#	coords of points
	set i 0
	foreach pn $plist {
		set coords [GetCoord $pn {37 38 39}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set z($i) [GetVal 39 $coords]
		incr i
	}
	# approximate values
	set y0e $y(0)
	set x0e $x(0)
	set z0e $z(0)
	set ae [expr {$y(1) - $y0e}]
	set be [expr {$x(1) - $x0e}]
	set ce [expr {$z(1) - $z0e}]
	set iteration 0
	while 1 {
		incr iteration
		set exitloop 1
		set st 0
		set st2 0
		set sly1 0
		set sly2 0
		set slx1 0
		set slx2 0
		set slz1 0
		set slz2 0
		for {set i 0} {$i < $n} {incr i} {
			set k 0
			set tw 0
			if {[expr {abs($ae)}] > $epsReg} {
				set tw [expr {$tw + ($y($i) - $y0e) / $ae}]
				incr k
			}
			if {[expr {abs($be)}] > $epsReg} {
				set tw [expr {$tw + ($x($i) - $x0e) / $be}]
				incr k
			}
			if {[expr {abs($ce)}] > $epsReg} {
				set tw [expr {$tw + ($z($i) - $z0e) / $ce}]
				incr k
			}
			if {$k == 0} {
				tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(cantSolve) \
					error 0 OK
				return
			}
			set t [expr {$tw / $k}]
			set st [expr {$st + $t}]
			set st2 [expr {$st2 + $t * $t}]
			set w [expr {$y($i) - $y0e - $ae * $t}]
			set sly1 [expr {$sly1 + $w}]
			set sly2 [expr {$sly2 + $w * $t}]
			set w [expr {$x($i) - $x0e - $be * $t}]
			set slx1 [expr {$slx1 + $w}]
			set slx2 [expr {$slx2 + $w * $t}]
			set w [expr {$z($i) - $z0e - $ce * $t}]
			set slz1 [expr {$slz1 + $w}]
			set slz2 [expr {$slz2 + $w * $t}]
		}
		set a(0,0) $n
		set a(1,0) $st
		set a(0,1) $st
		set a(1,1) $st2
		set b(0) $sly1
		set b(1) $sly2
		if {[catch {GaussElimination a b 2}]} {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(cantSolve) \
				error 0 OK
			return
		}
		if {$b(0) > $epsReg || $b(1) > $epsReg} { set exitloop 0 }
		set y0e [expr {$y0e + $b(0)}]
		set ae [expr {$ae + $b(1)}]
		set a(0,0) $n
		set a(1,0) $st
		set a(0,1) $st
		set a(1,1) $st2
		set b(0) $slx1
		set b(1) $slx2
		if {[catch {GaussElimination a b 2}]} {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(cantSolve) \
				error 0 OK
			return
		}
		if {$b(0) > $epsReg || $b(1) > $epsReg} { set exitloop 0 }
		set x0e [expr {$x0e + $b(0)}]
		set be [expr {$be + $b(1)}]
		set a(0,0) $n
		set a(1,0) $st
		set a(0,1) $st
		set a(1,1) $st2
		set b(0) $slx1
		set b(1) $slx2
		if {[catch {GaussElimination a b 2}]} {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(cantSolve) \
				error 0 OK
			return
		}
		if {$b(0) > $epsReg || $b(1) > $epsReg} { set exitloop 0 }
		set z0e [expr {$z0e + $b(0)}]
		set ce [expr {$ce + $b(1)}]
		if {$exitloop || $iteration > $maxIteration} { break }
	}
	GeoLog1
	GeoLog [lindex $reglist 10]
	GeoLog1 [format $geoEasyMsg(head0Line3DReg) [format %12.${decimals}f $y0e] $ae [format %12.${decimals}f $x0e] $be [format %12.${decimals}f $z0e] $ce]
	if {$iteration > $maxIteration} {
		GeoLog1 [format $geoEasyMsg(head2CircleReg) $maxIteration $epsReg]
	}
	GeoLog1
	GeoLog1 $geoEasyMsg(head1Line3DReg)
	for {set i 0} {$i < $n} {incr i} {
		set k 0
		set tw 0
		if {[expr {abs($ae)}] > $epsReg} {
			set tw [expr {$tw + ($y($i) - $y0e) / $ae}]
			incr k
		}
		if {[expr {abs($be)}] > $epsReg} {
			set tw [expr {$tw + ($x($i) - $x0e) / $be}]
			incr k
		}
		if {[expr {abs($ce)}] > $epsReg} {
			set tw [expr {$tw + ($z($i) - $z0e) / $ce}]
			incr k
		}
		if {$k == 0} {
			return
		}
		set t [expr {$tw / $k}]
		set dy [expr {$y0e + $ae * $t - $y($i)}]
		set dx [expr {$x0e + $be * $t - $x($i)}]
		set dz [expr {$z0e + $ce * $t - $z($i)}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) $z($i) \
			$dy $dx $dz [Distance3d 0 0 0 $dy $dx $dz]]
	}
}

#
#	Calculate regression plane Z, X and Z are changed
#		z = a0 + a1 * x + a2 * y  
#	@param plist list of point numbers to use
proc PlaneRegYXZ { plist } {
	global decimals
	global geoEasyMsg
	global reglist
	global PI2
	
#	calculate weight point
	set xs 0
	set ys 0
	set zs 0
	set n [expr {double([llength $plist])}]
	set i 0
#	sum for weight point
	foreach pn $plist {
		set coords [GetCoord $pn {37 38 39}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set z($i) [GetVal 39 $coords]
		set xs [expr {$xs + $x($i)}]
		set ys [expr {$ys + $y($i)}]
		set zs [expr {$zs + $z($i)}]
		incr i
	}
	set xs [expr {$xs / $n}]
	set ys [expr {$ys / $n}]
	set zs [expr {$zs / $n}]
	set kszi_2 0
	set eta_2 0
	set zeta_2 0
	set kszi_eta 0
	set kszi_zeta 0
	set eta_zeta 0
	for {set i 0} {$i < $n} {incr i} {
		set kszi($i) [expr {$y($i) - $ys}]
		set eta($i) [expr {$x($i) - $xs}]
		set zeta($i) [expr {$z($i) - $zs}]
		set kszi_eta [expr {$kszi_eta + $kszi($i) * $eta($i)}]
		set kszi_zeta [expr {$kszi_zeta + $kszi($i) * $zeta($i)}]
		set eta_zeta [expr {$eta_zeta + $eta($i) * $zeta($i)}]
		set kszi_2 [expr {$kszi_2 + $kszi($i) * $kszi($i)}]
		set eta_2 [expr {$eta_2 + $eta($i) * $eta($i)}]
		set zeta_2 [expr {$zeta_2 + $zeta($i) * $zeta($i)}]
	}
	set AA(0,0) $kszi_2
	set AA(0,1) $kszi_eta
	set AA(0,2) $kszi_zeta
	set AA(1,0) $kszi_eta
	set AA(1,1) $eta_2
	set AA(1,2) $eta_zeta
	set AA(2,0) $kszi_zeta
	set AA(2,1) $eta_zeta
	set AA(2,2) $zeta_2
	# look for eigenvalues
	Jacobi AA VV 3
	# look for smallest eigenvalue
	set index 0
	for {set i 0} {$i < 3} {incr i} {
		if {$AA($i,$i) < $AA($index,$index)} {
			set index $i
		}
	}
	set a $VV(0,$index)
	set b $VV(1,$index)
	set c $VV(2,$index)
	# move back from weight point
	set d [expr {-($a * $ys + $b * $xs + $c * $zs)}]
	if {[catch {
		set a0 [expr {-$d / double($c)}]
		set a1 [expr {-$a / double($c)}]
		set a2 [expr {-$b / double($c)}]}]} {
		tk_dialog .msg "Hiba" $geoEasyMsg(planreg) error 0 OK
		exit
	}
	GeoLog1
	GeoLog [lindex $reglist 3]
	GeoLog1 [format $geoEasyMsg(head0PlaneReg) [format "%+.${decimals}f" $a0] $a1 $a2]
#	slope angle and direction
	set dir [Bearing $a1 $a2 0 0]
	set ang [expr {atan(sqrt($a1*$a1+$a2*$a2))}]
	GeoLog1 [format $geoEasyMsg(head00PlaneReg) [DMS $dir] [DMS $ang]]
	GeoLog1
	GeoLog1 $geoEasyMsg(head1PDistReg)
	set sr2 0
#	list residuals
	for {set i 0} {$i < $n} {incr i} {
		set res [PlanePointDist [list $a $b $c $d] [lindex $plist $i]]
		set sr2 [expr {$sr2 + [lindex $res 0] * [lindex $res 0]}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f  %12.${decimals}f  %12.${decimals}f  %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) $z($i) [lindex $res 0] \
			[lindex $res 1] [lindex $res 2] [lindex $res 3]]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sr2 / $n)}]]
}

#
#	Horizontal regression plan z = constant
#	@param plist list of point numbers to use
proc PlaneHReg {plist} {
	global decimals
	global geoEasyMsg
	global reglist

#	calculate weight point
	set xs 0
	set ys 0
	set zs 0
	set n [expr {double([llength $plist])}]
	set i 0
#	sum for weight point
	foreach pn $plist {
		set coords [GetCoord $pn {37 38 39}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set z($i) [GetVal 39 $coords]
		set zs [expr {$zs + $z($i)}]
		incr i
	}
	set zs [expr {$zs / $n}]
	GeoLog1
	GeoLog [lindex $reglist 4]
	GeoLog1 [format $geoEasyMsg(head0HPlaneReg) [format %+.${decimals}f $zs]]
	GeoLog1
	GeoLog1 $geoEasyMsg(head1PlaneReg)
	set sdz2 0
#	list residuals
	for {set i 0} {$i < $n} {incr i} {
		set dz [expr {$zs - $z($i)}]
		set sdz2 [expr {$sdz2 + $dz * $dz}]
		GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
			[lindex $plist $i] $y($i) $x($i) $z($i) $dz]
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdz2 / $n)}]]
}

#
#	Line through two given points a*y+b*x+c=0
#	@param pn1 first point
#	@param pn2 second point
#	@return list of parameters of line
proc Line2D {pn1 pn2} {
	set coords1 [GetCoord $pn1 {37 38}]	
	set coords2 [GetCoord $pn2 {37 38}]	
	set x1 [GetVal 37 $coords1]
	set y1 [GetVal 38 $coords1]
	set x2 [GetVal 37 $coords2]
	set y2 [GetVal 38 $coords2]
	set a [expr {$x2 - $x1}]
	set b [expr {$y1 - $y2}]
	set c [expr {$y2 * $x1 - $x2 * $y1}]
	return [list $a $b $c]
}

#
#	Line and point distance
#	@param l line parameters (a,b,c)
#	@param pn point number
#	@return a list [distance dy dx y x]
proc LinePointDist {l pn} {
	set coords [GetCoord $pn {37 38}]	
	set x [GetVal 37 $coords]
	set y [GetVal 38 $coords]
	set a [lindex $l 0]
	set b [lindex $l 1]
	set c [lindex $l 2]
	# perpendicular line through the point
	set ap $b
	set bp [expr {-$a}]
	set cp [expr {$a * $x - $b * $y}]
	# intersection of the two lines
	set w [expr {double($a * $bp - $b * $ap)}]
	set yi [expr {($b * $cp - $c * $bp) / $w}]
	set xi [expr {($c * $ap - $a * $cp) / $w}]
	# co-ordinate differences
	set dy [expr {$yi - $y}]
	set dx [expr {$xi - $x}]
	# line point distance
	set d [expr {($a * $y + $b * $x + [lindex $l 2]) / sqrt($a * $a + $b * $b)}]
	return [list $d $dy $dx $y $x]
}

#
#
#	Plane through three given points a * y + b * x + c * z + d = 0
#	@param pn1 first point
#	@param pn2 second point
#	@param pn3 third point
#	@return parameters of plane
proc Plane3D {pn1 pn2 pn3} {
	set coords1 [GetCoord $pn1 {37 38 39}]	
	set coords2 [GetCoord $pn2 {37 38 39}]	
	set coords3 [GetCoord $pn3 {37 38 39}]	
	set x1 [GetVal 37 $coords1]
	set y1 [GetVal 38 $coords1]
	set z1 [GetVal 39 $coords1]
	set x2 [GetVal 37 $coords2]
	set y2 [GetVal 38 $coords2]
	set z2 [GetVal 39 $coords2]
	set x3 [GetVal 37 $coords3]
	set y3 [GetVal 38 $coords3]
	set z3 [GetVal 39 $coords3]
	set dx1 [expr {$x1 - $x2}]
	set dy1 [expr {$y1 - $y2}]
	set dz1 [expr {$z1 - $z2}]
	set dx2 [expr {$x3 - $x2}]
	set dy2 [expr {$y3 - $y2}]
	set dz2 [expr {$z3 - $z2}]
	# normal vector (dy1 dx1 dz1) x (dy2 dx2 dz2)
	set a [expr {$dx1 * $dz2 - $dx2 * $dz1}]
	set b [expr {$dy2 * $dz1 - $dy1 * $dz2}]
	set c [expr {$dy1 * $dx2 - $dy2 * $dx1}]
	set d [expr {-$a * $y1 - $b * $x1 - $c * $z1}]
	return [list $a $b $c $d]
}

#
#	Plane and point distance
#	@param p plane parameters (a,b,c,d)
#	@param pn point
#	@return a list [distance dy dx dz y x z]
proc PlanePointDist {p pn} {
	set coords [GetCoord $pn {37 38 39}]	
	set x [GetVal 37 $coords]
	set y [GetVal 38 $coords]
	set z [GetVal 39 $coords]
	set a [lindex $p 0]
	set b [lindex $p 1]
	set c [lindex $p 2]
	set d [lindex $p 3]
	# t parameter for 3D perpenducular line
	set t [expr {-($a * $y + $b * $x + $c * $z + $d) / ($a * $a + $b * $b + $c * $c)}]
	# intersection point
	set dy [expr {$a * $t}]
	set dx [expr {$b * $t}]
	set dz [expr {$c * $t}]
#	set dist1 [expr {sqrt($dy * $dy + $dx * $dx + $dz * $dz)}]

	set dist [expr {($a * $y + $b * $x + $c * $z + $d) / sqrt($a * $a + $b * $b + $c * $c)}]
	return [list $dist $dy $dx $dz $y $x $z]
}

#
#	Main proc for distance from line  or plane
#	Started from menu
#	@param index
proc GeoRegDist {index} {
	global geoEasyMsg
	global decimals

	if {$index == 0} {
		# select points for line
		set plist [lsort -dictionary [GetGiven {37 38}]]
		if {[llength $plist] > 2} {
			set eplist [GeoListbox $plist {0} $geoEasyMsg(lbTitle) 2]
			if {[llength $eplist] == 2} {
				# calculate line eq.
				if {[catch {set l \
						[Line2D [lindex $eplist 0] [lindex $eplist 1]]}]} {
					tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(linreg) \
						error 0 OK
					return
				}
				set rplist [GeoListbox $plist {0} $geoEasyMsg(lbTitle1) -1]
				if {[llength $rplist] == 0} { return }
				GeoLog1
				GeoLog [format $geoEasyMsg(head0LDistReg) \
					[lindex $eplist 0] [lindex $eplist 1]]
				GeoLog1 $geoEasyMsg(head1LDistReg)
				# distance from line
				foreach pn $rplist {
					set r [LinePointDist $l $pn]
					GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
						$pn [lindex $r 3] [lindex $r 4] [lindex $r 0] \
						[lindex $r 1] [lindex $r 2]]
				}
			}
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewCoord) error 0 OK
		}
	} elseif {$index == 1} {
		# select points for plane
		set plist [lsort -dictionary [GetGiven {37 38 39}]]
		if {[llength $plist] > 3} {
			set pplist [GeoListbox $plist {0} $geoEasyMsg(lbTitle) 3]
			if {[llength $pplist] == 3} {
				# calculate plane eq.
				if {[catch {set p \
						[Plane3D [lindex $pplist 0] [lindex $pplist 1] \
						[lindex $pplist 2]]}]} {
					tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(planreg) \
						error 0 OK
				}
				set rplist [GeoListbox $plist {0} $geoEasyMsg(lbTitle1) -1]
				if {[llength $rplist] == 0} { return }
				GeoLog1
				GeoLog [format $geoEasyMsg(head0PDistReg) \
					[lindex $pplist 0] [lindex $pplist 1] [lindex $pplist 2]]
				GeoLog1 $geoEasyMsg(head1PDistReg)
				foreach pn $rplist {
					set r [PlanePointDist $p $pn]
					GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
						$pn [lindex $r 4] [lindex $r 5] [lindex $r 6] \
						[lindex $r 0] [lindex $r 1] [lindex $r 2] [lindex $r 3]]
				}
			}
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewCoord) error 0 OK
		}
	}
}

#
#	Solve eigenvalue and eigenvector problem with Jacobi method
#	Side effects: elements of a and v matrix are changed
#	@param a name of input matrix/output eigen values
#	@param v name of matrix of eigenvectors
#	@param n size of matrix
proc Jacobi {amatrix vmatrix n} {

	upvar $amatrix a
	upvar $vmatrix v

	if {$n < 2} {
		return 1
	}
	set sum 0
	set tol 1e-30	;# tolerance to be zero
	#initial eigenvectors
	for {set i 0} {$i < $n} {incr i} {
		for {set j 0} {$j < $n} {incr j} {
			set v($i,$j) 0.0
			set sum [expr {$sum + abs($a($i,$j))}]
		}
		set v($i,$i) 1.0
	}
	if {$sum <= 0.0} {
		return 2	;# no positive semi definit
	}
	set sum [expr {double($sum) / $n / $n}]
	# reduce the matrix diagonal
	set ok 1
	while {$ok} {
		set ssum 0.0
		set amax 0.0
		for {set j 1} { $j < $n} {incr j} {
			for {set i 0} {$i < $j && $j < $n} {incr i} {
				# check if a(i,j) to be reduced
				set aa [expr {abs($a($i,$j))}]
				if {$aa > $amax} {
					set amax $aa
				}
				set ssum [expr {$ssum + $aa}]
				if {$aa >= [expr {0.1 * $amax}]} {
					# calculate rotational angle
					set aa [expr {atan2(2.0*$a($i,$j),$a($i,$i) - $a($j,$j)) / 2.0}]
					set si [expr {sin($aa)}]
					set co [expr {cos($aa)}]
					# modify i and j columns
					for {set k 0} {$k < $n} {incr k} {
						set tt $a($k,$i)
						set a($k,$i) [expr {$co * $tt + $si * $a($k,$j)}]
						set a($k,$j) [expr {-$si * $tt + $co * $a($k,$j)}]
						set tt $v($k,$i)
						set v($k,$i) [expr {$co * $tt + $si * $v($k,$j)}]
						set v($k,$j) [expr {-$si * $tt + $co * $v($k,$j)}]
					}
					# modify diagonal terms
					set a($i,$i) [expr {$co * $a($i,$i) + $si * $a($j,$i)}]
					set a($j,$j) [expr {-$si * $a($i,$j) + $co * $a($j,$j)}]
					set a($i,$j) 0.0
					# make a matrix symmetrical
					for {set k 0} {$k < $n} {incr k} {
						set a($i,$k) $a($k,$i)
						set a($j,$k) $a($k,$j)
					}
				}
			}
		}
		# check for convergence
		if {[expr {abs($ssum) / $sum}] < $tol} {
			set ok 0
		}
	}
	return 0
}

#
#	Calculatate best fit vertical paraboloid, iteration is used
#		y = y0 + a * sqrt(t) * sin(delta)
#		x = x0 + a * sqrt(t) * cos(delta)
#		z = z0 + t * sin(alfa)
#	y0, x0, z0 and a are unknowns (alfa, delta, t is calculated from coords)
#	@param plist list of point numbers to use
proc ParabReg {plist} {
	global geoEasyMsg
	global decimals
	global reglist
	global maxIteration epsReg

	set n [expr {double([llength $plist])}]
	set i 0
	set sx 0
	set sy 0
	set sz 0
#	coords of points
	foreach pn $plist {
		set coords [GetCoord $pn {37 38 39}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set z($i) [GetVal 39 $coords]
		set sx [expr {$sx + $x($i)}]
		set sy [expr {$sy + $y($i)}]
		set sz [expr {$sz + $z($i)}]
		incr i
	}
#	approximate center is the weight point
	set y0e [expr {$sy / $n}]
	set x0e [expr {$sx / $n}]
	set z0e [expr {$sz / $n}]
	set ae 1
	set iteration 0
	while 1 {
		incr iteration
		set sumw1 0
		set sumw2 0
		set sumt 0
		set sumb1 0
		set sumb2 0
		set sumb3 0
		set sumb4 0
		# relative coordinates to center of paraboloid
		for {set i 0} {$i < $n} {incr i} {
			set yo($i) [expr {$y($i) - $y0e}]
			set xo($i) [expr {$x($i) - $x0e}]
			set zo($i) [expr {$z($i) - $z0e}]
			set t [expr {$z($i) - $z0e}]
			set delta [Bearing 0 0 $yo($i) $xo($i)]
			if {$t >= 0} {
				set w1 [expr {sqrt($t) * sin($delta)}]
				set w2 [expr {sqrt($t) * cos($delta)}]
			} else {
				set w1 [expr {-sqrt(-$t) * sin($delta)}]
				set w2 [expr {-sqrt(-$t) * cos($delta)}]
			}
			set sumw1 [expr {$sumw1 + $w1}]
			set sumw2 [expr {$sumw2 + $w2}]
			set sumt [expr {$sumt + $t}]
			set v1 [expr {$yo($i) - $ae * $w1}]
			set v2 [expr {$xo($i) - $ae * $w2}]
			set v3 [expr {$zo($i) - $t}]
			set sumb1 [expr {$sumb1 + $v1}]
			set sumb2 [expr {$sumb2 + $v2}]
			set sumb3 [expr {$sumb3 + $v3}]
			set sumb4 [expr {$sumb4 + $w1 * $v1 + $w2 * $v2}]
		}
		# set up normal equation
		set a(0,0) $n
		set a(0,1) 0
		set a(0,2) 0
		set a(0,3) $sumw1
		set a(1,0) 0
		set a(1,1) $n
		set a(1,2) 0
		set a(1,3) $sumw2
		set a(2,0) 0
		set a(2,1) 0
		set a(2,2) $n
		set a(2,3) 0
		set a(3,0) $a(0,3)
		set a(3,1) $a(1,3)
		set a(3,2) $a(2,3)
		set a(3,3) $sumt
		set b(0) $sumb1
		set b(1) $sumb2
		set b(2) $sumb3
		set b(3) $sumb4
		GaussElimination a b 4
		if {[expr {abs($b(0))}] < $epsReg && [expr {abs($b(1))}] < $epsReg && \
			[expr {abs($b(2))}] < $epsReg && \
			[expr {abs($b(3) - $re)}] < $epsReg || $iteration > $maxIteration} {
				break
		}
		set y0e [expr {$y0e + $b(0)}]
		set x0e [expr {$x0e + $b(1)}]
		set z0e [expr {$z0e + $b(2)}]
		set ae [expr {$ae + $b(3)}]
	}
	set y0e [expr {$y0e + $b(0)}]
	set x0e [expr {$x0e + $b(1)}]
	set z0e [expr {$z0e + $b(2)}]
	set re [expr {$re + $b(3)}]
	GeoLog1
	GeoLog [lindex $reglist 8]
	GeoLog1 [format $geoEasyMsg(head0ParabReg) [format %.${decimals}f $y0e] [format %.${decimals} $x0e] [format %.${decimals}f $z0e] [format %.${decimals} $ae]]
	if {$iteration > $maxIteration} {
		GeoLog1 [format $geoEasyMsg(head2CircleReg) $maxIteration $epsReg]
	}
	GeoLog1
	GeoLog1 $geoEasyMsg(head1ParabReg)
	for {set i 0} {$i < $n} {incr i} {
#		set delta [Bearing $y0e $x0e $y($i) $x($i)]
		set delta [Bearing 0 0 $yo($i) $xo($i)]
		set t [expr {$z($i) - $z0e}]
	}
}

#
# fit parallel lines
# @param alist list of points on first line
# @param blist list of points on second line
proc ParLin {alist blist} {
	global geoEasyMsg geoCodes
	global decimals
	global reglist
#	calculate weight point of first
	set xs 0
	set ys 0
	set n [expr {double([llength $alist])}]
	set i 0
#	sum for weight point
	foreach pn $alist {
		set coords [GetCoord $pn {37 38}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set xs [expr {$xs + $x($i)}]
		set ys [expr {$ys + $y($i)}]
		incr i
	}
	set xs [expr {$xs / $n}]
	set ys [expr {$ys / $n}]

#	calculate weight point of second
	set xs1 0
	set ys1 0
	set n1 [expr {double([llength $blist])}]
#	sum for weight point
	foreach pn $blist {
		set coords [GetCoord $pn {37 38}]
		set x($i) [GetVal 37 $coords]
		set y($i) [GetVal 38 $coords]
		set xs1 [expr {$xs1 + $x($i)}]
		set ys1 [expr {$ys1 + $y($i)}]
		incr i
	}
	set xs1 [expr {$xs1 / $n1}]
	set ys1 [expr {$ys1 / $n1}]
	# offset of weight points
	set dxs [expr {$xs1 - $xs}]
	set dys [expr {$ys1 - $ys}]
	set kszi_eta 0
	set kszi_2 0
	set eta_2 0
	for {set i 0} {$i < [expr {$n + $n1}]} {incr i} {
		if {$i >= $n} {
			# shift second line to first
			set x($i) [expr {$x($i) - $dxs}]
			set y($i) [expr {$y($i) - $dys}]
		}
		set kszi [expr {$y($i) - $ys}]
		set eta [expr {$x($i) - $xs}]
		set kszi_eta [expr {$kszi_eta + $kszi * $eta}]
		set kszi_2 [expr {$kszi_2 + $kszi * $kszi}]
		set eta_2 [expr {$eta_2 + $eta * $eta}]
	}
	if {[catch { \
		set fi [expr {0.5 * atan2(2.0 * $kszi_eta, ($kszi_2 - $eta_2))}]}]} {
		tk_dialog .msg "Hiba" $geoEasyMsg(linreg) error 0 OK
		exit
	}
	set m [expr {tan($fi)}]
	set b [expr {$xs - $m * $ys}]
	set b1 [expr {$xs1 - $m * $ys1}]
	GeoLog1
	GeoLog [lindex $reglist 1]
	GeoLog1 [format $geoEasyMsg(head0LinRegX) $m [format %+.${decimals}f $b]]
	GeoLog1 [format $geoEasyMsg(head0LinRegX) $m [format %+.${decimals}f $b1]]
	GeoLog1 "$geoEasyMsg(hAngleReg) [DMS $fi]"
	# distance
	set dist [expr {sqrt(pow(($b * $m - $b1 * $m) / ($m * $m + 1), 2) + \
						 pow(($b1 - $b) / ($m * $m + 1), 2))}]
	GeoLog1 "$geoCodes(11): [format %.${decimals}f $dist]"
	# report correlation
	set correlation [expr {$kszi_eta / ($n - 1.0) / \
		sqrt($eta_2 / ($n - 1.)) / sqrt($kszi_2 / ($n - 1.))}]
	GeoLog1 "$geoEasyMsg(correlation) [format %.${decimals}f $correlation]"
	GeoLog1
	GeoLog1 $geoEasyMsg(head2LinReg)
#	list residuals
	set sdt2 0
	set plist [concat $alist $blist]
	for {set i 0} {$i < [expr {$n + $n1}]} {incr i} {
		set v [expr {($y($i) - $ys) * sin($fi) - \
			($x($i) - $xs) * cos($fi)}]
		set dy [expr {-1 * $v * sin($fi)}]
		set dx [expr {$v * cos($fi)}]
		set dt [expr {hypot($dy, $dx)}]
		set sdt2 [expr {$sdt2 + $dt * $dt}]
		if {$i < $n} {
			GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
				[lindex $plist $i] $y($i) $x($i) $dy $dx $dt]
		} else {
			GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
				[lindex $plist $i] [expr {$y($i) + $dys}] [expr {$x($i) + $dxs}] $dy $dx $dt]
		}
	}
	GeoLog1
	GeoLog1 [format "RMS=%.${decimals}f" [expr {sqrt($sdt2 / $n)}]]
}
