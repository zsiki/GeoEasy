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

#	Calculate transformation coefficient between two horizontal coordinate systems.
#	One of the loaded data set is he source for the transformation,
#	The target coordinate system is loaded for the transformation.
#	@param sourc name of geo data set to transform (optional)
proc GeoTran {{sourc ""}} {
	global geoLoaded geoLoadedDir
	global geoEasyMsg
	global fileTypes
	global lastDir
	global tranType trTypes tr2Types tranSave parSave
	global decimals
	
	if {! [info exists tranSave]} { set tranSave 0 }
	if {! [info exists tranType]} { set tranType 0 }
	if {! [info exists parSave]} { set parSave 0 }
	if {([info exists geoLoaded] == 0) || ([llength $geoLoaded] == 0)} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(-8) warning 0 OK
		return
	}
	# select source geo data set (co-ordinate system) if no parameter
	if {$sourc == ""} {
		if {[llength $geoLoaded] == 1} {
			set sourc [lindex $geoLoaded 0]
		} else { 
			set sourc [GeoListbox $geoLoaded 0 $geoEasyMsg(fromCS) 1]
			if {[llength $sourc] != 1} { return }
		}
	}
	# select target geo data set (co-ordinate system)
	set typ [list [lindex $fileTypes [lsearch -glob $fileTypes "*.geo*"]]]
	set targetFile [string trim [tk_getOpenFile -filetypes $typ \
		-title $geoEasyMsg(toCS) -initialdir $lastDir]]
	if {[string length $targetFile] == 0 || \
		[string match "after#*" $targetFile]} { return }
	set lastDir [file dirname $targetFile]
	set target [GeoSetID]
	if {[lsearch -exact $geoLoadedDir $targetFile] != -1} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(-2) warning 0 OK
		return
	}
	# load target geo data set
	set res [LoadGeo $targetFile $target]
	if {$res != 0} {	;# error loading
		UnloadGeo $target
		if {$res < 0} {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg($res) warning 0 OK
		} else {
			geo_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(-5) $res" \
				warning 0 OK
		}
		return
	}
	upvar #0 ${sourc}_coo sourceCoo 
	upvar #0 ${target}_coo targetCoo 
	# collect common points from the two geo data sets
	# select common points having horizontal coordinates
	set commonPn ""
	foreach pn [lsort -dictionary [array names sourceCoo]] {
		if {[info exists targetCoo($pn)] == 1 && \
			[GetVal {37} $sourceCoo($pn)] != "" && \
			[GetVal {38} $sourceCoo($pn)] != "" && \
			[GetVal {37} $targetCoo($pn)] != "" && \
			[GetVal {38} $targetCoo($pn)] != ""} {
			lappend commonPn $pn
		}
	}
	if {[llength $commonPn] < 2} {
		geo_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(fewPoints) $res" \
			warning 0 OK
	} else {
		# open dialog to select control points for transformation &
		# type of transfoormation
		set plist [GeoListbox $commonPn 0 $geoEasyMsg(pnttitle) -2]
		if {[llength $plist] > 0} {
			set type [TranParam [llength $plist]]
			if {$type >= 0} {
				GeoLog1
				switch -exact -- $type {
				0 {
					set par [Helmert4 ${sourc}_coo ${target}_coo $plist]
					set formX "expr [lindex $par 0] + [lindex $par 2] * \$x - \
						[lindex $par 3] * \$y"
					set formY "expr [lindex $par 1] + [lindex $par 3] * \$x + \
						[lindex $par 2] * \$y"
					# start output to log window
					GeoLog "$geoEasyMsg(typeHelmert4) [GetShortName $sourc] -> [GeoSetName $targetFile]"
					GeoLog1 [format $geoEasyMsg(formulaH4y) \
						[format "%.${decimals}f" [lindex $par 0]] \
						[lindex $par 2] [lindex $par 3]]
					GeoLog1 [format $geoEasyMsg(formulaH4x) \
						[format "%.${decimals}f" [lindex $par 1]] \
						[lindex $par 3] [lindex $par 2]]
					# print scale & rotation
					GeoLog1
					GeoLog1 [format $geoEasyMsg(scaleRot) \
						[expr {sqrt([lindex $par 2] * [lindex $par 2] + \
							[lindex $par 3] * [lindex $par 3])}] \
						[ANG [expr {atan2([lindex $par 3], [lindex $par 2])}]]]
				}
				1 {
					set par [Helmert3 ${sourc}_coo ${target}_coo $plist]
					set ca [expr {cos([lindex $par 2])}]
					set sa [expr {sin([lindex $par 2])}]
					set formX "expr [lindex $par 0] + $ca * \$x - $sa * \$y"
					set formY "expr [lindex $par 1] + $sa * \$x + $ca * \$y"
					# start output to log window
					GeoLog "$geoEasyMsg(typeHelmert3) [GetShortName $sourc] -> [GeoSetName $targetFile]"
					GeoLog1 [format $geoEasyMsg(formulaH3y) \
						[format "%.${decimals}f" [lindex $par 0]] \
						$ca $sa]
					GeoLog1 [format $geoEasyMsg(formulaH3x) \
						[format "%.${decimals}f" [lindex $par 1]] \
						$sa $ca]
					# print scale & rotation
					GeoLog1
					GeoLog1 [format $geoEasyMsg(scaleRot) 1 \
						[ANG [lindex $par 2]]]
				}
				2 {
					set par [Affin ${sourc}_coo ${target}_coo $plist]
					set formX "expr [lindex $par 0] + [lindex $par 2] * \$x + \
						[lindex $par 3] * \$y"
					set formY "expr [lindex $par 1] + [lindex $par 4] * \$x + \
						[lindex $par 5] * \$y"
					# start output to log window
					GeoLog "$geoEasyMsg(typeAffin) [GetShortName $sourc] -> [GeoSetName $targetFile]"
					GeoLog1 [format $geoEasyMsg(formulaAfy) \
						[format "%.${decimals}f" [lindex $par 0]] \
						[lindex $par 2] [lindex $par 3]]
					GeoLog1 [format $geoEasyMsg(formulaAfx) \
						[format "%.${decimals}f" [lindex $par 1]] \
						[lindex $par 4] [lindex $par 5]]
				}
				3 {
					set par [Polytrans ${sourc}_coo ${target}_coo $plist 2]
					set avgx [lindex $par 12]
					set avgy [lindex $par 13]
					set avgX [lindex $par 14]
					set avgY [lindex $par 15]
					set formX "expr [lindex $par 0] + \
						[lindex $par 2] * (\$x - $avgx) + \
						[lindex $par 4] * pow(\$x - $avgx, 2) + \
						[lindex $par 6] * (\$y - $avgy) + \
						[lindex $par 8] * (\$x - $avgx) * (\$y - $avgy) + \
						[lindex $par 10] * pow(\$y - $avgy, 2) + \
						$avgX"
					set formY "expr [lindex $par 1] + \
						[lindex $par 3] * (\$x - $avgx) + \
						[lindex $par 5] * pow(\$x - $avgx, 2) + \
						[lindex $par 7] * (\$y - $avgy) + \
						[lindex $par 9] * (\$x - $avgx) * (\$y - $avgy) + \
						[lindex $par 11] * pow(\$y - $avgy, 2) + \
						$avgY"
					GeoLog "$geoEasyMsg(typePoly2) [GetShortName $sourc] -> [GeoSetName $targetFile]"
					GeoLog1 [format $geoEasyMsg(formulaP2) \
						[format "%.${decimals}f" $avgx] \
						[format "%.${decimals}f" $avgy]]
					GeoLog1 [format $geoEasyMsg(formulaP2y) \
						[format "%.${decimals}f" [expr {[lindex $par 0] + $avgX}]] \
						[lindex $par 2] [lindex $par 4] [lindex $par 6] \
						[lindex $par 8] [lindex $par 10]]
					GeoLog1 [format $geoEasyMsg(formulaP2x) \
						[format "%.${decimals}f" [expr {[lindex $par 1] + $avgY}]] \
						[lindex $par 3] [lindex $par 5] [lindex $par 7] \
						[lindex $par 9] [lindex $par 11]]
				}
				4 {
					set par [Polytrans ${sourc}_coo ${target}_coo $plist 3]
					set avgx [lindex $par 20]
					set avgy [lindex $par 21]
					set avgX [lindex $par 22]
					set avgY [lindex $par 23]
					set formX "expr [lindex $par 0] + \
						[lindex $par 2] * (\$x-$avgx) + \
						[lindex $par 4] * pow(\$x-$avgx, 2) + \
						[lindex $par 6] * pow(\$x-$avgx, 3) + \
						[lindex $par 8] * (\$y-$avgy) + \
						[lindex $par 10] * (\$x-$avgx) * (\$y-$avgy) + \
						[lindex $par 12] * pow(\$x-$avgx, 2) * (\$y-$avgy) + \
						[lindex $par 14] * pow(\$y-$avgy, 2) + \
						[lindex $par 16] * (\$x-$avgx) * pow(\$y-$avgy, 2) + \
						[lindex $par 18] * pow(\$y-$avgy, 3) + \
						$avgX"
					set formY "expr [lindex $par 1] + \
						[lindex $par 3] * (\$x-$avgx) + \
						[lindex $par 5] * pow(\$x-$avgx, 2) + \
						[lindex $par 7] * pow(\$x-$avgx, 3) + \
						[lindex $par 9] * (\$y-$avgy) + \
						[lindex $par 11] * (\$x-$avgx) * (\$y-$avgy) + \
						[lindex $par 13] * pow(\$x-$avgx, 2) * (\$y-$avgy) + \
						[lindex $par 15] * pow(\$y-$avgy, 2) + \
						[lindex $par 17] * (\$x-$avgx) * pow(\$y-$avgy, 2) + \
						[lindex $par 19] * pow(\$y-$avgy, 3) + \
						$avgY"
					GeoLog "$geoEasyMsg(typePoly3) [GetShortName $sourc] -> [GeoSetName $targetFile]"
					GeoLog1 [format $geoEasyMsg(formulaP2) \
						[format "%.${decimals}f" $avgx] \
						[format "%.${decimals}f" $avgy]]
					GeoLog1 [format $geoEasyMsg(formulaP3y) \
						[format "%.${decimals}f" [expr {[lindex $par 0] + $avgX}]] \
						[lindex $par 2] [lindex $par 4] [lindex $par 6] \
						[lindex $par 8] [lindex $par 10] [lindex $par 12] \
						[lindex $par 14] [lindex $par 16] [lindex $par 18]]
					GeoLog1 [format $geoEasyMsg(formulaP3x) \
						[format "%.${decimals}f" [expr {[lindex $par 1] + $avgY}]] \
						[lindex $par 3] [lindex $par 5] [lindex $par 7] \
						[lindex $par 9] [lindex $par 11] [lindex $par 13] \
						[lindex $par 15] [lindex $par 17] [lindex $par 19]]
				}
				}	;# switch
				# calculate corrections & write to log window
				GeoLog1
				GeoLog1 $geoEasyMsg(head1Tran)
				set sl2 0		;# summa (dx^2+dy^2)
				foreach p $plist {
					set fp $sourceCoo($p)
					set tp $targetCoo($p)
					set x [GetVal {38} $fp]
					set y [GetVal {37} $fp]
					set X [GetVal {38} $tp]
					set Y [GetVal {37} $tp]
					set X1 [eval $formX]
					set Y1 [eval $formY]
					set dx [expr {$X1 - $X}]
					set dy [expr {$Y1 - $Y}]
					set dl2 [expr {$dy * $dy + $dx * $dx}]
					set sl2 [expr {$sl2 + $dl2}]
					GeoLog1 [format "%-10s   %10.${decimals}f   %10.${decimals}f   %10.${decimals}f   %10.${decimals}f   %10.${decimals}f   %10.${decimals}f %10.${decimals}f" [GetVal {5} $fp] $x $y $X $Y $dx $dy [expr {sqrt($dl2)}]]
				}
				GeoLog1
				set RMS [expr {sqrt($sl2 / [llength $plist])}]
				GeoLog1 "RMS= [format %.3f $RMS]"

				# transform other points from source to target
				GeoLog1
				GeoLog1 $geoEasyMsg(head2Tran)
				foreach p [lsort -dictionary [array names sourceCoo]] {
					if {[lsearch -exact $plist $p] == -1 && \
						[GetVal {37 38} $sourceCoo($p)] != "" } {
						;# not used in transf & has coordinates
						set fp $sourceCoo($p)
						set x [GetVal {38} $fp]
						set y [GetVal {37} $fp]
						# copy source z if target not set
						set Z ""
						catch {set Z [GetVal {39} $targetCoo($pn)]}
						if {$Z == ""} {
							catch {set Z [GetVal {39} $fp]}
						}
						set X [eval $formX]
						set Y [eval $formY]
						GeoLog1 [format "%-10s   %10.${decimals}f   %10.${decimals}f   %10.${decimals}f   %10.${decimals}f" [GetVal {5} $fp] $x $y $X $Y]
						# save point if not present in target data set
						if {$tranSave && [lsearch -exact $plist $p] == -1} {
							AddCoo $target $p $X $Y $Z [GetPCode $p]
						}
					}
				}
				if {$tranSave} {
					set res [SaveGeo $target [file rootname $targetFile]]
					if {$res != 0} {
						geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg($res) \
							error 0 OK
					}
				}
				if {$parSave} {
					if {$type == 3 || $type == 4} {
						set fn [string trim [tk_getSaveFile \
							-initialdir $lastDir -filetypes $tr2Types \
							-title $geoEasyMsg(parSave) \
							-defaultextension ".all"]]
					} else {
						set fn [string trim [tk_getSaveFile \
							-initialdir $lastDir -filetypes $trTypes \
							-title $geoEasyMsg(parSave) \
							-defaultextension ".prm"]]
					}
					if {[catch {set f [open $fn "w"]}] == 0} {
						switch -exact $type {
							0 {	puts $f [lindex $par 0]
								puts $f [lindex $par 1]
								puts $f [lindex $par 2]
								puts $f [expr {-1 * [lindex $par 3]}]
								puts $f [lindex $par 3]
								puts $f [lindex $par 2]
							}
							1 {	puts $f [lindex $par 0]
								puts $f [lindex $par 1]
								puts $f $ca
								puts $f [expr {-1 * $sa}]
								puts $f $sa
								puts $f $ca
							}
							2 { puts $f [lindex $par 0]
								puts $f [lindex $par 1]
								puts $f [lindex $par 2]
								puts $f [lindex $par 3]
								puts $f [lindex $par 4]
								puts $f [lindex $par 5]
							}
							3 {
								puts $f "GeoEasy $geoEasyMsg(typePoly2) $sourc -> $target"
								puts $f ""
								puts $f "$avgx $avgy"
								puts $f "0 [expr {[lindex $par 0] + $avgX}] [expr {[lindex $par 1] + $avgY}]"
								puts $f "1 [lindex $par 2] [lindex $par 3]"
								puts $f "2 [lindex $par 6] [lindex $par 7]"
								puts $f "3 [lindex $par 4] [lindex $par 5]"
								puts $f "4 [lindex $par 8] [lindex $par 9]"
								puts $f "5 [lindex $par 10] [lindex $par 11]"
							}
							4 {
								puts $f "GeoEasy $geoEasyMsg(typePoly3) $sourc -> $target"
								puts $f ""
								puts $f "$avgx $avgy"
								puts $f "0 [expr {[lindex $par 0] + $avgX}] [expr {[lindex $par 1] + $avgY}]"
								puts $f "1 [lindex $par 2] [lindex $par 3]"
								puts $f "2 [lindex $par 8] [lindex $par 9]"
								puts $f "3 [lindex $par 4] [lindex $par 5]"
								puts $f "4 [lindex $par 10] [lindex $par 11]"
								puts $f "5 [lindex $par 14] [lindex $par 15]"
								puts $f "6 [lindex $par 6] [lindex $par 7]"
								puts $f "7 [lindex $par 12] [lindex $par 13]"
								puts $f "8 [lindex $par 16] [lindex $par 17]"
								puts $f "9 [lindex $par 18] [lindex $par 19]"
							}
						}
						catch {close $f}
					}
				}
			}
		}
	}
	# unload target geo data set
	global ${target}_geo ${target}_ref ${target}_coo ${target}_par
	#remove memory structures
	foreach a "${target}_geo ${target}_ref ${target}_coo ${target}_par" {
		catch "unset $a"
	}
}

