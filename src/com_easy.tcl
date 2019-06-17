#//#
#	ComEasy serial communication extension to GeoEasy
#	It can communicate direct the instrument,
#	download/upload observations/coordinates
#//#
#
#	main entry to ComEasy
#	@param top name for toplevel window . if standalone
proc ComEasy {top} {
	global ctopw
	global comEasyMsg

	set w ""
	if {$top != "."} {
		if {[winfo exists $top]} {
			raise $top
			return
		}
		set w $top
		toplevel $w
	}
	set ctopw $w			;# save path to top level window
	wm protocol $top WM_DELETE_WINDOW "ComExit $top"
	wm protocol $top WM_SAVE_YOURSELF "ComExit $top"
	wm title $top $comEasyMsg(comTitle)
	menu $w.menu -relief raised -tearoff 0 ;#-type menubar

	frame $w.w
	pack $w.w -side bottom -fill both -expand 1

	$w.menu add cascade -label $comEasyMsg(mComFile) -menu $w.menu.file

	menu $w.menu.file -tearoff 0

	$w.menu.file add cascade -label $comEasyMsg(mComStored) \
		-menu $w.menu.file.stored
	$w.menu.file add command -label $comEasyMsg(mComPars) \
		-command "ComParsDlg"
	$w.menu.file add separator
#	$w.menu.file add cascade -label $comEasyMsg(mComDir) \
#		-menu $w.menu.file.dir
	$w.menu.file add command -label $comEasyMsg(mComDownload) \
		-command "ComDownload"
	$w.menu.file add command -label $comEasyMsg(mComUpload) \
		-command "ComUpload"
	$w.menu.file add command -label $comEasyMsg(mComStop) \
		-command "CloseCom 1" -state disabled -accelerator "Ctrl-Z"
#	$w.menu.file add separator
#	$w.menu.file add command -label $comEasyMsg(mComPrint) \
#		-command "GeoListPrint $w.w.t"
#	$w.menu.file add command -label $comEasyMsg(mComPrintSelection) \
#		-command "GeoListPrint $w.w.t 1"
	$w.menu.file add separator
	$w.menu.file add command -label $comEasyMsg(mComExit) \
		-command "ComExit $top"

	menu $w.menu.file.stored -tearoff 0 \
		-postcommand "ComSetFill $w.menu.file.stored"
#	menu $w.menu.file.dir -tearoff 0 \
#		-postcommand "ComDirFill $w.menu.file.dir"

	$w.menu add cascade -label $comEasyMsg(mComHelp) -menu $w.menu.help

	menu $w.menu.help -tearoff 0
	$w.menu.help add command -label $comEasyMsg(mComHelp1) \
		-command "GeoHelp ComEasy.html"
	$w.menu.help add command -label $comEasyMsg(mComAbout) \
		-command "ComAbout"

	$top configure -menu $w.menu

	text $w.w.t -setgrid 1 -wrap none -relief sunken -font courier \
		-exportselection yes \
		-yscrollcommand "$w.w.vs set" -xscrollcommand "$w.w.hs set"
	scrollbar $w.w.vs -orient vertical -command "$w.w.t yview"
	scrollbar $w.w.hs -orient horizontal -command "$w.w.t xview"
	pack $w.w.vs -side right -fill y
	pack $w.w.hs -side bottom -fill x
	pack $w.w.t -side top -fill both -expand 1

	bind $w.w.t <Key-Next> "$w.w.t yview scroll 1 pages"
	bind $w.w.t <Key-Prior> "$w.w.t yview scroll -1 pages"
	bind $w.w.t <Key-Down> "$w.w.t yview scroll 1 units"
	bind $w.w.t <Key-Up> "$w.w.t yview scroll -1 units"
	
	bind all <Control-Key-z> "CloseCom 1"

	focus $w.w.t 

	DefComParams
}

