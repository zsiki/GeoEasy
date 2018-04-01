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

#	Returns geo data set name, replaces invalid chars with "_"
#
#	@param fn file name of geo-easy data set
#	@return valid geo set name
#
proc GeoSetName {fn} {
	set w [string trim $fn]
	set f [file tail [file rootname $fn]]

	# replace invalid chars
	regsub -all "\[\t \.\]" $f "_" f   ;# replace space,tab & .
	if {[regexp "^\[_a-zA-Z\]" $f] == 0} {
		set f "_$f"
	}
	return [string tolower $f]
}

#	Generate sign character
#	
#	@param x a numeric value
#	@return sign character odf the parameter ("+" or "-")
proc signCh {x} {
	if {$x < 0} { return "-" } else { return "+" }
}

#	convert angle in radians into arc seconds
#	
#	@param rad angle in radians
#	@return the angle in seconds
proc Rad2Sec {rad} {
	global RO
	return [expr {$rad * $RO}]
}

#	Convert angle in arc seconds into radians
#	
#	@param sec angle in arc seconds
#	@return the angle in radians
proc Sec2Rad {rad} {
	global RO
	return [expr {$rad / $RO}]
}

#	Calculate reduced distance to horizontal and see level
#
#	@param dist slope distance to reducei, if va == "" then horizontal distance
#	@param va zenit angle, optional
#	@param dm height difference (used only if zenit angle not known), optional
#	@return reduced distance
proc GetRedDist {dist {va ""} {dm ""}} {
	global projRed avgH stdAngle stdDist1 stdDist2 refr
	global R

	if {$va != ""} {
		# slope distance, reduce to horizontal
		set dist [expr {$dist * sin($va)}]
	} elseif {$dm != ""} {
		set dist [expr {sqrt($dist * $dist - $dm * $dm)}]
	}
	# reduction to mean see level
	set dist [expr {$dist - $dist * $avgH / $R}]
	# reduction to projection plane
	# projection ... TBD!!! no coordinates are available for reduction
#	Special projections used:
#   Where x and y are 100 km units
	switch -exact $projRed {
		"EOV" {
#                                               2
#		EOV           m - 1 = 0.000123 * (x - 2) - 0.00007
		}
		"SZTEREO" {
#                                              2   2
#		stereographic m - 1 = 1/2 * 0.000123 (x + y )
		}
		"HENGER" {
#                                         2
#		cylindrical   m - 1 = 0.000123 * x
		}
		default {
			set dist [expr {$dist + $projRed * $dist / 1000.0 / 1000.0}]
		}
	}
	return $dist
}

#	Load geo-easy data set into memory.
#	Memory structures used
#		${fn}_geo - array elements are indexed by file line number and
#					hold a station or observation record
#		${fn}_coo - array elements are indexed by point number and
#					hold point type and coordinates
#		${fn}_ref - array elements are indexed by point number and
#					references to the point as indexes in _geo array
#		${fn}_par - list of meta data (optional)
#
#	@param fn file name of geo-easy data set
#	@returnxs < 0 in case of errors, 0 OK
proc LoadGeo {fn} {
	global geoEasyMsg
	global reg tcl_platform
	global autoRefresh

	set f [file rootname $fn]
#
#	open geo data file & coordinate file
#
	if {[catch {set f1 [open $f.geo r]}] != 0} {
		return -6
	}
	set f2 ""
	catch {set f2 [open $f.coo r]}
#	if {[catch {set f2 [open $f.coo r]}] != 0} {
#		catch {close $f1}
#		return -7
#	}
	set f3 ""
	catch {set f3 [open $f.par r]}	;# par file
#
#	load station and observation records
#
	set f [GeoSetName $fn]
	global ${f}_geo ${f}_coo ${f}_ref ${f}_par
	catch "unset ${f}_geo ${f}_coo ${f}_ref ${f}_par"
	set lineno 0
	while {! [eof $f1]} {
		gets $f1 buf
		if {[string length [string trim $buf]] == 0} {continue}
		if {[catch {set pn [GetVal {5 2 62} $buf]} msg]} {
			catch {close $f1}
			catch {close $f2}
			catch {close $f3}
			return [expr {$lineno + 1}]	
		}

		if {$pn == ""} {
			catch {close $f1}
			catch {close $f2}
			catch {close $f3}
			return [expr {$lineno + 1}]	
		}
#
#	check for DMS angles (DDD-MM-SS format)
#
		foreach code {7 8 17 18 21 100 101 102 103} {
			if {[set w [GetVal $code $buf]] != "" && \
				[regexp $reg(3) $w]} {
				set buf [DelVal $code $buf]
				set tmp [DMS2Rad $w]
				if {[string length $w] > 0} {
					lappend buf [list $code $tmp]
				} else { 	;# invalid angle value
					catch {close $f1}
					catch {close $f2}
					catch {close $f3}
					return [expr {$lineno + 1}]	
				}
			}
		}
#
#	check for numeric values
#
		foreach code {3 6 7 8 9 10 11 17 18 21 100 101 102 103} {
			if {[set w [GetVal $code $buf]] != ""} {
				if {[regexp $reg(2) $w] == 0} {
					catch {close $f1}
					catch {close $f2}
					catch {close $f3}
					return [expr {$lineno + 1}]	
				}
			}
		}
		set ${f}_geo($lineno) $buf
		lappend ${f}_ref($pn) $lineno
		incr lineno
	}
	catch {close $f1}
#
#	load coordinates (skip line if not 5, 2 or 62 code
#
	set coono 0
	set lineno 0
	if {[string length $f2]} {
		while {! [eof $f2]} {
			gets $f2 buf
			if {[string length [string trim $buf]] == 0} {continue}
			if {[catch {set pn [GetVal {5 2 62} $buf]} msg]} {
				catch {close $f3}
				catch {close $f2}
				return [expr {$lineno + 1}]	
			}

			if {$pn == ""} {
				catch {close $f3}
				catch {close $f2}
				return [expr {$lineno + 1}]	
			}
			foreach code {37 38 39 137 138 139} {
				if {[set w [GetVal $code $buf]] != ""} {
					if {[regexp $reg(2) $w] == 0} {
						catch {close $f3}
						catch {close $f2}
						return [expr {$lineno + 1}]	
					}
				}
			}
			if {[lsearch -exact [array names ${f}_coo] $pn] != -1} {
				tk_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(dblPn): $pn" \
					warning 0 OK
				continue
			}
			set ${f}_coo($pn) $buf
			incr coono
			incr lineno
		}
	}
	catch {close $f2}
#
#	load par file (meta data) single row
#
	if {[string length $f3]} {
		set but ""
		catch {gets $f3 buf}
		set ${f}_par $buf
		catch {close $f3}
	}
	if {$autoRefresh} {
		# refresh all graphic windows
		GeoDrawAll
	}
	return 0
}

#
#	Regenerate refference array for geo data set
#	@param geo name of geo data set
#	@return none
proc GeoRef {geo} {

	regsub "_geo$" $geo "_ref" rn				;# name of ref array
	global $rn $geo
	catch "unset $rn"							;# delete old array
	foreach i [array names ${geo}] {			;# regenerate array
		set pn [GetVal {2 5 62} [set ${geo}($i)]]
		lappend ${rn}($pn)  $i
	}
}