#
#
#	Select transformation type
#	@param n number of usable points
#	@return transformation type (0 - Helmert4, 1 - Helmert3, 2 - Affin)
proc TranParam {n} {
	global geoEasyMsg
	global tranType tranSave parSave

	set w [focus]
	if {$w == ""} { set w "." }
	set this .trandia
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}
	if {! [info exists tranType] || $tranType == -1} {set tranType 0}

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(typetitle)
	wm protocol $this WM_DELETE_WINDOW {global tranType; set tranType -1; destroy $this}
	wm protocol $this WM_SAVE_YOURSELF {global tranType; set tranType -1; destroy $this}
	wm transient $this $w
	catch {wm attribute $this -topmost}

	radiobutton $this.helmert4 -text $geoEasyMsg(typeHelmert4) \
		-variable tranType -relief flat -value 0
	radiobutton $this.helmert3 -text $geoEasyMsg(typeHelmert3) \
		-variable tranType -relief flat -value 1
	radiobutton $this.affin -text $geoEasyMsg(typeAffin) \
		-variable tranType -relief flat -value 2
	radiobutton $this.poly2 -text $geoEasyMsg(typePoly2) \
		-variable tranType -relief flat -value 3
	radiobutton $this.poly3 -text $geoEasyMsg(typePoly3) \
		-variable tranType -relief flat -value 4
	checkbutton $this.save -text $geoEasyMsg(trSave) \
		-variable tranSave
	checkbutton $this.savepar -text $geoEasyMsg(parSave) \
		-variable parSave
	button $this.exit -text $geoEasyMsg(ok) -command "destroy $this"
	button $this.cancel -text $geoEasyMsg(cancel) -command {set tranType -1; destroy .trandia}

	# disable affin if less then 3 points are used
	if {$n < 3} { $this.affin configure -state disabled }
	if {$n < 6} { $this.poly2 configure -state disabled }
	if {$n < 10} { $this.poly3 configure -state disabled }
	pack $this.helmert4 $this.helmert3 $this.affin \
		$this.poly2 $this.poly3 \
		$this.save $this.savepar -side top -anchor w
	pack $this.exit $this.cancel -side right
	tkwait visibility $this
	CenterWnd $this
	grab set $this
	tkwait window $this
	return $tranType
}

