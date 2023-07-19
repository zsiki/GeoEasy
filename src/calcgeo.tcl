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
#	Average of a list
#	@param l list to process
#	@return avarage of list
proc avg {l} {
	set s 0.0
	foreach w $l {
		set s [expr {$s + $w}]
	}
	return [expr {$s / [llength $l]}]
}
#
#	Orientation calculation for a station
#		reference angles are added to geo data set with	code 100/102 
#		the station gets the average of reference angles with code 101/103
#	@param geo name of a loaded geo data set
#	@param lineno line where station start at
#	@param flag bit 0 0/1 selected/all directions are used
#				 bit 1 0/1 fixed coordinates only/appropiate coords also
#				 bit 2 0/1 overwrite/do not overwrite previous orientation
#				 bit 3 0/1 no log/log result
#	@return average orient angle in radians or
#		-2 if no reference direction at all or
#		-1 in case of error
proc Orientation {geo lineno {flag 0}} {
	global geoLoaded
	global geoEasyMsg geoCodes
	global PI2 PI
	global decimals
	global oriDetail

	if {[lsearch -exact $geoLoaded $geo] == -1} {
		return -1
	}
	global ${geo}_geo ${geo}_coo ${geo}_ref
#
#	get station record
#
	if {[info exists ${geo}_geo($lineno)] == 0} {
		return -1
	}
	upvar #0 ${geo}_geo($lineno) station_rec
	set station_pn [GetVal 2 $station_rec]
	if {$station_pn == ""} {
		return -1						;# no point number
	}
	set station_coo [GetCoord $station_pn {38 37} $geo]
	if {$station_coo == "" && ($flag & 2)} {	;# try appropiate coords
		set station_coo [GetCoord $station_pn {138 137} $geo]
	}
	if {$station_coo == ""} {
		return -1						;# no coordinate for station
	}
	# station has orientation and not to overwrite ?
	if {($flag & 2)} {		;# appropiate values included ?
		set prev_ori [GetVal {101 103} $station_rec]
	} else {
		set prev_ori [GetVal 101 $station_rec]
	}
	if {($flag & 4) && $prev_ori != ""} {
		return $prev_ori						;# return previous orientation
	}
	# remove orientation angles
	set station_rec [DelVal {100 101 102 103} $station_rec]
	set slist ""
	if {$oriDetail} {
		set details ""
	} else {
		set details [GetDetail]	;# do not use detail points in orientation
	}
	for {set i [expr {$lineno + 1}]} {1} {incr i} {
		if {[info exists ${geo}_geo($i)] == 0} { break }	;# end of data set
		upvar #0 ${geo}_geo($i) buf 
		if {[GetVal 2 $buf] != ""} { break }			;# next station reached
		set ref_pn [GetVal {62 5} $buf]
		if {$ref_pn != "" && ([GetVal 62 $buf] != "" || \
				[lsearch -exact $details $ref_pn] == -1)} {
			# remove orientation angles
			set buf [DelVal {100 101 102 103} $buf]
			set r [GetVal {21 7} $buf]
			if {$r == ""} { continue }					;# no ref angle
			set ref_coo [GetCoord $ref_pn {38 37} $geo]		;# coords of ref p
			if {$ref_coo == "" && ($flag & 2)} {
				;# appr coords of ref point
				set ref_coo [GetCoord $ref_pn {138 137} $geo]
			}
			if {$ref_coo == ""} { continue }				;# no coords for ref
			set b [Bearing [GetVal {38 138} $station_coo] \
				[GetVal {37 137} $station_coo] \
				[GetVal {38 138} $ref_coo] [GetVal {37 137} $ref_coo]]
#			while {$b < 0} { set b [expr {$b + $PI2}] }

			set z [expr {$b - $r}]
			while {$z < 0} {
				set z [expr {$z + $PI2}]
			}
			set d [Distance [GetVal {38 138} $station_coo] \
				[GetVal {37 137} $station_coo] \
				[GetVal {38 138} $ref_coo] [GetVal {37 137} $ref_coo]]
			if {$d > 0.01} {
				lappend slist [list $i $ref_pn $z [string trim [ANG $z]] $d $r $b]
			} else {
				geo_dialog .msg $geoEasyMsg(error) \
					"$geoEasyMsg(samePnt) $station_pn $ref_pn $geo:$lineno" \
					error 0 OK
			}
			
		}
	}
	if {!($flag & 1)} {
		set slist [GeoListbox $slist {3 1} $geoEasyMsg(lbTitle1) -1]
	}
	set nz [llength $slist]
	if {$nz > 0} {
		set sz 0
		set cz 0
		set sd 0
		foreach items $slist {
			set ind [lindex $items 0]
			set z [lindex $items 2]
			set d [lindex $items 4]
			set sd [expr {$sd + $d}]
			set sz [expr {$sz + sin($z) * $d}]
			set cz [expr {$cz + cos($z) * $d}]
			if {$flag & 2} {
				lappend ${geo}_geo($ind) [list 102 $z]
			} else {
				lappend ${geo}_geo($ind) [list 100 $z]
			}
		}
		if {[catch {set sz [expr {$sz / $sd}]}] || \
			[catch {set cz [expr {$cz / $sd}]}]} {
			geo_dialog .msg $geoEasyMsg(error) \
				"$geoEasyMsg(noOri2) $station_pn" \
				error 0 OK
			return -1
		}
		set z [expr {atan2 ($sz, $cz)}]					;# average orient angle
		while {$z < 0} {
			set z [expr {$z + $PI2}]
		}
		if {$flag & 2} {
			lappend station_rec [list 103 $z]
		} else {
			lappend station_rec [list 101 $z]
		}
		# log results of orientation?
		if {$flag & 8} {	;# write log
			GeoLog1
			GeoLog "$geoEasyMsg(menuPopupOri) - $station_pn"
			GeoLog1 $geoEasyMsg(head1Ori)

			foreach items $slist {
				set emax [expr {int(24.0 / sqrt([lindex $items 4] / 1000.0))}]
				set e [expr {[Rad2Sec [lindex $items 2]] - [Rad2Sec $z]}]
				if {$e > [Rad2Sec $PI]} { set e [expr {$e - [Rad2Sec $PI2]}] }
				if {$e < "-[Rad2Sec $PI]"} { set e [expr {$e + [Rad2Sec $PI2]} ]}
				set E [expr {$e / 206264.8 * [lindex $items 4]}]
				GeoLog1 [format "%-10s %-10s %11s %11s %11s   %8.${decimals}f %4d %4d %8.${decimals}f"\
					[lindex $items 1] \
					[string range [GetPCode [lindex $items 1] 1] 0 9]\
					[ANG [lindex $items 5]] [ANG [lindex $items 6]] \
					[ANG [lindex $items 2]] [lindex $items 4] \
					[expr {int($e)}] $emax $E]
				if {[expr {abs($e)}] > $emax} {
					geo_dialog .msg $geoEasyMsg(warning) \
						"$geoEasyMsg(tajErr) $station_pn - [lindex $items 1]" \
						warning 0 OK
				}
			}
			GeoLog1 [format "%-46s%11s" $geoCodes(101) [ANG $z]]
		}
		return $z
	} else {
		return -2	;# no reference direction at all
	}
	return -1
}

#
#	Change angle from degree.mmss to radian
#	@param deg angle in degree minute second (like 12.4527)
#             less then 4 decimals cause error
#			  more then 4 decimals can be after the decimal point
proc Deg2Rad {deg} {
	global PI

	if {[regsub "^0*(\[0-9\]+)\.\[0-9\]*$" $deg \\1 d] &&
		[regsub "^\[0-9\]*\.(\[0-9\]\[0-9\]).*$" $deg \\1 m] &&
		[regsub "^\[0-9\]*\.\[0-9\]\[0-9\](\[0-9\]\[0-9\])\[0-9\]*$" $deg \\1 s] &&
		[regsub "^\[0-9\]*\.\[0-9\]\[0-9\]\[0-9\]\[0-9\](\[0-9\]*$)" $deg \\1 ts]
		} {
		# remove leading 0 from minute & second
		regsub "^0*(\[0-9\]+)$" $m \\1 m
		regsub "^0*(\[0-9\]+)$" $s \\1 s
		# add tenth of seconds
		set s "$s.$ts"
		return [expr {($d + $m / 60.0 + $s / 3600.0) / 180.0 * $PI}]
	} else {
		return ?
	}
}

#
#	Calculate whole circle bearing counter clockwise from north
#	@param xa,ya coordinates of station
#	@param xb,yb coordinates of reference point
#	@return whole circle bearing
proc Bearing {xa ya xb yb} {
global PI2
	
	set dx [expr {$xb - $xa}]
	set dy [expr {$yb - $ya}]
	set delta [expr {atan2($dx, $dy)}]
	while {$delta < 0} { set delta [expr {$delta + $PI2}] }
	return $delta
}

#
#	Calculate distance between two points
#	@param xa,ya coordinates of station
#	@param xb,yb coordinates of reference point
#	@return 2D distance
proc Distance {xa ya xb yb} {

	return [expr {hypot($xb - $xa, $yb - $ya)}]
}

#
#	Calculate slope distance between two points
#	@param xa,ya,za coordinates of station
#	@param xb,yb,zb coordinates of reference point
#	@param ih instrument height (optional, default 0)
#	@param th target height (optional, default 0)
proc Distance3d {xa ya za xb yb zb {ih 0} {th 0}} {

	return [expr {hypot(hypot($xb - $xa, $yb - $ya), \
		($zb + $th) - ($za + $ih))}]
}

#
#	Calculate zenith angle between two points
#	@param xa,ya,za coordinates of station
#	@param xb,yb,zb coordinates of reference point
#	@param ih instrument height (optional, default 0)
#	@param th target height (optional, default 0)
#	@return zenith angle in radian
proc ZenithAngle {xa ya za xb yb zb {ih 0} {th 0}} {
	global PI

	set d [expr {hypot($xb - $xa, $yb - $ya)}]
	set dz [expr {($zb + $th) - ($za + $ih)}]
	if {[expr {abs($dz)}] > 1e-4} {
		set z [expr {atan($d / $dz)}]
		if {$dz < 0} {set z [expr {$PI + $z}]}
		return $z
	}
	return [expr {$PI / 2.0}]
}