#
#	Unload geo-easy data set from memory.
#	Memory structures dropped
#		${fn}_geo - array elements are indexed by file line number and
#					hold a station or observation record
#		${fn}_coo - array elements are indexed by point number and
#					hold point type and coordinates
#		${fn}_ref - array elements are indexed by point number and
#					references to the point as indexes in _geo array
#		${fn}_par - list of meta data
#
#	side effects
#		geoLoaded changed
#		data sheets are closed
#	@param fn name of geo-easy data set
#	@return none
proc UnloadGeo {fn} {
	global geoLoaded
	global tinLoaded
	global geoLoadedDir
	global autoRefresh

	set retval 0
	if {[info exists geoLoaded]} {
		if {[set pos [lsearch -exact $geoLoaded $fn]] != -1} {
		#	remove name from the list of loaded datasets
			set geoLoaded [lreplace $geoLoaded $pos $pos]
			set geoLoadedDir [lreplace $geoLoadedDir $pos $pos]
		} else {
			set retval -8		;# no geo set loaded at all
		}
	} else {
		set retval -8		;# no geo set loaded at all
	}
	global ${fn}_geo ${fn}_ref ${fn}_coo ${fn}_par
#	remove memory structures
	foreach a "${fn}_geo ${fn}_ref ${fn}_coo ${fn}_par" {
		catch "unset $a"
	}
#	close open sheets for this data set
	set name [string tolower ${fn}]
	if {[winfo exists .${name}_geo]} {
		GeoMaskExit .${name}_geo
	}
	if {[winfo exists .${name}_coo]} {
		GeoMaskExit .${name}_coo
	}
	return $retval
}

#
#	Save GeoEasy data set.
#	@param fn name of GeoEasy data set
#	@param nn new path name of geo data set  without extension (optional)
#	@return none
proc SaveGeo {fn {nn ""}} {
	global geoLoaded
	global geoLoadedDir
	global tcl_platform
	global geoEasyMsg

#
#	open geo data file & coordinate file
#
	if {$nn != ""} {
		set fulln $nn
	} elseif {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8			;# geo data set not loaded
		}
		set fulln [file rootname [lindex $geoLoadedDir $pos]]
	} else {
		return ""
	}
	if {[catch {set f1 [open $fulln.geo w]}] != 0} {
		return -6
	}
	if {[catch {set f2 [open $fulln.coo w]}] != 0} {
		catch {close $f1}
		return -7
	}
#
#	save station and observation records
#
	global ${fn}_geo ${fn}_coo ${fn}_par
	set lineno 0
	while {[info exists ${fn}_geo($lineno)]} {
		puts $f1 [set ${fn}_geo($lineno)]
		incr lineno
	}
#
#	save coordinates
#
	set lineno 0
	foreach pn [lsort -dictionary [array names ${fn}_coo]] {
		set buf [set ${fn}_coo($pn)]
		# remove coordinate differences
		set buf [DelVal {40 41 42} $buf]
		puts $f2 $buf
		incr lineno
	}
	close $f1
	close $f2
#
#	save meta data
#
	if {[llength ${fn}_par]} {
		if {[catch {set f3 [open $fulln.par w]}] != 0} {
			return -11
		}
		catch {puts $f3 [set ${fn}_par]}
		catch {close $f3}
	}
	return 0
}

#	Get a value from a list of code value pairs
#
#	@param codes list of codes to look for in buf
#	@param buf list of pair of elements like {{code value} {code value} ...}
#	@return the value belongs to the first code from codes found in buf.
proc GetVal {codes buf} {

	foreach code $codes {
		set pos [lsearch -glob $buf "$code *"]
		if {$pos != -1} {
			return [lindex [lindex $buf $pos] 1]
		}
	}
	return ""
}

#	Delete values from a list of code value pairs
#
#	@param codes list of codes to remove from the kist of code value pairs
#	@param buf list of pair of elements like {{code value} {code value} ...}
#	@return the list without codes
proc DelVal {codes buf} {

	foreach code $codes {
		set pos [lsearch -glob $buf "$code *"]
		if {$pos != -1} {
			set buf [lreplace $buf $pos $pos]
		}
	}
	return $buf
}

#
#	Get coordinates of the point.
#	All loaded coordinate lists
#	are checked in the order of loading but first list can be set by
#	the second parameter.
#
#	@param pn point number
#	@param code coordinate codes to look for (38-x 37-y 39-z 138-xe 137-ye 139-ze)
#	@param first first coordinate list to look for (optional)
#	@return the coord list belongs to the point
proc GetCoord {pn code {first ""}} {
	global geoLoaded
#
#	if first parameter set and a name of loaded geo data set check it first
#
	if {$first != "" && [lsearch -exact $geoLoaded $first] != -1} {
		set res [GetCoord1 $pn $code $first]
		if {$res != ""} {return $res}
	}
#
#	check rest of loaded data sets
#
	foreach geo $geoLoaded {
		if {$first != $geo} {
			set res [GetCoord1 $pn $code $geo]
			if {$res != ""} {return $res}
		}
	}
	return ""					;# not found
}

#
#	Get coordinates of the point from a given coordinate data set
#
#	@param pn point number
#	@param code coordinate codes to look for (38-x 37-y 39-z 138-xe 137-ye 139-ze)
#	@param coo coordinate data set to look for
#	@return the coords belongs to the point from coo coordinate list or an
#	empty list if not all codes found
proc GetCoord1 {pn code coo} {
	global geoLoaded
	
	if {$coo != "" && [lsearch -exact $geoLoaded $coo] != -1} {
		global ${coo}_coo
		if {[info exists ${coo}_coo($pn)] == 1} {
			set cbuf [set ${coo}_coo($pn)]
			foreach c $code {
				if {[lsearch -glob $cbuf "$c *"] == -1} {
					return ""
				}
			}
			return $cbuf
		}
	}
	return ""					;# not loaded or not found
}

#
#	Get the coords belonging to the point from coo coordinate list even if 
#	the array is not registered in loaded data sets.
#	Used by Idex!
#	@param pn point number
#	@param code coord codes to look for (38-x 37-y 39-z 138-xe 137-ye 139-ze)
#	@param coo coordinate data set to look for
#	@return the coords belongs to the point from coo coordinate list or an
#	empty list if not all codes found
proc GetCoord2 {pn code coo} {
	
	if {$coo != ""} {
		global ${coo}_coo
		if {[info exists ${coo}_coo($pn)] == 1} {
			set cbuf [set ${coo}_coo($pn)]
			foreach c $code {
				if {[lsearch -glob $cbuf "$c *"] == -1} {
					return ""
				}
			}
			return $cbuf
		}
	}
	return ""					;# not loaded or not found
}