#
#	Calculate parameters of orthogonal transformation. Four parameters
#	scale, rotation and offset.
#	X = X0 + c * x - d * y
#	Y = Y0 + d * y + c * y
#	@param sourc geo data set name to transform from
#	@param destination geo data set name to transform to
#	@param plist list of pont names to use in calculation
#	@return the list of parameters {X0 Y0 c d}
proc Helmert4 {sourc destination plist} {
	upvar #0 $sourc src 
	upvar #0 $destination dest

	# calculate weight point in point list
	set xs 0	;# sum of source coordinates
	set ys 0
	set Xs 0	;# sum of destination coordinates
	set Ys 0
	foreach p $plist {
		set fp $src($p)
		set tp $dest($p)
		set xs [expr {$xs + [GetVal {38} $fp]}]
		set ys [expr {$ys + [GetVal {37} $fp]}]
		set Xs [expr {$Xs + [GetVal {38} $tp]}]
		set Ys [expr {$Ys + [GetVal {37} $tp]}]
	}
	set xw [expr {$xs / double([llength $plist])}]
	set yw [expr {$ys / double([llength $plist])}]
	set Xw [expr {$Xs / double([llength $plist])}]
	set Yw [expr {$Ys / double([llength $plist])}]

	set s1 0.0	;# sum of xi*Xi+yi*Yi
	set s2 0.0	;# sum of xi*Yi-yi*Xi
	set s3 0.0	;# sum of xi*xi+yi*yi
	foreach p $plist {
		set fp $src($p)
		set tp $dest($p)
		set x [expr {[GetVal {38} $fp] - $xw}]
		set y [expr {[GetVal {37} $fp] - $yw}]
		set X [expr {[GetVal {38} $tp] - $Xw}]
		set Y [expr {[GetVal {37} $tp] - $Yw}]
		set s1 [expr {$s1 + $x * $X + $y * $Y}]
		set s2 [expr {$s2 + $x * $Y - $y * $X}]
		set s3 [expr {$s3 + $x * $x + $y * $y}]
	}
	set c [expr {$s1 / $s3}]
	set d [expr {$s2 / $s3}]
	set X0 [expr {($Xs - $c * $xs + $d * $ys) / double([llength $plist])}]
	set Y0 [expr {($Ys - $c * $ys - $d * $xs) / double([llength $plist])}]
	return [list $X0 $Y0 $c $d]
}

