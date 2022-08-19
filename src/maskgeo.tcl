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

#	Create a new mask to view/edit geo data sets
#	The mask definition is a list
#		1st item mask type form or table
#		2nd number of rows, must be 1 in case of form
#		3rd .. nth	codes to display, may be a sublist
#	Param definition defines the output form for values given in mask
#		""	the stored values is displayed
#		"-"	the previous value is used if not in the actual record
#		"DMS" angle format
#		"DEC  n m"	format definition m decimals, field length n
#		"%4d" c like format
#		new toplevel window created
#		binds are added to move forward and backward
#	@param maskn mask definition name
#	@param f geo data set short name
#	@param type  "_geo" or "_coo" (optional, default _geo)
proc GeoMask {maskn f {type "_geo"}} {
	global geoEasyMsg
	global geoCodes
	global geoMasks geoMaskParams geoMaskWidths
	global cooMasks cooMaskParams CooMaskWidths
	global maskPos maskName
	global geoRes geoNum
	global geoMustHave geoTogether geoNotTogether
	global cooMustHave cooTogether cooNotTogether
	global geoModules
	global reglist

    set fn [GetInternalName $f]
    set fs [GetShortName $f]
	set w .[string tolower ${fn}]${type}
	set maskPos($w) 0
	set maskName($w) $maskn
	if {$type == "_geo"} {
		upvar #0 geoMasks($maskn) mask
		upvar #0 geoMaskParams($maskn) params
		upvar #0 geoMaskWidths($maskn) widths
	} else {
		upvar #0 cooMasks($maskn) mask
		upvar #0 cooMaskParams($maskn) params
		upvar #0 cooMaskWidths($maskn) widths
	}
	set geoRes($w) ""
	toplevel $w
	wm protocol $w WM_DELETE_WINDOW "GeoMaskExit $w"
	wm protocol $w WM_SAVE_YOURSELF "GeoMaskExit $w"
	wm resizable $w 0 0
    wm title $w ${fs}${type}

	set grd $w.grd
	set status $w.status
	set xtr $w.xtr
	set mnu $w.mnu
	frame $xtr -relief flat
	frame $grd -relief flat
	frame $status -relief sunken -borderwidth 2
	menu $mnu -relief raised -tearoff 0 ;#-type menubar

	pack $status $xtr -side bottom -fill x
	pack $grd -side left -in $xtr

	scrollbar $xtr.scr -takefocus 0 -command "GeoMaskScr $fn $type $w"
	pack $xtr.scr -side right -expand yes -fill y
	$xtr.scr set 0 1
#
#	menu
#
	$mnu add cascade -label $geoEasyMsg(menuGraCom) \
		-menu $mnu.command
	$mnu add cascade -label $geoEasyMsg(menuGraCal) \
		-menu $mnu.calculate
	$mnu add cascade -label $geoEasyMsg(help) \
		-menu $mnu.help

	menu $mnu.command -tearoff 0
	$mnu.command add command -label $geoEasyMsg(menuMask) \
		-command "ChangeMask $fn $type $w"
	$mnu.command add command -label $geoEasyMsg(menuResize) \
		-command "ResizeMask $maskn $fn $type $w"
	$mnu.command add command -label $geoEasyMsg(menuRefreshAll) \
		-command "RefreshAll" -accelerator "Ctrl-F2"
	if {$type == "_geo"} {
		$mnu.command add command -label $geoEasyMsg(menuGraRefresh) \
			-command "GeoFillMask $fn \$maskPos($w) $w" -accelerator "F2"
		$mnu.command add separator
		$mnu.command add command -label $geoEasyMsg(newSt) \
			-command "GeoNewSt $w.grd.e" -accelerator "F7"
		$mnu.command add command -label $geoEasyMsg(menuCoord) \
			-command "EditCoo $fn" -accelerator "F9"
		$mnu.command add command -label $geoEasyMsg(menuCheckObs) \
			-command "CheckGeo ${fn}_geo {$geoMustHave} {$geoTogether} {$geoNotTogether}"
	} else {
		$mnu.command add command -label $geoEasyMsg(menuGraRefresh) \
			-command "CooFillMask $fn \$maskPos($w) $w" -accelerator "F2"
		$mnu.command add separator
		$mnu.command add command -label $geoEasyMsg(newCoo) \
			-command "CooNew $w.grd.e" -accelerator "F7"
		$mnu.command add command -label $geoEasyMsg(menuObs) \
			-command "EditGeo $fn" -accelerator "F9"
		$mnu.command add command -label $geoEasyMsg(menuCheckCoord) \
			-command "CheckGeo ${fn}_coo {$cooMustHave} {$cooTogether} {$cooNotTogether}"
		$mnu.command add separator
		$mnu.command add command -label $geoEasyMsg(menuCooTr) \
			-command "CooTrDia ${fn}_coo"
		$mnu.command add command -label $geoEasyMsg(menuCooTrFile) \
			-command "CooTrFile ${fn}_coo"
		$mnu.command add command -label $geoEasyMsg(menuCooDif) \
			-command "CooDif ${fn}"
		$mnu.command add separator
		$mnu.command add command -label $geoEasyMsg(menuCooSwapEN) \
			-command "Swap2 ${fn} EN; CooFillMask $fn \$maskPos($w) $w"
		$mnu.command add command -label $geoEasyMsg(menuCooSwapEZ) \
			-command "Swap2 ${fn} EZ; CooFillMask $fn \$maskPos($w) $w"
		$mnu.command add command -label $geoEasyMsg(menuCooSwapNZ) \
			-command "Swap2 ${fn} NZ; CooFillMask $fn \$maskPos($w) $w"
		$mnu.command add separator
		$mnu.command add command -label $geoEasyMsg(finalCoo) \
			-command "CooFinal $w.grd.e"
		$mnu.command add command -label $geoEasyMsg(menuCooDelAppr) \
			-command "CooDelAppr ${fn}_coo"
		$mnu.command add command -label $geoEasyMsg(menuCooDelDetail) \
			-command "CooDelDetail ${fn}_coo"
		$mnu.command add command -label $geoEasyMsg(menuCooDel) \
			-command "CooDel ${fn}_coo"
		$mnu.command add command -label $geoEasyMsg(menuPntDel) \
			-command "PntDel ${fn}_coo"
	}
	$mnu.command add separator
	$mnu.command add command -label $geoEasyMsg(savebut) \
		-command "MenuSave $fn" -accelerator "Ctrl-S"
	$mnu.command add command -label $geoEasyMsg(menuSaveCsv) \
		-command "GeoMaskCsv $maskn $fn $type"
	$mnu.command add command -label $geoEasyMsg(menuSaveRtf) \
		-command "GeoMaskRtf $maskn $fn $type"
	$mnu.command add command -label $geoEasyMsg(menuSaveHtml) \
		-command "GeoMaskHtml $maskn $fn $type"
	$mnu.command add command -label $geoEasyMsg(menuGraClose) \
		-command "GeoMaskExit $w"

	menu $mnu.calculate -tearoff 0
	$mnu.calculate add command -label $geoEasyMsg(menuCalOri) \
		-command "GeoFinalOri 13"
    $mnu.calculate add command -label $geoEasyMsg(menuCalAppOri) \
        -command "GeoFinalOri 7"
    $mnu.calculate add command -label $geoEasyMsg(menuCalDelOri) \
        -command "GeoDelOri"
    $mnu.calculate add separator
    $mnu.calculate add command -label $geoEasyMsg(menuCalTra) \
        -command "GeoTraverse 0"
    $mnu.calculate add command -label $geoEasyMsg(menuCalTraNode) \
        -command "GeoTraverseNode 0"
    $mnu.calculate add command -label $geoEasyMsg(menuCalTrig) \
        -command "GeoTraverse 1"
    $mnu.calculate add command -label $geoEasyMsg(menuCalTrigNode) \
        -command "GeoTraverseNode 1"
    $mnu.calculate add separator
    $mnu.calculate add command -label $geoEasyMsg(menuCalLine) \
        -command "GeoLineLine"
    $mnu.calculate add command -label $geoEasyMsg(menuCalPntLine) \
        -command "GeoPointOnLine"
    $mnu.calculate add command -label $geoEasyMsg(menuCalLength) \
        -command "GeoCalcArea 0"
    $mnu.calculate add command -label $geoEasyMsg(menuCalArea) \
        -command "GeoCalcArea 1"
    $mnu.calculate add command -label $geoEasyMsg(menuCalArc) \
        -command "GeoSettingOutArc"
    $mnu.calculate add separator
    $mnu.calculate add command -label $geoEasyMsg(menuCalPre) \
        -command "GeoApprCoo"
    $mnu.calculate add command -label $geoEasyMsg(menuRecalcPre) \
        -command "GeoRecalcAppr"
	if {[lsearch -exact $geoModules "adj"] != -1} {
		# adjustment with gnu gama
		$mnu.calculate add command -label $geoEasyMsg(menuCalAdj3D) \
			-command "GeoNet3D"
		$mnu.calculate add command -label $geoEasyMsg(menuCalAdj2D) \
			-command "GeoNet2D"
		$mnu.calculate add command -label $geoEasyMsg(menuCalAdj1D) \
			-command "GeoNet1D"
	}
    $mnu.calculate add command -label $geoEasyMsg(menuCalTran) \
        -command "GeoTran $fn"
    $mnu.calculate add command -label $geoEasyMsg(menuCalHTran) \
        -command "GeoHTran $fn"
    $mnu.calculate add separator
    $mnu.calculate add command -label $geoEasyMsg(menuCalDet) \
        -command "GeoDetail 0"
    $mnu.calculate add command -label $geoEasyMsg(menuCalDetAll) \
        -command "GeoDetail 1"
    $mnu.calculate add command -label $geoEasyMsg(menuCalFront) \
        -command "GeoFront"
	if {[lsearch -exact $geoModules "reg"] != -1} {
		$mnu.calculate add separator
		$mnu.calculate add cascade -label $geoEasyMsg(menuReg) \
			-menu $mnu.regression
	
		menu $mnu.regression -tearoff 0
		set i 0
		set menuBreak {2}
		foreach r $reglist {
			$mnu.regression add command -label $r -command "GeoReg $i"
			if {[lsearch $menuBreak $i] >= 0} {
				$mnu.regression add separator
			}
			incr i
		}
		$mnu.regression add separator
		$mnu.regression add command -label $geoEasyMsg(menuRegLDist) \
			-command "GeoRegDist 0"
		$mnu.regression add command -label $geoEasyMsg(menuRegPDist) \
			-command "GeoRegDist 1"
	}
    menu $mnu.help -tearoff 0
    $mnu.help add command -label $geoEasyMsg(help) \
        -command "GeoHelp" -accelerator "F1"
	$w configure -menu $mnu
	
	set def [lrange $mask 2 end]
	set rows [lindex $mask 1]
	if {$rows <= 0} { set rows 1 }
	if {[lindex $mask 0] == "table"} { ;# table mask
		set i 0
		foreach items $def {			;# create header
			set l$i ""
			foreach item $items {
				if {[catch {set t $geoCodes($item)}] != 0} {
					geo_dialog .msg $geoEasyMsg(error) \
						[format $geoEasyMsg(geocode) $item] error 0 OK
					catch {destroy $w}
					return
				}
                if {$item > 0} {    ;# not not show not used
                    if {[string length [set l$i]] > 0} {
                        set l$i "[set l$i]\n$t"
                    } else {
                        set l$i $t
                    }
                }
			}
			set oarr($i) $items
			label $grd.l$i -text [set l$i]
			grid $grd.l$i -row 0 -column $i
			incr i
		}
		for {set i 1} {$i <= $rows} {incr i} {
			for {set j 0} {$j < [llength $def]} {incr j} {
				set ent ${grd}.e${i}-${j}
                if {[lsearch -exact {"ANG" "DST" "FLOAT" "INT"} [lindex $params $j]] == -1} {
                    entry $ent -width [lindex $widths $j] -justify left
                } else {
                    entry $ent -width [lindex $widths $j] -justify right    ;# right align numeric
                }
				bind $ent <FocusOut> "GeoValid %W"
				bind $ent <FocusIn> "LastVal %W"
				bind $ent <3> "GeoMaskPopup [list $oarr($j)] %W %X %Y"
				grid $ent -row $i -column $j
				if {$i == 1 && $j == 0} {focus $ent}
			}
		}
	}
#
#	create status line
#
	label $status.rnum -textvariable geoNum($w) -width 10
	label $status.res -textvariable geoRes($w)
	pack $status.rnum -padx 5 -side left 
	pack $status.res -side right -expand yes
	if {$type == "_geo"} {
		GeoFillMask $fn 0 $w
		bind $w <Key-F2> "GeoFillMask $fn \$maskPos($w) $w"
		bind $w <Key-F7> "GeoNewSt $w.grd.e"
		bind $w <Key-F8> {GeoNewObs [focus]}
		bind $w <Key-F9> "EditCoo $fn"
		bind $w <Control-Key-Prior> "GeoPageMask $fn $w home"
		bind $w <Control-Key-Next> "GeoPageMask $fn $w end"
		bind $w <Key-Next> "GeoPageMask $fn $w $rows"
		bind $w <Key-Prior> "GeoPageMask $fn $w -$rows"
		bind $w <Key-Down> "GeoPageMask $fn $w 1"
		bind $w <Key-Up> "GeoPageMask $fn $w -1"
		bind $w <MouseWheel> "GeoWheelMask $fn $w %D"
	} else {
		CooFillMask $fn 0 $w
		bind $w <Key-F2> "CooFillMask $fn \$maskPos($w) $w"
		bind $w <Key-F7> "CooNew $w.grd.e"
		bind $w <Key-F9> "EditGeo $fn"
		bind $w <Control-Key-Prior> "CooPageMask $fn $w home"
		bind $w <Control-Key-Next> "CooPageMask $fn $w end"
		bind $w <Key-Next> "CooPageMask $fn $w $rows"
		bind $w <Key-Prior> "CooPageMask $fn $w -$rows"
		bind $w <Key-Down> "CooPageMask $fn $w 1"
		bind $w <Key-Up> "CooPageMask $fn $w -1"
		bind $w <MouseWheel> "CooWheelMask $fn $w %D"
	}
	bind $w <Alt-KeyPress-F4> "GeoMaskExit $w"
}