#
#	Calculate intersection of two lines solving
#		xa + t1 * sin dap = xb + t2 * sin dbp
#		ya + t1 * cos dap = yb + t2 * cos dbp
#	@param xa first coordinate of first point
#	@param ya second coordinate of first point
#	@param xb first coordinate of second point
#	@param yb second coordinate of second point
#	@param dap direction (bearing) from first point to new point
#	@param dbp direction (bearing) from second point to new point
#	@return xp yp as a list or an empty list if lines are near paralel
proc Intersec {xa ya xb yb dap dbp} {

	set sdap [expr {sin($dap)}]
	set cdap [expr {cos($dap)}]
	set sdbp [expr {sin($dbp)}]
	set cdbp [expr {cos($dbp)}]
	set det [expr {$sdap * $cdbp - $sdbp * $cdap}]
	if {[catch { set t1 [expr {(($xb - $xa) * $cdbp - ($yb - $ya) * $sdbp) / double($det)}]}]} {
		return ""					;# paralel lines
	}
	set xp [expr {$xa + $t1 * $sdap}]
	set yp [expr {$ya + $t1 * $cdap}]
	return [list $xp $yp]
}

#
#	Calculate circle parameters defined by three points
#	center is the intersection of orthogonals at the midpoints
#	@param x1 first coordinate of first point
#	@param y1 second coordinate of first point
#	@param x2 first coordinate of second point
#	@param y2 second coordinate of second point
#	@param x3 first coordinate of third point
#	@param y3 second coordinate of third point
#	@return center x y and radius as a list or empty list in case of error
#		e.g infinit radius, two points are the same
proc Circle3P {x1 y1 x2 y2 x3 y3} {
	global PI

	set x12 [expr {($x1 + $x2) / 2.0}]		;# midpoints
	set y12 [expr {($y1 + $y2) / 2.0}]
	set x23 [expr {($x2 + $x3) / 2.0}]
	set y23 [expr {($y2 + $y3) / 2.0}]
	set d12 [expr {[Bearing $x1 $y1 $x2 $y2] + $PI / 2.0}]
	set d23 [expr {[Bearing $x2 $y2 $x3 $y3] + $PI / 2.0}]
	set center [Intersec $x12 $y12 $x23 $y23 $d12 $d23]
	if {$center != ""} {
		set r [Distance [lindex $center 0] [lindex $center 1] $x1 $y1]
		lappend center $r
		return $center
	}
	return ""
}

#
#	Calculate circle parameters defined by two points and included angle
#	@param xa first coordinate of first point
#	@param ya second coordinate of first point
#	@param xb first coordinate of second point
#	@param yb second coordinate of second point
#	@param alpha included angle (radian)
#
#	Returns center x y and radius as a list or empty list in case of error
#		e.g infinit radius, two points are the same
proc Circle2P {xa ya xb yb alpha} {

	set t2 [expr {[Distance $xa $ya $xb $yb] / 2.0}]
	set d [expr {$t2 / tan($alpha / 2.0)}]
	set dab [Bearing $xa $ya $xb $yb]
	set x3 [expr {$xa + $t2 * sin($dab) + $d * cos($dab)}]
	set y3 [expr {$ya + $t2 * cos($dab) - $d * sin($dab)}]
	return [Circle3P $xa $ya $xb $yb $x3 $y3]
}

#
#	Calculate intersection of two circles solving 
#		(x - x01)^2 + (y - y01)^2 = r1^2
#		(x - x02)^2 + (y - y02)^2 = r2^2
#	@param x01 first coordinate of first center
#	@param y01 second coordinate of first center
#	@param r1 radius of first circle
#	@param x01 first coordinate of second point
#	@param y01 second coordinate of second point
#	@param r2 radius of second circle
#
#	@return two, one or none intersection as a list
proc IntersecCC {x01 y01 r1 x02 y02 r2} {

	set swap 0
	if {[expr {abs($x02 - $x01)}] < 0.001} {
		set w $x01
		set x01 $y01
		set y01 $w
		set w $x02
		set x02 $y02
		set y02 $w
		set swap 1
	}
	set t [expr {($r1 * $r1 - $x01 * $x01 - $r2 * $r2 + $x02 * $x02 + \
		$y02 * $y02 - $y01 * $y01) / 2.0}]
	set dx [expr {double($x02 - $x01)}]
	set dy [expr {double($y02 - $y01)}]
	if {[expr {abs($dx)}] > 0.001} {
		set a [expr {1.0 + $dy * $dy / $dx / $dx}]
		set b [expr {2.0 * ($x01 * $dy / $dx - $y01 - $t * $dy / $dx / $dx)}]
		set c [expr {$t * $t / $dx / $dx - 2 * $x01 * $t / $dx - $r1 * $r1 + \
			$x01 * $x01 + $y01 * $y01}]
		set d [expr {$b * $b - 4 * $a * $c}]
		if {$d < 0} {
			return ""
		}
		set yp1 [expr {(-$b + sqrt($d)) / 2.0 / $a}]
		set yp2 [expr {(-$b - sqrt($d)) / 2.0 / $a}]
		set xp1 [expr {($t - $dy * $yp1) / $dx}]
		set xp2 [expr {($t - $dy * $yp2) / $dx}]
		if {$swap == 0} {
			return [list $xp1 $yp1 $xp2 $yp2]
		} else {
			return [list $yp1 $xp1 $yp2 $xp2]
		}
	}
	return ""
}

#
#	Calculate intersection of line and circle solving 
#		x = xa + t * sin dap
#		y = ya + t * cos dap
#		(x - x0)^2 + (y - y0)^2 = r^2
#		xa  - first coordinate of point on line
#		ya  - second coordinate of point on line
#		dap	- direction of line
#		x0  - first coordinate of circle center point
#		y0  - second coordinate of circle center point
#		r   - radius
#
#	Returns two, one or none intersection as a list
proc IntersecLC {xa ya dap x0 y0 r} {

	set b [expr {2 * (($ya - $y0) * cos($dap) + ($xa - $x0) * sin($dap))}]
	set t1 [expr {-$b}]		;#[expr {(-$b + sqrt($d)) / 2}]
	set t2 0				;#[expr {(-$b - sqrt($d)) / 2}]
	set xp1 [expr {$xa + $t1 * sin($dap)}]
	set yp1 [expr {$ya + $t1 * cos($dap)}]
	set xp2 $xa				;#[expr {$xa + $t2 * sin($dap)}]
	set yp2 $ya				;#[expr {$ya + $t2 * cos($dap)}]
	return [list $xp1 $yp1 $xp2 $yp2]
}

#
#	-- GeoOri
#	User interface for orientation for a station, if the station was occupied
#	more then once the user must select
#		orientation angles are added to data set
#	@param pn station number
#	@param w handle to widget
#	@param flag see flag for orientation
proc GeoOri {pn w {flag 0}} {
	global geoEasyMsg geoCodes
	global autoRefresh

	if {[GetCoord $pn {38 37}] == ""} {
		if {$flag & 2} {
			if {[GetCoord $pn {138 137}] == ""} {
				geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noOri) \
					warning 0 OK
				return
			}
		} else {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noOri) \
				warning 0 OK
			return
		}
	}
	set slist [GetStation $pn]

	switch -exact [llength $slist] {
		0 {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noOri) \
				warning 0 OK
			return
		}
		1 {
		}
		default {	;# select from occupations
            set vlist [InternalToShort $slist]
			set vlist [GeoListbox $vlist {0 1} $geoEasyMsg(lbTitle3) 1]
			if {[llength $vlist] == 0} {
				return
			}
            set slist [ShortToInternal $vlist]
		}
	}
	set res [Orientation [lindex [lindex $slist 0] 0] \
		[lindex [lindex $slist 0] 1] $flag]
	if {$res < 0} {
		return
	}
	if {$w != ""} {
		global geoRes
		set geoRes($w) [format "%s(%s):%s" $geoCodes(101) $pn [ANG $res]]
	}
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	User interface for intersection for a point if more then one triangles
#	available then the user must select one
#		Coordinates are added to all referenced data set
#	@param pn station number
proc GeoSec {pn {w ""}} {
	global geoEasyMsg
	global decimals
	global autoRefresh

	set res ""
	set slist [GetExtDir $pn]			;# return external directions
    set vlist [InternalToShort $slist]
	switch -exact [llength $slist] {
		0 -
		1 {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noSec) \
				warning 0 OK
			return
		}
		2 -
		default {
			set vlist [GeoListbox $vlist {0 2} $geoEasyMsg(lbTitle) 2]
			if {[llength $vlist] == 0} {
				return
			}
            set slist [ShortToInternal $vlist]
		}
	}
	set arec [lindex $slist 0]
	set brec [lindex $slist 1]
	set res [GeoSec1 $arec $brec]
	if {[llength $res] == 2} {		;# store coords
		StoreCoord $pn [lindex $res 0] [lindex $res 1]
		if {$w != ""} {
			global geoRes
			set geoRes($w) [format "%s: %.${decimals}f %.${decimals}f" $pn \
				[lindex $res 0] [lindex $res 1]]
		}
		set aco [GetCoord [lindex $arec 2] {37 38} [lindex $arec 0]]
		set bco [GetCoord [lindex $brec 2] {37 38} [lindex $brec 0]]
		GeoLog1
		GeoLog $geoEasyMsg(menuPopupSec)
		GeoLog1 $geoEasyMsg(head1Sec)
		GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f %11s" \
			[lindex $arec 2] \
			[string range [GetPCode [lindex $arec 2] 1] 0 9] \
			[GetVal {38} $aco] [GetVal {37} $aco] \
			[ANG [lindex $arec 3]]]
		GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f %11s" \
			[lindex $brec 2] \
			[string range [GetPCode [lindex $brec 2] 1] 0 9] \
			[GetVal {38} $bco] [GetVal {37} $bco] \
			[ANG [lindex $brec 3]]]
		GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f" \
			$pn [string range [GetPCode $pn 1] 0 9] \
			[lindex $res 0] [lindex $res 1]]
		if {$autoRefresh} {
			RefreshAll
		}
	} else {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noCoo) \
			warning 0 OK
	}
}

#
#	Calculate intersection from arec, brec, arec and brec are lists like:
#		{geo_set line_no station_number bearing}
#	If no exact coordinates are available then approximate ones are used
#	@param arec data for station a
#	@param brec data for station b
proc GeoSec1 {arec brec} {

	set a [lindex $arec 2]			;# station numbers
	set b [lindex $brec 2]
	if {$a == $b} { return ""}	;# points must be different
	set acoo [GetCoord $a {38 37} [lindex $arec 0]]
	if {$acoo == ""} {
		set acoo [GetCoord $a {138 137} [lindex $arec 0]]
		if {$acoo == ""} { return "" }	;# no coords
		set xa [GetVal 138 $acoo]
		set ya [GetVal 137 $acoo]
	} else {
		set xa [GetVal 38 $acoo]
		set ya [GetVal 37 $acoo]
	}
	set bcoo [GetCoord $b {38 37} [lindex $brec 0]]
	if {$bcoo == ""} {
		set bcoo [GetCoord $b {138 137} [lindex $brec 0]]
		if {$bcoo == ""} { return "" }	;# no coords
		set xb [GetVal 138 $bcoo]
		set yb [GetVal 137 $bcoo]
	} else {
		set xb [GetVal 38 $bcoo]
		set yb [GetVal 37 $bcoo]
	}
	return [Intersec $xa $ya $xb $yb [lindex $arec 3] [lindex $brec 3]]
}

