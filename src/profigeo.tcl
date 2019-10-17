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

#	Read in GeoProfi data files into memory
#	@param fn name of geoProfi mjk file
#	@return 0 on success
proc GeoProfi {fn} {
	global reg
	global gpCoo
	global geoCodes

	set gpCoo ""			;# name of releated coordinate file
	set fa [GeoSetName $fn]
	if {[string length $fa] == 0} {return 1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f1 [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	set obuf ""				;# output buffer
	set lines 0				;# number of lines in output
	set src 0				;# input line number
	set points 0			;# number of points in coord list
	set jm 0				;# default signal height
	set ${fa}_par [list [list 0 "GeoProfi import"]]
	while {! [eof $f1]} {
		incr src
		if {[gets $f1 buf] == 0} continue
		set rectype [string range $buf 0 1]
		switch -exact $rectype {
			MT { set gpCoo [string trim [string range $buf 3 15]] }
			AR { lappend ${fa}_par \
					[list 55 [string trim [string range $buf 3 15]]] }
			FN { lappend ${fa}_par \
					[list 53 [string trim [string range $buf 3 15]]] }
			DT { lappend ${fa}_par \
					[list 51 [string trim [string range $buf 3 15]]] }
			AP {
				# point number
				set pn [string trim [string range $buf 3 14]]
				set obuf ""
				lappend obuf [list 2 $pn]
				GeoLog1 "$geoCodes(2): $pn"
				# point code
				set w [string trim [string range $buf 16 25]]
				if {[string length $w] && $w != "..." && $w != "--------"} {
					lappend obuf [list 4 $w]
				}
				# station height
				set w [string trim [string range $buf 26 32]]
				if {[string length $w] > 0} {
					# check numeric value
					if {[regexp $reg(2) $w] == 0} { return $src }
					lappend obuf [list 3 $w]
				}
#				set jm 0	use previous signal height (Bence)
			}
			JM {
				set jm [string trim [string range $buf 3 8]]
				if {[string length $jm] > 0} {
					if {[regexp $reg(2) $jm] == 0} { return $src }
				} else { set jm 0 }	;# empty JM unset target height
			}
			RP -
			KE {
				# point number
				set pn [string trim [string range $buf 3 14]]
				set obuf ""
				lappend obuf [list 5 $pn]

				# point code
				set w [string trim [string range $buf 16 25]]
				if {[string length $w] && $w != "..." && $w != "--------"} {
					lappend obuf [list 4 $w]
				}
				# horizontal angle
				set w [string trim [string range $buf 27 34]]
				if {[string length $w] > 0} {
					set w [Deg2Rad $w]
					if {$w == "?"} { return $src }
					lappend obuf [list 7 $w]
				}
				# vertical angle
				set w [string trim [string range $buf 36 43]]
				if {[string length $w] > 0} {
					set w [Deg2Rad $w]
					if {$w == "?"} { return $src }
					lappend obuf [list 8 $w]
				}
				# slope distance
				set w [string trim [string range $buf 45 52]]
				if {[string length $w] > 0} {
					if {[regexp $reg(2) $w] == 0} { return $src }
					lappend obuf [list 9 $w]
				}
				if {$jm != 0} {
					lappend obuf [list 6 $jm]
				}
			}
		}
		if {$rectype == "AP" || $rectype == "RP" || $rectype == "KE"} {
			# check numeric values
			foreach l $obuf {
				if {[lsearch -exact \
						{3 6 7 8 9 10 11 21 24 25 26 27 28 29 37 38 39 49} \
						[lindex $l 0]] != -1 && \
						[regexp $reg(2) [lindex $l 1]] == 0} {
					return $src
				}
			}
			set ${fa}_geo($lines) $obuf
			if {[info exists ${fa}_ref($pn)] == -1} {
				set ${fs}_ref($pn) $lines
			} else {
				lappend ${fa}_ref($pn) $lines
			}
			incr lines
		}
	}
	close $f1
	return 0
}

#
#	Load geoprofi coordinate file.
#	Coordinate file format:
#		char pos
#		0-13	point number
#		14-23   Y coordinate
#       25-34   X coordinate
#		36-43   Z coordinate
#		44-		point code
#	@param fn name of geoprofi coordinate file
#	@param fmjk name of geoprofi mjk file (optional)
#	@return 0 on success
proc GeoProfiCoo {fn {fmjk ""}} {
	global reg
	global geoEasyMsg

	if {[string length $fmjk]} {
		# coordinates to observations
		set fa [GeoSetName $fmjk]
	} else {
		set fa [GeoSetName $fn]
	}
	if {[string length $fa] == 0} {return 1}
	global ${fa}_geo ${fa}_coo ${fa}_ref
	if {[catch {set f1 [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	set src 0				;# input line number
	set points 0			;# number of points in coord list
	while {! [eof $f1]} {
		set obuf ""
		incr src
		if {[gets $f1 buf] == 0} continue

		set pn [string trim [string range $buf 0 13] " ,"]
		# empty point number
		if {[string length $pn] == 0} { continue }
		lappend obuf [list 5 $pn]
		set x [string trim [string range $buf 14 23] " "]
		set y [string trim [string range $buf 25 34] " "]
		set z [string trim [string range $buf 36 43] " "]
		set code [string trim [string range $buf 44 80] " "]
		if {[regexp $reg(2) $x] == 0 || [regexp $reg(2) $y] == 0 || \
			[regexp $reg(2) $z] == 0} {
			close $f1
			return $src
		}
		if {$x != 0} { lappend obuf [list 38 $x] }
		if {$y != 0} { lappend obuf [list 37 $y] }
		if {$z != 0} { lappend obuf [list 39 $z] }
		if {[string length $code] > 0} { lappend obuf [list 4 $code] }
		# check for repeated point numbers
		if {[lsearch -exact [array names ${fa}_coo] $pn] != -1} {
			tk_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(dblPn): $pn" \
				warning 0 OK
			continue
		}
		set ${fa}_coo($pn) $obuf
	}
	return 0
}

#
#
#	Load coordinates from ascii text file
#	Text file can be separated by characters given in txtSep (geo_easy.msk)
#	Order of values can be set
#	If no point number given in input an ordinal number will be generated
#	@param fn name of txt file
#	@param ff format file optional
#	@return 0 on success
proc TxtCoo {fn {ff ""}} {
	global geoEasyMsg
	global reg
	global txtSep multiSep header txtFilter

	if {! [info exists txtSep] } { set txtSep "\t;" }
	if {! [info exists multiSep] } { set multiSep 0 }
	if {! [info exists header] } { set header 0 }
	if {! [info exists txtFilter] } { set txtFilter "" }
	set fa [GeoSetName $fn]
	if {[string length $fa] == 0} {return 1}
	global ${fa}_geo ${fa}_coo ${fa}_ref
	if {[catch {set f1 [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	set codes [TxtCols {5 38 37 39 4} {5 38 37 39 4 111 138 137 139} $fn $ff]	;# order of values
	if {[llength $codes] == 0} {
		return -999
	}
	set i [string first "\\t" $txtSep]
	set tab [format %c 9]	;# TAB char
	if {$i >= 0} { set txtSep [string replace $txtSep $i [expr {$i + 1}] $tab] }

	set npn [lsearch -exact $codes 5]	;# is point id in input?
	set src 0				;# input line number
	set points 0			;# number of points in coord list
	set nheader $header
	while {$nheader > 0} {
		gets $f1 buf
		incr src
		incr nheader -1
	}
	while {! [eof $f1]} {
		set obuf ""				;# output buffer
		incr src
		if {[gets $f1 buf] == 0} { continue }
		if {[string length $txtFilter] && [regexp $txtFilter $buf] == 0} {
			continue		;# filtered line
		}
		set buf [string trim $buf]		;# remove leading tailing spaces
		if {$multiSep}	{				;# remove adjecent separators
			set r1 "\[$txtSep\]"
			set r2 [string index $txtSep 0]
			while {[regsub -all "${r1}${r1}" $buf $r2 buf]} {}
		}
		set buflist [split $buf $txtSep]
		set n [llength $buflist]
		if {$n == 0} { continue }		;# empty line
		if {$npn >= 0} {
			set pn [lindex $buflist $npn]
		} else {
			set pn [expr $src - $header]
			lappend obuf [list 5 $pn]	;# add row number as point id
		}
		if {[string length $pn] > 0} {
			# point number given
			foreach code $codes val $buflist {
				if {[string length $code] > 0 && $code >= 0 && \
						[string length $val] > 0} {
					if {[lsearch -exact {38 37 39} $code] != -1} {
						# if "," is not separator and no "." in coord
						# replace "," width "."
						if {[string first "," $val] != -1 && [string first "." $val] == -1 && [string first "," $txtSep] == -1} {
							regsub "," $val "." val
						}
						# check numeric value
						if {[regexp $reg(2) $val] == 0} {
							close $f1
							return $src
						}
						#set val [format "%.4f" $val]
					}
					lappend obuf [list $code $val]
				}
			}
			# check for repeated point numbers
			if {[lsearch -exact [array names ${fa}_coo] $pn] != -1} {
				tk_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(dblPn): $pn" \
					warning 0 OK
				continue
			}
			set ${fa}_coo($pn) $obuf
		} else {
			close $f1
			return $src
		}
	}
	close $f1
	return 0
}

#
#	Save coordinates to text file
#	Text file fields are separated by cooSep global variable
#	Order will be point number Y X Z point_code, coordinates are optional.
#	@param fa name of geo data set
#	@param rn name of data file (.csv)
#	@return 0 on success
proc SaveTxt {fn rn} {
	global geoEasyMsg
	global geoLoaded
	global ${fn}_coo
	global cooSep
	global decimals

	# default separator is comma
	if {! [info exists cooSep] } { set cooSep "," }
	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	set f [open $rn w]
	# go through coordinates
	foreach pn [lsort -dictionary [array names ${fn}_coo]] {
		set x [GetVal {38} [set ${fn}_coo($pn)]]
		set y [GetVal {37} [set ${fn}_coo($pn)]]
		set z [GetVal {39} [set ${fn}_coo($pn)]]
		set code [GetVal {4} [set ${fn}_coo($pn)]]
		if {[string length $x] || [string length $y] || [string length $z]} {
			puts -nonewline $f $pn
			if {[string length $x]} {
				puts -nonewline $f [format "%s%.${decimals}f" $cooSep $x]
			} else { puts -nonewline $f "${cooSep}" }
			if {[string length $y]} {
				puts -nonewline $f [format "%s%.${decimals}f" $cooSep $y]
			} else { puts -nonewline $f "${cooSep}" }
			if {[string length $z]} {
				puts -nonewline $f [format "%s%.${decimals}f" $cooSep $z]
			} else { puts -nonewline $f "${cooSep}" }
			puts $f "${cooSep}$code"
		}
	}
	close $f
	return 0
}

#
#
#	Save coordinates to text file (ITR2.x compatible)
#	Text file fields are separated by , and space
#		point_number, y x z
#	Order will be point number Y X Z, Z is optional.
#	Missing Z coordinates are set to zero
#	Points without horizontal co-ordinates are skipped.
#	@param fa name of geo data set
#	@param rn name of data file (.txt)
#	@return 0 on success
proc SaveITR2 {fn rn} {
	global geoEasyMsg
	global geoLoaded
	global ${fn}_coo

	if {[info exists geoLoaded]} {
		set pos [lsearch -exact $geoLoaded $fn]
		if {$pos == -1} {
			return -8           ;# geo data set not loaded
		}
	} else {
		return 0
	}
	set f [open $rn w]
	# go through coordinates
	foreach pn [lsort -dictionary [array names ${fn}_coo]] {
		set x [GetVal {38} [set ${fn}_coo($pn)]]
		set y [GetVal {37} [set ${fn}_coo($pn)]]
		set z [GetVal {39} [set ${fn}_coo($pn)]]
		set code [GetVal {4} [set ${fn}_coo($pn)]]
		if {[string length $x] && [string length $y]} {
			set spaces [format "%[expr {14 - [string length $pn]}]s" " "]
			puts -nonewline $f "$pn,$spaces"
			puts -nonewline $f [format "%.3f  %.3f" $x $y]
			if {[string length $z] == 0} { set z 0 }
			puts $f [format "  %.3f" $z]
		}
	}
	close $f
	return 0
}

#
#	Select columns and order for txt output
#	@param codes list of possible columns
#	@param fn file name to load
#	@param ff format definition file (optional)
#	@return 0 on success
proc TxtCols {codes allCodes fn {ff ""}} {
	global geoCodes
	global geoEasyMsg
	global buttonid
	global txtSep locTxtSep multiSep locMultiSep header locHeader
	global txtFilter locTxtFilter
	global codelist
	global txpTypes
	global tmpAllCodes

	set tmpAllCodes $allCodes
	set codelist ""
	set locTxtSep "$txtSep"
	set locMultiSep $multiSep
	set locHeader $header
	set locTxtFilter $txtFilter
    set w [focus]
	if {$w == ""} { set w "." }
	set this .txtcols
	if {[winfo exists $this] == 1} {
        raise $this
        Beep
        return
    }

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(txtcols)
	wm resizable $this 0 0
	wm transient $this $w
	set buttonid -1

	frame $this.1
	frame $this.2
	frame $this.3
	frame $this.1.1
	frame $this.1.2
	frame $this.2.1
	frame $this.2.15
	frame $this.2.16
	frame $this.2.2
	pack $this.1 -side top -expand yes -fill both
	pack $this.1.1 $this.1.2 -side left
	pack $this.2 -side top -expand yes -fill both
	pack $this.2.1 $this.2.15 $this.2.16 $this.2.2 -side top -expand yes -fill both
	pack $this.3 -side bottom
	
	scrollbar $this.1.1.s -command "$this.1.1.l yview"
	listbox $this.1.1.l -width 20 -relief sunken -height 5 \
		-yscrollcommand "$this.1.1.s set" -setgrid yes
	button $this.1.2.up -text $geoEasyMsg(up) -state disabled -command {
		set i [.txtcols.1.1.l curselection]
		set t [.txtcols.1.1.l get $i]
		.txtcols.1.1.l delete $i
		incr i -1
		.txtcols.1.1.l insert $i $t
		c_state
	}
	button $this.1.2.down -text $geoEasyMsg(down) -state disabled -command {
		set i [.txtcols.1.1.l curselection]
		set t [.txtcols.1.1.l get $i]
		.txtcols.1.1.l delete $i
		incr i
		.txtcols.1.1.l insert $i $t
		c_state
	}
	button $this.1.2.add -text $geoEasyMsg(add) -command {
		global tmpAllCodes
		set al $geoCodes(-1)	;# skip
		set ll [.txtcols.1.1.l get 0 end]
		foreach c $tmpAllCodes {
			if {[lsearch -exact $ll $geoCodes($c)] == -1} {
				lappend al "$geoCodes($c)"
			}
		}
		set n [string trim [GeoListbox $al {0 1 2} "" 1] "\{\}"]
		.txtcols.1.1.l insert end $n
		c_state
	}
	button $this.1.2.del -text $geoEasyMsg(delete) -state disabled \
		-command {.txtcols.1.1.l delete [.txtcols.1.1.l curselection]
		c_state}
	pack $this.1.2.up $this.1.2.down $this.1.2.add $this.1.2.del -side top
	
	label $this.2.1.lcooSep -text  "[lindex $geoEasyMsg(ltxtsep) 0]:"
	entry $this.2.1.txtSep -textvariable locTxtSep -width 10
	pack $this.2.1.lcooSep  $this.2.1.txtSep -side left
	checkbutton $this.2.1.multisep -text $geoEasyMsg(lmultisep) \
		-variable locMultiSep
	pack $this.2.1.multisep -side bottom
	label $this.2.15.lheader -text $geoEasyMsg(lheader)
	entry $this.2.15.header -textvariable locHeader -width 4
	pack $this.2.15.lheader $this.2.15.header -side left
	label $this.2.16.lfilter -text $geoEasyMsg(lfilter)
	entry $this.2.16.filter -textvariable locTxtFilter -width 40
	pack $this.2.16.lfilter $this.2.16.filter -side left

	text $this.2.2.sample -height 5 -width 40 -setgrid 1
	pack  $this.2.2.sample -fill both -expand 1
	set f [open $fn r]
	for {set i 0} {$i < 5} {incr i} {
		catch {$this.2.2.sample insert end "[gets $f]\n"}
	}
	close $f
	button $this.3.exit -text $geoEasyMsg(ok) \
		-command {set codelist [.txtcols.1.1.l get 0 end]; destroy .txtcols; set multiSep $locMultiSep; set txtSep $locTxtSep; set buttonid 0}
	button $this.3.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"
	button $this.3.load -text $geoEasyMsg(loadbut) -command {
		global locTxtSep locMultiSep header
		global codelist txpTypes
		global geoCodes
		set fn [string trim [tk_getOpenFile -defaultextension txp \
			-filetypes $txpTypes]]
		if {[string length $fn] && [string match "after#*" $fn] == 0} {
		 	source $fn
			.txtcols.1.1.l delete 0 end
			foreach c $codelist {
				.txtcols.1.1.l insert end $geoCodes($c)
			}
		}
	}
	button $this.3.save -text $geoEasyMsg(savebut) -command {
		global locTxtSep locMultiSep header
		global codelist txpTypes
		global geoCodes
		global tmpAllCodes

		set fn [string trim [tk_getSaveFile -defaultextension ".txp" \
			-filetypes $txpTypes]]
		if {[string length $fn] && [string match "after#*" $fn] == 0} {
			set fp [open $fn w]
			puts $fp "set locTxtSep \"$locTxtSep\""
			puts $fp "set locMultiSep \"$locMultiSep\""
			puts $fp "set locHeader $locHeader"
			puts $fp "set locTxtFilter \"$locTxtFilter\""
			set cl ""
			foreach cv [.txtcols.1.1.l get 0 end] {
				foreach c $tmpAllCodes {
					if {$cv == $geoCodes($c)} {
						lappend cl $c
						break
					}
				}
			}
			puts $fp "set codelist \"$cl\""
			close $fp
		}
	}

	pack $this.1.1.s -side right -fill both
	pack $this.1.1.l -side left -fill both -expand 1
	
	pack $this.3.load -side right
	pack $this.3.save -side right
	pack $this.3.cancel -side right
	pack $this.3.exit -side right

	foreach c $codes {
		$this.1.1.l insert end $geoCodes($c)
	}
	bind $this.1.1.l <1> "c_state"
	if {[string length $ff]} {
		# get format from stored file
		if {$ff != ""} {
		 	if {[catch {source $ff}] == 0} {
				.txtcols.1.1.l delete 0 end
				foreach c $codelist {
					.txtcols.1.1.l insert end $geoCodes($c)
				}
			}
		}
	}
	update
	CenterWnd $this
	grab set $this
	tkwait variable buttonid

	if {$buttonid == 0} {
		set txtSep $locTxtSep
		set multiSep $locMultiSep
		set header $locHeader
		set txtFilter $locTxtFilter
		set al ""
		set ll $codelist
		set i 0
		foreach l $ll {
			set val -1
			# all possible codes
			foreach c {2 3 5 6 7 8 9 10 11 38 37 39 4 111 112 120 138 137 139} {
				if {[string compare $l $geoCodes($c)] == 0} {
					set val $c
					break
				}
			}
			lappend al $val
		}
		return $al
	} else {
		return ""
	}
}

#
#	Change state of controls in dialog
proc c_state {} {
	set i [.txtcols.1.1.l curselection]
	if {[llength $i]} {
		.txtcols.1.2.up configure -state normal
		.txtcols.1.2.down configure -state normal
		.txtcols.1.2.del configure -state normal
	} else {
		.txtcols.1.2.up configure -state disabled
		.txtcols.1.2.down configure -state disabled
		.txtcols.1.2.del configure -state disabled
	}
}

#
#	Load observations from ascii text file
#	Text file can be separated by characters given in txtSep (geo_easy.msk)
#	Order of values can be set
#	@param fn name of txt file
#	@param ff format file optional
#	@return 0 on success
proc TxtGeo {fn {ff ""}} {
	global geoEasyMsg geoCodes
	global reg
	global txtSep multiSep header txtFilter

	if {! [info exists txtSep] } { set txtSep "\t;" }
	if {! [info exists multiSep] } { set multiSep 0 }
	if {! [info exists header] } { set header 0 }
	if {! [info exists txtFilter] } { set txtFilter "" }
	set fa [GeoSetName $fn]
	if {[string length $fa] == 0} {return 1}
	global ${fa}_geo ${fa}_coo ${fa}_ref
	if {[catch {set f1 [open $fn r]}] != 0} {
			return -1		;# cannot open input file
	}
	set codes [TxtCols {2 5 7 8 9 6 3} {2 5 7 8 9 6 3 11 4 10 120} $fn $ff]	;# order of values
	if {[llength $codes] == 0} {
		return -999
	}
	set apn [lsearch -exact $codes 2]
	set npn [lsearch -exact $codes 5]
	if {$npn < 0 || $apn < 0} {
		return -12
	}
	set src 0			;# input line number
	set nrow 0			;# number of rows in fieldbook
	set ap ""			;# empty station id
	set nheader $header
	while {$nheader > 0} {
		gets $f1 buf
		incr src
		incr nheader -1
	}
	while {! [eof $f1]} {
		set obuf ""				;# output buffer
		incr src
		if {[gets $f1 buf] == 0} { continue }
		if {[string length $txtFilter] && [regexp $txtFilter $buf] == 0} {
			continue		;# filtered line
		}
		set buf [string trim $buf]		;# remove leading tailing spaces
		if {$multiSep}	{				;# remove adjecent separators
			set r1 "\[$txtSep\]"
			set r2 [string index $txtSep 0]
			while {[regsub -all "${r1}${r1}" $buf $r2 buf]} {}
		}
		set buflist [split $buf $txtSep]
		set n [llength $buflist]
		if {$n == 0} { continue }		;# empty line
		set wap [lindex $buflist $apn]
		if {$ap != $wap && [string length $wap]} {
			# new station
			set newstation 1
		} else {
			set newstation 0
		}
		if {[string length $wap]} {
			set ap $wap
		}	;# else keep previous station id
		set pn [lindex $buflist $npn]
		if {[string length $pn] > 0 && [string length $ap] > 0} {
			# station point number given
			foreach code $codes val $buflist {
				if {[string length $code] > 0 && $code >= 0 && \
						[string length $val] > 0} {
					if {[lsearch -exact {7 8} $code] != -1 && \
						[regexp $reg(3) $val]} {
						# angle in DMS
						set val [DMS2Rad $val]
					}
					# if "," is not separator and no "." in coord
					# replace "," width "."
					if {[string first "," $val] != -1 && [string first "." $val] == -1 && [string first "," $txtSep] == -1} {
						regsub "," $val "." val
					}
					if {[lsearch -exact {7 8 9 10 120 11 3 6 112} $code] != -1} {
						# check numeric value
						if {[regexp $reg(2) $val] == 0} {
							close $f1
							return $src
						}
					}
					lappend obuf [list $code $val]
				}
			}
			if {$newstation} {
				set sbuf ""
				lappend sbuf [list 2 $ap]
				GeoLog1 "$geoCodes(2): $ap"
				set w [GetVal 3 $obuf]
				# remove station data from buf
				if {[string length $w]} {
					lappend sbuf [list 3 $w]
				}
				set ${fa}_geo($nrow) $sbuf
				if {[info exists ${fa}_ref($pn)] == -1} {
					set ${fa}_ref($pn) $nrow
				} else {
					lappend ${fa}_ref($ap) $nrow
				}
				incr nrow
			}
			set obuf [DelVal 2 $obuf]
			set obuf [DelVal 3 $obuf]
			set face2 0
			# check for face 2
			set li [expr {$nrow - 1}]
			# look for the same point number in this station
			while {$li >= 0} {
				if {[string length [GetVal 2 [set ${fa}_geo($li)]]] != 0} {
					break
				}
				if {[GetVal {5 62} [set ${fa}_geo($li)]] == $pn} {
					# really second face?
					set obuf1 [set ${fa}_geo($li)]
					set avgbuf [AvgFaces $obuf1 $obuf]
					if {[llength $avgbuf]} {
						set face2 1
					} else {
						GeoLog1 [format $geoEasyMsg(noface2) \
							[GetVal {5 62} $obuf]]
					}
					break
				}
				incr li -1
			}
			if {$face2} {
				#store average for 2 faces
				set ${fa}_geo($li) $avgbuf
			} else {
				# new first face
				set ${fa}_geo($nrow) $obuf
				if {[info exists ${fa}_ref($pn)] == -1} {
					set ${fa}_ref($pn) $nrow
				} else {
					lappend ${fa}_ref($pn) $nrow
				}
				incr nrow
			}
		} else {
			close $f1
			return $src
		}
	}
	close $f1
	return 0
}

#
#	Load observations from ascii text file exported by n4ce
#	Text file can be separated by comma characters 
#	lines start with code 1/3/4/5
#	1 - config (units)
#	3 - station (3, station_id, ???, ???, ih)
#	4 - orientation (4, nop, hz, v, sd, th, point_id)
#	5 - detail point (5, point_id, hz, v, sd, th, code)
#	@param fn name of txt file
#	@return 0 on success
proc n4ce {fn} {
	global geoLoaded
	global geoEasyMsg
	global geoCodes

	set fa [GeoSetName $fn]
	if {[string length $fa] == 0} {return 1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	if {[catch {set f1 [open $fn r]}] != 0} {
		return -1       ;# cannot open input file
	}

	set fa [GeoSetName $fn]
	set lineno 0            ;# line number in input
	set nrow 0				;# fieldbook index
	set sep ","				;# field separator
	while {! [eof $f1]} {
		set obuf ""
		set pn ""
		incr lineno
		if {[gets $f1 buf] == 0} { continue }
		set buf [string trim $buf]		;# remove leading tailing spaces
		set buflist [split $buf $sep]
		set n [llength $buflist]
		if {$n == 0} { continue }		;# empty line
		switch -exact -- [lindex $buflist 0] {
			"1" {
				if {[string trim [lindex $buflist 1]] != "DMS" || \
					[string trim [lindex $buflist 2]] != "VASD"} {
					close $f1
					return -1
				}
			}
			"3" {					;# new station & orientation
				set pn [string trim [lindex $buflist  1]]
				lappend obuf [list 2 $pn]
				GeoLog1 "$geoCodes(2): $pn"
				lappend obuf [list 3 [string trim [lindex $buflist 4]]]
				set ${fa}_geo($nrow) $obuf	;# store station
				incr nrow
				set obuf ""
			}
			"4" {					;# orientation
				set pn [string trim [lindex $buflist 6]]
				lappend obuf [list 62 $pn]
				set hz [string trim [lindex $buflist 2]]
				if {[string length $hz]} {
					lappend obuf [list 7 [Deg2Rad [format %.4f [expr {$hz / 10000.0}]]]]
				}
				set v [string trim [lindex $buflist 3]]
				if {[string length $v]} {
					lappend obuf [list 8 [Deg2Rad [format %.4f [expr {$v / 10000.0}]]]]
				}
				set sd [string trim [lindex $buflist 4]]
				if {[string length $sd]} {
					lappend obuf [list 9 $sd]
				}
				set th [string trim [lindex $buflist 5]]
				if {[string length $th]} {
					lappend obuf [list 6 $th]
				}
			}
			"5" {
				set pn [string trim [lindex $buflist 1]]
				lappend obuf [list 5 $pn]
				set hz [string trim [lindex $buflist 2]]
				if {[string length $hz]} {
					lappend obuf [list 7 [Deg2Rad [format %.4f [expr {$hz / 10000.0}]]]]
				}
				set v [string trim [lindex $buflist 3]]
				if {[string length $v]} {
					lappend obuf [list 8 [Deg2Rad [format %.4f [expr {$v / 10000.0}]]]]
				}
				set sd [string trim [lindex $buflist 4]]
				if {[string length $sd]} {
					lappend obuf [list 9 $sd]
				}
				set th [string trim [lindex $buflist 5]]
				if {[string length $th]} {
					lappend obuf [list 6 $th]
				}
				set code [string trim [lindex $buflist 6]]
				if {[string length $code]} {
					lappend obuf [list 4 $code]
				}
			}
		}
		set face2 0
		if {[string length $pn] && [llength $obuf]} {
			set li [expr {$nrow - 1}]
			# look for the same point number in this station
			while {$li >= 0} {
				if {[string length [GetVal 2 [set ${fa}_geo($li)]]] != 0} {
					break
				}
				if {[GetVal {5 62} [set ${fa}_geo($li)]] == $pn} {
					# really second face?
					set obuf1 [set ${fa}_geo($li)]
					set avgbuf ""
					set avgbuf [AvgFaces $obuf1 $obuf]
					if {[llength $avgbuf]} {
						set face2 1
					} else {
						GeoLog1 [format $geoEasyMsg(noface2) \
							[GetVal {5 62} $obuf]]
					}
					break
				}
				incr li -1
			}
			if {$face2} {
				#store average for 2 faces
				set ${fa}_geo($li) $avgbuf
			} else {
				# new first face
				set ${fa}_geo($nrow) $obuf
				if {[info exists ${fa}_ref($pn)] == -1} {
					set ${fa}_ref($pn) $nrow
				} else {
					lappend ${fa}_ref($pn) $nrow
				}
				incr nrow
			}
		}
	}
	close $f1
	return 0
}