#
#	Store or replace the coordinates of 'pn' in every data set where
#	it is referenced. If x or y is empty no change in that coordinate.
#	Side effects:
#		point code is changed in the coordinate list if it is empty
#	@param pn point number
#	@param x first coordinate
#	@param y second coordinate
#	@param flag - 0/1 store x & y as final/approximate coordinate
#	@param force - 0/1 store coords even if not referenced/used
#				intersection of two lines or point on line
proc StoreCoord {pn x y {flag 0} {force 0}} {
	global geoLoaded
	global geoChanged

	if {$x == "" && $y == ""} {return}
#
#	check loaded data sets
#
	foreach geo $geoLoaded {
		global ${geo}_geo ${geo}_coo ${geo}_ref
		# if referenced or has coordinates
		if {$force || [info exists ${geo}_ref($pn)] || \
			[info exists ${geo}_coo($pn)]} {
			if {[info exists ${geo}_coo($pn)]} {	;# it has coordinates
				upvar #0 ${geo}_coo($pn) coo_rec
				if {$x != ""} {						;# remove x coord
					set coo_rec [DelVal {38 138} $coo_rec]
				}
				if {$y != ""} {						;# remove y coord
					set coo_rec [DelVal {37 137} $coo_rec]
				}
			} else {
				upvar #0 ${geo}_coo($pn) coo_rec
				set coo_rec [list [list 5 $pn]]
			}
			if {$x != ""} {
				set x [format "%.4f" $x]
				if {$flag} {
					lappend coo_rec [list 138 $x]
				} else {
					lappend coo_rec [list 38 $x]
				}
			}
			if {$y != ""} {
				set y [format "%.4f" $y]
				if {$flag} {
					lappend coo_rec [list 137 $y]
				} else {
					lappend coo_rec [list 37 $y]
				}
			}
			if {[GetVal 4 $coo_rec] == ""} {
				set pcode [GetPCode $pn]
				if {$pcode != ""} {
					lappend coo_rec [list 4 $pcode]
				}
			}
			set geoChanged($geo) 1
		}
	}
}

#
#	Store or replace the coordinates of 'pn' in every data set where
#	it is referenced.
#	@param pn point number
#	@param z elevation
#	@param flag 0/1 store z as final/approximate coordinate
proc StoreZ {pn z {flag 0}} {
	global geoLoaded
	global geoChanged

	if {$z == ""} {return}
#
#	check loaded data sets
#
	foreach geo $geoLoaded {
		global ${geo}_geo ${geo}_coo ${geo}_ref
		# if referenced or has coordinates
		if {[info exists ${geo}_ref($pn)] || \
			[info exists ${geo}_coo($pn)]} {
			if {[info exists ${geo}_coo($pn)]} {	;# it has coordinates
				upvar #0 ${geo}_coo($pn) coo_rec
				set coo_rec [DelVal {39 139} $coo_rec]	;# remove prev value
			} else {
				upvar #0 ${geo}_coo($pn) coo_rec
				set coo_rec [list [list 5 $pn]]
			}
			set z [format "%.5f" $z]
			if {$flag} {
				lappend coo_rec [list 139 $z]
			} else {
				lappend coo_rec [list 39 $z]
			}
			if {[GetVal 4 $coo_rec] == ""} {
				set pcode [GetPCode $pn]
				if {$pcode != ""} {
					lappend coo_rec [list 4 $pcode]
				}
			}
			set geoChanged($geo) 1
		}
	}
}

#
#	Generate a list of different point numbers in loaded geo data sets
#	@param none
#	Return the list of different point numbers in loaded geo data sets
proc GetAll {} {
	global geoLoaded
	
	set ret ""
	foreach fn $geoLoaded {
		global ${fn}_ref
		global ${fn}_coo
# observed or listed in coordinate list
		set pns [concat [array names ${fn}_ref] [array names ${fn}_coo]]
		foreach pn $pns {
			if {[lsearch -exact $ret $pn] == -1} {
				lappend ret $pn
			}
		}
	}
	return $ret
}

#
#	Generate the list of different observed point numbers in loaded geo data sets
#	@param none
#	@return the list of different observed point numbers in loaded geo data sets
proc GetAllObs {} {
	global geoLoaded
	
	set ret ""
	foreach fn $geoLoaded {
		global ${fn}_ref
# observed
		set pns [array names ${fn}_ref]
		foreach pn $pns {
			if {[lsearch -exact $ret $pn] == -1} {
				lappend ret $pn
			}
		}
	}
	return $ret
}

#
#	Generate the list of different point numbers in loaded coo files
#	@param none
#	@return the list of different point numbers in loaded coo files
proc GetAllCoo {} {
	global geoLoaded
	
	set ret ""
	foreach fn $geoLoaded {
		global ${fn}_coo
# listed in coordinate list
		set pns [array names ${fn}_coo]
		foreach pn $pns {
			if {[lsearch -exact $ret $pn] == -1} {
				lappend ret $pn
			}
		}
	}
	return $ret
}

#
#	Generate the list of point numbers having less than 2 references,
#	not used as station and have distance observed, and name fit to
#	detailreg regexp.
#	@param none
#	@return the list of point numbers
proc GetDetail {} {
	global geoLoaded
	global detailreg
	
	set lim 2									;# limit for number of refs
	set ret ""
	set noret ""
	set stations [GetStations]					;# collect stations
	foreach fn $geoLoaded {
		global ${fn}_ref ${fn}_geo
		set pns [array names ${fn}_ref]
		foreach pn $pns {
			if {[lsearch -exact $ret $pn] != -1 ||
				[lsearch -exact $noret $pn] != -1} {	;# checked yet
				continue;
			}
			# name not allowed or station?
			if {[regexp $detailreg $pn] == 0 || \
				[lsearch -exact $stations $pn] != -1} {
				continue
			}
			upvar #0 ${fn}_ref($pn) refs
			if {[GetSumRef $pn] >= $lim} {		;# may not be a detail
				continue
			}
			set station 0					;# suppose it is not a station
			set dist 0						;# suppose no distance
			foreach ref $refs {
				upvar #0 ${fn}_geo($ref) buf
				if {[GetVal 2 $buf] != ""} {
					set station 1
					break
				}
				if {[GetVal {9 11} $buf] != ""} {
					set dist 1
				}
			}
			if {$station == 0 && $dist > 0} {
				lappend ret $pn
			} else {
				lappend notret $pn
			}
		}
	}
	return $ret
}

#
#	Generate the list of point numbers having less than 2 references
#	in geo data sets and having no coordinates (X, Y or Z)
#	@param none
#	@return the list of point numbers
proc GetNewDetail {} {

	set detail [GetDetail]
	set newd ""
	foreach d $detail {
		if {[GetCoord $d {37 38}] == "" || [GetCoord $d {39}] == ""} {
			lappend newd $d
		}
	}
	return $newd
}

#
#	Generate the list of point numbers having less than 2 references
#	in geo data sets and having coordinates (X, Y or Z)
#	@param codes coordinate codes to check {37 38} or {37 38 39}
#
#	Return the list of point numbers
proc GetGivenDetail {{codes {37 38 39}}} {

	set detail [GetDetail]
	set givend ""
	foreach d $detail {
		if {[GetCoord $d $codes] != ""} {
			lappend givend $d
		}
	}
	return $givend
}

#
#	Generate the list of point numbers having more than 2 references
#	in geo data sets or are stations
#	@param none
#	@return the list of point numbers
proc GetBase {} {

	set base ""
	set all [GetAll]					;# get all point numbers
	set detail [GetDetail]				;# get point numbers of detail points
	if {[llength $detail] > 0} {
		foreach a $all {
			if {[lsearch -exact $detail $a] == -1} {
				lappend base $a			;# collect not detail (base) points
			}
		}
		return $base
	} else {
		return $all
	}
}

#
#	Generate list of stations
#	@param none
#	@return the list of point names
proc GetStations {} {

	set ret ""
	set all [GetAll]					;# get all point numbers
	foreach pn $all {
		if {[llength [GetStation $pn]] > 0} {
			lappend ret $pn				;# collect stations
		}
	}
	return $ret
}

#
#	Create the list of point names those were stations and have coordinates
#	@param codes list of codes to be found in coordinate list default x & y
#	@return list of cwbase station names
proc GetBaseStations {{codes {37 38}}} {

	set ret ""
	set all [GetAll]					;# get all point numbers
	foreach pn $all {
		if {[llength [GetStation $pn]] > 0 && \
			[llength [GetCoord $pn $codes]] > 0} {
			lappend ret $pn				;# collect stations with coordinates
		}
	}
	return $ret
}