#
#	Create a station list where pn can be resected
#		{{geo_data_set record_number} {geo_data_set record_number} ... }
#	@param pn station number
#	@return station list
proc GeoResStation {pn} {

	set wst [GetStation $pn]			;# get stations
	set stlist ""
	# remove those occupations where there is no 3 internal directions
	foreach s $wst {
		if {[llength [GetIntDir1 [lindex $s 0] [lindex $s 1]]] > 2} {
			lappend stlist $s
		}
	}
	return $stlist
}

#
#	User interface for resection calculation
#	if more then three direction available then the user must select three
#		Coordinates are added to all referenced data set
#	@param pn station number
#	@param w name of window having status line
#	@return none
proc GeoRes {pn {w ""}} {
	global geoEasyMsg
	global PI2
	global decimals
	global autoRefresh

	set res ""
	# stations we can resect
	set stlist [GeoResStation $pn]
    set vlist [InternalToShort $stlist]
	switch -exact [llength $stlist] {
		0 {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noStn) \
				warning 0 OK
			return
		}
		1 {
		}
		default {
			set vlist [GeoListbox $vlist {0 1} $geoEasyMsg(lbTitle3) 1]
			if {[llength $vlist] == 0} {
				return
			}
            set stlist [ShortToInternal $vlist]
		}
	}
	set slist [GetIntDir1 [lindex [lindex $stlist 0] 0] \
		[lindex [lindex $stlist 0] 1]]			;# return internal directions
    set vlist [InternalToShort $slist]
	switch -exact [llength $slist] {
		0 -
		1 -
		2 {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noRes) \
				warning 0 OK
			return
		}
		3 -
		default {
			set vlist [GeoListbox $vlist {0 2} $geoEasyMsg(lbTitle) 3]
			if {[llength $vlist] == 0} {
				return
			}
            set slist [ShortToInternal $vlist]
		}
	}
	set arec [lindex $slist 0]
	set brec [lindex $slist 1]
	set crec [lindex $slist 2]
	set res [GeoRes1 $arec $brec $crec]
	if {[llength $res] == 2} {		;# store coords
		StoreCoord $pn [lindex $res 0] [lindex $res 1]
		if {$w != ""} {
			global geoRes
			set geoRes($w) [format "%s: %.${decimals}f %.${decimals}f" $pn \
				[lindex $res 0] [lindex $res 1]]
		}
		set aco [GetCoord [lindex $arec 2] {37 38} [lindex $arec 0]]
		set bco [GetCoord [lindex $brec 2] {37 38} [lindex $brec 0]]
		set cco [GetCoord [lindex $crec 2] {37 38} [lindex $crec 0]]
		set alpha [expr {[lindex $brec 3] - [lindex $arec 3]}]
		while {$alpha < 0} { set alpha [expr {$alpha + $PI2}]}
		set beta [expr {[lindex $crec 3] - [lindex $brec 3]}]
		while {$beta < 0} { set beta [expr {$beta + $PI2}]}
		GeoLog1
		GeoLog $geoEasyMsg(menuPopupRes)
		GeoLog1 $geoEasyMsg(head1Res)
		GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f  %11s %11s" \
			[lindex $arec 2] [string range [GetPCode [lindex $arec 2] 1] 0 9] \
			[GetVal 38 $aco] [GetVal 37 $aco] \
			[ANG [lindex $arec 3]] [ANG $alpha]]
		GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f  %11s %11s" \
			[lindex $brec 2] [string range [GetPCode [lindex $brec 2] 1] 0 9] \
			[GetVal 38 $bco] [GetVal 37 $bco] \
			[ANG [lindex $brec 3]] [ANG $beta]]
		GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f  %11s" \
			[lindex $crec 2] [string range [GetPCode [lindex $crec 2] 1] 0 9] \
			[GetVal 38 $cco] [GetVal 37 $cco] \
			[ANG [lindex $crec 3]]]
		GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f" \
			$pn [string range [GetPCode $pn 1] 0 9] \
			[lindex $res 0] [lindex $res 1]]
		if {$autoRefresh} {
			RefreshAll
		}
	} else {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noCoo) \
			warning 0 OK
	}
}

#
#	Calculate resection from arec, brec & crec, lists like
#	{{geo_set line_no point_number horizontal_angle} {...}}
#	@param arec station data
#	@param brec station data
#	@param crec station data
proc GeoRes1 {arec brec crec} {
	set a [lindex $arec 2]			;# station numbers
	set b [lindex $brec 2]
	set c [lindex $crec 2]
	if {$a == $b || $a == $c || $b == $c} {
		return ""
	}
	set acoo [GetCoord $a {38 37} [lindex $arec 0]]
	if {$acoo == ""} {
		set acoo [GetCoord $a {138 137} [lindex $arec 0]]
	}
	set bcoo [GetCoord $b {38 37} [lindex $brec 0]]
	if {$bcoo == ""} {
		set bcoo [GetCoord $b {138 137} [lindex $brec 0]]
	}
	set ccoo [GetCoord $c {38 37} [lindex $crec 0]]
	if {$ccoo == ""} {
		set ccoo [GetCoord $c {138 137} [lindex $crec 0]]
	}
	set angle1 [expr {[lindex $brec 3] - [lindex $arec 3]}]
	set angle2 [expr {[lindex $crec 3] - [lindex $brec 3]}]
	set circ1 [Circle2P [GetVal {38 138} $acoo] [GetVal {37 137} $acoo] \
		[GetVal {38 138} $bcoo] [GetVal {37 137} $bcoo] $angle1]
	set circ2 [Circle2P [GetVal {38 138} $bcoo] [GetVal {37 137} $bcoo] \
		[GetVal {38 138} $ccoo] [GetVal {37 137} $ccoo] $angle2]
	if {[catch { set res [IntersecCC [lindex $circ1 0] [lindex $circ1 1] [lindex $circ1 2] [lindex $circ2 0] [lindex $circ2 1] [lindex $circ2 2]]}]} {
		return ""
	}
	if {[llength $res] == 4} {
#	select the right one from the two intersection points
		if {[expr {abs([GetVal {38 138} $bcoo] - [lindex $res 0])}] < 0.1 &&
				[expr {abs([GetVal {37 137} $bcoo] - [lindex $res 1])}] < 0.1} {
			return [list [lindex $res 2] [lindex $res 3]]
		} else {
			return [list [lindex $res 0] [lindex $res 1]]
		}
	}
	return ""
}

#
#	User interface for arcsection for a point if more then two distances are
#	available then the user must select two of them
#		Coordinates are added to all referenced data set
#	@param pn point number
#	@param w widget
proc GeoArc {pn {w ""}} {
	global geoEasyMsg
	global decimals
	global autoRefresh

	set res ""
	set slist [GetDist $pn]			;# return distances
    set vlist [InternalToShort $slist]
	switch -exact [llength $slist] {
		0 -
		1 {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noArc) \
				warning 0 OK
			return
		}
		2 -
		default {
			set vl [GeoListbox $vlist {0 2 3} $geoEasyMsg(lbTitle) 2]
			if {[llength $vl] == 0} {
				return
			}
            set sl [ShortToInternal $vl]
		}
	}
	set arec [lindex $sl 0]
	set brec [lindex $sl 1]
	set crec ""
	if {[llength $slist] > 2} {	;# choose a third distance for controll
		foreach s $slist {
			if {$s != $arec && $s != $brec} {
				set crec $s
				break
			}
		} else {
			# calculate approximate coordinates if not set
			# it is used to choose from 2 possible solutions
			if {[GetCoord pn {38 37}] == "" && [GetCoord pn {138 137}] == ""} {
				HorizCoo1 $pn 1
			}
		}
	}
	
	set res [GeoArc1 $pn $arec $brec $crec]
	if {[llength $res] == 2} {
		StoreCoord $pn [lindex $res 0] [lindex $res 1]
		if {$w != ""} {
			global geoRes
			set geoRes($w) [format "%s: %.${decimals}f %.${decimals}f" $pn \
				[lindex $res 0] [lindex $res 1]]
		}
		set aco [GetCoord [lindex $arec 2] {37 38} [lindex $arec 0]]
		set bco [GetCoord [lindex $brec 2] {37 38} [lindex $brec 0]]
		GeoLog1
		GeoLog $geoEasyMsg(menuPopupArc)
		GeoLog1 $geoEasyMsg(head1Arc)
		GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f    %8.${decimals}f" \
			[lindex $arec 2] [string range [GetPCode [lindex $arec 2] 1] 0 9] \
			[GetVal 38 $aco] [GetVal 37 $aco] \
			[GetRedDist [lindex $arec 3] [lindex $arec 4]]]
		GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f    %8.${decimals}f" \
			[lindex $brec 2] [string range [GetPCode [lindex $brec 2] 1] 0 9] \
			[GetVal 38 $bco] [GetVal 37 $bco] \
			[GetRedDist [lindex $brec 3] [lindex $brec 4]]]
		GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f" \
			$pn [string range [GetPCode $pn 1] 0 9] \
			[lindex $res 0] [lindex $res 1]]
		if {$autoRefresh} {
			RefreshAll
		}
	} else {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noCoo) \
			warning 0 OK
	}
}

