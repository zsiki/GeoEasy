#//#
# DTM module
#
#	Data structures
#		newtin_poly	- loaded or manually created break lines, list	
#			{{Y X Z geo pontszam} {Y X Z geo pontszam}} for geo points
#			{{Y X Z dtm pontszam} {Y X Z dtm pontszam}} for dtm points
#		newtin_hole - loaded or manually created hole points, list
#			{Y X}
#		dtm_node - loaded dtm points, array
#			dtm_node(id) {Y X Z}  id 0..n
#		dtm_ele - loaded dtm triangles, array
#			dtm_ele(id) {point1_id point2_id point2_id}
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

# Compare to lists of three elements
proc pcmp {a b} {
	if {[lindex $a 0] > [lindex $b 0]} { return 1 }
	if {[lindex $a 0] < [lindex $b 0]} { return -1 }
	if {[lindex $a 1] > [lindex $b 1]} { return 1 }
	if {[lindex $a 1] < [lindex $b 1]} { return -1 }
	if {[lindex $a 2] > [lindex $b 2]} { return 1 }
	if {[lindex $a 2] < [lindex $b 2]} { return -1 }
	return 0
}

#
#	Set tin parameters throught dialog box
proc CreateTinDia {win} {
	global geoEasyMsg
	global buttonid
	global polyTypes tinTypes
	global lastDir
	global dtmsource dtmdetail
	global dtmhoriz dtmconvex
	global dtm_pointlayer dtm_polylayer dtm_holelayer
	global autoRefresh
	global newtin_poly newtin_hole
	global tmp
	global tinLoaded tinPath tinChanged
	global cadTypes

	set tmp ""
	set w [focus]
	if {$w == ""} {set w "."}
	
	if {[string length $tinLoaded]} {
		if {[tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(regenDtm) warning 0 OK $geoEasyMsg(cancel)] == 1} {
			return
		}
	}
	set this .tindia
	set buttonid -1
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}
	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(tinpar)
	wm resizable $this 0 0
	wm transient $this $w
	catch {wm attribute $this -topmost}
	
	set dtmsource gepoints
	set dtmdetail 0
	set dtmhoriz 0
	set dtmconvex 1
	radiobutton $this.gepoints -text $geoEasyMsg(gepoints) \
		-variable dtmsource -value gepoints
	checkbutton $this.detail -text $geoEasyMsg(pd) -variable dtmdetail
	radiobutton $this.dxffile -text $geoEasyMsg(dxffile) \
		-variable dtmsource -value dxffile
	label $this.lplay -text $geoEasyMsg(dxfpoint)
	entry $this.play -textvariable dtm_pointlayer -width 30
	button $this.pntlayerlist -text $geoEasyMsg(layerlist) \
		-command "sellayer {$geoEasyMsg(layerlist)} dtm_pointlayer"
	label $this.lblay -text $geoEasyMsg(dxfbreak)
	entry $this.blay -textvariable dtm_polylayer -width 30
	button $this.polylayerlist -text $geoEasyMsg(layerlist) \
		-command "sellayer {$geoEasyMsg(layerlist)} dtm_polylayer"
	label $this.lhlay -text $geoEasyMsg(dxfhole)
	entry $this.hlay -textvariable dtm_holelayer -width 30
	button $this.holelayerlist -text $geoEasyMsg(layerlist) \
		-command "sellayer {$geoEasyMsg(layerlist)} dtm_holelayer"
	radiobutton $this.asciifile -text $geoEasyMsg(asciifile) \
		-variable dtmsource -value asciifile
	#checkbutton $this.horiz -text $geoEasyMsg(horiz) -variable dtmhoriz
	checkbutton $this.convex -text $geoEasyMsg(convex) -variable dtmconvex
	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"
	
	grid $this.gepoints -row 0 -column 0 -columnspan 3 -sticky w
	grid $this.detail -row 1 -column 1 -columnspan 2 -sticky w
	grid $this.dxffile -row 2 -column 0 -columnspan 3 -sticky w
	grid $this.lplay -row 3 -column 1 -sticky w
	grid $this.play -row 3 -column 2 -sticky w
	grid $this.pntlayerlist -row 3 -column 3 -sticky w
	grid $this.lblay -row 4 -column 1 -sticky w
	grid $this.blay -row 4 -column 2 -sticky w
	grid $this.polylayerlist -row 4 -column 3 -sticky w
	grid $this.lhlay -row 5 -column 1 -sticky w
	grid $this.hlay -row 5 -column 2 -sticky w
	grid $this.holelayerlist -row 5 -column 3 -sticky w
#	grid $this.asciifile -row 6 -column 0 -columnspan 3 -sticky w
#	grid $this.horiz -row 7 -column 0 -columnspan 3 -sticky w
	grid $this.convex -row 8 -column 0 -columnspan 3 -sticky w
	grid $this.exit -row 9 -column 0
	grid $this.cancel -row 9 -column 1
	tkwait visibility $this
	CenterWnd $this
	grab set $this

	tkwait window .tindia
	if {$buttonid == 0} {
		set target [string trim [tk_getSaveFile -defaultextension ".dtm" \
			-filetypes $tinTypes -initialdir $lastDir]]
		if {[string length $target] == 0 || [string match "after#*" $target]} {
			return
		}
		set lastDir [file dirname $target]
		
		switch -exact -- $dtmsource {
			gepoints {
				if {$dtmdetail} {
					# get details with x y & z coordinates
					set plist [GetGivenDetail {37 38 39}]
				} else {
					# get all known points with x y & z coordinates
					set plist [GetGiven {37 38 39}]
				}
				if {[llength $plist] < 3 && [string length $tinLoaded] == 0} {
					tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewmassp) \
						error 0 OK
					return
				}
				# write nodes to file
				set poly [file join [file dirname $target] tmp.poly]
				set f [open $poly w]
				set n [llength $plist]
				if {[string length $tinLoaded]} {
					global ${tinLoaded}_node
					set m [array size ${tinLoaded}_node]
					incr n $m
				}
				puts $f "$n 2 1 0"	;# header for nodes
				set i 0
				foreach p $plist {
					set clist [GetCoord $p {37 38 39}]
					puts $f "$i [GetVal 38 $clist] [GetVal 37 $clist] [GetVal 39 $clist]"
					# build id and pn array
					set ids([GetVal 5 $clist]) $i
					incr i
				}
				# write dtm points for regenerate
				set j [array size ids]
				if {[string length $tinLoaded]} {
					foreach i [array names ${tinLoaded}_node] {
						set p [set ${tinLoaded}_node($i)]
						puts $f "$j [lindex $p 0] [lindex $p 1] [lindex $p 2]"
						set ids1($i) $j
						incr j
					}
				}
				# write breaklines
				# count number of lines
				set n [llength $newtin_poly]
				puts $f "$n 0"
				set i 0
				foreach pp $newtin_poly {
					if {[lindex [lindex $pp 0] 3] == "geo" && \
							! [info exists ids([lindex [lindex $pp 0] 4])]} {
						tk_dialog .msg "Hiba" "ciki alappont?!" error 0 OK
						continue
					}
					if {[lindex [lindex $pp 1] 3] == "geo" && \
							! [info exists ids([lindex [lindex $pp 1] 4])]} {
						tk_dialog .msg "Hiba" "ciki alappont?!" error 0 OK
						continue
					}
					if {[lindex [lindex $pp 0] 3] == "geo"} {
						set ide $ids([lindex [lindex $pp 0] 4])
					} else {
						set ide $ids1([lindex [lindex $pp 0] 4])
					}
					if {[lindex [lindex $pp 1] 3] == "geo"} {
						set id $ids([lindex [lindex $pp 1] 4])
					} else {
						set id $ids1([lindex [lindex $pp 1] 4])
					}
					puts $f "$i $ide $id 1"
					incr i
				}
				# write hole centers
				puts $f [llength $newtin_hole]
				set i 0
				foreach p $newtin_hole {
					puts $f "$i [lindex $p 0] [lindex $p 1]"
					incr i
				}
				close $f
			}
			dxffile {
				# select source file
				if {[info exists tmp] == 0 || $tmp == ""} {
					set dxfFile [string trim [tk_getOpenFile \
						-defaultextension ".dxf" \
						-filetypes $cadTypes -initialdir $lastDir]]
				} else {
					set dxfFile $tmp
				}
				if {[string length $dxfFile] == 0 || \
					[string match "after#*" $dxfFile]} { return }
				# get point, breaklines, hole markers from dxf
				if {[catch {set f [open $dxfFile r]}]} {
					tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(-1) \
						error 0 OK
					return
				}
				set lastDir [file dirname $dxfFile]
				# search for entity section
				set buf [string toupper [gets $f]]
				while {[string compare $buf "ENTITIES"] != 0} {
					set buf [string toupper [gets $f]]
				}
				# process entities
				set layer ""
				set entity ""
				set main ""		;# main entity for verteces
				set points ""
				set polys ""
				set holes ""
				set verteces ""
				set pflags 0
				set dtm_pointlayer [string toupper $dtm_pointlayer]
				set dtm_polylayer [string toupper $dtm_polylayer]
				set dtm_holelayer [string toupper $dtm_holelayer]
				while {! [eof $f]} {
					set code [string trim [string toupper [gets $f]]]
					set buf [string trim [string toupper [gets $f]]]
					switch -exact $code {
						0 {
							if {[string compare $entity "POINT"] == 0 && \
								[lsearch -exact $dtm_pointlayer $layer] != -1} {
								lappend points [list $x $y $z]	
							} elseif {[string compare $entity "POINT"] == 0 && \
								[lsearch -exact $dtm_holelayer $layer] != -1} {
								lappend holes [list $x $y]	
							} elseif {[string compare $entity "LINE"] == 0 && \
								[lsearch -exact $dtm_polylayer $layer] != -1} {
								lappend polys [list [list $x $y $z]	\
									[list $x1 $y1 $z1]]
								# add to points too
								lappend points [list $x $y $z]	
								lappend points [list $x1 $y1 $z1]	
							} elseif {[string compare $entity "LINE"] == 0 && \
								[lsearch -exact $dtm_pointlayer $layer] != -1} {
								# add to points
								lappend points [list $x $y $z]	
								lappend points [list $x1 $y1 $z1]	
							} elseif {[string compare $entity "VERTEX"] == 0 && \
								[lsearch -exact $dtm_polylayer $layer] != -1} {
								lappend verteces [list $x $y $z]	
								lappend points [list $x $y $z]	
							} elseif {[string compare $entity "VERTEX"] == 0 && \
								[lsearch -exact $dtm_pointlayer $layer] != -1} {
								lappend points [list $x $y $z]	
							} elseif {[string compare $entity "SEQEND"] == 0 && \
								[string compare $main "POLYLINE"] == 0 && \
								[llength $verteces] && \
								[lsearch -exact $dtm_polylayer $layer] != -1} {
								set j 0
								lappend points [lindex $verteces $j]
								for {set i 1} {$i < [llength $verteces]} \
										{incr i} {
									lappend points [lindex $verteces $i]	
									lappend polys [list \
										[lindex $verteces $j]	\
										[lindex $verteces $i]]
									incr j
								}
								if {$pflags & 1} {
									# closed polyline
									lappend polys [list \
										[lindex $verteces $j]	\
										[lindex $verteces 0]]
								}
								set verteces ""
								set main ""
								set pflags 0
							} elseif {[string compare $entity "LWPOLYLINE"] == 0 && \
								[llength $verteces] && \
								[lsearch -exact $dtm_polylayer $layer] != -1} {
								# add points and polys
								set j 0
								lappend points [lindex $verteces $j]
								for {set i 1} {$i < [llength $verteces]} \
										{incr i} {
									lappend points [lindex $verteces $i]	
									lappend polys [list \
										[lindex $verteces $j]	\
										[lindex $verteces $i]]
									incr j
								}
								if {$pflags & 1} {
									# closed polyline
									lappend polys [list \
										[lindex $verteces $j]	\
										[lindex $verteces 0]]
								}
								set verteces ""
								set main ""
								set pflags 0
							} elseif {[string compare $entity "LWPOLYLINE"] == 0 && \
								[llength $verteces] && \
								[lsearch -exact $dtm_pointlayer $layer] != -1} {
								# add points only
								for {set i 0} {$i < [llength $verteces]} \
										{incr i} {
									lappend points [lindex $verteces $i]	
								}
								set verteces ""
								set main ""
							}
							if {[string compare $buf "POLYLINE"] == 0} {
								set main $buf
							}
							set entity $buf
							if {[string compare $entity "SEQEND"] != 0 && \
								[string compare $entity "VERTEX"] != 0} {
								# in case of SEQEND & VERTEX keep layer of main
								set layer ""
							}
							set z 0		;# default height
							set z1 0
						}
						8 {
							# do not overwrite layer after SEQEND & VERTEX in polyline
							if {[string compare $entity "SEQEND"] != 0 && \
								[string compare $entity "VERTEX"]} {
								set layer $buf
							}
						}
						10 {
							set x [format "%.4f" $buf]
						}
						20 {
							set y [format "%.4f" $buf]
							if {[string compare $entity "LWPOLYLINE"] == 0} {
								lappend verteces [list $x $y $z]
							}
						}
						30 {
							set z [format "%.4f" $buf]
						}
						11 {
							set x1 [format "%.4f" $buf]
						}
						21 {
							set y1 [format "%.4f" $buf]
						}
						31 {
							set z1 [format "%.4f" $buf]
						}
						38 {
							# LWPOLYLINE elevation
							set z [format "%.4f" $buf]
						}
						70 {
							# POLYLINE FLAGS
							if {[string compare $entity "LWPOLYLINE"] == 0 || \
								[string compare $entity "POLYLINE"] == 0} {
								set pflags $buf
							}
						}
					}
				}
				close $f
				if {[llength $points] < 3 && [string length $tinLoaded] == 0} {
					tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewmassp) \
						error 0 OK
					return
				}
				# remove duplicated points
				set pointsw [lsort -decreasing -command pcmp $points]
				# check points with and without z, largest z is first (decreasing order)
				set lastx ""
				set lasty ""
				set lastz ""
				set points ""
				foreach point $pointsw {
					set x [lindex $point 0]
					set y [lindex $point 1]
					set z [lindex $point 2]
#GeoLog1 "$x $y $z"
					if {$x != $lastx || $y != $lasty} {
						# different x y from previous	
						lappend points $point
#						if {[expr {abs($z)}] < 0.2} {
#							GeoLog1 "Nulla magassagu pont $x $y $z"
#						}
#					} elseif {$z > 0} {
#						GeoLog1 "Eltero magassagok egy pontban $x $y"
#					} else {
#						GeoLog1 "Kihagyott pont $x $y $z"
					}
					set lastx $x
					set lasty $y
					set lastz $z
				}
				# replace poly coords with ids
				set poly_ids ""
				foreach poly $polys {
					set ids ""
					foreach p $poly {
						# check only x and y coords
						set id [lsearch -glob $points [list [lindex $p 0] [lindex $p 1] *]]
						if {$id != -1} {
							lappend ids $id
						} else {	;# new point
							lappend points $p
							lappend ids [llength $points]
						}
					}
					lappend poly_ids $ids
				}
				# write nodes to file
				set poly [file join [file dirname $target] tmp.poly]
				set f [open $poly w]
				puts $f "[llength $points] 2 1 0"	;# header for nodes
				set i 0
				foreach p $points {
					puts $f "$i $p"
					incr i
				}
				# write breaklines
				puts $f "[llength $poly_ids] 0"
				set i 0
				foreach ids $poly_ids {
					for {set j 1} {$j < [llength $ids]} {incr j} {
						set j1 [expr {$j - 1}]
						puts $f \
							"$i [lindex $ids $j1] [lindex $ids $j]"	
						incr i
					}
				}
				# write hole centers
				puts $f [llength $holes]
				set i 0
				foreach h $holes {
					puts $f "$i $h"
					incr i
				}
				close $f
			}
			asciifile {
				# select source file
				set poly [string trim [tk_getOpenFile \
					-defaultextension ".poly" \
					-filetypes $polyTypes -initialdir $lastDir]]
				if {[string length $poly] == 0 || [string match "after#*"]} {
					return
				}
				set lastDir [file dirname $poly]
			}
		}
		if {[catch {CreateTin $poly $target} msg] == 1} {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(tinfailed) $msg" error 0 OK
			return
		} else {
			LoadTin [file rootname $target]
			if {$autoRefresh} {
				GeoDrawAll
			}
		}
		# remove temperary file
		catch {file  delete [file join [file dirname $target] tmp.poly]}
	}
}

