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

#	Create a multi select listbox from list, display sublist elements given
#	by poses and display it at the center of the screen
#	@param li list of information (sublist are possible)
#	@param poses positions in list to display
#	@param title title of window
#	@param mode  "n" exactly n item must be selected
#				"-n" at least n item must be selected
#				"0" no selection at all
#	@param trav  special handling of end point of traverse if > 0, optional
#	@return a list of selections (elements from li)
proc GeoListbox {li poses title mode {trav 0}} {
	global geoEasyMsg
	global sel
	global lbPos

	set sel ""									;# no selection
	set this .geolb
	if {[winfo exists $this]} {
		raise $this
		return
	}
	set w [focus]
	if {$w == ""} { set w "." }
	toplevel $this -class Dialog
	set pmode [expr {abs($mode)}]
	wm title $this [format $title $pmode]
	if {[info exists lbPos] == 0 && [string length $w]} {
		set lbPos \
			"+[expr {[winfo rootx $w] + 30}]+[expr {[winfo rooty $w] + 30}]"
	}

	# center window on screen
#	set x [expr {int(([winfo screenwidth .] - 150) / 2.0)}]
#	set y [expr {int(([winfo screenheight .] - 100) / 2.0)}]
#	catch {wm geometry $this "+$x+$y"}
	catch {wm geometry $this $lbPos}
	wm protocol $this WM_DELETE_WINDOW "lbExit $this $mode $pmode 0"
	wm protocol $this WM_SAVE_YOURSELF "lbExit $this $mode $pmode 0"
	wm transient $this $w
	catch {wm attribute $this -topmost}

	frame $this.2
	pack $this.2 -side bottom

	frame $this.1
	pack $this.1 -side top -expand yes -fill both

	button $this.2.exit -text $geoEasyMsg(ok) \
		-command "lbExit $this $mode $pmode 1"
	pack $this.2.exit -side left -expand yes
	if {$mode <= 0} {	;# all button id no upper limit for selection
		button $this.2.all -text $geoEasyMsg(all) \
			-command {.geolb.1.l selection set 0 end}
		pack $this.2.all -side left -expand yes
	}
	if {$mode != 0} {
		if {$trav > 0} {
			button $this.2.lastp -text $geoEasyMsg(lastPoint) \
				-command "lbExit $this $mode $pmode 2"
			pack $this.2.lastp -side left -expand yes
		}
		button $this.2.cancel -text $geoEasyMsg(cancel) \
			-command "lbExit $this $mode $pmode 0"
		pack $this.2.cancel -side left -expand yes
	}

	scrollbar $this.1.s -command "$this.1.l yview"
	set smode "extended"
	listbox $this.1.l -width 40 -relief sunken -height 10 -selectmode $smode \
		-yscrollcommand "$this.1.s set" -setgrid yes

	pack $this.1.s -side right -fill both
	pack $this.1.l -side left -fill both -expand 1

	foreach items $li {
		set litem ""
		foreach pos $poses {
			if {[string length [lindex $items $pos]]} {
				lappend litem [lindex $items $pos]
			}
		}
		$this.1.l insert end $litem
	}
	# set selection if minimal number is available in list
	if {[llength $li] == [expr {abs($mode)}]} {
		$this.1.l selection set 0 end
	}

	update
	grab set $this

	tkwait variable sel
	set ret ""
	foreach s $sel {
		lappend ret [lindex $li $s]
	}
	unset sel
	return $ret
}