#
#	Calculate arcsection from arec and brec lists like
#	{geo_set line_no point_number distance vertical_angle}
#	@param pn point number to calculate for
#	@param arec data of first distance and point
#	@param brec data of second distance and point
#	@param crec data of third distance and point for choosing from two
#				intersections (optional)
#	@param drec if given crec and drec are internal directions
proc GeoArc1 {pn arec brec {crec ""} {drec ""}} {
	global geoEasyMsg
	global decimals
	global PI PI2

	set a [lindex $arec 2]			;# station numbers
	set b [lindex $brec 2]
	if {$a == $b} { return ""}	;# points must be different
	set acoo [GetCoord $a {38 37} [lindex $arec 0]]
	if {$acoo == ""} {
		set acoo [GetCoord $a {138 137} [lindex $arec 0]]
	}
	set bcoo [GetCoord $b {38 37} [lindex $brec 0]]
	if {$bcoo == ""} {
		set bcoo [GetCoord $b {138 137} [lindex $brec 0]]
	}
	if {$crec != ""} {
		set ccoo [GetCoord [lindex $crec 2] {38 37} [lindex $crec 0]]
		if {$ccoo == ""} {
			set ccoo [GetCoord [lindex $crec 2] {138 137} [lindex $crec 0]]
		}
	}
	if {$drec != ""} {
		set dcoo [GetCoord [lindex $drec 2] {38 37} [lindex $drec 0]]
		if {$dcoo == ""} {
			set dcoo [GetCoord [lindex $drec 2] {138 137} [lindex $drec 0]]
		}
	}
	# calculate horizontal & reduced distance
	set adist [GetRedDist [lindex $arec 3] [lindex $arec 4]]
	set bdist [GetRedDist [lindex $brec 3] [lindex $brec 4]]
	set res [IntersecCC [GetVal {38 138} $acoo] [GetVal {37 137} $acoo] $adist \
		[GetVal {38 138} $bcoo] [GetVal {37 137} $bcoo] $bdist]
	if {[llength $res] == 4} {
		if {$drec != "" && $crec != ""} {
			# select the right one from the two points with angle of internel dirs
			set alfa [expr {[lindex $drec 3] - [lindex $crec 3]}]
			while {$alfa < 0} { set alfa [expr {$alfa + $PI2}] }
			while {$alfa > $PI2} { set alfa [expr {$alfa - $PI2}] }
			set alfa1 [expr {[Bearing [lindex $res 0] [lindex $res 1] [GetVal {38 138} $dcoo] [GetVal {37 137} $dcoo]] - [Bearing [lindex $res 0] [lindex $res 1] [GetVal {38 138} $ccoo] [GetVal {37 138} $ccoo]]}]
			while {$alfa1 < 0} { set alfa1 [expr {$alfa1 + $PI2}] }
			while {$alfa1 > $PI2} { set alfa1 [expr {$alfa1 - $PI2}] }
			if {[expr {abs($alfa1 - $alfa)}] < [expr {$PI / 20.0}]} {
				return [list [lindex $res 0] [lindex $res 1]]
			} else {
				return [list [lindex $res 2] [lindex $res 3]]
			}
		} elseif {$crec != ""} {
		# select the right one from the two points with the 3rd dist
			set cdist [expr {[lindex $crec 3] * sin([lindex $crec 4])}]
			set d1 [Distance [GetVal {38 138} $ccoo] [GetVal {37 137} $ccoo] \
				[lindex $res 0] [lindex $res 1]]
			set d2 [Distance [GetVal {38 138} $ccoo] [GetVal {37 137} $ccoo] \
				[lindex $res 2] [lindex $res 3]]
			if {[expr {abs($d1 - $cdist)}] < [expr {abs($d2 - $cdist)}]} {
				return [list [lindex $res 0] [lindex $res 1]]
			} else {
				return [list [lindex $res 2] [lindex $res 3]]
			}
		} else {
			# try to decide using approximate coordinate
			set coo [GetCoord $pn {38 37}]
			if {$coo == ""} {
				set coo [GetCoord $pn {138 137}]
			}
			if {$coo == ""} {
				# no coord ask the user
				set lst [list [list [format "%.${decimals}f" [lindex $res 0]] \
									[format "%.${decimals}f" [lindex $res 1]]] \
							  [list [format "%.${decimals}f" [lindex $res 2]] \
							  		[format "%.${decimals}f" [lindex $res 3]]]]
				set res [GeoListbox $lst {0 1} "$geoEasyMsg(lbTitle4) $pn"  1]
				return [lindex $res 0]
			} else {
				# distance from approximate/previous position
				set d1 [Distance [GetVal {38 138} $coo] [GetVal {37 137} $coo] \
					[lindex $res 0] [lindex $res 1]]
				set d2 [Distance [GetVal {38 138} $coo] [GetVal {37 137} $coo] \
					[lindex $res 2] [lindex $res 3]]
				if {$d1 < $d2} {
					return [list [lindex $res 0] [lindex $res 1]]
				} else {
					return [list [lindex $res 2] [lindex $res 3]]
				}
			}
		}
	} else {
		return ""
	}
}

#
#	Calculate side section and return coordinates
#	@param pn point number
#	@param arec list of bidirection: pn intdir extdir
#	@param brec list of internal direction: pn intdir
#	@return point coordinates
proc GeoSide1 {pn arec brec} {
	global PI2 PI
	set a [lindex $arec 0]
	set b [lindex $brec 0]
	if {$a == $b} { return ""}	;# points must be different
	set acoo [GetCoord $a {38 37} $a]
	if {$acoo == ""} {
		set acoo [GetCoord $a {138 137} $a]
	}
	set bcoo [GetCoord $b {38 37} $b]
	if {$bcoo == ""} {
		set bcoo [GetCoord $b {138 137} $b]
	}
	# check angle at "a" if a-b-p order is clockwise
	set dab [Bearing [GetVal {38 138} $acoo] [GetVal {37 137} $acoo] \
		[GetVal {38 138} $bcoo] [GetVal {37 137} $bcoo]]
	set da [expr {[lindex $arec 2] - $dab}]
	while {$da < 0} {set da [expr {$da + $PI2}]}
	if {$da < $PI} {	;# clockwise dir
		set c [Circle2P [GetVal {38 138} $acoo] [GetVal {37 137} $acoo] \
			[GetVal {38 138} $bcoo] [GetVal {37 137} $bcoo] \
			[expr {[lindex $brec 1] - [lindex $arec 1]}]]
	} else {			;# counter clockwise exchange a and b
		set c [Circle2P [GetVal {38 138} $bcoo] [GetVal {37 137} $bcoo] \
			[GetVal {38 138} $acoo] [GetVal {37 137} $acoo] \
			[expr {[lindex $arec 1] - [lindex $brec 1]}]]
	}
	if {[catch { set pcoo [IntersecLC [GetVal {38 138} $acoo] [GetVal {37 137} $acoo] [lindex $arec 2] [lindex $c 0] [lindex $c 1] [lindex $c 2]]}]} {
		return ""
	}
	# select from two intersections
	if {[llength $pcoo] >  2} {
		if {[Distance [GetVal {38 138} $acoo] [GetVal {37 137} $acoo] \
			[lindex $pcoo 0] [lindex $pcoo 1]] < \
			[Distance [GetVal {38 138} $acoo] [GetVal {37 137} $acoo] \
			[lindex $pcoo 2] [lindex $pcoo 3]]} {
			set pcoo [lrange $pcoo 2 3]
		} else {
			set pcoo [lrange $pcoo 0 1]
		}
	}
	return $pcoo
}

#
#	Calculate distance side section and return coordinates
#	@param pn point number
#	@param arec list of bidirection: pn intdir distance
#	@param brec list of internal direction: pn intdir
#	@return coordinates of point
proc GeoDistSide1 {pn arec brec} {
	global PI PI2
	set a [lindex $arec 0]
	set b [lindex $brec 0]
	if {$a == $b} { return ""}	;# points must be different
	set acoo [GetCoord $a {38 37} $a]
	if {$acoo == ""} {
		set acoo [GetCoord $a {138 137} $a]
	}
	set bcoo [GetCoord $b {38 37} $b]
	if {$bcoo == ""} {
		set bcoo [GetCoord $b {138 137} $b]
	}
	set alpha [expr {[lindex $brec 1] - [lindex $arec 1]}]
	while {$alpha < 0} { set alpha [expr {$alpha + $PI2}] }
	if {$alpha < $PI} {	;# clockwise a-b-p
		set c [Circle2P [GetVal {38 138} $acoo] [GetVal {37 137} $acoo] \
			[GetVal {38 138} $bcoo] [GetVal {37 137} $bcoo] $alpha]
	} else {	;# counterclockwise
#		set alpha [expr {$PI2 - $alpha}]
		set alpha [expr {-1 * $alpha}]
		set c [Circle2P [GetVal {38 138} $bcoo] [GetVal {37 137} $bcoo] \
			[GetVal {38 138} $acoo] [GetVal {37 137} $acoo] $alpha]
	}
	if {[catch { set pcoo [IntersecCC [GetVal {38 138} $acoo] [GetVal {37 137} $acoo] [lindex $arec 2] [lindex $c 0] [lindex $c 1] [lindex $c 2]]}]} {
		return ""
	}
	if {[llength $pcoo] >  2} {
		# select from two intersections calculating angle from
		# readings and bearings
		set alpha [expr {[lindex $brec 1] - [lindex $arec 1]}]
		while {$alpha < 0} { set alpha [expr {$alpha + $PI2}] }
		while {$alpha > $PI2} { set alpha [expr {$alpha - $PI2}] }
		set da [Bearing [lindex $pcoo 0] [lindex $pcoo 1] \
                        [GetVal {38 138} $acoo] [GetVal {37 137} $acoo]]
#		while {$da < 0} { set da [expr {$da + $PI2}] }
#		while {$da > $PI2} { set da [expr {$da - $PI2}] }
		set db [Bearing [lindex $pcoo 0] [lindex $pcoo 1] \
                        [GetVal {38 138} $bcoo] [GetVal {37 137} $bcoo]]
#		while {$db < 0} { set db [expr {$db + $PI2}] }
#		while {$db > $PI2} { set db [expr {$db - $PI2}] }
		set alpha1 [expr {$db - $da}]
		while {$alpha1 < 0} { set alpha1 [expr {$alpha1 + $PI2}] }
		while {$alpha1 > $PI2} { set alpha1 [expr {$alpha1 - $PI2}] }
		set da [Bearing [lindex $pcoo 2] [lindex $pcoo 3] \
                        [GetVal {38 138} $acoo] [GetVal {37 137} $acoo]]
#		while {$da < 0} { set da [expr {$da + $PI2}] }
#		while {$da > $PI2} { set da [expr {$da - $PI2}] }
		set db [Bearing [lindex $pcoo 2] [lindex $pcoo 3] \
                        [GetVal {38 138} $bcoo] [GetVal {37 137} $bcoo]]
#		while {$db < 0} { set db [expr {$db + $PI2}] }
#		while {$db > $PI2} { set db [expr {$db - $PI2}] }
		set alpha2 [expr {$db - $da}]
		while {$alpha2 < 0} { set alpha2 [expr {$alpha2 + $PI2}] }
		while {$alpha2 > $PI2} { set alpha2 [expr {$alpha2 - $PI2}] }
		# we can deside only if the two solutions are on oposite
		# side of AB line
		if {[expr {abs($alpha1 - $alpha2)}] > 1e-3} {
			if {[expr {abs($alpha - $alpha1)}] < \
				[expr {abs($alpha - $alpha2)}]} {
				set pcoo [lrange $pcoo 0 1]
			} else {
				set pcoo [lrange $pcoo 2 3]
			}
		}
	}
	return $pcoo
}