#
#	Fill a mask to view/edit geo data sets
#	@param fn geo data set name
#	@param start first row in dataset to display
#	@param w handle to window
proc GeoFillMask {fn start w} {
	set type _geo
	global geoCodes
	global ${fn}${type}
	global geoMaskColors geoNotUsedColor
	global geoMasks geoMaskParams
	global entryFmt entryCode entryCodes entryRow
	global maskName

	set maskn $maskName($w)
	upvar #0 geoMasks($maskn) mask
	upvar #0 geoMaskParams($maskn) params
#
#	update last changed entry
#
	set act [focus]

	set rows [lindex $mask 1]
	set n [llength [array names ${fn}${type}]]
#	set scrollbar position
	if {$n} {
		$w.xtr.scr set [expr {($start + 0.0) / $n}] \
			[expr {($start + 0.0 + $rows) / $n}]
	} else {
		$w.xtr.scr set 0 1
	}
	set def [lrange $mask 2 end]
	set grd $w.grd
	if {[lindex $mask 0] == "table"} { ;# table mask
		set k $start
		set station 0
		set i 1
		while {$i <= $rows} {
			if {[info exists ${fn}${type}($k)]} {
				set rec [set ${fn}${type}($k)]
				if {[GetVal 2 $rec] == ""} {
					# not a station record
					set station 0
				} else {
					set station 1
				}
			} else {
				set rec ""
				set station 0
			}
			set empty 1							;# suppose row is empty
			for {set j 0} {$j < [llength $def]} {incr j} {
				if {[llength $rec]} {
					set stat normal
					set bg white
				} else {
					set stat disabled			;# after last observation
					set bg grey
				}
				set items [lindex $def $j]
				set par [lindex $params $j]
				set ent ${grd}.e${i}-${j}
				set ind 0
				set color "black"
				# set color of entry depending on code position
				foreach item $items {
					set val [GetVal $item $rec]
					if {$val != ""} {
                        if {$item < 0} {
                            set color $geoNotUsedColor
                        } else {
                            set color [lindex $geoMaskColors $ind]
                        }
						break
					}
					incr ind
				}
				set copied 0
				if {[string index $par 0] == "-" && $rec != ""} {
					set par [string range $par 1 end]
					if {$val == ""} {			;# no value remember to last
						set val [GetLast $fn $type $k $items]
						set stat disabled
						set color "grey"
					}
				}
				$ent configure -state normal
				$ent delete 0 end				;# delete entry
				if {$station && ([lsearch -exact $items 5] != -1 || \
						[lsearch -exact $items 62] != -1)} {
					set stat disabled
					set bg grey
				}
				if {[llength $rec] > 0} {
					# set globals for storing back a modified value
					set entryFmt($ent) [lindex $params $j]
					set entryRow($ent) $k
					set entryCode($ent) [lindex $items $ind]
					set entryCodes($ent) $items
					if {$val != ""} {
						if {$par != ""} {
							set val [eval $par $val]
						}
						$ent insert 0 $val
						set empty 0
					}
				} else {
					catch "unset entryFmt($ent)"
					catch "unset entryRow($ent)"
					catch "unset entryCode($ent)"
					catch "unset entryCodes($ent)"
				}
				$ent configure -state $stat -background $bg -foreground $color
			}
			incr k
			if {! $empty || $rec == ""} {incr i}	;# use the same row if empty
		}
	}
}

#
#	Fill a coordinate mask to view/edit geo data sets
#	@param fn geo data set name
#	@param start first row in dataset to display
#	@param w handle to window
proc CooFillMask {fn start w} {
	global geoCodes
	global geoMaskColors
	global cooMasks cooMaskParams
	global entryFmt entryCode entryCodes entryRow
	global maskName
	set type _coo
	global ${fn}${type}

	set maskn $maskName($w)
	upvar #0 cooMasks($maskn) mask
	upvar #0 cooMaskParams($maskn) params

#
#	update last changed entry
#
	set act [focus]
# TBD jo ez?
	if {[info exists entryRow($act)]} {
		if {[GeoValid $act] == 1} { return }
	}

	set grd $w.grd
	set rows [lindex $mask 1]
	set n [llength [array names ${fn}${type}]]
#	set scrollbar
	if {$n} {
		$w.xtr.scr set [expr {($start + 0.0) / $n}] \
			[expr {($start + 0.0 + $rows) / $n}]
	} else {
		$w.xtr.scr set 0 1
	}
	set def [lrange $mask 2 end]
	set pns [lsort -dictionary [array names ${fn}${type}]]
	if {[lindex $mask 0] == "table"} { ;# table mask
		set k $start
		set i 1
		while {$i <= $rows} {
			set ind [lindex $pns $k]
			if {[info exists ${fn}${type}($ind)]} {
				set rec [set ${fn}${type}($ind)]
				set stat normal
				set bg white
			} else {
				set rec ""
				set stat disabled
				set bg grey
			}
			set empty 1							;# suppose row is empty
			for {set j 0} {$j < [llength $def]} {incr j} {
				set items [lindex $def $j]
				set par [lindex $params $j]
				set ent ${grd}.e${i}-${j}
				set wind 0
				foreach item $items {
					set val [GetVal $item $rec]
					if {$val != ""} {
						set color [lindex $geoMaskColors $wind]
						break
					}
					incr wind
				}
				if {[string index $par 0] == "-" && $rec != ""} {
					set par [string range $par 1 end]
					if {$val == ""} {	;# no value remember to last
						set val [GetLast $fn $type $h $items]
					}
				}
				$ent delete 0 end				;# delete entry
				$ent configure -state $stat -background $bg
				if {$stat == "normal"} {
					# set globals for storing back a modified value
					set entryFmt($ent) [lindex $params $j]
					set entryRow($ent) $ind
					set entryCode($ent) [lindex $items $wind]
					set entryCodes($ent) $items
					if {$val != ""} {
						if {$par != ""} {
							set val [eval $par $val]
						}
						$ent insert 0 $val
						if {$color == ""} {
							set color "black"
						}
						# set color of entry depending on code position
						$ent configure -foreground $color
						set empty 0
					}
				} else {
					catch "unset entryFmt($ent)"
					catch "unset entryRow($ent)"
					catch "unset entryCode($ent)"
					catch "unset entryCodes($ent)"
				}
			}
			incr k
			if {! $empty || $rec == ""} {incr i}	;# use the same row if empty
		}
	}
}

#
#	Compare two values
#	@param pn1 - values to compare
#	@param pn2
#	@return -1/0/1
proc pnumCmp {pn1 pn2} {
	set isnum1 [regexp "^\[0-9\]+$" $pn1]
	set isnum2 [regexp "^\[0-9\]+$" $pn2]
	if {$isnum1} {	;# first is number
		if {$isnum2} {
			return [expr {$pn1 - $pn2}]
		} else {
			return 1		;# put numbers after strings
		}
	} else {
		if {$isnum2} {
			return -1
		} else {
			return [string compare $pn1 $pn2]
		}
	}
}

#
#	Open new edit window
#	@param f geo data set short name
proc EditGeo {f} {
	global geoMasks geoMaskParams geoMaskDefault

    set fn [GetInternalName $f]
	if {[winfo exists .${fn}_geo]} {
		wm deiconify .${fn}_geo
		raise .${fn}_geo
		Beep
		return
	}
	if {[info exists geoMaskDefault] && \
		[info exists geoMasks($geoMaskDefault)]} {
		set m $geoMaskDefault
	} else {
		set m [GeoSelectMask geoMasks]
	}
	if {[llength $m] > 0} {
		GeoMask $m $fn
	}
}

#
#	Open new edit window
#	@param f coo data set short name
proc EditCoo {f} {
	global cooMasks cooMaskParams cooMaskDefault

    set fn [GetInternalName $f]
	if {[winfo exists .${fn}_coo]} {
		wm deiconify .${fn}_coo
		raise .${fn}_coo
		Beep
		return
	}
	if {[info exists cooMaskDefault] && \
		[info exists cooMasks($cooMaskDefault)]} {
		set m $cooMaskDefault
	} else {
		set m [GeoSelectMask cooMasks]
	}
	if {[llength $m] > 0} {
		GeoMask $m $fn "_coo"
	}
}

#
#	Fill a mask to view/edit geo data sets
#	@param fn geo data set name
#	@param w handle to window
#	@param step move step row forward or backward (if step < 0 move back)
#				"home" and "end" to jump top or bottom
proc GeoPageMask {fn w step} {
	global maskPos
	global geoMasks geoMaskParams
	global maskName
	global geoNum entryRow

	GeoValid [focus]
	set geo ${fn}_geo
	global $geo
	set maskn $maskName($w)
	upvar #0 geoMasks($maskn) mask
	upvar #0 geoMaskParams($maskn) params
	set rows [lindex $mask 1]	;# number of rows in mask
	set n [array size $geo]		;# number of rows in fieldbook

	set f [focus]	;# get entry with focus
	if {! [regexp "\.e\[0-9\]+-\[0-9\]+$" $f]} {	;# not an entry
		Beep
		return
	}
	set pos [string last "e" $f]	;# find row and col pos in entry name
	incr pos
	set rc [split [string range $f $pos end] "-"]
	set r [lindex $rc 0]	;# actual row & col
	set c [lindex $rc 1]
	switch -exact -- $step {
		home { set mp 0; set r -1 }
		end  { set mp [expr {$n - 1 - $rows}]; set r -1 }
		default {
			set mp $maskPos($w)
			incr mp $step
			incr r $step
		}
	}
	if {$mp < 0} {
		set mp 0
		if {$r < 1} {
			set r -1
			Beep
		}
	}
	if {$mp >= $n} {
		set mp [expr {$n - 1}]
		if {$r > $rows} {
			set r -1
			Beep
		}
	}
	if {[info exists ${geo}($mp)] == 0} {
		set mp $maskPos($w)
		Beep
	}
	if {$r < 1 || $r > $rows} {	;# row number from 1 to rows!
		# move content out of range
		set maskPos($w) $mp
		GeoFillMask $fn $maskPos($w) $w
	} else {
		# move position only
		incr pos -1
		set f "[string range $f 0 $pos]$r-$c"
		focus $f
	}
	# set position in status line
	catch { set geoNum([winfo toplevel $w]) \
			"[expr {$entryRow([focus]) + 1}]/[array size $geo]"
	}
	LastVal [focus]
}
	
#
#	Fill a mask to view/edit coo data sets
#	@param fn geo data set name
#	@param w handle to window
#	@param step move step row forward or backward (if step < 0 move back)
proc CooPageMask {fn w step} {
	global maskPos
	global cooMasks cooMaskParams
	global maskName
	global geoNum entryRow

GeoValid [focus]
	set maskn $maskName($w)
	set coo ${fn}_coo
	global $coo
	upvar #0 cooMasks($maskn) mask
	upvar #0 cooMaskParams($maskn) params
	set rows [lindex $mask 1]	;# number of rows in mask
	set n [array size $coo]		;# number of rows in coordinate list

	set f [focus]	;# get entry with focus
	if {! [regexp "\.e\[0-9\]+-\[0-9\]+$" $f]} {	;# not an entry
		Beep
		return
	}
	set pos [string last "e" $f]	;# find row and col pos in entry name
	incr pos
	set rc [split [string range $f $pos end] "-"]
	set r [lindex $rc 0]	;# actual row & col
	set c [lindex $rc 1]

	switch -exact -- $step {
		home { set mp 0; set r -1 }
		end  { set mp [expr {[array size $coo] - 1}]; set r -1 }
		default {
			set mp $maskPos($w)
			incr mp $step
			incr r $step
		}
	}
	if {$mp < 0} {
		set mp 0
		if {$r < 1} {
			set r -1
			Beep
		}
	}
	if {[array size ${coo}] <= $mp} {
		set mp [expr {[array size $coo] - 1}]
		if {$r > $rows} {
			set r -1
			Beep
		}
	}
	if {$r < 1 || $r > $rows} {	;# row number from 1 to rows!
		set maskPos($w) $mp
		CooFillMask $fn $maskPos($w) $w
	} else {
		# move position only
		incr pos -1
		set f "[string range $f 0 $pos]$r-$c"
		focus $f
	}
	set pns [lsort -dictionary [array names $coo]]
	catch { set geoNum([winfo toplevel $w]) \
		"[expr {[lsearch -exact $pns $entryRow([focus])] + 1}]/[array size $coo]"
	}
	LastVal [focus]
}

#
#	GeoWheelMask
#	@param fn data set name
#	@param w widget
#	@param s wheel change 
proc GeoWheelMask {fn w s} {

	if {$s > 0} {
		GeoPageMask $fn $w -1
	} else {
		GeoPageMask $fn $w 1
	}
}

#
#	CooWheelMask
#	@param fn data set name
#	@param w widget
#	@param s wheel change 
proc CooWheelMask {fn w s} {

	if {$s > 0} {
		CooPageMask $fn $w -1
	} else {
		CooPageMask $fn $w 1
	}
}

#
#	destroy window and global variables
#		this - handle to window
proc GeoMaskExit {this} {
	global maskPos maskName
	global entryFmt entryCode entryCodes entryRow
	global geoRes

#
#	update last changed entry
#
	set act [focus]
	if {[info exists entryRow($act)] && \
			[regexp -nocase "\.grd\.e\[0-9\]+" $act]} {
		if {[GeoValid $act]} { return }
	}
# unset global variables releated to widgets
	foreach ch [winfo children ${this}.grd] {
		catch "unset entryFmt($ch)"
		catch "unset entryCode($ch)"
		catch "unset entryCodes($ch)"
		catch "unset entryRow($ch)"
	}
	catch {destroy .findparams}	;# remove find window if open
	catch {destroy $this}
	catch {unset maskPos($this)}
	catch {unset maskName($this)}
	catch {unset geoRes($this)}
	catch {unset geoNum($this)}
}

#
#	Select one from the loaded masks
#	@param masks mask definitions stored in arrays
#	@return the mask definition
proc GeoSelectMask {masks} {
	global $masks
	global geoEasyMsg

	if {[array exists $masks] == 0} {
		geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(nomask) error 0 OK
		return ""
	}
	set w [focus]
	if {$w == ""} { set w "." }
	toplevel .selectmask -class Dialog
	wm protocol .selectmask WM_SAVE_YOURSELF {destroy .selectmask}
	wm protocol .selectmask WM_DELETE_WINDOW {destroy .selectmask}
	wm transient .selectmask $w
	wm title .selectmask $geoEasyMsg(maskTitle)
	wm geometry .selectmask +45+55
	catch {wm attribute .selectmask -topmost}
	frame .selectmask.1
	frame .selectmask.2
	pack .selectmask.2 -side bottom
	pack .selectmask.1 -side top -expand yes -fill both
	listbox .selectmask.1.lb -width 40 -yscrollcommand ".selectmask.1.sb set" \
		-setgrid yes
	scrollbar .selectmask.1.sb -command ".selectmask.1.lb yview"
	pack .selectmask.1.lb -side left -expand yes -fill both
	pack .selectmask.1.sb -side right -fill both

	# fill listbox
	set msks [lsort -ascii [array names $masks]]
	foreach m $msks {
		.selectmask.1.lb insert end $m
	}
	bind .selectmask.1.lb <Double-1> ".selectmask.2.ok invoke"
	.selectmask.1.lb selection set 0	;# select the first item as def.

	global ret
	set ret ""
	button .selectmask.2.ok -text $geoEasyMsg(ok) -command {
		global ret
		set act [.selectmask.1.lb curselection]
		set ret [.selectmask.1.lb get $act]
		destroy .selectmask
	}
	button .selectmask.2.cancel -text $geoEasyMsg(cancel) -command {
		destroy .selectmask
	}
	pack .selectmask.2.ok .selectmask.2.cancel -side left -expand y

	tkwait visibility .selectmask
	grab set .selectmask
	tkwait window .selectmask
	set r $ret
	unset ret
	if {[lsearch -exact $msks $r] != -1} {
		return $r
	}
	return ""
}

