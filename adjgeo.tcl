#//#
#	adjustment calculation
#//#
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

#	Calculate approximate coordinates for all points (horizontal and vertical)
#		approximate coordinates are stored in all referenced geo data set
#	@param none
#	@return the list of point names for which no coordinates were calculated
proc GeoApprCoo {} {
	global geoEasyMsg
	global autoRefresh

	set s1 [HorizCoo]
	if {[llength $s1] > 0} {
		set s1 [lsort $s1]
		GeoListbox $s1 0 $geoEasyMsg(noAppCoo) 0
	}
	set s2 [ElevCoo]
	if {[llength $s2] > 0} {
		set s2 [lsort $s2]
		GeoListbox $s2 0 $geoEasyMsg(noAppZ) 0
	}
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	Calculate approximate elevation coordinates for all points.
#		approximate coordinates are stored in all referenced geo data set
#	@param none
#	@return the list of point names for which no coordinates were calculated
proc ElevCoo {} {
	global geoLoaded
	global geoEasyMsg
	global np

	set np 0
	GeoDia .dia $geoEasyMsg(elevDia) np	;# display dialog panel
	set new 1
	while {$new > 0} {					;# while new coords calculated
		set new 0
		set unknown ""
		foreach fn $geoLoaded {
			global ${fn}_ref ${fn}_coo
			foreach pn [array names ${fn}_ref] {
				if {[GetCoord $pn {39}] == "" && \
					[GetCoord $pn {139}] == ""} {
					# no elevation
					# try to calculate approximate elevation
					set elist [GetEle $pn 1]
					if {[llength $elist] > 0} {
						set z [GeoEle1 $elist]
						if {$z != ""} {
							incr new
							incr np
							update
							StoreZ $pn $z 1
						}
					} else {
						lappend unknown $pn
					}
				}
			}
		}
	}
	GeoDiaEnd .dia
	return $unknown
}

#	Calculate approximate horizontal coordinates for all points.
#		approximate coordinates are stored in all referenced geo data set
#	@param none
#	@return the list of point names for which no coordinates calculated
proc HorizCoo {} {
	global geoLoaded
	global geoEasyMsg
	global np nz

	set np 0							;# counter for new coordinates
	set nz 0							;# counter for new orientations
	GeoDia .dia $geoEasyMsg(horizDia) np nz	;# display dialog panel
	# try first orientations
	set bs [GetBaseStations]
	foreach pn $bs {
		if {[HorizOri $pn]} {
			incr nz
			update
		}
	}
	set new 1
	# try first final coordinates only!
	foreach fn $geoLoaded {
		global ${fn}_ref ${fn}_coo
		foreach pn [array names ${fn}_ref] {
			if {[GetCoord $pn {37 38}] == "" && \
				[GetCoord $pn {137 138}] == ""} {
				# no horizontal coords
				# try to calculate approximate cordinates
				if {[HorizCoo1 $pn 0]} {
					incr new
					incr np
					# try orientation on the new point
					if {[HorizOri $pn]} {
						incr nz
					}
					update
				}
			} else {
				# try orientation on the point
				if {[HorizOri $pn]} {
					incr nz
					update
				}
			}
		}
	}

	# try again with appr. coords
	set new 1
	while {$new > 0} {					;# while new coords calculated
		set new 0
		set unknown ""
		foreach fn $geoLoaded {
			global ${fn}_ref ${fn}_coo
			foreach pn [array names ${fn}_ref] {
				if {[GetCoord $pn {37 38}] == "" && \
					[GetCoord $pn {137 138}] == ""} {
					# no horizontal coords
					# try to calculate approximate cordinates
					if {[HorizCoo1 $pn 1]} {
						incr new
						incr np
						if {[HorizOri $pn]} {
							incr nz
						}
						update
					} else {
						lappend unknown $pn
					}
				} else {		;# orientation if possible
					if {[HorizOri $pn]} {
						incr new
						incr nz
						update
					}
				}
			}
		}
	}
	GeoDiaEnd .dia
	return $unknown
}

#
#	Calculate approximate coordinates for point 'pn'
#		approximate coordinates are stored in all referenced geo data set
#	@param pn point number/name
#	@param flag 0/1 final/appr. coord are used
#	@return 1 on success, 0 if failed
proc HorizCoo1 {pn flag} {

#	try polar
	set pollist [GetPol $pn $flag]
	set n [llength $pollist]
	if {$n > 0} {
		# use the first polar
		set res [GeoPol1 [lindex $pollist 0]]
		if {[llength $res] >= 2} {
			StoreCoord $pn [lindex $res 0] [lindex $res 1] 1
			if {[llength $res] == 3} {
				StoreZ $pn [lindex $res 2] 1
			}
		}
		return 1
	}
#	try intersection
	set extlist [GetExtDir $pn $flag]
	set n [llength $extlist]
	if {$n > 1} {
	# try intersection from any pairs
		for {set i 0} {$i < $n} {incr i} {
			set arec [lindex $extlist $i]
			for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
				set brec [lindex $extlist $j]
				# different directions?
				if {[lindex $arec 2] != [lindex $brec 2]} {
					set res [GeoSec1 $arec $brec]
					if {[llength $res] == 2} {
						StoreCoord $pn [lindex $res 0] [lindex $res 1] 1
						return 1
					}
				}

			}
		}
	}
#	try resection
	set stlist [GetStation $pn]
	foreach stl $stlist {
		set intlist [GetIntDir1 [lindex $stl 0] [lindex $stl 1] $flag]
		set n [llength $intlist]
		if {$n > 2} {
#		try resection from any three direction
			for {set i 0} {$i < $n} {incr i} {
				set arec [lindex $intlist $i]
				for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
					set brec [lindex $intlist $j]
					# different directions?
					if {[lindex $arec 2] != [lindex $brec 2]} {
						for {set k [expr {$j + 1}]} {$k < $n} {incr k} {
							set crec [lindex $intlist $k]
							# different directions
							if {[lindex $arec 2] != [lindex $crec 2] && \
								[lindex $brec 2] != [lindex $crec 2]} {
								set res [GeoRes1 $arec $brec $crec]
								if {[llength $res] == 2} {
									StoreCoord $pn [lindex $res 0] [lindex $res 1] 1
									return 1
								}
							}
						}
					}
				}
			}
		}
	}