#
#	USer interface for a  polar point if more then one distances direction
#	pairs are available then the user must select one of them
#		Coordinates are added to all referenced data set
#	@param pn point number
#	@param w widget
proc GeoPol {pn {w ""}} {
	global geoEasyMsg
	global decimals
	global autoRefresh

	set slist [GetPol $pn]
	switch -exact [llength $slist] {
		0 {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noPol) \
				warning 0 OK
			return
		}
		1 -
		default {
			set slist [GeoListbox $slist {0 1 3 4} $geoEasyMsg(lbTitle) 1]
			if {[llength $slist] == 0} {
				return
			}
		}
	}
	set res [GeoPol1 [lindex $slist 0]]
	if {[llength $res] >= 2} {
		StoreCoord $pn [lindex $res 0] [lindex $res 1]
		if {[llength $res] == 3} {
			StoreZ $pn [lindex $res 2]
		}
		if {$w != ""} {
			global geoRes
			set geoRes($w) [format "%s: %.${decimals}f %.${decimals}f" \
				$pn [lindex $res 0] [lindex $res 1]]
		}
		set lis [lindex $slist 0]
		set co [GetCoord [lindex $lis 0] {37 38}]
		GeoLog1
		GeoLog $geoEasyMsg(menuPopupPol)
		GeoLog1 $geoEasyMsg(head1Pol)
		if {[llength $res] == 2} {
			# no z calculated
			GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f    %8.${decimals}f    %s" \
				[lindex $lis 0] [string range [GetPCode [lindex $lis 0] 1] 0 9] \
				[GetVal 38 $co] [GetVal 37 $co] \
				[lindex $lis 1] [lindex $lis 3]]
			GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f" \
				$pn [string range [GetPCode $pn 1] 0 9] \
				[lindex $res 0] [lindex $res 1]]
		} else {
			# z calculated
			GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f    %8.${decimals}f    %s" \
				[lindex $lis 0] [string range [GetPCode [lindex $lis 0] 1] 0 9] \
				[GetVal 38 $co] [GetVal 37 $co] \
				[lindex $lis 1] [lindex $lis 3]]
			GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f    %8.${decimals}f" \
				$pn [string range [GetPCode $pn 1] 0 9] \
					[lindex $res 0] [lindex $res 1] [lindex $res 2]]
		}
		if {$autoRefresh} {
			RefreshAll
		}
	} else {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noCoo) \
			warning 0 OK
	}
}

#
#	Calculate polar point
#	@param li - list of station point number horiz_dist bearing
proc GeoPol1 {li} {

	set pnr [lindex $li 0]
	set acoo [GetCoord $pnr {38 37}]
	if {$acoo == ""} {
		set acoo [GetCoord $pnr {138 137}]
	}
	set x [expr {[GetVal {38 138} $acoo] + [lindex $li 1] * \
		sin([lindex $li 2])}]
	set y [expr {[GetVal {37 137} $acoo] + [lindex $li 1] * \
		cos([lindex $li 2])}]
	if {[lindex $li 4] == ""} {
		return [list $x $y]
	} else {
		return [list $x $y [lindex $li 4]]
	}
}

#
#	User interface for elevation calculation for point pn
#		Z coordinate is changed
#	@param pn point number
proc GeoEle {pn {w ""}} {
	global geoEasyMsg
	global decimals
	global autoRefresh

	set res ""
	set slist [GetEle $pn]			;# return elevations list like
									;# geo_set line_no pn abs_height hor_dist
	switch -exact [llength $slist] {
		0 {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noEle) \
				warning 0 OK
			return
		}
		1 -
		default {
			set slist [GeoListbox $slist {2 3 4} $geoEasyMsg(lbTitle1) -1]
			if {[llength $slist] == 0} {
				return
			}
		}
	}
	set res [GeoEle1 $slist]
	if {[llength $res] == 1} {		;# store coords
		StoreZ $pn [lindex $res 0]
		if {$w != ""} {
			global geoRes
			set geoRes($w) [format "%s: %.${decimals}f" $pn [lindex $res 0]]
		}
		GeoLog1
		GeoLog $geoEasyMsg(menuPopupEle)
		GeoLog1 $geoEasyMsg(head1Ele)
		foreach lis $slist {
			GeoLog1 [format "%-10s %-10s    %8.${decimals}f      %8.${decimals}f" \
				[lindex $lis 2] [string range [GetPCode [lindex $lis 2] 1] 0 9] \
				[lindex $lis 3] [lindex $lis 4]]
		}
		GeoLog1
		GeoLog1 [format "%-10s %-10s    %8.${decimals}f" \
			$pn [string range [GetPCode $pn 1] 0 9] [lindex $res 0]]
		if {$autoRefresh} {
			RefreshAll
		}
	} else {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noCoo) \
			warning 0 OK
	}
}

#
#	Calculate elevation from list as a weighted average
#	list elements are list of {geo_set line_no pn abs_height hz_dist}
#	@param slist list of elevations
#	@return elevation
proc GeoEle1 {slist} {

	set sumw 0						;# sum of weights
	set sumz 0						;# sum of weight * elevation
	foreach sl $slist {
		set d [lindex $sl 4]
		if {$d > 0.0001} {
			set w [expr {1.0 / $d / $d}]
			set sumw [expr {$sumw + $w}]
			set sumz [expr {$sumz + $w * [lindex $sl 3]}]
		}
	}
	if {$sumw > 0} {
		return [expr {$sumz / $sumw}]
	}
	return ""
}

#
#	List information about point
#	@param pn point number
proc GeoInfo {pn} {
	global geoEasyMsg geoCodes
	global decimals

	set coord [GetCoord $pn ""]		;# get coordinates
	set dlist [GetDist $pn]			;# return distances
	set elist [GetExtDir $pn]		;# return external directions
	set slist [GetStation $pn]		;# get stations
	set wstr ""
	foreach c $coord {
		set code [lindex $c 0]
		if {$code ==  37 || $code ==  38 || $code ==  39 || \
			$code == 137 || $code == 138 || $code == 139} {
			# round co-ordinates to mm
			append wstr "$geoCodes([lindex $c 0]): [format "%.${decimals}f" [lindex $c 1]]\n"
		} else {
			append wstr "$geoCodes([lindex $c 0]): [lindex $c 1]\n"
		}
	}
	append wstr "$geoEasyMsg(nst) [llength $slist]\n"
	append wstr "$geoEasyMsg(ndist) [llength $dlist]\n"
	append wstr "$geoEasyMsg(next) [llength $elist]\n"
	geo_dialog .msg "$geoEasyMsg(info) $pn" $wstr info 0 OK
}

#
#	Calculate final orientations for all stations having no final orientation
#		average orientation angles are stored
#	@param flag bit 0 0/1 selected/all directions are used
#				 bit 1 0/1 fixed coordinates only/appropiate coords also
#				 bit 2 0/1 overwrite/do not overwrite previous orientation
#				 bit 3 0/1 no log/log result
#				 bit 4 0/1 ask for reorient all/do not ask for reorientation
proc GeoFinalOri {{flag 5}} {
	global geoEasyMsg
	global np
	global autoRefresh

	set np 0
	GeoDia .dia $geoEasyMsg(oriDia) np
	set base [GetBaseStations]
	set new 1
	while {$new} {
		set new 0
		set next ""
		foreach pn $base {
			if {[GetCoord $pn {38 37}] == ""} {
				if {$flag & 2} {
					if {[GetCoord $pn {138 137}] == ""} {
						continue
					}
				} else {
					continue
				}
			}
			set slist [GetStation $pn]
			foreach sl $slist {
				set geo [lindex $sl 0]
				set ref [lindex $sl 1]
				upvar #0 ${geo}_geo($ref) buf
				# overwrite previous ?
				if {$flag & 4} {	;# do not overwrite
					if {[GetVal 101 $buf] != "" || \
						($flag & 2) && [GetVal 103 $buf] != ""} {
						continue
					}
				}
				# no orientation angle
				set res [Orientation $geo $ref $flag]
				if {$res >= 0} {
					incr new
					incr np
					update
				} elseif {$res == -1} {
					lappend next $pn
				}
			}
		}
		if {[llength $next] == 0} {
			break
		}
	}
	GeoDiaEnd .dia
	if {[llength $next] > 0} {
		GeoListbox $next 0 $geoEasyMsg(noOri1) 0
	}
	if {$np == 0} {
		if {($flag & 4) == 0} {
			geo_dialog .msg $geoEasyMsg(info) $geoEasyMsg(cantOri) info 0 OK
		} else {
			if {($flag & 16) == 0 && \
				[geo_dialog .msg $geoEasyMsg(info) $geoEasyMsg(readyOri) info \
					0 OK $geoEasyMsg(cancel)] == 0} {
				# repeat orientartions, overwrite previous values
				GeoFinalOri [expr {$flag ^ 4}]
			}
		}
	} else {
		if {$autoRefresh} {
			RefreshAll
		}
	}
}

#
#	Delete all orientation angles 100, 101, 102, 103
#	@param none
#	@return none
proc GeoDelOri {} {
	global geoLoaded
	global geoEasyMsg
	global autoRefresh

    if {[geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(delori) \
        warning 0 OK $geoEasyMsg(cancel)] != 0} {
        return
    }
						
	foreach geo $geoLoaded {
		global ${geo}_geo
		for {set i 0} {$i < [array size ${geo}_geo]} {incr i} {
			upvar #0 ${geo}_geo($i) buf
			set buf [DelVal {100 101 102 103} $buf]
		}
	}
	if {$autoRefresh} {
		# refresh all graphic windows
        GeoDrawAll
	}
}