#
#	Generate a triangulated irregular network (TIN) from
#	masspoints, breaklines and boundaries
#	@param polyFile input data, masspoints, breaklines, etc
#	@param targetFile file name for the created dtm
proc CreateTin {polyFile targetFile} {
	global tcl_platform
	global geoEasyMsg
	global dtmhoriz dtmconvex
	global home
	global triangleProg

	set flags "-Q"
	if {$dtmhoriz} {append flags " -H"}
	if {$dtmconvex} {append flags " -c"}
	if {$tcl_platform(platform) != "unix"} {
		if {[catch {eval [concat exec "{${triangleProg}.exe} $flags \"$polyFile\""]} msg]} {
			tk_dialog .msg $geoEasyMsg(error) "$geoEasyMsg(creaDtm): $msg" \
				error 0 OK
			return
		}
	} else {
		regsub -all " " $polyFile "\\ " polyFile
		regsub -all " " $targetFile "\\ " targetFile
		if {[catch {eval [concat exec "{$triangleProg} $flags \"$polyFile\""]} msg]} {
			tk_dialog .msg $geoEasyMsg(error) "$geoEasyMsg(creaDtm): $msg" \
				error 0 OK
			return
		}
	}
	set src [file rootname $polyFile]
	set target [file rootname $targetFile]
	for {set i 0} {$i < 3} {incr i} {
		set ext [lindex {ele poly node} $i]
		set ext1 [lindex {dtm pol pnt} $i]
		if {[catch {file rename -force "${src}.1.${ext}" "${target}.${ext1}"} msg]} {
			tk_dialog .msg $geoEasyMsg(error) "$geoEasyMsg(tinfailed) $msg" \
				error 0 OK
			foreach ext {ele poly node} {
				catch {file delete -force ${src}.1.${ext}}
				catch {file delete -force ${target}.${ext}}
			}
			return
		}
	}
}

#
#	Select tin to load/append 
#	@param this 
#	@param add 0/1
proc LoadTinDia {this {add 0}} {
	global lastDir
	global tinTypes
	global tinLoaded tinPath tinChanged

	set tPath [string trim [tk_getOpenFile -filetypes $tinTypes \
		-initialdir $lastDir]]
	if {[string length $tPath] == 0 || [string match "after#*" $tPath]} {
		return
	}
	set lastDir [file dirname $tPath]
	if {[string length $tPath]} {
		if {$add} {
			set oldPath [file join $tinPath $tinLoaded]
			if  { $tinChanged } {
				SaveTin
			}
			AppendTin $tPath
			UnloadTin
			LoadTin $oldPath
		} else {
			set tPath [file rootname $tPath]
			LoadTin $tPath
		}
		GeoDraw $this
	}
}

#
#	Load a TIN into memory structures
#		Load ele and poly file
#			nodes and holes must be defined in poly file!
proc LoadTin {tp} {
	global tinLoaded tinPath tinChanged
	global contourInterval contourLayer
	global geoEasyMsg
	global newtin_poly newtin_hole

	if {[string length $tinLoaded]} {
		if {$tinChanged} {
			set a [tk_dialog .msg $geoEasyMsg(warning) \
				"$geoEasyMsg(saveDtm) $tinLoaded" \
				warning 0 $geoEasyMsg(yes) $geoEasyMsg(no) $geoEasyMsg(cancel)]
			switch -exact $a {
				0 {
					SaveTin
				}
				2 {
					return
				}
			}
		} else {
			if {[tk_dialog .msg $geoEasyMsg(warning) \
				"$geoEasyMsg(closDtm) $tinLoaded" \
				warning 0 $geoEasyMsg(yes) $geoEasyMsg(cancel)] == 1} {
				return
			}

		}
		UnloadTin
	}
	set newtin_poly ""	;# remove new elements
	set newtin_hole ""
	set contourInterval 0	;# no contours
	set contourLayer 0	;# no layer separation based on elevation in dxf
	set tinChanged 0
	set tinLoaded [file tail $tp]
	set tinPath [file dirname $tp]
	if {[LoadTinEle $tp] != 0 || \
			[LoadTinNodes $tp] != 0 || \
			[LoadTinPoly $tp] != 0} {
		tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(loadDtm) warning 0 OK
		UnloadTin
	}
	DtmMenuState
}

#
#	Save TIN to disk
proc SaveTin {} {
	global tinLoaded tinPath tinChanged
	global geoEasyMsg
	
	if {$tinLoaded == "" || $tinChanged == 0} {
		Beep
		return 
	}
	set path "$tinPath/$tinLoaded"
	if {[SaveTinEle $path] || \
		[SaveTinNodes $path] || \
		[SaveTinPoly $path]}	{
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(errsavedtm) \
			error 0 OK
	}
	set tinChanged 0
}

#
#	Unload a TIN from memory
proc UnloadTin {} {
	global geoEasyMsg
	global tinLoaded tinPath tinChanged
	global newtin_poly newtin_hole

	set newtin_poly ""
	set newtin_hole ""
	if {$tinLoaded == ""} { return }
	if {$tinChanged} {
		set a [tk_dialog .msg $geoEasyMsg(warning) \
			"$geoEasyMsg(saveit) $tinLoaded" \
			warning 0 $geoEasyMsg(yes) $geoEasyMsg(no) $geoEasyMsg(cancel)]
		switch -exact $a {
			0 {
				SaveTin
			}
			2 {
				return
			}
		}
	}
	global ${tinLoaded}_ele ${tinLoaded}_node
	catch {unset ${tinLoaded}_ele}
	catch {unset ${tinLoaded}_node}
	set tinLoaded ""
	set tinChanged 0
	set tinPath ""
	DtmMenuState
	RefreshAll
}

#
#	Display loaded tin in graphic window
#	@param wnd name of toplevel window to show TIN
proc ShowTin {this} {
	global tinLoaded

	global ${tinLoaded}_ele ${tinLoaded}_node
	global newtin_poly newtin_hole
	set can $this.map.c

	# draw triangles
	if {[info exists ${tinLoaded}_ele]} {
	foreach index [array names ${tinLoaded}_ele] {
			set triangle [set ${tinLoaded}_ele($index)]
			if {[catch {set p0 [set ${tinLoaded}_node([lindex $triangle 0])]}]} { continue }
			if {[catch {set p1 [set ${tinLoaded}_node([lindex $triangle 1])]}]} { continue }
			if {[catch {set p2 [set ${tinLoaded}_node([lindex $triangle 2])]}]} { continue }
			set x0 [GeoX $this [lindex $p0 0]]
			set y0 [GeoY $this [lindex $p0 1]]
			set x1 [GeoX $this [lindex $p1 0]]
			set y1 [GeoY $this [lindex $p1 1]]
			set x2 [GeoX $this [lindex $p2 0]]
			set y2 [GeoY $this [lindex $p2 1]]
			$can create polygon $x0 $y0 $x1 $y1 $x2 $y2 \
				-tags [list T${index} tin] -fill white -outline black
		}
	}
	# draw break lines, boundary
# !!! from newtin_poly !!!
#	foreach index [array names ${tinLoaded}_poly] {
#		set segment [set ${tinLoaded}_poly($index)]
#		set p0 [set ${tinLoaded}_node([lindex $segment 0])]
#		set p1 [set ${tinLoaded}_node([lindex $segment 1])]
#		set x0 [GeoX $this [lindex $p0 0]]
#		set y0 [GeoY $this [lindex $p0 1]]
#		set x1 [GeoX $this [lindex $p1 0]]
#		set y1 [GeoY $this [lindex $p1 1]]
#		$can create line $x0 $y0 $x1 $y1 \
#			-tags [list B${index} tin] -fill blue -width 2
#	}
	# draw holes (rectangle)
# !!! only from newtin_hole
#	set dx 2
#	foreach index [array names ${tinLoaded}_hole] {
#		set p0 [set ${tinLoaded}_hole($index)]
#		set x0 [GeoX $this [lindex $p0 0]]
#		set y0 [GeoY $this [lindex $p0 1]]
#		$can create rectangle [expr {$x0 - $dx}] [expr {$y0 - $dx}] \
#			[expr {$x0 + $dx}] [expr {$y0 + $dx}] \
#			-tags [list H${index} tin] -fill red -width 1
#	}

	# draw nodes
	set dx 2
	foreach index [array names ${tinLoaded}_node] {
		set p0 [set ${tinLoaded}_node($index)]
		set x [GeoX $this [lindex $p0 0]]
		set y [GeoY $this [lindex $p0 1]]
		$can create oval \
			[expr {$x - $dx}] [expr {$y - $dx}] \
			[expr {$x + $dx}] [expr {$y + $dx}] \
			-fill black -tags [list N${index} tin]
	}
	# draw newtin_poly
	foreach poly $newtin_poly {
		set xe [GeoX $this [lindex [lindex $poly 0] 0]]
		set ye [GeoY $this [lindex [lindex $poly 0] 1]]
		set x [GeoX $this [lindex [lindex $poly 1] 0]]
		set y [GeoY $this [lindex [lindex $poly 1] 1]]
		$can create line $xe $ye $x $y \
			-tags [list Bnew tin] -fill blue -width 2
	}
	# draw newtin_hole
	set i 0
	foreach hole $newtin_hole {
		set x0 [GeoX $this [lindex $hole 0]]
		set y0 [GeoY $this [lindex $hole 1]]
		$can create rectangle [expr {$x0 - $dx}] [expr {$y0 - $dx}] \
			[expr {$x0 + $dx}] [expr {$y0 + $dx}] \
			-tags [list Hnew tin] -fill blue -width 1
		incr i
	}
}

