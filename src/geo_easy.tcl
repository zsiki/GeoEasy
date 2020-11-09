#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

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
#	Main startup proc of GeoEasy
#		@param top name of top level window
#		@return none
proc GeoEasy {top} {
	global env argc argv
	global tcl_precision tcl_platform
	global auto_path
	global geoEasyMsg
	global geoLoaded geoLoadedDir
	global tinLoaded
	global PI PI2 RO R PISEC PI2SEC FOOT2M OL2M SEC2CC E
	global topw
	global logName
	global geoPrinterFont
	global lastDir
	global geoModules version
	global contourInterval
	global arcCp arcSp arcEp arcR arcP arcSave arcStep arcNum
	global home

#	set default geo_easy.msk parameters
	global projRed avgH stdAngle stdDist1 stdDist2 refr stdLevel
	global cooSep txtSep decimals multiSep autoRefresh geoLang geoCp browser rtfview
	global geoMaskColors
	global geoLineColor geoFinalColor geoApprColor geoStationColor \
		geoOrientationColor geoNostationColor
	global geoMasks geoMaskParams
	global cooMasks cooMaskParams
	global geoFormHeaders geoForms geoFormParams geoFormPat
	global cooFormHeaders cooForms cooFormParams cooFormPat
	global newtin_poly newtin_hole
	global geoMustHave geoTogether geoNotTogether
	global cooMustHave cooTogether cooNotTogether
	global fn
	global saveType comSaveType
	global geoLangs langCodes

	set version 313 ;# update for new release!
	set version_str "[join [split $version {}] .]"
	set geoEasyMsg(mainTitle) "GeoEasy $version_str"
	# check conditions for geo and coo data
	# each record must have point number
	set geoMustHave {2 5 62}
	# each sublist has a master code and other codes
	# beside master code one of the other codes must be present
	set geoTogether {{9 8 10 120}}
	# no observation and target height for station
	# no instrunment height for target point
	set geoNotTogether {{2 6} {2 7} {2 8} {2 9} {2 11} {5 3}}
	set cooMustHave {5}
	set cooTogether {{37 38} {38 37} {137 138} {138 137}}
	set cooNotTogether ""
	#
	# platform dependent fonts
	#
	entry .tmp
	set fn [.tmp cget -font]    ;# font for entries
	destroy .tmp

	# initialize globals
	set tcl_precision 17		;# use maximal precision
	set geoLoaded ""
	set geoLoadedDir ""
	set tinLoaded ""
	set newtin_poly ""
	set newtin_hole ""
	set contourInterval 0
	set arcCp ""
	set arcSP ""
	set arcR ""
	set arcP ""
	set arcSave 1
	set arcStep ""
	set arcNum ""
	set PI [expr {4 * atan(1)}]
	set PISEC [expr {180 * 60 * 60}]
	set PI2 [expr {2 * $PI}]
	set PI2SEC [expr {360 * 60 * 60}]
	set FOOT2M 0.3048			;# foot to m factor
	set OL2M 1.89648384			;# ol to m factor
	set RO [expr {180.0 * 60.0 * 60.0 / $PI}] ;# sec to cc multiplier
	set R 6380000.0	;# radii of Earth in meters
	set SEC2CC [expr {400.0 / 360.0 * 10000.0 / 3600.0}] ;# sec to cc multiplier
	set E [expr {exp(1.0)}]		;# e
	set geoPrinterFont "\"Courier New\" 10"
	set saveType ""
	set comSaveType ""
	# get home dir from name of executable
	set myName [file tail [info nameofexecutable]]
	if {[regexp "^GeoEasy(64)?(\.exe)?$" $myName]} {
		# Linux or Windows binary release
		set home [file dirname [info nameofexecutable]]
	} elseif {[regexp "^wish" $myName]} {
		# for debian package
		set home [file dirname [file normalize [info script]]]
	} elseif {$myName == ""} {
		# android
		set home [file dirname [file normalize [info script]]]
	} else {
		# for debugging
		set home .
	}
	set auto_path [linsert $auto_path 0 $home]
	set lastDir [pwd]
	# central european code page
#	catch {encoding system cp1250}
	DXFset    ;# set dxf params, msk may rewrite
	ProjSet   ;# set proj params
	TrSet     ;# set transformation params, msk may rewrite
	if {[catch {source [file join $home "geo_easy.msk"]} msg] == 1} {
		tk_dialog .msg "Error" \
			"Error in mask file:\n$msg\nDefault settings will be used" error 0 OK
		if {[catch {source [file join $home "default.msk"]} msg] == 1} {
			tk_dialog .msg "Error" \
				"Error in default mask file:\n$msg [info script] [info nameofexecutable]" error 0 OK
			exit
		}
	}
	# update maskRows in mask definitions
	foreach m [array names geoMasks] {
		set geoMasks($m) [lreplace $geoMasks($m) 1 1 $maskRows]
	}
	foreach m [array names cooMasks] {
		set cooMasks($m) [lreplace $cooMasks($m) 1 1 $maskRows]
	}
	set w ""
	# get the language of the operating system
	if {$tcl_platform(platform) != "unix"} {
		set ww ""
		catch {set ww [string toupper [registry get HKEY_LOCAL_MACHINE\\SYSTEM\\CONTROLSET001\\control\\nls\\language InstallLanguage]]}
		if {[lsearch -exact [array names langCodes] $ww] > -1} {
			set w $langCodes($ww)
		} else {
			set w eng
		}
	} else {
		catch {set w [string range [string tolower $env(LANG)] 0 2]}
	}
	if {! [info exists geoLang] || \
		[lsearch -exact [array names geoLangs] $geoLang] == -1} {
		set geoLang eng ;# default language
		foreach lang [array names geoLangs] {
			if {[lsearch $geoLangs($lang) [string range $w 0 1]] > -1} {
				set geoLang $lang
				break
			}
		}
	}
	if {! [info exists geoCp] || \
		[lsearch -exact {utf-8 cp1250 cp-1250 iso8859-2 utf8 iso-8859-2 iso88592} $geoCp] == -1} {
		# get codepage of operating system
		set p [string last "\." $w]
		incr p
		if {$p} {
			set geoCp [string range $w $p end]
		} else {
			if {$tcl_platform(platform) != "unix"} {
			#TODO what about other languages?
				if {$geoLang == "hu"} {
					set geoCp "cp-1250"
				} else {
					set geoCp "iso-8859-2"
				}
			} else {
				set geoCp utf-8
			}
		}
	}
	# get user's home directory for log file
	if {$tcl_platform(platform) != "unix"} {
		set uhome "$env(HOMEDRIVE)$env(HOMEPATH)"
	} else {
		set uhome $env(HOME)
	}
	set logName [file join $uhome geo_easy.log]
	# process command line switches
	if {[llength $argv] > 0} {
		# overwrite language if command line parameter given
		set l [getopt "-lang"]  
		if {$l == ""} {
			set l [getopt "--lang"]  
		}
		if {[string length $l]} {
			set l [string tolower $l]
			set i [lsearch -exact [array names geoLangs] $l]
			if {$i == -1} {
				set geoLang eng ;# default language
				foreach lang [array names geoLangs] {
					if {[lsearch $geoLangs($lang) [string range $l 0 1]] > -1} {
						set l $lang
						break
					}
				}
			}
			set geoLang $l
		}
		# overwrite log name if given
		set logName [getopt "--log" $logName]  
	}
	# parse help options
	set help [getopt "--help" "--nopar"]
	if {$help == 1} {
		puts $geoEasyMsg(mainTitle)
		puts ""
		if {$help == "authors"} {
			puts "Authors:"
			puts "zvezdochiot <zvezdochiot@github.com>"
			puts "Bence Takacs <takacsbence@github.com>"
			puts "Andres Herrera <AndresHerrera@github.com>"
			puts "Copyright (c) 2017-[clock format [clock seconds] -format "%Y"], Zoltan Siki <zsiki@github.com>."
		} elseif {$help == "modules"} {
			global ge_sources
			if {! [info exists ge_sources]} { source $home/sources.tcl }
			puts "Modules: [lsort $ge_sources]"
		} elseif {$help == "version"} {
			puts "Changes:"
			puts "See on GitHub"
		} else {
			puts "Usage: geoeasy \[options\] \[files\]"
			puts " options:"
			puts "  --help \[string\] - print help info and exit {authors, modules, version}"
			puts "  --lang \[string\] - switch to a different language {[lsort [array names geoLangs]]}, default=auto"
			puts "  --log \[string\] - select log {path/to/file.log | stdout | stderr}, default=$logName"
			puts "  --nogui - process command line files and exit"
			puts " files:"
			puts "  optional list of files of four types"
			puts "    geo_easy data files (.geo, .gsi, etc.) to load"
			puts "    geo_easy project file (.gpr) to load"
			puts "    tcl script files (.tcl) to execute/load"
			puts "    mask definition files (.msk) to load"
			puts " the order of the files in the command line is the order of processing"
		}
		exit 0
	}  

#	GeoEasy & ComEasy message file
	foreach name [list geo_easy com_easy] {
		set msgFile [file join $home i18n $name.$geoLang]
		if {[file isfile $msgFile] && [file readable $msgFile]} {
			if {[catch {source $msgFile} msg] == 1} {
				tk_dialog .msg "Error" "Error in message file:\n$msg" error 0 OK
				exit
			}
		} else {
			tk_dialog .msg "Error" \
				"Message file ($msgFile) not found" error 0 OK
			exit
		}
	}
#
#	regular expressions for forms
#
	global reg
	set reg(0) ".*"												;# any text
	set reg(1) "^-?\[0-9\]+$"									;# integer
	set reg(2) "^-?\[0-9\]+(\\.\[0-9\]*)?(\[eE\]\[+-\]?\[0-9\]*)?$"	;# float
	set reg(3) "^\[0-9\]\[0-9\]?\[0-9\]?(-\[0-9\]\[0-9\]?)?(-\[0-9\]\[0-9\]?(\.\[0-9\]*)?)?$"	;# DMS

	set geoModules [GeoModules 0xFFFF]	;# enable all modules

	global nogui
	set nogui 0		;# GUI enabled 
	if {[getopt "--nogui" "--nopar"] == 1} { set nogui 1 }	;# turn of gui
	# process command line file arguments
	if {[llength $argv] > 0} {
		foreach arg $argv {
			set name [string trim $arg]
			if {[string length $name]} {
				# skip switches
				if {[string match "-*" $name] || \
					[lsearch -exact [array names geoLangs] $name] >= 0} {
					continue
				}
				regsub -all {\\} $name "/" name
				regsub "^\{" $name "" name
				regsub "\}$" $name "" name
				switch -glob -- $name {
					*.geo {
						MenuLoad $top $name
					}
					*.gpr { GeoProjLoad $top $name }
					*.msk -
					*.tcl {
						if {[catch {source $name} msg] != 0} {
							GeoLog "$geoEasyMsg(nostartup) $name"
							GeoLog1 $msg
						} else {
							GeoLog "$geoEasyMsg(startup) $name"
						}
					}
					default {
						MenuLoad $top $name
					}
				}
			}
		}
	}
	if {$nogui == 1} {
		exit 0
	}

#	toolbar images for graph window
	image create bitmap zoom_in -file [file join $home bitmaps bar zoom_in.xbm]
	image create bitmap zoom_out -file [file join $home bitmaps bar zoom_out.xbm]
	image create bitmap zoom_prev -file [file join $home bitmaps bar zoom_prev.xbm]
	image create bitmap pan -file [file join $home bitmaps bar pan.xbm]
	image create bitmap area -file [file join $home bitmaps bar area.xbm]
#	image create bitmap newp -file [file join $home bitmaps bar newp.xbm]
	image create bitmap ruler -file [file join $home bitmaps bar ruler.xbm]
	image create bitmap sp1 -file [file join $home bitmaps bar sp1.xbm]
	if {[lsearch -exact $geoModules "reg"] != -1} {
		image create bitmap reg -file [file join $home bitmaps bar reg.xbm]
	}
	if {[lsearch -exact $geoModules "dtm"] != -1} {
		image create bitmap zdtm -file [file join $home bitmaps bar zdtm.xbm]
		image create bitmap breakline -file [file join $home bitmaps bar breakline.xbm]
		image create bitmap hole -file [file join $home bitmaps bar hole.xbm]
		image create bitmap xchgtri -file [file join $home bitmaps bar xchgtri.xbm]
	}

#
#	start the application
#
	# open result window
	catch {GeoLogWindow}

	set topw ""
	if {$top != "."} {
		toplevel $top -class Dialog
		set topw $top
	}
	wm title $top $geoEasyMsg(mainTitle)
	wm geometry $top +10+10
	wm resizable $top 0 0
	wm protocol $top WM_DELETE_WINDOW "GeoExit $top"
	wm protocol $top WM_SAVE_YOURSELF "GeoExit $top"
#
#	set up menu
#
	menu $topw.menu -relief raised -tearoff 0

	$topw.menu add cascade -label $geoEasyMsg(menuFile) \
		-menu $topw.menu.file
	$topw.menu add cascade -label $geoEasyMsg(menuEdit) \
		-menu $topw.menu.edit
	$topw.menu add cascade -label $geoEasyMsg(menuGraCal) \
		-menu $topw.menu.calculate
	$topw.menu add cascade -label $geoEasyMsg(menuGraph) \
		-menu $topw.menu.graph
	$topw.menu add cascade -label $geoEasyMsg(help) \
		-menu $topw.menu.help
#
#	file menu
#
	menu $topw.menu.file -tearoff 0
	$topw.menu.file add command -label $geoEasyMsg(menuFileNew) \
		-command "MenuNew $top" -accelerator "Ctrl-N"
	$topw.menu.file add command -label $geoEasyMsg(menuFileLoad) \
		-command "MenuLoad $top" -accelerator "Ctrl-O"
	$topw.menu.file add cascade -label $geoEasyMsg(menuFileUnload) \
		-menu $topw.menu.file.unload
	$topw.menu.file add cascade -label $geoEasyMsg(menuFileSave) \
		-menu $topw.menu.file.save
	$topw.menu.file add command -label $geoEasyMsg(menuFileSaveAll) \
		-command "GeoSaveAll" -accelerator "Ctrl-S"
	$topw.menu.file add cascade -label $geoEasyMsg(menuFileSaveAs) \
		-menu $topw.menu.file.saveas
	$topw.menu.file add command -label $geoEasyMsg(menuFileJoin) \
		-command "GeoJoin"
	if {[lsearch -exact $geoModules "adj"] != -1} {
		$topw.menu.file add command -label $geoEasyMsg(menuFileExport) \
			-command "GamaExport" -accelerator "Ctrl-G"
	}
	$topw.menu.file add separator
	$topw.menu.file add command -label $geoEasyMsg(menuProjLoad) \
		-command "GeoProjLoad $top"
	$topw.menu.file add command -label $geoEasyMsg(menuProjSave) \
		-command "GeoProjSave"
	$topw.menu.file add command -label $geoEasyMsg(menuProjClose) \
		-command "GeoProjClose"
	if {[lsearch -exact $geoModules "com"] != -1} {
		$topw.menu.file add separator
		$topw.menu.file add command -label $geoEasyMsg(menuComEasy) \
			-command "ComEasy .com" -accelerator "F12"
	}
	$topw.menu.file add separator
	$topw.menu.file add command -label $geoEasyMsg(menuFileStat) \
		-command "GeoStat"
	$topw.menu.file add separator
	$topw.menu.file add command -label $geoEasyMsg(menuFileCParam) \
		-command "GeoCParam"
    if {[lsearch -exact $geoModules "adj"] != -1} {
		$topw.menu.file add command -label $geoEasyMsg(menuFileGamaParam) \
			-command "GamaParams"
	}
	$topw.menu.file add command -label $geoEasyMsg(menuFileColor) \
		-command "GeoColor"
	$topw.menu.file add command -label $geoEasyMsg(menuFileOParam) \
		-command "GeoOParam"
	$topw.menu.file add command -label $geoEasyMsg(menuFileSaveP) \
		-command "GeoSaveParams"
	$topw.menu.file add separator
	$topw.menu.file add command -label $geoEasyMsg(menuFileExit) \
		-command "GeoExit $top" -accelerator "Alt-F4"
	
	menu $topw.menu.file.unload -tearoff 0 \
		-postcommand {MenuFill $topw.menu.file.unload $geoLoaded MenuUnload}
	menu $topw.menu.file.save -tearoff 0 \
		-postcommand {MenuFill $topw.menu.file.save $geoLoaded MenuSave}
	menu $topw.menu.file.saveas -tearoff 0 \
		-postcommand {MenuFill $topw.menu.file.saveas $geoLoaded MenuSaveAs}
#
#	edit menu
#
	menu $topw.menu.edit -tearoff 0
	$topw.menu.edit add cascade -label $geoEasyMsg(menuEditGeo) \
		-menu $topw.menu.edit.geo
	$topw.menu.edit add cascade -label $geoEasyMsg(menuEditCoo) \
		-menu $topw.menu.edit.coo
	$topw.menu.edit add cascade -label $geoEasyMsg(menuEditPar) \
		-menu $topw.menu.edit.par
	$topw.menu.edit add separator
	$topw.menu.edit add command -label $geoEasyMsg(menuEditMask) \
		-command "LoadMask"

	menu $topw.menu.edit.geo -tearoff 0 \
		-postcommand {MenuFill $topw.menu.edit.geo $geoLoaded EditGeo}
	menu $topw.menu.edit.coo -tearoff 0 \
		-postcommand {MenuFill $topw.menu.edit.coo $geoLoaded EditCoo}
	menu $topw.menu.edit.par -tearoff 0 \
		-postcommand {MenuFill $topw.menu.edit.par $geoLoaded EditPar}
#
#	calculate menu
#
	menu $topw.menu.calculate -tearoff 0
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalOri) \
        -command "GeoFinalOri 13"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalAppOri) \
        -command "GeoFinalOri 7"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalDelOri) \
        -command "GeoDelOri"
    $topw.menu.calculate add separator
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalTra) \
        -command "GeoTraverse 0"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalTraNode) \
        -command "GeoTraverseNode 0"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalTrig) \
        -command "GeoTraverse 1"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalTrigNode) \
        -command "GeoTraverseNode 1"
    $topw.menu.calculate add separator
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalLine) \
        -command "GeoLineLine"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalPntLine) \
        -command "GeoPointOnLine"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalLength) \
        -command "GeoCalcArea 0"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalArea) \
        -command "GeoCalcArea 1"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalArc) \
        -command "GeoSettingOutArc"
    $topw.menu.calculate add separator
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalPre) \
        -command "GeoApprCoo"
    $topw.menu.calculate add command -label $geoEasyMsg(menuRecalcPre) \
        -command "GeoRecalcAppr"
    if {[lsearch -exact $geoModules "adj"] != -1} {
        # adjustment with gnu gama
        $topw.menu.calculate add command -label $geoEasyMsg(menuCalAdj3D) \
             -command "GeoNet3D"
        $topw.menu.calculate add command -label $geoEasyMsg(menuCalAdj2D) \
             -command "GeoNet2D"
        $topw.menu.calculate add command -label $geoEasyMsg(menuCalAdj1D) \
             -command "GeoNet1D"
	}
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalTran) \
        -command "GeoTran"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalHTran) \
        -command "GeoHTran"
    $topw.menu.calculate add separator
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalDet) \
        -command "GeoDetail 0"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalDetAll) \
        -command "GeoDetail 1"
    $topw.menu.calculate add command -label $geoEasyMsg(menuCalFront) \
        -command "GeoFront"
    if {[lsearch -exact $geoModules "reg"] != -1} {
        $topw.menu.calculate add separator
        $topw.menu.calculate add cascade -label $geoEasyMsg(menuReg) \
            -menu $topw.menu.regression

        menu $topw.menu.regression -tearoff 0
        set i 0
		set menuBreak {2}
        foreach r $reglist {
            $topw.menu.regression add command -label $r -command "GeoReg $i"
			if {[lsearch $menuBreak $i] >= 0} {
				$topw.menu.regression add separator
			}
            incr i
        }
        $topw.menu.regression add separator
        $topw.menu.regression add command -label $geoEasyMsg(menuRegLDist) \
            -command "GeoRegDist 0"
        $topw.menu.regression add command -label $geoEasyMsg(menuRegPDist) \
            -command "GeoRegDist 1"
	}