#
#	Calculate orientations and detail points as polars
#	z is calculated even if x & y known
#	@param all calculate new/all (0/1) detail points 
proc GeoDetail {{all 0}} {
	global geoEasyMsg
	global decimals
	global autoRefresh
	global np

#	first calculate missing final orientations
	GeoFinalOri 29

	if {$all} {
		set detail [lsort -dictionary [GetDetail]]
	} else {
		set detail [lsort -dictionary [GetNewDetail]]
	}
	if {[llength $detail] == 0} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(nodetail) warning 0 OK
		return
	}
	set np 0
	GeoDia .dia $geoEasyMsg(elevDia) np
	set next ""
	GeoLog1
	if {$all == 0} {
		GeoLog $geoEasyMsg(menuCalDet)
	} else {
		GeoLog $geoEasyMsg(menuCalDetAll)
	}
	GeoLog1 $geoEasyMsg(head1Det)
	GeoLog1 $geoEasyMsg(head2Det)
	foreach pn $detail {
		set slist [GetPol $pn]
		if {[llength $slist] > 0} {
			set sl0 [lindex $slist 0]
			set res [GeoPol1 $sl0]
			if {[llength $res] >= 2} {
				if {($all && [llength $res] == 2) || \
					([GetCoord $pn {38 37}] == "" && [llength $res] == 2)} {
					StoreCoord $pn [lindex $res 0] [lindex $res 1]
					GeoLog1 [format \
						"%-10s %-10s %12.${decimals}f %12.${decimals}f              %-10s %10s %8.${decimals}f" \
						$pn [lindex $sl0 5] [lindex $res 0] [lindex $res 1] \
						[lindex $sl0 0] [lindex $sl0 3] [lindex $sl0 1]]
				}
				if {($all && [llength $res] == 3) || \
					([llength $res] == 3 && [GetCoord $pn {39}] == "")} {
					StoreCoord $pn [lindex $res 0] [lindex $res 1]
					StoreZ $pn [lindex $res 2]
					GeoLog1 [format \
						"%-10s %-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %-10s %10s %8.${decimals}f" \
						$pn [lindex $sl0 5] \
						[lindex $res 0] [lindex $res 1] [lindex $res 2] \
						[lindex $sl0 0] [lindex $sl0 3] [lindex $sl0 1]]
				}
				incr np
				update
			} else {
				lappend next $pn
			}
		}
	}
	GeoDiaEnd .dia
	if {[llength $next] > 0} {
		GeoListbox $next 0 $geoEasyMsg(noAppCoo) 0
	}
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	Calculate/recalculate all detail points from station
#	Orientation must be calculated before
#	@param pn station name
proc GeoDetailStation {pn} {
	global decimals
	global geoEasyMsg
	global autoRefresh

	set slist [GetStation $pn]
	switch -exact [llength $slist] {
		0 {
			return
		}
		1 {
		}
		default {	;# select from occupations
			set slist [GeoListbox $slist {0 1} $geoEasyMsg(lbTitle3) 1]
			if {[llength $slist] == 0} {
				return
			}
		}
	}
	set fn [lindex [lindex $slist 0] 0]	;# dataset name
	set station_index [lindex [lindex $slist 0] 1]
	global ${fn}_geo
	# no orientation yet
	if {[GetVal 101 [set ${fn}_geo($station_index)]] == ""} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noOri1) warning 0 OK
		return
	}
	set detail [GetDetail]
	incr station_index
	GeoLog1
	GeoLog "$geoEasyMsg(menuPopupDetail) - $pn"
	GeoLog1 $geoEasyMsg(head1Det)
	GeoLog1 $geoEasyMsg(head2Det)
	while {[info exists ${fn}_geo($station_index)]} {
		set buf [set ${fn}_geo($station_index)]
		if {[GetVal 2 $buf] != ""} {
			break
		}
		set dpn [GetVal 5 $buf]
		if {[lsearch -exact $detail $dpn] != -1} {
			set slist [GetPol $dpn]
			if {[llength $slist] > 0} {
				set sl0 [lindex $slist 0]
				set res [GeoPol1 $sl0]
				if {[llength $res] >= 2} {
					if {[llength $res] == 2} {
						StoreCoord $dpn [lindex $res 0] [lindex $res 1]
						GeoLog1 [format \
							"%-10s %-10s %12.${decimals}f %12.${decimals}f              %-10s %10s %8.${decimals}f" \
							$dpn [lindex $sl0 5] [lindex $res 0] [lindex $res 1] \
							[lindex $sl0 0] [lindex $sl0 3] [lindex $sl0 1]]
					}
					if {[llength $res] == 3} {
						StoreCoord $dpn [lindex $res 0] [lindex $res 1]
						StoreZ $dpn [lindex $res 2]
						GeoLog1 [format \
							"%-10s %-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %-10s %10s %8.${decimals}f" \
							$dpn [lindex $sl0 5] \
							[lindex $res 0] [lindex $res 1] [lindex $res 2] \
							[lindex $sl0 0] [lindex $sl0 3] [lindex $sl0 1]]
					}
				}
			}
		}
		incr station_index
	}
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	User interface to calculates bearing, distance, slope distance and
#	zenith angle to selected points
#	@param pn point number
#	@param w widget
proc GeoBearingDistance {pn {w ""}} {
	global geoEasyMsg
	global PI2
	global decimals

	set pn_coo [GetCoord $pn {37 38}]
	if {$pn_coo == ""} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noAppCoo) \
			warning 0 OK
		return
	}
	set pn_z [GetCoord $pn 39]
	# get all points with coordinates
	set slist [GetGiven {37 38}]
	if {[set i [lsearch -exact $slist $pn]] != -1} {
		set slist [lreplace $slist $i $i]	;# remove pn from list
	}
	set slist [lsort -dictionary $slist]
	set slist [GeoListbox $slist 0 $geoEasyMsg(lbTitle1) -1]
	if {[llength $slist] == 0} { return }
	GeoLog1
	GeoLog $geoEasyMsg(menuPopupBD)
	GeoLog1 $geoEasyMsg(head1Dis)
	foreach s1 $slist {
		set pn1 [lindex $s1 0]
		set pn1_coo [GetCoord $pn1 {37 38}]
		if {$pn1_coo == ""} {
			set pn1_coo [GetCoord $pn1 {137 138}]
			if {$pn1_coo == ""} {
				return
			}
		}
		set pn1_z [GetCoord $pn1 39]
		set b [Bearing [GetVal {38 138} $pn_coo] [GetVal {37 137} $pn_coo] \
			[GetVal {38 138} $pn1_coo] [GetVal {37 137} $pn1_coo]]
#		while {$b < 0} { set b [expr {$b + $PI2}]}
		set d [Distance [GetVal {38 138} $pn_coo] [GetVal {37 137} $pn_coo] \
			[GetVal {38 138} $pn1_coo] [GetVal {37 137} $pn1_coo]]
		set d3d ""
		set za ""
		if {$pn_z != "" && $pn1_z != ""} {
			set d3d [Distance3d [GetVal {38 138} $pn_coo] \
				[GetVal {37 137} $pn_coo] [GetVal {39} $pn_z] \
				[GetVal {38 138} $pn1_coo] [GetVal {37 137} $pn1_coo] \
				[GetVal {39} $pn1_z]]
			set za [ZenithAngle [GetVal {38 138} $pn_coo] \
				[GetVal {37 137} $pn_coo] [GetVal {39} $pn_z] \
				[GetVal {38 138} $pn1_coo] [GetVal {37 137} $pn1_coo] \
				[GetVal {39} $pn1_z]]
		}
		if {$w != ""} {
			global geoRes
			set geoRes($w) [format "%s-%s: %s %.${decimals}f" $pn $pn1 [ANG $b] $d]
		}
		if {$d3d == ""} {
			GeoLog1 [format "%-10s %-10s %11s %8.${decimals}f" \
				$pn $pn1 [ANG $b] $d]
		} else {
			GeoLog1 [format "%-10s %-10s %11s %8.${decimals}f %8.${decimals}f %s" \
				$pn $pn1 [ANG $b] $d $d3d [ANG $za]]
		}
	}
}

#
#	Calculate polar and rectangular steak out values
#	and optionally save to geo data set
#	@param pn point number
#	@param w widget
proc GeoAngle {pn {w ""}} {
	global geoEasyMsg
	global geoCodes
	global fileTypes
	global PI2
	global decimals
	global lastDir
	global _temp_geo _temp_coo geoLoaded

	set pn_coo [GetCoord $pn {37 38}]
	if {$pn_coo == ""} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noAppCoo) \
			warning 0 OK
		return
	}
	# get all points with coordinates
	set slist [GetGiven {37 38}]
	if {[set i [lsearch -exact $slist $pn]] != -1} {
		set slist [lreplace $slist $i $i]	;# remove pn from list
	}
	set slist [lsort -dictionary $slist]
	# get reference direction
	set slist0 [GeoListbox $slist 0 $geoEasyMsg(refTitle) 1]
	set pn1 [lindex [lindex $slist0 0] 0]
	set pn1_coo [GetCoord $pn1 {37 38}]
	if {$pn1_coo == ""} {
		Beep
		return
	}
	GeoLog1
	GeoLog $geoEasyMsg(menuPopupAngle)
	GeoLog1 "$geoCodes(2): $pn   $geoCodes(62): $pn1"
	GeoLog1 $geoEasyMsg(head1Angle)
	set b [Bearing [GetVal {38} $pn_coo] [GetVal {37} $pn_coo] \
		[GetVal {38} $pn1_coo] [GetVal {37} $pn1_coo]]