#
#	Create the list of point names those were stations, have coordinates and
#	have orientation angle
#	@param codes list of codes to be found in coordinate list default x & y
#	@return the list of oriented station names
proc GetOrientedBaseStations {{codes {37 38}}} {

	set ret ""
	set all [GetAll]					;# get all point numbers
	foreach pn $all {
		set sts [GetStation $pn]
		if {[llength $sts] > 0 && \
			[llength [GetCoord $pn $codes]] > 0} {
			foreach st $sts {
				set geoset [lindex $st 0]
				global ${geoset}_geo
				if {[GetVal 101 [set ${geoset}_geo([lindex $st 1])]] != ""} {
					lappend ret $pn
					break
				}
			}
		}
	}
	return $ret
}

#
#	Create the list of point names having coordinates
#	@param codes list of codes to be found in coordinate list default x & y
#	@return the list of point names having coordinates
proc GetGiven {{codes {37 38}}} {

	set ret ""
	set all [GetAll]					;# get all point numbers
	foreach pn $all {
		if {[llength [GetCoord $pn $codes]] > 0} {
			lappend ret $pn				;# points with coordinates
		}
	}
	return $ret
}

#
#	Create the list of point names used in observations
#	@param pl list of point numbers to check/reduce
#	@return the list of point names
proc UsedPointsOnly {pl} {
	global geoLoaded

	# create redundant list of used points
	set allUsed ""
	foreach fn $geoLoaded {
		global ${fn}_ref
		set allUsed [concat $allUsed [array names ${fn}_ref]]
	}
	set ret ""
	foreach p $pl {
		if {[lsearch -exact $allUsed $p] != -1} { lappend ret $p }
	}
	return $ret
}

#
#	Create the list of point names having coordinates (x,y)
#		final or approximate coordinates are considered too
#	@param pl list of point numbers to check
#	@return the list of point names
proc KnownPointsOnly {pl} {
	global geoLoaded

	# create redundant list of known points
	set ret ""
	foreach p $pl {
		if {[llength [GetCoord $p {38 37}]] > 0 || \
			[llength [GetCoord $p {138 137}]] > 0} { lappend ret $p }
	}
	return $ret
}

#
#	Create the list of point names having Z coordinates (elevation)
#		final or approximate coordinates are considered too
#	@param pl list of point numbers to check
#	@return the list of point names
proc KnownZPointsOnly {pl} {

	# create redundant list of known points
	set ret ""
	foreach p $pl {
		if {[llength [GetCoord $p  39]] > 0 || \
			[llength [GetCoord $p 139]] > 0} { lappend ret $p }
	}
	return $ret
}

#
#	Create the list of point names having coordinates (x,y,z)
#		final or approximate coordinates are considered too
#	@param pl list of point numbers to check
#	@return the list of point names
proc Known3DPointsOnly {pl} {
	global geoLoaded

	# create redundant list of known points
	set ret ""
	foreach p $pl {
		if {([llength [GetCoord $p {38 37}]] > 0 || \
			 [llength [GetCoord $p {138 137}]] > 0) &&
			([llength [GetCoord $p 39]] > 0 ||
			 [llength [GetCoord $p 139]] > 0)} { lappend ret $p }
	}
	return $ret
}

#
#	Create the list of geo data set names and row numbers where the
#	given point is a station
#
#	@param pn point number to search for as a station
#	@return the list of geo data set names and row numbers
proc GetStation {pn} {
	global geoLoaded

	set ret ""
	foreach fn $geoLoaded {
		global ${fn}_geo ${fn}_ref
		if {[info exists ${fn}_ref($pn)]} {		;# point has ref in data set
			set refs [set ${fn}_ref($pn)]
			foreach ref $refs {
				if {[GetVal 2 [set ${fn}_geo($ref)]] != ""} {
					lappend ret [list $fn $ref]
				}
			}
		}
	}
	return $ret
}

#
#	Create the list of geo data set names and row numbers from where the
#	given point is shot (horizontal angle) and station has orientation
#	Form returned list:
#	{ {geo_set line_no station_number bearing} {...}}
#
#	@param pn point number
#	@param flag 0 only final orientations are considered
#				1 approximate orientations are used too
#	@return the list of geo data set names and row numbers
proc GetExtDir {pn {flag 0}} {
	global geoLoaded
	global PI PI2

	set ret ""
	foreach fn $geoLoaded {
		global ${fn}_geo ${fn}_ref
		if {[info exists ${fn}_ref($pn)]} {		;# point has ref in data set
			upvar #0 ${fn}_ref($pn) refs
			foreach ref $refs {
				upvar #0 ${fn}_geo($ref) buf
				if {[GetVal 2 $buf] == ""} {	;# not a station
					set dir [GetVal {21 7} $buf]
					if {$dir != ""} {			;# there is horizontal angle
						# step back to find station
						set buf1 [GetLastRec $fn _geo $ref 2]
						if {$buf1 != ""} {
							set st [GetVal 2 $buf1]
							if {$st != ""} {		;# station found
								set z [GetVal {101 100} $buf1]	;# orientation
								if {$z == "" && $flag} {
									set z [GetVal {103 102} $buf1]
								}
								# station coords?
								set coo [GetCoord $st {38 37}]
								if {$coo == "" && $flag} {
									set coo [GetCoord $st {138 137}]
								}
								if {$z != "" && $coo != ""} {
									set delta [expr {$z + $dir}]
									while {$delta > $PI2} {
										set delta [expr {$delta - $PI2}]
									}
									lappend ret [list $fn $ref $st $delta]
								}
							}
						}
					}
				}
			}
		}
	}
	return $ret
}

#
#	Create the list of geo data set names and row numbers to where there
#	is a shot (horizontal angle) & target has coordinates (the first station)
#	Form returned list:
#	{ {geo_set line_no point_number horizontal_angle} {...}}
#
#	@param pn point number
#	@param flag 0 only fixed coordinates are used (codes 38 37)
#				1 approximate coordinates are also used (codes 38 37 138 137)
#	@return the list of geo data set names and row numbers
proc GetIntDir {pn {flag 0}} {
	global geoLoaded
	global PI PI2

	set ret ""
	foreach fn $geoLoaded {
		global ${fn}_geo ${fn}_ref
		if {[info exists ${fn}_ref($pn)]} {		;# point has ref in data set
			upvar #0 ${fn}_ref($pn) refs
			foreach ref $refs {
				upvar #0 ${fn}_geo($ref) buf
				if {[GetVal 2 $buf] != ""} {	;# it is a station
					return [GetIntDir1 $fn $ref $flag]
				}
			}
		}
	}
	return $ret
}

#
#	Create the list of geo data set names and row numbers to where there
#	is a shot (horizontal angle) & target has coordinates
#	Form returned list:
#	{{geo_set line_no point_number horizontal_angle} {...}}
#
#	@param fn geo data set name
#	@param ref start of station
#	@param flag 0 only fixed coordinates are usedd (code 38 37)
#				1 approximate coordinates are also used (code 38 37 138 137)
#	@return the list of geo data set names and row numbers
proc GetIntDir1 {fn ref {flag 0}} {
	global ${fn}_geo

	set r [expr {$ref + 1}]
	set ret ""
	while {1} {
		if {[info exists ${fn}_geo($r)] == 0} { break }
		upvar #0 ${fn}_geo($r) buf
		if {[GetVal 2 $buf] != ""} { break }	;# next station reached
		set pn [GetVal {5 62} $buf]				;# point number
		set hz [GetVal {7 21} $buf]				;# horiz angle
		if {$hz != "" && ([GetCoord $pn {38 37} $fn] != "" || \
			$flag && [GetCoord $pn {138 137} $fn] != "")} {
			lappend ret [list $fn $r $pn $hz]
		}
		incr r
	}
	return $ret
}