#
#	windows menu
#
	menu $topw.menu.graph -tearoff 0
	$topw.menu.graph add command -label $geoEasyMsg(menuGraNew) \
		-command "GeoNewWindow" -accelerator "F11"
	$topw.menu.graph add command -label $geoEasyMsg(menuLogNew) \
		-command "GeoLogWindow"
	$topw.menu.graph add command -label $geoEasyMsg(menuConsoleNew) \
		-command "GeoConsoleWindow"
	$topw.menu.graph add separator
	$topw.menu.graph add cascade -label $geoEasyMsg(menuWin) \
		-menu $topw.menu.graph.win
	$topw.menu.graph add command -label $geoEasyMsg(menuRefreshAll) \
		-command "RefreshAll" -accelerator "Ctrl-F2"

	menu $topw.menu.graph.win -tearoff 0 \
		-postcommand {WinFill $topw.menu.graph.win}
#
#	help menu
#
	menu $topw.menu.help -tearoff 0
	$topw.menu.help add command -label $geoEasyMsg(help) \
		-command "GeoHelp" -accelerator "F1"
	$topw.menu.help add command -label $geoEasyMsg(menuHelpAbout) \
		-command "GeoAbout"

	if {$tcl_platform(platform) == "unix"} {
		bind all <Control-KeyPress-c> "GeoExit $top"
	} else {
		bind all <Alt-KeyPress-F4> "GeoExit $top"
	}
	bind all <Key-F1> "GeoHelp"
	bind all <Control-Key-F2> "RefreshAll"
	bind all <Control-Key-n> "MenuNew $top"
	bind all <Control-Key-o> "MenuLoad $top"
	bind all <Control-Key-s> "GeoSaveAll"
	bind all <Control-Key-g> "GamaExport"
	bind all <Key-F12> "ComEasy .com"
	bind all <Key-F11> "GeoNewWindow"
	bind Entry <Key-Return> {NextField %W}
	#
	# start rotating world animation
	#
	init_animate $topw

	$top configure -menu $topw.menu
	GeoLog $geoEasyMsg(start)

