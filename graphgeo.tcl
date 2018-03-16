#//#
# tags used in graphic window
#
#	obs - observation lines
#	Ppnum - point number for circles e.g. P102
#	pnum - point number text (the word "pnum")
#	pcirc - point symbols
#	win - window for zoom in
#	poly - temperary polys for distance, area, traversing
#	Tid - triangles of dtm e.g. T123
#	Bid - break lines, boundaries for dtm e.g. B12
#	Hid - holes in dtm
#	Nid - nodes in dtm
#	tin - minden TIN elem
#	dtmpoly - temperary breakline polygons
#//#

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
#	Create a new graphic window
#	@param win_name name for window (e.g. .g0)
proc GeoNewWindow {{win_name ""}} {
	global geoEasyMsg
	global geoLoaded
	global geoWindowScale
	global geoWindowWidth
	global geoWindowHeight
	global geoXAct geoYAct geoRes
	global defaultObservations defaultDetails defaultPointNumbers \
		defaultUsedPointsOnly defaultCodedLines
	global observations details pointNumbers usedPointsOnly codedLines
	global toolbarMode 
	global geoModules
	global reglist

	if {([info exists geoLoaded] == 0 || [llength $geoLoaded] == 0) && \
		[lsearch -exact $geoModules "dtm"] == -1} {
		tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noGeo) warning 0 OK
#		return	;# no geo data set loaded
	}
	if {[llength [GetGiven]] == 0 && \
		[lsearch -exact $geoModules "dtm"] == -1} {
		tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noCoo) warning 0 OK
	}
	if {[string length $win_name]} {
		if {[winfo exists $win_name]} { }
		set this $win_name
		regexp "^\.g(\[0-9\]+)$" $win_name tmp i
	} else {
		# find first free window name
		set i 0
		while {[winfo exists .g$i] == 1} {
			incr i
		}
		if {$i > 9} {
			tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(maxGr) warning 0 OK
			return
		}
		set this .g$i
	}
	set geoXAct($this) ""
	set geoYAct($this) ""
	set geoRes($this) ""

	toplevel $this
	wm protocol $this WM_DELETE_WINDOW "GeoWindowExit $this"
	wm protocol $this WM_SAVE_YOURSELF "GeoWindowExit $this"
	wm title $this "$geoEasyMsg(graphTitle) $i"

# set default window parameters
	set geoWindowScale($this) 1.0
	set geoWindowWidth($this) 400
	set geoWindowHeight($this) 300
	set toolbarMode($this) 1

#	create the three main frames
	menu $this.menu -relief raised -tearoff 0 ;#-type menubar
	frame $this.toolbar -relief raised -borderwidth 2
	frame $this.map -relief flat
	frame $this.status -relief flat
	pack $this.toolbar -side top -fill x
	pack $this.status -side bottom -fill x
	pack $this.map -side bottom -fill both -expand yes