#	while {$b < 0} { set b [expr {$b + $PI2}]}
	set d [Distance [GetVal {38 138} $pn_coo] [GetVal {37 137} $pn_coo] \
		[GetVal {38} $pn1_coo] [GetVal {37} $pn1_coo]]
	set b1 $b
	set si_b [expr {sin($b)}]
	set co_b [expr {cos($b)}]
	# output reference
	GeoLog1 [format "%-10s %s %8.${decimals}f   0-00-00" \
		$pn1 [ANG $b] $d]

	# remove reference point from list
	if {[set i [lsearch -exact $slist $pn1]] != -1} {
		set slist [lreplace $slist $i $i]	;# remove pn from list
	}

	set slist [GeoListbox $slist 0 $geoEasyMsg(soTitle) -1]
	if {[llength $slist] == 0} { Beep; return }
	set blast $b1
	# reset arrays for new geo data set
	catch {array unset _temp_geo}
	catch {array unset _temp_coo}
	# add station
	set _temp_geo(0) [list "2 $pn"]
	set _temp_geo(1) [list "5 $pn1" "7 0" "11 $d"]
	set _temp_coo($pn) [list [list 5 $pn] [list 38 0] [list 37 0]]
	set d [Distance [GetVal {38} $pn_coo] [GetVal {37} $pn_coo] \
		[GetVal {38} $pn1_coo] [GetVal {37} $pn1_coo]]
	set _temp_coo($pn1) [list [list 5 $pn1] [list 38 $d] [list 37 0]]
	set i 2
	foreach s1 $slist {
		set pn1 [lindex $s1 0]
		set pn1_coo [GetCoord $pn1 {37 38}]
		if {$pn1_coo == ""} {
			Beep
			return
		}
		# polar setting out data
		set b [Bearing [GetVal {38} $pn_coo] [GetVal {37} $pn_coo] \
			[GetVal {38} $pn1_coo] [GetVal {37} $pn1_coo]]
#		while {$b < 0} { set b [expr {$b + $PI2}]}
		set d [Distance [GetVal {38} $pn_coo] [GetVal {37} $pn_coo] \
			[GetVal {38} $pn1_coo] [GetVal {37} $pn1_coo]]
		set alfa [expr {$b - $blast}]
		while {$alfa < 0} { set alfa [expr {$alfa + $PI2}]}
		set alfa0 [expr {$b - $b1}]
		while {$alfa0 < 0} { set alfa0 [expr {$alfa0 + $PI2}]}
		# orthogonal setting out data
		set abc [expr { \
			([GetVal {38} $pn1_coo] - [GetVal {38} $pn_coo]) * $si_b + \
			([GetVal {37} $pn1_coo] - [GetVal {37} $pn_coo]) * $co_b}]
		set ord [expr { \
			-([GetVal {38} $pn1_coo] - [GetVal {38} $pn_coo]) * $co_b + \
			([GetVal {37} $pn1_coo] - [GetVal {37} $pn_coo]) * $si_b}]
		if {$w != ""} {
			global geoRes
			set geoRes($w) [format "%s-%s: %s %.${decimals}f" \
				$pn $pn1 [ANG $b] $d]
		}
		GeoLog1 [format "%-10s %s %8.${decimals}f %s %s \
			%12.${decimals}f %12.${decimals}f" \
			$pn1 [ANG $b] $d [ANG $alfa] [ANG $alfa0] $abc $ord]
		set _temp_geo($i) [list "5 $pn1" "7 $alfa0" "11 $d"]
		set _temp_coo($pn1) [list [list 5 $pn1] [list 38 $abc] [list 37 $ord]]
		incr i
		set blast $b
	}
	set a [geo_dialog .msg $geoEasyMsg(warning) \
		$geoEasyMsg(saveso) warning 0 $geoEasyMsg(yes) $geoEasyMsg(no)]
	if {$a == 0} {
		set typ [list [lindex $fileTypes [lsearch -glob $fileTypes "*.geo*"]]]
		set nn [string trim [tk_getSaveFile -filetypes $typ \
			-initialdir $lastDir -defaultextension ".geo"]]
		# string match is used to avoid silly Windows 10 bug
		if {[string length $nn] == 0 || [string match "after#*" $nn]} {
			return
		}
		set lastDir [file dirname $nn]
		set rn [file rootname $nn]
		set fn [file rootname [file tail $nn]]
		set save_geoLoaded $geoLoaded
		lappend geoLoaded "_temp"
		SaveGeo "_temp" $rn
		set geoLoaded $save_geoLoaded
	}
}

#
#	User interface to calculate intersection of two lines
proc GeoLineLine {} {
	global geoEasyMsg
	global geoCodes
	global autoRefresh

	# get all points with coordinates
	set slist [GetGiven {37 38}]
	set slist [lsort -dictionary $slist]
	# first line (2 points)
	set s1list [GeoListbox $slist 0 $geoEasyMsg(l1Title) 2]
	if {[llength $s1list] == 0} { return }
	set pn1 [lindex $s1list 0]
	set pn2 [lindex $s1list 1]
	if {[set i [lsearch -exact $slist $pn1]] != -1} {
		set slist [lreplace $slist $i $i]	;# remove pn1 from list
	}
	if {[set i [lsearch -exact $slist $pn2]] != -1} {
		set slist [lreplace $slist $i $i]	;# remove pn2 from list
	}
	set s2list [GeoListbox $slist 0 $geoEasyMsg(l2Title) 2]
	if {[llength $s2list] == 0} { return }
	set r [LineLine $pn1 $pn2 [lindex $s2list 0] [lindex $s2list 1]]
	set pn [string trim [GeoEntry $geoCodes(5) $geoEasyMsg(menuCalLine)]]
	if {[string length $pn]} {
		StoreCoord $pn [lindex $r 0] [lindex $r 1] 0 1
		if {$autoRefresh} { RefreshAll }
	}
}

#	Calculate intersection of two lines
#	@param pn1,pn2 points on first line
#	@param pn3,pn4 points on second line
#
#	@return list of the coordinates of the intersection
proc LineLine {pn1 pn2 pn3 pn4} {
	global geoEasyMsg
	global decimals
	global PI2

	# coordinates
	set pn1coo [GetCoord $pn1 {37 38}]
	set pn2coo [GetCoord $pn2 {37 38}]
	set pn3coo [GetCoord $pn3 {37 38}]
	set pn4coo [GetCoord $pn4 {37 38}]
	# bearings
	set b12 [Bearing [GetVal {38} $pn1coo] [GetVal {37} $pn1coo] \
		[GetVal {38} $pn2coo] [GetVal {37} $pn2coo]]
	while {$b12 < 0} {
		set b12 [expr {$b12 + $PI2}]
	}
	set b34 [Bearing [GetVal {38} $pn3coo] [GetVal {37} $pn3coo] \
		[GetVal {38} $pn4coo] [GetVal {37} $pn4coo]]
#	while {$b34 < 0} { set b34 [expr {$b34 + $PI2}] }
	# intersection
	set res [Intersec [GetVal {38} $pn1coo] [GetVal {37} $pn1coo] \
		[GetVal {38} $pn3coo] [GetVal {37} $pn3coo] $b12 $b34]
	# results
	GeoLog1
	GeoLog $geoEasyMsg(menuCalLine)
	GeoLog1 $geoEasyMsg(head1Sec)
	GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f %11s" \
		[GetVal {5} $pn1coo] [GetVal {4} $pn1coo] \
		[GetVal {38} $pn1coo] [GetVal {37} $pn1coo] [ANG $b12]]
	GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f" \
		[GetVal {5} $pn2coo] [GetVal {4} $pn2coo] \
		[GetVal {38} $pn2coo] [GetVal {37} $pn2coo]]
	GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f %11s" \
		[GetVal {5} $pn3coo] [GetVal {4} $pn3coo] \
		[GetVal {38} $pn3coo] [GetVal {37} $pn3coo] [ANG $b34]]
	GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f" \
		[GetVal {5} $pn4coo] [GetVal {4} $pn4coo] \
		[GetVal {38} $pn4coo] [GetVal {37} $pn4coo]]
	GeoLog1
	GeoLog1 [format "%-21s %12.${decimals}f %12.${decimals}f" \
		$geoEasyMsg(menuCalLine) [lindex $res 0] [lindex $res 1]]
	return $res
}

#	User interface to calculate point on line
proc GeoPointOnLine {} {
	global geoEasyMsg
	global geoCodes
	global autoRefresh

	# get all points with coordinates
	set slist [GetGiven {37 38}]
	set slist [lsort -dictionary $slist]
	# start point of line
	set s1list [GeoListbox $slist 0 $geoEasyMsg(p1Title) 1]
	if {[llength $s1list] == 0} { return }
	set pn1 [lindex $s1list 0]
	if {[set i [lsearch -exact $slist $pn1]] != -1} {
		set slist [lreplace $slist $i $i]	;# remove pn1 from list
	}
	# end point of line
	set s2list [GeoListbox $slist 0 $geoEasyMsg(p2Title) 1]
	if {[llength $s2list] == 0} { return }
	set pn2 [lindex $s2list 0]
	set dist [GeoEntry $geoCodes(11) $geoEasyMsg(menuCalPntLine)]
	if {[string length [string trim $dist]] == 0} { return }
	set dist1 [GeoEntry $geoCodes(117) $geoEasyMsg(menuCalPntLine)]
	if {[string length [string trim $dist1]] == 0} { set dist1 0 }
	set r [PointOnLine $pn1 $pn2 $dist $dist1]
	set pn [string trim [GeoEntry $geoCodes(5) $geoEasyMsg(menuCalPntLine)]]
	if {[string length $pn]} {
		StoreCoord $pn [lindex $r 0] [lindex $r 1] 0 1
		if {$autoRefresh} { RefreshAll }
	}
}

#
#	Calculate point on line
#	@param pn1,pn2 start and endpoint of line
#	@param dist distance from startpoint
#	@param total total measured distance between start and end, optional
#	@return list of the coordinates of point on line
proc PointOnLine {pn1 pn2 dist {total 0}} {
	global geoEasyMsg
	global decimals
	global PI2

	# coordinates
	set pn1coo [GetCoord $pn1 {37 38}]
	set pn2coo [GetCoord $pn2 {37 38}]
	set y1 [GetVal {38} $pn1coo]
	set x1 [GetVal {37} $pn1coo]
	if {$total < 0.001 } {
		set total [Distance $y1 $x1 [GetVal {38} $pn2coo] [GetVal {37} $pn2coo]]
	}
	set yp [expr {$y1 + $dist / $total * ([GetVal {38} $pn2coo] - $y1)}]
	set xp [expr {$x1 + $dist / $total * ([GetVal {37} $pn2coo] - $x1)}]
	# results
	GeoLog1
	GeoLog $geoEasyMsg(menuCalPntLine)
	GeoLog1 $geoEasyMsg(head1Pnt)
	GeoLog1 [format "%-10s %-10s %12.${decimals}f %12.${decimals}f %8.${decimals}f %8.${decimals}f" \
		[GetVal {5} $pn1coo] [GetVal {4} $pn1coo] $y1 $x1 $dist $total]
	GeoLog1
	GeoLog1 [format "%-21s %12.${decimals}f %12.${decimals}f" \
		$geoEasyMsg(menuCalPntLine) $yp $xp]
	return [list $yp $xp]
}

#
#	Calculate distances
#	@param points {{any any pointnumber} ... }
#	@return sum distance
proc CalcDistances {points} {
	global decimals
	global geoEasyMsg

	set sum 0
	set n 0
	GeoLog1
	GeoLog $geoEasyMsg(dist)
	GeoLog1 $geoEasyMsg(headDist)
	foreach pl $points {
		set pn [lindex $pl 2]
		set xy [GetCoord $pn {37 38}]
		if {$xy == ""} {
			set xy [GetCoord $pn {137 138}]
		}
		set x [GetVal {38 138} $xy]
		set y [GetVal {37 137} $xy]
		if {$n > 0} {
			set d [Distance $prevx $prevy $x $y]
			GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f" $pn $x $y $d]
			set sum [expr {$sum + $d}]
		} else {
			GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f" $pn $x $y]
		}
		incr n
		set prevx $x
		set prevy $y
	}
	GeoLog1
	GeoLog1 [format "%-10s                           %12.${decimals}f" $geoEasyMsg(sum) $sum]
	return [format "%.${decimals}f" $sum]
}