#
#	Exit proc for GeoListBox
#	Window position and size are stored in lbPos global
#	@param this window
#	@param mode "n" exactly n item must be selected
#				"-n" at least n item must be selected
#				"0" no selection at all
#	@param pmode absolute value of mode
#	@param flag 0/1/2 check the number of selected rows
#				2 is used for traversing
proc lbExit {this mode pmode flag} {
	global geoEasyMsg
	global sel
	global lbPos

	if {$flag > 0} {
		set s [$this.1.l curselection]
		set nsel [llength $s]
		if {$mode < 0 && $pmode > $nsel || $mode > 0 && $pmode != $nsel} {
			if {$mode > 0} {
				set msg  "$geoEasyMsg(wrongsel)\n[format $geoEasyMsg(wrongsel1) $pmode]"
			} else {
				set msg  "$geoEasyMsg(wrongsel)\n[format $geoEasyMsg(wrongsel2) $pmode]"
			}
			tk_dialog .msg $geoEasyMsg(warning) $msg warning 0 OK
			return
		}
		if {$flag == 2} { lappend s "end" }
	} else {
		set s ""
	}
	set sel $s
	set lbPos [wm geometry $this]
	destroy $this
}

#
#	Handler for button 1 click
#	@param x
#	@param y
proc lbButton1 {x y} {
	.geolb.1.l selection clear 0 end
	set i [.geolb.1.l index @$x,$y]
	.geolb.1.l selection set $i $i
	update
}

#
#	Create a new toplevel window with local grab to enter any text
#	@param l label to display
#	@param title title of window
#	@param def default entry
#	@param width width of entry field
#	@return the text entered
proc GeoEntry {l title {def ""} {width 10}} {
	global geoEasyMsg
	global buttonid e

	set w [focus]
	if {$w == ""} { set w . }
	catch {destroy .ge}
	set buttonid 0
	toplevel .ge -class Dialog
	wm title .ge $title
	wm transient .ge $w
	wm resizable .ge 0 0
	catch {wm attribute .ge -topmost}
	if {[string length $w]} {
		wm geometry .ge \
			"+[expr {[winfo rootx $w] + 30}]+[expr {[winfo rooty $w] + 30}]"
	}
	label .ge.l -text $l
	entry .ge.e -textvariable e
	.ge.e delete 0 [string length [.ge.e get]]
	.ge.e insert 0 $def
	.ge.e selection range 0 end
	grid .ge.l -row 0 -column 0
	grid .ge.e -row 0 -column 1
	button .ge.ok -text $geoEasyMsg(ok) -command "destroy .ge; set buttonid 0"
	button .ge.cancel -text $geoEasyMsg(cancel) \
		-command "destroy .ge; set buttonid 1"
	grid .ge.ok -row 1 -column 0
	grid .ge.cancel -row 1 -column 1
	focus .ge.e
	bind .ge.e <Return> "destroy .ge; set buttonid 0"
	bind .ge.e <Key-Escape> "destroy .ge; set buttonid 1"
	tkwait visibility .ge
	grab set .ge
	tkwait window .ge
	if {$buttonid} { return ""}			;# cancel return empty string
	return [string trim $e]
}

#
#	Create a new toplevel window with local grab to stop user interaction
#	@param ms message to display
#	@param t title
proc GeoProgress {{ms "Please wait"} {t ""}} {

	set w [focus]
	if {$w == ""} { set w "." }
	catch {destroy .gp}
	toplevel .gp -class Dialog
	wm title .gp $t
	wm protocol .gp WM_DELETE_WINDOW { }
	wm transient .gp $w
	wm resizable .gp 0 0
	catch {wm attribute .gp -topmost}
	bind .gp <Destroy> {break}
	label .gp.h -bitmap hourglass
	label .gp.l -text $ms
	pack .gp.h .gp.l -side left
	update
	tkwait visibility .gp
	CenterWnd .gp
	grab set .gp
	return .gp
}