#	create menu
	$this.menu add cascade -label $geoEasyMsg(menuGraCom) \
		-menu $this.menu.command
	$this.menu add cascade -label $geoEasyMsg(menuGraCal) \
		-menu $this.menu.calculate
	if {[lsearch -exact $geoModules "dtm"] != -1} {
		$this.menu add cascade -label $geoEasyMsg(menuDtm) \
			-menu $this.menu.dtm
	}
	$this.menu add cascade -label $geoEasyMsg(help) \
		-menu $this.menu.help

	# display observations
	set observations($this) $defaultObservations
	# display detail points
	set details($this) $defaultDetails
	# display point numbers
	set pointNumbers($this) $defaultPointNumbers
	# unused points are displayed
	set usedPointsOnly($this) $defaultUsedPointsOnly
	# line from point codes are displayed
	set codedLines($this) $defaultCodedLines

	menu $this.menu.command -tearoff 0
	$this.menu.command add command -label $geoEasyMsg(menuRefreshAll) \
		-command "RefreshAll" -accelerator "Ctrl-F2"
	$this.menu.command add command -label $geoEasyMsg(menuGraRefresh) \
		-command "GeoDraw $this" -accelerator "F2"
	$this.menu.command add command -label $geoEasyMsg(menuGraZoomAll) \
		-command "GeoZoomAll $this.map.c" -accelerator "F3"
	$this.menu.command add command -label $geoEasyMsg(menuGraFind) \
		-command "GeoGraphFind $this" -accelerator "Ctlr-F"
	$this.menu.command add separator
	$this.menu.command add checkbutton -label $geoEasyMsg(menuGraPn) \
		-variable pointNumbers($this) -command "GeoDraw $this" \
		-accelerator "F7"
	$this.menu.command add checkbutton -label $geoEasyMsg(menuGraObs) \
		-variable observations($this) -command "GeoDraw $this" \
		-accelerator "F4"
	$this.menu.command add checkbutton -label $geoEasyMsg(menuGraDet) \
		-variable details($this) -command "GeoDraw $this" \
		-accelerator "F5"
	$this.menu.command add checkbutton -label $geoEasyMsg(menuGraUsed) \
		-variable usedPointsOnly($this) -command "GeoDraw $this" \
		-accelerator "F6"
	$this.menu.command add checkbutton -label $geoEasyMsg(menuGraLines) \
		-variable codedLines($this) -command "GeoDraw $this"
	$this.menu.command add separator
	$this.menu.command add command -label $geoEasyMsg(menuGraDXF) \
		-command "GeoDXF"
	$this.menu.command add separator
	$this.menu.command add command -label $geoEasyMsg(menuGraClose) \
		-command "GeoWindowExit $this"

	menu $this.menu.calculate -tearoff 0
	$this.menu.calculate add command -label $geoEasyMsg(menuCalOri) \
		-command "GeoFinalOri 13"
	$this.menu.calculate add command -label $geoEasyMsg(menuCalAppOri) \
		-command "GeoFinalOri 7"
	$this.menu.calculate add command -label $geoEasyMsg(menuCalDelOri) \
		-command "GeoDelOri"
	$this.menu.calculate add separator
	$this.menu.calculate add command -label $geoEasyMsg(menuCalTra) \
		-command "GeoTraverse 0"
	$this.menu.calculate add command -label $geoEasyMsg(menuCalTraNode) \
		-command "GeoTraverseNode 0"
	$this.menu.calculate add command -label $geoEasyMsg(menuCalTrig) \
		-command "GeoTraverse 1"
	$this.menu.calculate add command -label $geoEasyMsg(menuCalTrigNode) \
		-command "GeoTraverseNode 1"
	$this.menu.calculate add separator
    $this.menu.calculate add command -label $geoEasyMsg(menuCalLine) \
        -command "GeoLineLine"
    $this.menu.calculate add command -label $geoEasyMsg(menuCalPntLine) \
        -command "GeoPointOnLine"
    $this.menu.calculate add command -label $geoEasyMsg(menuCalLength) \
        -command "GeoCalcArea 0"
    $this.menu.calculate add command -label $geoEasyMsg(menuCalArea) \
        -command "GeoCalcArea 1"
    $this.menu.calculate add command -label $geoEasyMsg(menuCalArc) \
        -command "GeoSettingOutArc"
	$this.menu.calculate add separator
	$this.menu.calculate add command -label $geoEasyMsg(menuCalPre) \
		-command "GeoApprCoo"
	$this.menu.calculate add command -label $geoEasyMsg(menuRecalcPre) \
		-command "GeoRecalcAppr"
	if {[lsearch -exact $geoModules "adj"] != -1} {
		# adjustment with gnu gama
		$this.menu.calculate add command -label $geoEasyMsg(menuCalAdj3D) \
			-command "GeoNet3D"
		$this.menu.calculate add command -label $geoEasyMsg(menuCalAdj2D) \
			-command "GeoNet2D"
		$this.menu.calculate add command -label $geoEasyMsg(menuCalAdj1D) \
			-command "GeoNet1D"
	}
	$this.menu.calculate add command -label $geoEasyMsg(menuCalTran) \
		-command "GeoTran"
	$this.menu.calculate add command -label $geoEasyMsg(menuCalHTran) \
		-command "GeoHTran"
	$this.menu.calculate add separator
	$this.menu.calculate add command -label $geoEasyMsg(menuCalDet) \
		-command "GeoDetail 0"
	$this.menu.calculate add command -label $geoEasyMsg(menuCalDetAll) \
		-command "GeoDetail 1"
	$this.menu.calculate add command -label $geoEasyMsg(menuCalFront) \
		-command "GeoFront"
	if {[lsearch -exact $geoModules "reg"] != -1} {
		$this.menu.calculate add separator
		$this.menu.calculate add cascade -label $geoEasyMsg(menuReg) \
			-menu $this.menu.regression
	
		menu $this.menu.regression -tearoff 0
		set i 0
		set menuBreak {3 4 8}
		foreach r $reglist {
			$this.menu.regression add command -label $r -command "GeoReg $i"
			if {[lsearch $menuBreak $i] >= 0} {
				$this.menu.regression add separator
			}
			incr i
		}
		$this.menu.regression add separator
		$this.menu.regression add command -label $geoEasyMsg(menuRegLDist) \
			-command "GeoRegDist 0"
		$this.menu.regression add command -label $geoEasyMsg(menuRegPDist) \
			-command "GeoRegDist 1"
	}

	if {[lsearch -exact $geoModules "dtm"] != -1} {
		menu $this.menu.dtm -tearoff 0
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmCreate) \
			-command "CreateTinDia $this"
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmLoad) \
			-command "LoadTinDia $this"
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmAdd) \
			-command "LoadTinDia $this 1"
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmUnload) \
			-command "UnloadTin"
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmSave) \
			-command "SaveTin"
		$this.menu.dtm add separator
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmInterp) \
			-command "DtmInterpolateDialog"
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmContour) \
			-command "GeoContour $this"
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmVolume) \
			-command "GeoVolume $this"
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmVolumeDif) \
			-command "GeoVolumeDif"
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmVrml) \
			-command "CreateVrml"
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmKml) \
			-command "CreateKml"
		$this.menu.dtm add command -label $geoEasyMsg(menuDtmGrid) \
			-command "CreateGrid"
		$this.menu.dtm add command -label $geoEasyMsg(menuLandXML) \
			-command "LandXMLOut"
		$this.menu.dtm add command -label $geoEasyMsg(menuFileStat) \
			-command "DtmStat"
	}
	menu $this.menu.help -tearoff 0
	$this.menu.help add command -label $geoEasyMsg(help) \
		-command "GeoHelp" -accelerator "F1"

	$this configure -menu $this.menu
	set can $this.map.c

	# create toolbar
	set fr $this.toolbar
	radiobutton $fr.zoom_in -image zoom_in -indicatoron 0 -selectcolor gray \
		-variable toolbarMode($this) -value 1 -command "PolyInit $can"
	radiobutton $fr.zoom_out -image zoom_out -indicatoron 0 -selectcolor gray \
		-variable toolbarMode($this) -value 2 -command "PolyInit $can"
	radiobutton $fr.pan -image pan -indicatoron 0 -selectcolor gray \
		-variable toolbarMode($this) -value 3 -command "PolyInit $can"
	radiobutton $fr.ruler -image ruler -indicatoron 0 -selectcolor gray \
		-variable toolbarMode($this) -value 4  -command "PolyInit $can"
	radiobutton $fr.area -image area -indicatoron 0 -selectcolor gray \
		-variable toolbarMode($this) -value 5  -command "PolyInit $can"
	radiobutton $fr.sp1 -image sp1 -indicatoron 0 -selectcolor gray \
		-variable toolbarMode($this) -value 7  -command "PolyInit $can"

	pack $fr.zoom_in $fr.zoom_out $fr.pan $fr.ruler $fr.area \
		$fr.sp1 -side left
	# toolbar for optional modules
	if {[lsearch -exact $geoModules "reg"] != -1} {
		radiobutton $fr.reg -image reg -indicatoron 0 -selectcolor gray \
			-variable toolbarMode($this) -value 20 -command "PolyInit $can"
		pack $fr.reg -side left
	}	
	if {[lsearch -exact $geoModules "dtm"] != -1} {
		radiobutton $fr.zdtm -image zdtm -indicatoron 0 -selectcolor gray \
			-variable toolbarMode($this) -value 40  \
			-command "PolyInit $can"
		radiobutton $fr.break -image breakline -indicatoron 0 \
			-selectcolor gray -variable toolbarMode($this) -value 41  \
			-command "DtmPolyInit $can"
		radiobutton $fr.hole -image hole -indicatoron 0 -selectcolor gray \
			-variable toolbarMode($this) -value 42  \
			-command "PolyInit $can"
		radiobutton $fr.xchgtri -image xchgtri -indicatoron 0 \
			-selectcolor gray -variable toolbarMode($this) -value 43  \
			-command "PolyInit $can"
		pack $fr.zdtm $fr.break $fr.hole $fr.xchgtri -side left
		DtmMenuState	;# enable/disable menu and toolbar
	}	