#
#	Create the list of geo data set names and row numbers from/to where there
#	is a distance & station/target has coordinates
#	Returned list format:
#	{ {geo_set line_no point_number distance vertical_angle} {...}}
#
#	@param pn point number
#	@param flag 0 only fixed coordinates are used (code 38 37)
#				1 approximate coordinates are also used (code 38 37 138 137)
#
#	Return the list of geo data set names and row numbers
proc GetDist {pn {flag 0}} {
	global geoLoaded
	global PI PI2
	global decimals

	set ret ""
	foreach fn $geoLoaded {
		global ${fn}_geo ${fn}_ref
		if {[info exists ${fn}_ref($pn)]} {		;# point has ref in data set
			upvar #0 ${fn}_ref($pn) refs
			foreach ref $refs {
				upvar #0 ${fn}_geo($ref) buf
				if {[GetVal 2 $buf] != ""} {	;# it is a station
					set r [expr {$ref + 1}]
					while {1} {
						if {[info exists ${fn}_geo($r)] == 0} { break }
						upvar #0 ${fn}_geo($r) buf
						# next station reached
						if {[GetVal 2 $buf] != ""} { break }
						set pnr [GetVal {5 62} $buf]	;# point number
						set di [GetVal 11 $buf]			;# horiz dist
						set va [expr {$PI / 2.0}]
						if {$di == ""} {
							set di [GetVal 9 $buf]		;# slope dist
							set va [GetVal 8 $buf]		;# vert. angle
						}
						if {$di != "" && $va != "" && \
							([GetCoord $pnr {38 37} $fn] != "" || \
							$flag && [GetCoord $pnr {138 137} $fn] != "")} {
							set di [format "%.${decimals}f" $di]
							lappend ret [list $fn $r $pnr $di $va]
						}
						incr r
					}
				} else {
					set di [GetVal 11 $buf]					;# horiz dist
					set va [expr {$PI / 2.0}]
					if {$di == ""} {
						set di [GetVal 9 $buf]				;# slope dist
						set va [GetVal 8 $buf]				;# vert. angle
					}
					if {$di != ""} {
						set pnr [GetLast $fn _geo $ref 2]
						if {$pnr != ""} {
							set di [format "%.${decimals}f" $di]
							lappend ret [list $fn $ref $pnr $di $va]
						}
					}
				}
			}
		}
	}
	set r ""
	foreach li $ret {
		set pn [lindex $li 2]
		if {[GetCoord $pn {38 37}] != "" || \
			$flag == 1 && [GetCoord $pn {138 137}] != ""} {
			lappend r $li
		}
	}
	return $r
}

#
#	Create the list of point name, horizontal distance, and bearing
#	Form of returned list:
#	{{point_number horiz_distance bearing DMS_bearing height} {...}}
#
#	@param pn point number
#	@param flag 0 only fixed coordinates are used (code 38 37)
#				1 approximate coordinates are also used (code 38 37 138 137)
#
#	@return the list of point name, horizontal distance, and bearing
proc GetPol {pn {flag 0}} {
	global geoLoaded
	global PI PI2
	global refr
	global decimals

	set ret ""
	foreach fn $geoLoaded {
		global ${fn}_geo ${fn}_ref
		if {[info exists ${fn}_ref($pn)]} {		;# point has ref in data set
			upvar #0 ${fn}_ref($pn) refs
			foreach ref $refs {
				upvar #0 ${fn}_geo($ref) buf
				if {[GetVal 2 $buf] != ""} {continue}	;# station
				set dir [GetVal {21 7} $buf]
				if {$dir == "" || [GetVal {9 11} $buf] == ""} {
					continue				;# no horizontal angle or distance
				}
				set strec [GetLastRec $fn _geo $ref 2]	;# get last station rec
				set stpn [GetVal 2 $strec]				;# station name
				if {[GetCoord $stpn {38 37}   $fn] == "" && $flag == 0 || \
					[GetCoord $stpn {138 137} $fn] == "" && $flag} {
					continue				;# no coord for station
				}
				set z [GetVal 101 $strec]				;# mean orientation
				if {$z == "" && $flag} {
					set z [GetVal 103 $strec]			;# approx mean ori
				}
				if {$z == ""} {continue}				;# no orientation
				set delta [expr {$z + $dir}]
				while {$delta > $PI2} {
					set delta [expr {$delta - $PI2}]
				}
				set hdist [GetVal 11 $buf]			;# horiz dist
				set va [GetVal 8 $buf]				;# vertical angle
				set dm [GetVal 10 $buf]				;# height diff.
				set pcode [GetVal 4 $buf]			;# point code
				if {$hdist == ""} {
					set sdist [GetVal 9 $buf]			;# slope dist
					if {($va == "" && $dm =="") || $sdist == ""} {
						continue		;# slope dist without vert. angle or dm
					}
					if {$va != ""} {
						set hdist [expr {$sdist * sin($va)}]
					} else {
						set hdist [expr {sqrt($sdist*$sdist - $dm*$dm)}]
					}
				}
				if {$hdist == ""} { continue }
				# reduction only to see level & projection
				set hdist [GetRedDist $hdist]

				set sth [GetVal {3 6} $strec]				;# instrument height
				set h [GetVal 6 $buf]					;# signal height
				if {$h == ""} {set h 0}					;# default signal height
				set stcoo [GetCoord $stpn 39 $fn]		;# height of station
				if {$stcoo == "" && $flag} {
					set stcoo [GetCoord $stpn 139 $fn]
				}
				if {$stcoo != "" && $dm != ""} {
					set height [expr {[GetVal {39 139} $stcoo] + $dm}]
					# refraction
					if {$refr && $hdist > 400} {
						set height [expr {$height + [GetRefr $hdist]}]
					}
					lappend ret [list $stpn [format "%.${decimals}f" $hdist] $delta \
						[DMS $delta] [format "%.${decimals}f" $height] $pcode]
				} elseif {$stcoo != "" && $sth != "" && $h != "" && $va != ""} {
					set height [expr {[GetVal {39 139} $stcoo] + $sth + \
						$hdist / tan($va) - $h}]
					# refraction
					if {$refr && $hdist > 400} {
						set height [expr {$height + [GetRefr $hdist]}]
					}
					lappend ret [list $stpn [format "%.${decimals}f" $hdist] $delta \
						[DMS $delta] [format "%.4f" $height] $pcode]
				} else {
					set height ""
					lappend ret [list $stpn [format "%.${decimals}f" $hdist] $delta \
						[DMS $delta] $height $pcode]
				}
			}
		}
	}
	return $ret
}

#
#	Calculate refraction correction for trigonomertic height
#	correction = (1 - k) * di^2 / 2 / R
#
#	@param di distance
#
#	Return refraction correction
proc GetRefr {di} {
	global R

	return [expr {0.86 * $di * $di / 2.0 / $R}]
}

