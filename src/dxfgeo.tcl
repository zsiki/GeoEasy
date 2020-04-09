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
#	Create AutoCAD release 10/11/12 DXF file
proc GeoDXF {} {
	global geoEasyMsg
	global dxfview
	global tcl_platform
	global geoLoaded
	global buttonid
	global lastDir
	global reg
	global rp dxpn dypn dxz dyz spn sz pon zon slay pnlay zlay p3d pd zdec \
		pcodelayer xzplane useblock
	global contourInterval contourDxf contourLayer contour3Dface
	global cadTypes

	set filen [string trim [tk_getSaveFile -filetypes $cadTypes \
		-defaultextension ".dxf" -initialdir $lastDir]]
	if {[string length $filen] && [string match "after#*" $filen] == 0} {
		set lastDir [file dirname $filen]
		DXFparams
		tkwait window .dxfparams
		if {$buttonid} { return }
		if {[regexp $reg(2) $rp] == 0 || [regexp $reg(2) $spn] == 0 || \
			[regexp $reg(2) $dxpn] == 0 || [regexp $reg(2) $dypn] == 0 || \
			[regexp $reg(2) $dxz] == 0 || [regexp $reg(2) $dyz] == 0 || \
			[regexp $reg(2) $sz] == 0 || [regexp $reg(1) $zdec] == 0 || \
			[regexp $reg(2) $contourInterval] == 0} {

			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
				error 0 OK
			return
		}
		DXFout $filen

		if {[tk_dialog .msg $geoEasyMsg(info) $geoEasyMsg(openit) info 0 \
				$geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
			if {[ShellExec "$filen"]} {
				tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(rtfview) \
					warning 0 OK
			}
		}
	}
}

#
#	Create AutoCAD release 10/11/12 DXF file
#	@param fn file name
proc DXFout {fn} {
	global geoLoaded geoEasyMsg
	global pd
	global rp dxpn dypn dxz dyz spn sz pon zon slay pnlay zlay p3d zdec \
		pcodelayer xzplane useblock addlines
    global contourInterval contourDxf contourLayer contour3Dface
	global regLineStart regLineCont regLineEnd regLine regLineClose

	if {[catch {set fd [open $fn w]} msg]} {
		tk_dialog .msg $geoEasyMsg(error) "$geoEasyMsg(-1): $msg" \
			error 0 OK
		return
	}
	set p_list [GetAll]						;# all point names
	if {$pd} {
		set p_list [GetDetail]					;# names of detail points
	}
	# generate MBR
	set xmin ""; set ymin ""; set xmax ""; set ymax ""
	if {$contourDxf} {
		set minmax [DtmStat 0]
		set xmin [lindex $minmax 0]
		set ymin [lindex $minmax 1]
		set xmax [lindex $minmax 3]
		set ymax [lindex $minmax 4]
	}
	foreach p $p_list {
		set c [GetCoord $p {37 38}]
		set x [GetVal 37 $c]
		set y [GetVal 38 $c]
		if {$x != "" && ($x < $xmin || $xmin == "")} {
			set xmin $x
		}
		if {$y != "" && ($y < $ymin || $ymin == "")} {
			set ymin $y
		}
		if {$x != "" && ($x > $xmax || $xmax == "")} {
			set xmax $x
		}
		if {$y != "" && ($y > $ymax || $ymax == "")} {
			set ymax $y
		}
	}
	puts $fd "  0\nSECTION\n  2\nHEADER"
	puts $fd "  9\n\$ACADVER\n  1\nAC1009"
	# minimax
	puts $fd "  9\n\$EXTMIN\n 10\n$ymin\n 20\n$xmin\n 30\n0.0"
	puts $fd "  9\n\$EXTMAX\n 10\n$ymax\n 20\n$xmax\n 30\n0.0"
	puts $fd "  9\n\$PDMODE\n 70\n   2"
	puts $fd "  9\n\$PDSIZE\n 40\n $rp"
	puts $fd "  0\nENDSEC"
	# dxf tables
	puts $fd "  0\nSECTION\n  2\nTABLES"
	# vport table
#	puts $fd "  0\nTABLE\n  2\nVPORT"
#	puts $fd " 70\n  2\n  0\nVPORT\n  2\n*ACTIVE"
#	puts $fd " 70\n0\n 10\n0.0\n20\n0.0\n 11\n1.0\n21\n1.0"
#	puts $fd " 12\n[expr {($ymin + $ymax) / 2.0}]"
#	puts $fd " 22\n[expr {($xmin + $xmax) / 2.0}]"
#	puts $fd " 13\n0.0\n 23\n0.0\n 14\n1.0\n 24\n1.0\n 15\n0.0\n 25\n0.0"
#	puts $fd " 16\n0.0\n 26\n0.0\n 36\n1.0\n 17\n0.0\n 27\n0.0\n 37\n0.0"
# 40, 41, 42 elrontva TBD
#	puts $fd " 40\n1.0\n 41\n1.0\n 42\n50.0\n 43\n0.0"
#	puts $fd " 44\n0.0\n 50\n0.0\n 51\n0.0"
#	puts $fd " 71\n0\n 72\n100\n 73\n1\n 74\n3\n 75\n0\n 76\n0\n 77\n0\n 78\n0"
#	puts $fd "  0\nENDTAB"
	# layer table (base layers only)
	puts $fd "  0\nTABLE\n  2\nLAYER\n 70\n4"
	puts $fd "  0\nLAYER\n  2\n0\n 70\n0\n 62\n7\n  6\nCONTINUOUS"
	puts $fd "  0\nLAYER\n  2\n$slay\n 70\n0\n 62\n7\n  6\nCONTINUOUS"
	puts $fd "  0\nLAYER\n  2\n$pnlay\n 70\n0\n 62\n7\n  6\nCONTINUOUS"
	puts $fd "  0\nLAYER\n  2\n$zlay\n 70\n0\n 62\n7\n  6\nCONTINUOUS"
	# TBD contour & linework layers
	puts $fd "  0\nENDTAB"
	puts $fd "  0\nENDSEC"
	# blocks
	if {$useblock} {
		puts $fd "  0\nSECTION\n  2\nBLOCKS"
		puts $fd "  0\nBLOCK\n  8\n0\n  2\nPONT\n 70\n2"
		puts $fd " 10\n0.0\n 20\n0.0\n 30\n0.0"
		puts $fd "  3\nPONT\n  1\n"
		puts $fd "  0\nATTDEF\n  8\n0\n 62\n0"
		puts $fd " 10\n0.0\n 20\n-1.4\n 30\n0.0\n 40\n1.0\n  1\n"
		puts $fd "  3\nPontkod\n  2\nKOD\n 70\n0"
		puts $fd "  0\nATTDEF\n  8\n0\n 62\n0"
		puts $fd " 10\n0.0\n 20\n0.0\n 30\n0.0\n 40\n1.0\n  1\n"
		puts $fd "  3\nPontszam\n  2\nPONTSZAM\n 70\n0"
		puts $fd "  0\nCIRCLE\n  8\n0\n 62\n0"
		puts $fd " 10\n0.0\n 20\n0.0\n 30\n0.0\n 40\n0.5"
		puts $fd "  0\nENDBLK"
		puts $fd "  0\nENDSEC"
	}
	
	puts $fd "  0\nSECTION\n  2\nENTITIES"
	set lineno 0
	foreach pn $p_list {
		DXFout1 $fd $pn
		incr lineno
	}
	# draw contours
	TContour "" 1 $fd
	# draw linework
	if {$addlines} {
		if {[string length $regLineStart]} {
			set multiLine 1
		} else {
			set lastCode ""
			set multiLine 0
		}
		foreach geo $geoLoaded {
			global ${geo}_geo
			set indexes [lsort -integer [array names ${geo}_geo]]
			foreach ind $indexes {
				set rec [set ${geo}_geo($ind)]
				set st [GetVal 2 $rec]
				if {$st != ""} {		;# station found
					if {! $multiLine} {
						set lastCode ""	;# new line to start
						set lastp_x ""
						set lastp_y ""
						set lastp_z ""
					}
				} else {
					set p [GetVal {5 62} $rec]
					if {[lsearch -exact $p_list $p] == -1} {
						# point not drawn
						continue
					}
					set p_coo [GetCoord $p {37 38}]
					if {$p_coo != ""} {
						set p_x [GetVal 38 $p_coo]
						set p_y [GetVal 37 $p_coo]
						set p_z [GetVal 39 $p_coo]
						if {$p_z == ""} { set p_z 0}
						set code [GetVal 4 $rec]
						if {[string length [string trim $code]] == 0} { continue }
						if {$multiLine} {
							if {[regexp $regLineStart $code]} {
								set pat "(.*)$regLineStart"
								regsub -- $pat $code \\1 codeName
								if {[string length $codeName]} {
									set lastp_x($codeName) $p_x
									set lastp_y($codeName) $p_y
									set lastp_z($codeName) $p_z
									set first_x($codeName) $p_x
									set first_y($codeName) $p_y
									set first_z($codeName) $p_z
								}
							} elseif {[regexp $regLineCont $code]} {
								set pat "(.*)$regLineCont"
								regsub -- $pat $code \\1 codeName
								if {[string length $codeName]} {
									if {[info exists lastp_x($codeName)] && [info exists lastp_y($codeName)]} {
										puts $fd "  0\nLINE\n  8\n$codeName"
										if {$p3d} {
											puts $fd " 10\n$lastp_x($codeName)\n 20\n$lastp_y($codeName)\n 30\n$last_z($codeName)"
											puts $fd " 11\n$p_x\n 21\n$p_y\n\ 31\n$p_z"
										} else {
											puts $fd " 10\n$lastp_x($codeName)\n 20\n$lastp_y($codeName)"
											puts $fd " 11\n$p_x\n 21\n$p_y"
										}
									}
									set lastp_x($codeName) $p_x
									set lastp_y($codeName) $p_y
									set lastp_z($codeName) $p_z
								}
							} elseif {[regexp $regLineEnd $code]} {
								set pat "(.*)$regLineEnd"
								regsub -- $pat $code \\1 codeName
								if {[string length $codeName]} {
									if {[info exists lastp_x($codeName)] && [info exists lastp_y($codeName)]} {
										puts $fd "  0\nLINE\n  8\n$codeName"
										if {$p3d} {
											puts $fd " 10\n$lastp_x($codeName)\n 20\n$lastp_y($codeName)\n 30\n$last_z($codeName)"
											puts $fd " 11\n$p_x\n 21\n$p_y\n\ 31\n$p_z"
										} else {
											puts $fd " 10\n$lastp_x($codeName)\n 20\n$lastp_y($codeName)"
											puts $fd " 11\n$p_x\n 21\n$p_y"
										}
										unset lastp_x($codeName)
										unset lastp_y($codeName)
										unset lastp_z($codeName)
									}
									if {[info exists first_x($codeName)] && [info exists first_y($codeName)]} {
										unset first_x($codeName)
										unset first_y($codeName)
										unset first_z($codeName)
									}
								}
							} elseif {[regexp $regLineClose $code]} {
								set pat "(.*)$regLineClose"
								regsub -- $pat $code \\1 codeName
								if {[string length $codeName]} {
									if {[info exists lastp_x($codeName)] && [info exists lastp_y($codeName)]} {
										puts $fd "  0\nLINE\n  8\n$codeName"
										if {$p3d} {
											puts $fd " 10\n$lastp_x($codeName)\n 20\n$lastp_y($codeName)\n 30\n$last_z($codeName)"
											puts $fd " 11\n$p_x\n 21\n$p_y\n\ 31\n$p_z"
										} else {
											puts $fd " 10\n$lastp_x($codeName)\n 20\n$lastp_y($codeName)"
											puts $fd " 11\n$p_x\n 21\n$p_y"
										}
										unset lastp_x($codeName)
										unset lastp_y($codeName)
										unset lastp_z($codeName)
									}
									if {[info exists first_x($codeName)] && [info exists first_y($codeName)]} {
										puts $fd "  0\nLINE\n  8\n$codeName"
										if {$p3d} {
											puts $fd " 10\n$p_x\n 20\n$p_y\n\ 30\n$p_z"
											puts $fd " 11\n$first_x($codeName)\n 20\n$first_y($codeName)\n 30\n$firstz($codeName)"
										} else {
											puts $fd " 10\n$p_x\n 20\n$p_y"
											puts $fd " 11\n$first_x($codeName)\n 21\n$first_y($codeName)"
										}
										unset first_x($codeName)
										unset first_y($codeName)
										unset first_z($codeName)
									}
								}
							}
						} else {
							if {[string length $lastCode] && [regexp $regLine $code] \
								&& $code == $lastCode} {
								puts $fd "  0\nLINE\n  8\n$code"
								if {$p3d} {
									puts $fd " 10\n$lastp_x\n 20\n$lastp_y\n 30\n$last_z"
									puts $fd " 11\n$p_x\n 21\n$p_y\n\ 31\n$p_z"
								} else {
									puts $fd " 10\n$lastp_x\n 20\n$lastp_y"
									puts $fd " 11\n$p_x\n 21\n$p_y"
								}
							}
							set lastCode $code
							set lastp_x $p_x
							set lastp_y $p_y
							set lastp_z $p_z
						}
					}
				}
			}
		}
	}
	puts $fd "  0\nENDSEC\n  0\nEOF"
	close $fd
}

#
#	Write data for one point
#	@param fd file handle
#	@param pn point name
proc DXFout1 {fd pn} {
	global rp dxpn dypn dxz dyz spn sz pon zon slay pnlay zlay p3d zdec \
		pcodelayer xzplane useblock

	set buf [GetCoord $pn {38 37}]
	set x [GetVal 38 $buf]
	set y [GetVal 37 $buf]
	set z [GetVal 39 $buf]
	if {$xzplane} {
		set w $y
		set y $z
		set z $w
	}
	if {[string length [string trim $x]] == 0 || \
		[string length [string trim $y]] == 0} {
		return				;# no x or y coordinate
	}
	set x [format "%.3f" $x]
	set y [format "%.3f" $y]
	set code [GetVal 4 $buf]
	set layer $slay
	if {$pcodelayer} {
		if {[string length $code]} {
			append layer "_" $code
		}
	}
	if {[string length [string trim $z]]} {
		set z [format "%.${zdec}f" $z]
	} else { set z "" }
	if {$useblock} {
		puts $fd "  0\nINSERT\n  8\n$layer\n 66\n1\n  2\nPONT"
		if {$p3d && [string length $z]} {
			puts $fd " 10\n$x\n 20\n$y\n 30\n$z"
		} else {
			puts $fd " 10\n$x\n 20\n$y"
		}
		puts $fd " 41\n$rp\n 42\n$rp\n 43\n$rp"
		puts $fd "  0\nATTRIB\n  8\n$layer\n 62\n0"
		puts $fd " 10\n$x\n 20\n[expr {$y-1.4}]\n 30\n0.0\n 40\n1.0"
		puts $fd "  1\n$code\n  2\nKOD\n 70\n0"
		puts $fd "  0\nATTRIB\n  8\n$layer\n 62\n0"
		puts $fd " 10\n$x\n 20\n$y\n 30\n0.0\n 40\n1.0"
		puts $fd "  1\n$pn\n  2\nPONTSZAM\n 70\n0"
		puts $fd "  0\nSEQEND"
	} else {
		if {$p3d && [string length $z]} {
			puts $fd "  0\nPOINT\n  8\n$layer\n 10\n$x\n 20\n$y\n 30\n$z"
		} else {
			puts $fd "  0\nPOINT\n  8\n$layer\n 10\n$x\n 20\n$y"
		}
	}
	if {$zon} {
		set wx [format "%.3f" [expr {$x + $dxz}]]
		set wy [format "%.3f" [expr {$y + $dyz}]]
		if {[string length $z]} {
			if {$p3d} {
				puts $fd "  0\nTEXT\n  8\n$zlay\n 10\n$wx\n 20\n$wy\n 30\n$z\n 40\n$sz\n  1\n$z"
			} else {
				puts $fd "  0\nTEXT\n  8\n$zlay\n 10\n$wx\n 20\n$wy\n 40\n$sz\n  1\n$z"
			}
		}
	}
	
	if {$pon && ! $useblock} {
		set wx [format "%.3f" [expr {$x + $dxpn}]]
		set wy [format "%.3f" [expr {$y + $dypn}]]
		if {$p3d && [string length $z]} {
			puts $fd "  0\nTEXT\n  8\n$pnlay\n 10\n$wx\n 20\n$wy\n 30\n$z\n 40\n$spn\n  1\n$pn"
		} else {
			puts $fd "  0\nTEXT\n  8\n$pnlay\n 10\n$wx\n 20\n$wy\n 40\n$spn\n  1\n$pn"
		}
	}
}

#	User interface to get parameters for dxf output
proc DXFparams {} {
	global geoEasyMsg
	global rp dxpn dypn dxz dyz spn sz pon zon slay pnlay zlay p3d pd zdec \
		pcodelayer xzplane useblock addlines
	global contourInterval contourDxf contourLayer contour3Dface
	global buttonid

	set w [focus]
	if {$w == ""} { set w "." }
	set this .dxfparams
	set buttonid 0
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(dxfpar)
	wm resizable $this 0 0
	wm transient $this [winfo toplevel $w]
	catch {wm attribute $this -topmost}

	label $this.lslay -text $geoEasyMsg(layer1)
	label $this.lr -text $geoEasyMsg(ssize)
	checkbutton $this.pcode -text $geoEasyMsg(pcode) -variable pcodelayer
	checkbutton $this.xz -text $geoEasyMsg(xzplane) -variable xzplane
	checkbutton $this.useblock -text $geoEasyMsg(useblock) -variable useblock \
		-command "bl_check $this \$useblock"
	checkbutton $this.p3d -text $geoEasyMsg(3d) -variable p3d
	checkbutton $this.pd -text $geoEasyMsg(pd) -variable pd
	checkbutton $this.pon -text $geoEasyMsg(pnon) -variable pon \
		-command "p_check $this \$pon"
	checkbutton $this.lines -text $geoEasyMsg(addlines) -variable addlines
	label $this.lplay -text $geoEasyMsg(layer2)
	label $this.ldxpn -text $geoEasyMsg(dxpn)
	label $this.ldypn -text $geoEasyMsg(dypn)
	label $this.lspn -text $geoEasyMsg(spn)
	checkbutton $this.zon -text $geoEasyMsg(pzon) -variable zon \
		-command "z_check $this \$zon"
	label $this.lzlay -text $geoEasyMsg(layer3)
	label $this.ldxz -text $geoEasyMsg(dxz)
	label $this.ldyz -text $geoEasyMsg(dyz)
	label $this.lsz -text $geoEasyMsg(sz)
	label $this.lzdec -text $geoEasyMsg(zdec)

	grid $this.lslay -row 0 -column 0 -sticky w
	grid $this.lr -row 1 -column 0 -sticky w
	grid $this.pcode -row 2 -column 0 -sticky w
	grid $this.lines -row 2 -column 1 -sticky w
	grid $this.xz -row 3 -column 0 -sticky w
	grid $this.useblock -row 3 -column 1 -sticky w
	grid $this.pd -row 4 -column 0 -sticky w
	grid $this.p3d -row 4 -column 1 -sticky w
	grid $this.pon -row 5 -column 0 -sticky w -columnspan 2
	grid $this.lplay -row 6 -column 0 -sticky w
	grid $this.ldxpn -row 7 -column 0 -sticky w
	grid $this.ldypn -row 8 -column 0 -sticky w
	grid $this.lspn -row 9 -column 0 -sticky w
	grid $this.zon -row 10 -column 0 -sticky w
	grid $this.lzlay -row 11 -column 0 -sticky w -columnspan 2
	grid $this.ldxz -row 12 -column 0 -sticky w
	grid $this.ldyz -row 13 -column 0 -sticky w
	grid $this.lsz -row 14 -column 0 -sticky w
	grid $this.lzdec -row 15 -column 0 -sticky w

	entry $this.slay -textvariable slay -width 10
	entry $this.r -textvariable rp -width 10
	entry $this.pnlay -textvariable pnlay -width 10
	entry $this.dxpn -textvariable dxpn -width 10
	entry $this.dypn -textvariable dypn -width 10
	entry $this.spn -textvariable spn -width 10
	entry $this.zlay -textvariable zlay -width 10
	entry $this.dxz -textvariable dxz -width 10
	entry $this.dyz -textvariable dyz -width 10
	entry $this.sz -textvariable sz -width 10
	entry $this.zdec -textvariable zdec -width 10

	grid $this.slay -row 0 -column 1 -sticky w
	grid $this.r -row 1 -column 1 -sticky w
	grid $this.pnlay -row 6 -column 1 -sticky w
	grid $this.dxpn -row 7 -column 1 -sticky w
	grid $this.dypn -row 8 -column 1 -sticky w
	grid $this.spn -row 9 -column 1 -sticky w
	grid $this.zlay -row 11 -column 1 -sticky w
	grid $this.dxz -row 12 -column 1 -sticky w
	grid $this.dyz -row 13 -column 1 -sticky w
	grid $this.sz -row 14 -column 1 -sticky w
	grid $this.zdec -row 15 -column 1 -sticky w

	# add contour options
	checkbutton $this.ldxf -text $geoEasyMsg(contourpar) -variable contourDxf \
		-command "c_check $this \$contourDxf"
	label $this.lcontourinterval -text $geoEasyMsg(contourInterval)
	entry $this.contourentry -textvariable contourInterval -width 10
	checkbutton $this.llay -text $geoEasyMsg(contourLayer) \
		-variable contourLayer
	checkbutton $this.l3d -text $geoEasyMsg(contour3Dface) \
		-variable contour3Dface
	grid $this.ldxf -row 16 -column 0 -sticky w -columnspan 2
	grid $this.lcontourinterval -row 17 -column 0 -sticky w
	grid $this.contourentry -row 17 -column 1 -sticky w
	grid $this.llay -row 18 -column 0 -columnspan 2 -sticky e
	grid $this.l3d -row 19 -column 0 -columnspan 2 -sticky e

	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"
	grid $this.exit -row 20 -column 0
	grid $this.cancel -row 20 -column 1
	tkwait visibility $this
	CenterWnd $this
	grab set $this

	p_check $this $pon
	z_check $this $zon
	c_check $this $contourDxf
}

#
#	Setup default values for dxf parameters
proc DXFset {} {
	global rp dxpn dypn dxz dyz spn sz pon zon slay pnlay zlay p3d pd zdec \
		pcodelayer bname battr block ptext xzplane
	global contourInterval contourDxf contourLayer contour3Dface
	global tinLoaded

	set p3d 0							;# 2d points
	set pd 0							;# all points
	set pon 1
	set zon 1
	set slay "PT"
	set pnlay "PN"
	set zlay "ZN"
	set rp 1.0							;# size of point symbol
	set dxpn 0.8						;# offset values to texts
	set dypn 1.0
	set dxz 0.8
	set dyz -1.0
	set spn 1.8							;# text size for point number
	set sz 1.5							;# text size for elevation
	set zdec 2							;# decimals in point height
	set pcodelayer 0					;# add pointcode to layer name
	set xzplane 0
	set block 0							;# import points from blocks
	set bname ""						;# block name for points
	set battr ""						;# attribute name for point number
	set ptext 0							;# import points from text
	if {[string length $tinLoaded] == 0} {
		set contourDxf 0
	} else {
		set contourDxf 1
	}
	set contourInterval 1.0
	set contourLayer 0
	set contour3Dface 0
}

#
#	Change enabled/disables state based on point number on/off
#	Used by DXF export
#	@param this
#	@param flag
proc p_check {this flag} {

	if {$flag} {
		$this.pnlay configure -state normal -foreground black
		$this.dxpn configure -state normal -foreground black
		$this.dypn configure -state normal -foreground black
		$this.spn configure -state normal -foreground black
	} else {
		$this.pnlay configure -state disabled -foreground grey
		$this.dxpn configure -state disabled -foreground grey
		$this.dypn configure -state disabled -foreground grey
		$this.spn configure -state disabled -foreground grey
	}
}

#
#	Change enabled/disables state based on elevation on/off
#	Used by DXF export
#	@param this
#	@param flag
proc z_check {this flag} {

	if {$flag} {
		$this.zlay configure -state normal -foreground black
		$this.dxz configure -state normal -foreground black
		$this.dyz configure -state normal -foreground black
		$this.sz configure -state normal -foreground black
		$this.zdec configure -state normal -foreground black
	} else {
		$this.zlay configure -state disabled -foreground grey
		$this.dxz configure -state disabled -foreground grey
		$this.dyz configure -state disabled -foreground grey
		$this.sz configure -state disabled -foreground grey
		$this.zdec configure -state disabled -foreground grey
	}
}

#
#	Change enabled/disables state based on contour on/off
#	Used by DXF export
#	@param this
#	@param flag
proc c_check {this flag} {
	global tinLoaded
	if {[string length $tinLoaded] == 0} {
		set flag 0
		$this.ldxf configure -state disabled -foreground grey
	}
	if {$flag} {
		$this.contourentry configure -state normal -foreground black
		$this.llay configure -state normal -foreground black
		$this.l3d configure -state normal -foreground black
	} else {
		$this.contourentry configure -state disabled -foreground grey
		$this.llay configure -state disabled -foreground grey
		$this.l3d configure -state disabled -foreground grey
	}
}

#
#	Change enabled/disables state based on block on/off
#	Used by DXF export
#	@param this
#	@param flag
proc bl_check {this flag} {

	if {$flag} {
		$this.pnlay configure -state disabled -foreground grey
		$this.dxpn configure -state disabled -foreground grey
		$this.dypn configure -state disabled -foreground grey
		$this.spn configure -state disabled -foreground grey
		$this.pon configure -state disabled -foreground grey
	} else {
		$this.pnlay configure -state normal -foreground black
		$this.dxpn configure -state normal -foreground black
		$this.dypn configure -state normal -foreground black
		$this.spn configure -state normal -foreground black
		$this.pon configure -state normal -foreground black
	}
}

#
#	Change enabled/disables state based on block on/off
#	Used by DXF import
#	@param this
#	@param flag
proc b_check {this flag} {
global p3d

	if {$flag} {
		$this.bname configure -state normal -foreground black
		$this.battr configure -state normal -foreground black
		$this.bcode configure -state normal -foreground black
		$this.blocklist configure -state normal -foreground black
		$this.attrlist configure -state normal -foreground black
		$this.codelist configure -state normal -foreground black
		if {$p3d} {
			$this.belev configure -state normal -foreground black
			$this.elevlist configure -state normal -foreground black
		}
	} else {
		$this.bname configure -state disabled -foreground grey
		$this.battr configure -state disabled -foreground grey
		$this.bcode configure -state disabled -foreground grey
		$this.belev configure -state disabled -foreground grey
		$this.blocklist configure -state disabled -foreground grey
		$this.attrlist configure -state disabled -foreground grey
		$this.codelist configure -state disabled -foreground grey
		$this.elevlist configure -state disabled -foreground grey
	}
}

#
#	Change enabled/disables state based on point text on/off
#	Used by DXF import
#	@param this
#	@param flag
proc t_check {this flag} {

	if {$flag} {
		$this.pnlay configure -state normal -foreground black
		$this.pcode configure -state normal -foreground black
		$this.layerlist configure -state normal -foreground black
	} else {
		$this.pnlay configure -state disabled -foreground grey
		$this.pcode configure -state disabled -foreground grey
		$this.layerlist configure -state disabled -foreground grey
	}
}

#
#	Change enabled/disables state based on 3D checkbox
#	Used by DXF import
#	@param this
#	@param flag
proc d3_check {this flag} {
	global block

	if {$flag && $block} {
		$this.elevlist configure -state normal -foreground black
		$this.belev configure -state normal -foreground black
	} else {
		$this.elevlist configure -state disabled -foreground grey
		$this.belev configure -state disabled -foreground grey
	}
}

#
#	Collect layer names from DXF file
#	@param title
#	@param mode
proc dxflayers {title {mode 1}} {
	global tmp
	global pnlay

	if {[catch {set f [open $tmp "r"]}]} { return }
	# skip headers till ENTITIES
	set code ""
	set value ""
	while {! [eof $f] && \
			($code != 2 || [string toupper $value] != "ENTITIES")} {
		set code [gets $f]
		set value [gets $f]
	}
	set layer_list ""
	while {! [eof $f]} {
		set code [string trim [gets $f]]
		set value [string toupper [string trim [gets $f]]]
		if {$code == 8} {
			if {[lsearch -exact $layer_list $value] == -1} {
				lappend layer_list $value
			}
		}
	}
	set layer_list [lsort $layer_list]
	set pnlay [GeoListbox $layer_list 0 $title $mode]
}

#
#	Collect block names from DXF file
#	@param title
proc dxfblocks {title} {
	global tmp
	global bname

	if {[catch {set f [open $tmp "r"]}]} { return }
	# skip headers till ENTITIES
	set code ""
	set value ""
	while {! [eof $f] && \
			($code != 2 || [string toupper $value] != "ENTITIES")} {
		set code [gets $f]
		set value [gets $f]
	}
	set block_list ""
	while {! [eof $f]} {
		set code [string trim [gets $f]]
		set value [string toupper [string trim [gets $f]]]
		if {$code == 0} {
			set entity $value
		}
		if {$code == 2 && $entity == "INSERT"} {
			if {[lsearch -exact $block_list $value] == -1} {
				lappend block_list $value
			}
		}
	}
	set block_list [lsort $block_list]
	set bname [GeoListbox $block_list 0 $title 1]
}

#
#	-- dxfattrs
proc dxfattrs {title mode} {
	global tmp
	global battr bcode bname belev

	# no blockname given
	if {[string length [string trim $bname]] == 0} {
		Beep
		return
	}
	if {[catch {set f [open $tmp "r"]}]} { return }
	# skip headers till ENTITIES
	set code ""
	set value ""
	while {! [eof $f] && \
			($code != 2 || [string toupper $value] != "ENTITIES")} {
		set code [gets $f]
		set value [gets $f]
	}
	set attr_list ""
	set entity ""
	set actblock ""
	while {! [eof $f]} {
		set code [string trim [gets $f]]
		set value [string toupper [string trim [gets $f]]]
		if {$code == 0} {
			if {$entity != "ATTRIB"} {
				set lastentity $entity
			}
			set entity $value
		}
		if {$code == 2 && $entity == "INSERT"} {
			set actblock $value
		}
		if {$code == 2 && $lastentity == "INSERT" && $entity == "ATTRIB" && \
				$actblock == $bname} {
			if {[lsearch -exact $attr_list $value] == -1} {
				lappend attr_list $value
			}
		}
	}
	set attr_list [lsort $attr_list]
	switch -exact $mode {
		PNUM { set battr [GeoListbox $attr_list 0 $title 1] }
		CODE { set bcode [GeoListbox $attr_list 0 $title 1] }
		ELEV { set belev [GeoListbox $attr_list 0 $title 1] }
	}
}

#
#	Load coordinates from dxf file
#	@param filen name of dxf file
proc DXFimport {filen} {
	global geoEasyMsg
	global bname battr bcode belev pnlay p3d pcodelayer block ptext dxfpnt
	global buttonid
	global tmp

	set w [focus]
	if {$w == ""} { set w "." }
	set this .dxfimp
	set buttonid 0
	set tmp $filen
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(dxfinpar)
	wm resizable $this 0 0
	wm transient $this $w
	catch {wm attribute $this -topmost}

	checkbutton $this.block -text $geoEasyMsg(block) -variable block \
		-command "b_check $this \$block"
	label $this.lblay -text $geoEasyMsg(layerb)
	label $this.lbattr -text $geoEasyMsg(attrib)
	label $this.lbcode -text $geoEasyMsg(attrcode)
	label $this.lbelev -text $geoEasyMsg(attrelev)
	checkbutton $this.ptext -text $geoEasyMsg(ptext) -variable ptext \
		-command "t_check $this \$ptext"
	label $this.lplay -text $geoEasyMsg(layer2)
	checkbutton $this.pcode -text $geoEasyMsg(pcode1) -variable pcodelayer
	checkbutton $this.dxfpnt -text $geoEasyMsg(dxfpnt) -variable dxfpnt
	checkbutton $this.p3d -text $geoEasyMsg(3d) -variable p3d \
		-command "d3_check $this \$p3d"

	grid $this.block -row 0 -column 0 -sticky w -columnspan 2
	grid $this.lblay -row 1 -column 1 -sticky w
	grid $this.lbattr -row 2 -column 1 -sticky w
	grid $this.lbcode -row 3 -column 1 -sticky w
	grid $this.lbelev -row 4 -column 1 -sticky w
	grid $this.ptext -row 5 -column 0 -sticky w -columnspan 2
	grid $this.pcode -row 6 -column 1 -sticky w -columnspan 2
	grid $this.lplay -row 7 -column 1 -sticky w
	grid $this.dxfpnt -row 8 -column 0 -sticky w -columnspan 2
	grid $this.p3d -row 9 -column 0 -sticky w -columnspan 2

	entry $this.bname -textvariable bname -width 10
	entry $this.battr -textvariable battr -width 10
	entry $this.bcode -textvariable bcode -width 10
	entry $this.belev -textvariable belev -width 10
	entry $this.pnlay -textvariable pnlay -width 10

	grid $this.bname -row 1 -column 2 -sticky w
	grid $this.battr -row 2 -column 2 -sticky w
	grid $this.bcode -row 3 -column 2 -sticky w
	grid $this.belev -row 4 -column 2 -sticky w
	grid $this.pnlay -row 7 -column 2 -sticky w

	button $this.blocklist -text $geoEasyMsg(blocklist) \
		-command "dxfblocks {$geoEasyMsg(blocklist)}"
	button $this.attrlist -text $geoEasyMsg(attrlist) \
		-command "dxfattrs {$geoEasyMsg(attrlist)} PNUM"
	button $this.codelist -text $geoEasyMsg(attrlist) \
		-command "dxfattrs {$geoEasyMsg(attrlist)} CODE"
	button $this.elevlist -text $geoEasyMsg(attrlist) \
		-command "dxfattrs {$geoEasyMsg(attrlist)} ELEV"
	button $this.layerlist -text $geoEasyMsg(layerlist) \
		-command "dxflayers {$geoEasyMsg(layerlist)}"
	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"
	grid $this.blocklist -row 1 -column 3
	grid $this.attrlist -row 2 -column 3
	grid $this.codelist -row 3 -column 3
	grid $this.elevlist -row 4 -column 3
	grid $this.layerlist -row 7 -column 3
	grid $this.exit -row 10 -column 0
	grid $this.cancel -row 10 -column 1

	tkwait visibility $this
	CenterWnd $this
	grab set $this

	b_check $this $block
	t_check $this $ptext
}

#
#	Import points from  AutoCAD release 10..2000 DXF file
#	@param filen name of dxf file
proc GeoDXFin {filen} {
	global geoLoaded
	global buttonid

	DXFimport $filen
	tkwait window .dxfimp
	if {$buttonid} { return -999}
	return [DXFin $filen]
}

#
#	Import points & blocks from  AutoCAD release 10..2000 DXF file
#	@param fn
proc DXFin {fn} {

	global bname battr bcode belev pnlay p3d pcodelayer block ptext dxfpnt
	global geoEasyMsg

	set fa [GeoSetName $fn]
	if {[string length $fa] == 0} {return 1}
	global ${fa}_geo ${fa}_coo ${fa}_ref ${fa}_par
	
	if {[catch {set f [open $fn "r"]}] != 0} {
		Beep
		return -1
	}
	set counter 0	;# automatic point counter/name
	set code ""
	set value ""
	set bname [string toupper $bname]
	set src 0
	set ${fa}_par [list [list 0 "DXF import"]]
	# skip headers till ENTITIES
	while {! [eof $f] && \
			($code != 2 || [string toupper $value] != "ENTITIES")} {
		set code [gets $f]
		set value [gets $f]
		incr src 2
	}
	set entity ""
	set subentity ""
	set layer ""
	set pcode ""
	set blk ""
	set psz ""
	set x ""
	set y ""
	set z ""
	if {$pcodelayer} {
		set pattern "^$pnlay.*"
	} else {
		set pattern "^$pnlay$"
	}
	while {! [eof $f]} {
		incr src
		set code [string trim [gets $f]]
		incr src
		set value [string trim [gets $f]]
		incr src
		switch -exact $code {
			0 { if {$value == "ATTRIB" || $value == "SEQEND" || \
						$value == "VERTEX"} {
					set subentity [string toupper $value]
					continue
				}
				# store previous entity if layer/block and point number ok
				set obuf ""
				if {$ptext && [regexp -nocase $pattern $layer] && \
						$entity == "TEXT"} {
					regsub -nocase "^${pnlay}(.*)" $layer \\1 pcode
				} elseif {($block && $blk == $bname && $entity == "INSERT")} {
					if {[string length $psz] == 0} {
						incr counter
						set psz $counter
					}
					if {[string length $pcode] == 0} {
						set pcode $layer	;# pcode from layer name
					}
				} elseif {$dxfpnt && $entity == "POINT"} {
					incr counter
					set psz $counter
				}
				if {[string length $psz]} {
					lappend obuf [list 5 $psz]
					if {[string length $pcode] > 0} {
						lappend obuf [list 4 $pcode]
					}
					lappend obuf [list 38 $x]
					lappend obuf [list 37 $y]
					if {$p3d} { lappend obuf [list 39 $z] }
					if {[lsearch -exact [array names ${fa}_coo] $psz] != -1} {
						tk_dialog .msg $geoEasyMsg(warning) \
							"$geoEasyMsg(dblPn): $psz" warning 0 OK
					} else {
						set ${fa}_coo($psz) $obuf
					}
				}
				
				set layer ""
				set blk ""
				set psz ""
				set pcode ""
				set x ""
				set y ""
				set z ""
				set entity [string toupper $value]
				set subentity ""
			}
			1 { if {$ptext && $entity == "TEXT" && \
					[regexp -nocase $pattern $layer]} {
					set psz [string trim $value]
				}
				if {$block && $subentity == "ATTRIB" && $blk == $bname} {
					set attr [string trim $value]
				}
			}
			2 { if {$entity == "INSERT"} {
					if {[string length $subentity] == 0} {
						set blk [string toupper $value]
					} elseif {[string toupper $value] == $battr} {
						set psz [string trim $attr]
					} elseif {[string toupper $value] == $bcode} {
						set pcode [string trim $attr]
					} elseif {[string toupper $value] == $belev} {
						set z [string trim $attr]
					}
				}
			}
			8 { if {[string length $subentity] == 0} {
					set layer [string trim [string toupper $value]]
				}
			}
			10 { if {($entity == "TEXT" || $entity == "INSERT" || \
						$entity == "POINT") && \
						[string length $subentity] == 0} {
					set x $value ;#[format "%.4f" $value]
				}
			}
			20 { if {($entity == "TEXT" || $entity == "INSERT" || \
						$entity == "POINT") && \
						[string length $subentity] == 0} {
					set y $value ;#[format "%.4f" $value]
				}
			}
			30 { if {($entity == "TEXT" || $entity == "INSERT" || \
						$entity == "POINT") && \
						[string length $subentity] == 0} {
					set z $value ;#[format "%.4f" $value]
				}
			}
		}
	}
	close $f
	return 0
}

#
#	Create SVG file
#	@param fn file name
proc SVGout {fn} {
	global geoLoaded geoEasyMsg tinLoaded
    global contourInterval contourDxf contourLayer contour3Dface
	global regLineStart regLineCont regLineEnd regLine regLineClose

	if {[catch {set fd [open $fn w]} msg]} {
		tk_dialog .msg $geoEasyMsg(error) "$geoEasyMsg(-1): $msg" \
			error 0 OK
		return
	}
	set p_list [GetAll]						;# all point names
	# generate MBR
	set xmin ""; set ymin ""; set xmax ""; set ymax ""
	if {[string length $tinLoaded]} {
		set minmax [DtmStat 0]
		set xmin [lindex $minmax 0]
		set ymin [lindex $minmax 1]
		set xmax [lindex $minmax 3]
		set ymax [lindex $minmax 4]
	}
	foreach p $p_list {
		set c [GetCoord $p {37 38}]
		set x [GetVal 37 $c]
		set y [GetVal 38 $c]
		if {$x != "" && ($x < $xmin || $xmin == "")} {
			set xmin $x
		}
		if {$y != "" && ($y < $ymin || $ymin == "")} {
			set ymin $y
		}
		if {$x != "" && ($x > $xmax || $xmax == "")} {
			set xmax $x
		}
		if {$y != "" && ($y > $ymax || $ymax == "")} {
			set ymax $y
		}
	}
	set dx [expr {$xmax - $xmin}]
	set dy [expr {$ymax - $ymin}]
	set xmin [expr {$xmin - $dx / 10}]
	set ymin [expr {$ymin - $dy / 10}]
	set xmax [expr {$xmax + $dx / 10}]
	set ymax [expr {$ymax + $dy / 10}]
	set dx [expr {$xmax - $xmin}]
	set dy [expr {$ymax - $ymin}]
	set svgmax 1000
	set scax [expr {$svgmax / $dx}]
	set scay [expr {$svgmax / $dy}]
	if {$scax < $scay} {
		set sca $scax
	} else {
		set sca $scay
	}
	set svg_x [expr {int(ceil($sca * $dx))}]
	set svg_y [expr {int(ceil($sca * $dy))}]
	puts $fd "<?xml version='1.0' encoding='utf-8' standalone='no'?>"
	puts $fd "<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>"

	puts $fd "<svg width=\"$svg_y\" height=\"$svg_x\">"
	set lineno 0
	foreach pn $p_list {
		set buf [GetCoord $pn {38 37}]
		if {[string length $buf]} {
			set x [expr {int(floor(($xmax - [GetVal 37 $buf]) * $sca + 0.5))}]
			set y [expr {int(floor(([GetVal 38 $buf] - $ymin) * $sca + 0.5))}]
			puts $fd "<circle cx='$y' cy='$x' r='1' stroke='black' stroke-width='1' fill='red' />"
			puts $fd "<text font-family='sans-serif' x='$y' y='$x' font-size='10'>$pn</text>"
			incr lineno
		}
	}
	# draw contours
	#TContour "" 1 $fd
	puts $fd "</svg>"
	close $fd
}


#
#	very-very simple SVG output points & ids
proc GeoSVG {} {
	global svgTypes lastDir
	set filen [string trim [tk_getSaveFile -filetypes $svgTypes \
		-defaultextension ".svg" -initialdir $lastDir]]
	if {[string length $filen] && [string match "after#*" $filen] == 0} {
		set lastDir [file dirname $filen]
		SVGout $filen
	}
}