#
#
#	Calculate parameters of affine transformation. Six parameters
#	X = X0 + a * x + b * y
#	Y = Y0 + c * x + d * y
#	@param sourc geo data set name to transform
#	@param destination geo data set name to trnasform to
#	@param plist list of pont names to use in calculation
#	@return the list of parameters {X0 Y0 a b c d}
proc Affin {sourc destination plist} {
	upvar #0 $sourc src
	upvar #0 $destination dest

	# calculate weight point in point list
	set xs 0	;# sum of source coordinates
	set ys 0
	set Xs 0	;# sum of destination coordinates
	set Ys 0
	foreach p $plist {
		set fp $src($p)
		set tp $dest($p)
		set xs [expr {$xs + [GetVal {38} $fp]}]
		set ys [expr {$ys + [GetVal {37} $fp]}]
		set Xs [expr {$Xs + [GetVal {38} $tp]}]
		set Ys [expr {$Ys + [GetVal {37} $tp]}]
	}
	set xw [expr {$xs / double([llength $plist])}]
	set yw [expr {$ys / double([llength $plist])}]
	set Xw [expr {$Xs / double([llength $plist])}]
	set Yw [expr {$Ys / double([llength $plist])}]

	set s1 0	;# sum of xi*xi
	set s2 0	;# sum of yi*yi
	set s3 0	;# sum of xi*yi
	set s4 0	;# sum of xi*Xi
	set s5 0	;# sum of yi*Xi
	set s6 0	;# sum of xi*Yi
	set s7 0	;# sum of yi*Yi
	foreach p $plist {
		set fp $src($p)
		set tp $dest($p)
		set x [expr {[GetVal {38} $fp] - $xw}]
		set y [expr {[GetVal {37} $fp] - $yw}]
		set X [expr {[GetVal {38} $tp] - $Xw}]
		set Y [expr {[GetVal {37} $tp] - $Yw}]
		set s1 [expr {$s1 + $x * $x}]
		set s2 [expr {$s2 + $y * $y}]
		set s3 [expr {$s3 + $x * $y}]
		set s4 [expr {$s4 + $x * $X}]
		set s5 [expr {$s5 + $y * $X}]
		set s6 [expr {$s6 + $x * $Y}]
		set s7 [expr {$s7 + $y * $Y}]
	}
	set w [expr {double($s1 * $s2 - $s3 * $s3)}]
	set a [expr {-($s5 * $s3 - $s4 * $s2) / $w}]
	set b [expr {-($s4 * $s3 - $s1 * $s5) / $w}]
	set c [expr {-($s7 * $s3 - $s6 * $s2) / $w}]
	set d [expr {-($s6 * $s3 - $s7 * $s1) / $w}]
	set X0 [expr {($Xs - $a * $xs - $b * $ys) / double([llength $plist])}]
	set Y0 [expr {($Ys - $c * $xs - $d * $ys) / double([llength $plist])}]
	return [list $X0 $Y0 $a $b $c $d]
}