#
#	Fill menu with stored configuration files
#	@param m path to menu widget to fill
proc ComSetFill {m} {
	global actPars

	catch "$m delete 0 last"			;# remove previous options
	catch {foreach c [glob "com_set/*.com"] {
		$m add command -label [file tail $c] \
			-command "source $c; ShowMsg $c; ShowPars"
	}}
}

#
#	Read available info from serial buffer
#	@param com handle to communication chanel
proc ReadCom {com} {
	global saveto	;# file to write to
	global comEasyMsg
	global actPars

	if {[catch {set cmsg [gets $com]} msg]} {
		tk_dialog .msg $comEasyMsg(error) "$comEasyMsg(cantRead)\n$msg" \
			error 0 OK
		CloseCom
		return
	}
	# end of file ?
	if {[eof $com]} {
		ShowMsg $comEasyMsg(eof)
		CloseCom 1
		return
	}
	if {[string length $cmsg]} {	;# skip empty lines
		# check for EOF char
		set n [expr {[string length $actPars(eofchar)] - 1}]
		if {$n >= 0 && \
			[string compare $actPars(eofchar) [string range $cmsg 0 $n]] == 0} {
			CloseCom 1
			return
		}
		# check for Leica TC 600 conversation
		set n [expr {[string length $actPars(sendquery)]}]
		if {$n == 0 || \
				[expr {[string length $actPars(sendquery)]}] > 0 && \
				[string compare $actPars(sendquery) $cmsg] != 0} {
			ShowMsg $cmsg
			if {[catch {puts $saveto $cmsg} msg]} {
				tk_dialog .msg $comEasyMsg(error) \
					"$comEasyMsg(cantFWrite)\n$msg" error 0 OK
				CloseCom
				return
			}
		} else {
			# do not write ask for query message
			if {$n} {
				puts $com $actPars(query)	;# query next line
			}
		}
	}
}

#
#	Close connection and output file pressing ctrl-z
#	@param load 0/1 if 1 load data to geo_easy if not stand alone version
proc CloseCom {{load 0}} {
	global com	;# opened communication chanel
	global saveto	;# file to write to
	global savename
	global ctopw
	global comEasyMsg

	if {[catch {close $com}] == 0} {
		ShowMsg $comEasyMsg(comClose)
	}
	if {[catch {close $saveto}] == 0} {
		ShowMsg $comEasyMsg(comFClose)
	}
	if {$load && [string length $ctopw]} {
		if {[tk_dialog .msg info $comEasyMsg(loadgizi) info 0 OK \
				$comEasyMsg(cancel)] == 0} {
			MenuLoad $ctopw $savename
		}
	}
	ComMenu 0	;# enable menus
}

#
#	Open serial port and set communication parameters
proc OpenCom {} {
	global comEasyMsg
	global com	;# opened communication chanel
	global actPars

	CloseCom
	if {[regexp -nocase "com\[0-9\]+" $actPars(port)]} {
	# windows
		set sp [format {\\.\%s} $actPars(port)]
	} else {
		set sp $actPars(port)
	}
	if {[catch {set com [open $sp RDWR]} msg] == 1} {
		tk_dialog .msg $comEasyMsg(error) "$comEasyMsg(comOpen)\n$msg" \
			error 0 OK
		return 1
	}
	if {[catch {fconfigure $com \
		-mode $actPars(baud),$actPars(parity),$actPars(data),$actPars(stop) \
		-blocking $actPars(blocking) \
		-translation $actPars(translation) \
		-buffering $actPars(buffering) \
		-buffersize $actPars(buffsize)} msg] == 1} {
			tk_dialog .msg $comEasyMsg(error) \
				"$comEasyMsg(comConfigure)\n$msg" error 0 OK
			return 1
	}
	fileevent $com readable [list ReadCom $com]
	if {[string length $actPars(query)]} {
		puts $com $actPars(query)
	}
	return 0
}

#
#		Write message to the text widget and make text visible
proc ShowMsg {msg} {
	global ctopw

	$ctopw.w.t insert end "$msg\n"
	$ctopw.w.t see end
}