#
#	Dialog to set up calculation parameters
proc GeoCParam {} {
	global projRed avgH stdAngle stdDist1 stdDist2 refr stdLevel
	global locprojRed locavgH locstdAngle locstdDist1 locstdDist2 locrefr locstdLevel locdec
	global decimals
	global geoEasyMsg
	global buttonid

	set locprojRed $projRed
	set locavgH $avgH 
	set locstdAngle $stdAngle
	set locstdDist1 $stdDist1
	set locstdDist2 $stdDist2
	set locrefr $refr
	set locstdLevel $stdLevel
	set locdec $decimals

	set w [focus]
	if {$w == ""} { set w "." }
	catch {destroy .param}
	toplevel .param -class Dialog
	
	wm title .param $geoEasyMsg(parTitle)
	wm resizable .param 0 0
	wm transient .param $w
	catch {wm attribute .param -topmost}

	label .param.lprojred -text $geoEasyMsg(projred)
	label .param.lavgh -text $geoEasyMsg(avgh)
	label .param.lstdangle -text $geoEasyMsg(stdangle)
	label .param.lstddist1 -text $geoEasyMsg(stddist1)
	label .param.lstddist2 -text $geoEasyMsg(stddist2)
	label .param.lstdlevel -text $geoEasyMsg(stdlevel)
	checkbutton .param.refr -text $geoEasyMsg(refr) -variable locrefr
	label .param.ldec -text $geoEasyMsg(dec)
	
	entry .param.projred -textvariable locprojRed -width 10
	entry .param.avgh -textvariable locavgH -width 10
	entry .param.stdangle -textvariable locstdAngle -width 10
	entry .param.stddist1 -textvariable locstdDist1 -width 10
	entry .param.stddist2 -textvariable locstdDist2 -width 10
	entry .param.stdlevel -textvariable locstdLevel -width 10
	entry .param.dec -textvariable locdec -width 10

	button .param.exit -text $geoEasyMsg(ok) \
		-command "destroy .param; set buttonid 0"
	button .param.cancel -text $geoEasyMsg(cancel) \
		-command "destroy .param; set buttonid 1"

	grid .param.lprojred -row 0 -column 0 -sticky w
	grid .param.lavgh -row 1 -column 0 -sticky w
	grid .param.lstdangle -row 2 -column 0 -sticky w
	grid .param.lstddist1 -row 3 -column 0 -sticky w
	grid .param.lstddist2 -row 4 -column 0 -sticky w
	grid .param.lstdlevel -row 5 -column 0 -sticky w
	grid .param.refr -row 6 -column 0 -sticky e -columnspan 2
	grid .param.ldec -row 7 -column 0 -sticky w

	grid .param.projred -row 0 -column 1 -sticky w
	grid .param.avgh -row 1 -column 1 -sticky w
	grid .param.stdangle -row 2 -column 1 -sticky w
	grid .param.stddist1 -row 3 -column 1 -sticky w
	grid .param.stddist2 -row 4 -column 1 -sticky w
	grid .param.stdlevel -row 5 -column 1 -sticky w
	grid .param.dec -row 7 -column 1 -sticky w
	
	grid .param.exit -row 8 -column 0
	grid .param.cancel -row 8 -column 1

	tkwait visibility .param
	CenterWnd .param
	grab set .param

	tkwait variable buttonid
	if {$buttonid == 0} {
		if {[catch {format %f $locprojRed}] == 0} {
			set projRed $locprojRed
		} else {
			if {[lsearch -exact {"EOV" "SZTEREO" "HENGER"} [string toupper $locprojRed]] != -1} {
				set projRed [string toupper $locprojRed]
			}
		}
		if {[catch {format %f $locavgH}] == 0} {
			set avgH $locavgH 
		}
		if {[catch {format %f $locstdAngle}] == 0} {
			set stdAngle $locstdAngle
		}
		if {[catch {format %f $locstdDist1}] == 0} {
			set stdDist1 $locstdDist1
		}
		if {[catch {format %f $locstdDist2}] == 0} {
			set stdDist2 $locstdDist2
		}
		if {[catch {format %f $locstdLevel}] == 0} {
			set stdLevel $locstdLevel
		}
		set refr $locrefr
		if {[catch {format %f $locdec}] == 0} {
			set decimals $locdec
		}
	}
}