#
#	Calculate area
#	@param points {{any any pointnumber} ... }
proc CalcArea {points} {
	global decimals
	global geoEasyMsg

	# remove last point if it is the same as first
	set n_1 [expr {[llength $points] - 1}]
	set pn1 [lindex [lindex $points 0] 2]
	set pnn [lindex [lindex $points $n_1] 2]
	if {$pn1 == $pnn} {
		set points [lrange $points 0 [expr {$n_1 - 1}]]
	}
    if {[llength $points] < 3} { return 0 }
	set n 0
	set sumd 0
	set sumx 0
	set sumy 0
	set sumxa 0
	set sumya 0
	GeoLog1
	GeoLog $geoEasyMsg(area)
	GeoLog1 $geoEasyMsg(headDist)
	foreach pl $points {
		set pn [lindex $pl 2]
		set xy [GetCoord $pn {37 38}]
		if {$xy == ""} {
			set xy [GetCoord $pn {137 138}]
		}
		set x [GetVal {38 138} $xy]
		set y [GetVal {37 137} $xy]
		# for weight point
		set sumx [expr {$sumx + $x}]
		set sumy [expr {$sumy + $y}]
		if {$n > 0} {
			set d [Distance $prevx $prevy $x $y]
			set sumd [expr {$sumd + $d}]
			GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f" $pn $x $y $d]
		} else {
			set x1 $x	;# store first point
			set y1 $y
			GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f" $pn $x $y]
		}
		set xx($n) [format "%.${decimals}f" $x]	;# save coords
		set yy($n) [format "%.${decimals}f" $y]	;# displayed precision
		incr n
		set prevx $x
		set prevy $y
	}
	# add first point to the end of output list
	set d [Distance $prevx $prevy $x1 $y1]
	set sumd [expr {$sumd + $d}]
	GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f" $pn1 $x1 $y1 $d]
	
	set n_1 [expr {$n - 1}]
	set sum 0
	for {set i 0} {$i < $n} {incr i} {
		if {$i == 0} {
			set i_1 $n_1
		} else {
			set i_1 [expr {$i - 1}]
		}
		if {$i == $n_1} {
			set i1 0
		} else {
			set i1 [expr {$i + 1}]
		}
		set sum [expr {$sum + $xx($i) * ($yy($i1) - $yy($i_1))}]
		# for area weight point
		set sumxa [expr {$sumxa + ($xx($i) + $xx($i1)) * ($xx($i) * $yy($i1) - $xx($i1) * $yy($i))}]
		set sumya [expr {$sumya + ($yy($i) + $yy($i1)) * ($xx($i) * $yy($i1) - $xx($i1) * $yy($i))}]
	}
	set area [format "%.5f" [expr {abs($sum / 2.0)}]]
	GeoLog1
	GeoLog1 [format "%-10s                        %17.5f" $geoEasyMsg(sum1) $area]
	GeoLog1 [format "%-10s                      %17.${decimals}f" $geoEasyMsg(sum2) $sumd]
	GeoLog1 [format "%-17s                      %11.${decimals}f, %11.${decimals}f" $geoEasyMsg(meanp) [expr {$sumx / $n}] [expr {$sumy / $n}]]
	GeoLog1 [format "%-17s                      %11.${decimals}f, %11.${decimals}f" $geoEasyMsg(centroid) [expr {$sumxa / (3 * $sum)}] [expr {$sumya / (3 * $sum)}]]
	return $area
}

#
#	Select point from list and calculate area or sum length
#	@param area 0/1 length/area is calculated
proc GeoCalcArea {{area 1}} {
	global geoEasyMsg
	# get all points with coordinates
	set slist [GetGiven {37 38}]
	set slist [lsort -dictionary $slist]
	set plist ""
	set last 0
	while {$last == 0 && [llength $slist]} {
		set pn [GeoListbox $slist 0 $geoEasyMsg(lbTitle) 1 1]
		if {[llength $pn] > 1} {
			set last 1
			set pn [lindex $pn 0]
		}
		if {$pn == ""} {
			Beep
			return
		}
		lappend plist [list 0 0 $pn]
		# remove used points
		set n [lsearch -exact $slist $pn]
		if {$n != -1} {
			set slist [lreplace $slist $n $n]
		}
	}
	if {[llength $plist] > 0} {
		if {$area} {
			CalcArea $plist
		} else {
			CalcDistances $plist
		}
	}
}

#	Calculate statistics on loaded data sets
proc GeoStat {} {
	global geoEasyMsg
	global geoLoaded

#	occupied stations and oriented stations
	set ori 0
	set sta 0
	foreach pn [GetAll] {
		set stl [GetStation $pn]
		foreach st $stl {
			incr sta
			set fn [lindex $st 0]
			set row [lindex $st 1]
			global ${fn}_geo
			if {[GetVal {101} [set ${fn}_geo($row)]] != ""} {
				incr ori
			}
		}
	}
	set wstr [format $geoEasyMsg(stat) \
			[llength $geoLoaded] \
			[llength [GetAll]] \
			[llength [GetBase]] \
			[llength [GetDetail]] \
			[llength [GetStations]] \
			[llength [GetBaseStations]] \
			$sta $ori]
	GeoLog1
	GeoLog $geoEasyMsg(menuFileStat)
	GeoLog1 $wstr
	geo_dialog .msg $geoEasyMsg(info) $wstr info 0 OK
}

#
#	Calculate several intersections from given points
proc GeoFront {} {
	global autoRefresh
	global PI PI2
	global geoEasyMsg
	global decimals
	
	set slist [GetOrientedBaseStations {37 38 39}]
	if {[llength $slist] == 0} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(orist) warning 0 OK
		return
	}
	set stpns [GeoListbox $slist 0 $geoEasyMsg(lbTitle1) -2 0]
	if {[llength $stpns] == 0} { return }
	set n 0
	set nz 0
	set pns [lsort -dictionary [GetAll]]
	GeoLog1
	GeoLog $geoEasyMsg(menuCalFront)
	GeoLog1 $geoEasyMsg(head1Front)
	foreach pn $pns {
		set wstr ""
		# unknown points are calculated only
		if {[llength [GetCoord $pn {37 38}]] == 0} {
			# collect external dirs from the given points
			set extdirs [GetExtDir $pn]
			set useddirs ""
			foreach extdir $extdirs {
				if {[lsearch -exact $stpns [lindex $extdir 2]] != -1} {
					lappend useddirs $extdir
				}
			}
			set next [llength $useddirs]
			set variants ""
			if {$next > 1} {
				# calculate intersections angles in all combinations
				for {set i 0} {$i < $next} {incr i} {
					for {set j [expr {$i+1}]} {$j < $next} {incr j} {
						set alfa [expr {[lindex [lindex $useddirs $i] 3] - \
							[lindex [lindex $useddirs $j] 3]}]
						while {$alfa < 0} {set alfa [expr {$alfa + $PI2}]}
						if {$alfa > $PI} {set alfa [expr {$alfa - $PI}]}
						# angle difference to ideal 90 degree
						set alfa [expr {abs($alfa - $PI / 2.0)}]
						lappend variants [list $i $j $alfa]
					}
				}
				set variants [lsort -real -index 2 $variants]
				set nsec 0
				set sx 0
				set sy 0
				set xmin 1e99
				set xmax -1e99
				set ymin 1e99
				set ymax -1e99
				foreach v $variants {
					set arec [lindex $useddirs [lindex $v 0]]
					set brec [lindex $useddirs [lindex $v 1]]
					set res [GeoSec1 $arec $brec]
					if {[llength $res] == 2} {		;# store coords
						set x [lindex $res 0]
						set y [lindex $res 1]
						if {$x < $xmin} {set xmin $x}
						if {$x > $xmax} {set xmax $x}
						if {$y < $ymin} {set ymin $y}
						if {$y > $ymax} {set ymax $y}
						set sx [expr {$sx + $x}]
						set sy [expr {$sy + $y}]
						incr nsec
						if {$nsec > 2} { break }	;# best three intersection
					}
				}
				if {$nsec} {
					set x [expr {$sx / $nsec}]
					set y [expr {$sy / $nsec}]
					StoreCoord $pn $x $y
					incr n
					set wstr [format "%-10s %-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" \
						$pn [string range [GetPCode $pn 1] 0 9] $x $y \
						[expr {$xmax - $xmin}] [expr {$ymax - $ymin}]]
				}
			}
		}
		if {[llength [GetCoord $pn 39]] == 0 &&
				[llength [GetCoord $pn {37 38}]] != 0} {
			# height calculation
			set slist [GetEle $pn]			;# return elevations list
			# collect heights from given points
			set hlist ""
			foreach h $slist {
				if {[lsearch -exact $stpns [lindex $h 2]] != -1} {
					lappend hlist $h
				}
			}
			if {[llength $hlist] > 0} {
				set hres [GeoEle1 $hlist]
				set hlist [lsort -real -index 3 $hlist]
				if {[llength $hres] == 1} {		;# store coords
					StoreZ $pn [lindex $hres 0]
					if {[string length $wstr]} {
						set wstr1 [format "%12.${decimals}f %12.${decimals}f" \
							[lindex $hres 0] \
							[expr {[lindex [lindex $hlist end] 3] - \
							[lindex [lindex $hlist 0] 3]}]]
						set wstr "$wstr $wstr1"
					} else {
						set wstr [format  "%-10s %-10s                                                     %12.${decimals}f %12.${decimals}f" \
							$pn [string range [GetPCode $pn 1] 0 9] \
							[lindex $hres 0] \
							[expr {[lindex [lindex $hlist end] 3] - \
							[lindex [lindex $hlist 0] 3]}]]
						incr nz
					}
					GeoLog1 $wstr
				} elseif {[string length $wstr]} {
					GeoLog1 $wstr
				}
			} elseif {[string length $wstr]} {
				GeoLog1 $wstr
			}
		}
	}
	if {$n && $autoRefresh} {
		RefreshAll
	}
}

#	Check if val between bounds
#	@param bound1 lower bound
#	@param bound2 upper bound
#	@param val value to check
#	@return 0/1 outside/inside bound
proc between {bound1 bound2 val} {
	if {($val >=  $bound1 && $val < $bound2) || \
		($val > $bound2 && $val <= $bound1)} {
		return 1
	}
	return 0
}
