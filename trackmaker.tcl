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

# transformation between coordinate reference systems
# using cs2cs (from proj.4 project) and temperary files
# @param source epsg code of sourcce reference system
# @param destination epsg code of destination reference system
# @param coords source coordinates lists pn pc east north elev
# @return list of converted coordinates
proc cs2cs {from_epsg to_epsg coords} {
	global geoEasyMsg
	global env

	set res ""
    if {[info exists env(TMP)]} {
        set tmpdir $env(TMP)
    } elseif {[info exists env(TEMP)]} {
        set tmpdir $env(TEMP)
    } else {
        set tmpdir "."
    }
    set tmpname [file join  $tmpdir tmp.txt]
    set tmp1name [file join  $tmpdir tmp1.txt]
    catch {file delete $tmpname $tmp1name]}
	set fp [open $tmpname w]
	foreach coord $coords {
		puts $fp [lrange $coord 2 end]
	}
	close $fp
	if {[catch {eval [concat exec "cs2cs -f \"%.7f\" +init=epsg:$from_epsg +to +init=epsg:$to_epsg < $tmpname > $tmp1name"]} msg]} {
		tk_dialog .msg $geoEasyMsg(error) $msg error 0 OK
		return
	}
	set fp1 [open $tmp1name r]
	set tr_coords [split [read $fp] "\n"]
	foreach coord $coords tr_coord $tr_coords {
		set tr [split [string trim $tr_coord "\r"] " \t"]
		if {[llength $tr] > 1} {
			lappend res [concat [lrange $coord 0 1] $tr]	
		}
	}
    catch {file delete $tmpname $tmp1name]}
	return $res
}

#	Save coordinates to Tracmaker txt format, convert to WGS84
#	@param fn geo data set name
#	@param rn file name
#	@return 0 on success
proc TrackmakerOut {fn rn} {
	global geoEasyMsg geoCodes
	global geoLoaded
	global ${fn}_coo ${fn}_par
	global tcl_platform

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	# get source epsg code
	set from_epsg [GeoEntry $geoCodes(140) $geoEasyMsg(fromEpsg)]
	if {$from_epsg == ""} { return }
	set t [clock seconds]
	set d [clock format $t -format "%m/%d/%Y"]
	set t [clock format $t -format "%H:%M:%S"]
	set f [open $rn w]
	puts $f "Version,212\n"
	puts $f "WGS 84 (GPS),217, 6378137, 298.257223563, 0, 0, 0"
	puts $f "USER GRID,0,0,0,0,0\n"
	set line 0
	set fi 0
	set lambda 0
	# go through coordinates
	set coords ""
	foreach pn [lsort -dictionary [array names ${fn}_coo]] {
		set pn [GetVal {5} [set ${fn}_coo($pn)]]
		set pc [GetVal {4} [set ${fn}_coo($pn)]]
		regsub -all "," $pc ";" pc
		if {[string length $pc] == 0} { set pc $pn }
		set x [GetVal {38} [set ${fn}_coo($pn)]]
		set y [GetVal {37} [set ${fn}_coo($pn)]]
		set z [GetVal {39} [set ${fn}_coo($pn)]]
		if {[string length $z] == 0} { set z 0 }
		if {[string length $x] && [string length $y]} {
			lappend coords [list $pn $pc $x $y $z]
		}
	}
	set tr_coords [cs2cs $from_epsg 4326 $coords]
	foreach tr_coord $tr_coords {
		incr line
		set pn [lindex $tr_coord 0]
		set pc [lindex $tr_coord 1]
		set lambda [lindex $tr_coord 2]
		set fi [lindex $tr_coord 3]
		set z [lindex $tr_coord 4]
		puts $f "w,d,$pn,$fi,$lambda,$pc,$d,$t,$z,0,0"
	}
	close $f
	return 0
}