#
#	Ask for a color and change the background color of a widget
#	@param w
proc SetColor {w} {

	set last [$w cget -background]
	set c [tk_chooseColor -initialcolor $last]
	if {[string length $c] > 0} {
		$w configure -background $c
	}
}

#
#	Get color values from dialog
proc GetColors {} {
	global geoMaskColors
	global geoObsColor geoLineColor geoFinalColor geoApprColor geoStationColor \
		geoOrientationColor geoNostationColor
	
	set geoMaskColors [list [.colors.mask1 cget -background] \
		[.colors.mask2 cget -background] \
		[.colors.mask3 cget -background] \
		[.colors.mask4 cget -background] \
		[.colors.mask5 cget -background]]
	set geoObsColor [.colors.obs cget -background]
	set geoFinalColor [.colors.final cget -background]
	set geoApprColor [.colors.appr cget -background]
	set geoNostationColor [.colors.nostation cget -background]
	set geoStationColor [.colors.station cget -background]
	set geoOrientationColor [.colors.orient cget -background]
	set geoLineColor [.colors.line cget -background]
}

#
#	Dialog to set up colors
proc GeoColor {} {
	global geoMaskColors
	global geoLineColor geoObsColor geoFinalColor geoApprColor geoStationColor \
		geoOrientationColor geoNostationColor
	global geoEasyMsg
	global buttonid
	global autoRefresh

	set w [focus]
	if {$w == ""} { set w "." }
	catch {destroy .colors}
	toplevel .colors -class Dialog
	
	wm title .colors $geoEasyMsg(colTitle)
	wm resizable .colors 0 0
	wm transient .colors $w
	catch {wm attribute .colors -topmost}

	label .colors.lmask -text $geoEasyMsg(mask)
	label .colors.lmask1 -text $geoEasyMsg(mask1Color)
	label .colors.lmask2 -text $geoEasyMsg(mask2Color)
	label .colors.lmask3 -text $geoEasyMsg(mask3Color)
	label .colors.lmask4 -text $geoEasyMsg(mask4Color)
	label .colors.lmask5 -text $geoEasyMsg(mask5Color)

	label .colors.lgraph -text $geoEasyMsg(graphTitle)
	label .colors.lobs -text $geoEasyMsg(obsColor)
	label .colors.lfinal -text $geoEasyMsg(finalColor)
	label .colors.lappr -text $geoEasyMsg(apprColor)
	label .colors.lnostation -text $geoEasyMsg(nostationColor)
	label .colors.lstation -text $geoEasyMsg(stationColor)
	label .colors.lorient -text $geoEasyMsg(orientColor)
	label .colors.lline -text $geoEasyMsg(lineColor)
	
	button .colors.mask1 -text " ... " \
		-background [dec2c [c2dec [lindex $geoMaskColors 0]]] \
		-command {SetColor .colors.mask1}
	button .colors.mask2 -text " ... " \
		-background [dec2c [c2dec [lindex $geoMaskColors 1]]] \
		-command {SetColor .colors.mask2}
	button .colors.mask3 -text " ... " \
		-background [dec2c [c2dec [lindex $geoMaskColors 2]]] \
		-command {SetColor .colors.mask3}
	button .colors.mask4 -text " ... " \
		-background [dec2c [c2dec [lindex $geoMaskColors 3]]] \
		-command {SetColor .colors.mask4}
	button .colors.mask5 -text " ... " \
		-background [dec2c [c2dec [lindex $geoMaskColors 4]]] \
		-command {SetColor .colors.mask5}
	button .colors.obs -text " ... " \
		-background [dec2c [c2dec $geoObsColor]] \
		-command {SetColor .colors.obs}
	button .colors.final -text " ... " \
		-background [dec2c [c2dec $geoFinalColor]] \
		-command {SetColor .colors.final}
	button .colors.appr -text " ... " \
		-background [dec2c [c2dec $geoApprColor]] \
		-command {SetColor .colors.appr}
	button .colors.nostation -text " ... " \
		-background [dec2c [c2dec $geoNostationColor]] \
		-command {SetColor .colors.nostation}
	button .colors.station -text " ... " \
		-background [dec2c [c2dec $geoStationColor]] \
		-command {SetColor .colors.station}
	button .colors.orient -text " ... " \
		-background [dec2c [c2dec $geoOrientationColor]] \
		-command {SetColor .colors.orient}
	button .colors.line -text " ... " \
		-background [dec2c [c2dec $geoLineColor]] \
		-command {SetColor .colors.line}

	button .colors.exit -text $geoEasyMsg(ok) \
		-command "GetColors; destroy .colors; set buttonid 0"
	button .colors.cancel -text $geoEasyMsg(cancel) \
		-command "destroy .colors; set buttonid 1"

	grid .colors.lmask -row 0 -column 0 ;#-sticky w
	grid .colors.lmask1 -row 1 -column 0 -sticky w
	grid .colors.lmask2 -row 2 -column 0 -sticky w
	grid .colors.lmask3 -row 3 -column 0 -sticky w
	grid .colors.lmask4 -row 4 -column 0 -sticky w
	grid .colors.lmask5 -row 5 -column 0 -sticky w
	grid .colors.lgraph -row 6 -column 0 ;#-sticky w
	grid .colors.lobs -row 7 -column 0 -sticky w
	grid .colors.lfinal -row 8 -column 0 -sticky w
	grid .colors.lappr -row 9 -column 0 -sticky w
	grid .colors.lnostation -row 10 -column 0 -sticky w
	grid .colors.lstation -row 11 -column 0 -sticky w
	grid .colors.lorient -row 12 -column 0 -sticky w
	grid .colors.lline -row 13 -column 0 -sticky w

	grid .colors.mask1 -row 1 -column 1 -sticky w
	grid .colors.mask2 -row 2 -column 1 -sticky w
	grid .colors.mask3 -row 3 -column 1 -sticky w
	grid .colors.mask4 -row 4 -column 1 -sticky w
	grid .colors.mask5 -row 5 -column 1 -sticky w
	grid .colors.obs -row 7 -column 1 -sticky w
	grid .colors.final -row 8 -column 1 -sticky w
	grid .colors.appr -row 9 -column 1 -sticky w
	grid .colors.nostation -row 10 -column 1 -sticky w
	grid .colors.station -row 11 -column 1 -sticky w
	grid .colors.orient -row 12 -column 1 -sticky w
	grid .colors.line -row 13 -column 1 -sticky w
	
	grid .colors.exit -row 14 -column 0
	grid .colors.cancel -row 14 -column 1

	tkwait visibility .colors
	CenterWnd .colors
	grab set .colors

	tkwait variable buttonid
	if {$buttonid == 0} {
		if {$autoRefresh} {
			RefreshAll
		}
	}
}