#
#
#	Calculate parameters of orthogonal transformation. Three parameters
#	X = X0 + cos(alpha) * x - sin(alpha) * y
#	Y = Y0 + sin(alpha) * x + cos(alpha) * y
#	@param sourc geo data set name to transform
#	@param destination geo data set name to trnasform to
#	@param plist list of pont names to use in calculation
#	@return the list of parameters {X0 Y0 alpha}
proc Helmert3 {sourc destination plist} {
	upvar #0 $sourc src
	upvar #0 $destination dest

	# approximate values from Helmert4
	set appr [Helmert4 $sourc $destination $plist]
	set X0 [lindex $appr 0]
	set Y0 [lindex $appr 1]
	set alpha [expr {atan2([lindex $appr 3], [lindex $appr 2])}]
	# calculate sums
	set s1 0	;# -xi*sin(alpha) - yi*cos(alpha)
	set s2 0	;#  xi*cos(alpha) - yi*sin(alpha)
	set s3 0	;# (-xi*sin(alpha) - yi*cos(alpha))^2 + \
				;# ( xi*cos(alpha) - yi*sin(alpha))^2
	set s4 0	;# Xi - Xei
	set s5 0	;# Yi - Yei
	set s6 0	;# (-xi*sin(alpha) - yi*cos(alpha)) * (Xi-Xei) +
				;# ( xi*cos(alpha) - yi*sin(alpha)) * (Yi-Yei)
	
	foreach p $plist {
		set fp $src($p)
		set tp $dest($p)
		set x [GetVal {38} $fp]
		set y [GetVal {37} $fp]
		set X [GetVal {38} $tp]
		set Y [GetVal {37} $tp]
		set w1 [expr {-$x * sin($alpha) - $y * cos($alpha)}]
		set w2 [expr { $x * cos($alpha) - $y * sin($alpha)}]
		set s1 [expr {$s1 + $w1}]
		set s2 [expr {$s2 + $w2}]
		set s3 [expr {$s3 + $w1 * $w1 + $w2 * $w2}]
		
		set w3 [expr {$X - ($X0 + $x * cos($alpha) - $y * sin($alpha))}]
		set w4 [expr {$Y - ($Y0 + $x * sin($alpha) + $y * cos($alpha))}]
		set s4 [expr {$s4 + $w3}]
		set s5 [expr {$s5 + $w4}]
		set s6 [expr {$s6 + $w1 * $w3 + $w2 * $w4}]
	}
	# set matrix of normal equation
	set ata(0,0) [llength $plist]
	set ata(0,1) 0
	set ata(0,2) $s1
	set ata(1,0) 0
	set ata(1,1) [llength $plist]
	set ata(1,2) $s2
	set ata(2,0) $s1
	set ata(2,1) $s2
	set ata(2,2) $s3
	# set A*l
	set al(0) $s4
	set al(1) $s5
	set al(2) $s6
	# solve the normal equation
	GaussElimination ata al 3

	return [list [expr {$X0 + $al(0)}] [expr {$Y0 + $al(1)}] \
		[expr {$alpha + $al(2)}]]
}