#	catch {raise $top .log}
#	catch {raise $top}
}

#
#	Check availability of GeoEasy modules
#		@param moduleinfo binary coded module info 1/2/4/8 - com/reg/dtm/adj
#		@return list of available module names
proc GeoModules {moduleinfo} {
	global home
	global geoEasyMsg
	global tcl_platform
	global gamaProg
	global triangleProg
	global cs2csProg
#
#	module info bits
#	1 com ComEasy
#	2 reg Regression
#	4 dtm DTM
#	8 adj Network adjustment
	set modules ""
	if {[expr {$moduleinfo & 1}]} { lappend modules com}
	if {[expr {$moduleinfo & 2}]} { lappend modules reg}
	if {[file pathtype $triangleProg] == "relative"} {
		# change relative path to absolute
		set triangleProg [file join $home $triangleProg]
	}
	if {[expr {$moduleinfo & 4}]} {
		if {$tcl_platform(platform) == "unix"} {
			if {[info exists triangleProg] && [file exists $triangleProg]} {
				lappend modules dtm
			} else {
				tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(dtmModule) \
					error 0 OK
			}
		} else {
			if {[info exists triangleProg] && \
				([file exists "${triangleProg}.exe"] || [file exists "${triangleProg}64.exe"])} {
				lappend modules dtm
				if {$tcl_platform(pointerSize) == 8 && \
					[file exists "${triangleProg}64.exe"]} {
					set triangleProg "${triangleProg}64"
				}
			} else {
				tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(dtmModule) \
					error 0 OK
			}
		}
	}
	if {[expr {$moduleinfo & 8}]} {
		# minimal gama-local version 1.12!!!
		if {[file pathtype $gamaProg] == "relative"} {
			# change relative path to absolute
			set gamaProg [file join $home $gamaProg]
		}
		if {$tcl_platform(platform) == "unix"} {
			if {[info exists gamaProg] && [file exists $gamaProg]} {
				lappend modules adj
			} else {
				tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(adjModule) \
					error 0 OK
			}
		} else {
			if {[info exists gamaProg] && \
				([file exists "${gamaProg}.exe"] || [file exists "${gamaProg}64.exe"])} {
				lappend modules adj
				if {$tcl_platform(pointerSize) == 8 && \
					[file exists "${gamaProg}64.exe"]} {
					set gamaProg "${gamaProg}64"
				}
			} else {
				tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(adjModule) \
					error 0 OK
			}
		}
	}
	# reprojection available?
	if {[file pathtype $cs2csProg] == "relative"} {
		set cs2csProg [file join $home $cs2csProg]
	}
	if {$tcl_platform(platform) == "unix"} {
		if {[info exists cs2csProg] && [file exists $cs2csProg]} {
			lappend modules crs
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(crsModule) \
				error 0 OK
		}
	} else {
		if {[info exists cs2csProg] && \
			([file exists "${cs2csProg}.exe"] || [file exists "${cs2csProg}64.exe"])} {
			lappend modules crs
			if {$tcl_platform(pointerSize) == 8 && \
				[file exists "${cs2csProg}64.exe"]} {
				set cs2csProg "${cs2csProg}64"
			}
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(crsModule) \
				error 0 OK
		}
	}
	return $modules
}