# try arc section
	set distlist [GetDist $pn $flag]
	set n [llength $distlist]
	if {$n > 2} {
	# try arcsection from any pairs + a controll distance
		for {set i 0} {$i < $n} {incr i} {
			set arec [lindex $distlist $i]
			for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
				set brec [lindex $distlist $j]
				# different distances?
				if {[lindex $arec 2] != [lindex $brec 2]} {
					for {set k [expr {$j + 1}]}  {$k < $n} {incr k} {
						set crec [lindex $distlist $k]
						# different distances?
						if {[lindex $arec 2] != [lindex $crec 2] && \
							[lindex $brec 2] != [lindex $crec 2]} {
							set res [GeoArc1 "" $arec $brec $crec]
							if {[llength $res] == 2} {
								StoreCoord $pn [lindex $res 0] [lindex $res 1] 1
								return 1
							}
						}
					}
				}
			}
		}
	}
	if {$n == 2 && [llength $stlist]} {
	# use angle to select arcsection results
		set arec [lindex $distlist 0]
		set brec [lindex $distlist 1]
		foreach stl $stlist {
			set intlist [GetIntDir1 [lindex $stl 0] [lindex $stl 1] $flag]
			set n [llength $intlist]
			if {$n > 1} {
				set n1 [expr {$n - 1}]
				for {set i 0} {$i < $n1} {incr i} {
					for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
						set res [GeoArc1 "" $arec $brec [lindex $intlist $i] [lindex $intlist $j]]
						if {[llength $res] == 2} {
							StoreCoord $pn [lindex $res 0] [lindex $res 1] 1
							return 1
						}
					}
				}
			}
		}
	}