#
#
#	Calculate parameters of polynomial (rubber sheet) transformation.
#	X = X0 + a1 * x + a2 * y + a3 * xy + a4 * x^2 + a5 * y^2 + ...
#	Y = Y0 + b1 * x + b2 * y + b3 * xy + b4 * x^2 + b5 * y^2 + ...
#	@param sourc geo data set name to transform
#	@param destination geo data set name to trnasform to
#	@param plist list of pont names to use in calculation
#	@param degree
#	@return the list of parameters X0 Y0 a1 b1 a2 b2 a3 b3 ...
#		and the weight point coordinates in source and target system
proc Polytrans {sourc destination plist {degree 3}} {
	upvar #0 $sourc src
	upvar #0 $destination dest

	# set up A matrix (a1 for x, a2 for y)
	set n [llength $plist]	;# number of points
	set m [expr {($degree + 1) * ($degree + 2) / 2}]	;# number of unknowns
	# calculate average x and y to reduce rounding errors
	set s1 0
	set s2 0
	set S1 0
	set S2 0
	foreach p $plist {
		set fp $src($p)
		set tp $dest($p)
		set x [GetVal {38} $fp]
		set y [GetVal {37} $fp]
		set s1 [expr {$s1 + $x}]
		set s2 [expr {$s2 + $y}]
		set X [GetVal {38} $tp]
		set Y [GetVal {37} $tp]
		set S1 [expr {$S1 + $X}]
		set S2 [expr {$S2 + $Y}]
	}
	set avgx [expr {$s1 / $n}]
	set avgy [expr {$s2 / $n}]
	set avgX [expr {$S1 / $n}]
	set avgY [expr {$S2 / $n}]
	set i 0
	foreach p $plist {
		set fp $src($p)
		set tp $dest($p)
		set x [expr {[GetVal {38} $fp] - $avgx}]
		set y [expr {[GetVal {37} $fp] - $avgy}]
		set X [expr {[GetVal {38} $tp] - $avgX}]
		set Y [expr {[GetVal {37} $tp] - $avgY}]
		set l 0
		for {set j 0} {$j <= $degree} {incr j} {
			for {set k 0} {$k <= $degree} {incr k} {
				if {[expr {$j + $k}] <= $degree} {
					set a1($i,$l) [expr {pow($x,$k) * pow($y,$j)}]
					set a2($i,$l) [expr {pow($x,$k) * pow($y,$j)}]
					incr l
				}
			}
		}
		set l1($i) $X
		set l2($i) $Y
		incr i
	}
	# set matrix of normal equation
	# N1 = a1T*a1, N2 = a2T * a2, n1 = a1T * l1, n2 = a2T * l2
	for {set i 0} {$i < $m} {incr i} {
		for {set j $i} {$j < $m} {incr j} {
			set s1 0
			set s2 0
			for {set k 0} {$k < $n} {incr k} {
				set s1 [expr {$s1 + $a1($k,$i) * $a1($k,$j)}]
				set s2 [expr {$s2 + $a2($k,$i) * $a2($k,$j)}]
			}
			set N1($i,$j) $s1
			set N1($j,$i) $s1
			set N2($i,$j) $s2
			set N2($j,$i) $s2
		}
	}
	for {set i 0} {$i < $m} {incr i} {
		set s1 0
		set s2 0
		for {set k 0} {$k < $n} {incr k} {
			set s1 [expr {$s1 + $a1($k,$i) * $l1($k)}]
			set s2 [expr {$s2 + $a2($k,$i) * $l2($k)}]
		}
		set n1($i) $s1
		set n2($i) $s2
	}
	# solve the normal equation
	GaussElimination N1 n1 $m
	GaussElimination N2 n2 $m
	set res ""
	for {set i 0} {$i < $m} {incr i} {
		set l 0
		lappend res $n1($i) $n2($i)
	}
	lappend res $avgx $avgy $avgX $avgY
	return $res
}

