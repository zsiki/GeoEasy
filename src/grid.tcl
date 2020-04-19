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

#	Load a grid into memory (tcl array)
#	@param fname input file
#	@return 0 on success
proc LoadGrid {fname} {

	set name [file rootname [file tail $fname]]
	global $name
	if {[info exists $name]} {
		puts "Grid already loaded: $name"
		return 0
	}
	if {![file exists $fname]} {
		puts "File not found: $fname"
		return 1
	}
	if {[catch {set f [open $fname "r"]} msg]} {
		puts $msg
		return 2
	}
	# read ascii grid
	set i 0
	while {! [eof $f]} {
		set buf [string trim [gets $f]]
		if {[string length $buf] == 0} { continue }	;# skip empty line
		while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
		set buflist [split $buf]
		switch -regexp -- [lindex $buflist 0] {
			[cC][oO][lL][sS]: -
			[nN][cC][oO][lL][sS] {
				set ncols [lindex $buflist 1]
				set ${name}(ncols) $ncols
			}
			[rR][oO][wW][sS]: -
			[nN][rR][oO][wW][sS] {
				set nrows [lindex $buflist 1]
				set ${name}(nrows) $nrows
			}
			[xX][lL][lL][cC][oO][rR][nN][eE][rR] {
				set ${name}(xllcorner) [lindex $buflist 1]
			}
			[yY][lL][lL][cC][oO][rR][nN][eE][rR] {
				set ${name}(yllcorner) [lindex $buflist 1]
			}
			[xX][lL][lL][cC][eE][nN][tT][eE][rR] {
				set ${name}(xllcenter) [lindex $buflist 1]
			}
			[yY][lL][lL][cC][eE][nN][tT][eE][rR] {
				set ${name}(yllcenter) [lindex $buflist 1]
			}
			[cC][eE][lL][lL][sS][iI][zZ][eE] {
				set ${name}(cellsize) [lindex $buflist 1]
			}
			[nN][uU][lL][lL]: -
			[nN][oO][dD][aA][tT][aA]_[vV][aA][lL][uU][eE] {
				set ${name}(nodata) [lindex $buflist 1]
			}
			[nN][oO][rR][tT][hH]: {
				set ${name}(north) [lindex $buflist 1]
			}
			[sS][oO][uU][tT][hH]: {
				set ${name}(south) [lindex $buflist 1]
			}
			[eE][aA][sS][tT]: {
				set ${name}(east) [lindex $buflist 1]
			}
			[wW][eE][sS][tT]: {
				set ${name}(west) [lindex $buflist 1]
			}
			default {
				if {! [info exists ${name}(xllcorner)] && [info exists ${name}(xllcenter)]} {
					set ${name}(xllcorner) [expr {[set ${name}(xllcenter)] - 0.5 * [set $name(cellsize)]}]
				}
				if {! [info exists ${name}(yllcorner)] && [info exists ${name}(yllcenter)]} {
					set ${name}(yllcorner) [expr {[set ${name}(yllcenter)] - 0.5 * [set $name(cellsize)]}]
				}
				if {! [info exists ${name}(cellsize)]} {
					set cellsize [expr {([set ${name}(west)] - [set ${name}(xllcorner)]) / [set ${name}(ncols)]}]
				}
				if {[llength $buflist] != $ncols} {
					puts "Few columns in row [expr {$i + 1}]"
					close $f
					return 3
				}
				set ${name}($i) $buflist
				incr i
			}
		}
	}
	close $f
	return 0
}