#
#	Create the list of geo data set names and row numbers from/to where there
#	is a height difference & station/target has coordinates
#	Format of returned list:
#	{{geo_set line_no point_number abs_height horiz_distance} {...}}
#
#	@param pn point number
#	@param flag 0 only final elevations are considered
#				1 approximate elevations are also used
#
#	@return the list of geo data set names and row numbers
proc GetEle {pn {flag 0}} {
	global geoLoaded
	global PI PI2
	global projRed avgH stdAngle stdDist1 stdDist2 refr
	global decimals
	set ret ""
	foreach fn $geoLoaded {
		global ${fn}_geo ${fn}_ref
		if {[info exists ${fn}_ref($pn)]} {		;# point has ref in data set
			upvar #0 ${fn}_ref($pn) refs
			foreach ref $refs {
				upvar #0 ${fn}_geo($ref) buf
				if {[GetVal 2 $buf] != ""} {
					# it is a station
					set stcoo [GetCoord $pn {38 37} $fn]
					if {$stcoo == "" && $flag == 1} {
						set stcoo [GetCoord $pn {138 137} $fn]
					}
					set sth [GetVal {3 6} $buf]			;# station height
					set r [expr {$ref + 1}]
					while {1} {
						if {[info exists ${fn}_geo($r)] == 0} { break }
						upvar #0 ${fn}_geo($r) buf
						# next station reached ?
						if {[GetVal 2 $buf] != ""} { break }
						set pnr [GetVal {5 62} $buf]	;# point number
						set va [GetVal 8 $buf]			;# vert. angle
						set h [GetVal 6 $buf]			;# signal height
						set dm [GetVal {10 120} $buf]			;# height diff.
						if {$h == ""} { set h 0 }		;# signal height default
						set di ""
						set pnrcoo ""			;# horizontal coords for target
						set pnrz [GetCoord $pnr {39}]		;# height for target
						if {$pnrz == "" && $flag == 1} {
							set pnrz [GetCoord $pnr {139}]
						}
						if {$pnrz != "" && ($va != "" || $dm != "")} {	;# zenit or dm available
							if {$di == ""} {
								set di [GetVal 11 $buf]		;# horiz distance
							}
							if {$di == ""} {
								set di [GetVal 9 $buf]	;# slope dist
								if {$di != ""} {
									if {$va != ""} {
										# calculate horiz dist
										set di [expr {$di * sin($va)}]
									} else {
										# calculate horiz dist
										set di [expr {sqrt($di*$di-$dm*$dm)}]
									}
								}
							}
							# get target horizontal coordinates
							set pnrcoo [GetCoord $pnr {38 37} $fn]
							if {$pnrcoo == "" && $flag == 1} {
								set pnrcoo [GetCoord $pnr {138 137} $fn]
							}
							if {$di == ""} {
								if {$stcoo != "" && $pnrcoo != "" && \
									[GetVal {37 137} $stcoo] != "" && \
									[GetVal {38 138} $stcoo] != "" && \
									[GetVal {37 137} $pnrcoo] != "" && \
									[GetVal {38 138} $pnrcoo] != ""} {
									set di [Distance [GetVal {38 138} $stcoo] \
										[GetVal {37 137} $stcoo] \
										[GetVal {38 138} $pnrcoo] \
										[GetVal {37 137} $pnrcoo]]
								}
							}
# if no distance then use unit weight for approximate coordinates
							if {$di == "" && $flag == 1 && $dm != ""} {
								set di 1
							}
							if {$di != "" } {
								if {[GetVal {39 139} $pnrz] != ""}  {
									if {$dm != ""} {
										set height [expr { \
											[GetVal {39 139} $pnrz] - $dm}]
										if {$refr && $di > 400} {
											set height [expr { \
												$height - [GetRefr $di]}]
										}
										lappend ret [list $fn $r $pnr \
											[format "%.${decimals}f" $height] \
											[format "%.${decimals}f" $di]]
									} elseif {$sth != ""} {
										set height [expr { \
											[GetVal {39 139} $pnrz] - \
											$di / tan($va) - $sth + $h}]
										if {$refr && $di > 400} {
											set height [expr { \
												$height - [GetRefr $di]}]
										}
										lappend ret [list $fn $r $pnr \
											[format "%.${decimals}f" $height] \
											[format "%.${decimals}f" $di]]
									}
								}
							}
						}
						incr r
					}
				} else {
					set va [GetVal 8 $buf]			;# vert. angle
					set h [GetVal 6 $buf]			;# signal height
					set dm [GetVal {10 120} $buf]	;# height diff
					if {$h == ""} { set h 0 }		;# default signal height 0
					set xxx [GetLastRec $fn _geo $ref 2]
					set sth [GetVal {3 6} $xxx]		;# instrument height
					set pnr [GetVal 2 $xxx]			;# station
					set pnrz [GetCoord $pnr {39} $fn]		;# magassag is !!!
					if {$pnrz == "" && $flag == 1} {
						set pnrz [GetCoord $pnr {139} $fn]
					}
					set di ""
					if {$pnrz != "" && ($sth != "" && $va != "" || $dm != "")} {
						set di [GetVal 11 $buf]				;# horiz dist
						if {$di == ""} {
							set di [GetVal 9 $buf]			;# slope dist
							if {$di != ""} {
								if {$va != ""} {
									set di [expr {$di * sin($va)}];# horiz dist
								} else {
									set di [expr {sqrt($di*$di-$dm*$dm)}]
								}
							}
						}
						if {$di == ""} {
							set pnrcoo [GetCoord $pnr {38 37} $fn]
							if {$pnrcoo == "" && $flag == 1} {
								set pnrcoo [GetCoord $pnr {138 137} $fn]
							}
							set pncoo [GetCoord $pn {38 37} $fn]
							if {$pncoo == "" && $flag == 1} {
								set pncoo [GetCoord $pn {138 137} $fn]
							}
							if {[GetVal {38 138} $pncoo] != "" && \
									[GetVal {37 137} $pncoo] != "" && \
									[GetVal {38 138} $pnrcoo] != "" && \
									[GetVal {37 137} $pnrcoo] != ""} {
								set di [Distance [GetVal {38 138} $pncoo] \
										[GetVal {37 137} $pncoo] \
										[GetVal {38 138} $pnrcoo] \
										[GetVal {37 137} $pnrcoo]]
							}
						}
# if no distance use unit weight for approximate coords
						if {$di == "" && $flag == 1 && $dm != ""} {
							set di 1
						}
						if {$di != ""} {
							if {$dm != ""} {
								set height [expr {[GetVal {39 139} $pnrz] + $dm}]
								if {$refr && $di > 400} {
									set height [expr {$height + [GetRefr $di]}]
								}
							} else {
								set height [expr { \
									[GetVal {39 139} $pnrz] + $di / tan($va) + $sth - $h}]
								if {$refr && $di > 400} {
									set height [expr {$height + [GetRefr $di]}]
								}
							}
							lappend ret [list $fn $ref $pnr \
								[format "%.${decimals}f" $height] \
								[format "%.${decimals}f" $di]]
						}
					}
				}
			}
		}
	}
	return $ret
}

#
#	Find the most recent value of the first code found from the list
#
#	@param fn geo data set name
#	@param type geo data set type (geo, coo etc)
#	@parma pos position to start from the search
#	@param codes list of codes to look for
#
#	@return the most recent value of the first code found from the list
proc GetLast {fn type pos codes} {
	global ${fn}${type}
	global geoEasyMsg

	set j [expr {$pos - 1}]
	while {$j >= 0} {
		upvar #0 ${fn}${type}($j) buf1
		set st [GetVal $codes $buf1]
		if {$st != ""} {		;# code found
			return $st
		}
		incr j -1
	}
	return ""
}