#
#
#	Load TIN nodes into memory structures
#	File structure:
#		first line: <# of vertices> <dimension (must be 2)> <# of attributes>
#					<# of boundary markers>
#		remaining lines: <vertex #> <x> <y> [attributes] [boundary marker]
#
#	Blank lines and comments prefixed by '#' may be placed anywhere.
#	Vertices must be numbered consecutively, startinf from 0 or 1.
#	@param tinPath path and TIN name
proc LoadTinNodes {tinPath} {
	global reg

	if {! [file readable ${tinPath}.pnt]} { return 1 } ;# no file
	set tinName [file tail $tinPath]
	global ${tinName}_node
	catch {unset ${tinName}_node}
	set f [open ${tinPath}.pnt r]
	set buf [string trim [gets $f]]
	while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
	set buflist [split $buf]
	set n [lindex $buflist 0]	;# number of nodes
	set i 0
	while {! [eof $f]} {
		set buf [string trim [gets $f]]
		if {[string length $buf] == 0 || [string range $buf 0 0] == "#"} {
			# skip empty or comment line
			incr i
			continue
		}
		while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
		set buflist [split $buf]
		if {[llength $buflist] < 4 || \
				[regexp $reg(1) [lindex $buflist 0]] == 0 || \
				[regexp $reg(2) [lindex $buflist 1]] == 0 || \
				[regexp $reg(2) [lindex $buflist 2]] == 0 || \
				[regexp $reg(2) [lindex $buflist 3]] == 0} {
			# short line or format error
			catch {unset ${tinName}_node}
			catch {close $f}
			return -$i
		}
		set ${tinName}_node([lindex $buflist 0]) [lrange $buflist 1 3]
		incr i
	}
	close $f
	return 0
}

#
#	Save tin points to file
#	@param tinPath directory and tin name without extension
proc SaveTinNodes {tinPath} {
	if {! [file writable ${tinPath}.pnt]} {return 1}
	set tinName [file tail $tinPath]
	global ${tinName}_node
	if {! [info exists ${tinName}_node]} {return 2}
	set f [open ${tinPath}.pnt w]
	puts $f "[array size ${tinName}_node] 2 1 1"
	foreach i [lsort -integer [array names ${tinName}_node]] {
		set t [set ${tinName}_node($i)]
		puts $f "$i $t" 
	}
	close $f
	return 0
}

#
#	Load TIN triangles into memory structures
#	File structure:
#		first line: <# of triangles> <nodes per triangle> <# of attributes>
#		remaining lines: <triangle #> <node> <node> ... [attributes]
#	Blank lines and comments prefixed by '#' may be placed anywhere.
#	Triangles must be numbered consecutively, startinf from 0 or 1.
#	Nodes are indices into the corresponding .node file. Nodes are
#	listed counterclockwise order.
#	@param tinPath path and TIN name
proc LoadTinEle {tinPath} {
	global reg

	if {! [file readable ${tinPath}.dtm]} { return 1 } ;# no file
	set tinName [file tail $tinPath]
	global ${tinName}_ele
	catch {unset ${tinName}_ele}
	set f [open ${tinPath}.dtm r]
	set buf [string trim [gets $f]]
	while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
	set buflist [split $buf]
	set n [lindex $buflist 0]	;# number of nodes
	set i 0
	while {! [eof $f]} {
		set buf [string trim [gets $f]]
		if {[string length $buf] == 0 || [string range $buf 0 0] == "#"} {
			# skip empty or comment line
			incr i
			continue
		}
		while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
		set buflist [split $buf]
		if {[llength $buflist] < 4 || \
				[regexp $reg(1) [lindex $buflist 0]] == 0 || \
				[regexp $reg(1) [lindex $buflist 1]] == 0 || \
				[regexp $reg(1) [lindex $buflist 2]] == 0 || \
				[regexp $reg(1) [lindex $buflist 3]] == 0} {
			# short line or format error
			catch {unset ${tinName}_ele}
			catch {close $f}
			return -$i
		}
		set ${tinName}_ele([lindex $buflist 0]) [lrange $buflist 1 3]
		incr i
	}
	close $f
	return 0
}

#
#	Save loaded TIN triangles
#	@param tinPath directory and tin name without extension
proc SaveTinEle {tinPath} {
	if {! [file writable ${tinPath}.dtm]} {return 1}
	set tinName [file tail $tinPath]
	global ${tinName}_ele
	if {! [info exists ${tinName}_ele]} {return 2}
	set f [open ${tinPath}.dtm w]
	puts $f "[array size ${tinName}_ele] 3 0"
	foreach i [lsort -integer [array names ${tinName}_ele]] {
		set t [set ${tinName}_ele($i)]
		puts $f "$i $t" 
	}
	close $f
	return 0
}

#
#	Load TIN breaklines/boundaries into memory structures
#	File structure:
#		first line: <# of vertices> <dimension (must be 2)> <# of attributes>
#					<# of boundary markers (0 or 1)>
#		following lines: <vertex #> <x> <y> [attributes] [boundary marker]
#		one line: <# of segments> <# of boundary markers (0 or 1)>
#		following lines: <segment #> <endpoint> <endpoint> [boundary marker]
#		one line: <# of holes>
#		following lines: <hole #> <x> <y>
#		optional line: <# of regional attributes and/or are constraints>
#		optional following lines: <region #> <x> <y> <attribute> <max area>
#
#	<# of vertices> may be set to zero to indicater that the vertices are
#	listed  in separate .node file.
#	Blank lines and comments prefixed by '#' may be placed anywhere.
#	Vertices, segments, holes and regions must be numbered consecutively, 
#	starting from 0 or 1.
#	@param tinPath path and TIN name
proc LoadTinPoly {tinPath} {
	global reg
	global newtin_poly
	global newtin_hole
	global geoEasyMsg

set newtin_poly ""	;# delete previous break/boundary lines

	if {! [file readable ${tinPath}.pol]} { return 0 } ;# no file
	set tinName [file tail $tinPath]
	global ${tinName}_node
	global ${tinName}_poly
	global ${tinName}_hole
	catch {unset ${tinName}_node}
	catch {unset ${tinName}_poly}
	catch {unset ${tinName}_hole}
	if {[catch {set f [open ${tinPath}.pol r]}] == 1} {
		tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(tinload) warning 0 OK
		return
	}
	set buf [string trim [gets $f]]
	while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
	set buflist [split $buf]
	set n [lindex $buflist 0]	;# number of vertices
	set lin 1
	set i 0
	if {$n > 0} {
		# load vertices part
		catch {unset ${tinName}_node}
		for {set i 0} {$i < $n} {incr i} {
			set buf [string trim [gets $f]]
			if {[string length $buf] == 0 || [string range $buf 0 0] == "#"} {
				# skip empty or comment line
				incr lin
				continue
			}
			while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
			set buflist [split $buf]
			if {[llength $buflist] < 4 || \
					[regexp $reg(1) [lindex $buflist 0]] == 0 || \
					[regexp $reg(2) [lindex $buflist 1]] == 0 || \
					[regexp $reg(2) [lindex $buflist 2]] == 0 || \
					[regexp $reg(2) [lindex $buflist 3]] == 0} {
				# short line or format error
				catch {unset ${tinName}_node}
				catch {close $f}
				return -$lin
			}
			set ${tinName}_node([lindex $buflist 0]) [lrange $buflist 1 3]
			
			incr lin
		}
	} else {
		# load node data from separate file
		LoadTinNodes $tinPath
	}
	set buf [string trim [gets $f]]
	incr lin
	while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
	set buflist [split $buf]
	set n [lindex $buflist 0]	;# number of segments
	# load segments part
	for {set i 0} {$i < $n} {incr i} {
		set buf [string trim [gets $f]]
		if {[string length $buf] == 0 || [string range $buf 0 0] == "#"} {
			# skip empty or comment line
			incr lin
			continue
		}
		while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
		set buflist [split $buf]
		if {[llength $buflist] < 3 || \
				[regexp $reg(1) [lindex $buflist 0]] == 0 || \
				[regexp $reg(1) [lindex $buflist 1]] == 0 || \
				[regexp $reg(1) [lindex $buflist 2]] == 0} {
			# short line or format error
			catch {unset ${tinName}_poly}
			catch {close $f}
			return -$lin
		}
		set ${tinName}_poly([lindex $buflist 0]) [lrange $buflist 1 2]
set pe [set ${tinName}_node([lindex $buflist 1])]
lappend pe "dtm"
lappend pe [lindex $buflist 1]
set p [set ${tinName}_node([lindex $buflist 2])]
lappend p "dtm"
lappend p [lindex $buflist 2]
lappend newtin_poly [list $pe $p]
#		incr line
	}
	set buf [string trim [gets $f]]
	incr lin
	while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
	set buflist [split $buf]
	set n [lindex $buflist 0]	;# number of holes
	# load holes part
	for {set i 0} {$i < $n} {incr i} {
		set buf [string trim [gets $f]]
		if {[string length $buf] == 0 || [string range $buf 0 0] == "#"} {
			# skip empty or comment line
			incr lin
			continue
		}
		while {[regsub -all "  " $buf " " buf]} { }	;# remove double spaces
		set buflist [split $buf]
		if {[llength $buflist] < 3 || \
				[regexp $reg(1) [lindex $buflist 0]] == 0 || \
				[regexp $reg(2) [lindex $buflist 1]] == 0 || \
				[regexp $reg(2) [lindex $buflist 2]] == 0} {
			# short line or format error
			catch {unset ${tinName}_poly}
			catch {close $f}
			return -$lin
		}
		set ${tinName}_hole([lindex $buflist 0]) [lrange $buflist 1 2]
		set p [set ${tinName}_hole([lindex $buflist 0])]
		lappend newtin_hole $p
		incr lin
	}
	close $f
	return 0
}

#
#	Save loaded TIN breaklines/borders/holes
#	@param tinPath directory and tin name without extension
proc SaveTinPoly {tinPath} {
	if {! [file writable ${tinPath}.pol]} {return 1}
	set tinName [file tail $tinPath]
	global ${tinName}_poly ${tinName}_hole
#	if {! [info exists ${tinName}_poly] || ! [info exists ${tinName}_hole]} {
#		return 2
#	}
	set f [open ${tinPath}.pol w]
	puts $f "0 2 1 1"	;# no points
	if {[info exists ${tinName}_poly]} {
		puts $f "[array size ${tinName}_poly] 3 0"
		foreach i [lsort -integer [array names ${tinName}_poly]] {
			set t [set ${tinName}_poly($i)]
			puts $f "$i $t" 
		}
	} else {
		puts $f "0 3 0"
	}
	if {[info exists ${tinName}_hole]} {
		puts $f "[array size ${tinName}_hole]"
		foreach i [lsort -integer [array names ${tinName}_hole]] {
			set t [set ${tinName}_hole($i)]
			puts $f "$i $t" 
		}
	} else {
		puts $f 0
	}
	close $f
	return 0
}

#
#	Interpolate z value in triangle of dtm
#	@param this handle to window
#	@param cx canvas x
#	@param cy canvas y
proc InterpolateTin {this cx cy} {
	global geoWindowScale
	global tinLoaded

	set can $this.map.c
	set pos -1
	set start 0
	set found {}	;# list of found ids
	# look for topmost triangle or point
	while {$pos == -1} {
		set id [$can find closest $cx $cy 0 $start]
		if {$id == "" || [lsearch -exact $found $id] != -1} {
			Beep
			return -9999
		}
		set tags [$can gettags $id]
		set pos [lsearch -glob $tags "T*"]	;# triangle
		if {$pos == -1} {
			set pos [lsearch -glob $tags "N*"]	;# node
			if {$pos == -1} {
				set pos [lsearch -glob $tags "Z*"]	;# contour
			}
		}
		lappend found $id
		set start $id
	}
	set buf [lindex $tags $pos]
	set index [string range $buf 1 end]
	set it [string index $buf 0]	;# T/N/Z
	global ${tinLoaded}_node ${tinLoaded}_ele
	set xact [expr {$cx / double($geoWindowScale($this))}]
	set yact [expr {-$cy / double($geoWindowScale($this))}]
	if {$it == "Z"} {
		return $index
	}
	if {$it == "N"} {
		set p1 [set ${tinLoaded}_node($index)]
		set z [lindex $p1 2]
		return $z
	}
	# get triangle points
	set triang [set ${tinLoaded}_ele($index)]
	set p1 [set ${tinLoaded}_node([lindex $triang 0])]
	set p2 [set ${tinLoaded}_node([lindex $triang 1])]
	set p3 [set ${tinLoaded}_node([lindex $triang 2])]
	set x1 [lindex $p1 0]
	set y1 [lindex $p1 1]
	set z1 [lindex $p1 2]
	set x2 [lindex $p2 0]
	set y2 [lindex $p2 1]
	set z2 [lindex $p2 2]
	set x3 [lindex $p3 0]
	set y3 [lindex $p3 1]
	set z3 [lindex $p3 2]
	set dx1 [expr {$x1 - $x2}]
	set dy1 [expr {$y1 - $y2}]
	set dz1 [expr {$z1 - $z2}]
	set dx2 [expr {$x3 - $x2}]
	set dy2 [expr {$y3 - $y2}]
	set dz2 [expr {$z3 - $z2}]
	# normal vector (dy1 dx1 dz1) x (dy2 dx2 dz2)
	set a [expr {$dy1 * $dz2 - $dy2 * $dz1}]
	set b [expr {$dx2 * $dz1 - $dx1 * $dz2}]
	set c [expr {double($dx1 * $dy2 - $dx2 * $dy1)}]
	set d [expr {-$a * $x1 - $b * $y1 - $c * $z1}]
	set z [expr {-($a * $xact + $b * $yact + $d) / $c}]
	return $z
}