#
#	Recalculate all approximate coordinates, all loaded geo data sets may be changed
#	@param none
#	@return none
#
#	Delete all approximate coordinate fro mall opened data set
proc GeoRecalcAppr {} {
	global geoLoaded
	global geoEasyMsg

	if {[tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(delappr) \
		warning 0 OK $geoEasyMsg(cancel)] != 0} {
		return
	}
	foreach fn $geoLoaded {
		global ${fn}_coo
		CooDelAppr ${fn}_coo 0
	}
	GeoApprCoo
}

#
#	Fill a cascade menu with options
#	@param m handle to menu widget
#	@param o list of menu option texts
#	@param p command name to execute with selected option parameter
proc MenuFill {m o p} {

	catch "$m delete 0 last"					;# remove previous options
	foreach opt $o {
		$m add command -label $opt -command "$p $opt"
	}
}

#
#	Fill a cascade menu with the title of open windows
#	@param m handle to menu widget
#	@return none
proc WinFill {m} {

	catch "$m delete 0 last"					;# remove previous options
	set w [winfo children .]
	foreach win $w {
		if {![regexp "^\.__" $win] && ![regexp "menu\$" $win]} {
			if {[catch {set t [wm title $win]}] == 0} {
				$m add command -label $t -command "wm deiconify $win; raise $win"
			}
		}
	}
}