# try to find external direction and distance pair for polar
	foreach dir $extlist {
		set n [lsearch -glob $distlist [list * * [lindex $dir 2] * *]]
		if {$n != -1} {
			set d [lindex $distlist $n]
			set res [GeoPol1 [list [lindex $dir 2] [lindex $d 3] \
				[lindex $dir 3]]]
			if {[llength $res] >= 2} {
				StoreCoord $pn [lindex $res 0] [lindex $res 1] 1
				return 1
			}
		}
	}
# try to find an internal and a bidirecitonal direction for sidesection
	if {[llength $extlist] > 0} {			;# we have external directions
		foreach stl $stlist {	;# for each occupation
			set reslist ""
			set n_ext 0
			set intlist [GetIntDir1 [lindex $stl 0] [lindex $stl 1] $flag]
			foreach intdir $intlist {
				set n [lsearch -glob $extlist [list * * [lindex $intdir 2] *]]
				if {$n != -1} {	# bidirection
					set extdir [lindex $extlist $n]
					# result list pn intdir extdir
					# external dir to the beginning
					set reslist [linsert $reslist 0 \
						[list [lindex $intdir 2] [lindex $intdir 3] \
						[lindex $extdir 3]]]
					incr n_ext	;# no. of external dirs
				} else {	;# internal dir
					lappend reslist [list [lindex $intdir 2] [lindex $intdir 3]]
				}
			}
			set n [llength $reslist]
			# try any combination
			for {set i 0} {$i < $n_ext} {incr i} {
				set bidir [lindex $reslist $i]
				for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
					set intdir [lindex $reslist $j]
					set res [GeoSide1 "" $bidir $intdir]
					if {[llength $res] == 2} {
						StoreCoord $pn [lindex $res 0] [lindex $res 1] 1
						return 1
					}
				}
			}
		}
	}

# try to find two internal directions and a distance along one of the
# directions for distance sidesection
	foreach stl $stlist {	;# for each occupation
		set reslist ""
		set intlist [GetIntDir1 [lindex $stl 0] [lindex $stl 1] $flag]
		set n_dist 0
		foreach intdir $intlist {
			set n [lsearch -glob $distlist [list * * [lindex $intdir 2] * *]]
			if {$n != -1} {
				set dist [lindex $distlist $n]
				# result list pn direction distance zenit_angle
				# distances to the beginning
				set reslist [linsert $reslist 0 \
					[list [lindex $intdir 2] [lindex $intdir 3] \
					[lindex $dist 3] [lindex $dist 4]]]
				incr n_dist
			} else {
				# result list pn direction
				# directions to the end
				lappend reslist [list [lindex $intdir 2] [lindex $intdir 3]]
			}
		}
		set n [llength $reslist]
		# try any combination
		for {set i 0} {$i < $n_dist} {incr i} {
			set dist [lindex $reslist $i]
			for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
				set intdir [lindex $reslist $j]
				set res [GeoDistSide1 $pn $dist $intdir]
				if {[llength $res] == 2} {
					StoreCoord $pn [lindex $res 0] [lindex $res 1] 1
					return 1
				}
			}
		}
	}
# TBD tovabbi probalkozas kell
	return 0
}

#
#	Calculate approximate orientation angles for point 'pn' if not present
#		approximate orientation angeles are stored in geo data set
#	@param pn point number/name
#	@return number of stations oriented
proc HorizOri {pn} {

	set st 0
	set stlist [GetStation $pn]
	if {[llength $stlist] == 0} {return 0}	;# no station
	foreach stl $stlist {
		set geo [lindex $stl 0]
		set lin [lindex $stl 1]
		upvar #0 ${geo}_geo($lin) buf
		if {[GetVal {101 103} $buf] == ""} {	;# if no orientation yet
			if {[Orientation $geo $lin 7] >= 0} { incr st}
		}
	}
	return $st
}