#
#	Swap two triangles if they have convex boundary
#	@param this window
#	@param x position on canvas
#	@param y position on canvas
proc SwapTriangles {this x y} {
	global tinChanged
	global tinLoaded
	
	set can $this.map.c
	set cx [$can canvasx $x]
	set cy [$can canvasy $y]
	set ids [$can find overlapping [expr {$cx - 1}] [expr {$cy - 1}] \
		[expr {$cx + 1}] [expr {$cy + 1}]]
	if {[llength $ids] < 2} {
		Beep
		return
	}
	# find two triangles
	set id1 -1	;# id of 1st triangle
	set id2 -1	;# id of 2nd triangle
	foreach id $ids {
		set tags [$can gettags $id]
		set pos [lsearch -glob $tags "T*"]
		if {$pos != -1} {
			set buf [lindex $tags $pos]
			if {$id1 == -1} {
				set id1 [string range $buf 1 end]
			} else {
				set id2 [string range $buf 1 end]
			}
		}
	}
	if {$id1 == -1 || $id2 == -1} {
		Beep	;# no triangle border here
		return
	}
	global ${tinLoaded}_node ${tinLoaded}_ele
	# get triangles & corners
	set triang1 [set ${tinLoaded}_ele($id1)]
	set triang2 [set ${tinLoaded}_ele($id2)]
	# points of triangles
	# find common side of two triangle
	set cp1 -1
	set cp2 -1	;# ids of common points
	foreach p $triang1 {
		if {[lsearch -exact $triang2 $p] != -1} {
			if {$cp1 == -1} {
				set cp1 $p
			} else {
				set cp2 $p
			}
		}
	}
	if {$cp1 == -1 || $cp2 == -1} {	;# no common side
		Beep
		return
	}
	# find end points of other diagonal
	set op1 -1
	set op2 -1
	foreach p $triang1 {
		if {$p != $cp1 && $p != $cp2} {
			set op1 $p
			break
		}
	}
	foreach p $triang2 {
		if {$p != $cp1 && $p != $cp2} {
			set op2 $p
			break
		}
	}
	# convex ? diagonals are crossing
	set cp1_coo [set ${tinLoaded}_node($cp1)]
	set cp2_coo [set ${tinLoaded}_node($cp2)]
	set op1_coo [set ${tinLoaded}_node($op1)]
	set op2_coo [set ${tinLoaded}_node($op2)]
	set cb [Bearing [lindex $cp1_coo 0] [lindex $cp1_coo 1] \
		[lindex $cp2_coo 0] [lindex $cp2_coo 1]]
	set ob [Bearing [lindex $op1_coo 0] [lindex $op1_coo 1] \
		[lindex $op2_coo 0] [lindex $op2_coo 1]]
	set ip_coo [Intersec [lindex $cp1_coo 0] [lindex $cp1_coo 1] \
		[lindex $op1_coo 0] [lindex $op1_coo 1] $cb $ob]
	if {([lindex $cp1_coo 0] <= [lindex $ip_coo 0] && \
		 [lindex $ip_coo 0] <= [lindex $cp2_coo 0] || \
		 [lindex $cp2_coo 0] <= [lindex $ip_coo 0] && \
		 [lindex $ip_coo 0] <= [lindex $cp1_coo 0]) && \
		([lindex $cp1_coo 1] <= [lindex $ip_coo 1] && \
		 [lindex $ip_coo 1] <= [lindex $cp2_coo 1] || \
		 [lindex $cp2_coo 1] <= [lindex $ip_coo 1] && \
		 [lindex $ip_coo 1] <= [lindex $cp1_coo 1])} {
		# convex - swap diagonals
# TDB koruljarasi irany vizsgalat
		set ${tinLoaded}_ele($id1) [list $cp1 $op1 $op2]
		set ${tinLoaded}_ele($id2) [list $cp2 $op1 $op2]
		GeoDraw $this	;# refresh window
		set tinChanged 1
	} else {
		Beep
	}
}

#
#	Draw contour lines
#	@param w graphic window, empty if dxf output
#	@param dxf dxf output 1/0 yes/no
#	@param fd file descriptor, empty if screen output
proc TContour {w {dxf 0} {fd ""}} {
	global tinLoaded
	global geoEasyMsg
	global contourInterval contourDxf contourLayer contour3Dface

	set dz $contourInterval
	set layersep $contourLayer
	set faces $contour3Dface
	set tin $tinLoaded

	global ${tin}_ele ${tin}_node

	set n 0
	if {$dxf} {
		set n [string first "." $dz]
		# number of decimals in elevation in DXF layername
		if {$n == -1} {
			set n 0
		} else {
			set n [expr {[string length $dz] - $n - 1}]
		}
		set layername "szintvonal"
	}
	set dz [expr {double($dz)}]
	set nt [array size ${tin}_ele]
	set can $w.map.c
	
	# for each triangle in tin
	foreach i [array names ${tin}_ele] {
		set triang [set ${tin}_ele($i)]
		if {[catch {set p1 [set ${tin}_node([lindex $triang 0])]}] || \
			[catch {set p2 [set ${tin}_node([lindex $triang 1])]}] || \
			[catch {set p3 [set ${tin}_node([lindex $triang 2])]}]} {
			continue
		}
		set x1 [lindex $p1 0]
		set y1 [lindex $p1 1]
		set z1 [lindex $p1 2]
		set x2 [lindex $p2 0]
		set y2 [lindex $p2 1]
		set z2 [lindex $p2 2]
		set x3 [lindex $p3 0]
		set y3 [lindex $p3 1]
		set z3 [lindex $p3 2]
		if {$dxf && $faces} {
			puts $fd "  0\n3DFACE\n  8\nFELULET"
			puts $fd " 10\n$x1\n 20\n$y1\n 30\n$z1"
			puts $fd " 11\n$x2\n 21\n$y2\n 31\n$z2"
			puts $fd " 12\n$x3\n 22\n$y3\n 32\n$z3"
			puts $fd " 13\n$x3\n 23\n$y3\n 33\n$z3"
		}
		if {$dz == "" || $dz == 0} { continue }	;# skip contours
		# min and max z
		set minz [expr {($z1 < $z2) ? $z1 : $z2}]
		set minz [expr {($minz < $z3) ? $minz : $z3}]
		set maxz [expr {($z1 > $z2) ? $z1 : $z2}]
		set maxz [expr {($maxz > $z3) ? $maxz : $z3}]
		set z [expr {int($minz / $dz) * $dz}]
		set eps [expr {$dz / 100.0}]
		if {$z < $minz} {set z [expr {$z + $dz}]}
		while {$z <= $maxz} {
			catch {unset x}
			catch {unset y}
			set k 0
			if {[expr {abs($z2 - $z1)}] > $eps} {
				set zz12 [expr {($z - $z1) / double($z2 - $z1)}]
			} else {
				set zz12 0
			}
			if {[expr {abs($z3 - $z2)}] > $eps} {
				set zz23 [expr {($z - $z2) / double($z3 - $z2)}]
			} else {
				set zz23 0
			}
			if {[expr {abs($z1 - $z3)}] > $eps} {
				set zz31 [expr {($z - $z3) / double($z1 - $z3)}]
			} else {
				set zz31 0
			}
			if {[expr {abs($z1 - $z)}] < $eps && \
				[expr {abs($z2 - $z)}] < $eps} {
				# contour on 1-2 edge
				set x($k) $x1
				set y($k) $y1
				incr k
				set x($k) $x2
				set y($k) $y2
				incr k
			} elseif {$z1 < $z && $z <= $z2 || $z2 < $z && $z <= $z1} {
				# interpolate on 1-2 edge
				set x($k) [expr {$x1 + ($x2 - $x1) * $zz12}]
				set y($k) [expr {$y1 + ($y2 - $y1) * $zz12}]
				incr k
			}
			if {[expr {abs($z2 - $z)}] < $eps && \
				[expr {abs($z3 - $z)}] < $eps} {
				# contour on 2-3 edge
				set x($k) $x2
				set y($k) $y2
				incr k
				set x($k) $x3
				set y($k) $y3
				incr k
			} elseif {$z2 < $z && $z <= $z3 || $z3 < $z && $z <= $z2} {
				# interpolate on 2-3 edge
				set x($k) [expr {$x2 + ($x3 - $x2) * $zz23}]
				set y($k) [expr {$y2 + ($y3 - $y2) * $zz23}]
				incr k
			}
			if {[expr {abs($z3 - $z)}] < $eps && \
				[expr {abs($z1 - $z)}] < $eps} {
				# contour on 3-1 edge
				set x($k) $x3
				set y($k) $y3
				incr k
				set x($k) $x1
				set y($k) $y1
				incr k
			} elseif {$z3 < $z && $z <= $z1 || $z1 < $z && $z <= $z3} {
				# interpolate on 3-1 edge
				set x($k) [expr {$x3 + ($x1 - $x3) * $zz31}]
				set y($k) [expr {$y3 + ($y1 - $y3) * $zz31}]
				incr k
			}
			for {set j 0} {$j < [expr {$k - 1}]} {incr j 2} {
				set j1 [expr {$j + 1}]
				if {[Distance $x($j) $y($j) $x($j1) $y($j1)] > $eps} {
					# draw contours longer than eps
					# round height
					set zz [format "%.${n}f" $z]
					if {$dxf} {
						if {$layersep} {
							set layername "sz$zz"
						}
						puts $fd "  0\nLINE\n  8\n$layername"
						puts $fd " 10\n$x($j)\n 20\n$y($j)\n 30\n$z"
						puts $fd " 11\n$x($j1)\n 21\n$y($j1)\n 31\n$z"
					} else {
						$can create line [GeoX $w $x($j)] [GeoY $w $y($j)] \
							[GeoX $w $x($j1)] [GeoY $w $y($j1)] -fill red \
							-tags Z$zz
					}
				}
			} 
			set z [expr {$z + $dz}]
		}
	}
}

#
#	Display dialog to set contour interval
proc ContourDia {} {
	global geoEasyMsg
	global buttonid
	global contourInterval contourDxf contourLayer contour3Dface
	global tinLoaded

	set w [focus]
	if {$w == ""} { set w "." }
	set this .contourparam
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(contourpar)
	wm resizable $this 0 0
	wm transient $this $w
	catch {wm attribute $this -topmost}

	set buttonid 0
	if {! [info exists contourInterval] || \
			[string length $contourInterval] == 0 || $contourInterval < 0} {
		set contourInterval 1.0
	}

	label $this.lcontourinterval -text $geoEasyMsg(contourInterval)
	entry $this.contourentry -textvariable contourInterval -width 10
	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"

	grid $this.lcontourinterval -row 1 -column 0 -sticky w
	grid $this.contourentry -row 1 -column 1 -sticky w
	grid $this.exit -row 2 -column 0
	grid $this.cancel -row 2 -column 1

	tkwait visibility $this
	CenterWnd $this
	grab set $this
}

#
#	Draw contours in window and optionally write to dxf file
#	@param this graphic window name (.g0)
proc GeoContour {this} {
	global contourInterval
	global buttonid
	global reg
	global geoEasyMsg
	global tinLoaded
	global tinLoaded
	
	if {[string length $tinLoaded] == 0} {
		Beep
		return
	}
	ContourDia
	tkwait window .contourparam
	if {$buttonid} {
		set contourInterval 0	;# no contours
		return
	}
	if {[regexp $reg(2) $contourInterval] == 0 || \
			$contourInterval < 0} {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(contourIntErr) \
			error 0 OK
		return
	}
	GeoDraw $this
}