#
#	Get the most recent record of the first code found from the list
#
#	@param fn geo data set name
#	@param type geo data set type (_geo, _coo etc)
#	@param pos position to start from
#	@param codes list of previous codes to look for
#
#	@return the most recent record of the first code found from the list
proc GetLastRec {fn type pos codes} {
	global ${fn}${type}
	global geoEasyMsg

	set j [expr {$pos - 1}]
	while {$j >= 0} {
		upvar #0 ${fn}${type}($j) buf1
		set st [GetVal $codes $buf1]
		if {$st != ""} {		;# code found
			return $buf1
		}
		incr j -1
	}
	return ""
}

#
#	Collect possible next point in traverse or trigonometric line.
#	It must also be station. It returns a list of possible point names.
#
#		prev - a list of {geo_set line point_name}
#		stat - list of station names
#		given- list of point having coordinates (final)
#
#	Return possible next point in traverse or trigonometric line
proc GetShootedPoints {prev} {
	set ret ""
	set geo [lindex $prev 0]
	global ${geo}_geo
	set index [expr {[lindex $prev 1] + 1}]
	while {[info exists ${geo}_geo($index)]} {
		# next station reached
		if {[GetVal 2 [set ${geo}_geo($index)]] != ""} { break }
		set pn [GetVal {5 62} [set ${geo}_geo($index)]]
# complex condition removed for free traverse endpoint
#		if {$pn != "" && ([lsearch -exact $stat $pn] != -1 || \
#				[lsearch -exact $given $pn] != -1) && \
#				$pn != [lindex $prev 2]} 
		if {$pn != "" && $pn != [lindex $prev 2]} {
			lappend ret $pn
		}
		incr index
	}
	return $ret
}

#
#	Sum up all references from all loaded geo data set to a point
#
#	@param pn point number
#	@return  number of references to point
proc GetSumRef {pn} {
	global geoLoaded

	set sum 0
	foreach fn $geoLoaded {
		global ${fn}_ref
		if {[info exists ${fn}_ref($pn)]} {		;# point has ref in data set
			upvar #0 ${fn}_ref($pn) refs
			incr sum [llength $refs]
		}
	}
	return $sum
}

#
#	Get point code (4) value for point number
#	The first point code value is returned even if different
# 	point codes are given in the data sets.
#	First coordinates, then observation are checked
#
#	@param pn point number
#	@param coo 1: check first coordinate list then observations
#             0: check only observations
proc GetPCode {pn {coo 0}} {
	global geoLoaded

	# search in coordinates
	if {$coo} {
		foreach fn $geoLoaded {
			global ${fn}_coo
			if {[info exists ${fn}_coo($pn)]} {	;# point has coord in data set
				upvar #0 ${fn}_coo($pn) buf
				set ret [string trim [GetVal 4 $buf]]
				if {[string length $ret] > 0} {
					return $ret
				}
			}
		}
	}

	# search in observations
	foreach fn $geoLoaded {
		global ${fn}_ref ${fn}_geo
		if {[info exists ${fn}_ref($pn)]} {		;# point has ref in data set
			upvar #0 ${fn}_ref($pn) refs
			foreach ref $refs {
				upvar #0 ${fn}_geo($ref) buf
				set ret [string trim [GetVal 4 $buf]]
				if {[string length $ret] > 0} {
					return $ret
				}
			}
		}
	}
	return ""
}

#
#	Consistency check of a single geo data set
#	@param name name of geo or coo data set (with _geo or _coo)
#	@return none
proc CheckGeo {name mustHave together notTogether} {
	global $name
	global geoEasyMsg

	# list of array indices increasing order
	set indices [lsort -dictionary [array names ${name}]]
	set n 0
	GeoLog1
	GeoLog "$geoEasyMsg(check) $name"
	set station ""
	set dirs ""
	foreach i $indices {
		upvar #0 ${name}($i) buf

		if {[string match "*_geo" $name]} {
			if {[GetVal 2 $buf] != ""} {
				set station [GetVal 2 $buf]
				set dirs ""
			} elseif {[GetVal {5 62} $buf] != ""} {
				set pn [GetVal {5 62} $buf]
				if {$station == $pn} {
					GeoLog1 [format $geoEasyMsg(stationpn) $pn [expr {$i + 1}]]
					incr n
				} elseif {$station == ""} {
					GeoLog1 [format $geoEasyMsg(missingstation) \
						[expr {$i + 1}]]
					incr n
				}
				if {[lsearch -exact $dirs $pn] != -1} {
					GeoLog1 [format $geoEasyMsg(doublepn) $pn [expr {$i + 1}]]
					incr n
				}
				lappend dirs $pn
			}
		}
		if {[GetVal $mustHave $buf] == ""} {
			# error missing obligatory code
			if {[string match "*_geo" $name]} {
				GeoLog1 [format $geoEasyMsg(missing) [CodeNames $mustHave] \
					[expr {$i + 1}]]
			} else {
				GeoLog1 [format $geoEasyMsg(missing) [CodeNames $mustHave] $i]
			}
			incr n
		}
		foreach codes $together {
			set m 0
			set master [lindex $codes 0]
			if {[GetVal $master $buf] != ""} {
				foreach  code [lrange $codes 1 end] {
					if {[GetVal $code $buf] != ""} { incr m }
				}
				if {$m == 0} {
					# error missing code
					if {[string match "*_geo" $name]} {
						GeoLog1 [format $geoEasyMsg(together) \
							[CodeNames $codes] [expr {$i + 1}]]
					} else {
						GeoLog1 [format $geoEasyMsg(together) \
							[CodeNames $codes] $i]
					}
					incr n
				}
			}
		}
		foreach codes $notTogether {
			set m 0
			foreach  code $codes {
				if {[GetVal $code $buf] != ""} { incr m }
			}
			if {$m > 1} {
				# error invalide code combination
				if {[string match "*_geo" $name]} {
					GeoLog1 [format $geoEasyMsg(notTogether) \
						[CodeNames $codes] [expr {$i + 1}]]
				} else {
					GeoLog1 [format $geoEasyMsg(notTogether) \
						[CodeNames $codes] $i]
				}
				incr n
			}
		}
	}
	GeoLog1 [format $geoEasyMsg(numError) $n]
}

#
#	Create name list from codes
#
#   @param codes list of codes
#	@return code names separated by comma.
#
proc CodeNames {codes} {
	global geoCodes

	set w ""
	foreach code $codes {
		if {$w == ""} {
			set w $geoCodes($code)
		} else {
			set w "$w,$geoCodes($code)"
		}
	}
	return $w
}