# create map releted widgets
	set w $this.map
	scrollbar $w.vscroll -relief sunken -command "$can yview"
	scrollbar $w.hscroll -relief sunken -command "$can xview" \
		-orient horizontal
	canvas $can -relief sunken -xscrollcommand "$w.hscroll set" \
		-yscrollcommand "$w.vscroll set" -borderwidth 3 \
		-xscrollincrement 1 -yscrollincrement 1 \
		-width $geoWindowWidth($this) -height $geoWindowHeight($this) \
		-cursor crosshair
	pack $w.hscroll -side bottom -fill x
	pack $w.vscroll -side right -fill y
	pack $can -side top -fill both -expand yes

	bind $can <1> "ToolbarHandler $this %x %y"
	bind $can <2> "$can scan mark %x %y"
	bind $can <B2-Motion> "$can scan dragto %x %y"
	bind $can <Key-F2> "GeoDraw $this"
	bind $can <Key-F3> "GeoZoomAll $can"
	bind $can <Key-F4> "AlterObs $this; GeoDraw $this"
	bind $can <Key-F5> "AlterDet $this; GeoDraw $this"
	bind $can <Key-F6> "AlterUsed $this; GeoDraw $this"
	bind $can <Key-F7> "AlterPn $this; GeoDraw $this"
	bind $can <Configure> "GeoCanvasResize %W %w %h"
	bind $can <Motion> "GeoCoords %W %x %y"
	bind $can <3> "GeoPopup %W %x %y %X %Y"
	bind $can <MouseWheel> "GeoWheelZoom $this %D %x %y"
#	bind $this <Key-Escape> "GeoWindowExit $this"
	bind $this <Alt-KeyPress-F4> "GeoWindowExit $this"
	bind $this <Key-F2> "GeoDraw $this"	;# for refresh
	bind $this <Control-Key-F> "GeoGraphFind $this"

#	Tooltips
	bind $fr.zoom_in <Enter> "TooltipHandler $this toolZoomin"
	bind $fr.zoom_in <Leave> "TooltipHandler $this"
	bind $fr.zoom_out <Enter> "TooltipHandler $this toolZoomout"
	bind $fr.zoom_out <Leave> "TooltipHandler $this"
	bind $fr.pan <Enter> "TooltipHandler $this toolPan"
	bind $fr.pan <Leave> "TooltipHandler $this"
	bind $fr.ruler <Enter> "TooltipHandler $this toolRuler"
	bind $fr.ruler <Leave> "TooltipHandler $this"
	bind $fr.area <Enter> "TooltipHandler $this toolArea"
	bind $fr.area <Leave> "TooltipHandler $this"
	bind $fr.sp1 <Enter> "TooltipHandler $this toolSp"
	bind $fr.sp1 <Leave> "TooltipHandler $this"

	if {[lsearch -exact $geoModules "reg"] != -1} {
		bind $fr.reg <Enter> "TooltipHandler $this toolReg"
		bind $fr.reg <Leave> "TooltipHandler $this"
	}
	if {[lsearch -exact $geoModules "dtm"] != -1} {
		bind $fr.zdtm <Enter> "TooltipHandler $this toolZdtm"
		bind $fr.zdtm <Leave> "TooltipHandler $this"
		bind $fr.break <Enter> "TooltipHandler $this toolBreak"
		bind $fr.break <Leave> "TooltipHandler $this"
		bind $fr.hole <Enter> "TooltipHandler $this toolHole"
		bind $fr.hole <Leave> "TooltipHandler $this"
		bind $fr.xchgtri <Enter> "TooltipHandler $this toolXchgtri"
		bind $fr.xchgtri <Leave> "TooltipHandler $this"
	}
#	create status bar
	label $this.status.x -textvariable geoXAct($this) -relief sunken
	label $this.status.y -textvariable geoYAct($this) -relief sunken
	label $this.status.res -textvariable geoRes($this)
	pack $this.status.x $this.status.y -side left
	pack $this.status.res -side right -expand 1

	GeoDraw $this			;# display loaded geo data sets
	GeoZoomAll $can

	focus $can
}

#
#	Turn on/off observation lines
#	@param w window
proc AlterObs {w} {
	global observations
	set observations($w) [expr ! {$observations($w)}]
}

#
#	Turn on/off detail points
#	@param w window
proc AlterDet {w} {
	global details
	set details($w) [expr ! {$details($w)}]
}

#
#	Turn on/off unused points
#	@param w window
proc AlterUsed {w} {
	global usedPointsOnly
	global details
	set usedPointsOnly($w) [expr ! {$usedPointsOnly($w)}]
}

#
#	Turn on/off point numbers
#	@param w window
proc AlterPn {w} {
	global pointNumbers
	set pointNumbers($w) [expr ! {$pointNumbers($w)}]
}

#
#	Close a graphic window
#	@param this window
proc GeoWindowExit {this} {
	global geoWindowScale
	global geoWindowWidth
	global geoWindowHeight
	global geoRes

	catch {unset geoWindowScale($this)}
	catch {unset geoWindowScale($this)}
	catch {unset geoWindowWidth($this)}
	catch {unset geoRes($this)}
	catch {unset toolbarMode($this)}
	catch {destroy $this}
}