#
#	Calculate volume difference between to grids
#	@param gridname1
#	@param gridname2
#	@param out
#	@return list of {area_above area_below area_same vol_above vol_below}
proc GridDif {gridname1 gridname2 {out ""}} {

	set name1 [file rootname [file tail $gridname1]]
	global $name1
	LoadGrid $gridname1
	set name2 [file rootname [file tail $gridname2]]
	global $name2
	LoadGrid $gridname2
	# check grid resolution and area
	set dx [set ${name1}(cellsize)]
	set x0 [set ${name1}(xllcorner)]
	set y0 [set ${name1}(yllcorner)]
	set nrows [set ${name1}(nrows)]
	set ncols [set ${name1}(ncols)]
	set nodata [set ${name1}(nodata)]
	if {$dx != [set ${name2}(cellsize)] || $x0 != [set ${name2}(xllcorner)] || \
		$y0 != [set ${name2}(yllcorner)] || $nrows != [set ${name2}(nrows)] || \
		$ncols != [set ${name2}(ncols)]} {
		tk_dialog .msg "Hiba" "eltero parameterek" error 0 OK
	}
	set dx2 [expr {$dx * $dx}]
	set no 0
	set yes 0
	set plus 0
	set minus 0
	set same 0
	set plusv 0
	set minusv 0
	set zmi 1e39
	set zma -1e39
	for {set i 0} {$i < $nrows} {incr i} {
		set buf1 [set ${name1}($i)]
		set buf2 [set ${name2}($i)]
		set dif($i) ""
		foreach v1 $buf1 v2 $buf2 {
			if {$v1 == $nodata || $v2 == $nodata} {
				lappend dif($i) $nodata
				incr no
			} else {
				set dz [expr {$v1 - $v2}]
				lappend dif($i) $dz
				if {$dz > 0.01} {
					incr plus
					set plusv [expr {$plusv + $dz * $dx2}]
				} elseif {$dz < -0.01} {
					incr minus
					set minusv [expr {$minusv + $dz * $dx2}]
				} else {
					incr same
				}
				incr yes
				if {$dz > $zma} { set zma $dz }
				if {$dz < $zmi} { set zmi $dz }
			}
		}
	}
	# save difference ascii grid
	if {[string length $out]} {
		if {[catch {set f [open $out w]}] == 0} {
			puts $f "ncols $ncols"
			puts $f "nrows $nrows"
			puts $f "xllcorner $x0"
			puts $f "yllcorner $y0"
			puts $f "cellsize $dx"
			puts $f "nodata_value $nodata"
			for {set i 0} {$i < $nrows} {incr i} {
				set buf $dif($i)
				foreach v $buf {
					puts -nonewline $f [format "%.2f " $v]
				}
				puts $f ""
			}
			close $f
		}
	}
	unset $name1
	unset $name2
	return [list [expr {$plus * $dx2}] [expr {$minus * $dx2}] [expr {$same * $dx2}] $plusv $minusv]
}

#
#	Change array of lists to a sortable list of [i j val]
#	@param name name of array
proc Grid2List {name} {
	global $name

	set res ""
	set n [set ${name}(nrows)]
	for {set i 0} {$i < $n} {incr i} {
		set buflist [set ${name}($i)]
		set j 0
		foreach val $buflist {
#if {[catch {expr {$val + 0.5}}]} { puts "$i $j $val" }
			lappend res [list $i $j $val]
			incr j
		}
	}
	return $res
}

#	Initialize grid with nodata value
#	@param name
#	@param ncols
#	@param nrows
#	@param xllcorner
#	@param yllcorner
#	@param cellsize
#	@param nodata
proc GridInit {name ncols nrows xllcorner yllcorner cellsize nodata} {

	global $name
	catch {unset $name}
	set $name(ncols) $ncols
	set $name(nrows) $nrows
	set $name(xllcorner) $xllcorner
	set $name(yllcorner) $yllcorner
	set $name(cellsize) $cellsize
	set $name(nodata) $nodata

	#set buf ""
	#for {set i 0} {$i < $nrows} {incr i} { lappend buf $nodata }
	set buf [lrepeat $ncols $nodata]
	for {set i 0} {$i < $nrows} {incr i} {
		set ${name}($i) $buf
	}
}

