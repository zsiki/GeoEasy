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

#	Save coordinates to Tracmaker txt format, convert to WGS84
#	@param fn geo data set name
#	@param rn file name
#	@return 0 on success
proc TrackmakerOut {fn rn} {
	global geoEasyMsg geoCodes
	global geoLoaded
	global ${fn}_coo ${fn}_par
	global tcl_platform
	global epsg proj_zfac proj_zoffs proj_preserv
	global buttonid
	global reg

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	# get source params
	ProjPar
	tkwait window .projparams
	if {$buttonid} { return }
	if {[regexp $reg(1) $epsg] == 0 || [regexp $reg(2) $proj_zfac] == 0 || \
		[regexp $reg(2) $proj_zoffs] == 0} {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
			error 0 OK
		return
	}
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
	set tr_coords [cs2cs $epsg 4326 $coords]
	for {set i 0} {$i < [llength $tr_coords]} { incr i} {
		set tr_coord [lindex $tr_coords $i]
		set pn [lindex $tr_coord 0]
		set pc [lindex $tr_coord 1]
		set lambda [lindex $tr_coord 2]
		set fi [lindex $tr_coord 3]
		if {$proj_preserv} {
			set coord [lindex $coords $i]
			set z [lindex $coord 4]
		} else {
			set z [expr {[lindex $tr_coord 4] * $proj_zfac + $proj_zoffs}]
		}
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
	global epsg proj_zfac proj_zoffs proj_preserv
	global buttonid
	global reg

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	# get source params
	ProjPar
	tkwait window .projparams
	if {$buttonid} { return }
	if {[regexp $reg(1) $epsg] == 0 || [regexp $reg(2) $proj_zfac] == 0 || \
		[regexp $reg(2) $proj_zoffs] == 0} {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
			error 0 OK
		return
	}

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
	set tr_coords [cs2cs $epsg 4326 $coords]
	set t [clock seconds]
	set d [clock format $t -format "%Y-%m-%d"]T[clock format $t -format "%H:%M:%S"]Z
	set f [open $rn w]
	puts $f "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
	puts $f "<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" creator=\"GeoEasy\" version=\"1.1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">"
	puts $f "<metadata><link href=\"digikom.hu\"><text>DigiKom Ltd</text></link><time>$d</time>"
	set wpt "</metadata>"
	set minlat 90
	set maxlat -90
	set minlon 180
	set maxlon -180
	# go through coordinates
	for {set i 0} {$i < [llength $tr_coords]} { incr i} {
		set tr_coord [lindex $tr_coords $i]
		set pn [lindex $tr_coord 0]
		set pc [lindex $tr_coord 1]
		if {[string length $pc] == 0} { set pc $pn }
		set lambda [lindex $tr_coord 2]
		set fi [lindex $tr_coord 3]
		if {$proj_preserv} {
			set coord [lindex $coords $i]
			set z [lindex $coord 4]
		} else {
			set z [expr {[lindex $tr_coord 4] * $proj_zfac + $proj_zoffs}]
		}
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
	global epsg proj_zfac proj_zoffs proj_preserv
	global buttonid
	global reg

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	# get source params
	ProjPar
	tkwait window .projparams
	if {$buttonid} { return }
	if {[regexp $reg(1) $epsg] == 0 || [regexp $reg(2) $proj_zfac] == 0 || \
		[regexp $reg(2) $proj_zoffs] == 0} {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
			error 0 OK
		return
	}
	set t [clock seconds]

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
	set tr_coords [cs2cs $epsg 4326 $coords]
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
	# go through coordinates
	for {set i 0} {$i < [llength $tr_coords]} { incr i} {
		set tr_coord [lindex $tr_coords $i]
		set pn [lindex $tr_coord 0]
		set pc [lindex $tr_coord 1]
		if {[string length $pc] == 0} { set pc $pn }
		set lambda [lindex $tr_coord 2]
		set fi [lindex $tr_coord 3]
		if {$proj_preserv} {
			set coord [lindex $coords $i]
			set z [lindex $coord 4]
		} else {
			set z [expr {[lindex $tr_coord 4] * $proj_zfac + $proj_zoffs}]
		}
		puts $f "<Placemark>"
		puts $f "  <name>$pn</name>"
		puts $f "  <ExtendedData><SchemaData schemaUrl=\"#$name\">"
		puts $f "    <SimpleData name=\"time\">$d</SimpleData>"
		puts $f "    <SimpleData name=\"cmt\">$pc</SimpleData>"
		puts $f "    <SimpleData name=\"sym\">Waypoint</SimpleData>"
		puts $f "  </SchemaData></ExtendedData>"
		puts $f "  <Point><coordinates>$lambda,$fi,$z</coordinates></Point>"
		puts $f "</Placemark>"
	}
	puts $f "</Folder>"
	puts $f "</Document></kml>"
	close $f
	return 0
}

#
#	Set proj params
proc ProjPar {} {
	global geoEasyMsg
	global epsg proj_zfac proj_zoffs proj_preserv
	global buttonid

	set w [focus]
	if {$w == ""} { set w "." }
	set this .projparams
	set buttonid 0
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(projpar)
	wm resizable $this 0 0
	wm transient $this [winfo toplevel $w]
	catch {wm attribute $this -topmost}

	label $this.lepsg -text $geoEasyMsg(fromEpsg)
	checkbutton $this.preserv -text $geoEasyMsg(preservz) \
		-variable proj_preserv -command "preserv $this \$proj_preserv"
	label $this.lzfac -text $geoEasyMsg(zfaclabel)
	label $this.lzoffs -text $geoEasyMsg(zoffslabel)
	entry $this.epsg -textvariable epsg -width 10
	entry $this.zfac -textvariable proj_zfac -width 10
	entry $this.zoffs -textvariable proj_zoffs -width 10

	grid $this.lepsg -row 0 -column 0 -sticky w
	grid $this.epsg -row 0 -column 1 -sticky w
	grid $this.preserv -row 1 -column 0 -sticky w -columnspan 2
	grid $this.lzfac -row 2 -column 0 -sticky w
	grid $this.zfac -row 2 -column 1 -sticky w
	grid $this.lzoffs -row 3 -column 0 -sticky w
	grid $this.zoffs -row 3 -column 1 -sticky w

	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"
	grid $this.exit -row 4 -column 0
	grid $this.cancel -row 4 -column 1
	tkwait visibility $this
	CenterWnd $this
	grab set $this

	preserv $this $proj_preserv
}

#
#	set enable/disable in proj dialog
#	@param this
#	@param flag
proc preserv {this flag} {
	if {$flag} {
		$this.zfac configure -state disabled -foreground grey
		$this.zoffs configure -state disabled -foreground grey
	} else {
		$this.zfac configure -state normal -foreground black
		$this.zoffs configure -state normal -foreground black
	}
}

#
#	Setup default values for proj parameters
proc ProjSet {} {
	global epsg proj_zfac proj_zoffs proj_preserv

	set epsg ""
	set proj_zfac 1
	set proj_zoffs 0
	set proj_preserv 1
}