#
#	Draw the points etc in graphic window
#	@param this toplevel widget of graphic window
proc GeoDraw {this} {
	global geoEasyMsg
	global dxfview
	global tcl_platform
	global geoModules
	global geoLoaded
	global tinLoaded
	global newtin_poly newtin_hole
	global contourInterval contourDxf dxfFile contourLayer contour3Dface
	global observations details pointNumbers usedPointsOnly codedLines
	global regLineStart regLineCont regLineEnd regLine
	global geoLineColor geoFinalColor geoApprColor geoStationColor geoOrientationColor
	global geoLineColor geoObsColor geoFinalColor geoApprColor geoStationColor \
		geoOrientationColor geoNostationColor

	set can $this.map.c
	$can delete all					;# remove everything from canvas
#	$can delete obs pnum pcirc		;# remove all but DTM
	# tins
	if {[lsearch -exact $geoModules "dtm"] != -1} {
		if {$tinLoaded != "" || [llength $newtin_poly] || \
				[llength $newtin_hole]} {
#			if [llength [$can find withtag tin]] == 0
				# no tin drawn yet
				ShowTin $this
				if {$contourInterval > 0} {
					TContour $this
				}
		} else {
			$can delete all					;# remove everything from canvas
		}
	}

	# points & observations
	if {$details($this) == 1} {
		set p_list [GetAll] ;# display detail points too
	} else {
		set p_list [GetBase] ;# display base points only
	}
	if {$usedPointsOnly($this) == 1} {
		set p_list [UsedPointsOnly $p_list]
	}
	# connect points as observations & using codes (linework)
	if {[string length $regLineStart]} {
		set multiLine 1
	} else {
		set lastCode ""
		set multiLine 0
	}
	if {$observations($this) == 1 || $codedLines($this) == 1} {
		foreach geo $geoLoaded {
			global ${geo}_geo
			set st_coo ""
			set indexes [lsort -integer [array names ${geo}_geo]]
			foreach ind $indexes {
				set rec [set ${geo}_geo($ind)]
				set st [GetVal 2 $rec]
				if {$st != ""} {		;# station found
					set st_coo [GetCoord $st {37 38}]
					if {$st_coo == ""} {
						set st_coo [GetCoord $st {137 138}]
					}
					if {$st_coo != ""} {
						set st_x [GeoX $this [GetVal {38 138} $st_coo]]
						set st_y [GeoY $this [GetVal {37 137} $st_coo]]
					}
					if {! $multiLine} {
						set lastCode ""	;# new line to start
						set lastp_x ""
						set lastp_y ""
					}
				} else {
					if {$st_coo != ""} {
						set p [GetVal {5 62} $rec]
						if {[lsearch -exact $p_list $p] == -1} {
							# point not drawn
							continue
						}
						set p_coo [GetCoord $p {37 38}]
						if {$p_coo == ""} {
							set p_coo [GetCoord $p {137 138}]
						}
						if {$p_coo != ""} {
							set p_x [GeoX $this [GetVal {38 138} $p_coo]]
							set p_y [GeoY $this [GetVal {37 137} $p_coo]]
							if {$observations($this) == 1} {
								$can create line \
									$st_x $st_y $p_x $p_y \
									-tags obs -arrow last -fill $geoObsColor \
									-arrowshape "10 13 3"
							}
							# linework
							if {$codedLines($this) == 1} {
								set code [string trim [string tolower [GetVal 4 $rec]]]
								if {[string length [string trim $code]] == 0} { continue }
								if {$multiLine} {
									if {[regexp $regLineStart $code]} {
										set pat "(.*)$regLineStart"
										regsub -- $pat $code \\1 codeName
										if {[string length $codeName]} {
											set lastp_x($codeName) $p_x
											set lastp_y($codeName) $p_y
										}
									} elseif {[regexp $regLineCont $code]} {
										set pat "(.*)$regLineCont"
										regsub -- $pat $code \\1 codeName
										if {[string length $codeName]} {
											if {[info exists lastp_x($codeName)] && [info exists lastp_y($codeName)]} {
												$can create line \
													$lastp_x($codeName) $lastp_y($codeName) $p_x $p_y \
													-tags obs -fill $geoLineColor
											}
											set lastp_x($codeName) $p_x
											set lastp_y($codeName) $p_y
										}
									} elseif {[regexp $regLineEnd $code]} {
										set pat "(.*)$regLineEnd"
										regsub -- $pat $code \\1 codeName
										if {[string length $codeName]} {
											if {[info exists lastp_x($codeName)] && [info exists lastp_y($codeName)]} {
												$can create line \
													$lastp_x($codeName) $lastp_y($codeName) $p_x $p_y \
													-tags obs -fill $geoLineColor
												unset lastp_x($codeName)
												unset lastp_y($codeName)
											}
										}
									}
								} else {
									if {[string length $lastCode] && \
										[regexp $regLine $code] && $code == $lastCode} {
										$can create line \
											$lastp_x $lastp_y $p_x $p_y \
											-tags obs -fill $geoLineColor
									}
									set lastCode $code
									set lastp_x $p_x
									set lastp_y $p_y
								}
							}
						}
					}
				}
			}
		}
	}
	set dx 2
	foreach pn $p_list {
		set textcolor $geoFinalColor
		set xy [GetCoord $pn {38 37}]
		if {$xy == ""} {
			set xy [GetCoord $pn {138 137}]
			set textcolor $geoApprColor
		}
		if {$xy == ""} {
			continue
		}
		if {[set x [GetVal 38 $xy]] == ""} {
			set x [GetVal 138 $xy]
		}
		if {[set y [GetVal 37 $xy]] == ""} {
			set y [GetVal 137 $xy]
		}
		if {$x != "" && $y != ""} {
			set x [GeoX $this $x]
			set y [GeoY $this $y]
			if {$pointNumbers($this) == 1} {
				$can create text \
					$x [expr {$y - 4.0 * $dx}] -fill $textcolor \
						-text $pn -tags pnum
			}
			set fillcol $geoNostationColor
			# references to geo data set where this point is a station
			set ll [GetStation $pn]
			if {[llength $ll] > 0} {
				set fillcol $geoStationColor
				# is there orientation too? globals were set before
				foreach lll $ll {
					set fn [lindex $lll 0]
					set ref [lindex $lll 1]
					global ${fn}_geo
					if {[GetVal 101 [set ${fn}_geo($ref)]] != ""} {
						set fillcol $geoOrientationColor
						break
					}
				}
			}
			$can create oval \
				[expr {$x - $dx}] [expr {$y - $dx}] \
				[expr {$x + $dx}] [expr {$y + $dx}] \
				-fill $fillcol -tags "P${pn} pcirc"
		}
	}
	$can configure -scrollregion [$can bbox all]
}

#
#	Refresh all graphic windows
proc GeoDrawAll {} {
	for {set i 0} {$i < 10} {incr i} {
		if {[winfo exists .g$i] == 1} {
#			GeoDraw .g$i
			eval [bind .g$i <Key-F2>]
		}
	}
}