#
#	Change other parameters like txtsep etc.
proc GeoOParam {} {
	global cooSep
	global txtSep multiSep
	global browser
	global rtfview
	global autoRefresh
	global oriDetail
	global geoEasyMsg
	global locCooSep locTxtSep locBrowser locRtfview locMultiSep locAutoRefresh
	global locLang locOriDetail
	global locMaskRows locGeoMaskDefault locCooMaskDefault
	global buttonid
	global tcl_platform
	global geoLang
	global geoMasks cooMasks
	global maskRows geoMaskDefault cooMaskDefault

	set locCooSep $cooSep
	set locTxtSep $txtSep
	set locMultiSep $multiSep
	set locAutoRefresh $autoRefresh
	set locLang $geoLang
	set locOriDetail $oriDetail
	set locMaskRows $maskRows
	set locGeoMaskDefault $geoMaskDefault
	set locCooMaskDefault $cooMaskDefault

	set buttonid -1
	set w [focus]
	if {$w == ""} { set w "." }
	catch {destroy .oparams}
	toplevel .oparams -class Dialog
	
	wm title .oparams $geoEasyMsg(oparTitle)
	wm resizable .oparams 0 0
	wm transient .oparams $w
	catch {wm attribute .oparams -topmost}

	label .oparams.lcooSep -text  $geoEasyMsg(lcoosep)
	label .oparams.ltxtSep -text $geoEasyMsg(ltxtsep)
	label .oparams.llang -text $geoEasyMsg(llang)
	label .oparams.lgeomask -text $geoEasyMsg(defaultgeomask)
	label .oparams.lcoomask -text $geoEasyMsg(defaultcoomask)
	label .oparams.lmaskrows -text $geoEasyMsg(maskrows)
	if {$tcl_platform(platform) == "unix"} {
		label .oparams.lbrowser -text $geoEasyMsg(lbrowser)
		label .oparams.lrtfview -text $geoEasyMsg(lrtfview)
	}

	entry .oparams.cooSep -textvariable locCooSep -width 3
	entry .oparams.txtSep -textvariable locTxtSep -width 10
	checkbutton .oparams.multiSep -text $geoEasyMsg(lmultisep) \
		-variable locMultiSep
	checkbutton .oparams.autoR -text $geoEasyMsg(lautor) \
		-variable locAutoRefresh
	tk_optionMenu .oparams.lang locLang hun eng ger
	checkbutton .oparams.ori -text $geoEasyMsg(loridetail) \
		-variable locOriDetail
	set gm [tk_optionMenu .oparams.geomask locGeoMaskDefault dummy]
	$gm delete 0
	set i 0
	foreach g [lsort [array names geoMasks]] {
		$gm insert $i radiobutton -label $g -variable v -command \
			{global v; set locGeoMaskDefault $v}
		incr i
	}
	set cm [tk_optionMenu .oparams.coomask locCooMaskDefault dummy]
	$cm delete 0
	set i 0
	foreach c [lsort [array names cooMasks]] {
		$cm insert $i radiobutton -label $c -variable v -command \
			{global v; set locCooMaskDefault $v}
		incr i
	}
	entry .oparams.maskrows -textvariable locMaskRows -width 4
	if {$tcl_platform(platform) == "unix"} {
		set locBrowser $browser
		set locRtfview $rtfview
		entry .oparams.browser -textvariable locBrowser -width 50
		entry .oparams.rtfview -textvariable locRtfview -width 50

		button .oparams.bbrowser -text $geoEasyMsg(browse) \
			-command {set w [tk_getOpenFile]; \
				if {$w != ""} {set locBrowser $w}}
		button .oparams.brtfview -text $geoEasyMsg(browse) \
			-command {set w [tk_getOpenFile]; \
				if {$w != ""} {set locRtfview $w}}
	}

	button .oparams.exit -text $geoEasyMsg(ok) \
		-command "destroy .oparams; set buttonid 0"
	button .oparams.cancel -text $geoEasyMsg(cancel) \
		-command "destroy .oparams; set buttonid 1"

	grid .oparams.llang -row 0 -column 0 -sticky w
	grid .oparams.lang -row 0 -column 1 -sticky w
	grid .oparams.lcooSep -row 1 -column 0 -sticky w
	grid .oparams.ltxtSep -row 2 -column 0 -sticky w
	grid .oparams.lgeomask -row 7 -column 0 -sticky w
	grid .oparams.lcoomask -row 8 -column 0 -sticky w
	grid .oparams.lmaskrows -row 9 -column 0 -sticky w

	grid .oparams.cooSep -row 1 -column 1 -sticky w
	grid .oparams.txtSep -row 2 -column 1 -sticky w
	grid .oparams.multiSep -row 3 -column 0 -columnspan 2 -sticky w
	grid .oparams.autoR -row 4 -column 0 -columnspan 2 -sticky w
	grid .oparams.ori -row 6 -column 0 -columnspan 2 -sticky w
	grid .oparams.geomask -row 7 -column 1 -sticky w
	grid .oparams.coomask -row 8 -column 1 -sticky w
	grid .oparams.maskrows -row 9 -column 1 -sticky w
	if {$tcl_platform(platform) == "unix"} {
		grid .oparams.lbrowser -row 10 -column 0 -sticky w
		grid .oparams.lrtfview -row 11 -column 0 -sticky w

		grid .oparams.browser -row 10 -column 1 -sticky w
		grid .oparams.rtfview -row 11 -column 1 -sticky w

		grid .oparams.bbrowser -row 10 -column 2 -sticky w
		grid .oparams.brtfview -row 11 -column 2 -sticky w
	}
	grid .oparams.exit -row 12 -column 0
	grid .oparams.cancel -row 12 -column 1

	tkwait visibility .oparams
	CenterWnd .oparams
	grab set .oparams

	tkwait variable buttonid
	if {$buttonid == 0} {
		if {[string length $locCooSep]} {
			set cooSep $locCooSep
		}
		if {[string length $locTxtSep]} {
			set txtSep $locTxtSep
		}
		set multiSep $locMultiSep
		set autoRefresh $locAutoRefresh
		if {$locLang != $geoLang} {
			set geoLang $locLang
			tk_dialog .msg $geoEasyMsg(info) $geoEasyMsg(langChange) info 0 OK
		}
		set oriDetail $locOriDetail
		if {$locMaskRows > 2 && $locMaskRows < 50} {
			if {$locMaskRows != $maskRows} {
				set maskRows $locMaskRows
				# update maskRows in mask definitions
				foreach m [array names geoMasks] {
					set geoMasks($m) [lreplace $geoMasks($m) 1 1 $maskRows]
				}
				foreach m [array names cooMasks] {
					set cooMasks($m) [lreplace $cooMasks($m) 1 1 $maskRows]
				}
			}
		}
		set geoMaskDefault $locGeoMaskDefault
		set cooMaskDefault $locCooMaskDefault
		if {$tcl_platform(platform) == "unix"} {
			set browser $locBrowser
			set rtfview $locRtfview
		}
	}
}