#
#	Calculate sum on grids TBD
#	@param h_order list in decreasing height of cell {{row col height} {...}}
#	@param dtm_grid height grid
#	@param flow_dirs name of flow directions grid
#	@param slope name of slope dir
#	@param res name of result grid
proc FlowSum {h_order dtm_grid flow_dirs slope res} {
	global $flow_dirs $slope $res

	set d_nodata [set ${dtm_grid}(nodata)]
	set f_nodata [set ${flow_dirs}(nodata)]
	set s_nodata [set ${slope}(nodata)]
	set r_nodata [set ${res}(nodata)]
	foreach cell $h_order {
		set i [lindex $cell 0]
		set j [lindex $cell 1]
		set s [lindex [set ${slope}($i)] $j]		;# slope on cell
		set f [lindex [set ${flow_dirs}($i)] $j]	;# flow direction on cell
		if {[lindex $cell 2] != $d_nodata && \
			$s != $s_nodata && $f != $f_nodata} {

			switch -exact $f {
				1 { set k $i ; set l [expr {$j + 1}]}
				2 { set k [expr {$i + 1}] ; set l [expr {$j + 1}]}
				4 { set k [expr {$i + 1}] ; set l $j }
				8 { set k [expr {$i + 1}] ; set l [expr {$j - 1}]}
				16 { set k $i ; set l [expr {$j - 1}]}
				32 { set k [expr {$i - 1}] ; set l [expr {$j - 1}]}
				64 { set k [expr {$i - 1}] ; set l $j }
				128 { set k [expr {$i - 1}] ; set l [expr {$j + 1}]}
				default {
				}
			}
			set buf [set ${res}($k)]
			if {[lindex $buf $l] != $r_nodata} {
				set val [expr {[lindex $buf $l] + 1}]
			} else {
				set val 1
			}
			set ${res}($i) [lreplace $buf $l $l $val]
		}
	}
}

#
#	Load a grid into memory as points
#	@param fn file name to load (*.asc or *arx)
#	@return 0 on succcess
proc GeoGridIn {fn} {

	set fa [GeoSetName $fn]
	if {[string length $fa] == 0} {return -1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	set name [file rootname [file tail $fn]]
	if {[catch {set f [open $fn r]}] != 0} {
		return -1       ;# cannot open input file
	}
	# read ascii grid
	# TBD repeated code!!!
	set src 0
	set row 0
	set k 0
	while {! [eof $f]} {
		incr src
		set buf [string trim [gets $f]]
		if {[string length $buf] == 0} { continue }	;# skip empty line
		while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
		set buflist [split $buf]
		switch -regexp -- [lindex $buflist 0] {
			[cC][oO][lL][sS]: -
			[nN][cC][oO][lL][sS] {
				set ncols [lindex $buflist 1]
			}
			[rR][oO][wW][sS]: -
			[nN][rR][oO][wW][sS] {
				set nrows [lindex $buflist 1]
			}
			[xX][lL][lL][cC][oO][rR][nN][eE][rR] {
				set xllcorner [lindex $buflist 1]
			}
			[yY][lL][lL][cC][oO][rR][nN][eE][rR] {
				set yllcorner [lindex $buflist 1]
			}
			[xX][lL][lL][cC][eE][nN][tT][eE][rR] {
				set xllcenter [lindex $buflist 1]
			}
			[yY][lL][lL][cC][eE][nN][tT][eE][rR] {
				set yllcenter [lindex $buflist 1]
			}
			[cC][eE][lL][lL][sS][iI][zZ][eE] {
				set cellsize [lindex $buflist 1]
			}
			[nN][uU][lL][lL]: -
			[nN][oO][dD][aA][tT][aA]_[vV][aA][lL][uU][eE] {
				set nodata [lindex $buflist 1]
			}
			[nN][oO][rR][tT][hH]: {
				set north [lindex $buflist 1]
			}
			[sS][oO][uU][tT][hH]: {
				set yllcorner [lindex $buflist 1]
			}
			[eE][aA][sS][tT]: {
				set xllcorner [lindex $buflist 1]
			}
			[wW][eE][sS][tT]: {
				set west [lindex $buflist 1]
			}
			default {
				if {[llength $buflist] != $ncols} {
					close $f
					return $src
				}
				if {! [info exists xllcorner] && [info exists xllcenter]} {
					set xllcorner [expr {$xllcenter - 0.5 * $cellsize}]
				}
				if {! [info exists yllcorner] && [info exists yllcenter]} {
					set yllcorner [expr {$yllcenter - 0.5 * $cellsize}]
				}
				if {! [info exists cellsize]} {
					set cellsize [expr {($west - $xllcorner) / $ncols}]
				}
				set x [expr {$yllcorner + $cellsize * ($nrows - $row - 0.5)}]
				for {set col 0} {$col < $ncols} {incr col} {
					set y [expr {$xllcorner + ($col + 0.5) * $cellsize}]
					set z [lindex $buflist $col]
					if {$z != $nodata} {
						incr k
						set pn $name$k
						AddCoo $fa $pn $y $x $z
					}
				}
				incr row
			}
		}
	}
	close $f
	return 0
}