#
#		Change menu state depending on busy
#		@param busy 0/1 idle/busy
proc ComMenu {busy} {
	global ctopw

	if {$busy} {
		# disable load settings, settings, download, upload
		foreach i {0 1 3 4} {
			$ctopw.menu.file entryconfigure $i -state disabled
		}
		# enable stop transfer
		$ctopw.menu.file entryconfigure 5 -state normal
	} else {
		# disable stop transfer
		$ctopw.menu.file entryconfigure 5 -state disabled
		# enable load settings, settings, download, upload
		foreach i {0 1 3 4} {
			$ctopw.menu.file entryconfigure $i -state normal
		}
	}
}

#
#	Write message to the text widget and make text visible
proc ShowPars {} {
	global actPars
	global comEasyMsg
	global ctopw

	ShowMsg $comEasyMsg(separator)
	ShowMsg "$comEasyMsg(parsPort) $actPars(port)"
	ShowMsg "$comEasyMsg(parsBaud) $actPars(baud)"
	ShowMsg "$comEasyMsg(parsParity) $actPars(parity)"
	ShowMsg "$comEasyMsg(parsData) $actPars(data)"
	ShowMsg "$comEasyMsg(parsStop) $actPars(stop)"
	ShowMsg "$comEasyMsg(parsBlocking) $actPars(blocking)"
	ShowMsg "$comEasyMsg(parsTranslation) $actPars(translation)"
	ShowMsg "$comEasyMsg(parsBuffering) $actPars(buffering)"
	ShowMsg "$comEasyMsg(parsBuffsize) $actPars(buffsize)"
	ShowMsg "$comEasyMsg(parsEncoding) $actPars(encoding)"
	if {[string length  $actPars(eofchar)]} {
		scan $actPars(eofchar) %c w
		if {$w < 32} {
			ShowMsg "$comEasyMsg(parsEofchar) Ctrl-[format %c [expr {$w | 64}]]"
		} else {
			ShowMsg "$comEasyMsg(parsEofchar) $actPars(eofchar)"
		}
	} else {
		ShowMsg "$comEasyMsg(parsEofchar) $actPars(eofchar)"
	}
	ShowMsg "$comEasyMsg(parsInit) $actPars(init)"
	ShowMsg "$comEasyMsg(parsQuery) $actPars(query)"
	ShowMsg "$comEasyMsg(parsSendquery) $actPars(sendquery)"

	ShowMsg $comEasyMsg(separator)

	# update menu
	if {! [info exists actPars(dir)]} {
		set actPars(dir) ""
	}
}

#
#	Set up default communication parameters
#	params are stored in an array
proc DefComParams {} {
	global tcl_platform
	global comEasyMsg
	global actPars

	catch { unset actPars }	;# remove previous settings
	if {[file exists "com_set/default.com"]} {
		# load default parameters from file
		if {[catch {source "com_set/default.com"}] == 0} {
			# echo settings
			ShowPars
			return
		}
	}
	# set general default 
	if {$tcl_platform(platform) == "unix"} {
		set actPars(port) "/dev/ttyUSB0"
	} else {
		set actPars(port) "com1"
	}
	set actPars(baud) 9600
	set actPars(parity) "n"
	set actPars(data) 8
	set actPars(stop) 1
	set actPars(blocking) 0
	set actPars(translation) auto
	set actPars(buffering) line
	set actPars(buffsize) [fconfigure stdin -buffersize]
	set actPars(encoding) [fconfigure stdout -encoding]
	set actPars(eofchar) ""
	set actPars(init) ""
	set actPars(query) ""
	set actPars(sendquery) ""
	set actPars(dir) ""

	# echo settings
	ShowPars
}