#
#	Join all opened data set into one
#	@param none
#	@return none
proc GeoJoin { } {
	global geoLoaded
	global lastDir
	global geoEasyMsg
	global fileTypes

	if {[llength $geoLoaded] < 1} {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(-8) error 0 OK
		return
	}
	# get output name
	set typ [list [lindex $fileTypes [lsearch -glob $fileTypes "*.geo*"]]]
	set fn [tk_getSaveFile -filetypes $typ -initialdir $lastDir]
	set fn [string trim $fn]
	if {[string length $fn] == 0} {return}
	GeoLog "$geoEasyMsg(menuFileJoin) $geoLoaded \-\> $fn"
	set lastDir [file dirname $fn]
	set fn1 "[file rootname $fn].geo"
	set fn2 "[file rootname $fn].coo"
	# save observations
	if {[catch {set f1 [open $fn1 "w"]} errmsg] == 1} {
		tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK
		return
	}
	foreach dataSet $geoLoaded {
		global ${dataSet}_geo
		set lineno 0
		while {[info exists ${dataSet}_geo($lineno)]} {
			if {[catch {puts $f1 [set ${dataSet}_geo($lineno)]} errmsg] == 1} {
				tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK
				catch {close $f1}
				catch {file delete $fn1}
				return
			}
			incr lineno
		}
	}
	catch {close $f1}
	# save coordinates
	if {[catch {set f2 [open $fn2 "w"]} errmsg] == 1} {
		tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK
		return
	}
	foreach psz [GetAll] {
		set buf ""
		foreach dataSet $geoLoaded {
			global ${dataSet}_coo
			if {[info exists ${dataSet}_coo($psz)]} {
				foreach item [set ${dataSet}_coo($psz)] {
					set code [lindex $item 0]
					set val [lindex $item 1]
					if {[lsearch -glob $buf "$code *"] == -1} {
						lappend buf "$code $val"
					}
					switch -exact -- $code {
						37 -
						38 { set buf [DelVal {137 138} $buf] }
						39 { set buf [DelVal 139 $buf] }
						137 -
						138 { if {[GetVal {37 38} $buf] != ""} {
								set buf [DelVal {137 138} $buf]
							}
						}
						139 { if {[llength [GetVal 39 $buf]]} {
								set buf [DelVal 139 $buf]
							}
						}
					}
				}
			}
		}
		if {[llength $buf]} {	;# has it coordinates?
			if {[catch {puts $f2 $buf} errmsg] == 1} {
				tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK
				catch {close $f1}
				catch {close $f2}
				catch {file delete $fn1}
				catch {file delete $fn2}
				return
			}
		}
	}
	catch {close $f2}
}

#
#	Save parameters to geo_easy.msk file
#	@param none
#	@return none
proc GeoSaveParams {} {
	global geoEasyMsg
# global variables a msk file
	global geoLang geoCp
	global autoRefresh
	global projRed avgH stdAngle stdDist1 stdDist2 refr stdLevel
	global maxColl maxIndex
	global cooSep
	global txtSep multiSep txtFilter header
	global decimals
	global detailreg
	global oriDetail
	global lastDir
	global maxIteration epsReg
	global browser
	global rtfview
	global dxfview
	global geoMaskColors
	global geoObsColor geoLineColor geoFinalColor geoApprColor geoStationColor \
		geoOrientationColor geoNostationColor
	global defaultObservations defaultDetails defaultPointNumbers \
		defaultUsedPointsOnly defaultCodedLines
	global geoMasks geoMaskParams geoMaskDefault
	global cooMasks cooMaskParams cooMaskDefault
	global parMask
	global geoFormHeaders geoForms geoFormParams geoFormPat
	global cooFormHeaders cooForms cooFormParams cooFormPat
	global maskRows
	global regLineStart regLineCont regLineEnd regLine
    global rp dxpn dypn dxz dyz spn sz pon zon slay pnlay zlay p3d pd zdec \
	        pcodelayer bname battr block ptext xzplane
	global polyStyle

	# backup original params
	catch {file copy -force "geo_easy.msk" "geo_easy.msk.bak"}
	set fn "geo_easy.msk"
	set oldfn "geo_easy.msk.bak"
	if {[catch {set fi [open $oldfn "r"]} errmsg] == 1} {
		tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK
		return
	}
	if {[catch {set f [open $fn "w"]} errmsg] == 1} {
		tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK
		return
	}
	# read msk file and replace values
	while {! [eof $fi]} {
		gets $fi buffer
		if {[regexp "^\[ \t\]*set " $buffer]} {
			set n [expr {[string first "set" $buffer] + 2}]
			puts -nonewline $f [string range $buffer 0 $n]
			incr n
			set buffer [string range $buffer $n end]
			set n 0
			# start of second word
			while {[regexp "\[ \t\]" [string index $buffer $n]]} {
				puts -nonewline $f [string index $buffer $n]
				incr n
			}
			set buffer [string range $buffer $n end]
			set n 0
			set varname ""
			# get variable name
			while {[regexp "\[^ \t\]" [string index $buffer $n]]} {
				append varname [string index $buffer $n]
				puts -nonewline $f [string index $buffer $n]
				incr n
			}
			set buffer [string range $buffer $n end]
			puts -nonewline $f " \{"
			if {[info exist $varname]} {
				puts -nonewline $f [set $varname]
			} else {
				tk_dialog .msg "Error" "Variable not found $varname" error 0 OK
			}
			puts $f "\}"
		} else {
			puts $f $buffer
		}
	}
	catch {close $f}
	catch {close $fi}
	GeoLog $geoEasyMsg(msgsave)
}

#
#	Dump GeoEasy data set.
#	@param fn name of GeoEasy data set
#	@param nn new path name of geo data set  without extension (optional)
#	@return none
proc TxtOut {fn {nn ""}} {
	global geoLoaded
	global geoLoadedDir
	global tcl_platform
	global geoEasyMsg
	global decimals

#
#	open geo data file & coordinate file
#
	if {$nn != ""} {
		set fulln $nn
	} elseif {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8			;# geo data set not loaded
		}
		set fulln [file rootname [lindex $geoLoadedDir $pos]]
	} else {
		return ""
	}
	if {[catch {set f1 [open $fulln w]}] != 0} {
		return -6
	}
#
#	save station and observation records
#
	global ${fn}_geo
	set lineno 0
	set stpn ""
	set ih ""
	while {[info exists ${fn}_geo($lineno)]} {
		set rec [set ${fn}_geo($lineno)]
		if {[GetVal {2} $rec] != ""} {
			# station record
			set stpn [GetVal {2} $rec]
			set ih [GetVal {3} $rec]
		} else {
			# observation record
			set hz [GetVal {7 21} $rec]
			if {$hz != ""} { set hz [string trim [DMS $hz]] }
			set v [GetVal {8} $rec]
			if {$v != ""} { set v [string trim [DMS $v]] }
			set d [GetVal {9 11} $rec]
			if {$d != ""} { set d [format "%.${decimals}f" $d] }
			set th [GetVal {6} $rec]
			if {$th != ""} { set th [format "%.${decimals}f" $th] }

			puts $f1 "$stpn;[GetVal {5 62} $rec];$hz;$v;$d;$th;$ih"
		}
		incr lineno
	}
	close $f1
	return 0
}
#
#	Set save as filter for points
#	TBD not used yet
#	@param none
#	@return none
proc GeoSaveFilter {} {
global geoFilter

	FilterParams
	tkwait window .filterparams
}

#
#	Point filter dialog
#	filtering modes all/regexp/interval/rect
#	TBD not used yet
#	@param none
#	@return none
proc FilterParams {} {
	global geoFilter
	global buttonid
	global geoEasyMsg

	set w [focus]
	if {$w == ""} { set w "." }
	set this .filterparams
	set buttonid 0
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}
	
	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(filterpar)
	wm resizable $this 0 0
	wm transient $this [winfo toplevel $w]
	catch {wm attribute $this -topmost}
	radiobutton $this.all -text $geoEasyMsg(allpoints) -variable x
	radiobutton $this.pointno -text $geoEasyMsg(pointno) -variable x
	radiobutton $this.pointrect -text $geoEasyMsg(pointrect) -variable x
	radiobutton $this.pointcode -text $geoEasyMsg(pointcode) -variable x

}