#
#	Solve a linear equation system
#		a * x = b
#		a & b are changed!
#	@param a name of matrix of the equation system
#	@param b name of vector of pure term of equations
#	@param size size of the matrix
#	@return x will be in vector b, the inverse will be in matrix a
proc GaussElimination {a b size} {
	upvar $a matrix
	upvar $b l

	for {set i 0} {$i < $size} {incr i} {
		set q [expr {1.0 / $matrix($i,$i)}]
		for {set k 0} {$k < $size} {incr k} {
			if {$i != $k} {
				set matrix($i,$k) [expr {$q * $matrix($i,$k)}]
			} else {
				set matrix($i,$k) $q
			}
		}
		set l($i) [expr {$q * $l($i)}]
		for {set j 0} {$j < $size} {incr j} {
			if {$j != $i} {
				set t $matrix($j,$i)
				for {set k 0} {$k < $size} {incr k} {
					if {$i != $k} {
						set matrix($j,$k) [expr {$matrix($j,$k) - \
							$t * $matrix($i,$k)}]
					} else {
						set matrix($j,$k) [expr {-$t * $q}]
					}
				}
				set l($j) [expr {$l($j) - $t * $l($i)}]
			}
		}
	}
}

#
#	Calculate product of amatrix & bmatrix
#		c = a * b
#	   n,m n,l l,m
#		cmatrix is changed
#	@param amatrix name of the first matrix (n * l)
#	@param bmatrix name of the second matrix (l * m)
#	@param n number of rows in amatrix & cmatrix
#	@param m number of columns in bmatrix & cmatrix
#	@param l number of columns in amatrix & number of rows in bmatrix
#	@param cmatrix name of the product matrix (n * m)
proc MatrixProd {amatrix bmatrix n m l cmatrix} {
	upvar $amatrix a
	upvar $bmatrix b
	upvar $cmatrix c

	for {set i 0} {$i < $n} {incr i} {
		for {set j 0} {$j < $m} {incr j} {
			set w 0
			for {set k 0} {$k < $l} {incr k} {
				set w [expr {$w + $a($i,$k) * $b($k,$j)}]
			}
			set c($i,$j) $w
		}
	}
}

#
#	Display "str" string and variables listed in args at the center of the 
#	screen.
#	@param this name for window to create
#	@param str message string to display in window
#	@param args names of variables to display in window
proc GeoDia {this str args} {
	global geoEasyMsg

	set w [focus]
	if {$w == ""} { set w "." }
	catch "destroy $this"
	toplevel $this -class Dialog
	wm transient $this $w
	wm protocol $this WM_DELETE_WINDOW "Beep"
	wm protocol $this WM_SAVE_YOURSELF "Beep"
	wm title $this $geoEasyMsg(wait)
	catch {wm attribute $this -topmost}
	label $this.l1 -text $str
	pack $this.l1 -side left
	foreach a $args {
		global $a
		label $this.$a -textvariable $a
		pack $this.$a -side left
	}
	tkwait visibility $this
	# center window on screen
	set g [split [winfo geometry $this] "x+"]
	set wthis [expr {[lindex $g 0] + 50}]
	set hthis [lindex $g 1]
	set w [winfo screenwidth .]
	set h [winfo screenheight .]
	set x [expr {int(($w - $wthis) / 2.0)}]
	set y [expr {int(($h - $hthis) / 2.0)}]
	wm geometry $this "${wthis}x${hthis}+${x}+${y}"
	update
	grab set $this
}

#
#	Destroy this widget and release all windows
#	@param this name for window to destroy
#	@return none
proc GeoDiaEnd {this} {

	grab release $this
	catch "destroy $this"
}