#
#	Zoom in/out or pan graphic window
#	@param this toplevel widget of graphic window
#	@param x x position of new window center
#	@param y y position of new window center
#	@param f scale factor change (if = 1 pan function)
#	@param flag 0/1 zoom & redraw / zoom only (optional, default 0)
#	@param flag1- 0/1 x & y screen/canvas co-ordinates (optional, default 0)
proc GeoZoom {this x y f {flag 0} {flag1 0}} {
	global geoWindowScale
	global geoWindowWidth
	global geoWindowHeight

	set can $this.map.c
	set ff [expr {$geoWindowScale($this) * $f}]	;# scale after zoom
	if {[llength [$can bbox all]] == 0 || $ff > 1e4 || $ff < 1e-4} {
		;# nothing on canvas or invalid scale
		Beep
		return
	}
	if {$flag1} {
		set cx [expr {$x * $f}]
		set cy [expr {$y * $f}]
	} else {
		set cx [expr {[$can canvasx $x] * $f}]	;# canvas coords of new center
		set cy [expr {[$can canvasy $y] * $f}]	;# after scale
	}
	# global scale
	set geoWindowScale($this) $ff
	if {$flag} {
		$can scale all 0 0 $f $f				;# rescale all elements
	} else {
		GeoDraw $this							;# redraw all elements
	}
	set box [$can bbox all]						;# new bounding box
	if {[llength $box] != 4} { return }
	$can configure -scrollregion $box
	set x_min [lindex $box 0]
	set x_max [lindex $box 2]
	set y_min [lindex $box 1]
	set y_max [lindex $box 3]
	set x_full_size [expr {$x_max - $x_min}]
	set y_full_size [expr {$y_max - $y_min}]
	if {$x_full_size < 0.01 || $y_full_size < 0.01} {
		Beep									;# 
		return
	}
	set x_fraction \
		[expr {($cx - $x_min - $geoWindowWidth($this) / 2.0) / $x_full_size}]
	set y_fraction \
		[expr {($cy - $y_min - $geoWindowHeight($this) / 2.0) / $y_full_size}]

	$can xview moveto $x_fraction
	$can yview moveto $y_fraction
}

#
#	Zoom in/out using mouse wheel
#	@param this toplevel widget of graphic window
#	@param s direction of zoom +120/-120
#	@param x mouse position
#	@param y
proc GeoWheelZoom {this s x y} {
	global geoWindowScale
	global geoWindowWidth
	global geoWindowHeight

	set can $this.map.c
	set xv [lindex [$can xview] 0]
	set yv [lindex [$can yview] 0]
	if {$s > 0} {
		set f 1.2
		set xv [min [expr {$xv + 0.1}] 1]
		set yv [min [expr {$yv + 0.1}] 1]
	} else {
		set f 0.8
		set xv [max [expr {$xv - 0.1}] 0]
		set yv [max [expr {$yv - 0.1}] 0]
	}
	if {[llength [$can bbox all]] == 0 || \
		[expr {$geoWindowScale($this) * $f}] > 1e4 || \
		[expr {$geoWindowScale($this) * $f}] < 1e-4} {
		# nothing on canvas or invalid scale
		Beep
		return
	}
	set geoWindowScale($this) [expr {$geoWindowScale($this) * $f}]	;# global scale
	GeoDraw $this								;# redraw all elements
	set box [$can bbox all]						;# new bounding box
	$can configure -scrollregion $box
	$can xview moveto $xv
	$can yview moveto $yv
}

#
#	Zoom to see all points
#	@param w name of actual widget (canvas)
#	@param flag 0/1 zoom & redraw/zoom only (optional, default 0)
proc GeoZoomAll {w {flag 0}} {
	global geoWindowWidth
	global geoWindowHeight
	global geoLoaded tinLoaded

	set this [winfo toplevel $w]
	set box [$w bbox all]
	if {[llength $box] != 4} { 
		if {[llength $geoLoaded] == 0 && [string length $tinLoaded] == 0} {
			return
		}
		# new geo dataset or tin loaded after opening window
		GeoDraw $this
		set box [$w bbox all]
		if {[llength $box] != 4} { return }	;# nothing to display
	}
	set dx [expr {[lindex $box 2] - [lindex $box 0] + 2.0}]
	set dy [expr {[lindex $box 3] - [lindex $box 1] + 2.0}]

	set fx 1
	if {[expr {abs($dx)}] > 1e-2} {
		set fx [expr {$geoWindowWidth($this) / $dx}]
	}
	set fy 1
	if {[expr {abs($dy)}] > 1e-2} {
		set fy [expr {$geoWindowHeight($this) / $dy}]
	}
	if {$fx < $fy} {
		set f $fx
	} else {
		set f $fy
	}
	GeoZoom $this [expr {$geoWindowWidth($this) / 2.0}] \
		[expr {$geoWindowHeight($this) / 2.0}] $f $flag
}

#
#	Create zoom window
#	@param this name of actual widget (toplevel)
#	@param x screen position on canvas
#	@param y
proc GeoWinStart {this x y} {
	global sx sy

	set sx $x
	set sy $y
	set can $this.map.c
	catch "$can delete win"
	set cx [$can canvasx $x]
	set cy [$can canvasy $y]
	$can create rectangle $cx $cy $cx $cy -outline red -tags win
}

#
#	Change size of zoom window
#	@param this name of actual widget (toplevel)
#	@param x position on canvas
#	@param y
proc GeoWinMove {this x y} {
	global sx sy

	if {[info exists sx] == 0} { return }
	set can $this.map.c
#	set co [$can coords win]
	set cx [$can canvasx $x]
	set cy [$can canvasy $y]
	$can coords win [$can canvasx $sx] [$can canvasy $sy] $cx $cy
}

#
#	Get minimal value from parameters
#	minimum two arguments must be given
#	@param a1 first argument
#	@param args list of other arguments
#	@return minimal value
proc min {a1 args} {

	set m $a1
	foreach a $args {
		if {$a < $m} { set m $a }
	}
	return $m
}

#
#	Get maximal value from parameters
#	minimum two arguments must be given
#	@param a1 first argument
#	@param args list of other arguments
#	@return maximal value
proc max {a1 args} {

	set m $a1
	foreach a $args {
		if {$a > $m} { set m $a }
	}
	return $m
}

#
#	Store position as end of a zoom window
#		@param this name of actual widget (toplevel)
#		@param x position on canvas
#		@param y
#		@param flag 0/1 Geo/Dat (optional, default 0)
proc GeoWinEnd {this x y {flag 0}} {
	global sx sy
	global geoWindowWidth
	global geoWindowHeight

	set can $this.map.c
	set id [$can find withtag win]
	if {[llength $id] != 1} {return}
	set co [$can coords $id]
	set x1 [lindex $co 0]		;# window corners
	set y1 [lindex $co 1]
	set x2 [lindex $co 2]
	set y2 [lindex $co 3]
	set dx [expr {abs($x1 - $x2)}]
	set dy [expr {abs($y1 - $y2)}]
	$can delete $id
	if {$dx < 5 || $dy < 5} {
		GeoZoom $this $x $y 2.0 $flag
	} else {
	# zoom window ***
		GeoZoom $this [expr {($sx + $x) / 2.0}] [expr {($sy + $y) / 2.0}] \
			[min [expr {$geoWindowWidth($this) / double($dx)}] \
				[expr {$geoWindowHeight($this) / double($dy)}]] $flag
	}
	unset sx
	unset sy
}