#
#	Set up communication parameters in a dialogbox
proc ComParsDlg {} {
	global comEasyMsg
	global ctopw
	global actPars	;# actual communication parameters	
	global tcl_platform
	global aport abaud aparity adata astop ablocking atranslation abuffering \
		abuffsize aencoding ainit aeof aquery asendquery adir
	global buttonid
	global comSetTypes

	set w1 [focus]
	if {$w1 == ""} { set w1 "." }
	set w ".compars"
	if {[winfo exists $w]} { return }
	toplevel $w -class Dialog
	wm title $w $comEasyMsg(parsTitle)
	wm resizable $w 0 0
	wm transient $w $w1
	catch {wm attribute $this -topmost}
	set aport $actPars(port)
	set abaud $actPars(baud)
	set aparity $actPars(parity)
	set adata $actPars(data)
	set astop $actPars(stop)
	set ablocking $actPars(blocking)
	set atranslation $actPars(translation)
	set abuffering $actPars(buffering)
	set abuffsize $actPars(buffsize)
	set aeof $actPars(eofchar)
	set aencoding $actPars(encoding)
	set ainit $actPars(init)
	set aquery $actPars(query)
	set asendquery $actPars(sendquery)
	set adir $actPars(dir)
	
	# headlines
	label $w.lhead1 -text $comEasyMsg(parsHead1)
	label $w.lhead2 -text $comEasyMsg(parsHead2)
	label $w.lhead3 -text $comEasyMsg(parsHead3)


	# serial line settings
	label $w.lport -text $comEasyMsg(parsPort)
	set portlist ""
	for {set i 0} {$i < 25} {incr i} {
		if {$tcl_platform(platform) == "unix"} {
			if {[catch {set tmp [open /dev/ttyS$i RDWR]} msg] == 0} {
				close $tmp
				lappend portlist /dev/ttyS$i
			}
			if {[catch {set tmp [open /dev/ttyUSB$i RDWR]} msg] == 0} {
				close $tmp
				lappend portlist /dev/ttyUSB$i
			}
		} else {
			set sp [format {\\.\com%d} $i]
			if {[catch {set tmp [open $sp RDWR]} msg] == 0} {
				close $tmp
				lappend portlist com${i}
			}
		}
	}
	if {[llength $portlist] == 0} { set portlist {"no port"} }
	eval tk_optionMenu $w.mport aport $portlist
	label $w.lbaud -text $comEasyMsg(parsBaud)
	tk_optionMenu $w.mbaud abaud "9600" "4800" "2400" "1200" "300" "110" \
		"19200" "38400" "57600"
	label $w.lparity -text $comEasyMsg(parsParity)
	tk_optionMenu $w.mparity aparity "n" "e" "o"
	label $w.ldata -text $comEasyMsg(parsData)
	tk_optionMenu $w.mdata adata "8" "7" "6" "5" "4"
	label $w.lstop -text $comEasyMsg(parsStop)
	tk_optionMenu $w.mstop astop "1" "1.5" "2"
	label $w.leof -text $comEasyMsg(parsEofchar)
	entry $w.eeof -textvariable aeof -width 5
	label $w.lblocking -text $comEasyMsg(parsBlocking)
	tk_optionMenu $w.mblocking ablocking "0" "1"

	# communication settings
	label $w.ltranslation -text $comEasyMsg(parsTranslation)
	tk_optionMenu $w.mtranslation atranslation "auto" "binary" \
		"cr" "crlf" "lf"
	label $w.lbuffering -text $comEasyMsg(parsBuffering)
	tk_optionMenu $w.mbuffering abuffering "line" "none" "full" 
	label $w.lbuffsize -text  $comEasyMsg(parsBuffsize)
	entry $w.ebuffsize -textvariable abuffsize -width 10
	label $w.lencoding -text $comEasyMsg(parsEncoding)
	eval tk_optMenu $w.mencoding aencoding [lsort [split [encoding names]]]
	label $w.linit -text $comEasyMsg(parsInit)
	entry $w.einit -textvariable ainit -width 10

	label $w.lquery -text $comEasyMsg(parsQuery)
	entry $w.equery -textvariable aquery -width 10
	label $w.lsendquery -text $comEasyMsg(parsSendquery)
	entry $w.esendquery -textvariable asendquery -width 10

	label $w.ldir -text $comEasyMsg(parsDir)
	entry $w.edir -textvariable adir -width 10

	button $w.save -text $comEasyMsg(save) \
		-command "destroy $w; set buttonid 0"
	button $w.load -text $comEasyMsg(load) \
		-command "destroy $w; set buttonid 1"
	button $w.cancel -text $comEasyMsg(cancel) \
		-command "destroy $w; set buttonid 2"
	button $w.exit -text $comEasyMsg(ok) -default active \
		-command "destroy $w; set buttonid 3"

	grid $w.lhead1 -row 0 -column 0 -columnspan 2 -sticky w
	grid $w.lhead2 -row 0 -column 2 -columnspan 2 -sticky w
#	grid $w.lhead3 -row 0 -column 4 -columnspan 2 -sticky w

	grid $w.lport -row 1 -column 0 -sticky w
	grid $w.mport -row 1 -column 1 -sticky w
	grid $w.lbaud -row 2 -column 0 -sticky w
	grid $w.mbaud -row 2 -column 1 -sticky w
	grid $w.lparity -row 3 -column 0 -sticky w
	grid $w.mparity -row 3 -column 1 -sticky w
	grid $w.ldata -row 4 -column 0 -sticky w
	grid $w.mdata -row 4 -column 1 -sticky w
	grid $w.lstop -row 5 -column 0 -sticky w
	grid $w.mstop -row 5 -column 1 -sticky w
	grid $w.leof -row 6 -column 0 -sticky w
	grid $w.eeof -row 6 -column 1 -sticky w
	grid $w.lblocking -row 7 -column 0 -sticky w
	grid $w.mblocking -row 7 -column 1 -sticky w

	grid $w.ltranslation -row 1 -column 2 -sticky w
	grid $w.mtranslation -row 1 -column 3 -sticky w
	grid $w.lbuffering -row 2 -column 2 -sticky w
	grid $w.mbuffering -row 2 -column 3 -sticky w
	grid $w.lbuffsize -row 3 -column 2 -sticky w
	grid $w.ebuffsize -row 3 -column 3 -sticky w
	grid $w.lencoding -row 4 -column 2 -sticky w
	grid $w.mencoding -row 4 -column 3 -sticky w
	grid $w.linit -row 5 -column 2 -sticky w
	grid $w.einit -row 5 -column 3 -sticky w
	grid $w.lquery -row 6 -column 2 -sticky w
	grid $w.equery -row 6 -column 3 -sticky w
	grid $w.lsendquery -row 7 -column 2 -sticky w
	grid $w.esendquery -row 7 -column 3 -sticky w

#	grid $w.ldir -row 1 -column 4 -sticky w
#	grid $w.edir -row 1 -column 5 -sticky w

	grid $w.save -row 8 -column 0 ;#-sticky w
	grid $w.load -row 8 -column 1 ;#-sticky w
	grid $w.cancel -row 8 -column 2 ;#-sticky w
	grid $w.exit -row 8 -column 3 ;#-sticky w

	set buttonid -1
	tkwait visibility $w
	CenterWnd $w
	grab set $w
	tkwait variable buttonid
	if {$buttonid == 0 || $buttonid == 3} {		;# ok or save
		set actPars(port) $aport
		set actPars(baud) $abaud
		set actPars(parity) $aparity
		set actPars(data) $adata
		set actPars(stop) $astop
		if {$ablocking == 1} {
			set ablocking 0
			tk_dialog .msg $comEasyMsg(error) \
				"$comEasyMsg(noBlocking)" warning 0 OK
		}
		set actPars(blocking) $ablocking
		set actPars(translation) $atranslation
		set actPars(buffering) $abuffering
		set actPars(buffsize) $abuffsize
		set actPars(init) [string trim $ainit]
		set actPars(query) [string trim $aquery]
		set actPars(sendquery) [string trim $asendquery]
		set aeof [string trim $aeof]
		switch -glob $aeof {
			"\\x[0-9a-z][0-9a-z]" {
				scan [string range $aeof 2 3] "%x" w
				set aeof [format %c $w]
			}
			"\\X[0-9A-Z][0-9A-Z]" {
				scan [string range $aeof 2 3] "%X" w
				set aeof [format %c $w]
			}
			"^[a-zA-Z]" {
				scan [string range $aeof 1 1] "%c" w
				set aeof [format %c [expr {$w & 31}]]
			}
			"[Cc][Tt][Rr][Ll]-[a-zA-Z]" {
				set w [string range $aeof end end]
				set aeof [format %c [expr {$w & 31}]]
			}
		}
		set actPars(eofchar) $aeof
		set actPars(dir) $adir

		# echo settings
		ShowPars
	}
	if {$buttonid == 0} {	;# save settings
		set fn [string trim [tk_getSaveFile -filetypes $comSetTypes \
			-defaultextension ".com" -initialdir com_set]]
		if {[string length $fn] && [string match "after#*" $fn] == 0} {
			if {[catch {set of [open $fn "w"]} msg]} {
				tk_dialog .msg $comEasyMsg(error) \
					"$comEasyMsg(cantSave)\n$msg" warning 0 OK
				return
			}
			foreach i [array names actPars] {
				puts $of "set actPars($i) \"$actPars($i)\""
			}
			close $of
		}
	}
	if {$buttonid == 1} {
		# load setting from file
		set fn [string trim [tk_getOpenFile -filetypes $comSetTypes \
			-defaultextension ".com" -initialdir com_set]]
		if {[string length $fn] && [string match "after#*" $fn] == 0} {
			if {[catch {source $fn} msg]} {
				tk_dialog .msg $comEasyMsg(error) \
					"$comEasyMsg(cantSource)\n$msg" warning 0 OK
				return
			}
			# echo settings
			ShowPars
		}
	}
}