#
#	Create VRML 2 file and open it optionally
proc CreateVrml { } {
	global tinLoaded
	global vrmlTypes
	global lastDir
	global geoEasyMsg
	global tcl_platform
	global reg

	if {[string length $tinLoaded]} {
		# select tin to export
		set tin $tinLoaded
		global ${tin}_ele ${tin}_node
		set zfac [GeoEntry $geoEasyMsg(zfaclabel) $geoEasyMsg(menuDtmVrml) "1"]
		if {$zfac == ""} {
			return
		}
		if {[regexp $reg(2) $zfac] == 0 || $zfac <= 0} {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) error 0 OK
			return
		}
		# get output name
		set target [string trim [tk_getSaveFile -defaultextension ".wrl" \
			-filetypes $vrmlTypes -initialdir $lastDir]]
		if {[string length $target] == 0 || [string match "after#*" $target]} {
			return
		}
		set lastDir [file dirname $target]
		set f [open $target w]
		puts $f "\#VRML V2.0 utf8"
		puts $f "\# Created by GeoEasy DTM extension"
		puts $f "\# www.digikom.hu"
		# create viewpoints
		set pnt [set ${tin}_node(0)]
		set minx [lindex $pnt 0]
		set miny [lindex $pnt 1]
		set minz [lindex $pnt 2]
		set maxx $minx
		set maxy $miny
		set maxz $minz
		foreach i [array names ${tin}_node] {
			set pnt [set ${tin}_node($i)]
			if {$minx > [lindex $pnt 0]} { set minx [lindex $pnt 0] }
			if {$maxx < [lindex $pnt 0]} { set maxx [lindex $pnt 0] }
			if {$miny > [lindex $pnt 1]} { set miny [lindex $pnt 1] }
			if {$maxy < [lindex $pnt 1]} { set maxy [lindex $pnt 1] }
			if {$minz > [lindex $pnt 2]} { set minz [lindex $pnt 2] }
			if {$maxz < [lindex $pnt 2]} { set maxz [lindex $pnt 2] }
		}
		puts $f "Viewpoint \{"
		puts $f "fieldOfView 0.785398"
		puts $f "position [expr {($maxx - $minx) / 2.0}] [expr {($maxy - $miny) / 2.0}] [expr {($maxz + $maxz - $minz) * $zfac}]"
#		puts $f "orientation 0 0 1 0"
		puts $f "jump TRUE"
		puts $f "description \"v1\""
		puts $f "\}"
		puts $f "Background \{"
		puts $f "skyColor \[0.0 0.0 0.9\]"
		puts $f "\}"
		puts $f "Shape \{"
		puts $f "appearance Appearance \{ material Material \{ \}\}"
		puts $f "geometry IndexedFaceSet \{ coord Coordinate \{ point \["
		foreach i [array names ${tin}_node] {
			set pnt [set ${tin}_node($i)]
			puts $f "[lindex $pnt 0] [lindex $pnt 1] [expr {$zfac * [lindex $pnt 2]}]"
		}
		puts $f "\]\}"
		puts $f "coordIndex \["
		set nt [array size ${tin}_ele]
		foreach i [array names ${tin}_ele] {
			set triang [set ${tin}_ele($i)]
			puts $f "[lindex $triang 0]  [lindex $triang 1] \
				[lindex $triang 2] -1"
		}
		puts $f "\]"	;# close coordIndex
		puts $f "colorPerVertex FALSE"
		puts $f "creaseAngle 0"
		puts $f "solid FALSE"
		puts $f "ccw TRUE"
		puts $f "convex TRUE"
		puts $f "\}"	;# close geometry
		puts $f "\}"	;# close Shape
		close $f
		if {[tk_dialog .msg $geoEasyMsg(info) $geoEasyMsg(openit) info 0 \
			$geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
			if {[ShellExec $target]} {
				tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(rtfview) \
					warning 0 OK
			}
		}
	} else {
		Beep
	}
}

#
#	Create KML file and open it optionally
#	Only HD72/EOV CRS (EPSG=23700) is supported!
proc CreateKml { } {
	global tinLoaded
	global kmlTypes polyStyle
	global lastDir
	global geoEasyMsg geoCodes
	global tcl_platform
	global reg

	if {[string length $tinLoaded]} {
		# select tin to export
		set tin $tinLoaded
		global ${tin}_ele ${tin}_node
		set from_epsg [GeoEntry $geoCodes(140) $geoEasyMsg(fromEpsg)]
		if {$from_epsg == ""} {
			return
		}
		set zfac [GeoEntry $geoEasyMsg(zfaclabel) $geoEasyMsg(menuDtmKml) "1"]
		if {$zfac == ""} {
			return
		}
		if {[regexp $reg(2) $zfac] == 0 || $zfac <= 0} {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) error 0 OK
			return
		}
		# get output name
		set target [string trim [tk_getSaveFile -defaultextension ".kml" \
			-filetypes $kmlTypes -initialdir $lastDir]]
		if {[string length $target] == 0 || [string match "after#*" $target]} {
			return
		}
		set lastDir [file dirname $target]
		set f [open $target w]
		puts $f "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
		puts $f "<kml xmlns=\"http://www.opengis.net/kml/2.2\">"
		puts $f "<Document>"
		puts $f "<Style id=\"polyStyle\">"
		puts $f "<LineStyle><width>1</width></LineStyle>"
		puts $f "<PolyStyle><color>$polyStyle</color></PolyStyle>"
		puts $f "</Style>"
		# transform nodes to wgs84
		set coords ""
		foreach i [array names ${tin}_node] {
			set node [set ${tin}_node($i)]
			lappend coords [linsert $node 0 $i $i]
		}
		set tr_coords [cs2cs $from_epsg 4326 $coords]
		if {[llength $tr_coords] == 0} {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(cs2cs) error 0 OK
			return
		}
		foreach tr_coord $tr_coords {
			set tr_node([lindex $tr_coord 0]) [lrange $tr_coord 2 end]
		}
		# create kml file
		foreach i [array names ${tin}_ele] {
			puts $f "<Placemark>"
			puts $f "<name>$i</name>"
			puts $f "<styleUrl>#polyStyle</styleUrl>"
			puts $f "<Polygon>"
			puts $f "<extrude>$zfac</extrude>"
			puts $f "<altituteMode>absolute</altituteMode>"
			puts $f "<outerBoundaryIs>"
			puts $f "<LinearRing>"
			puts $f "<coordinates>"
			set triang [set ${tin}_ele($i)]
			set p1 $tr_node([lindex $triang 0])
			puts $f [join $p1 ","]
			set p2 $tr_node([lindex $triang 1])
			puts $f [join $p2 ","]
			set p3 $tr_node([lindex $triang 2])
			puts $f [join $p3 ","]
			puts $f [join $p1 ","]
			puts $f "</coordinates>"
			puts $f "</LinearRing>"
			puts $f "</outerBoundaryIs>"
			puts $f "</Polygon>"
			puts $f "</Placemark>"
		}
		puts $f "</Document>"
		puts $f "</kml>"
		close $f
		if {[tk_dialog .msg $geoEasyMsg(info) $geoEasyMsg(openit) info 0 \
			$geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
			if {[ShellExec $target]} {
				tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(rtfview) \
					warning 0 OK
			}
		}
	} else {
		Beep
	}
}

#
#	Calculate volume and surface area.
#	@param tin tin to calculate
#	@param level elevation to calculate from
#	@return list {total_volume volume_above volume_below base_area surface_area}
proc TinVolume {tin {level 0}} {
	global ${tin}_ele ${tin}_node

	set volume 0
	set area 0
	set surface 0
	set above 0
	set below 0
	foreach ii [lsort -integer [array names ${tin}_ele]] {
		set triangle [set ${tin}_ele($ii)]
		set p0 [set ${tin}_node([lindex $triangle 0])]
		set p1 [set ${tin}_node([lindex $triangle 1])]
		set p2 [set ${tin}_node([lindex $triangle 2])]
		set x0 [lindex $p0 0]
		set y0 [lindex $p0 1]
		set z0 [expr {[lindex $p0 2] - $level}]
		set x1 [lindex $p1 0]
		set y1 [lindex $p1 1]
		set z1 [expr {[lindex $p1 2] - $level}]
		set x2 [lindex $p2 0]
		set y2 [lindex $p2 1]
		set z2 [expr {[lindex $p2 2] - $level}]
		# area of base
		set base [Area $x0 $y0 0 $x1 $y1 0 $x2 $y2 0]
		set area [expr {$area + $base}]
		# area of surface
		set top [Area $x0 $y0 $z0 $x1 $y1 $z1 $x2 $y2 $z2]
		set surface [expr {$surface + $top}]
		set l1 ""	;# list of part bellow
		set l2 ""	;# list of part above
		# volume of prizm
		if {$z0 >= 0 && $z1 >= 0 && $z2 >= 0 || \
			$z0 <= 0 && $z1 <= 0 && $z2 <= 0} {
			# entire below or above level
			set avg_z [expr {($z0 + $z1 + $z2) / 3.0}]
			set v [expr {$base * $avg_z}]
			# sum
			set volume [expr {$volume + $v}]
			if {$v > 0} {
				set above [expr {$above + $v}]
			} else {
				set below [expr {$below + $v}]
			}
		} else {
			# partly above or below
			for {set i 0} {$i < 3} {incr i} {
				set j [expr {($i + 1) % 3}]
				if {[set z$i] == 0} {
					lappend l1 [list [set x$i] [set y$i] [set z$i]]
					lappend l2 [list [set x$i] [set y$i] [set z$i]]
				} elseif {[set z$i] < 0 && [set z$j] > 0} {
					# going above
					set w [expr {(- [set z$i])/double([set z$j] - [set z$i])}]
					set x [expr {([set x$j] - [set x$i]) * $w + [set x$i]}]
					set y [expr {([set y$j] - [set y$i]) * $w + [set y$i]}]
					lappend l1 [list [set x$i] [set y$i] [set z$i]]
					lappend l1 [list $x $y 0]
					lappend l2 [list $x $y 0]
				} elseif {[set z$i] > 0 && [set z$j] < 0} {
					# going below
					set w [expr {(- [set z$i])/double([set z$j] - [set z$i])}]
					set x [expr {([set x$j] - [set x$i]) * $w + [set x$i]}]
					set y [expr {([set y$j] - [set y$i]) * $w + [set y$i]}]
					lappend l1 [list $x $y 0]
					lappend l2 [list [set x$i] [set y$i] [set z$i]]
					lappend l2 [list $x $y 0]
				} elseif {[set z$i] < 0} {
					lappend l1 [list [set x$i] [set y$i] [set z$i]]
				} else {
					lappend l2 [list [set x$i] [set y$i] [set z$i]]
				}
			}
			# volume below
			set n [llength  $l1]
			set t 0
			set sumz 0
			for {set i 0} {$i < $n} {incr i} {
				set sumz [expr {$sumz + [lindex [lindex $l1 $i] 2]}]
				set j [expr {($i + 1) % $n}]
				set k [expr {($i + $n - 1) % $n}]
				set t [expr {$t + [lindex [lindex $l1 $i] 0] * \
					([lindex [lindex $l1 $k] 1] - [lindex [lindex $l1 $j] 1])}]
			}
			set t [expr {abs($t) / 2.0}]
			set w [expr {abs($t * $sumz / double($n))}]
			set below [expr {$below - $w}]
			set volume [expr {$volume - $w}]

			# volume above
			set n [llength  $l2]
			set t 0
			set sumz 0
			for {set i 0} {$i < $n} {incr i} {
				set sumz [expr {$sumz + [lindex [lindex $l2 $i] 2]}]
				set j [expr {($i + 1) % $n}]
				set k [expr {($i + $n - 1) % $n}]
				set t [expr {$t + [lindex [lindex $l2 $i] 0] * \
					([lindex [lindex $l2 $k] 1] - [lindex [lindex $l2 $j] 1])}]
			}
			set t [expr {abs($t) / 2.0}]
			set w [expr {abs($t * $sumz / double($n))}]
			set above [expr {$above + $w}]
			set volume [expr {$volume + $w}]
		}
	}
	return [list $volume $above $below $area $surface]
}

#
#	Display dialog to set volume calculation
proc VolumeDia {} {
	global geoEasyMsg
	global buttonid
	global volumeLevel
	global tinLoaded

	set w [focus]
	if {$w == ""} { set w "." }
	set this .volumeparam
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(volumepar)
	wm resizable $this 0 0
	wm transient $this $w
	catch {wm attribute $this -topmost}

	set buttonid 0
	if {! [info exists volumeLevel] || [string length $volumeLevel] == 0} {
		set volumeLevel 0
	}

	label $this.lvolumelevel -text $geoEasyMsg(volumeLevel)
	entry $this.levelentry -textvariable volumeLevel -width 10
	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"

	grid $this.lvolumelevel -row 1 -column 0 -sticky w
	grid $this.levelentry -row 1 -column 1 -sticky w
	grid $this.exit -row 2 -column 0
	grid $this.cancel -row 2 -column 1

	tkwait visibility $this
	CenterWnd $this
	grab set $this
}

#
#	Menu interface to volume calculation
proc GeoVolume {w} {
	global volumeLevel
	global buttonid
	global reg
	global geoEasyMsg
	global decimals
	global tinLoaded
	global geoRes

	if {[string length $tinLoaded] == 0} {
		Beep
		return
	}
	VolumeDia
	tkwait window .volumeparam
	if {$buttonid == 0} {
		if {[regexp $reg(2) $volumeLevel]} {
			set res [TinVolume $tinLoaded $volumeLevel]
			GeoLog1
			GeoLog "$geoEasyMsg(menuDtmVolume) - $tinLoaded"
			GeoLog1 $geoEasyMsg(headVolume)
			GeoLog1 [format "%8.${decimals}f %12.1f %12.1f %12.1f %12.1f %12.1f" \
				$volumeLevel [lindex $res 0] [lindex $res 1] \
				[expr {abs([lindex $res 2])}] [lindex $res 3] [lindex $res 4]]
			set geoRes($w) [format "%.0f m3" [lindex $res 0]]
		} else {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(volumeErr) \
				error 0 OK
			return

		}
	}
}