#
#	Create rubber line
#	@param this name of actual widget (toplevel)
#	@param x screen position on canvas
#	@param y
proc GeoLineStart {this x y} {
	global sx sy

	set sx $x
	set sy $y
	set can $this.map.c
	catch "$can delete rubberline"
	set cx [$can canvasx $x]
	set cy [$can canvasy $y]
	$can create line $cx $cy $cx $cy -fill red -tags rubberline
}

#
#	Change end position of rubber line
#	@param this name of actual widget (toplevel)
#	@param x screen position on canvas
#	@param y
proc GeoLineMove {this x y} {
	global sx sy

	if {[info exists sx] == 0} { return }
	set can $this.map.c
	set cx [$can canvasx $x]
	set cy [$can canvasy $y]
	$can coords rubberline [$can canvasx $sx] [$can canvasy $sy] $cx $cy
}

#
#	Store position as section end and calculate heights
#	@param this name of actual widget (toplevel)
#	@param x screen position on canvas
#	@param y
proc GeoLineEnd {this x y} {
	global sx sy	;# start of rubber line
	global geoEasyMsg
	global geoRes
	global decimals
	global xInterp yInterp x1Interp y1Interp stepInterp dxfProfile

	set can $this.map.c
	set id [$can find withtag rubberline]	;# find rubber line
	if {[llength $id] != 1} {return}
	set co [$can coords $id]
	set x1 [lindex $co 0]		;# line coords
	set y1 [lindex $co 1]
	set x2 [lindex $co 2]
	set y2 [lindex $co 3]
	set dx [expr {$x2 - $x1}]
	set dy [expr {$y2 - $y1}]
	$can delete $id		;# remove rubber line
	if {[expr {abs($dx)}] < 2 && [expr {abs($dy)}] < 2} {
		# interpolate at a single point
		set xact [WorldX $this $x1]
		set yact [WorldY $this $y1]
		set z [InterpolateTin $this $x1 $y1]
		set geoRes($this) [format $geoEasyMsg(ZDtm) $z]
		GeoLog1 [format "$geoEasyMsg(interpolateTin) %.${decimals}f %.${decimals}f %.${decimals}f" $xact $yact $z]
	} else {
		set xInterp [format "%.${decimals}f" [WorldX $this $x1]]
		set yInterp [format "%.${decimals}f" [WorldY $this $y1]]
		set x1Interp [format "%.${decimals}f" [WorldX $this $x2]]
		set y1Interp [format "%.${decimals}f" [WorldY $this $y2]]
		DtmInterpolateDialog
	}
	unset sx
	unset sy
}

#
#	Store new canvas size after resizing
#	@param w name of actual widget (canvas)
#	@param width new size for canvas
#	@param height new size for canvas
proc GeoCanvasResize {w width height} {
	global geoWindowWidth
	global geoWindowHeight

	set this [winfo toplevel $w]
	set geoWindowWidth($this) $width
	set geoWindowHeight($this) $height
}

#
#	Transform world coordinates to canvas coordinates
#	@param this name of actual widget (canvas)
#	@param x coordinate in world system
#	@return x coordinate on canvas
proc GeoX {w x} {
	global geoWindowScale

	set this [winfo toplevel $w]
	return [expr {$x * $geoWindowScale($this)}]
}

#	Transform world coordinates to canvas coordinates
#	@param this name of actual widget (canvas)
#	@param y coordinate in world system
#	@return y coordinate on canvas
proc GeoY {w y} {
	global geoWindowScale

	set this [winfo toplevel $w]
	return [expr {-$y * $geoWindowScale($this)}]
}

#	
#	Calculate world x coordinate from canvas coord
#	@param w actual window/widget
#	@param cx canvas x coord
#	@return x coordinate in world system
proc WorldX {w cx} {
	global geoWindowScale

	set this [winfo toplevel $w]
	return [expr {$cx / double($geoWindowScale($this))}]
}

#	
#	Calculate world y coordinate from canvas coord
#	@param w actual window/widget
#	@param cy canvas x coord
#	@return y coordinate in world system
proc WorldY {w cy} {
	global geoWindowScale

	set this [winfo toplevel $w]
	return [expr {-$cy / double($geoWindowScale($this))}]
}
	
#
#	Transform mouse/canvas coordinates to world coordinates
#		global variables changed, coordinate display actualized
#	@param can name of actual widget (canvas)
#	@param x coordinate of mouse pointer
#	@param y coordinate of mouse pointer
#	@param c 1 if canvas coordinates are given, otherwise 0 (optional, default 0)
proc GeoCoords {can x y {c 0}} {
	global geoXAct geoYAct

	set this [winfo toplevel $can]
	if {$c} {
		set cx $x
		set cy $y
	} else {
		set cx [$can canvasx $x]
		set cy [$can canvasy $y]
	}
	set geoXAct($this) [format "%12.2f" [WorldX $this $cx]]
	set geoYAct($this) [format "%12.2f" [WorldY $this $cy]]
}