#
#	Save coordinates to GPX format, convert to WGS84
#	@param fn geo data set name
#	@param rn file name
#	@return 0 on success
proc GpxOut {fn rn} {
	global geoEasyMsg geoCodes
	global geoLoaded
	global ${fn}_coo
	global tcl_platform
	global env

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	# get source epsg code
	set from_epsg [GeoEntry $geoCodes(140) $geoEasyMsg(fromEpsg)]
	if {$from_epsg == ""} { return }

	set coords ""
	# go through coordinates
	foreach pn [lsort -dictionary [array names ${fn}_coo]] {
		set pn [GetVal {5} [set ${fn}_coo($pn)]]
		set pc [GetVal {4} [set ${fn}_coo($pn)]]
		if {[string length $pc] == 0} { set pc $pn }
		set x [GetVal {38} [set ${fn}_coo($pn)]]
		set y [GetVal {37} [set ${fn}_coo($pn)]]
		set z [GetVal {39} [set ${fn}_coo($pn)]]
		if {[string length $z] == 0} { set z 0 }
		if {[string length $x] && [string length $y]} {
			lappend coords [list $pn $pc $x $y $z]
		}
	}
	set tr_coords [cs2cs $from_epsg 4326 $coords]
	set t [clock seconds]
	set d [clock format $t -format "%Y-%m-%d"]T[clock format $t -format "%H:%M:%S"]Z
	set f [open $rn w]
	puts $f "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
	puts $f "<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" creator=\"GeoEasy\" version=\"1.1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">"
	puts $f "<metadata><link href=\"digikom.hu\"><text>DigiKom Ltd</text></link><time>$d</time>"
	set wpt "</metadata>"
	set line 0
	set minlat 90
	set maxlat -90
	set minlon 180
	set maxlon -180
	# go through coordinates
	foreach tr_coord $tr_coords {
		incr line
		set pn [lindex $tr_coord 0]
		set pc [lindex $tr_coord 1]
		if {[string length $pc] == 0} { set pc $pn }
		set lambda [lindex $tr_coord 2]
		set fi [lindex $tr_coord 3]
		set z [lindex $tr_coord 4]
		if {[string length $z] == 0} { set z 0 }
		if {$fi < $minlat} { set minlat $fi }
		if {$fi > $maxlat} { set maxlat $fi }
		if {$lambda < $minlon} { set minlon $lambda }
		if {$lambda > $maxlon} { set maxlon $lambda }
		set wpt "$wpt<wpt lat=\"$fi\" lon=\"$lambda\"><time>$d</time><name>$pn</name><cmt>$pc</cmt><desc>$pc</desc><sym>Waypoint</sym></wpt>"
	}
	# minimax
	puts $f "<bounds minlat=\"$minlat\" minlon=\"$minlon\" maxlat=\"$maxlat\" maxlon=\"$maxlon\"/>"
	puts $f $wpt
	puts $f "</gpx>"
	close $f
	return 0
}

#
#	Save coordinates to KML format, convert to WGS84
#	@param fn geo data set name
#	@param rn file name
#	@return 0 on success
proc KmlOut {fn rn} {
	global geoEasyMsg geoCodes
	global geoLoaded
	global ${fn}_coo
	global tcl_platform
	global env

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	# get source epsg code
	set from_epsg [GeoEntry $geoCodes(140) $geoEasyMsg(fromEpsg)]
	if {$from_epsg == ""} { return }

	set coords ""
	# go through coordinates
	foreach pn [lsort -dictionary [array names ${fn}_coo]] {
		set pn [GetVal {5} [set ${fn}_coo($pn)]]
		set pc [GetVal {4} [set ${fn}_coo($pn)]]
		if {[string length $pc] == 0} { set pc $pn }
		set x [GetVal {38} [set ${fn}_coo($pn)]]
		set y [GetVal {37} [set ${fn}_coo($pn)]]
		set z [GetVal {39} [set ${fn}_coo($pn)]]
		if {[string length $z] == 0} { set z 0 }
		if {[string length $x] && [string length $y]} {
			lappend coords [list $pn $pc $x $y $z]
		}
	}
	set tr_coords [cs2cs $from_epsg 4326 $coords]
	set t [clock seconds]
	set d [clock format $t -format "%Y-%m-%d"]T[clock format $t -format "%H:%M:%S"]Z
	set f [open $rn w]
	puts $f "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
	puts $f "<kml xmlns=\"http://www.opengis.net/kml/2.2\">"
	puts $f "<Document id=\"root_doc\">"
	set name [file tail [file rootname $rn]]
	puts $f "<Schema name=\"$name\" id=\"$name\">"
	puts $f "  <SimpleField name=\"time\" type=\"string\"></SimpleField>"
	puts $f "  <SimpleField name=\"cmt\" type=\"string\"></SimpleField>"
	puts $f "  <SimpleField name=\"sym\" type=\"string\"></SimpleField>"
	puts $f "</Schema>"
	puts $f "<Folder><name>$name</name>"
	set line 0
	# go through coordinates
	foreach tr_coord $tr_coords {
		incr line
		set pn [lindex $tr_coord 0]
		set pc [lindex $tr_coord 1]
		if {[string length $pc] == 0} { set pc $pn }
		set lambda [lindex $tr_coord 2]
		set fi [lindex $tr_coord 3]
		puts $f "<Placemark>"
		puts $f "  <name>$pn</name>"
		puts $f "  <ExtendedData><SchemaData schemaUrl=\"#$name\">"
		puts $f "    <SimpleData name=\"time\">$d</SimpleData>"
		puts $f "    <SimpleData name=\"cmt\">$pc</SimpleData>"
		puts $f "    <SimpleData name=\"sym\">Waypoint</SimpleData>"
		puts $f "  </SchemaData></ExtendedData>"
		puts $f "  <Point><coordinates>$lambda,$fi</coordinates></Point>"
		puts $f "</Placemark>"
	}
	puts $f "</Folder>"
	puts $f "</Document></kml>"
	close $f
	return 0
}
