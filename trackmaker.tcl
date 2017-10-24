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

#	Save coordinates to Tracmaker txt format, convert EOV to WGS84
#	@param fn geo data set name
#	@param rn file name
#	@return 0 on success
proc TrackmakerOut {fn rn} {
	global geoEasyMsg
	global geoLoaded
	global ${fn}_coo
	global tcl_platform

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	set t [clock seconds]
	set d [clock format $t -format "%m/%d/%Y"]
	set t [clock format $t -format "%H:%M:%S"]
	set f [open $rn w]
	puts $f "Version,212\n"
	puts $f "WGS 84 (GPS),217, 6378137, 298.257223563, 0, 0, 0"
	puts $f "USER GRID,0,0,0,0,0\n"
#	puts $f "Datum,WGS84,WGS84,0,0,0,0,0"
	set line 0
	set fi 0
	set lambda 0
	set noconvert ""
	# go through coordinates
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
			if {$x > 400000.0 && $x < 1100000 && $y > 0 && $y < 400000} {
				incr line
				set fi [wgsfi $x $y]
				set lambda [wgslambda $x $y]
				puts $f "w,d,$pn,$fi,$lambda,$pc,$d,$t,$z,0,0"
#				puts $f "WP,D,$pn,$fi,$lambda,$d,$t,$pc"
			} else {
				lappend noconvert $pn
			}
		}
	}
	if {[llength $noconvert]} {
		GeoListbox $noconvert 0 $geoEasyMsg(noConvert) 0
	}
	close $f
	return 0
}

#
#	Save coordinates to GPX format, convert EOV to WGS84
#	@param fn geo data set name
#	@param rn file name
#	@return 0 on success
proc GpxOut {fn rn} {
	global geoEasyMsg
	global geoLoaded
	global ${fn}_coo
	global tcl_platform

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	set t [clock seconds]
	set d [clock format $t -format "%Y-%m-%d"]T[clock format $t -format "%H:%M:%S"]Z
	set f [open $rn w]
	puts $f "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
	puts $f "<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" creator=\"GeoEasy\" version=\"1.1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">"
	puts $f "<metadata><link href=\"digikom.hu\"><text>DigiKom Ltd</text></link><time>$d</time>"
	set wpt "</metadata>"
	set line 0
	set noconvert ""
	set minlat 90
	set maxlat -90
	set minlon 180
	set maxlon -180
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
			if {$x > 400000.0 && $x < 1100000 && $y > 0 && $y < 400000} {
				incr line
				set fi [wgsfi $x $y]
				if {$fi < $minlat} { set minlat $fi }
				if {$fi > $maxlat} { set maxlat $fi }
				set lambda [wgslambda $x $y]
				if {$lambda < $minlon} { set minlon $lambda }
				if {$lambda > $maxlon} { set maxlon $lambda }
				set wpt "$wpt<wpt lat=\"$fi\" lon=\"$lambda\"><time>$d</time><name>$pn</name><cmt>$pc</cmt><desc>$pc</desc><sym>Waypoint</sym></wpt>"
			} else {
				lappend noconvert $pn
			}
		}
	}
	if {[llength $noconvert]} {
		GeoListbox $noconvert 0 $geoEasyMsg(noConvert) 0
	}
	# minimax
	puts $f "<bounds minlat=\"$minlat\" minlon=\"$minlon\" maxlat=\"$maxlat\" maxlon=\"$maxlon\"/>"
	puts $f $wpt
	puts $f "</gpx>"
	close $f
	return 0
}