#		Calculate volume difference between two TINs
proc GeoVolumeDif {} {
	global tinLoaded tinPath
	global gridDX
	global buttonid
	global reg
	global tinTypes
	global lastDir
	global geoEasyMsg

	GridParams
	tkwait window .gridparams
	if {$buttonid} { return }
	if {[regexp $reg(2) $gridDX] == 0} {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
			error 0 OK	
		return
	}
	# get extent
	set tin $tinLoaded
	global ${tin}_ele ${tin}_node ${tin}_poly ${tin}_hole
	set xmi 1e39
	set ymi 1e39
	set zmi 1e39
	set xma -1e39
	set yma -1e39
	set zma -1e39
	foreach id [array names ${tin}_node] {
		set p [set ${tin}_node($id)]
		set x [lindex $p 0]
		set y [lindex $p 1]
		set z [lindex $p 2]
		if {$x < $xmi} {set xmi $x}
		if {$y < $ymi} {set ymi $y}
		if {$z < $zmi} {set zmi $z}
		if {$x > $xma} {set xma $x}
		if {$y > $yma} {set yma $y}
		if {$z > $zma} {set zma $z}
	}
	# convert actual TIN to ASCII grid
	set gridname1 [file join $tinPath "g1.asc"]
	tin2grid $gridname1 $gridDX $xmi $ymi $xma $yma
	# save original TIN params
	set oldTinLoaded $tinLoaded
	set oldTinPath $tinPath
	# load second TIN
	set tp [string trim [tk_getOpenFile -filetypes $tinTypes \
		-initialdir $lastDir]]
	if {[string length $tp] && [string match "after#*" $tp] == 0} {
		UnloadTin	;# unload first TIN
		set tp [file rootname $tp]
		LoadTin $tp	;# load second TIN
		# convert actual TIN to ASCII grid
		set gridname2 [file join $tinPath "g2.asc"]
		tin2grid $gridname2 $gridDX $xmi $ymi $xma $yma
		set res [GridDif $gridname1 $gridname2 \
			[file join $oldTinPath "${oldTinLoaded}-${tinLoaded}.asc"]]
		UnloadTin
		LoadTin [file join $oldTinPath $oldTinLoaded]	;# restore oroginal TIN
		catch {file delete $gridname1 $gridname2}
		GeoLog1
		GeoLog "$geoEasyMsg(menuDtmVolumeDif) [file join $oldTinPath $oldTinLoaded] - $tp"
		GeoLog1 [format $geoEasyMsg(griddx1) $gridDX]
		GeoLog1 [format $geoEasyMsg(llc) $xmi $ymi]
		GeoLog1 [format $geoEasyMsg(urc) $xma $yma]
		GeoLog1 [format $geoEasyMsg(voldif) [expr {abs([lindex $res 3])}] [lindex $res 0] [expr {abs([lindex $res 4])}] [lindex $res 1] [lindex $res 2]]
		GeoDrawAll
	}
}

#
#	Restart breakline drawing (stop by double click)
#	delete previous poly
#	@param can canvas
proc DtmPolyInit {can} {
	global dtmPolyPoints
	global dtmPrevPoint

	$can delete dtmpoly
	set dtmPolyPoints ""
	set dtmPrevPoint ""
}

#
#	Mark closed areas to skip in dtm
#	@param this handle to top level widget
#	@param x,y  position
proc DtmHole {this x y} {
	global newtin_hole
	global geoWindowScale

	set can $this.map.c
	set cx [$can canvasx $x]
	set cy [$can canvasy $y]
	set dx [expr {0.5 * double($geoWindowScale($this))}]
	$can create rectangle [expr {$cx - $dx}] [expr {$cy - $dx}] \
		[expr {$cx + $dx}] [expr {$cy + $dx}] -fill blue -outline blue \
		-width 2 -tags [list Hnew tin]
	set cx [expr {[$can canvasx $x] / double($geoWindowScale($this))}]
	set cy [expr {-[$can canvasy $y] / double($geoWindowScale($this))}]
	lappend newtin_hole [list $cx $cy]
}

#
#	Mark breaklines on map windows 
#		dtmPolyPoints list is built
#			iterms are lists {point_id x y z}
#	@param this handle to top level widget
#	@param x,y position
proc DtmPolyPoint {this x y} {
	global dtmPolyPoints				;# store/collect breakline points
	global dtmPrevPoint
	global geoEasyMsg
	global tinLoaded
	global newtin_poly

	set can $this.map.c
	set cx [$can canvasx $x]
	set cy [$can canvasy $y]
	set id [$can find closest $cx $cy]
	if {$id == ""} {
		Beep
		return
	}
	set itemtype [$can type $id]
	if {$itemtype == "oval"} {
		set tags [$can gettags $id]
		set pos [lsearch -glob $tags "N*"]	;# dtm node
		set ptype dtm
		if {$pos == -1} {
			set pos [lsearch -glob $tags "P*"]	;# geo_easy point
			set ptype geo
		}
		if {$pos == -1} { return }
		set pn [string range [lindex $tags $pos] 1 end]
	} else {
		Beep
		return
	}
	if {$ptype == "geo"} {
		set ref [GetCoord $pn {37 38 39}]
		if {[llength $ref] == 0} {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(noZDtm) error 0 OK
			return
		}
		# GeoEasy point
		lappend dtmPolyPoints \
			[list [GetVal 38 $ref] [GetVal 37 $ref] [GetVal 39 $ref] geo \
				[GetVal 5 $ref]]
	} else {
		# DTM point
		global ${tinLoaded}_node
		set p [set ${tinLoaded}_node($pn)]
		lappend p "dtm"
		lappend p $pn	;# add node id
		lappend dtmPolyPoints $p
	}
	set n [llength $dtmPolyPoints]
	if {$n > 1} {		;# not the first point
		if {$pn == $dtmPrevPoint} {
			# do not add the same point
				return
		}
		set pxy [$can coords P$dtmPrevPoint]
		if {[llength $pxy] == 0} {
			set pxy [$can coords N$dtmPrevPoint]
		}
		set xy [$can coords P$pn]
		if {[llength $xy] == 0} {
			set xy [$can coords N$pn]
		}
		# draw breakline
		$can create line [lindex $pxy 0] [lindex $pxy 1] \
			[lindex $xy 0] [lindex $xy 1] -fill blue -width 2 \
			-tags [list Bnew tin]
		set p [lindex $dtmPolyPoints end]
		set pe [lindex $dtmPolyPoints [expr {[llength $dtmPolyPoints] - 2}]]
		if {[expr {hypot([lindex $pe 0]-[lindex $p 0], [lindex $pe 1]-[lindex $p 1])}] > 0.01} {
			lappend newtin_poly [list $pe $p]
		}
	}
	set dtmPrevPoint $pn
}

#
#	Close polyline
proc DtmPolyEnd {this} {
	global dtmPolyPoints
	global geoEasyMsg
	global tinLoaded tinChanged
	global newtin_poly

	set n [llength $dtmPolyPoints]
	if {$n < 2} {
		Beep
		return                  ;# at least 2 points must be given
	}
	# store breakline
	if {[llength $dtmPolyPoints] > 1} {
		# append edge by edge
		set pe [lindex $dtmPolyPoints 0]
		for {set i 1} {$i < [llength $dtmPolyPoints]} {incr i} {
			set p [lindex $dtmPolyPoints $i]
			# remove zero length lines
			if {[expr {hypot([lindex $pe 0]-[lindex $p 0], [lindex $pe 1]-[lindex $p 1])}] > 0.01} {
				lappend newtin_poly [list $pe $p]
			}
			set pe $p
		}
	}
	set dtmPolyPoints ""
}

#
#	Display statistics about dtm
#	@param screen 1/0 screen output/return minmax as list
proc DtmStat {{screen 1}} {
	global tinLoaded
	global geoEasyMsg

	if {[string length $tinLoaded]} {
		set tin $tinLoaded
		global ${tin}_ele ${tin}_node ${tin}_poly ${tin}_hole
		set xmi 1e39
		set ymi 1e39
		set zmi 1e39
		set xma -1e39
		set yma -1e39
		set zma -1e39
		foreach id [array names ${tin}_node] {
			set p [set ${tin}_node($id)]
			set x [lindex $p 0]
			set y [lindex $p 1]
			set z [lindex $p 2]
			if {$x < $xmi} {set xmi $x}
			if {$y < $ymi} {set ymi $y}
			if {$z < $zmi} {set zmi $z}
			if {$x > $xma} {set xma $x}
			if {$y > $yma} {set yma $y}
			if {$z > $zma} {set zma $z}
		}
		if {$screen} {
			set wstr [format $geoEasyMsg(dtmStat) $tin \
				[array size ${tin}_node] \
				[array size ${tin}_ele] \
				[array size ${tin}_poly] \
				[array size ${tin}_hole] \
				$xmi $ymi $zmi $xma $yma $zma]
			GeoLog1
			GeoLog $geoEasyMsg(menuFileStat)
			GeoLog1 $wstr
			tk_dialog .msg $geoEasyMsg(info) $wstr info 0 OK
		} else {
			return [list $xmi $ymi $zmi $xma $yma $zma]
		}
	} else {
		Beep
	}
}

#
#	Set DTM menu and toolbar element's state in all opened graphic window
proc DtmMenuState {} {
	global tinLoaded

	if {[string length $tinLoaded]} {
		set newstate "normal"
	} else {
		set newstate "disabled"
	}

	foreach w [winfo children .] {
		if {[regexp "^\.g\[0-9\]$" $w]} {
			$w.menu.dtm entryconfigure 2 -state $newstate
			$w.menu.dtm entryconfigure 3 -state $newstate
			$w.menu.dtm entryconfigure 4 -state $newstate
			$w.menu.dtm entryconfigure 6 -state $newstate
			$w.menu.dtm entryconfigure 7 -state $newstate
			$w.menu.dtm entryconfigure 8 -state $newstate
			$w.menu.dtm entryconfigure 9 -state $newstate
			$w.menu.dtm entryconfigure 10 -state $newstate
			$w.menu.dtm entryconfigure 11 -state $newstate
			$w.menu.dtm entryconfigure 12 -state $newstate
			$w.menu.dtm entryconfigure 13 -state $newstate
			$w.toolbar.zdtm configure -state $newstate
#			$w.toolbar.break configure -state $newstate
#			$w.toolbar.hole configure -state $newstate
			$w.toolbar.xchgtri configure -state $newstate
		}
	}
}

#
#	Delete a new break line
#	@param x,y - point on line to delete
proc DeleteBreak {x y} {
	global newtin_poly

	# find nearest line
	set i 0
	set mindist 1e15
	set mini -1
	foreach l $newtin_poly {
		set x1 [lindex [lindex $l 0] 0]
		set y1 [lindex [lindex $l 0] 1]
		set x2 [lindex [lindex $l 1] 0]
		set y2 [lindex [lindex $l 1] 1]
		# line through 1-2
		set a [expr {$y1 - $y2}]
		set b [expr {$x2 - $x1}]
		set c [expr {$x1 * $y2 - $x2 * $y1}]
		# distance from line
		set dist [expr {abs($a * $x + $b * $y + $c) / sqrt ($a * $a + $b * $b)}]
		# perpendicular line
		if {[expr {abs($a)}] > 0.01} {
			set e 1
			set d [expr {-$b / $a}]
			set f [expr {-$x * $d - $y}]
		} else {
			set d 1
			set e [expr {-$a / $b}]
			set f [expr {-$x - $y * $e}]
		}
		# talppont
		set w [expr {$a * $e - $d * $b}]
		set xt [expr {($b * $f - $e * $c) / $w}]
		set yt [expr {($d * $c - $a * $f) / $w}]
		if {(($xt >= $x1 && $xt <= $x2) || \
			($xt >= $x2 && $xt <= $x1) || \
			($yt >= $y1 && $yt <= $y2) || \
			($yt >= $y2 && $yt <= $y1)) && \
			$dist < $mindist} {
			set mini $i
			set mindist $dist
		}
		incr i
	}
	if {$mini != -1} {
		set newtin_poly [lreplace $newtin_poly $mini $mini]	;# remove line
	}
}

#
#	Delete a new hole marker
#	@param x,y - point on line to delete
proc DeleteHole {x y} {
	global newtin_hole
	# find nearest marker
	set index -1
	set dist 10
	set i 0
	foreach h $newtin_hole {
		set d [expr {hypot([lindex $h 0] - $x, [lindex $h 1] - $y)}]
		if {$d < $dist} {
			set dist $d
			set index $i
		}
		incr i
	}
	if {$index != -1} {
		set newtin_hole [lreplace $newtin_hole $index $index]
	}
}