#
#		Load new mask file other than default
proc LoadMask {} {
	global geoMasks geoMaskParams cooMasks cooMaskParams
	global geoForms geoFormParams geoFormPat
	global cooForms cooFormParams cooFormPat
	global mskTypes
    global geoEasyMsg

	set fn [string trim [tk_getOpenFile -filetypes $mskTypes]]
	if {[string length $fn] && [string match "after#*" $fn] == 0} {
		if {[catch {source $fn} msg] != 0} {
			geo_dialog .msg $geoEasyMsg(warning) \
				[format $geoEasyMsg(wrongmask) $msg] \
				warning 0 OK
			unset geoMasks
			# reload original masks
			catch {source [file join [file dirname [info script]] geo_easy.msk]}
		}
	}
}

#
#	Creates a new window (w) with a text widget and menu
#	@param w name of window
#	@param title window header text
#	@param typ type of wondow simple/log/console
proc GeoTextWindow {w {title "?"} {typ "simple"}} {
	global geoEasyMsg tcl_platform
	global logName
	global consoleEntry

	toplevel $w
	wm protocol $w WM_DELETE_WINDOW "GeoFormExit $w"
	wm protocol $w WM_SAVE_YOURSELF "GeoFormExit $w"
	wm title $w $title
	menu $w.menu -tearoff 0 ;# -type menubar
	if {$typ == "console"} {
		# add text input widget
		entry $w.input -textvariable consoleEntry -relief sunken -width 40
		pack $w.input -side top -fill x
	}

	frame $w.w
	pack $w.w -side bottom -fill both -expand 1

	$w.menu add cascade -label $geoEasyMsg(menuFile) -menu $w.menu.file

	menu $w.menu.file -tearoff 0

	$w.menu.file add command -label $geoEasyMsg(menuFileFind) \
		-command "GeoFormFind $w.w.t"
	if {$typ == "log"} {
		$w.menu.file add command -label $geoEasyMsg(menuFileClear) \
			-command "$w.w.t delete 0.1 end"
	}
	$w.menu.file add separator
	if {$typ == "log"} {
		$w.menu.file add command -label $geoEasyMsg(menuFileLogLoad) \
			-command "GeoLoadLog $w"
		$w.menu.file add command -label $geoEasyMsg(menuFileLogClear) \
			-command "GeoClearLog $w"
	}
	if {$typ == "console"} {
		$w.menu.file add command -label $geoEasyMsg(menuFileTclLoad) \
			-command "GeoLoadTcl $w"
	}
	$w.menu.file add command -label $geoEasyMsg(menuFileSaveAs) \
		-command "GeoListSave $w.w.t"
	$w.menu.file add command -label $geoEasyMsg(menuFileSaveSelection) \
		-command "GeoListSave $w.w.t 1"
	if {$tcl_platform(platform) != "unix"} {	;# page setup
		$w.menu.file add separator
		$w.menu.file add command -label $geoEasyMsg(menuFileFontSetup) \
			-command "GeoFontSelect"
	}
	$w.menu.file add separator
	$w.menu.file add command -label $geoEasyMsg(menuGraClose) \
		-command "GeoFormExit $w"
	$w configure -menu $w.menu

	text $w.w.t -setgrid 1 -wrap none -relief sunken -font courier \
		-exportselection yes \
		-yscrollcommand "$w.w.vs set" -xscrollcommand "$w.w.hs set"
	scrollbar $w.w.vs -orient vertical -command "$w.w.t yview"
	scrollbar $w.w.hs -orient horizontal -command "$w.w.t xview"
	pack $w.w.vs -side right -fill y
	pack $w.w.hs -side bottom -fill x
	pack $w.w.t -side top -fill both -expand 1

	bind $w <Alt-KeyPress-F4> "GeoFormExit $w"
	bind $w.w.t <Key-Next> "$w.w.t yview scroll 1 pages"
	bind $w.w.t <Key-Prior> "$w.w.t yview scroll -1 pages"
	bind $w.w.t <Key-Down> "$w.w.t yview scroll 1 units"
	bind $w.w.t <Key-Up> "$w.w.t yview scroll -1 units"

	if {$typ == "console"} {
		bind $w.input <Return> "GeoExec $w" 
		focus $w.input
	} else {
		focus $w.w.t
	}
}

#
#	Load every lines of log file and jump to the end
#	@param w - text window
proc GeoLoadLog {w} {
	global logName
	catch {
		$w.w.t delete 0.1 end	;# delete content
		set f [open $logName "r"]	;# open log file
		while { ! [eof $f]} {
			$w.w.t insert end "[gets $f]\n"
		}
		close $f
		$w.w.t see end
	}
}

#
#	Delete log file and clear result window
#	@param w text window
proc GeoClearLog {w} {
	global logName geoEasyMsg
	global lstTypes
	catch {
		if {[geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(logDelete) \
				warning 0 $geoEasyMsg(ok) $geoEasyMsg(cancel)] == 0} {
			file delete -force $logName
			$w.w.t delete 0.1 end	;# delete content
		}
	}
}

#
#	Save all/selected text stored in text widget
#	@param w handle to text widget
#	@param sel 0/1 save all/selected
proc GeoListSave {w {sel 0}} {
global lastDir
global lstTypes

	if {$sel} {
		set t ""
		catch {set t [$w get sel.first sel.last]}
	} else {
		set t [$w get 1.0 end]
	}
	if {[string length $t] == 0} {
		Beep
		return
	}
	set fn [string trim [tk_getSaveFile -filetypes $lstTypes \
		-defaultextension ".lst" -initialdir $lastDir]]
	if {[string length $fn] && [string match "after#*" $fn] == 0} {
		set lastDir [file dirname $fn]
		if {[catch {set fd [open $fn w]
			puts $fd $t
			close $fd
				} msg] != 0} {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(cantSave) \
				warning 0 OK
			return
		}
	}
}

#
#
#	Execute command from console input widget
#	@param w widget for console window
proc GeoExec {w} {
	global consoleEntry

	if {[string length $consoleEntry]} {
		$w.w.t insert end "$consoleEntry\n"
		GeoLog1 [eval $consoleEntry]
		# clear entry
		$w.input delete 0 200
		focus $w.input
	}
}

#
#
#	Source a tcl script
#	@param w widget for console window
proc GeoLoadTcl {w} {
	global tclTypes
	global geoEasyMsg
	global lastDir

	set on [string trim [tk_getOpenFile -defaultextension ".tcl" \
		-initialdir $lastDir -filetypes $tclTypes ]]
	if {[string length $on] == 0 || [string match "after#*" $on]} { return }
	set lastDir [file dirname $on]
	if {[catch {source $on} msg] != 0} {
		geo_dialog .msg $geoEasyMsg(error) $msg error 0 OK
	}
}

#
#   convert angle (radian) to string 
#   @param val angle to convert in radian
#   @return angle in angleUnits
proc ANG {val} {
    global angleUnits

    set w ""
    if {[string length [string trim $val]] > 0} {
        switch -exact $angleUnits {
            "DMS" { set w [DMS $val]}
            "GON" { set w [GON $val]}
            "DMS1" { set w [DMS1 $val]}
            "DEG" { set w [DEG $val]}
        }
    }
    return $w
}

#
#   Convert text to angle
#   @param val angle text format
#   @return angl in radians
proc ANG1 {val} {
    global angleUnits PI

    set w ""
    switch -exact $angleUnits {
        "DMS1" -
        "DMS" { set w [DMS2Rad $val]}
        "GON" { set w [expr {$val / 200.0 * $PI}]}
        "DEG" { set w [expr {$val / 180.0 * $PI}]}
    }
    return $w
}
    
#
#   Convert distance/coordinate to string
#   @param val distance/coordinate
#   @return distance in $distUnits
proc DST {val} {
    global distUnits
    global decimals

    set w ""
    switch -exact $distUnits {
        "m" { set w [format "%.${decimals}f" $val] }
        "FEET" { set w [FEET $val] }
        "OL" { set w [OL $val] }
    }
    return $w
}

#
#   Convert string to distance/coordinate
#   @param val distance/coordinate string
#   @return distance in metres
proc DST1 {val} {
    global distUnits
    global FOOT2M OL2M

    set w ""
    switch -exact $distUnits {
        "m" { set w $val }
        "FEET" { set w [expr {$val * $FOOT2M}] }
        "OL" { set w [expr {$val * OL2M}] }
    }
    return $w
}

#
#	Convert angle in radian or seconds to DMS
#	@param angle angle to convert in radian
#	@param unit angle unit rad/sec
#	@param dec number of decimals in seconds
#	@return angle in DMS
proc DMS {val {unit "rad"} {dec 0}} {
	global PI

	if {$val < 0} {
		set val [expr {abs($val)}]
		set sign 1
	} else {
		set sign 0
	}
	switch -exact $unit {
		rad {
			set seconds [Rad2Sec $val]
		}
		sec {
			set seconds $val
		}
	}
	set p [expr {pow(10, $dec)}]
	set ss [expr {round($seconds * $p)}]
	set d [expr {int($ss / (3600 * $p))}]
	set m [expr {int(($ss % round(3600 * $p)) / 60 / $p)}]
	set s [expr {$ss % round(60 * $p) / $p}]
	if {$dec} {
		set wstr [format "%3d-%02d-%02.${dec}f" $d $m $s]
	} else {
		set wstr [format "%3d-%02d-%02d" $d $m [expr {round($s)}]]
	}
	if {$sign} {	;# negative angle
		set wstr "-$wstr"
	}
	return $wstr
}

#
#	Convert angle in DMS with tenth of seconds
#	@param val - angle in radians
#	@return angle in DMS with tenth of seconds
proc DMS1 {val} {
	return [DMS $val "rad" 1]
}

#
#	Convert angle in radian to Gon
#	@param angle angle to convert in radian/sec
#	@param unit angle unit rad/sec
proc GON {val {unit "rad"}} {
	global PI

	if {$unit == "sec"} {
		set val [Sec2Rad $val]
	}
	return [format "%.4f" [expr {$val * 200.0 / $PI}]]
}

#
#	Convert anle in rad or sec to decimal degrees
#	@param angle angle to convert
#	@param unit angle unit rad/sec
#	@return agnle in decimal degree
proc DEG {val {unit "rad"}} {
	global PI

	if {$unit == "sec"} {
		set val [Sec2Rad $val]
	}
	return [format "%.4f" [expr {$val * 180.0 / $PI}]]
}

#
#	Convert distance in meters to feet
#	@param dist distance in meter
#	@return dinstance in feet
proc FEET {dist} {
	global FOOT2M
	global decimals

	return [format "%.${decimals}f" [expr {$dist / $FOOT2M}]]
}

#
#	Convert distance in meters to ol (acient Hungarien length unit)
#	@param dist distance in meter
#	@return distance in ol
proc OL {dist} {
	global OL2M
	global decimals

	return [format "%.${decimals}f" [expr {$dist / $OL2M}]]
}

#
#	Convert angle from DMS to radian
#	@param dms angle in DMS (deg-min-sec) to convert into radian
#	@return angle in radian
#		or empty string if invalid value got
proc DMS2Rad {dms} {
	global PI

	set m 0
	set s 0
	regsub -- "^(\[0-9\]+).*" $dms "\\1" d			;# degree
#	remove leading zeros
	regsub -- "^0+(.*)" $d "\\1" d
	if {$d == ""} {set d 0}
	if {[regexp "^\[0-9\]+-\[0-9\]+" $dms]} {
		regsub -- "^\[0-9\]+-(\[0-9\]+).*" $dms "\\1" m	;# minute
	}
#	remove leading zeros
	regsub -- "^0+(.*)" $m "\\1" m
	if {$m == ""} {set m 0}
	if {[regexp "^\[0-9\]+-\[0-9\]+-\[0-9\]+" $dms]} {
		regsub -- "^\[0-9\]+-\[0-9\]+-(\[0-9\]+.*)" $dms "\\1" s	;# second
	}
#	remove leading zeros
	regsub -- "^0+(.*)" $s "\\1" s
	if {$s == ""} {set s 0}
	# check limits for degree, minute & second
	if {$d > 359 || $m > 60 || $s > 60} {
		return ""
	} else {
		return [expr {($d + $m / 60.0 + $s / 3600.0) / 180.0 * $PI}]
	}
}

#
#	Convert a float/integer value
#	@param n field length
#	@param m decimals
#	@param v value to convert
#	@return formatted number
proc DEC {n m v} {

	if {$m < 1} {				;# no decimals eg. integer
		if {$n < 1} {
			set f "%d"
		} else {
			set f "%${n}d"
		}
	} else {
		if {$n < 1} {
			set f "%.${m}f"
		} else {
			set f "%${n}.${m}f"
		}
	}
	return [format $f $v]
}

#
#	Convert a float value
#		uses $decimals global variable
#	@param v value to convert
proc FLOAT {v} {
	global decimals

	return [format "%.${decimals}f" $v]
}

#
#	Convert an integer value
#	@param v - value to convert
proc INT {v} {
	set v1 [expr {round($v)}]
	return [format "%d" $v1]
}

#
#	Beep n times
#	@param n number of beeps
proc Beep {{n 1}} {

	for {set i 0} {$i < $n} {incr i} {
		bell
	}
}

#
#
#
#	Check if entry contains a valid value and store if valid
#		and change to meters or radians
#	@param w handle to widget
#	@return 0 if valid, 1 if not
proc GeoValid {w} {
	global entryFmt entryCode entryCodes entryRow
	global geoEasyMsg
	global lastVal lastCode lastW
	global reg
	global PI FOOT2M OL2M

	set mustfill {2 5 62}
	# check only for enabled entry fields
	if {$w == "" || [winfo class $w] != "Entry" ||  \
			[$w cget -state] == "disabled"} {
		return 0
	}
	# avoid store using up and down arrow
	if {[info exists lastW] && $w != $lastW} { return 0 }
	set val [$w get]
	set origVal $val
	set r [GeoFmtCode $entryFmt($w)]
	regsub "^\[ 	\]*" $val "" val	;# remove leading spaces/tabs
	regsub "\[ 	\]*$" $val "" val		;# remove trailing spaces/tabs
	# one of the point names must be filled
	if {[lsearch -exact $mustfill $entryCode($w)] != -1 && \
		[string length $val] == 0} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(mustfill) \
			warning 0 OK
		set lastVal ""	;# to realize changes!
		focus $w
		return 1
	}
	if {[string length $val] == 0} {
		if {[info exists lastVal] && $lastVal != $val} { 
			GeoStoreEntry $w $val	;# empty delete previous
		}
	} elseif {[regexp $reg($r) $val]} {
		switch -- $entryFmt($w) {
			"DMS1" -
			"DMS" -
            "GON" -
            "DEG" -
            "ANG" {
				set val [ANG1 $val]
				if {[string length $val] == 0} {	;# invalid angle
					geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(wrongval) \
						warning 0 OK
					set lastVal ""	;# to realize changes!
					focus $w
					return 1
				}
			}
			"FEET" -
            "OL" -
            "DST" {
				set val [DST1 $val]
			}
		}
		if {[info exists lastVal] && \
				[string compare $origVal $lastVal] == 0 && \
				$lastCode == $entryCode($w)} {
			return 0	;# neither code nor value changed
		}
		GeoStoreEntry $w $val	;# store new value
	} else {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(wrongval) warning 0 OK
		focus $w
		return 1
	}
	return 0
}