#
#	Open file with the program assigned to the extension ini the registry
#	or in geo_easy.msk (linux)
#	@param f file to open
#	@return 0/1 success/error
proc ShellExec {f} {
	global tcl_platform
	global env
	global browser dxfview rtfview

	set cmd "open"
	set extension [string tolower [file extension $f]]
	if {[string tolower $tcl_platform(platform)] == "windows"} {
		if {[catch {set fileType [registry get "HKEY_CLASSES_ROOT\\$extension" ""]} err_str]} {
			return 1
		}
		if {[catch {set cmds [registry keys "HKEY_CLASSES_ROOT\\$fileType\\shell"]} err_str]} {
			return 1
		}
		if {[lsearch -exact $cmds $cmd] == -1} {
			return 1
		}
		if {[catch {set prog [registry get "HKEY_CLASSES_ROOT\\$fileType\\shell\\$cmd\\command" ""]} err_str]} {
			return 1
		}
		# double blackslashes for exec
		regsub -all {\\} $prog {\\\\} prog
		set prog [lindex $prog 0]
		# replace %var% from envexec
		while {[regexp "%(\[a-zA-Z0-9 \]+)%" $prog e v]} {
			regsub "$e" $prog $env($v) prog
		}
		# change relative to absolute path
		set f [file normalize $f]
		# execute program in the background
		if {[catch {exec "$prog" "$f" & } err_str]} {
			return 1
		}
	} else {
		switch -exact $extension {
			".html" -
			".htm" {
				if {[catch {eval exec "$browser" "$f" &} err_str]} {
					return 1
				}
			}
			".rtf" {
				if {[catch {eval exec "$rtfview" "$f" &} err_str]} {
					return 1
				}
			}
			".dxf" {
				if {[catch {eval exec "$dxfview" "$f" &} err_str]} {
					return 1
				}
			}
		}
	}
	return 0
}