#
#	Delete a DTM point
#	@param id point id to delete
proc DeletePnt {id} {
	global tinLoaded
	global ${tinLoaded}_node
	if {[info exists ${tinLoaded}_node($id)]} {
		unset ${tinLoaded}_node($id)
	} else { Beep }
}

#
#	Delete a DTM triangle
#	@param id triangle id to delete
proc DeleteTri {id} {
	global tinLoaded tinChanged
	global ${tinLoaded}_ele
	if {[info exists ${tinLoaded}_ele($id)]} {
		unset ${tinLoaded}_ele($id)
		incr tinChanged
	} else { Beep }
}

#
#	Select a layer from a dxf file
#	@param title title for selection list
#	@param var   - name of variable to set
proc sellayer {title var} {
	global tmp pnlay lastDir
	global cadTypes

	upvar $var v
	if {[info exists tmp] == 0} { set tmp ""}
	if {$tmp == "" || [file exists $tmp] == 0} {
		set tmp [string trim [tk_getOpenFile -defaultextension ".dxf" \
			-filetypes $cadTypes -initialdir $lastDir]]
	}
	if {[string length $tmp] == 0 || [string match "after#*" $tmp]} { return }
	set lastDir [file dirname $tmp]
	set xxx $pnlay
	dxflayers $title -1
	if {[string length $pnlay]} {
		set v $pnlay
	}
	set pnlay $xxx
}

#
#	Calculate area of a triangle
#	@param x0,y0,z0 first point of triangle
#	@param x1,y1,z1 second point of triangle
#	@param x2,y2,z2 third point of triangle
#	@return area
proc Area {x0 y0 z0 x1 y1 z1 x2 y2 z2} {
	# area of triangle
	set a [expr {hypot(hypot($x1-$x0, $y1-$y0), $z1-$z0)}]
	set b [expr {hypot(hypot($x2-$x1, $y2-$y1), $z2-$z1)}]
	set c [expr {hypot(hypot($x0-$x2, $y0-$y2), $z0-$z2)}]
	set s [expr {($a + $b + $c) / 2.0}]
	set w [expr {$s * ($s-$a) * ($s-$b) * ($s-$c)}]
	if {$w < 0} { return 0}
	return [expr {sqrt($w)}]
}

#
#	Convert the loaded tin to an esri (.asc) or grass (.arx) ascii grid
#	If no corners (x0,y0,x1,y1) given MBR used.
#	@param gridname name of the grid file
#	@param dx resolution of grid
#	@param x0,y0 lower left corner of grid (optional)
#	@param x1,y1 upper right corner of grid (optional)
#	@param vrml generate vrml output
#	@return 0 OK
#			-1 grid too dense
#			-2 no tin loaded
#			-3 file open error
proc tin2grid {gridname dx {xmi ""} {ymi ""} {xma ""} {yma ""} {vrml 0}} {
	global tinLoaded
	global geoEasyMsg
	global tcl_platform

	if {$dx < 0.01} {
		return -1
	}
	set dy $dx
	if {![string length $tinLoaded]} {
		return -2
	}
	set tin $tinLoaded
	global ${tin}_ele ${tin}_node ${tin}_poly ${tin}_hole
	if {$xmi == "" || $ymi == "" || $xma == "" || $yma == ""} {
		set xmi 1e39
		set ymi 1e39
		set zmi 1e39
		set xma -1e39
		set yma -1e39
		set zma -1e39
		foreach id [array names ${tin}_node] {
			set p [set ${tin}_node($id)]
			set xx [lindex $p 0]
			set yy [lindex $p 1]
			set zz [lindex $p 2]
			if {$xx < $xmi} {set xmi $xx}
			if {$yy < $ymi} {set ymi $yy}
			if {$zz < $zmi} {set zmi $zz}
			if {$xx > $xma} {set xma $xx}
			if {$yy > $yma} {set yma $yy}
			if {$zz > $zma} {set zma $zz}
		}
	}
	set x0 [expr {(int($xmi / $dx)) * $dx}]
	set y0 [expr {(int($ymi / $dy)) * $dy}]
	set x1 [expr {(int($xma / $dx)) * $dx}]
	set y1 [expr {(int($yma / $dy)) * $dy}]
	set n [expr {int(($y1 - $y0) / $dy) + 1}]
	set m [expr {int(($x1 - $x0) / $dx) + 1}]
	# init grid with NODATA
	for {set i 0} {$i < $n} {incr i} {
		for {set j 0} {$j < $m} {incr j} {
			set grd($i,$j) -9999
		}
	}
	# calculate grid values
	foreach i [array names ${tin}_ele] {
		set triang [set ${tin}_ele($i)]
		set p1 [set ${tin}_node([lindex $triang 0])]
		set p2 [set ${tin}_node([lindex $triang 1])]
		set p3 [set ${tin}_node([lindex $triang 2])]
		set x1 [lindex $p1 0]
		set y1 [lindex $p1 1]
		set z1 [lindex $p1 2]
		set x2 [lindex $p2 0]
		set y2 [lindex $p2 1]
		set z2 [lindex $p2 2]
		set x3 [lindex $p3 0]
		set y3 [lindex $p3 1]
		set z3 [lindex $p3 2]
		set area0 [Area $x1 $y1 0 $x2 $y2 0 $x3 $y3 0]
		set xmin [min $x1 $x2 $x3]
		set ymin [min $y1 $y2 $y3]
		set zmin [min $z1 $z2 $z3]
		set xmax [expr {[max $x1 $x2 $x3] + 0.01}]
		set ymax [expr {[max $y1 $y2 $y3] + 0.01}]
		set zmax [max $z1 $z2 $z3]
		set xmingrid [expr {(int($xmin / $dx)) * $dx}]
		set ymingrid [expr {(int($ymin / $dy)) * $dy}]
		for {set xgrid $xmingrid} {$xgrid < $xmax} {set xgrid [expr {$xgrid + $dx}]} {
			for {set ygrid $ymingrid} {$ygrid < $ymax} {set ygrid [expr {$ygrid + $dy}]} {
				# xgrid, ygrid in the triangle ?
				set area1 [Area $x1 $y1 0 $x2 $y2 0 $xgrid $ygrid 0]
				set area2 [Area $x1 $y1 0 $x3 $y3 0 $xgrid $ygrid 0]
				set area3 [Area $x3 $y3 0 $x2 $y2 0 $xgrid $ygrid 0]
				set area123 [expr {$area1 + $area2 + $area3}]
				if {[expr {abs($area0 - $area123)}] < 0.01} {
					# normal vector (dy1 dx1 dz1) x (dy2 dx2 dz2)
					set dx1 [expr {double($x1 - $x2)}]
					set dy1 [expr {double($y1 - $y2)}]
					set dz1 [expr {double($z1 - $z2)}]
					set dx2 [expr {double($x3 - $x2)}]
					set dy2 [expr {double($y3 - $y2)}]
					set dz2 [expr {double($z3 - $z2)}]
					set a [expr {$dy1 * $dz2 - $dy2 * $dz1}]
					set b [expr {$dx2 * $dz1 - $dx1 * $dz2}]
					set c [expr {$dx1 * $dy2 - $dx2 * $dy1}]
					set w [expr {sqrt($a * $a + $b * $b + $c * $c)}]
					set a [expr {$a / $w}]
					set b [expr {$b / $w}]
					set c [expr {$c / $w}]
					set d [expr { -($a * $x1 + $b * $y1 + $c * $z1)}]
					set zz [expr {(-$d - $a * $xgrid - $b * $ygrid) / $c}]
					set k [expr {int(($xgrid - $x0) / $dx + 0.001)}]
					set j [expr {int(($ygrid - $y0) / $dy + 0.001)}]
# TBD miert esik kivul az interpolalt ertek????
					if {$zmin > $zz} {
						set zz $zmin
#						GeoLog1 "min $zz - $zmin"
					}
					if {$zz > $zmax} {
						set zz $zmax
#						GeoLog1 "max $zz - $zmax"
					}
					set grd($j,$k) $zz
				}
			}
		}
	}
	set fmt [string tolower [file extension $gridname]]
	if {[string length $fmt]} {
		# output grid
		if {[catch {set f [open $gridname w]}]} {
			return -3
		}
		switch -exact -- $fmt {
			".asc" {
				puts $f "ncols $m"
				puts $f "nrows $n"
				puts $f "xllcorner $x0"
				puts $f "yllcorner $y0"
				puts $f "cellsize $dx"
				puts $f "nodata_value -9999"
			}
			".arx" {
				puts $f "north: $y1"
				puts $f "south: $y0"
				puts $f "east: $x0"
				puts $f "west: $x1"
				puts $f "rows: $n"
				puts $f "cols: $m"
				puts $f "null: -9999"
			}
		}
		for {set i [expr {$n - 1}]} {$i >= 0} {incr i -1} {
			for {set j 0} {$j < $m} {incr j} {
				if {$grd($i,$j) < -9998} {
					puts -nonewline $f "[format %d $grd($i,$j)] "
				} else {	
					puts -nonewline $f "[format %.2f $grd($i,$j)] "
				}
			}
			puts $f ""
		}
		close $f
	}
	if {$vrml} {
		set fmt "[file rootname $gridname].wrl"
		if {[catch {set f [open $fmt w]}]} {
			return -3
		}
		puts $f "#VRML V2.0 utf8"
		puts $f "# Created by GeoEasy DTM extension"
		puts $f "# www.digikom.hu"
		puts $f "Background \{"
		puts $f "skyColor \[0.0 0.0 0.9\]"
		puts $f "\}"
		puts $f "Shape \{ appearance Appearance \{material Material \{diffuseColor 0.5 0.5 0.5\}\}"
		puts $f "geometry ElevationGrid \{"
		puts $f " xDimension $n"
		puts $f " zDimension $m"
		puts $f " xSpacing $dx"
		puts $f " zSpacing $dx"
		puts $f " height \["
		for {set i [expr {$n - 1}]} {$i >= 0} {incr i -1} {
			for {set j 0} {$j < $m} {incr j} {
				if {$grd($i,$j) < -9998} {
					# use minz instead of nodata
					puts -nonewline $f "[format %.2f $zmi] "
				} else {	
					puts -nonewline $f "[format %.2f $grd($i,$j)] "
				}
			}
			puts $f ","
		}
		puts $f " \] \} \}"
		close $f
		if {[tk_dialog .msg $geoEasyMsg(info) $geoEasyMsg(openit) info 0 \
			$geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
			if {[ShellExec $target]} {
				tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(rtfview) \
					warning 0 OK
			}
		}
	}
	return 0
}

#	Export TIN to ESRI ARCII GRID format
proc CreateGrid {} {
	global lastDir
	global reg
	global geoEasyMsg
	global gridDX gridVrml
	global buttonid
	global grdTypes
	global saveType

	set filen [string trim [tk_getSaveFile -filetypes $grdTypes \
		-typevariable saveType -initialdir $lastDir]]
	# string match is used to avoid silly Windows 10 bug
	if {[string length $filen] && [string match "after#*" $filen] == 0} {
        # some extra work to get extension for windows
        regsub "\\(.*\\)$" $saveType "" saveType
        set saveType [string trim $saveType]
        set typ [lindex [lindex $grdTypes [lsearch -regexp $grdTypes $saveType]] 1]
        if {[string match -nocase "*$typ" $filen] == 0} {
            set filen "$filen$typ"
        }
		set lastDir [file dirname $filen]
		GridParams
		tkwait window .gridparams
		if {$buttonid} { return }
		if {[regexp $reg(2) $gridDX] == 0} {
			tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
				error 0 OK	
			return
		}
		tin2grid $filen $gridDX "" "" "" "" $gridVrml
		GeoLog "$geoEasyMsg(menuDtmGrid) $filen"
	}
}

#	Get GRID resolution
proc GridParams {} {
	global gridDX gridVrml
	global buttonid
	global geoEasyMsg

	set w [focus]
	if {$w == ""} { set w "." }
	set this .gridparams
	set buttonid 0
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}

	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(gridtitle)
	wm resizable $this 0 0
	wm transient $this $w
	catch {wm attribute $this -topmost}
	label $this.ldx -text $geoEasyMsg(griddx)
	entry $this.dx -textvariable gridDX -width 10
	checkbutton $this.vrml -text $geoEasyMsg(gridvrml) -variable gridVrml
	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"
	grid $this.ldx -row 0 -column 0
	grid $this.dx -row 0 -column 1
	grid $this.vrml -row 1 -column 0
	grid $this.exit -row 2 -column 0
	grid $this.cancel -row 2 -column 1
	tkwait visibility $this
	CenterWnd $this
	grab set $this
}