#
#	Read data from instrument
proc ComDownload {} {
	global comEasyMsg
	global comTypes
	global actPars
	global saveto
	global savename
	global com
	global lastDir
	global comSaveType

	if {[winfo exists .compars]} { return }
	set savename ""
	set fn [string trim [tk_getSaveFile -filetypes $comTypes \
		-initialdir $lastDir -typevariable comSaveType]]
	# string match is used to avoid silly Windows 10 bug
	if {[string length $fn] && [string match "after#*" $fn] == 0} {
		# some extra work to get extension for windows
		regsub "\\(.*\\)$" $comSaveType "" comSaveType
		set comSaveType [string trim $comSaveType]
		set typ [lindex [lindex $comTypes [lsearch -regexp $comTypes $comSaveType]] 1]
		if {[string match -nocase "*$typ" $fn] == 0} {
			set fn "$fn$typ"
		}
		set lastDir [file dirname $fn]
		set savename $fn
		if {[OpenCom] == 0} {
			ComMenu 1	;# disable menus
			if {[catch {set saveto [open $fn w]} msg] == 1} {
				tk_dialog .msg $comEasyMsg(error) \
					"$comEasyMsg(cantSave)\n$msg" warning 0 OK
				return
				CloseCom
			}
			if {[string length $actPars(init)]} {
				# send init string
				if {[catch {puts $com $actPars(init)} msg]} {
					CloseCom
					tk_dialog .msg $comEasyMsg(error) \
						"$comEasyMsg(cantWrite)\n$msg" warning 0 OK
					return
				}
			}
			ShowMsg  $comEasyMsg(waiting)
		}
	}
}