#	Create a new geo data set
#	Side effects:
#		geoLoaded changes and new global arrays are created
#	@param w handle to top level widget
proc MenuNew {w} {
	global saveTypes
	global geoEasyMsg
	global tcl_platform
	global geoLoaded geoLoadedDir geoChanged
	global lastDir
	global saveType

	set typ [list [lindex $saveTypes [lsearch -glob $saveTypes "*.geo*"]]]
	set fn [string trim [tk_getSaveFile -filetypes $typ -initialdir $lastDir \
		-typevariable saveType]]
	if {$fn == ""} { return }
    # some extra work to get extension for windows

    regsub "\\(.*\\)$" $saveType "" saveType
    set saveType [string trim $saveType]
    set typ [lindex [lindex $typ [lsearch -regexp $typ $saveType]] 1]
    if {[string match -nocase "*$typ" $fn] == 0} {
        set fn "$fn$typ"
    }
	if {[string length $fn] == 0 || [string match "after#*" $fn]} { return }
	set lastDir [file dirname $fn]
	set fn "[file rootname $fn].geo"
	if {$tcl_platform(platform) != "unix" && \
		([file exists $fn] || [file exists "[file rootname $fn].coo"] || \
		[file exists "[file rootname $fn].par"])} {
		if {[tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(overw) \
			warning 1 $geoEasyMsg(yes) $geoEasyMsg(no)] == 1} {
			return	;# do not overwrite existing file
		}
	}
	# validity check
	set f [GeoSetName $fn]
	if {[info exists geoLoaded]} {
		if {[lsearch -exact $geoLoaded $f] != -1} {
			tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(-2) \
				warning 0 OK
			return			;# geo data set already loaded
		}
	} else {
		set geoLoaded ""
		set geoLoadedDir ""
		unset geoChanged
	}

	lappend geoLoaded $f
	lappend geoLoadedDir $fn
	set geoChanged($f) 0
}

#
#	Load/convert a data file
#	Side effects:
#		geoLoaded changes and new global arrays are created by LoadGeo
#	@param w handle to top widget
#	@def data set name to load, optional, if not given a file selection dialog open
#	@return none
proc MenuLoad {w {def ""}} {
	global fileTypes
	global geoEasyMsg
	global tcl_platform
	global geoLoaded geoLoadedDir geoChanged
	global lastDir
	global gpCoo
	global autoRefresh
	global loadHeader	;# 0/1 header for faces written or not

	set loadHeader 0			;# no header written yet
	set obspn [GetAllObs]		;# get all observed point names for later checks
	set coopn [GetAllCoo]		;# get all observed point names for later checks
	if {[string length $def]} {
		set fns $def
	} else {
		set fns [string trim [tk_getOpenFile -filetypes $fileTypes \
			-initialdir $lastDir -multiple 1]]
	}
	foreach fn $fns {
		if {[string length $fn] && [string match "after#*" $fn] == 0} {
			set lastDir [file dirname $fn]
			set f [GeoSetName $fn]
			if {[info exists geoLoaded]} {
				if {[lsearch -exact $geoLoaded $f] != -1} {
					tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(-2) \
						warning 0 OK
					continue			;# geo data set already loaded
				}
			} else {
				set geoLoaded ""
				set geoLoadedDir ""
			}
			switch -glob [string tolower $fn] {
				*.job {
					set res [Geodimeter $fn]
					if {$res == 0} {	;# try to load are too
						set fn1 [file rootname $fn]
						append fn1 ".are"
						if {[file exists $fn1]} {
							set res [Geodimeter $fn1]
						}
					}
				}
				*.are {
					set res [Geodimeter $fn]
					# .are eseten nincs .job betoltes
				}
				*.gdt {
					set res [Geodat124 $fn]
				}
				*.scr -
				*.set {
					set res [Sokia $fn]
				}
				*.crd -
				*.sdr {
					set res [Sdr $fn]
				}
				*.gsi -
				*.gre -
				*.wld {
					set res [Leica $fn]
				}
				*.idx {
					set res [Idex $fn]
				}
				*.m5 {
					set res [TrimbleM5 $fn]
				}
				*.geo {
					set res [LoadGeo $fn]
				}

				*.mjk {
					set res [GeoProfi $fn]
					if {$res == 0} {
						set typ [list [lindex $fileTypes \
							[lsearch -glob $fileTypes "*.eov*"]]]
						set fnCoo [string trim [tk_getOpenFile -filetypes $typ \
							-initialdir $lastDir -initialfile $gpCoo]]
						if {[string length $fnCoo] && \
							[string match "after#*" $fnCoo] == 0} {
							set lastDir [file dirname $fnCoo]
							set res [GeoProfiCoo $fnCoo $fn]
						}
					}
				}

				*.gmj {
					set res [GeoCalc $fn]
				}
				
				*.eov -
				*.szt -
				*.her -
				*.hkr -
				*.hdr {
					set res [GeoProfiCoo $fn]
				}

				*.pnt {
					set res [TxtCoo $fn "pnt.txp"]
				}
				*.dat {
					set res [TxtCoo $fn "dat.txp"]
				}
				*.csv -
				*.txt {
					set res [TxtCoo $fn]
				}
				*.dmp {
					set res [TxtGeo $fn]
				}

				*.gts7 -
				*.700 {
					set res [TopCon $fn]
					if {$res == 0} {
						set fn1 [file rootname $fn]
						append fn1 ".yxz"
						if {[file exists $fn1]} {
							set res [TopConCoo $fn1]
						}
					}
				}

				*.210 {
					set res [TopCon210 $fn]
				}

				*.yxz {
					set res [TopConCoo $fn]
					if {$res == 0} {
						set fn1 [file rootname $fn]
						append fn1 ".700"
						if {[file exists $fn1]} {
							set res [TopCon $fn1]
						}
					}
				}

				*.nik {
					set res [Nikon $fn]
				}

				*.dxf {
					set res [GeoDXFin $fn]
				}
				*.asc -
				*.arx {
					set res [GeoGridIn $fn]
				}
				*.gjk {
					set res [GeoZseni $fn]
				}
				*.rw5 -
				*.raw {
					set res [SurvCe $fn]
				}
				*.n4c {
					set res [n4ce $fn]
				}
				default {
					tk_dialog .msg $geoEasyMsg(warning) \
						"$geoEasyMsg(filetype) $fn" warning 0 OK
					continue
				}
			}

			if {$res != 0} {
				UnloadGeo $f
				if {$res == -999} {
					# cancelled, no error
				} elseif {$res < 0} {
					tk_dialog .msg $geoEasyMsg(warning) \
					"$geoEasyMsg($res) $fn" warning 0 OK
				} else {
					tk_dialog .msg $geoEasyMsg(warning) \
						"$geoEasyMsg(-5) $res $fn" warning 0 OK
					
				}
				continue
			}
			lappend geoLoaded $f
			lappend geoLoadedDir $fn
			# data set not changed yet
			if {[regexp -nocase "\.geo$" $fn] || [regexp -nocase "\.coo$" $fn]} {
				set geoChanged($f) 0
			} else {
				set geoChanged($f) 1	;# imported data set should be saved
			}
			GeoLog "$fn $geoEasyMsg(load)"
	#
	#		collect repeated observed point numbers/names
	#
			global ${f}_ref ${f}_geo ${f}_coo
	#		set used ""
	#		foreach pn [array names ${f}_ref] {
	#			if {[lsearch -exact $obspn $pn] != -1} {
	#				lappend used $pn
	#			}
	#		}
	#		if {[llength $used] > 0} {
	#			GeoListbox [lsort $used] 0 $geoEasyMsg(double) 0
	#		}
	#
	#		collect repeated point numbers in coo lists
	#
			set used ""
			foreach pn [array names ${f}_coo] {
				if {[lsearch -exact $coopn $pn] != -1} {
					lappend used $pn
				}
			}
			if {[llength $used] > 0} {
				GeoListbox [lsort $used] 0 $geoEasyMsg(double) 0
			}
			if {[llength [array names ${f}_geo]] == 0} {
				# no observations at all
				tk_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(1)\n$fn" \
					warning 0 OK
			}
			if {[llength [array names ${f}_coo]] == 0} {	;# no coordinates at all
				tk_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(2)\n$fn" \
					warning 0 OK
			}
		}
	}
	if {$autoRefresh} {
		GeoDrawAll
	}
}