#
#	Dialog interface to interpolate z along a line from dtm
proc DtmInterpolateDialog {} {
	global geoEasyMsg
	global buttonid
	global xInterp yInterp x1Interp y1Interp stepInterp dxfProfile cooProfile
	global gwin

	set w [focus]
	set gwin [winfo toplevel $w]
	if {$w == ""} { set w "." }
	set this .interpolatedia
	set buttonid 0
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}
	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(interptitle)
	wm resizable $this 0 0
	wm transient $this $w
	catch {wm attribute $this -topmost}
	label $this.lx -text $geoEasyMsg(lx)
	entry $this.x -textvariable xInterp -width 10
	label $this.ly -text $geoEasyMsg(ly)
	entry $this.y -textvariable yInterp -width 10
	label $this.lx1 -text $geoEasyMsg(lx1)
	entry $this.x1 -textvariable x1Interp -width 10
	label $this.ly1 -text $geoEasyMsg(ly1)
	entry $this.y1 -textvariable y1Interp -width 10
	label $this.lstep -text $geoEasyMsg(lstep)
	entry $this.step -textvariable stepInterp -width 10
	checkbutton $this.dxf -text $geoEasyMsg(ldxf) -variable dxfProfile
	checkbutton $this.coo -text $geoEasyMsg(lcoo) -variable cooProfile
	button $this.exit -text $geoEasyMsg(ok) \
		-command {destroy .interpolatedia
					global gwin
					DtmProfile $gwin}
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"
	
	grid $this.lx -row 0 -column 0 -sticky w
	grid $this.ly -row 1 -column 0 -sticky w
	grid $this.lx1 -row 2 -column 0 -sticky w
	grid $this.ly1 -row 3 -column 0 -sticky w
	grid $this.lstep -row 4 -column 0 -sticky w
	grid $this.x -row 0 -column 1 -sticky w
	grid $this.y -row 1 -column 1 -sticky w
	grid $this.x1 -row 2 -column 1 -sticky w
	grid $this.y1 -row 3 -column 1 -sticky w
	grid $this.step -row 4 -column 1 -sticky w
	grid $this.dxf -row 5 -column 1 -sticky w
	grid $this.coo -row 6 -column 1 -sticky w
	grid $this.exit -row 7 -column 1
	grid $this.cancel -row 7 -column 0
	tkwait visibility $this
	CenterWnd $this
	grab set $this
}

#	Interpolate along a line
#	Section line parameters come from global variables
proc DtmProfile {this} {
	global geoEasyMsg
	global lastDir
	global tcl_platform dxfview
	global decimals
	global reg
	global xInterp yInterp x1Interp y1Interp stepInterp dxfProfile cooProfile
	global cadTypes fileTypes

	set can $this.map.c
	if {[regexp $reg(2) $xInterp] == 0 || [regexp $reg(2) $yInterp] == 0} {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
			error 0 OK
		return
	}
	if {$x1Interp == "" && $y1Interp == ""} {
		# calculate elevation at a single point
		set cx [GeoX $can $xInterp]	;# calculate canvas coords
		set cy [GeoY $can $yInterp]
		set z [InterpolateTin $this $cx $cy]
		GeoLog1
		GeoLog $geoEasyMsg(menuDtmInterp)
		GeoLog1 [format "%.${decimals}f %.${decimals}f %.${decimals}f" $xInterp $yInterp $z]
		return
	} elseif {[regexp $reg(2) $x1Interp] == 0 || \
		[regexp $reg(2) $y1Interp] == 0 || [regexp $reg(2) $stepInterp] == 0} {
		tk_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
			error 0 OK
		return
	}
	GeoLog1
	GeoLog $geoEasyMsg(menuDtmInterp)
	GeoLog1 [format "%.${decimals}f, %.${decimals}f - %.${decimals}f, %.${decimals}f %s %.${decimals}f" $xInterp $yInterp $x1Interp $y1Interp $geoEasyMsg(lstep) $stepInterp]
	if {$dxfProfile} {
		set filen [string trim [tk_getSaveFile -filetypes $cadTypes \
			-defaultextension ".dxf" -initialdir $lastDir]]
		if {[string length $filen] == 0 || [string match "after#*" $filen]} {
			return
		}
        set lastDir [file dirname $filen]
		if {[catch {set fd [open $filen w]} msg]} {
			tk_dialog .msg $geoEasyMsg(error) "$geoEasyMsg(-1): $msg" \
				error 0 OK
			return
		}
		puts $fd "  0\nSECTION\n  2\nENTITIES"
	}
	if {$cooProfile} {
		set typ [list [lindex $fileTypes [lsearch -glob $fileTypes "*.geo*"]]]
		set fn [string trim [tk_getSaveFile -filetypes $typ \
			-defaultextension ".geo" -initialdir $lastDir]]
		if {[string length $fn] == 0 || [string match "after#*" $fn]} {
			return
		}
        set lastDir [file dirname $fn]
		if {[catch {set fc [open $fn w]} msg]} {
			tk_dialog .msg $geoEasyMsg(error) "$geoEasyMsg(-1): $msg" \
				error 0 OK
			return
		}
        set fn "[file rootname $fn].geo"
        # create empty geo
        set fc [open $fn "w"]
        close $fc
		# create coo
        set fn "[file rootname $fn].coo"
        set fc [open $fn "w"]
	} 
	set d [Distance $xInterp $yInterp $x1Interp $y1Interp]
	for {set i 0} {$i < $d} {set i [expr {$i + $stepInterp}]} {
		set x [expr {$xInterp + ($x1Interp - $xInterp) / $d * $i}]
		set y [expr {$yInterp + ($y1Interp - $yInterp) / $d * $i}]
		set cx [GeoX $can $x]	;# calculate canvas coords
		set cy [GeoY $can $y]
		set z [InterpolateTin $this $cx $cy]
# TODO mi van ha szakadas van a metszetben? (lyuk a dtm-ben)
		GeoLog1 [format "%.${decimals}f %.${decimals}f %.${decimals}f %.${decimals}f" $x $y $z $i]
		if {$dxfProfile} {
			if {$i >= $stepInterp && $last_z > -9999 && $z > -9999} {
				puts $fd "  0\nLINE\n  8\nPROFIL"
				puts $fd " 10\n$last_i\n 20\n$last_z"
				puts $fd " 11\n$i\n 21\n$z"
			}
			set last_i $i
			set last_z $z
		}
		if {$cooProfile} {
			puts $fc [list [list 5 s$i] [list 38 $x] [list 37 $y] [list 39 $z]]
		}
	}
	set cx [GeoX $can $x1Interp]	;# calculate canvas coords
	set cy [GeoY $can $y1Interp]
	set z [InterpolateTin $this $cx $cy]
	GeoLog1 [format "%.${decimals}f %.${decimals}f %.${decimals}f %.${decimals}f" $x1Interp $y1Interp $z $d]
	if {$dxfProfile && $last_z > -9999 && $z > -9999} {
		puts $fd "  0\nLINE\n  8\nPROFIL"
		puts $fd " 10\n$last_i\n 20\n$last_z"
		puts $fd " 11\n$d\n 21\n$z"
	}
	if {$dxfProfile} {
		puts $fd "  0\nENDSEC\n  0\nEOF"
		close $fd
		if {[tk_dialog .msg $geoEasyMsg(info) $geoEasyMsg(openit) info 0 \
			$geoEasyMsg(yes) $geoEasyMsg(no)] == 0} {
			if {[ShellExec $filen]} {
				tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(rtfview) \
					warning 0 OK
			}
		}
	}
	if {$cooProfile} {
		puts $fc [list [list 5 s$i] [list 38 $x1Interp] [list 37 $y1Interp] [list 39 $z]]
		close $fc
	}
}

#
#	Export TIN to LandXML format
proc LandXMLOut {} {
	global tinLoaded
	global geoEasyMsg
	global version
	global lastDir
	global decimals

	set fn [string trim [tk_getSaveFile -defaultextension ".xml" \
		-filetypes {{"LandXML" {.xml}}} -initialdir $lastDir]]
	if {[string length $fn] == 0 || [string match "after#*" $fn]} { return }
	set lastDir [file dirname $fn]
	if {[catch {set f [open $fn "w"]} msg] == 1} {
		tk_dialog .msg $geoEasyMsg(error) "$geoEasyMsg(cantSave)\n$msg" error 0 OK
		return
	}
	# XML header
	puts $f "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	set w [clock seconds]
	set d [clock format $w -format "%Y.%m.%d"]
	set t [clock format $w -format "%H:%M:%S"]
	puts $f "<LandXML xmlns=\"http://www.landxml.org/schema/LandXML-1.1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.landxml.org/schema/LandXML-1.1 http://www.landxml.org/schema/LandXML-1.1/LandXML-1.1.xsd\" version=\"1.0\" date=\"$d\" time=\"$t\" readOnly=\"false\" language=\"English\">"
	puts $f "<Units>"
	puts $f "<Metric linearUnit=\"meter\" areaUnit=\"squareMeter\" volumeUnit=\"cubicMeter\" temperatureUnit=\"celsius\" pressureUnit=\"mmHG\" angularUnit=\"decimal degrees\" directionUnit=\"decimal degrees\"/>"
	puts $f "</Units>"
	puts $f "<Application name=\"GeoEasy\" manufacturer=\"DigiKom\" version=\"$version\" desc=\"GeoEasy for all surveyers\" manufacturerURL=\"www.digikom.hu\"/>"
	puts $f "<Surfaces>"
	puts $f "<Surface name=\"$tinLoaded\">"
	puts $f "<Definition surfType=\"TIN\">"
	# TIN nodes
	global ${tinLoaded}_node
	puts $f "<Pnts>"
	foreach i [lsort -integer [array names ${tinLoaded}_node]] {
		set t [set ${tinLoaded}_node($i)]
		puts $f [format "<P id=\"%d\">%.${decimals}f %.${decimals}f %.${decimals}f</P>" $i [lindex $t 0] [lindex $t 1] [lindex $t 2]]
	}
	puts $f "</Pnts>"
	# triangles
	global ${tinLoaded}_ele
	puts $f "<Faces>"
	foreach i [lsort -integer [array names ${tinLoaded}_ele]] {
		set t [set ${tinLoaded}_ele($i)]
		puts $f "<F>$t</F>" 
	}
	puts $f "</Faces>"
	puts $f "</Definition>"
	puts $f "</Surface>"
	puts $f "</Surfaces>"
	puts $f "</LandXML>"
	close $f
	return 0
}

#
#	Append another tin to the loaded one
#	@param tPath path to DTM to append
proc AppendTin {tn} {
	global tinLoaded tinPath

	set tinName $tinLoaded
	global ${tinName}_node
	global ${tinName}_poly
	global ${tinName}_hole

	set savePath [file join $tinPath $tinLoaded]
	set tPath [file join [file dirname $tn] [file rootname $tn]]
	set tName [file tail $tPath]
	global ${tName}_node
	global ${tName}_poly
	global ${tName}_hole
	catch {unset ${tName}_node}
	catch {unset ${tName}_poly}
	catch {unset ${tName}_hole}
	# copy old elements to new arrays
	foreach i [lsort -integer [array names ${tinName}_node]] {
		set node($i) [set ${tinLoaded}_node($i)]
	}
	set n [array size ${tinName}_node]
	set n_old $n
	# load new nodes
	LoadTinNodes $tPath

	foreach i [lsort -integer [array names ${tName}_node]] {
		set node($n) [set ${tName}_node($i)]
		incr n
	}
	# copy old breaklines to new array
	foreach i [lsort -integer [array names ${tinName}_poly]] {
		set poly($i) [set ${tinLoaded}_poly($i)]
	}
	set np [array size ${tinName}_poly]
	# load new polys, holes and add to new arrays
	LoadTinPoly $tPath
	foreach i [lsort -integer [array names ${tName}_poly]] {
		set l [set ${tName}_poly($i)]
		set ll [list [expr {[lindex $l 0] + $n_old}] [expr {[lindex $l 1] + $n_old}]]
		set poly($np) $ll
		incr np
	}
	# copy old holes to new array
	set nh [array size ${tinName}_hole]
	foreach i [lsort -integer [array names ${tinName}_hole]] {
		set hole($i) [set ${tinLoaded}_hole($i)]
	}
	# add from second
	foreach i [lsort -integer [array names ${tName}_hole]] {
		set hole($nh) [set ${tName}_hole($i)]
		incr nh
	}
	# write nodes to file
	set polyname [file join $tinPath tmp.poly]
	set f [open $polyname w]
	puts $f "$n 2 1 0"	;# header for nodes
	if { $n } {
		foreach i [lsort -integer [array names node]] {
			puts $f "$i $node($i)"
		}
	}
	# write polys to file
	puts $f "$np 0"
	if { $np } {
		foreach i [lsort -integer [array names poly]] {
			puts $f "$i $poly($i)"
		}
	}
	puts $f "$nh 0"
	if { $nh } {
		foreach i [lsort -integer [array names hole]] {
			puts $f "$i $hole($i)"
		}
	}
	close $f
	catch {unset node poly hole}
	catch {unset ${tName}_node ${tName}_poly ${tName}_hole}
	UnloadTin	;# unload first TIN
	global dtmhoriz dtmconvex
	set dtmhoriz 0
	set dtmconvex 0
	CreateTin $polyname $savePath
}