#
#	Write data to instrument
proc ComUpload {} {
	global com
	global comEasyMsg
	global comTypes
	global actPars

	if {[winfo exists .compars]} { return }
	set fn [string trim [tk_getOpenFile -filetypes $comTypes]]
	if {[string length $fn] && [string match "after#*" $fn] == 0} {
		if {[catch {set f [open $fn r]} msg] == 1} {
			tk_dialog .msg $comEasyMsg(error) \
				"$comEasyMsg(cantOpen)\n$msg" warning 0 OK
			return
		}
		if {[OpenCom] == 0} {
			ComMenu 1	;# disable menus
			if {[string length $actPars(init)]} {
				# send init string
				if {[catch {puts $com $actPars(init)} msg]} {
					CloseCom
					catch {close $f}
					tk_dialog .msg $comEasyMsg(error) \
						"$comEasyMsg(cantWrite)\n$msg" warning 0 OK
					return
				}
			}
			while {! [eof $f]} {
				if {[catch {gets $f buf} msg]} {
					CloseCom
					catch {close $f}
					tk_dialog .msg $comEasyMsg(error) \
						"$comEasyMsg(cantFRead)\n$msg" warning 0 OK
					return
				}
				puts $com $buf
				after 50	;# delay for some slow instruments
				ShowMsg $buf
#update
			}
			# send eof
			set eofchar [lindex [fconfigure $com -eofchar] 0]
			if {[string length $eofchar]} {
				if {[catch {puts $com $eofchar} msg]} {
					CloseCom
					catch {close $f}
					tk_dialog .msg $comEasyMsg(error) \
						"$comEasyMsg(cantWrite)\n$msg" warning 0 OK
					return
				}
			}
			catch {close $f}
			CloseCom
			ComMenu 0	;# enable menus
		}
	}
}