#
#	Ask for save than unload geo data set
#	@param fn name of geo data set
#	@return code 0/2 OK/Canceled
proc MenuUnload {fn} {
	global geoEasyMsg
	global geoChanged
	global autoRefresh

	if {[info exists geoChanged($fn)] && $geoChanged($fn) > 0} {
		set a [tk_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(saveit) $fn" \
				warning 0 $geoEasyMsg(yes) $geoEasyMsg(no) $geoEasyMsg(cancel)]
		switch -exact $a {
			0 {
				set res [SaveGeo $fn]
				if {$res == 0} {
					GeoLog "$fn $geoEasyMsg(save)"
				} else {
					tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg($res) \
						error 0 OK
				}
			}
			1 {
				GeoLog "$fn $geoEasyMsg(unload)"
			}
			2 {
				return 2
			}
		}
	} else {
		GeoLog "$fn $geoEasyMsg(unload)"
	}
	catch {unset geoChanged($fn)}
	UnloadGeo $fn
	if {$autoRefresh} {
		GeoDrawAll
	}
	return 0
}

#
#	Save geo data set
#	@param fn name of geo data set
#	@return none
proc MenuSave {fn} {
	global geoEasyMsg
	global geoChanged

	set res [SaveGeo $fn]
	if {$res == 0} {
		set geoChanged($fn) 0	;# not changed yet
		GeoLog "$fn $geoEasyMsg(save)"
	} else {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg($res) \
			error 0 OK
	}
}

#
#	Ask for new file name and save geo data set
#	@param fn original name of loaded geo data set
#	@return none
proc MenuSaveAs {fn} {
	global geoEasyMsg
	global saveTypes
	global lastDir
	global saveType

	set saved 0
	set nn $fn
	# set filter for point in coordinate list
#	GeoSaveFilter TBD
	while {! $saved} {
		set saved 1
		set nn [string trim [tk_getSaveFile -filetypes $saveTypes \
			-initialdir $lastDir -initialfile [file rootname [file tail $nn]] \
			-typevariable saveType]]
		# string match is used to avoid silly Windows 10 bug
		if {[string length $nn] == 0 || [string match "after#*" $nn]} {
			return
		}
		# some extra work to get extension for windows
		regsub "\\(.*\\)$" $saveType "" saveType
		set saveType [string trim $saveType]
		set typ [lindex [lindex $saveTypes [lsearch -regexp $saveTypes $saveType]] 1]
		if {[string match -nocase "*$typ" $nn] == 0} {
			set nn "$nn$typ"
		}
		set lastDir [file dirname $nn]
		set rn [file rootname $nn]
		switch -glob $nn {
			*.geo { set res [SaveGeo $fn $rn] }
			*.are { set res [SaveAre $fn $nn] }
			*.job { set res [SaveJob $fn $nn] }
			*.wld { set res [SaveGsi $fn $nn 8] }
			*.gsi { set res [SaveGsi $fn $nn 16] }
			*.scr { set res [SaveScr $fn $nn]}
			*.sdr { set res [SaveSdr $fn $nn]}
			*.210 { set res [Save210 $fn $nn]}
			*.nik { set res [SaveNikon $fn $nn]}
			*.csv { set res [SaveTxt $fn $nn]}
			*.itr { set res [SaveITR2 $fn $nn]}
			*.txt { set res [TrackmakerOut $fn $nn]}
			*.gpx { set res [GpxOut $fn $nn]}
			*.dmp { set res [TxtOut $fn $nn]}
			*.kml { set res [KmlOut $fn $nn]}
            *.sql { set res [SavePSql $fn $nn]}
			default {
				tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(saveext) \
					warning 0 OK
				set saved 0
			}
		}
	}
	if {$res == 0} {
		GeoLog "$fn $geoEasyMsg(saveas) $nn"
	} else {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg($res) \
			error 0 OK
	}
}

#
#	Load a saved project, open data sets and windows
#	@param top top level widget
#	@param pn project file (optional)
#	@return none
proc GeoProjLoad {top {pn ""}} {
	global lastDir
	global geoEasyMsg
	global projTypes
	global geoLoaded
	global geoWindowScale
	global observations details pointNumbers usedPointsOnly codedLines

	if {$pn == ""} {
		set pn [string trim [tk_getOpenFile -filetypes $projTypes \
			-initialdir $lastDir -defaultextension ".gpr"]]
		if {[string length $pn] == 0 || [string match "after#*" $pn]} { return }
		set lastDir [file dirname $pn]
	}
	# close/save loaded data sets
	GeoProjClose
	if {[catch {set f [open $pn "r"]}] != 0} {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(-1) error 0 OK
		return
	}
	set type 0
	set n 0
	set prjd [file dirname $pn]
	while {! [eof $f]} {
		set fn [string trim [gets $f]]
		incr n
		if {[string length $fn] == 0} {continue}
		if {[string compare $fn "\[data\]"] == 0} {
			set type 1
		} elseif {[string compare $fn "\[win\]"] == 0} {
			set type 2
		} elseif {[string compare $fn "\[dtm\]"] == 0} {
			set type 3
		} elseif {$type == 1} {
			set prn [file join $prjd $fn]
			set prn1 [file join $prjd [file tail $fn]]
			if {[file exists $prn]} {
				MenuLoad $top $prn	;# try project relative
			} elseif {[file exists $prn1]} {
				MenuLoad $top $prn1	;# try from project dir
			} else {
				MenuLoad $top $fn	;# try absolute path
			}
		} elseif {$type == 2} {
			set par [split $fn]
			set w [lindex $par 0]
			switch -regexp $w {
				"_geo$" {
					set ds [split $w "_"]
					set ds [string range [lindex $ds 0] 1 end]
					GeoMask [lindex $par 1] $ds "_geo"
					wm geometry $w [lindex $par 3]
					GeoFillMask $ds [lindex $par 2] $w
				}
				"_coo$" {
					set ds [split $w "_"]
					set ds [string range [lindex $ds 0] 1 end]
					GeoMask [lindex $par 1] $ds "_coo"
					wm geometry $w [lindex $par 3]
					CooFillMask $ds [lindex $par 2] $w
				}
				"^\.g[0-9]$" {
					GeoNewWindow $w
					wm geometry $w [lindex $par 1]
					set observations($w) [lindex $par 2]
					set details($w) [lindex $par 3]
					set pointNumbers($w) [lindex $par 4]
					set usedPointsOnly($w) [lindex $par 5]
					set codedLines($w) [lindex $par 6]
					GeoZoom $w [expr {[lindex $par 8] * $geoWindowScale($w)}] \
						[expr {[lindex $par 9] * $geoWindowScale($w)}] \
						[expr {[lindex $par 7] / double($geoWindowScale($w))}] \
						0 1
				}
				"^\.log$" {
					GeoLogWindow
					wm geometry .log [lindex $par 1]
				}
			}
		} elseif {$type == 3} {
			set prn [file join $prjd $fn]
			set prn1 [file join $prjd [file tail $fn]]
			if {[file exists $prn]} {
				LoadTin $prn	;# try project relative
			} elseif {[file exists $prn1]} {
				LoadTin $top $prn1	;# try from project dir
			} else {
				LoadTin $fn	;# try absolute path
			}
		} else {
			tk_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(-10) $n" \
				warning 0 OK
			return
		}
	}
	# load params if exists
	set pn1 "[file rootname $pn].msk"
	if {[file exists $pn1]} {
		source $pn1
	}
	GeoLog "$pn $geoEasyMsg(pload)"
}

#
#	Save a project, open data sets and windows
#	File format:
#	[data]
#	file
#	...
#	[win]
#	.xxx_geo mask_name mask_pos geometry
#	.yyy_coo mask_name mask_pos geometry
#	.g0 geometry observations details pointnumbers usedpointsonly scale
#		center_x center_y
#	.log geometry
#	...
#	@param none
#	@return none
proc GeoProjSave {} {
	global geoLoadedDir
	global lastDir
	global geoEasyMsg
	global projTypes
	global maskName maskPos
	global observations details pointNumbers usedPointsOnly codedLines
	global geoWindowScale
	global tinLoaded tinPath

	set pn [string trim [tk_getSaveFile -filetypes $projTypes \
		-initialdir $lastDir -defaultextension ".gpr"]]
	if {[string length $pn] == 0 || [string match "after#*" $pn]} { return }
	set lastDir [file dirname $pn]
	if {[catch {set f [open $pn "w"]}] != 0} {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(-1) error 0 OK
		return
	}
	# save loaded data set names
	puts $f "\[data\]"
	set pd [file dirname $pn]
	foreach fn $geoLoadedDir {
		# make project relative path if possible
		if {[string match "${pd}*" $fn]} {
			set fn [string range $fn [expr {[string length $pd] + 1}] end]
		}
		puts $f $fn
	}
	puts $f "\[win\]"
	foreach w [winfo children .] {
		if {[regexp "_geo$" $w] || [regexp "_coo$" $w]} {
			# observations or co-ordinates
			# get only position, not the size
			set g [split [winfo geometry $w] "x+"]
			catch {puts $f "$w $maskName($w) $maskPos($w) +[lindex $g 2]+[lindex $g 3]"}
		} elseif {[regexp "^\.g\[0-9\]$" $w]} {
			# graphic window
			# calculate center point
			set sr  [lindex [$w.map.c configure -scrollregion] end]
			set hs [$w.map.hscroll get]
			set vs [$w.map.vscroll get]
			set cx [expr {([lindex $sr 0] + ([lindex $sr 2] - [lindex $sr 0]) \
				* ([lindex $hs 0] + [lindex $hs 1]) / 2.0) / \
				$geoWindowScale($w)}]
			set cy [expr {-([lindex $sr 1] + ([lindex $sr 3] - [lindex $sr 1]) \
				* ([lindex $vs 0] + [lindex $vs 1]) / 2.0) / \
				$geoWindowScale($w)}]
			puts $f "$w [winfo geometry $w] $observations($w) $details($w) $pointNumbers($w) $usedPointsOnly($w) $codedLines($w) $geoWindowScale($w) $cx $cy"
		} elseif {[regexp "^\.log$" $w]} {
			# log window
			# get only position, not the size
			set g [split [winfo geometry $w] "x+"]
			puts $f "$w  +[lindex $g 2]+[lindex $g 3]"
		}
	}
	if {[string length $tinLoaded]} {
		puts $f "\[dtm\]"
		puts $f "[file join $tinPath $tinLoaded]"
	}
	close $f
	# save settings
	set pn1 "[file rootname $pn].msk"
	GeoSaveParams $pn1
	GeoLog "$pn $geoEasyMsg(psave)"
}

#
#	Close project unload all data sets
#	@param none
#	@return none
proc GeoProjClose {} {
	global geoLoaded

	# close/save loaded data sets
	foreach ds $geoLoaded {
		MenuUnload $ds
	}
	# close graphic/console/calculation result windows
	foreach wi [winfo children .] {
		switch -glob -- $wi {
			.g[0-9] {GeoWindowExit $wi}
			.log -
			.console {GeoFormExit $wi}
		}
	}
}

#
#	Save all changed data sets
#	@param none
#	@return none
proc GeoSaveAll {} {
	global geoLoaded
	global geoEasyMsg
	global geoChanged

	# save loaded data sets
	foreach fn $geoLoaded {
		if {[info exists geoChanged($fn)] && $geoChanged($fn) > 0} {
			MenuSave $fn
		}
	}
}

#
#	Write log message with date and time to log file and to log window (if open)
#	@param msg log message to write
#	@return none
proc GeoLog {msg} {

	set datetime [clock format [clock seconds] -format "%Y.%m.%d %H:%M"]
	GeoLog1 "$datetime - $msg"
}

#
#	Write log message to log file and to log window if it is open
#	@param msg log message to write (optional), if not given an empty line is written to log
proc GeoLog1 {{msg ""}} {
	global logName
	global geoEasyMsg

	if {$logName == "stdout" || $logName == "stderr"} {
		set logFile $logName
	} elseif {[catch {set logFile [open $logName "a+"]} errmsg] == 1} {
		tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK	
	}
	if {[catch {puts $logFile $msg} errmsg] == 1} {
		tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK	
	}
	if {$logName != "stdout" && $logName != "stderr"} {
		if {[catch {close $logFile} errmsg] == 1} {
			tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK	
		}
	}
	if {[winfo exists .log]} {
		if {[catch {.log.w.t insert end "$msg\n"} errmsg] == 1} {
			tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK	
		}
		if {[catch {.log.w.t see end} errmsg] == 1} {	;# move to end of text
			tk_dialog .msg $geoEasyMsg(error) $errmsg error 0 OK	
		}
	}
}

#
#	send GeoEasy msg to tk_dialog or log depending on nogui global variable
proc GeoMsg {wnd title msg bitmap def args} {
	global nogui
	if {$nogui == 0} {	# tk_dialog if gui on
		set res [tk_dialog $wnd $title $msg $bitmap $def {*}$args]
	} else {
		GeoLog "$title: $msg"
		set res $def
	}
	return $res
}
#
#	Open log window if it is not opened before or rise it
#	@param none
#	@return none
proc GeoLogWindow {} {
	global geoEasyMsg

	if {[winfo exists .log]} {
		raise .log
	} else {
		GeoTextWindow .log $geoEasyMsg(logWin) "log"
	}
}

#
#	Open console window if it is not opened before or rise it
#	@param none
#	@return none
proc GeoConsoleWindow {} {
	global geoEasyMsg

	if {[winfo exists .console]} {
		raise .console
	} else {
		GeoTextWindow .console $geoEasyMsg(consoleWin) "console"
	}
}

#
#	Refresh all opened window having F2 binded
#	@param none
#	@return none
proc RefreshAll {} {
	global maskPos	;# used on parameter list for mask window refresh

	foreach w [winfo children .] {
		set f [bind $w <Key-F2>]
		if {[string length $f]} {
			eval $f	;# exec refresh for window
		}
	}
}

#
#	Exit from GeoEasy package & close all windows
#	@param this handle to main widget
proc GeoExit {this} {
	global geoLoaded
	global env
	global geoEasyMsg
	global logFile logName
#
#	free up memory
#
	foreach geo $geoLoaded {
		if {[MenuUnload $geo] == 2} { return }
		global ${geo}_geo ${geo}_coo ${geo}_ref
		catch {unset ${geo}_geo ${geo}_coo ${geo}_ref}
	}

	catch "GeoLog $geoEasyMsg(stop)"
	if {[info exists logFile]} { catch "close $logFile" }
#
#	destroy open windows
#
	catch "Animate $this.b off"
	foreach w [winfo children .] {
		catch {destroy $w}
	}
	if {[info exists env(GEO_DEBUG)] == 0 || $env(GEO_DEBUG) != 1} {
		catch {destroy .}
	}
}

#
#	Center window on screen
#	@param this handle to window
#	@return none
proc CenterWnd {this} {

#	tkwait visibility $this
	set g [split [winfo geometry $this] "x+"]
	set wthis [lindex $g 0]			;# width of dialog
	set hthis [lindex $g 1]			;# height of dialog
	set w [winfo screenwidth .]		;# width of screen
	set h [winfo screenheight .]	;# height of screen
	set x [expr {int(($w - $wthis) / 2.0)}]
	set y [expr {int(($h - $hthis) / 2.0)}]
	wm geometry $this "+${x}+${y}"
	update
}

#
#   Get commandline parameter with default value
#	@param name nameof argument
#	@param default default value if switch not given, special --nopar default value to mark switch without par
#   @return value for name or empty
proc getopt {name {default ""}} {
	global argv

	set pos [lsearch -regexp $argv ^$name]
	set var ""
	if {$pos >= 0} {
		if {$default != "--nopar"} { 	;# get value for switch
			set pos1 [expr {$pos + 1}]
			if {[llength $argv] > $pos1} {
				set var [lindex $argv $pos1]
				set argv [lreplace $argv $pos $pos1]
			} else {
				set argv [lreplace $argv $pos $pos]
			}
		} else {
			set var 1	;# mark presence of switch without arg value
		}
	} else {
		set var $default
	}
	return $var
}

#
#	start application
#
GeoEasy .