#
#
#	Select transformation params
#	@return -1/0 Cancel/Ok
proc TranHParam {} {
	global geoEasyMsg
	global tranType tranSave parSave

	set w [focus]
	if {$w == ""} { set w "." }
	set this .tranhdia
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}

	if {! [info exists tranType] || $tranType == -1} {set tranType 0}
	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(typetitle)
	wm protocol $this WM_DELETE_WINDOW {global tranType; set tranType -1; destroy $this}
	wm protocol $this WM_SAVE_YOURSELF {global tranType; set tranType -1; destroy $this}
	wm transient $this $w
	catch {wm attribute $this -topmost}

	checkbutton $this.save -text $geoEasyMsg(trSave) \
		-variable tranSave
	checkbutton $this.savepar -text $geoEasyMsg(parSave) \
		-variable parSave
	button $this.exit -text $geoEasyMsg(ok) -command "destroy $this"
	button $this.cancel -text $geoEasyMsg(cancel) -command {set tranType -1; destroy .tranhdia}

	pack $this.save $this.savepar -side top -anchor w
	pack $this.exit $this.cancel -side right
	tkwait visibility $this
	CenterWnd $this
	grab set $this
	tkwait window $this
	return $tranType
}

#
#
#	Calculate transformation coefficient between two vertical systems.
#	One of the loaded data set is he source for the transformation,
#	The target coordinate system is loaded for the transformation.
#	@param sourc name of geo data set to transform (optional)
proc GeoHTran {{sourc ""}} {
	global geoLoaded geoLoadedDir
	global geoEasyMsg
	global fileTypes
	global lastDir
	global tranType trHTypes tranSave parSave
	global decimals
	
	if {! [info exists tranSave]} { set tranSave 0 }
	if {! [info exists parSave]} { set parSave 0 }
	if {([info exists geoLoaded] == 0) || ([llength $geoLoaded] == 0)} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(-8) warning 0 OK
		return
	}
	# select source geo data set (co-ordinate system) if no parameter
	if {$sourc == ""} {
		if {[llength $geoLoaded] == 1} {
			set sourc [lindex $geoLoaded 0]
		} else { 
			set sourc [GeoListbox $geoLoaded 0 $geoEasyMsg(fromCS) 1]
			if {[llength $sourc] != 1} { return }
		}
	}
	# select target geo data set (co-ordinate system)
	set typ [list [lindex $fileTypes [lsearch -glob $fileTypes "*.geo*"]]]
	set targetFile [string trim \
		[tk_getOpenFile -filetypes $typ -title $geoEasyMsg(toCS) \
			-initialdir $lastDir]]
	if {[string length $targetFile] == 0 || \
		[string match "after#*" $targetFile]} { return }
	set lastDir [file dirname $targetFile]
	set target [GeoSetID]
	if {[lsearch -exact $geoLoadedDir $targetFile] != -1} {
		geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(-2) warning 0 OK
		return
	}
	# load target geo data set
	set res [LoadGeo $targetFile $target]
	if {$res != 0} {	;# error loading
		UnloadGeo $target
		if {$res < 0} {
			geo_dialog .msg $geoEasyMsg(warning) $geoEasyMsg($res) warning 0 OK
		} else {
			geo_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(-5) $res" \
				warning 0 OK
		}
		return
	}
	upvar #0 ${sourc}_coo sourceCoo 
	upvar #0 ${target}_coo targetCoo 
	# collect common points from the two geo data sets
	# select common points having elevations
	set commonPn ""
	foreach pn [lsort -dictionary [array names sourceCoo]] {
		if {[info exists targetCoo($pn)] == 1 && \
			[GetVal {39} $sourceCoo($pn)] != "" && \
			[GetVal {39} $targetCoo($pn)] != ""} {
			lappend commonPn $pn
		}
	}
	if {[llength $commonPn] < 1} {
		geo_dialog .msg $geoEasyMsg(warning) "$geoEasyMsg(fewPoints) $res" \
			warning 0 OK
	} else {
		# open dialog to select control points for transformation &
		# type of transformation
		set plist [GeoListbox $commonPn 0 $geoEasyMsg(pnttitle) -1]
		if {[llength $plist] > 0} {
			set type [TranHParam]
			if {$type == -1} { return }
			# calculate corrections & write to log window
			set sum_src 0		;# sum elevations
			set sum_dst 0
			foreach p $plist {
				set fp $sourceCoo($p)
				set tp $targetCoo($p)
				set z [GetVal {39} $fp]
				set Z [GetVal {39} $tp]
				set sum_src [expr {$sum_src + $z}]
				set sum_dst [expr {$sum_dst + $Z}]
			}
			GeoLog "$geoEasyMsg(menuCalHTran) $sourc -> $target"
			GeoLog1
			GeoLog1 $geoEasyMsg(head1HTran)
			set agv_src [expr {$sum_src / [llength $plist]}]
			set agv_dst [expr {$sum_dst / [llength $plist]}]
			set dz [expr {$agv_dst - $agv_src}]
			set sl2 0
			GeoLog1 [format $geoEasyMsg(formula1D) \
				[format "%.${decimals}f" $dz]]
			foreach p $plist {
				set fp $sourceCoo($p)
				set tp $targetCoo($p)
				set z [GetVal {39} $fp]
				set Z [GetVal {39} $tp]
				set d [expr {$z + $dz - $Z}]
				GeoLog1 [format "%-10s   %10.${decimals}f   %10.${decimals}f   %10.${decimals}f" [GetVal {5} $fp] $z $Z $d]
				set sl2 [expr {$sl2 + pow($d, 2)}]
			}
			set RMS [expr {sqrt($sl2 / [llength $plist])}]
			GeoLog1 "RMS= [format %.3f $RMS]"

			# transform other points from source to target
			GeoLog1
			GeoLog1 $geoEasyMsg(head2HTran)
			foreach p [lsort -dictionary [array names sourceCoo]] {
				if {[lsearch -exact $plist $p] == -1 && \
					[GetVal {39} $sourceCoo($p)] != "" } {
					;# not used in transf & has coordinates
					set fp $sourceCoo($p)
					set x [GetVal {38} $fp]
					set y [GetVal {37} $fp]
					# copy source source north, east if target not set
					set X ""
					set Y ""
					catch {set X [GetVal {38} $targetCoo($pn)]}
					catch {set Y [GetVal {37} $targetCoo($pn)]}
					if {$Y == "" && $X == ""} {
						catch {set X [GetVal {38} $fp]}
						catch {set Y [GetVal {37} $fp]}
					}
					set z [GetVal {39} $fp]
					set Z [expr {$z + $dz}]
					GeoLog1 [format "%-10s   %10.${decimals}f   %10.${decimals}f" [GetVal {5} $fp] $z $Z]
					# save point if not present in target data set
					if {$tranSave && [lsearch -exact $plist $p] == -1} {
						AddCoo $target $p $X $Y $Z [GetPCode $p]
					}
				}
			}
			if {$tranSave} {
				set res [SaveGeo $target [file rootname $targetFile]]
				if {$res != 0} {
					geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg($res) \
						error 0 OK
				}
			}
			if {$parSave} {
				set fn [string trim [tk_getSaveFile -initialdir $lastDir \
					-filetypes $trHTypes -title $geoEasyMsg(parSave) \
					-defaultextension ".vsh"]]
				set f [open $fn "w"]
				puts $f $dz
				close $f
			}
		}
	}
	# unload target geo data set
	global ${target}_geo ${target}_ref ${target}_coo ${target}_par
	#remove memory structures
	foreach a "${target}_geo ${target}_ref ${target}_coo ${target}_par" {
		catch "unset $a"
	}
}