#
#	Display popup menu at mouse position
#	@param can name of actual widget (canvas)
#	@param x coordinate of mouse pointer
#	@param y coordinate of mouse pointer
#	@param rootx position of popup0
#	@param rooty
proc GeoPopup {can x y rootx rooty} {
	global geoEasyMsg
	global geoModules

#
#	option menu for graphic window
#
	set this [winfo toplevel $can]
	set cx [$can canvasx $x]
	set cy [$can canvasy $y]
	set id [$can find closest $cx $cy]
	if {$id == ""} {return}
	set tags [$can gettags $id]
	set pos [lsearch -glob $tags "P*"]
	if {$pos == -1} {
		if {[lsearch -exact $geoModules dtm] != -1} {
			# new dtm item?
			if {[lsearch -glob $tags Bnew] != -1} {
				# delete break line
				if {[tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(delbreakline) \
					warning 0 $geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
					$can delete $id
					DeleteBreak [WorldX $this $cx] [WorldY $this $cy]
				}
			} elseif {[lsearch -glob $tags Hnew] != -1} {
				# delete hole marker
				if {[tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(delhole) \
					warning 0 $geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
					$can delete $id
					DeleteHole [WorldX $this $cx] [WorldY $this $cy]
				}
			} elseif {[lsearch -glob $tags "N*"] != -1} {
				# delete dtm node
				if {[tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(deldtmpnt) \
					warning 0 $geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
					$can delete $id
					set pid [lindex $tags [lsearch -glob $tags "N*"]]
					set pid [string range $pid 1 end]
					DeletePnt $pid
					# refresh ???
					GeoDraw $this
				}
			} elseif {[lsearch -glob $tags "T*"] != -1} {
				# delete triangle
				if {[tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(deldtmtri) \
					warning 0 $geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
					$can delete $id
					set pid [lindex $tags [lsearch -glob $tags "T*"]]
					set pid [string range $pid 1 end]
					DeleteTri $pid
					# refresh ???
					GeoDraw $this

			}
			} else {Beep}
		} else {Beep}
		return
	}
	# get point name & coords for actual point
	set pn [string range [lindex $tags $pos] 1 end]
	set coords [GetCoord $pn {37 38}]
	set apprCoords [GetCoord $pn {137 138}]
	# get number of occupations
	set st [GetStation $pn]

	catch {destroy .optmenu}
	menu .optmenu -tearoff 0
	.optmenu add command -label $pn -command "GeoInfo $pn"
	.optmenu add separator
	if {[llength $coords] > 1} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.optmenu add command -label $geoEasyMsg(menuPopupBD) \
		-command "GeoBearingDistance $pn [winfo toplevel $can]" -state $mstat
	.optmenu add command -label $geoEasyMsg(menuPopupAngle) \
		-command "GeoAngle $pn [winfo toplevel $can]" -state $mstat
	if {[llength $coords] > 1 && [llength $st] > 0} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.optmenu add command -label $geoEasyMsg(menuPopupOri) \
		-command "GeoOri $pn [winfo toplevel $can] 8" -state $mstat
	if {([llength $coords] > 1 || [llength $apprCoords] > 1) && \
		 [llength $st] > 0} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.optmenu add command -label $geoEasyMsg(menuPopupAppOri) \
		-command "GeoOri $pn [winfo toplevel $can] 2" -state $mstat
	if {[llength [GetPol $pn]] > 0}  {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.optmenu add command -label $geoEasyMsg(menuPopupPol) \
		-command "GeoPol $pn [winfo toplevel $can]" -state $mstat
	if {[llength [GetExtDir $pn]] > 1} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.optmenu add command -label $geoEasyMsg(menuPopupSec) \
		-command "GeoSec $pn [winfo toplevel $can]" -state $mstat
	if {[llength [GeoResStation $pn]] > 0} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.optmenu add command -label $geoEasyMsg(menuPopupRes) \
		-command "GeoRes $pn [winfo toplevel $can]" -state $mstat
	if {[llength [GetDist $pn]] > 1} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.optmenu add command -label $geoEasyMsg(menuPopupArc) \
		-command "GeoArc $pn [winfo toplevel $can]" -state $mstat
	
	set sumRef [GetSumRef $pn]
	set hzCoo 0
	if {[GetCoord $pn {38 37}] != "" || [GetCoord $pn {138 137}] != ""} {
		set hzCoo 1
	}
	set elevCoo 0
	if {[GetCoord $pn {39}] != "" || [GetCoord $pn {139}] != ""} {
		set elevCoo 1
	}
	if {[lsearch -exact $geoModules adj] != -1} {
		if {$sumRef > 0 && $hzCoo && $elevCoo} {
			set mstat "normal"
		} else {
			set mstat "disabled"
		}
		.optmenu add command -label $geoEasyMsg(menuPopupAdj3D) \
			-command "GeoNet3D $pn" -state $mstat
		if {$sumRef > 0 && $hzCoo} {
			set mstat "normal"
		} else {
			set mstat "disabled"
		}
		.optmenu add command -label $geoEasyMsg(menuPopupAdj2D) \
			-command "GeoNet2D $pn" -state $mstat
		if {$sumRef > 0 && $elevCoo} {
			set mstat "normal"
		} else {
			set mstat "disabled"
		}
		.optmenu add command -label $geoEasyMsg(menuPopupAdj1D) \
			-command "GeoNet1D $pn" -state $mstat
	}
	if {[llength [GetEle $pn]] > 0} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.optmenu add command -label $geoEasyMsg(menuPopupEle) \
		-command "GeoEle $pn [winfo toplevel $can]" -state $mstat
	if {[llength $coords] > 1 && [llength $st] > 0} {
		set mstat "normal"
	} else {
		set mstat "disabled"
	}
	.optmenu add command -label $geoEasyMsg(menuPopupDetail) \
		-command "GeoDetailStation $pn" -state $mstat

	tk_popup .optmenu $rootx $rooty
}

#
#	Display tooltip for tool buttons, if ind empty string then erase status
#	@param w widget
#	@param ind message index
proc TooltipHandler {w {ind ""}} {
	global geoRes
	global geoEasyMsg

	if {$ind == ""} {
		set geoRes($w) ""
	} else {
		set geoRes($w) $geoEasyMsg($ind)
	}
}

#
#	Handle clicks on canvas
#	@param this widget
#	@param x position
#	@param y
proc ToolbarHandler {this x y} {
	global toolbarMode
	global tinLoaded

	set can $this.map.c
	bind $can <B1-Motion> ""
	bind $can <B1-ButtonRelease> ""
	switch -exact $toolbarMode($this) {
		1 {	;# zoom in
			GeoWinStart $this $x $y
			bind $can <B1-Motion> "GeoWinMove $this %x %y"
			bind $can <B1-ButtonRelease> "GeoWinEnd $this %x %y 0"
		}
		2 { ;# zoom out
			GeoZoom $this $x $y 0.5
		}
		3 { ;# pan
			bind $can <B1-Motion> "$can scan dragto %x %y"
			$can scan mark $x $y
		}
		# distance, area, traverse
		4 -
		5 -
		7 -
		20 {	;# regression
			PolyPoint $this $x $y
			bind $can <Double-Button-1> "PolyEnd $this"
		}
		40 {	;# interpolate on tin
			if {$tinLoaded != ""} {
				GeoLineStart $this $x $y
				bind $can <B1-Motion> "GeoLineMove $this %x %y"
				bind $can <B1-ButtonRelease> "GeoLineEnd $this %x %y"
#				set can $this.map.c
#				set cx [$can canvasx $x]
#				set cy [$can canvasy $y]
#				InterpolateTin $this $cx $cy
			} else {
				Beep
			}
		}
		41 {	;# input break line/border
			DtmPolyPoint $this $x $y
#			bind $can <Double-Button-1> "DtmPolyEnd $this"
		}
		42 {	;# input holes
			DtmHole $this $x $y
		}
		43 {	;# swap triangles
			if {$tinLoaded != ""} {
				SwapTriangles $this $x $y
			} else {
				Beep
			}
		}
	}
}

#
#	Restart traverse/distance/area measurment (stop by double click)
#	delete previous poly
#	@param can canvas
proc PolyInit {can} {
	global polyPoints

	$can delete poly
	set polyPoints ""
}

#
#	Mark traverse/area/dist points on map windows and start calculation if
#	endpoint is given
#		polyPoints list is built
#			iterms are lists {dataset row point_number}
#			dataset and row used only for traverse points
#	@param this handle to top level widget
#	@param x,y position
proc PolyPoint {this x y} {
	global polyPoints				;# store/collect traverse points
	global toolbarMode
	global geoEasyMsg

	set can $this.map.c
	set cx [$can canvasx $x]
	set cy [$can canvasy $y]
	set id [$can find closest $cx $cy]
	if {$id == ""} {
		Beep
		return
	}
	set itemtype [$can type $id]
	if {$itemtype == "text"} {
		set pn [$can itemcget $id -text]
	} elseif {$itemtype == "oval"} {
		set tags [$can gettags $id]
		set pos [lsearch -glob $tags "P*"]
		if {$pos == -1} {return}
		set pn [string range [lindex $tags $pos] 1 end]
	} else {
		Beep
		return
	}
	set n [llength $polyPoints]
	if {$n > 0} {		;# not the first point
		set prevPoint [lindex [lindex $polyPoints [expr {$n - 1}]] 2]
		if {$pn == $prevPoint} {
			# do not add the same point
			# check for end (for multiple occupied points!)
			if {[tk_dialog .msg $geoEasyMsg(info) $geoEasyMsg(endp) info 0 \
					$geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
				PolyEnd $this
				return
			} else {
				return
			}
		}
		set pxy [$can coords P$prevPoint]
		set xy [$can coords P$pn]
		$can create line [lindex $pxy 0] [lindex $pxy 1] \
			[lindex $xy 0] [lindex $xy 1] -tags poly
	} else {
		$this.map.c delete poly	;# first point remove prev poly
	}
	if {$toolbarMode($this) == 7} {		;# traverse point
		set stlist [GetStation $pn]		;# check multiply occupied stations
		if {[llength $stlist] > 1} {
			set ref [lindex [GeoListbox $stlist {0 1} \
				$geoEasyMsg(lbTitle3) 1] 0]
			if {$ref == ""} {
				Beep
				return
			}
		} elseif {[llength $stlist] == 1} {
			set ref [lindex $stlist 0]
		} else {
			set ref [list "" -2]	;# not occupied at all!
		}
	} else {
		set ref [list "" 0]
	}
	lappend ref $pn
	lappend polyPoints $ref
}

#
#	End of polyline input
#	@param this widget
proc PolyEnd {this} {
	global polyPoints
	global toolbarMode
	global geoRes
	global geoEasyMsg
	global autoRefresh

	set n [llength $polyPoints]
	if {$n < 2 || $toolbarMode($this) == 7 && $n < 3} {
		Beep
		return                  ;# at least 2 or 3 points must be
	}
	switch -exact $toolbarMode($this) {
		4 {		;# distance
			set geoRes($this) "$geoEasyMsg(sum) [CalcDistances $polyPoints]"
		}
		5 {		;# area
			# close polygon
			set pn0 [lindex [lindex $polyPoints 0] 2]
			set n_1 [expr {[llength $polyPoints] - 1}]
			set pnn [lindex [lindex $polyPoints $n_1] 2]
			if {$pn0 != $pnn} {
				set can $this.map.c
				set pxy [$can coords P$pn0]
				set xy [$can coords P$pnn]
				$can create line [lindex $pxy 0] [lindex $pxy 1] \
		            [lindex $xy 0] [lindex $xy 1] -tags poly
			}
			set geoRes($this) "$geoEasyMsg(sum1) [CalcArea $polyPoints]"
		}
		7 {		;# traverse
			set t [TravDia]
			if {[string length $t] == 0} { return }
			if {[expr {$t & 1}] == 1} {
				CalcTraverse $polyPoints
			}
			if {[expr {$t & 2}] == 2} {
				CalcTrigLine $polyPoints
			}
			if {$autoRefresh} {
				RefreshAll
			}
			set geoRes($this) ""
		}
		20 {	;# regression
			set plist ""
			foreach p $polyPoints {
				lappend plist [lindex $p 2]
			}
			GeoReg1	$plist
		}
	}
#	PolyInit $this.map.c
	set polyPoints ""
}

#
#	Look for a point number in graph window and pan to it
#	@param w widget
proc GeoGraphFind {w} {
	global geoEasyMsg
	global geoCodes
	global geoWindowWidth
	global geoWindowHeight

	set lookfor [GeoEntry "$geoCodes(5):" $geoEasyMsg(find)]
	if {[string length $lookfor] == 0} {
		Beep
		return
	}
	set can $w.map.c
	set id [$can find withtag "P${lookfor}"]
	if {[llength $id] != 1} {
		Beep
		return
	}
	set co [$can coords $id]
	set cx [lindex $co 0]		;# window corners
	set cy [lindex $co 1]
	if {[llength [$can bbox all]] == 0} {
		;# nothing on canvas
		Beep
		return
	}
	set box [$can bbox all]						;# bounding box
	set x_min [lindex $box 0]
	set x_max [lindex $box 2]
	set y_min [lindex $box 1]
	set y_max [lindex $box 3]
	set x_full_size [expr {$x_max - $x_min}]
	set y_full_size [expr {$y_max - $y_min}]
	set x_fraction \
		[expr {($cx - $x_min - $geoWindowWidth($w) / 2.0) / $x_full_size}]
	set y_fraction \
		[expr {($cy - $y_min - $geoWindowHeight($w) / 2.0) / $y_full_size}]

	$can xview moveto $x_fraction
	$can yview moveto $y_fraction
}