#
#	Change entry type using popup menu
#	@param opts - codes of options in menu
#	@param w handle to widget
#	@param rootx, rooty position on screen
proc GeoMaskPopup {opts w rootx rooty} {
	global geoEasyMsg
	global geoMaskColors geoNotUsedColor
	global geoCodes
	global entryFmt entryCode entryCodes entryRow
	global geoModules

	catch {destroy .maskmenu}
	if {[lindex [$w configure -state] end] == "disabled"} {return}
	if {[GeoValid $w] == 1} {
		catch [focus $w]
		return
	}
	catch [focus $w]
	menu .maskmenu -tearoff 0
	set cl [lrange $geoMaskColors 0 [expr {[llength $opts] - 1}]]
	foreach o $opts c $cl {
        if {$o > 0} {
            .maskmenu add command -label $geoCodes($o) -foreground $c \
                -activeforeground $c \
                -command "set entryCode($w) $o; \
                    $w configure -foreground $c; \
                    GeoValid $w"
         } else {   ;# use gray for not used
            .maskmenu add command -label $geoCodes($o) -foreground $geoNotUsedColor \
                -activeforeground $geoNotUsedColor \
                -command "set entryCode($w) $o; \
                    $w configure -foreground $geoNotUsedColor; \
                    GeoValid $w"
         }
	}
	.maskmenu add separator
	if {[regexp "_geo\.grd\.e" $w]} {					;# geo data set
		.maskmenu add command -label $geoEasyMsg(delete) \
			-command "GeoDelete $w"
		.maskmenu add command -label $geoEasyMsg(newObs) \
			-command "GeoNewObs $w" -accelerator "F8"
		.maskmenu add command -label $geoEasyMsg(newSt) \
			-command "GeoNewSt $w" -accelerator "F7"
		.maskmenu add command -label $geoEasyMsg(insSt) \
			-command "GeoInsSt $w"
		.maskmenu add command -label $geoEasyMsg(delSt) \
			-command "GeoDelete $w 1"
	} else {											;# coordinates
		.maskmenu add command -label $geoEasyMsg(delete) \
			-command "CooDelete $w"
		.maskmenu add command -label $geoEasyMsg(newCoo) \
			-command "CooNew $w" -accelerator "F7"
	}
	.maskmenu add command -label $geoEasyMsg(find) \
		-command "GeoMaskFind $w"
	.maskmenu add cascade -label $geoEasyMsg(menuGraCal) \
		-menu .maskmenu.calc
	menu .maskmenu.calc -tearoff 0
	# get point name & coords for actual point
	set actPn [MaskGeoPNum $w]
	set coords [GetCoord $actPn {37 38}]
	set apprCoords [GetCoord $actPn {137 138}]
	# get number of occupations
	set st [GetStation $actPn]
	.maskmenu.calc add command -label $actPn -command "GeoInfo $actPn"
	.maskmenu.calc add separator
	if {[llength $coords] > 1} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.maskmenu.calc add command -label $geoEasyMsg(menuPopupBD) \
		-command "GeoBearingDistance $actPn [winfo toplevel $w]" \
		-state $mstat
	.maskmenu.calc add command -label $geoEasyMsg(menuPopupAngle) \
		-command "GeoAngle $actPn [winfo toplevel $w]" -state $mstat
	if {[llength $coords] > 1 && [llength $st] > 0} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.maskmenu.calc add command -label $geoEasyMsg(menuPopupOri) \
		-command "GeoOri $actPn [winfo toplevel $w] 8" \
		-state $mstat
	if {([llength $coords] > 1 || [llength $apprCoords] > 1) && \
		 [llength $st] > 0} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.maskmenu.calc add command -label $geoEasyMsg(menuPopupAppOri) \
		-command "GeoOri $actPn [winfo toplevel $w] 2" \
		-state $mstat
	if {[llength [GetPol $actPn]] > 0}  {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.maskmenu.calc add command -label $geoEasyMsg(menuPopupPol) \
		-command "GeoPol $actPn [winfo toplevel $w]" \
		-state $mstat
	if {[llength [GetExtDir $actPn]] > 1} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.maskmenu.calc add command -label $geoEasyMsg(menuPopupSec) \
		-command "GeoSec $actPn [winfo toplevel $w]" \
		-state $mstat
	if {[llength [GeoResStation $actPn]] > 0} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.maskmenu.calc add command -label $geoEasyMsg(menuPopupRes) \
		-command "GeoRes $actPn [winfo toplevel $w]" \
		-state $mstat
	if {[llength [GetDist $actPn]] > 1} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.maskmenu.calc add command -label $geoEasyMsg(menuPopupArc) \
		-command "GeoArc $actPn [winfo toplevel $w]" \
		-state $mstat
	set sumRef [GetSumRef $actPn]
	set hzCoo 0
	if {[GetCoord $actPn {38 37}] != "" || [GetCoord $actPn {138 137}] != ""} {
		set hzCoo 1
	}
	set elevCoo 0
	if {[GetCoord $actPn {39}] != "" || [GetCoord $actPn {139}] != ""} {
		set elevCoo 1
	}
	if {[lsearch -exact $geoModules adj] != -1} {
		if {$sumRef > 0 && $hzCoo && $elevCoo} {
			set mstat "normal"
		} else {
			set mstat "disabled"
		}
		.maskmenu.calc add command -label $geoEasyMsg(menuPopupAdj3D) \
			-command "GeoNet3D $actPn" -state $mstat
		if {$sumRef > 0 && $hzCoo} {
			set mstat "normal"
		} else {
			set mstat "disabled"
		}
		.maskmenu.calc add command -label $geoEasyMsg(menuPopupAdj2D) \
			-command "GeoNet2D $actPn" -state $mstat
		if {$sumRef > 0 && $elevCoo} {
			set mstat "normal"
		} else {
			set mstat "disabled"
		}
		.maskmenu.calc add command -label $geoEasyMsg(menuPopupAdj1D) \
			-command "GeoNet1D $actPn" -state $mstat
	}
	if {[llength [GetEle $actPn]] > 0} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.maskmenu.calc add command -label $geoEasyMsg(menuPopupEle) \
		-command "GeoEle $actPn [winfo toplevel $w]" \
		-state $mstat

	if {[llength $coords] > 1 && [llength $st] > 0} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.maskmenu.calc add command -label $geoEasyMsg(menuPopupDetail) \
		-command "GeoDetailStation $actPn" -state $mstat

	tk_popup .maskmenu $rootx $rooty
}

#
#	Get format specific code
#	@param fmt format string in mask definition
#	@return 0/1/2/3 text/int/float/DMS
proc GeoFmtCode {fmt} {

	switch -regexp -- $fmt {
		"^A[0-9]*$" {return 0}
		"^format .*d$" -
		"^INT$" -
		"^DEC \[0-9\]+$" {return 1}
		"^format .*f$" -
		"^FEET" -
		"^OL" -
		"^FLOAT$" -
		"^DEC \[0-9\]+\.?\[0-9\]+$" {return 2}
		"^DMS1?$" {return 3}
	}
	return 0									;# default ascii
}

#
#	Store new value in geo data set
#	@param w handle to widget
#	@param val value for entry
#			(stored form, angles must be in radians, distances in meters!)
proc GeoStoreEntry {w {val ""}} {
	global entryFmt entryCode entryCodes entryRow
	global geoChanged

	if {[lindex [$w configure -state] 4] != "normal"} {return}
	regsub "^\.(.*)\.grd\.e.*$" $w {\1} geo	;# get name of data set
	global $geo
	set ind $entryRow($w)
	if {[info exists ${geo}($ind)] == 0} {return}
	# mark change in data set
	regsub "^(.*)_\[gc\]\[eo\]o$" $geo {\1} fn
	set geoChanged($fn) 1

	upvar #0 ${geo}($ind) buf
	set buf [DelVal $entryCodes($w) $buf]
	if {[string length $val] > 0} {
		if {[string length $entryCode($w)] == 0} {
			set entryCode($w) [lindex $entryCodes($w) 0]
		}
		lappend buf [list $entryCode($w) $val]
	}
	switch -glob $geo {
		"*_geo" {
			if {[lsearch $entryCode($w) 2] != -1 || \
				[lsearch $entryCode($w) 5] != -1 || \
				[lsearch $entryCode($w) 62] != -1} {
				GeoRef $geo								;# refresh index
			}
		}
		"*_coo" {
			if {$entryCode($w) == 5 && $ind != $val} {
				#point number has been changed
				set w $buf
				unset ${geo}($ind)
				set ${geo}($val) $w
			}
		}
	}
}

#
#	Store entry code and value as string in lastVal & lastCode
#	@param w handle to widget
proc LastVal {w} {
	global lastVal lastCode lastW
	global entryRow entryCode
	global geoNum

	if {[winfo class $w] == "Entry" && [$w cget -state] == "normal"} {
		set lastW $w
		set lastVal [$w get]
		set lastCode $entryCode($w)
		# set record numer in status line
		regsub "^\.(.*)\.grd\.e.*$" $w {\1} geo	;# get name of data set
		global $geo
		if {[regexp "._geo" $geo]} {
			# observations
			catch {set geoNum([winfo toplevel $w]) \
				"[expr {$entryRow($w) + 1}]/[array size $geo]"}
		} else {
			# coordinates
			set pns [lsort -dictionary [array names $geo]]
			catch {set geoNum([winfo toplevel $w]) \
				"[expr {[lsearch -exact $pns $entryRow($w)] + 1}]/[array size $geo]"}
		}
	}
}

#
#	Delete observation/station from geo data set
#	@param w handle to widget
#	@param st_only delete station record only (optional, default 0)
proc GeoDelete {w {st_only 0}} {
	global geoEasyMsg
	global autoRefresh
	global entryFmt entryCode entryCodes entryRow
	global maskPos
	global geoChanged

	regsub "^\.(.*)\.grd\.e.*$" $w "\\1" geo		;# name of data set
	global $geo
	regsub "^(.*)_\[gc\]\[eo\]o$" $geo {\1} fn
	# mark change in data set
	set geoChanged($fn) 1
	set row $entryRow($w)
	set buf [set ${geo}($row)]
	set start $row
	set next [expr {$row + 1}]
	set n [llength [array names ${geo}]]
	if {[GetVal 2 $buf] != "" && $st_only == 0} {	;# station
		# confirm delete whole station
		if {[geo_dialog .msg $geoEasyMsg(info) $geoEasyMsg(stndel) \
			info 0 OK $geoEasyMsg(cancel)] == 1} {
			return
		}
		# looking for next station start
		while {$next < $n && [GetVal 2 [set ${geo}($next)]] == ""} {
			incr next
		}
	} else {
		# confirm delete record
		if {[geo_dialog .msg $geoEasyMsg(info) $geoEasyMsg(recdel) \
			info 0 OK $geoEasyMsg(cancel)] == 1} {
			return
		}
	}
	while {$next < $n} {							;# copy data set records
		set ${geo}($start) [set ${geo}($next)]
		incr start
		incr next
	}
	while {$start < $n} {							;# delete
		unset ${geo}($start)
		incr start
	}
	GeoRef $geo									;#	regenerate ref index
	# set position in status line
	catch { set geoNum([winfo toplevel $w]) \
			"[expr {$entryRow([focus]) + 1}]/[array size $geo]"
	}
#	avoid GeoValid in GeoFillMask !!!!!
	set act [focus]
	catch {unset entryRow($act)}
#	refresh mask
	if {$autoRefresh} {
		RefreshAll
	} else {
		eval [bind .$geo <Key-F2>]
	}
}

#
#	Delete coordinate entry
#	@param w handle to widget
proc CooDelete {w} {
	global entryFmt entryCode entryCodes entryRow
	global maskPos
	global geoChanged
	global autoRefresh
	global geoEasyMsg

	# confirm delete record
	if {[geo_dialog .msg $geoEasyMsg(info) $geoEasyMsg(recdel) \
		info 0 OK $geoEasyMsg(cancel)] == 1} {
		return
	}
	regsub "^\.(.*)\.grd\.e.*$" $w "\\1" geo		;# name of data set
	global $geo
	# mark change in data set
	regsub "^(.*)_\[gc\]\[eo\]o$" $geo {\1} fn
	set geoChanged($fn) 1
	set row $entryRow($w)
	if {[catch "unset ${geo}($row)"]} {
		# error deleting row
		Beep
		return
	} else {
		while {$maskPos(.$geo) >= [array size $geo]} {
			incr maskPos(.$geo) -1
		}
	}
	# set position in status line
	catch { set geoNum([winfo toplevel $w]) \
			"[expr {$entryRow([focus]) + 1}]/[array size $geo]"
	}
	if {$autoRefresh} {
		RefreshAll
	} else {
		eval [bind .$geo <Key-F2>]
	}
}

#
#	Add a new record to coordinates and ask for point name
#	@param w handle to widget
proc CooNew {w} {
	global geoCodes geoEasyMsg
	global cooMasks cooMaskParams
	global maskPos maskName
	global geoChanged

	set pn [GeoEntry "$geoCodes(5):" $geoCodes(5)]
	if {$pn == ""} {return}
	regsub "^\.(.*)\.grd\.e.*$" $w "\\1" geo		;# name of data set
	global $geo
	# mark change in data set
	regsub "^(.*)_\[gc\]\[eo\]o$" $geo {\1} fn
	set geoChanged($fn) 1
	if {[lsearch -exact [array names $geo] $pn] != -1} {
		# point name already used
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(usedPn) warning 0 OK
		return
	}
	set ${geo}($pn) [list [list 5 $pn]]
	# position of new element
	set maskPos(.$geo) [lsearch -exact [lsort -dictionary \
		[array names $geo]] $pn]
	eval [bind .$geo <Key-F2>]
}

#
#	Change approximate coordinates to final
#	@param w handle to widget
proc CooFinal {w} {
	global geoEasyMsg
	global autoRefresh

	regsub "^\.(.*)\.grd\.e.*$" $w "\\1" geo		;# name of data set
	if {[geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(finalize) \
		warning 0 $geoEasyMsg(yes) $geoEasyMsg(no)] == 1} { return }
	global $geo
	# mark change in data set
	regsub "^(.*)_\[gc\]\[eo\]o$" $geo {\1} fn
	set geoChanged($fn) 1
	foreach psz [array names $geo] {
		# replace 137, 138, 139 codes with 38, 37, 39
		upvar #0 ${geo}($psz) buf
		foreach code [list 137 138 139] {
			set pos [lsearch -glob $buf "$code *"]
			if {$pos >= 0} {
				set newCode [expr {$code - 100}]
				# has it final coordinate ?
				set pos1 [lsearch -glob $buf "$newCode *"]
				if {$pos1 >= 0} {
					# delete approximate coordinate, if we have final too
					set buf [DelVal $code $buf]
				} else {
					# replace approximate code with final
					set buf [lreplace $buf $pos $pos \
						[list $newCode [lindex [lindex $buf $pos] 1]]]
				}
			}
		}
	}
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	Add a new observation to geo data set and ask for point name
#	@param w handle to widget
proc GeoNewObs {w} {
	global geoCodes geoEasyMsg
	global entryFmt entryCode entryCodes entryRow
	global maskPos maskName geoMasks geoMaskParams
	global geoChanged

	if {[winfo class $w] != "Entry" || [info exists entryRow($w)] == 0} {
		Beep
		return
	}
	set pn [GeoEntry "$geoCodes(5):" $geoCodes(5)]
	if {$pn == ""} {return}
	regsub "^\.(.*)\.grd\.e.*$" $w "\\1" geo		;# name of data set
	set maskn $maskName(.$geo)
	upvar #0 geoMasks($maskn) mask
	set rows [lindex $mask 1]	;# number of rows in mask
	
	global $geo
	# mark change in data set
	regsub "^(.*)_\[gc\]\[eo\]o$" $geo {\1} fn
	set geoChanged($fn) 1
	# make room for new observation
	set n [llength [array names ${geo}]]
	set row $entryRow($w)
	for {set i [expr {$n - 1}]} {$i > $row} {incr i -1} {
		set ${geo}([expr {$i + 1}]) [set ${geo}($i)]
	}
	incr row
	set ${geo}($row) [list [list 5 $pn]]
	GeoRef $geo 									;# refresh ref array
	if {[expr {$maskPos(.$geo) + $rows - 1}] < $row} {
		set maskPos(.$geo) [expr {$n - ($rows >> 1)}]
	}
	eval [bind .$geo <Key-F2>]
}

#
#	Add a new station record to geo data set and ask for point name
#	@param w handle to widget
proc GeoNewSt {w} {
	global geoCodes geoEasyMsg
	global entryFmt entryCode entryCodes entryRow
	global maskPos maskName geoMasks geoMaskParams
	global geoChanged

	set pn [GeoEntry "$geoCodes(2):" $geoCodes(2)]
	if {$pn == ""} {return}
	regsub "^\.(.*)\.grd\.e.*$" $w "\\1" geo		;# name of data set
	regsub "_geo$" $geo "_ref" rn					;# name of ref array
	set maskn $maskName(.$geo)
	upvar #0 geoMasks($maskn) mask
	set rows [lindex $mask 1]	;# number of rows in mask
	
	global $geo $rn
	# mark change in data set
	regsub "^(.*)_\[gc\]\[eo\]o$" $geo {\1} fn
	set geoChanged($fn) 1
	# add to the end of data set
	set n [llength [array names ${geo}]]
	set ${geo}($n) [list [list 2 $pn]]
	lappend ${rn}($pn) $n
	if {[expr {$maskPos(.$geo) + $rows - 1}] < $n} {
		set maskPos(.$geo) [expr {$n - ($rows >> 1)}]
	}
	eval [bind .$geo <Key-F2>]
}

#
#	Insert a new station record before actual record
#	@param w widget
proc GeoInsSt {w} {
	global geoCodes geoEasyMsg
	global maskPos maskName geoMasks geoMaskParams
	global entryFmt entryCode entryCodes entryRow
	global geoChanged

	set pn [GeoEntry "$geoCodes(2):" $geoCodes(2)]
	if {$pn == ""} {return}
	regsub "^\.(.*)\.grd\.e.*$" $w "\\1" geo		;# name of data set
	global $geo
	regsub "^(.*)_\[gc\]\[eo\]o$" $geo {\1} fn
	# mark change in data set
	set geoChanged($fn) 1
	set maskn $maskName(.$geo)
	upvar #0 geoMasks($maskn) mask
	set rows [lindex $mask 1]	;# number of rows in mask
	set row $entryRow($w)
	set buf [set ${geo}($row)]
	# make room for new station
	set n [llength [array names ${geo}]]
	set row $entryRow($w)
	for {set i [expr {$n - 1}]} {$i >= $row} {incr i -1} {
		set ${geo}([expr {$i + 1}]) [set ${geo}($i)]
	}
#	incr row
	set ${geo}($row) [list [list 2 $pn]]
	GeoRef $geo 									;# refresh ref array
	if {[expr {$maskPos(.$geo) + $rows - 1}] < $row} {
		set maskPos(.$geo) [expr {$n - ($rows >> 1)}]
	}
	eval [bind .$geo <Key-F2>]
}

#
#	Scroll a mask
#	@param fn geo data set name
#	@param type _geo or _coo
#	@param w widget (toplevel)
#	@param args scroll info (scroll 1/-1 units/pages moveto percent
proc GeoMaskScr {fn type w args} {
	global geoMasks cooMasks
	global maskPos
	global ${fn}${type}
	global maskName

	set maskn $maskName($w)
	if {$type == "_geo"} {
		switch -exact [lindex $args 0] {
			scroll {
				if {[lindex $args 2] == "units"} {
					GeoPageMask $fn $w [lindex $args 1]
				} else {
					GeoPageMask $fn $w \
						[expr {[lindex $args 1] * [lindex $geoMasks($maskn) 1]}]
				}
			}
			moveto {
				set newpos [expr {int(\
					[lindex $args 1] * [llength [array names ${fn}${type}]] - \
					$maskPos($w) + 0.5)}]
				if {[expr {abs($newpos)}] > 2} {	;# move at least 3 lines
					GeoPageMask $fn $w $newpos
				}
			}
		}
	} else {
		switch -exact [lindex $args 0] {
			scroll {
				if {[lindex $args 2] == "units"} {
					CooPageMask $fn $w [lindex $args 1]
				} else {
					CooPageMask $fn $w \
						[expr {[lindex $args 1] * [lindex $cooMasks($maskn) 1]}]
				}
			}
			moveto {
				set newpos [expr {int(\
					[lindex $args 1] * [llength [array names ${fn}${type}]] - \
					$maskPos($w) + 0.5)}]
				if {[expr {abs($newpos)}] > 2} {	;# move at least 3 lines
					CooPageMask $fn $w $newpos
				}
			}
		}
	}
}

#
#	Start find/replace dialog
#	@param w widget, define column to search
proc GeoMaskFind {w} {
	global entryCodes entryRow
	global geoEasyMsg
	global maskPos
	global findTxt replaceTxt findMode findEntry findStart

	if {[info exists findTxt] == 0} { set findTxt "" }
	if {[info exists replaceTxt] == 0} { set replaceTxt "" }
	if {[info exists findMode] == 0} { set findMode 0 }
	set findEntry $w
	regsub "^\.(.*)\.grd\.e.*$" $w "\\1" geo		;# name of data set
	regsub ".*(_\[gc\]\[eo\]o)\$" $geo \\1 type		;# type of datat set
	if {$type == "_geo"} {
		set findStart [expr {$entryRow($w) + 1}]
	} else {
		set l [lsort -dictionary [array names $geo]]
		set p [lsearch  -exact $l $entryRow($w)]
		set findStart [expr {$p + 1}]
	}
	FindParams
#	tkwait window .findparams
#	if {$buttonid == 1} {return}
}

#
#		Find next entry matching pattern
proc GeoMaskFindNext {} {
	global findTxt replaceTxt findMode findEntry findStart
	global entryCodes entryFmt
	global geoEasyMsg
	global maskPos

	if {[string length $findTxt] == 0} {
		Beep
		return
	}
	set w $findEntry
	if {[info exists entryCodes($w)]} {
		set codes $entryCodes($w)
		regsub "^\.(.*)\.grd\.e.*$" $w "\\1" geo		;# name of data set
		global $geo
		regsub "_\[gc\]\[eo\]o\$" $geo "" fn			;# name of file
		regsub ".*(_\[gc\]\[eo\]o)\$" $geo \\1 type		;# type of datat set
		set n [llength [array names $geo]]
		if {$type == "_geo"} {
			for {set i $findStart} {$i < $n} {incr i} {
				set val [GetVal $codes [set ${geo}($i)]]
				if {$entryFmt($w) == 3 && [string length $val]} {
					set val [string trim [ANG $val]]
				}
				if {$findMode == 0 && [string match $findTxt $val] || \
					$findMode == 1 && [regexp -- $findTxt $val]} {
					GeoFillMask $fn $i [winfo toplevel $w]
					set maskPos([winfo toplevel $w]) $i
					set findStart [expr {$i + 1}]
					return
				}
			}
		} else {
			set l [lsort -dictionary [array names $geo]]
			set l [lrange $l $findStart end]
			foreach pn $l {
				set val [GetVal $codes [set ${geo}($pn)]]
				if {$findMode == 0 && [string match "$findTxt" "$val"] || \
					$findMode == 1 && [regexp -- "$findTxt" "$val"]} {
					CooFillMask $fn $findStart [winfo toplevel $w]
					set maskPos([winfo toplevel $w]) $findStart
					incr findStart
					return
				}
				incr findStart
			}
		}
	}
	Beep
	geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(nomore) warning 0 OK
}

#
#	Find/replace dialog box
proc FindParams {} {
	global geoEasyMsg
	global findTxt replaceTxt findMode findEntry findStart
	global buttonid

	set w [focus]
	if {$w == ""} { set w "." }
	set this .findparams
	set buttonid 0
	if {[winfo exists $this] == 1} {
		destroy $this
	}

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(findpar)
	wm resizable $this 0 0
	wm transient $this $w
	catch {wm attribute $this -topmost}
	label $this.lfind -text $geoEasyMsg(findWhat)
	label $this.lreplace -text $geoEasyMsg(replaceWith)
	checkbutton $this.mode -text $geoEasyMsg(findMode) -variable findMode
	entry $this.findtxt -textvariable findTxt -width 10
	entry $this.replacetxt -textvariable replaceTxt -width 10
	button $this.exit -text $geoEasyMsg(find) \
		-command "GeoMaskFindNext; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"
	grid $this.lfind -row 0 -column 0 -sticky w
	grid $this.findtxt -row 0 -column 1 -sticky w
#	grid $this.lreplace -row 1 -column 0 -sticky w
#	grid $this.replacetxt -row 1 -column 1 -sticky w
	grid $this.mode -row 2 -column 0 -sticky w -columnspan 2
	grid $this.exit -row 3 -column 0
	grid $this.cancel -row 3 -column 1
	focus $this.findtxt
	bind $this <Key-Escape> "destroy $this; set buttonid 1"
	tkwait visibility $this
	CenterWnd $this
}

#
#	Find the point number (station or target) for actual cell
#	@param w widget
proc MaskGeoPNum {w} {
	global entryRow

	if {[info exists entryRow($w)] == 0 || \
		[winfo class $w] != "Entry"} {return ""} ;# no check for entry
	regsub "^\.(.*)\.grd\.e.*$" $w {\1} geo	;# get name of data set
	global $geo
	set ind $entryRow($w)
	if {[info exists ${geo}($ind)] == 0} {return ""}
	upvar #0 ${geo}($ind) buf
	return [GetVal {2 5 62} $buf]
}

#
#	Export mask to html file & open browser
#	@param maskn mask definition name
#	@param fn geo data set name
#	@param type "_geo" or "_coo"
proc GeoMaskHtml {maskn fn type} {
	global geoEasyMsg
	global geoCodes
	global geoMasks geoMaskParams cooMasks cooMaskParams
	global lastDir
	global ${fn}${type}
	global ${fn}_par
	global geoMaskColors
	global browser
	global tcl_platform
	global webTypes

	if {$type == "_geo"} {
		upvar #0 geoMasks($maskn) mask
		upvar #0 geoMaskParams($maskn) params
	} else {
		upvar #0 cooMasks($maskn) mask
		upvar #0 cooMaskParams($maskn) params
	}
	set on [string trim [tk_getSaveFile -defaultextension ".html" \
		-initialdir $lastDir -filetypes $webTypes \
        -initialfile "i[GetShortName ${fn}]${type}"]]
	if {[string length $on] == 0 || [string match "after#*" $on]} { return }
	set lastDir [file dirname $on]
	set fd [open $on w]				;# output file
	fconfigure $fd -encoding cp1250
	puts $fd "<html>"
	puts $fd "<head><title>${fn}${type} ${geoEasyMsg(mainTitle)}</title>"
	puts $fd "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-2\">"
	puts $fd "</head>"
	puts $fd "<body bgcolor=\"#FFFFFF\" text=\"#000000\">"
	puts $fd "<p align=\"center\">${fn}${type}</p>"

	# param data for observations
	if {$type == "_geo"} {
		if {[info exists ${fn}_par]} {
			puts $fd "<p align=\"left\">"
			foreach codeval [set ${fn}_par] {
				set val [lindex $codeval 1]
				if {[string length $val]} {
					set code [lindex $codeval 0]
					puts $fd "$geoCodes($code): $val<br>"
				}
			}
		}
	}
	
	# table header
	puts $fd "<center><table border=1><tr>"
	
	set def [lrange $mask 2 end]
	foreach items $def {			;# create items in table header
		puts $fd "<th>"
		set i 0	;# color index
		foreach item $items {
			if {[catch {set t $geoCodes($item)}] != 0} {
				geo_dialog .msg $geoEasyMsg(error) \
					[format $geoEasyMsg(geocode) $item] error 0 OK
				close $fd
				return
			}
			if {$i > 0} {
				puts $fd "<br>"
			}
			puts $fd "<font color=\"[lindex $geoMaskColors $i]\">$t</font>"
			incr i
		}
		puts $fd "</th>"
	}
	puts $fd "</tr>"

	# output table body
	if {$type == "_geo"} {
		# observations
		set k 0
		while {1} {
			if {[info exists ${fn}${type}($k)]} {
				set rec [set ${fn}${type}($k)]
				if {[GetVal 2 $rec] == ""} {
					# not a station record
					set station 0
				} else {
					set station 1
				}
			} else {
				break
			}
			# start new table row
			puts $fd "<tr>"
			for {set j 0} {$j < [llength $def]} {incr j} {
				set items [lindex $def $j]
				set par [lindex $params $j]
				set ind 0
				set color "black"
				set code 0
				# set color of entry depending on code position
				foreach item $items {
					set val [GetVal $item $rec]
					if {$val != ""} {
						set color [lindex $geoMaskColors $ind]
						set code $item
						break
					}
					incr ind
				}
				if {[string index $par 0] == "-"} {
					set par [string range $par 1 end]
					if {$val == ""} {			;# no value remember to last
						set val [GetLast $fn $type $k $items]
					}
				}
				if {$val != ""} {
					if {$par != ""} {
						set val [eval $par $val]
					}
				} else {
					set val "\&nbsp\;"
				}
				# right justify numeric  values
				if {[lsearch -exact {3 6 7 8 9 10 11 21 100 101 102 103} \
							$code] != -1} {
					puts $fd "<td align=\"right\" valign=\"top\"><font color=\"$color\">$val</font></td>"
				} else {
					puts $fd "<td align=\"left\" valign=\"top\"><font color=\"$color\">$val</font></td>"
				}
			}
			puts $fd "</tr>"
			incr k
		}
	} else {
		# coordinates
		set pns [lsort -dictionary [array names ${fn}${type}]]
		foreach pn $pns {
			if {[info exists ${fn}${type}($pn)]} {
				set rec [set ${fn}${type}($pn)]
			} else {
				break
			}
			# start new table row
			puts $fd "<tr>"
			for {set j 0} {$j < [llength $def]} {incr j} {
				set items [lindex $def $j]
				set par [lindex $params $j]
				set ind 0
				set color "black"
				set code 0
				foreach item $items {
					set val [GetVal $item $rec]
					if {$val != ""} {
						set color [lindex $geoMaskColors $ind]
						set code $item
						break
					}
					incr ind
				}
				if {[string index $par 0] == "-"} {
					set par [string range $par 1 end]
					if {$val == ""} {	;# no value remember to last
						set val [GetLast $fn $type $h $items]
					}
				}
				if {$val != ""} {
					if {$par != ""} {
						set val [eval $par $val]
					}
				} else {
					set val "\&nbsp\;"
				}
				# right justify numeric values
				if {[lsearch -exact {37 38 39 137 138 139} $code] != -1} {
					puts $fd "<td align=\"right\" valign=\"top\"><font color=\"$color\">$val</font></td>"
				} else {
					puts $fd "<td align=\"left\" valign=\"top\"><font color=\"$color\">$val</font></td>"
				}
			}
			puts $fd "</tr>"
		}
	}

	puts $fd "</table></body></html>"
	close $fd
	if {[geo_dialog .msg $geoEasyMsg(info) $geoEasyMsg(openit) info 0 \
			$geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
		if {[ShellExec "$on"]} {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(browser) \
				warning 0 OK
		}
	}
}

#
#	Color name to RGB
#	@param c color name or rgb in #rrggbb form
#	@return r g b value list r, g, b < 256
proc c2dec {c} {

	foreach {r g b} [winfo rgb . $c] {break}
	foreach {rmax gmax bmax} [winfo rgb . white] {break}
	set r [expr {$r / (($rmax + 1) / 256)}]
	set g [expr {$g / (($gmax + 1) / 256)}]
	set b [expr {$b / (($bmax + 1) / 256)}]
	return [list $r $g $b]
}

#
#	RGB color to hexa code
#	@param rgbList list of decimal r, g, b values
#	@return hexadecimal color #rrggbb
proc dec2c {rgbList} {
	return [format "#%02X%02X%02X" \
		[lindex $rgbList 0] [lindex $rgbList 1] [lindex $rgbList 2]]
}

#
#	Export mask to rtf file & open word processor
#	@param maskn mask definition name
#	@param fn geo data set name
#	@param type "_geo" or "_coo"
proc GeoMaskRtf {maskn fn type} {
	global geoEasyMsg
	global geoCodes
	global geoMasks geoMaskParams cooMasks cooMaskParams
	global lastDir
	global ${fn}${type}
	global ${fn}_par
	global geoMaskColors
	global rtfview
	global tcl_platform
	global docTypes

	if {$type == "_geo"} {
		upvar #0 geoMasks($maskn) mask
		upvar #0 geoMaskParams($maskn) params
	} else {
		upvar #0 cooMasks($maskn) mask
		upvar #0 cooMaskParams($maskn) params
	}
	set on [string trim [tk_getSaveFile -defaultextension ".rtf" \
		-initialdir $lastDir -filetypes $docTypes \
        -initialfile "[GetShortName ${fn}]${type}"]]
	if {[string length $on] == 0 || [string match "after#*" $on]} { return }
	set lastDir [file dirname $on]
	set fd [open $on w]				;# output file
	fconfigure $fd -encoding cp1250
	# start rtf
	puts $fd "\{\\rtf1\\ansi\\ansicpg1250\\deff0\\deflang1038\\deflangfe1038"
	# font table
	puts $fd "\{\\fonttbl\{\\f0\\fmodern\\fcharset0 Courier New;\}\}"
	# page view, hungarian language, fontsize 10
	puts $fd "\\viewkind1\\pard\\lang1038\\f0\\fs20"
	# color table
	puts $fd "\{\\colortbl;"
	foreach c $geoMaskColors {
		set rgb [c2dec $c]
		puts $fd "\\red[lindex $rgb 0]\\green[lindex $rgb 1]\\blue[lindex $rgb 2];"
	}
	puts $fd "\}"
	# info
	puts $fd "\{\\info\{\\author $geoEasyMsg(mainTitle)\}\}"
	# page header/footer
	puts $fd "\{\\header \\brdrb\\brdrs\\brdrw10\\brsp20 \\qr\{$geoEasyMsg(mainTitle)\\par\}\}"
	puts $fd "\{\\footer \\brdrt\\brdrs\\brdrw10\\brsp20 \\qr\{\\field\{\\*\\fldinst \{PAGE\}\}\}\\par\}"

	# param data for observations
	if {$type == "_geo"} {
		if {[info exists ${fn}_par]} {
			foreach codeval [set ${fn}_par] {
				set val [lindex $codeval 1]
				if {[string length $val]} {
					set code [lindex $codeval 0]
					puts $fd "$geoCodes($code): $val\\par"
				}
			}
		}
	}
	# table header (repeated on all pages)
#	puts $fd "\\par "
	puts $fd "\\trowd \\trqc\\trgaph70\\trrh0\\trleft-70\\trhdr"
	set cwidth 1440	;# cell width in twips
	set def [lrange $mask 2 end]
	for {set i 0} {$i < [llength $def]} {incr i} {
		puts $fd "\\clbrdrt\\brdrhair \\clbrdrl\\brdrhair \\clbrdrb\\brdrhair \\clbrdrr\\brdrhair \\cellx[expr {($i + 1) * $cwidth}]"
	}
	foreach items $def {			;# create items in table header
		set i 0	;# color index
		puts $fd "\\pard \\intbl \\qc"
		foreach item $items {
			if {[catch {set t $geoCodes($item)}] != 0} {
				geo_dialog .msg $geoEasyMsg(error) \
					[format $geoEasyMsg(geocode) $item] error 0 OK
				close $fd
				return
			}
			if {$i > 0} {
				puts $fd "\\line "
			}
			puts $fd "\\cf[expr {$i + 1}] $t"
			incr i
		}
		puts $fd "\\cell"
	}
	puts $fd "\\pard \\intbl \\row"

	# output table body
	if {$type == "_geo"} {
		# observations
		set k 0
		while {1} {
			if {[info exists ${fn}${type}($k)]} {
				set rec [set ${fn}${type}($k)]
				if {[GetVal 2 $rec] == ""} {
					# not a station record
					set station 0
				} else {
					set station 1
				}
			} else {
				break
			}
			# start new table row
			puts $fd "\\trowd \\trqc\\trgaph70\\trrh0\\trleft-70"
			# cell definitions in row
			for {set j 0} {$j < [llength $def]} {incr j} {
				# cell borders
				puts $fd "\\clbrdrt\\brdrhair \\clbrdrl\\brdrhair \\clbrdrb\\brdrhair \\clbrdrr\\brdrhair \\cellx[expr {($j + 1) * $cwidth}]"
			}
			for {set j 0} {$j < [llength $def]} {incr j} {
				set items [lindex $def $j]
				set par [lindex $params $j]
				set ind 0
				set color "black"
				set code 0
				# set color of entry depending on code position
				foreach item $items {
					set val [GetVal $item $rec]
					if {$val != ""} {
#						set color [lindex $geoMaskColors $ind]
						set code $item
						break
					}
					incr ind
				}
				if {[string index $par 0] == "-"} {
					set par [string range $par 1 end]
					if {$val == ""} {			;# no value remember to last
						set val [GetLast $fn $type $k $items]
					}
				}
				if {$val != ""} {
					if {$par != ""} {
						set val [string trim [eval $par $val]]
					}
				} else {
					set color "black"
				}
				incr ind	;# color index start from 1
				# right justify numeric  values
				if {[lsearch -exact {3 6 7 8 9 10 11 21 100 101 102 103} \
							$code] != -1} {
					puts $fd "\\pard \\intbl \\qr \\cf$ind $val\\cell"
				} else {
					puts $fd "\\pard \\intbl \\ql \\cf$ind $val\\cell"
				}
			}
			puts $fd "\\pard \\intbl \\row"
			incr k
		}
	} else {
		# coordinates
		set pns [lsort -dictionary [array names ${fn}${type}]]
		foreach pn $pns {
			if {[info exists ${fn}${type}($pn)]} {
				set rec [set ${fn}${type}($pn)]
			} else {
				break
			}
			# start new table row
			puts $fd "\\trowd \\trqc\\trgaph70\\trrh0\\trleft-70"
			# cell definitions in row
			for {set j 0} {$j < [llength $def]} {incr j} {
				# cell borders
				puts $fd "\\clbrdrt\\brdrhair \\clbrdrl\\brdrhair \\clbrdrb\\brdrhair \\clbrdrr\\brdrhair \\cellx[expr {($j + 1) * $cwidth}]"
			}
			for {set j 0} {$j < [llength $def]} {incr j} {
				set items [lindex $def $j]
				set par [lindex $params $j]
				set ind 0
				set color "black"
				set code 0
				foreach item $items {
					set val [GetVal $item $rec]
					if {$val != ""} {
						set color [lindex $geoMaskColors $ind]
						set code $item
						break
					}
					incr ind
				}
				if {[string index $par 0] == "-"} {
					set par [string range $par 1 end]
					if {$val == ""} {	;# no value remember to last
						set val [GetLast $fn $type $h $items]
					}
				}
				if {$val != ""} {
					if {$par != ""} {
						set val [string trim [eval $par $val]]
					}
				} else {
					set color "black"
				}
				incr ind	;# color index start from 1
				# right justify numeric values
				if {[lsearch -exact {37 38 39 137 138 139} $code] != -1} {
					puts $fd "\\pard \\intbl \\qr \\cf$ind $val\\cell"
				} else {
					puts $fd "\\pard \\intbl \\ql \\cf$ind $val\\cell"
				}
			}
			puts $fd "\\pard \\intbl \\row"
		}
	}

	puts $fd "\\pard\\f0\\fs20\\par\}"
	close $fd
	if {[geo_dialog .msg $geoEasyMsg(info) $geoEasyMsg(openit) info 0 \
			$geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
		if {[ShellExec "$on"]} {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(rtfview) \
				warning 0 OK
		}
	}
}

#
#	Export mask to csv file & open spreadsheet
#	@param maskn mask definition name
#	@param fn geo data set internl name
#	@param type "_geo" or "_coo"
proc GeoMaskCsv {maskn fn type} {
	global geoEasyMsg
	global geoCodes
	global geoMasks geoMaskParams cooMasks cooMaskParams
	global lastDir
	global ${fn}${type}
	global ${fn}_par
	global geoMaskColors
#	global browser TBD
	global tcl_platform
	global csvTypes

	if {$type == "_geo"} {
		upvar #0 geoMasks($maskn) mask
		upvar #0 geoMaskParams($maskn) params
	} else {
		upvar #0 cooMasks($maskn) mask
		upvar #0 cooMaskParams($maskn) params
	}
	set on [string trim [tk_getSaveFile -defaultextension ".csv" \
		-initialdir $lastDir -filetypes $csvTypes \
        -initialfile "[GetShortName ${fn}]${type}"]]
	if {[string length $on] == 0 || [string match "after#*" $on]} { return }
	set lastDir [file dirname $on]
	set fd [open $on w]				;# output file
	fconfigure $fd -encoding cp1250
	puts $fd "[GetShortName ${fn}]${type}/${geoEasyMsg(mainTitle)}"

	# param data for observations
	if {$type == "_geo"} {
		if {[info exists ${fn}_par]} {
			foreach codeval [set ${fn}_par] {
				set val [lindex $codeval 1]
				if {[string length $val]} {
					set code [lindex $codeval 0]
					puts $fd "$geoCodes($code);$val"
				}
			}
		}
	}
	
	set def [lrange $mask 2 end]
	foreach items $def {			;# create items in table header
		set i 0	;# color index
		puts -nonewline $fd "\""
		foreach item $items {
			if {[catch {set t $geoCodes($item)}] != 0} {
				geo_dialog .msg $geoEasyMsg(error) \
					[format $geoEasyMsg(geocode) $item] error 0 OK
				close $fd
				return
			}
			if {$i > 0} {
				puts $fd ""
			}
			puts -nonewline $fd "$t"
			incr i
		}
		puts -nonewline $fd "\";"
	}
	puts $fd ""

	# output table body
	if {$type == "_geo"} {
		# observations
		set k 0
		while {1} {
			if {[info exists ${fn}${type}($k)]} {
				set rec [set ${fn}${type}($k)]
				if {[GetVal 2 $rec] == ""} {
					# not a station record
					set station 0
				} else {
					set station 1
				}
			} else {
				break
			}
			# start new row
			for {set j 0} {$j < [llength $def]} {incr j} {
				set items [lindex $def $j]
				set par [lindex $params $j]
				set ind 0
				set code 0
				# set color of entry depending on code position
				foreach item $items {
					set val [GetVal $item $rec]
					if {$val != ""} {
						set code $item
						break
					}
					incr ind
				}
				if {[string index $par 0] == "-"} {
					set par [string range $par 1 end]
					if {$val == ""} {			;# no value remember to last
						set val [GetLast $fn $type $k $items]
					}
				}
				if {$val != ""} {
					if {$par != ""} {
						set val [eval $par $val]
					}
				} else {
					set val ""
				}
				puts -nonewline $fd "$val;"
			}
			puts $fd ""
			incr k
		}
	} else {
		# coordinates
		if {[geo_dialog .msg $geoEasyMsg(info) $geoEasyMsg(csvwarning) info 0 \
				$geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
			set pns [lsort -dictionary [array names ${fn}${type}]]
			foreach pn $pns {
				if {[info exists ${fn}${type}($pn)]} {
					set rec [set ${fn}${type}($pn)]
				} else {
					break
				}
				# start new table row
				for {set j 0} {$j < [llength $def]} {incr j} {
					set items [lindex $def $j]
					set par [lindex $params $j]
					set ind 0
					set code 0
					foreach item $items {
						set val [GetVal $item $rec]
						if {$val != ""} {
							set code $item
							break
						}
						incr ind
					}
					if {[string index $par 0] == "-"} {
						set par [string range $par 1 end]
						if {$val == ""} {	;# no value remember to last
							set val [GetLast $fn $type $h $items]
						}
					}
					if {$val != ""} {
						if {$par != ""} {
							set val [eval $par $val]
						}
					} else {
						set val ""
					}
					# right justify numeric values
					puts -nonewline $fd "$val;"
				}
				puts $fd ""
			}
		} else {
			close $fd
			return
		}
	}

	close $fd
	if {[geo_dialog .msg $geoEasyMsg(info) $geoEasyMsg(openit) info 0 \
			$geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
		if {[ShellExec "$on"]} {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(browser) \
				warning 0 OK
		}
	}
}

#
#	Display meta data (date, observer, instrument, ...) in modal dialog
#	@param f geo data set short name
proc EditPar {f} {
	global geoLoaded parMask
	global geoChanged
	global buttonid
	global geoEasyMsg geoCodes
	global reg

    set fn [GetInternalName $f]
	global ${fn}_par
    set fs [GetShortName $f]
	set w [focus]
	if {$w == ""} { set w "." }
	set this .parmask
	set buttonid 0
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}

	toplevel $this -class Dialog
	wm title $this "$fs $geoEasyMsg(parmask)"
	wm resizable $this 0 0
	wm transient $this $w
	catch {wm attribute $this -topmost}

	if {[info exists ${fn}_par] == 0} { set ${fn}_par "" }
	set i 0
	foreach c $parMask {
		label $this.l$i -text "$geoCodes($c):"
		global e$i
		set e$i [GetVal $c [set ${fn}_par]]
		set old_e$i [set e$i]
		entry $this.e$i -textvariable e$i -width 10 -justify right
		grid $this.l$i -row $i -column 0 -sticky w
		grid $this.e$i -row $i -column 1 -sticky w
		incr i
	}
	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"
	grid $this.exit -row $i -column 0
	grid $this.cancel -row $i -column 1
	
#	update
	CenterWnd $this
	grab set $this
	tkwait variable buttonid

	if {$buttonid == 0} {
		set i 0
		foreach c $parMask {
			if {[info exists e$i] && [string length [set e$i]] && \
					[lsearch -exact {114 115 116} $c] != -1 && \
					[regexp $reg(2) [set e$i]] == 0} {
				geo_dialog .msg $geoEasyMsg(error) \
					"$geoEasyMsg(wrongval) $geoCodes($c)" error 0 OK
				return
			}
			incr i
		}
		set i 0
		set ${fn}_par ""
		foreach c $parMask {
			if {[info exists e$i]} {
				lappend ${fn}_par [list $c [set e$i]]
				if {[set e$i] != [set old_e$i]} {
					set geoChanged($fn) 1	;# mark id changed
				}
			}
			incr i
		}
	}
}

#
#	Get orthogonal transformation parameters (offset, rotation, scale)
#	and execute transformation
#	@param c name of coordinate array to transform
proc CooTrDia {c} {
	global geoEasyMsg
	global $c
	global tr_dy tr_dx tr_rot tr_scale tr_dz tr_scalez
	global reg
	global autoRefresh
	global decimals
	global buttonid

	set w [focus]
	if {$w == ""} { set w "." }
	set this .trparams
	set buttonid 0
	if {[winfo exists $this]} {
		raise $this
		Beep
		return
	}

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(trpar)
	wm resizable $this 0 0
	wm transient $this $w
	catch {wm attribute $this -topmost}

	label $this.ltrdy -text $geoEasyMsg(trdy)
	entry $this.etrdy -textvariable tr_dx -width 10
	label $this.ltrdx -text $geoEasyMsg(trdx)
	entry $this.etrdx -textvariable tr_dy -width 10
	label $this.ltrrot -text $geoEasyMsg(trrot)
	entry $this.etrrot -textvariable tr_rot -width 10
	label $this.ltrscale -text $geoEasyMsg(trscale)
	entry $this.etrscale -textvariable tr_scale -width 10
	label $this.ltrdz -text $geoEasyMsg(trdz)
	entry $this.etrdz -textvariable tr_dz -width 10
	label $this.ltrscalez -text $geoEasyMsg(trscalez)
	entry $this.etrscalez -textvariable tr_scalez -width 10
	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"

	grid $this.ltrdy -row 0 -column 0 -sticky w
	grid $this.etrdy -row 0 -column 1 -sticky w
	grid $this.ltrdx -row 1 -column 0 -sticky w
	grid $this.etrdx -row 1 -column 1 -sticky w
	grid $this.ltrrot -row 2 -column 0 -sticky w
	grid $this.etrrot -row 2 -column 1 -sticky w
	grid $this.ltrscale -row 3 -column 0 -sticky w
	grid $this.etrscale -row 3 -column 1 -sticky w
	grid $this.ltrdz -row 4 -column 0 -sticky w
	grid $this.etrdz -row 4 -column 1 -sticky w
	grid $this.ltrscalez -row 5 -column 0 -sticky w
	grid $this.etrscalez -row 5 -column 1 -sticky w
	grid $this.exit -row 6 -column 0
	grid $this.cancel -row 6 -column 1

	tkwait visibility $this
	CenterWnd $this
	grab set $this

	tkwait window $this
	if {$buttonid == 0} {
		if {[regexp $reg(2) $tr_dx] == 0 || [regexp $reg(2) $tr_dy] == 0 || \
			[regexp $reg(3) $tr_rot] == 0 || [regexp $reg(2) $tr_scale] == 0 || \
			[regexp $reg(2) $tr_dz] == 0 || [regexp $reg(2) $tr_scalez] == 0} {
			geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
				error 0 OK
			return
		}
		set angle [DMS2Rad $tr_rot]
		GeoLog1
		GeoLog "$geoEasyMsg(menuCooTr) - $c"
		# horizontal transformation
		if {$tr_dx != 0 || $tr_dy !=0 || $tr_scale != 1 || $angle != 0} {
			GeoLog1 "Y = $tr_dx + [expr {$tr_scale * cos($angle)}] * y - [expr {$tr_scale * sin($angle)}] * x"
			GeoLog1 "X = $tr_dy + [expr {$tr_scale * sin($angle)}] * y + [expr {$tr_scale * cos($angle)}] * x"
		}
		# vertical transformation
		if {$tr_dz != 0 || $tr_scalez != 1} {
			GeoLog1 "Z = $tr_dz + $tr_scalez * z"
		}

		GeoLog1 $geoEasyMsg(head2Tran)
		foreach p [lsort -dictionary [array names $c]] {
			upvar #0 ${c}($p) buf
			set x [GetVal 38 $buf]
			set y [GetVal 37 $buf]
			set xt ""
			set yt ""
			set zt ""
			if {$x != "" && $y != "" && \
				($tr_dx != 0 || $tr_dy != 0 || $tr_scale != 1 || $angle != 0)} {
				set xt [expr {$tr_dx + $tr_scale * cos($angle) * $x - \
					$tr_scale * sin($angle) * $y}]
				set yt [expr {$tr_dy + $tr_scale * sin($angle) * $x + \
					$tr_scale * cos($angle) * $y}]
				set buf [DelVal {37 38 137 138} $buf]
				lappend buf [list 38 $xt] ;#[format "%.4f" $xt]]
				lappend buf [list 37 $yt] ;#[format "%.4f" $yt]]
				GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" [GetVal 5 $buf] $x $y $xt $yt]
			}
			set z [GetVal 39 $buf]
			if {$z != "" && ($tr_dz != 0 || $tr_scalez != 1)} {
				set zt [expr {$tr_dz + $tr_scalez * $z}]
				set buf [DelVal {39 139} $buf]
				lappend buf [list 39 $zt] ;#[format "%.4f" $zt]]
				GeoLog1 [format "%-10s                                                      %12.${decimals}f %12.${decimals}f" [GetVal 5 $buf] $z $zt]
			}
			set x [GetVal 138 $buf]
			set y [GetVal 137 $buf]
			if {$x != "" && $y != ""} {
				set xt [expr {$tr_dx + $tr_scale * cos($angle) * $x + \
					$tr_scale * sin($angle) * $y}]
				set yt [expr {$tr_dy - $tr_scale * sin($angle) * $x + \
					$tr_scale * cos($angle) * $y}]
				set buf [DelVal {37 38 137 138} $buf]
				lappend buf [list 138 $xt] ;#[format "%.4f" $xt]]
				lappend buf [list 137 $yt] ;#[format "%.4f" $yt]]
				GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" [GetVal 5 $buf] $x $y $xt $yt]
			}
			set z [GetVal 139 $buf]
			if {$z != ""} {
				set zt [expr {$tr_dz + $tr_scalez * $z}]
				set buf [DelVal {39 139} $buf]
				lappend buf [list 139 $zt] ;#[format "%.4f" $zt]]
				GeoLog1 [format "%-10s                                                      %12.${decimals}f %12.${decimals}f" [GetVal 5 $buf] $z $zt]
			}
		}
		if {$autoRefresh} {
			RefreshAll
		}
	}
}

#
#	Set defaults for transformation
proc TrSet { } {
	global tr_dy tr_dx tr_rot tr_scale tr_dz tr_scalez

	set tr_dx 0
	set tr_dy 0
	set tr_rot 0
	set tr_scale 1
	set tr_dz 0
	set tr_scalez 1
}

#
#	Transform coords using TRAFO .all parameter file.
#	@param x,y coordinate to transform
#	@param a name of polynom coefficients array
#	@return transformed x
proc PolyTr {x y aref} {
	upvar $aref a
	set n [array size a]
	set xt 0
	if {$n > 2} {
		# linear part
		set xt [expr {$a(0) + $a(1) * $x + $a(2) * $y}]
	}
	if {$n > 5} {
		# quadratic part
		set xt [expr {$xt + $a(3) * $x * $x + $a(4) * $x * $y + \
			$a(5) * $y * $y}]
	}
	if {$n > 9} {
		# cubic part
		set xt [expr {$xt + $a(6) * pow($x,3) + $a(7) * $x * $x * $y + \
			$a(8) * $x * $y * $y + $a(9) * pow($y,3)}]
	}
	if {$n > 14} {
		# fourth order
		set xt [expr {$xt + $a(10) * pow($x,4) + $a(11) * pow($x,3) * $y + \
			$a(12) * $x * $x * $y * $y + $a(13) * $x * pow($y,3) + \
			$a(14) * pow($y,4)}]
	}
	if {$n > 20} {
		# fifth order
		set xt [expr {$xt + $a(15) * pow($x,5) + $a(16) * pow($x,4) * $y + \
			$a(17) * pow($x,3) * $y * $y + $a(18) * $x * $x * pow($y,3) + \
			$a(19) * $x * pow($y,4) + $a(20) * pow($y,5)}]
	}
	return $xt
}

#
#	Transform coords using ITR .prm or TRAFO .all parameter file
#	@param c name of coordinate array to transform
proc CooTrFile {c} {
	global $c
	global autoRefresh
	global geoEasyMsg
	global lastDir
	global tr12Types
	global decimals

	set fn [string trim \
		[tk_getOpenFile -filetypes $tr12Types -initialdir $lastDir]]
	if {[string length $fn] && [string match "after#*" $fn] == 0} {
		set lastDir [file dirname $fn]
		switch -glob [string tolower $fn] {
			*.prm {
				if {[catch {set f [open $fn "r"]}] != 0} {
					geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(-1) error 0 OK
					return
				}
				# load affine parameters
				for {set i 0} {$i < 6} {incr i} {
					if {[catch {set par($i) [string trim [gets $f]]}] != 0} {
						geo_dialog .msg $geoEasyMsg(error) \
							"$geoEasyMsg(-5) [expr {$i + 1}]" error 0 OK
						catch {close $f}
						return
					}
				}
				catch {close $f}
				GeoLog1
				GeoLog "$geoEasyMsg(menuCooTrFile) - $c - $fn"
				GeoLog1 [format $geoEasyMsg(formulaPrmy) \
					[format "%.${decimals}f" $par(0)] $par(2) $par(3)]
				GeoLog1 [format $geoEasyMsg(formulaPrmx) \
					[format "%.${decimals}f" $par(1)] $par(4) $par(5)]
				GeoLog1 $geoEasyMsg(head2Tran)
				catch {unset buf}
				foreach p [lsort -dictionary [array names $c]] {
					upvar #0 ${c}($p) buf
					set x [GetVal 38 $buf]
					set y [GetVal 37 $buf]
					set xe [GetVal 138 $buf]
					set ye [GetVal 137 $buf]
					if {$x != "" && $y != ""} {
						set xt [expr {$par(0) + $par(2) * $x + $par(3) * $y}]
						set yt [expr {$par(1) + $par(4) * $x + $par(5) * $y}]
						set buf [DelVal {37 38 137 138} $buf]
						lappend buf [list 38 $xt] ;#[format "%.4f" $xt]]
						lappend buf [list 37 $yt] ;#[format "%.4f" $yt]]
						GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" [GetVal 5 $buf] $x $y $xt $yt]
					} elseif {$xe != "" && $ye != ""} {
						set xt [expr {$par(0) + $par(2) * $xe + $par(3) * $ye}]
						set yt [expr {$par(1) + $par(4) * $xe + $par(5) * $ye}]
						set buf [DelVal {37 38 137 138} $buf]
						lappend buf [list 138 $xt] ;#[format "%.4f" $xt]]
						lappend buf [list 137 $yt] ;#[format "%.4f" $yt]]
						GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f *" [GetVal 5 $buf] $xe $ye $xt $yt]
					}	
				}
			}
			*.all {
				if {[catch {set f [open $fn "r"]}] != 0} {
					geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(-1) error 0 OK
					return
				}
				for {set i 0} {$i < 20} {incr i} {
					set a($i) 0
					set b($i) 0
				}
				set sy 0
				set sx 0
				set j 0
				while {! [eof $f]} {
					set buf [gets $f]
					if {[regexp "^\[ \t\]*\[0-9\]+\[ \t\]+-?\[0-9\]+\.?\[0-9\]*(\[dDeE\]\[+-\]?\[0-9\]*)?\[ \t\]+-?\[0-9\]+\.?\[0-9\]*(\[dDeE\]\[+-\]?\[0-9\]*)?\[ \t\]*$" $buf]} {
						while {[regsub -all "  " [string trim $buf] " " buf]} {}
						while {[regsub -all "\[dD\]" [string trim $buf] "e" buf]} {}	;# 1d5 -> 1e5
						set buflist [split $buf]
#						set i [expr {[lindex $buflist 0] - 1}]
						set a($j) [lindex $buflist 1]
						set b($j) [lindex $buflist 2]
						incr j
					} elseif {[regexp "^ *sy *= *.*sx *= *" $buf]} {
						while {[regsub -all "\[,=sxy\]" $buf "" buf]} { }
						while {[regsub -all "  " $buf " " buf]} { }
						set buflist [split [string trim $buf]]
						set sx [lindex $buflist 0]
						set sy [lindex $buflist 1]
					} elseif {[regexp "^\[ \t\]*-?\[0-9\]+\.?\[0-9\]*(\[dDeE\]\[+-\]?\[0-9\]*)?\[ \t\]+-?\[0-9\]+\.?\[0-9\]*(\[dDeE\]\[+-\]?\[0-9\]*)?\[ \t\]*$" $buf]} {
						while {[regsub -all "  " $buf " " buf]} { }
						set buflist [split [string trim $buf]]
						set sx [lindex $buflist 0]
						set sy [lindex $buflist 1]
					}
				}
				catch {close $f}
				if {$j > 21} {
					geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(allparnum) \
						error 0 OK
					return
				}
				GeoLog1
				GeoLog "$geoEasyMsg(menuCooTrFile) - $c - $fn"
#				GeoLog1 "Y = $a(0) + $a(1) * y + $a(2) * x + $a(3) * y^2 + $a(4) * y * x + $a(5) * x^2 + $a(6) * y^3 + $a(7) * y^2 * x + $a(8) * y * x^2 + $a(9) * x^3"
#				GeoLog1 "X = $b(0) + $b(1) * y + $b(2) * x + $b(3) * y^2 + $b(4) * y * x + $b(5) * x^2 + $b(6) * y^3 + $b(7) * y^2 * x + $b(8) * y * x^2 + $b(9) * x^3"
				GeoLog1 $geoEasyMsg(head2Tran)
				catch {unset buf}
				foreach p [lsort -dictionary [array names $c]] {
					upvar #0 ${c}($p) buf
					set x [GetVal 38 $buf]
					set xx $x
					if {$x != ""} {set x [expr {$x - $sx}]}
					set y [GetVal 37 $buf]
					set yy $y
					if {$y != ""} {set y [expr {$y - $sy}]}
					set xe [GetVal 138 $buf]
					set xxe $xe
					if {$xe != ""} {set xe [expr {$xe - $sx}]}
					set ye [GetVal 137 $buf]
					set yye $ye
					if {$ye != ""} {set ye [expr {$ye - $sy}]}
					if {$x != "" && $y != ""} {
						set xt [PolyTr $x $y a]
						set yt [PolyTr $x $y b]
						set buf [DelVal {37 38 137 138} $buf]
						lappend buf [list 38 $xt] ;#[format "%.4f" $xt]]
						lappend buf [list 37 $yt] ;#[format "%.4f" $yt]]
						GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f" [GetVal 5 $buf] $xx $yy $xt $yt]
					} elseif {$xe != "" && $ye != ""} {
						set xt [PolyTr $xe $ye a]
						set yt [PolyTr $xe $ye b]
						set buf [DelVal {37 38 137 138} $buf]
						lappend buf [list 138 $xt] ;#[format "%.4f" $xt]]
						lappend buf [list 137 $yt] ;#[format "%.4f" $yt]]
						GeoLog1 [format "%-10s %12.${decimals}f %12.${decimals}f %12.${decimals}f %12.${decimals}f ***" [GetVal 5 $buf] $xxe $yye $xt $yt]
					}
				}
			}
		}
		if {$autoRefresh} {
			RefreshAll
		}
	}
}

#
#	Delete approximate coordinates from data set
#	@param c data set
#	@param confirm 1/0 confirm delete/no confirmation
proc CooDelAppr {c {confirm 1}} {
	global geoEasyMsg
	global $c
	global autoRefresh
	global geoChanged

	if {$confirm} {
		if {[geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(delappr) \
			warning 0 OK $geoEasyMsg(cancel)] != 0} {
			return
		}
	}
	regsub "_coo$" $c "" fn
	foreach p [array names $c] {
		upvar #0 ${c}($p) buf
		set buf [DelVal {137 138 139} $buf]
		set geoChanged($fn) 1
	}
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	Delete all coordinates from data set
#	@param c data set
proc CooDel {c} {
	global geoEasyMsg
	global $c
	global autoRefresh
	global geoChanged

	if {[geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(delcoo) \
		warning 0 OK $geoEasyMsg(cancel)] != 0} {
		return
	}
	regsub "_coo$" $c "" fn
	foreach p [array names $c] {
		upvar #0 ${c}($p) buf
		set buf [DelVal {37 38 39 137 138 139} $buf]
		set geoChanged($fn) 1
	}
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	Delete all points from data set
#	@param c data set
proc PntDel {c} {
	global geoEasyMsg
	global $c
	global autoRefresh

	if {[geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(delpnt) \
		warning 0 OK $geoEasyMsg(cancel)] != 0} {
		return
	}
	unset $c
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	Delete all deatail point from coordinate list
#	@param c data set
proc CooDelDetail {c} {
	global geoEasyMsg
	global $c
	global autoRefresh
	global geoChanged

	if {[geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(deldetailpnt) \
		warning 0 OK $geoEasyMsg(cancel)] != 0} {
		return
	}
	regsub "_coo$" $c "" fn
	set detail [GetDetail]
	foreach p $detail {
		if {[info exists ${c}($p)]} {
			upvar #0 ${c}($p) buf
			set buf [DelVal {37 38 39 137 138 139} $buf]
			set geoChanged($fn) 1
		}
	}
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	Set the focus to the next field, move up the list on last field
#	Binded to Key-Return, Tab
#	It is special for fieldbook an co-ordinate list windows
#	@param field handle to widget
proc NextField {field} {

	if {[regexp "\.grd\.e\[0-9\]+-\[0-9\]+$" $field]} {
		global maskPos
		# a field from a fieldbook or co-ordinate list
		regsub "(.*)\.grd\.e\[0-9\]+-\[0-9\]+$" $field \\1 w
		set pos [string last "e" $field];# find row and col pos in entry name
		incr pos
		set rc [split [string range $field $pos end] "-"]
		set r [lindex $rc 0]	;# actual row
		set next_field [tk_focusNext $field]
		set pos [string last "e" $next_field];# find row and col pos in entry name
		incr pos
		set rc_next [split [string range $next_field $pos end] "-"]
		set r_next [lindex $rc_next 0]	;# row of next field
		if {$r > $r_next} {
			incr maskPos($w)
			set pos [string last "_" $w]
			incr pos -1
			set fn [string range $w 1 $pos]
			if {[regexp "_geo$" $w]} {
				GeoFillMask $fn $maskPos($w) $w
			} else {
				CooFillMask $fn $maskPos($w) $w
			}
		} else {
			catch {focus [tk_focusNext $field]}
		}
	} else {
		# dialog box take the next field
		catch {focus [tk_focusNext $field]}
	}
}

#
#	Change the number of rows in mask
#	@param maskn mask name to use
#	@param fn data set to show
#	@param type geo or coo
#	@param w widget to actual window
proc ResizeMask {maskn fn type w} {
	global geoEasyMsg
	global geoMasks geoMaskParams cooMasks cooMaskParams
	global reg

	if {$type == "_geo"} {
		set r [lindex $geoMasks($maskn) 1]
	} else {
		set r [lindex $cooMasks($maskn) 1]
	}
	set r [GeoEntry $geoEasyMsg(rowCount) $geoEasyMsg(resize) $r 10]
	if {$r == ""} { return }
	if {[regexp $reg(1) $r] == 0 || $r < 5} {
		geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) error 0 OK
		return
	}
	if {$type == "_geo"} {
		set geoMasks($maskn) [lreplace $geoMasks($maskn) 1 1 $r]
	} else {
		set cooMasks($maskn) [lreplace $cooMasks($maskn) 1 1 $r]
	}
	GeoMaskExit $w
	GeoMask $maskn $fn $type
}

#
#	Change the mask for window
#	@param fn data set to show
#	@param type _geo or _coo
#	@param w widget to change
proc ChangeMask {fn type w} {

	if {$type == "_geo"} {
		set m [GeoSelectMask geoMasks]
	} else {
		set m [GeoSelectMask cooMasks]
	}
	if {[llength $m] > 0} {
		GeoMaskExit $w
		GeoMask $m $fn $type
	}
}

#
#	Generate co-ordinate difference to a loaded or unloaded coo file
#		source data set changed, co-ordinate differences addeds
#		(40-dN, 41-dE, 42-dZ)
#	@param source source geo data set
proc CooDif {{source ""}} {
    global geoLoaded
    global geoEasyMsg
    global fileTypes
    global lastDir
	global geoChanged
	global autoRefresh

    if {([info exists geoLoaded] == 0) || ([llength $geoLoaded] == 0)} {
        geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(-8) warning 0 OK
        return
    }
    # select source geo data set (co-ordinate system) if no parameter
    if {$source == ""} {
        set source [GeoListbox $geoLoaded 0 $geoEasyMsg(fromCS) 1]
        if {[llength $source] != 1} { return }
    }
    # select target geo data set (co-ordinate system)
    set typ [list [lindex $fileTypes [lsearch -glob $fileTypes "*.geo*"]]]
    set targetFile [string trim [tk_getOpenFile -filetypes $typ \
		-title $geoEasyMsg(toCS) -initialdir $lastDir]]
    if {[string length $targetFile] == 0 || \
		[string match "after#*" $targetFile]} { return }
    set lastDir [file dirname $targetFile]
    set target [GeoSetID]
	set unload 0
    if {[lsearch -exact $geoLoaded $target] == -1} {
		set unload 1
		# geo dataset not loaded, load target geo data set
		set res [LoadGeo $targetFile $target]
		if {$res != 0} {    ;# error loading
			UnloadGeo $target
			if {$res < 0} {
				geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg($res) warning 0 OK
			} else {
				geo_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(-5) $res" \
					warning 0 OK
			}
			return
		}
	} else {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(loaded) \
			warning 0 OK
	}
    upvar #0 ${source}_coo sourceCoo
    upvar #0 ${target}_coo targetCoo
	# calculate differences for all source points
    foreach pn [array names sourceCoo] {
		if {[info exists targetCoo($pn)]} {
			# remove old differences if exist
			set sourceCoo($pn) [DelVal {40 41} $sourceCoo($pn)]
			if {[GetVal {37 38} $sourceCoo($pn)] != "" && \
				[GetVal {37 38} $targetCoo($pn)] != ""} {
				set dN [expr {[GetVal 37 $sourceCoo($pn)] - [GetVal 37 $targetCoo($pn)]}]
				set dE [expr {[GetVal 38 $sourceCoo($pn)] - [GetVal 38 $targetCoo($pn)]}]
				lappend sourceCoo($pn) [list 40 $dN]
				lappend sourceCoo($pn) [list 41 $dE]
			}
			if {[GetVal {39} $sourceCoo($pn)] != "" && \
				[GetVal {39} $targetCoo($pn)] != ""} {
				set dEle [expr {[GetVal 39 $sourceCoo($pn)] - [GetVal 39 $targetCoo($pn)]}]
				# remove old differences if exist
				set sourceCoo($pn) [DelVal {42} $sourceCoo($pn)]
				lappend sourceCoo($pn) [list 42 $dEle]
			}
		}
	}
	if {$unload} {
		# unload target geo data set
		global ${target}_geo ${target}_ref ${target}_coo ${target}_par
		#remove memory structures
		foreach a "${target}_geo ${target}_ref ${target}_coo ${target}_par" {
			catch "unset $a"
		}
	}
	set geoChanged($source) 1
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	Search for a text pattern in window
#	@param w handle to text widget
proc GeoFormFind {w} {
	global geoEasyMsg

	set par [winfo toplevel $w]
	set this ${par}.find
	if {[winfo exists $this]} {
		wm deiconify $this
		raise $this
		$this.1.e selection range 0 end ;# pre select text
		Beep
		return
	}
	toplevel $this -class Dialog
	wm protocol $this WM_DELETE_WINDOW "destroy $this"
	wm protocol $this WM_SAVE_YOURSELF "destroy $this"
	wm resizable $this 0 0
	wm title $this $geoEasyMsg(find)
	wm geometry $this \
		"+[expr {[winfo rootx $w] + 30}]+[expr {[winfo rooty $w] + 30}]"
	catch {wm attribute $this -topmost}
	frame $this.1
	frame $this.2
	pack $this.1 $this.2 -side top
	label $this.1.l -text $geoEasyMsg(pattern)
	entry $this.1.e -textvariable pattern
	$this.1.e selection range 0 end	;# pre select text
	pack $this.1.l $this.1.e -side left
	button $this.2.find -text $geoEasyMsg(find) \
		-command "GeoFormFind1 $w \$pattern start"
	button $this.2.findnext -text $geoEasyMsg(findNext) \
		-command "GeoFormFind1 $w \$pattern last"
	button $this.2.close -text $geoEasyMsg(ok) -command "destroy $this"
	pack $this.2.find $this.2.findnext $this.2.close -side left -fill x
}

proc GeoFormFind1 {w pattern f} {
	global pos$w

	if {$f == "last" && [info exists pos$w] && [set pos$w] != ""} {
		set from [$w index "[set pos$w] +1 c"]
	} else {
		$w tag delete sel		;# remove previous selection
		set from "1.0"
	}
	set pos$w [$w search -forwards -regexp -nocase $pattern $from]
	if {[set pos$w] != ""} {
		$w see [set pos$w]
		$w tag add sel [set pos$w] [$w index "[set pos$w] wordend"]
	} else {
		Beep
	}
}

#
# destroy window and find window
# @param w window handler
proc GeoFormExit {w} {

    catch {destroy "$w.find"}
    destroy $w
}

#
# swap two coordinates in a loaded data set
# @param dataset a loaded data set
# @param cc code for coords to swap EN/EZ/NZ
proc Swap2 {dataset cc} {
    global geoChanged
    upvar #0 ${dataset}_coo coo

    if {! [info exists coo]} {
        GeoLog "Dataset not loaded $dataset"
        return
    }
	switch $cc {
		EN -
		NE -
		en -
		ne {
				set code1 38
				set code2 37
		}
		NZ -
		ZN -
		nz -
		zn {
				set code1 37
				set code2 39
		}
		EZ -
		ZE -
		ez -
		ze {
				set code1 38
				set code2 39
		}
		default { 
			GeoLog "invalid parameter"
			return
		}
	}
	set code3 [expr {$code1 + 100}]
	set code4 [expr {$code2 + 100}]
    foreach pn [array names coo] {
        upvar #0 ${dataset}_coo($pn) coo_rec
        set prelim1 0
		set prelim2 0
        set c1 [GetVal $code1 $coo_rec]
        if {$c1 == ""} {
            # try preliminary coords
            set c1 [GetVal $code3 $coo_rec]
            set prelim1 1
        }
        set c2 [GetVal $code2 $coo_rec]
        if {$c2 == ""} {
            set c2 [GetVal $code4 $coo_rec]
            set prelim2 1
		}
        if {$c1 != "" && $c2 != ""} {
            set coo_rec [DelVal [list $code1 $code3] $coo_rec]
            set coo_rec [DelVal [list $code2 $code4] $coo_rec]
            lappend coo_rec [list [expr {$prelim2 * 100 + $code1}] $c2]
            lappend coo_rec [list [expr {$prelim1 * 100 + $code2}] $c1]
            set geoChanged($dataset) 1
        }
    }
}