#
#	Close all windows and open communication chanels/files
proc ComExit {top} {

	CloseCom
	foreach w [winfo children $top] {
		destroy $w
	}
	destroy $top
}

#
#	tk_optionMenu variant with multicolumn popup
#
#	@param w menubutton name
#	@param varName global variable to store selected value
# 	@param args option to select from
proc tk_optMenu {w varName args} {
	upvar #0 $varName var

	if { ! [info exists var]} {
		set var [lindex $args 0]
	}
	menubutton $w -textvariable $varName -indicatoron 1 -menu $w.menu \
		-relief raised -bd 2 -highlightthickness 2 -anchor c \
		-direction flush
	menu $w.menu -tearoff 0
	set k 0
	foreach  i $args {
		if {$k > 0 && [expr {$k % 15}] == 0} {	#; 16 elemenkent uj oszlop
			$w.menu add radiobutton -label $i -variable $varName -columnbreak 1
		} else {
			$w.menu add radiobutton -label $i -variable $varName
		}
		incr k
	}
	return $w.menu
}

#
#	Display About dialog box
proc ComAbout {} {
	global comEasyMsg

	set w [focus]
	if {$w == ""} { set w "." }
	set bmdir bitmaps
	catch {destroy .about}
	toplevel .about -class Dialog
	wm title .about $comEasyMsg(mComAbout)
	wm resizable .about 0 0
	wm transient .about $w
	catch {wm attribute $this -topmost}
	if {[lsearch -exact [image names] about] == -1} {
		image create photo about -file [file join $bmdir about.gif]
	}
	label .about.l -image about
	label .about.t1 -text $comEasyMsg(comTitle)
	label .about.t2 -text $comEasyMsg(digikom)
	label .about.t3 -text $comEasyMsg(about1)
	label .about.t4 -text $comEasyMsg(about2)
	grid .about.l -column 0 -row 0 -rowspan 4
	grid .about.t1 -column 1 -row 0
	grid .about.t2 -column 1 -row 1
	grid .about.t3 -column 1 -row 2
	grid .about.t4 -column 1 -row 3
	button .about.ok -text $comEasyMsg(ok) -command "destroy .about"
	grid .about.ok -row 4 -column 0 -columnspan 2
	tkwait visibility .about
	CenterWnd .about
	grab set .about
}
