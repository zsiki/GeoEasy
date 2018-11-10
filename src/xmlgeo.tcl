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

#	Export observations for 3D (3D network) adjustment for gnu-gama
#	gama xml file is created (.g3d)
#	all loaded data sets are considered
#	@param pns unknown points list
proc GeoNet3D {{pns ""}} {
	global geoEasyMsg
	global geoLang geoCp
	global env
	global home
	global lastDir
	global gamaProg gamaConf gamaAngles gamaTol gamaShortOut gamaSvgOut

	if {[info exists env(TMP)]} {
		set tmpname $env(TMP)
	} elseif {[info exists env(TEMP)]} {
		set tmpname $env(TEMP)
	} else {
		set tmpname "."
	}
	set tmpname [file join  $tmpname tmp.g3d]
	catch {file delete [glob "${tmpname}*"]}
	if {[GamaExport "$tmpname" $pns] == 0} { return }
	if {$gamaSvgOut} {
		# save svg out 
		set filen [string trim [tk_getSaveFile -filetypes \
			{{"Scalable Vector Graphics SVG" {.svg}}} \
			-defaultextension ".svg" -initialdir $lastDir]]
		if {[string length $filen] == 0 || [string match "after#*" $filen]} {
			return
		}
		if {[catch {eval [concat exec "{$gamaProg} --language [string range $geoLang 0 1] --encoding $geoCp --angles $gamaAngles --xml \"${tmpname}.xml\" --text \"${tmpname}.txt\" --svg \"${filen}\" \"$tmpname\""]} msg]} {
			tk_dialog .msg $geoEasyMsg(error) $msg error 0 OK
			return
		}
	} else {
		if {[catch {eval [concat exec "{$gamaProg} --language [string range $geoLang 0 1] --encoding $geoCp --angles $gamaAngles --xml \"${tmpname}.xml\" --text \"${tmpname}.txt\" \"$tmpname\""]} msg]} {
			tk_dialog .msg $geoEasyMsg(error) $msg error 0 OK
			return
		}
	}
	if {! $gamaShortOut} {
		if {[file exists "${tmpname}.txt"]} {
			set fn "${tmpname}.txt"
			# add result to log
			set f [open $fn "r"]
			while { ! [eof $f]} {
				GeoLog1 [gets $f]
			}
			close $f
			catch {file delete "${tmpname}.txt"}
		} else {
			GeoLog1 $geoEasyMsg(gamanull)
		}
	}
	# read back coordinates and orientations from tmp.g3d.xml
	if {[file exists "${tmpname}.xml"]} {
		ProcessXml "${tmpname}.xml"
	} else {
		GeoLog1 $geoEasyMsg(gamanull1)
	}
}

#
#	Export observations for 2D (horizontal network) adjustment for gnu-gama
#	gama xml file is created (.g2d)
#	all loaded data sets are considered
#	@param pns optional list of unknowns
proc GeoNet2D {{pns ""}} {
	global geoEasyMsg
	global geoLang geoCp
	global env
	global home
	global lastDir
	global gamaProg gamaConf gamaAngles gamaTol gamaShortOut gamaSvgOut

	if {[info exists env(TMP)]} {
		set tmpname $env(TMP)
	} elseif {[info exists env(TEMP)]} {
		set tmpname $env(TEMP)
	} else {
		set tmpname "."
	}
	set tmpname [file join  $tmpname tmp.g2d]
	catch {file delete [glob "${tmpname}*"]}
	if {[GamaExport "$tmpname" $pns] == 0} { return }
	if {$gamaSvgOut} {
		# save svg out 
		set filen [string trim [tk_getSaveFile -filetypes \
			{{"Scalable Vector Graphics SVG" {.svg}}} \
			-defaultextension ".svg" -initialdir $lastDir]]
		if {[string length $filen] == 0 || [string match "after#*" $filen]} {
			return
		}
		if {[catch {eval [concat exec "{$gamaProg} --language [string range $geoLang 0 1] --encoding $geoCp --angles $gamaAngles --xml \"${tmpname}.xml\" --text \"${tmpname}.txt\" --svg \"${filen}\" \"$tmpname\""]} msg]} {
			tk_dialog .msg $geoEasyMsg(error) $msg error 0 OK
			return
		}
	} else {
		if {[catch {eval [concat exec "{$gamaProg} --language [string range $geoLang 0 1] --encoding $geoCp --angles $gamaAngles --xml \"${tmpname}.xml\" --text \"${tmpname}.txt\" \"$tmpname\""]} msg]} {
			tk_dialog .msg $geoEasyMsg(error) $msg error 0 OK
			return
		}
	}
	if {! $gamaShortOut} {
		if {[file exists "${tmpname}.txt"]} {
			set fn "${tmpname}.txt"
			# add result to log
			set f [open $fn "r"]
			while { ! [eof $f]} {
				GeoLog1 [gets $f]
			}
			close $f
			catch {file delete "${tmpname}.txt"}
		} else {
			GeoLog1 $geoEasyMsg(gamanull)
		}
	}
	# read back coordinates and orientations from tmp.g2d.xml
	if {[file exists "${tmpname}.xml"]} {
		ProcessXml "${tmpname}.xml"
	} else {
		GeoLog1 $geoEasyMsg(gamanull1)
	}
}

#
#	Export observations for 1D (elevation) adjustment for gnu-gama
#	gama xml file is created (.g1d)
#	all loaded data sets are considered
#	@param pns optional list of unknowns
proc GeoNet1D {{pns ""}} {
	global geoEasyMsg
	global geoLang geoCp
	global env
	global home
	global gamaProg gamaConf gamaAngles gamaTol gamaShortOut gamaSvgOut

	if {[info exists env(TMP)]} {
		set tmpname $env(TMP)
	} elseif {[info exists env(TEMP)]} {
		set tmpname $env(TEMP)
	} else {
		set tmpname "."
	}
	set tmpname [file join  $tmpname tmp.g1d]
		catch {file delete [glob "${tmpname}*"]}
	if {[GamaExport "$tmpname" $pns] == 0} { return }
	if {[catch {eval [concat exec "{$gamaProg} --language [string range $geoLang 0 1] --encoding $geoCp --angles $gamaAngles --xml \"${tmpname}.xml\" --text \"${tmpname}.txt\" \"$tmpname\""]} msg]} {
		tk_dialog .msg  $geoEasyMsg(error) $msg error 0 OK
		return
	}
	if {! $gamaShortOut} {
		if {[file exists "${tmpname}.txt"]} {
			set fn "${tmpname}.txt"
# add result to log
				set f [open $fn "r"]
				while { ! [eof $f]} {
					GeoLog1 [gets $f]
				}
			close $f
				catch {file delete "${tmpname}.txt"}
		} else {
			GeoLog1 $geoEasyMsg(gamanull)
		}
	}
# read back coordinates and orientations from tmp.g1d.xml
	if {[file exists "${tmpname}.xml"]} {
		ProcessXml "${tmpname}.xml"
	} else {
		GeoLog1 $geoEasyMsg(gamanull1)
	}
}

#
#	Export observations for adjustment for gnu-gama
#	gama xml file is created (.g1d/.g2d/.g3d)
#	all loaded data sets are considered
#	@param fn output file name, extension defines the type of network
#			 .g1d elevation network, .g2d horizontal network
#			 .g3d 3d network optional (default selected byuser)
#	@param pns list of unknown points optional (default selected by user)
#	@param fixed list of fixed points optional (default selected by user, "all" can be used)
proc GamaExport {{fn ""} {pns ""} {fixed ""}} {
	global xmlTypes lastDir
	global geoEasyMsg
	global oriDetail
	global saveType

	GeoLog1
	if {[string length $fn] == 0} {
		set fn [string trim [tk_getSaveFile -filetypes $xmlTypes \
			-initialdir $lastDir -typevariable saveType]]
		if {[string length $fn] == 0 || [string match "after#*" $fn]} { return }
		# some extra work to get extension for windows
        regsub "\\(.*\\)$" $saveType "" saveType
        set saveType [string trim $saveType]
        set typ [lindex [lindex $xmlTypes [lsearch -regexp $xmlTypes $saveType]] 1]
        if {[string match -nocase "*$typ" $fn] == 0} {
            set fn "$fn$typ"
        }

		GeoLog "$geoEasyMsg(menuFileExport) $fn"
	} else {
		switch -exact [file extension $fn] {
			".g1d" {
						GeoLog $geoEasyMsg(menuCalAdj1D)
			}
			".g2d" {
						GeoLog $geoEasyMsg(menuCalAdj2D)
			}
			".g3d" {
						GeoLog $geoEasyMsg(menuCalAdj3D)
			}
		}
	}
	if {$oriDetail} {
		set used [GetAll]				;# include detail points
	} else {
		set used [GetBase]				;# points are not details
	}
	set used [UsedPointsOnly $used]	;# get point numbers of observed points
	switch -exact [file extension $fn] {
		".g2d" {
			set used [KnownPointsOnly $used];# at least appr. e and n coordinates
			if {[llength $used] > 0} {		;# there are observed points
				set used [lsort -dictionary $used]
				if {[llength $pns]} {
					set unknowns $pns
				} else {
					set unknowns [GeoListbox $used 0 $geoEasyMsg(lbTitle2) -1]
				}
				if {[llength $unknowns] > 0} {
					if {[llength $fixed]} {
						if {[string compare $fixed "all"] == 0} {
							set fixed [lsort -dictionary [ldiff [GetGiven {37 38} $used] $unknowns]]
						}
					} else {
						set fixed [lsort -dictionary [ldiff [GetGiven {37 38} $used] $unknowns]]
						if {[llength $fixed]} {
							set fixed [GeoListbox $fixed 0 $geoEasyMsg(lbTitle5) 0]
						}
					}
					Gama2dXmlOut $fn $unknowns $fixed
					return 1
				}
			} else {
				tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noUnknowns) \
					warning 0 OK
			}
		}
		".g1d" {
			set used [KnownZPointsOnly $used];# at least appr. z coordinates
			if {[llength $used] > 0} {		;# there are observed points
				set used [lsort -dictionary $used]
				if {[llength $pns]} {
					set unknowns $pns
				} else {
					set unknowns [GeoListbox $used 0 $geoEasyMsg(lbTitle2) -1]
				}
				if {[llength $unknowns] > 0} {
					if {[llength $fixed]} {
						if {[string compare $fixed "all"] == 0} {
							set fixed [lsort -dictionary [ldiff [GetGiven {39} $used] $unknowns]]
						}
					} else {
						set fixed [lsort -dictionary [ldiff [GetGiven {39} $used] $unknowns]]
						if {[llength $fixed]} {
							set fixed [GeoListbox $fixed 0 $geoEasyMsg(lbTitle5) 0]
						}
					}
					Gama1dXmlOut $fn $unknowns $fixed
					return 1
				}
			} else {
				tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noUnknowns) \
					warning 0 OK
			}
		}
		".g3d" {
			set used [Known3DPointsOnly $used];# at least appr. coordinates
			if {[llength $used] > 0} {		;# there are observed points
				set used [lsort -dictionary $used]
				if {[llength $pns]} {
					set unknowns $pns
				} else {
					set unknowns [GeoListbox $used 0 $geoEasyMsg(lbTitle2) -1]
				}
				if {[llength $unknowns] > 0} {
					if {[llength $fixed]} {
						if {[string compare $fixed "all"] == 0} {
							set fixed [lsort -dictionary [ldiff [GetGiven {37 38 39} $used] $unknowns]]
						}
					} else {
						set fixed [lsort -dictionary [ldiff [GetGiven {37 38 39} $used] $unknowns]]
						if {[llength $fixed]} {
							set fixed [GeoListbox $fixed 0 $geoEasyMsg(lbTitle5) 0]
						}
					}
					Gama3dXmlOut $fn $unknowns $fixed
					return 1
				}
			} else {
				tk_dialog .msg $geoEasyMsg(warning) $geoEasyMsg(noUnknowns) \
					warning 0 OK
			}
		}
	}
	return 0
}


#
#	Calculate height difference & standard deviation
#	@param st station name
#	@param st_buf station record in geo data set
#	@param tg target name
#	@param tg_buf target record in geo data set
#	@param w1 stddev for leveling
#	@return list of height difference and standatd deviation
proc GetHdW {st st_buf tg tg_buf w1} {
	global projRed avgH stdAngle stdDist1 stdDist2 refr
	global dirLimit RO
	global stdLevel

	if {[info exists st_buf] == 0 || [info exists tg_buf] == 0} {
		return ""
	}
	# measured distance
	set sd [GetVal 9 $tg_buf]
	set z [GetVal 8 $tg_buf]
	set ih [GetVal 3 $st_buf]
	set th [GetVal 6 $tg_buf]
	if {$th == ""} {set th 0}	;# default taget height
	set d [GetVal 11 $tg_buf]
	set dm [GetVal 120 $tg_buf]
	if {($sd != "" || $d != "") && $z != "" && $ih != ""} {	;# trigonometric height diff
		if {$d == ""} {
			set d [expr {$sd * sin($z)}]	;# horizontal distance
			set dm [expr {$sd * cos($z) + $ih - $th}]
		}
		if {$sd == ""} {
			set sd [expr {$d / sin($z)}]
			set dm [expr {$d / tan($z) + $ih - $th}]
		}
		if {$d > 400 && $refr} {
			set dm [expr {$dm + [GetRefr $d]}]	;# refraction
		}
		# standard deviation
		set d1 [expr {pow(cos($z), 2) * pow($sd / 1000 * $stdDist2 + $stdDist1, 2)}]
		if {$sd < $dirLimit} {
			set s1 [expr {$stdAngle * $dirLimit / $sd}]
		} else {
			set s1 $stdAngle
		}
		set d2 [expr {pow($sd * 1000 * sin($z), 2) * pow($s1 / $RO, 2)}]
		set w [expr {sqrt($d1 + $d2)}]
		return [list $dm $w]
	} elseif {$d != "" && $dm != ""} {			;# levelling
		if {$w1 == ""} {
			set w1 $stdLevel
		}
		set w [expr {$d / 1000.0 * $w1}]	;# std dev
		return [list $dm $w]
	}
	return ""
}

#
#	Export observations into vertical network gnu-gama xml file
#	all loaded data sets are considered
#	@param fn output file name
#	@param pns list of unknown points (names)
#	@param fixed list of known points (names)
#	@flag do not show messages if 1 
proc Gama1dXmlOut {fn pns fixed {flag 0}} {
	global geoLoaded
	global geoEasyMsg
	global decimals
	global n nmeasure
	global stdAngle stdDist1 stdDist2 stdLevel
	global gamaProg gamaConf gamaAngles gamaTol gamaShortOut gamaSvgOut
	global SEC2CC

	set used ""
	set msg_flag 0	;# display warning on too large pure value
	set nmeasure 0
	set n [llength $pns]
	GeoDia .dia $geoEasyMsg(adjDia) nmeasure n	;# display dialog panel
	update
	set free_network [expr {([llength $fixed] == 0) ? 1 : 0}]
	set stpn ""
	#	get all observations from all loaded geo data sets
	foreach geo $geoLoaded {
		global ${geo}_geo ${geo}_par
		if {! [info exists ${geo}_par]} {
			set ${geo}_par ""	;# to avoid undefined variable
		}
		upvar #0 ${geo}_par par
		# standard deviations
		set stdL [GetVal 118 $par]
		if {$stdL == ""} {
			set stdL $stdLevel
		}
		foreach i [lsort -integer [array names ${geo}_geo]] {
			upvar #0 ${geo}_geo($i) pbuf
			if {[string length [GetVal 2 $pbuf]]} {
				# station record
				upvar #0 ${geo}_geo($i) stbuf
				set stpn [GetVal 2 $stbuf]
				set stcoo ""
				if {[lsearch -exact $pns $stpn] >= 0} {
					set newst 1			;# station is unknown point
					set stcoo [GetCoord $stpn 39 $geo]
					if {$stcoo == ""} {
						# use approximate coords
						set stcoo [GetCoord $stpn 139 $geo]
					}
				} elseif {[lsearch -exact $fixed $stpn] >= 0} {
					set newst 0			;# station is known point
					set stcoo [GetCoord $stpn 39 $geo]
				}
				if {$stcoo == ""} {
					set stpn ""	;# clear station number!
					continue	;# no coordinate for station skip it
				}
				set stz [GetVal {39 139} $stcoo]
			} else {
				# observation record
				set p [GetVal {5 62} $pbuf]	;# point number of other end
				set pcoo ""
				if {[lsearch -exact $pns $p] >= 0} {
					set newp 1			;# p is unknown point
					set pcoo [GetCoord $p 39 $geo]
					if {$pcoo == ""} {
						set pcoo [GetCoord $p 139 $geo]
					}
				} elseif {[lsearch -exact $fixed $p] >= 0} {
					set newp 0			;# p is known point
					set pcoo [GetCoord $p 39 $geo]
				}
				if {$pcoo == ""} {
					continue	;# no coordinate skip it
				}
				set pz [GetVal {39 139} $pcoo]
				if {$newst == 1 || $newp == 1} {
					# one end is unknown
					set ll [GetHdW $stpn $stbuf $p $pbuf $stdL]
					if {[llength $ll] == 0} {
						continue
					}
					set dm [lindex $ll 0]
					set w  [lindex $ll 1]
					# repeat count
					set nrep [GetVal 112 $pbuf]
					if {$nrep != ""} {
						set w [expr {$w / sqrt($nrep)}]
					}
					set measure($nmeasure) [list $stpn $p "V" $dm]
#					if {$w < 0.5} { set w 0.5 } ;# TODO set minimal weight
					set stddev($nmeasure) $w
					set pure [expr {$pz - $stz - $dm}]
					if {[expr {abs($pure)}] > [expr {0.05 * $w}] && \
							$flag == 0} {
						GeoLog1 [format "$geoEasyMsg(pure)" \
									$stpn E $p $pure]
						if {$msg_flag == 0} {
							switch -exact \
								[tk_dialog .msg $geoEasyMsg(warning) \
									[format "$geoEasyMsg(pure)" \
									$stpn $p E $pure] warning 0 OK \
									$geoEasyMsg(ignore) \
									$geoEasyMsg(cancel)] {
									
								1 {set msg_flag 1}
								2 {
									GeoLog1 $geoEasyMsg(cancelled)
									GeoDiaEnd .dia
									return 0
								}
							}
						}
					}
					if {[lsearch -exact $used $stpn] == -1} {
						lappend used $stpn
					}
					if {[lsearch -exact $used $p] == -1} {
						lappend used $p
					}
					incr nmeasure
					update
					if {$newst == 0 || $newp == 0} {
						set free_network 0
					}
				}
			}
		}
	}
	GeoDiaEnd .dia
	# xml output
	set xml [open $fn w]
	puts $xml "<?xml version=\"1.0\" ?>"
	puts $xml "<!DOCTYPE gama-xml SYSTEM \"gama-xml.dtd\">"
	puts $xml "<gama-local version=\"2.0\">"
	puts $xml "<network>"
	puts $xml "<description>"
	puts $xml "GeoEasy 1D network"
	puts $xml "</description>"
	puts $xml "<parameters sigma-apr = \"1\" conf-pr = \"$gamaConf\" tol-abs = \"$gamaTol\" sigma-act = \"aposteriori\" update-constrained-coordinates=\"yes\" />"
	puts $xml "<points-observations distance-stdev=\"$stdDist1 $stdDist2\" direction-stdev=\"[expr {round($stdAngle * $SEC2CC)}]\" angle-stdev=\"[expr {round($stdAngle * $SEC2CC * sqrt(2.0))}]\" zenith-angle-stdev=\"[expr {round($stdAngle * $SEC2CC)}]\" >"
	if {$free_network} {
		set adjz "Z"
	} else {
		set adjz "z"
	}
	foreach pn $used {
		if {[lsearch -exact $pns $pn] != -1} {
			# unknown for adjustment
			set pcoo [GetCoord $pn 39]
			if {$pcoo == ""} {
				set pcoo [GetCoord $pn 139]
				if {$pcoo == ""} {
					puts $xml "<point id=\"$pn\" adj=\"$adjz\" />"
				} else {
					puts $xml "<point id=\"$pn\" z=\"[format %.${decimals}f [GetVal 139 $pcoo]]\" adj=\"$adjz\" />"
				}
			} else {
				puts $xml "<point id=\"$pn\" z=\"[format %.${decimals}f [GetVal 39 $pcoo]]\" adj=\"$adjz\" />"
			}
		} else {
			set pcoo [GetCoord $pn 39]
			puts $xml "<point id=\"$pn\" z=\"[format %.${decimals}f [GetVal 39 $pcoo]]\" fix=\"z\" />"
		}
#		set adjz "z"
	}
	set last_st ""
	puts $xml "<height-differences>"
	for {set i 0} {$i < $nmeasure} {incr i} {
		switch -exact [lindex $measure($i) 2] {
			"V" {
				if {$stddev($i) <= 0} {
					set stddev($i) 0.1
				}
				puts $xml "<dh from=\"[lindex $measure($i) 0]\" to=\"[lindex $measure($i) 1]\" val=\"[format %.${decimals}f [lindex $measure($i) 3]]\" stdev=\"[format %.${decimals}f $stddev($i)]\" />"
			}
		}
	}
	puts $xml "</height-differences>"
	puts $xml "</points-observations>"
	puts $xml "</network>"
	puts $xml "</gama-local>"
	close $xml
}

#
#	Export observations into horizontal network gnu-gama xml file
#	all loaded data sets are considered
#	@param fn output file name
#	@param pns list of unknown points (names)
#	@param fixed list of fixed points (names)
#	@flag do not show messages if 1 
proc Gama2dXmlOut {fn pns fixed {flag 0}} {
	global projRed avgH refr
	global geoLoaded
	global geoEasyMsg
	global PI PI2
	global stdAngle stdDist1 stdDist2 stdLevel
	global dirLimit
	global decimals
	global autoRefresh
	global xmlTypes 
	global lastDir
	global decimals
	global n nmeasure
	global gamaProg gamaConf gamaAngles gamaTol gamaShortOut gamaSvgOut
	global RO
	global SEC2CC

	set nmeasure 0							;# number of observations considered
	set n [llength $pns]
	GeoDia .dia $geoEasyMsg(adjDia) nmeasure n	;# display dialog panel
	set stations ""							;# used station references
	set used ""								;# list of used points
	set zks ""								;# orientation ids for reoccupied stations
	set zkind ""							;# station recs for orientations
	# check for approximate coordinates for unknowns
	set free_network [expr {([llength $fixed] == 0) ? 1 : 0}]
	set msg_flag 0	;# display warning on too large pure value
	foreach pn $pns {
	#	get all references from all loaded geo data sets
		foreach geo $geoLoaded {
			global ${geo}_ref ${geo}_geo ${geo}_par
			if {! [info exists ${geo}_par]} {
				set ${geo}_par ""	;# to avoid undefined variable
			}
			if {[info exists ${geo}_ref($pn)]} {	;# point is referenced
				upvar #0 ${geo}_ref($pn) refs 
				upvar #0 ${geo}_par par
                # standard deviations
				set stdA [GetVal 114 $par]
				if {$stdA == ""} { set stdA $stdAngle}
				set stdD1 [GetVal 115 $par]
				if {$stdD1 == ""} { set stdD1 $stdDist1}
				set stdD2 [GetVal 116 $par]
				if {$stdD2 == ""} { set stdD2 $stdDist2}
				foreach ref $refs {
					upvar #0 ${geo}_geo($ref) stbuf
					set stpn [GetVal 2 $stbuf]
					set stref $ref
					if {$stpn == ""} {	;# not a station
						# go back to the station record
						while {$stref >=0 && [GetVal 2 $stbuf] == ""} {
							incr stref -1
							upvar #0 ${geo}_geo($stref) stbuf
						}
						if {$stref >= 0} {
							set stpn [GetVal 2 $stbuf]
						} else {
							tk_dialog .msg $geoEasyMsg(error) \
								$geoEasyMsg(noStation) error 0 OK
							GeoDiaEnd .dia
							return
						}
					}
					if {[lsearch -exact $stations "$geo $stref"] != -1} {
					# station already processed
						continue
					}
					lappend stations [list $geo $stref]	;# store processed stations
					set stcoo ""
					if {[lsearch -exact $pns $stpn] >= 0} {
						set newst 1			;# station is unknown point
						set stcoo [GetCoord $stpn {38 37} $geo]
						if {$stcoo == ""} {
							# use approximate coords
							set stcoo [GetCoord $stpn {138 137} $geo]
						}
					} elseif {[lsearch -exact $fixed $stpn] >= 0} {
						set newst 0			;# station is known point
						set stcoo [GetCoord $stpn {38 37} $geo]
					}
					if {$stcoo == ""} {
						continue	;# no coordinate for station skip it
					}
					set stx [GetVal {38 138} $stcoo]
					set sty [GetVal {37 137} $stcoo]
#
# go through the observations from this station and
# set up an equation for each horizontal distance
# if at least one end is unknown (eg. mentioned in pns list
# meanwhile count reference directions and other directions
#
					set refdir 0
					set othdir 0
					set lineno [expr {$stref + 1}]	;# first observation
					while {1} {
						if {[info exists ${geo}_geo($lineno)] == 0} {
							break		;# end of geo data set
						}
						upvar #0 ${geo}_geo($lineno) pbuf
						if {[GetVal 2 $pbuf] != ""} {
							break		;# next station reached
						}
						set p [GetVal {5 62} $pbuf]	;# point number of other end
#puts $dbg "iranyzott pont $p"
						set pcoo ""
						if {[lsearch -exact $pns $p] >= 0} {
							set newp 1			;# p is unknown point
							set pcoo [GetCoord $p {38 37} $geo]
							if {$pcoo == ""} {
								# use approximate coords
								set pcoo [GetCoord $p {138 137} $geo]
							}
						} elseif {[lsearch -exact $fixed $p] >= 0} {
							set newp 0			;# p is known point
							set pcoo [GetCoord $p {38 37} $geo]
						}
						if {$pcoo == ""} {
							incr lineno
							continue	;# no coordinate skip it
						}
						if {($newst == 1 || $newp == 1) && \
							([lsearch -exact $fixed $stpn] > -1 || \
							 [lsearch -exact $pns $stpn] > -1) && \
							([lsearch -exact $fixed $p] > -1 || \
							 [lsearch -exact $pns $p] > -1)} {
							# one end is unknown
							set d [GetVal 11 $pbuf]	;# horizontal distance
							set v ""	;# no reduction to horizont
							set dm ""
							if {$d == ""} {
								set d [GetVal 9 $pbuf]	;# slope distance
								set v [GetVal 8 $pbuf]	;# vertical angle
								if {$v == ""} {
									# try height difference
									set dm [GetVal 10 $pbuf]
									if {$dm == ""} {
										set ih [GetVal 3 $stbuf]
										set th [GetVal 6 $pbuf]
										set stz [GetVal 39 $stcoo]
										set pz [GetVal 39 $pcoo]
										if {$ih != "" && $th != "" && $stz != "" && $pz != ""} {
											set dm [expr {$pz - $stz - $ih + $th}]
										} else {
											set d ""		;# no horizontal distance
										}
									}
								}
							}
							if {$d != ""} {
								# reduce to horizontal and mean see level ...
								set d [GetRedDist $d $v $dm]
								# condition for distance
								set px [GetVal {38 138} $pcoo]
								set py [GetVal {37 137} $pcoo]
								set dist [Distance $px $py $stx $sty]
								set measure($nmeasure) [list $stpn $p "D" $d ""]
#puts $dbg "sorszam: $nmeasure meres: $measure($nmeasure)"
								# repeat count
								set nrep [GetVal 112 $pbuf]
								if {$nrep == "" || $nrep <= 0} { set nrep 1 }
								#  standard
								# dev [mm] = stdD1 + stdD2 * dist[km]
								set w [expr {($stdD1 + \
									$dist / 1000.0 * $stdD2) / sqrt($nrep)}]
								# std dev
								set stddev($nmeasure) $w
								set pure [expr {$dist - $d}]
								if {[expr {abs($pure)}] > [expr {50.0 * $w}] && \
										$flag == 0} {
									GeoLog1 [format "$geoEasyMsg(pure)" \
										$stpn $p D $pure]
									if {$msg_flag == 0} {
										switch -exact \
										[tk_dialog .msg $geoEasyMsg(warning) \
											[format "$geoEasyMsg(pure)" \
											$stpn $p D $pure] \
											warning 0 OK \
											$geoEasyMsg(ignore) \
											$geoEasyMsg(cancel)] {
											
											1 {set msg_flag 1}
											2 {
												GeoLog1 $geoEasyMsg(cancelled)
												GeoDiaEnd .dia
												return 0
											}
										}
									}
								}
								if {[lsearch -exact $used $stpn] == -1} {
									lappend used $stpn
								}
								if {[lsearch -exact $used $p] == -1} {
									lappend used $p
								}
								if {$newst == 0 || $newp == 0} {
									set free_network 0
								}
								incr nmeasure
								update
							}
							if {[GetVal {21 7} $pbuf] != ""} {
							# horizontal angle & coords are available
								if {$newst || $newp} {
									incr othdir
								} else {
									incr refdir
								}
							}
						}
						incr lineno
					}
#
# go through the observations from this station and
# set up an equation for each horizontal angle
# if at least one new point is shot at and at least two directions observed
#
					if {$othdir == 0 || [expr {$othdir + $refdir}] < 2} {
					# no unkonw point or only one direction
						continue
					}
					set zk [GetVal {101 103} $stbuf]	;# orientation
					if {$zk == ""} {
						if {$flag == 0} {
							GeoLog1 "$geoEasyMsg(noOri1) $stpn"
							set w [tk_dialog .msg $geoEasyMsg(warning) \
								"$geoEasyMsg(noOri1) $stpn" warning 1 OK \
									$geoEasyMsg(cancel)]
						} else { set w 1 }
						if {$w == 1} {
							GeoDiaEnd .dia
							return 0
						} else {
							continue
						}
					}
					set zid "${stpn}_z0"			;# set id for orientation
					set zidi 0
					while {[lsearch -exact $zks $zid] != -1} {
						incr zidi
						set zid "${stpn}_z${zidi}"	;# set id for orientation
					}
					lappend zks $zid
					lappend zkind [list $geo $stref];# store zk name and index
					set lineno [expr {$stref + 1}]	;# first observation
					while {1} {
						if {[info exists ${geo}_geo($lineno)] == 0} {
							break		;# end of geo data set
						}
						upvar #0 ${geo}_geo($lineno) pbuf
						if {[GetVal 2 $pbuf] != ""} {
							break		;# next station reached
						}
						set p [GetVal {5 62} $pbuf]	;# point number of other end
						set pcoo ""
						if {[lsearch -exact $pns $p] >= 0} {
							set newp 1			;# p is unknown point
							set pcoo [GetCoord $p {38 37} $geo]
							if {$pcoo == ""} {
								# use approximate coords
								set pcoo [GetCoord $p {138 137} $geo]
							}
						} elseif {[lsearch -exact $fixed $p] >= 0} {
							set newp 0			;# p is known point
							set pcoo [GetCoord $p {38 37} $geo]
						}
						
						if {$pcoo == ""} {
							incr lineno
							continue	;# no coordinate skip it
						}
						set h [GetVal {21 7} $pbuf]		;# horizontal angle 
						if {$h != ""} {
						# condition for direction
							set px [GetVal {38 138} $pcoo]
							set py [GetVal {37 137} $pcoo]
							set dist [Distance $stx $sty $px $py]
							set bearing [Bearing $stx $sty $px $py]
							set measure($nmeasure) [list $stpn $p "H" $h $zid]
							set apprb [expr {$h + $zk}]
							while {$apprb < 0} {set apprb [expr {$apprb + $PI2}]}
							while {$apprb > $PI2} {set apprb [expr {$apprb - $PI2}]}
							while {$bearing < 0} {set bearing [expr {$bearing + $PI2}]}
							while {$bearing > $PI2} {set bearing [expr {$bearing - $PI2}]}
							# repeat count
							set nrep [GetVal 112 $pbuf]
							if {$nrep == "" || $nrep <= 0} { set nrep 1 }
							# std dev
							# standard deviation (short distance exception)
							if {$dist < $dirLimit} {
								if {$dist < 0.1} { set dist 0.1 }
								set w [expr {($stdA * $dirLimit / $dist / $RO) / sqrt($nrep)}]
							} else {
								set w [expr {($stdA / $RO) / sqrt($nrep)}]
							}
							set stddev($nmeasure) $w
							set pure [expr {$bearing - $apprb}]
							# trying to avoid 0-00-02 - 359-59-58
							if {$pure > $PI} {
								set pure [expr {$pure - $PI2}]
							}
							if {$pure < [expr {-$PI}]} {
								set pure [expr {$pure + $PI2}]
							}
							if {[expr {abs($pure)}] > [expr {50.0 * $w}] && \
									$flag == 0} {
								GeoLog1 [format "$geoEasyMsg(pure)" \
									$stpn $p H [DMS $pure]]
								if {$msg_flag == 0} {
									switch -exact \
									[tk_dialog .msg $geoEasyMsg(warning) \
										[format "$geoEasyMsg(pure)" \
										$stpn $p H [DMS $pure]] \
										warning 0 OK \
										$geoEasyMsg(ignore) \
										$geoEasyMsg(cancel)] {

										1 {set msg_flag 1}
										2 {
											GeoLog1 $geoEasyMsg(cancelled)
											GeoDiaEnd .dia
											return 0
										}
									}
								}
							}
							if {[lsearch -exact $used $stpn] == -1} {
								lappend used $stpn
							}
							if {[lsearch -exact $used $p] == -1} {
								lappend used $p
							}
							if {$newst == 0 || $newp == 0} {
								set free_network 0
							}
							incr nmeasure
							update
						}
						incr lineno
					}
				}
			}
		}
	}
	update
	if {$nmeasure == 0 || $nmeasure < $n} {
		if {$flag == 0} {
			GeoLog1 $geoEasyMsg(noAdj)
			tk_dialog .msg $geoEasyMsg(warning) \
				$geoEasyMsg(noAdj) warning 0 OK
		}
		GeoDiaEnd .dia
		return 0
	}
	GeoDiaEnd .dia
	# xml output
	set xml [open $fn w]
	puts $xml "<?xml version=\"1.0\" ?>"
	puts $xml "<!DOCTYPE gama-xml SYSTEM \"gama-xml.dtd\">"
	puts $xml "<gama-local version=\"2.0\">"
	puts $xml "<network axes-xy=\"ne\" angles=\"left-handed\">"
	puts $xml "<description>"
	puts $xml "GeoEasy 2D network"
	puts $xml "</description>"
#TBD valodi parameterek
	puts $xml "<parameters sigma-apr = \"1\" conf-pr = \"$gamaConf\" tol-abs = \"$gamaTol\" sigma-act = \"aposteriori\" update-constrained-coordinates=\"yes\" />"
	puts $xml "<points-observations distance-stdev=\"$stdDist1 $stdDist2\" direction-stdev=\"[expr {round($stdAngle * $SEC2CC)}]\" angle-stdev=\"[expr {round($stdAngle * $SEC2CC * sqrt(2.0))}]\" zenith-angle-stdev=\"[expr {round($stdAngle * $SEC2CC)}]\" >"
	if {$free_network} {
		set adjxy "XY"
#		set i 1
	} else {
		set adjxy "xy"
#		set i 0
	}
	foreach pn $used {
		if {[lsearch -exact $pns $pn] != -1} {
			# unknown for adjustment
			set pcoo [GetCoord $pn {38 37}]
			if {$pcoo == ""} {
				set pcoo [GetCoord $pn {138 137}]
				if {$pcoo == ""} {
					puts $xml "<point id=\"$pn\" adj=\"$adjxy\" />"
				} else {
					puts $xml "<point id=\"$pn\" y=\"[format %.${decimals}f [GetVal 138 $pcoo]]\" x=\"[format %.${decimals}f [GetVal 137 $pcoo]]\" adj=\"$adjxy\" />"
				}
			} else {
				puts $xml "<point id=\"$pn\" y=\"[format %.${decimals}f [GetVal 38 $pcoo]]\" x=\"[format %.${decimals}f [GetVal 37 $pcoo]]\" adj=\"$adjxy\" />"
			}
		} else {
			set pcoo [GetCoord $pn {38 37}]
			puts $xml "<point id=\"$pn\" y=\"[format %.${decimals}f [GetVal 38 $pcoo]]\" x=\"[format %.${decimals}f [GetVal 37 $pcoo]]\" fix=\"xy\" />"
		}
#		if {$i} {
#			incr i -1
#		} else {
#			set adjxy "xy"
#		}
	}
	set last_st ""
	set last_st_id ""
	for {set i 0} {$i < $nmeasure} {incr i} {
		if {$last_st != [lindex $measure($i) 0] || \
				$last_st_id != [lindex $measure($i) 4]} {
			if {$i} {
				puts $xml "</obs>"
			}
			puts $xml "<obs from=\"[lindex $measure($i) 0]\">"
		}
		if {$stddev($i) <= 0} {
			set stddev($i) 0.1
		}
		switch -exact [lindex $measure($i) 2] {
			"D" {
				puts $xml "<distance to=\"[lindex $measure($i) 1]\" val=\"[format %.${decimals}f [lindex $measure($i) 3]]\" stdev=\"[format %.${decimals}f $stddev($i)]\" />"
			}
			"H" {
				puts $xml "<direction to=\"[lindex $measure($i) 1]\" val=\"[GON [lindex $measure($i) 3]]\" stdev=\"[expr {round([GON $stddev($i)] * 10000)}]\" />"
			}
		}
		set last_st [lindex $measure($i) 0]
		set last_st_id [lindex $measure($i) 4]
	}
	puts $xml "</obs>"
	puts $xml "</points-observations>"
	puts $xml "</network>"
	puts $xml "</gama-local>"
	close $xml
}

#
#	Export observations into 3D network gnu-gama xml file
#	all loaded data sets are considered
#	@param fn output file name
#	@param pns list of unknown points (names)
#	@param fixed list of fixed points (names)
#	@param flag do not display messages if 1
proc Gama3dXmlOut {fn pns fixed {flag 0}} {
	global projRed avgH refr
	global geoLoaded
	global geoEasyMsg
	global PI PI2
	global stdAngle stdDist1 stdDist2 stdLevel
	global dirLimit
	global decimals
	global autoRefresh
	global xmlTypes 
	global lastDir
	global nmeasure n
	global gamaProg gamaConf gamaAngles gamaTol gamaShortOut gamaSvgOut
	global RO
	global SEC2CC

	set nmeasure 0							;# number of observations considered
	set n [llength $pns]
	GeoDia .dia $geoEasyMsg(adjDia) nmeasure n	;# display dialog panel
	set stations ""							;# used station references
	set used ""								;# list of used points
	set zks ""								;# orientation ids for reoccupied stations
	set zkind ""							;# station recs for orientations
	# check for approximate coordinates for unknowns
	set msg_flag 0	;# display warning on too large pure value
	set free_network [expr {([llength $fixed] == 0) ? 1 : 0}]
	foreach pn $pns {
	#	get all references from all loaded geo data sets
		foreach geo $geoLoaded {
			global ${geo}_ref ${geo}_geo ${geo}_par
			if {! [info exists ${geo}_par]} {
				set ${geo}_par ""	;# to avoid undefined variable
			}
			if {[info exists ${geo}_ref($pn)]} {	;# point is referenced
				upvar #0 ${geo}_ref($pn) refs 
				upvar #0 ${geo}_par par
                # standard deviations
				set stdA [GetVal 114 $par]
				if {$stdA == ""} { set stdA $stdAngle}
				set stdD1 [GetVal 115 $par]
				if {$stdD1 == ""} { set stdD1 $stdDist1}
				set stdD2 [GetVal 116 $par]
				if {$stdD2 == ""} { set stdD2 $stdDist2}
				foreach ref $refs {
					upvar #0 ${geo}_geo($ref) stbuf
					set stpn [GetVal 2 $stbuf]
					set stref $ref
					if {$stpn == ""} {	;# not a station
						# go back to the station record
						while {$stref >=0 && [GetVal 2 $stbuf] == ""} {
							incr stref -1
							upvar #0 ${geo}_geo($stref) stbuf
						}
						if {$stref >= 0} {
							set stpn [GetVal 2 $stbuf]
						} else {
							tk_dialog .msg $geoEasyMsg(error) \
								$geoEasyMsg(noStation) error 0 OK
							GeoDiaEnd .dia
							return
						}
					}
					set ih [GetVal {3 6} $stbuf]	;# instrument height
 					if {$ih == ""} { set ih 0 }
					if {[lsearch -exact $stations "$geo $stref"] != -1} {
					# station already processed
						continue
					}
					lappend stations [list $geo $stref]	;# store processed stations
					set stcoo ""
					if {[lsearch -exact $pns $stpn] >= 0} {
						set newst 1			;# station is unknown point
						set stcoo [GetCoord $stpn {38 37 39} $geo]
						if {$stcoo == ""} {
							# use approximate coords
							set stcoo [GetCoord $stpn {138 137 139} $geo]
						}
					} elseif {[lsearch -exact $fixed $stpn] >= 0} {
						set newst 0			;# station is known point
						set stcoo [GetCoord $stpn {38 37} $geo]
					}
					if {$stcoo == ""} {
						continue	;# no coordinate for station skip it
					}
					set stx [GetVal {38 138} $stcoo]
					set sty [GetVal {37 137} $stcoo]
					set stz [GetVal {39 139} $stcoo]
#
# go through the observations from this station and
# set up an equation for each distance
# if at least one end is unknown (eg. mentioned in pns list
# meanwhile count reference directions and other directions
#
					set refdir 0
					set othdir 0
					set lineno [expr {$stref + 1}]	;# first observation
					while {1} {
						if {[info exists ${geo}_geo($lineno)] == 0} {
							break		;# end of geo data set
						}
						upvar #0 ${geo}_geo($lineno) pbuf
						if {[GetVal 2 $pbuf] != ""} {
							break		;# next station reached
						}
						set p [GetVal {5 62} $pbuf]	;# point number of other end
						set th [GetVal 6 $pbuf]		;# target height
						if {$th == ""} { set th 0}
#puts $dbg "iranyzott pont $p"
						set pcoo ""
						if {[lsearch -exact $pns $p] >= 0} {
							set newp 1			;# p is unknown point
							set pcoo [GetCoord $p {38 37 39} $geo]
							if {$pcoo == ""} {
								# use approximate coords
								set pcoo [GetCoord $p {138 137 139} $geo]
							}
						} elseif {[lsearch -exact $fixed $p] >= 0} {
							set newp 0			;# p is known point
							set pcoo [GetCoord $p {38 37 39} $geo]
						}
						if {$pcoo == ""} {
							incr lineno
							continue	;# no coord skip
						}
						set px [GetVal {38 138} $pcoo]
						set py [GetVal {37 137} $pcoo]
						set pz [GetVal {39 139} $pcoo]
						if {($newst == 1 || $newp == 1) && \
							([lsearch -exact $fixed $stpn] > -1 || \
							 [lsearch -exact $pns $stpn] > -1) && \
							([lsearch -exact $fixed $p] > -1 || \
							 [lsearch -exact $pns $p] > -1)} {
							# one end is unknown
							set d [GetVal 11 $pbuf]	;# horizontal distance
							set hz 1	;# no reduction to horizont
							if {$d == ""} {
								set hzd 0
								set d [GetVal 9 $pbuf]	;# slope distance
							}
							if {$d != ""} {
								# condition for slope distance
								if {$hzd} {	;# horizontal distance
									set dist [Distance $stx $sty $px $py]
									set measure($nmeasure) [list $stpn $p "D" $d ""]
								} else {
									set dist [Distance3d $stx $sty $stz $px $py $pz $ih $th]
									set measure($nmeasure) [list $stpn $p "S" $d "" $ih $th]
								}
#puts $dbg "sorszam: $nmeasure meres: $measure($nmeasure)"
								# repeat count
								set nrep [GetVal 112 $pbuf]
								if {$nrep == "" || $nrep <= 0} { set nrep 1 }
								#  standard
								# dev [mm] = stdD1 + stdD2 * dist[km]
								set w [expr {($stdD1 + \
									$dist / 1000.0 * $stdD2) / sqrt($nrep)}]
								set pure [expr {$dist - $d}]
								if {[expr {abs($pure)}] > [expr {50.0 * $w}] && \
										$flag == 0} {
									GeoLog1 [format "$geoEasyMsg(pure)" \
										$stpn $p D $pure]
									if {$msg_flag == 0} {
										switch -exact \
										[tk_dialog .msg $geoEasyMsg(warning) \
											[format "$geoEasyMsg(pure)" \
											$stpn $p D $pure] \
											warning 0 OK \
											$geoEasyMsg(ignore) \
											$geoEasyMsg(cancel)] {
											
											1 {set msg_flag 1}
											2 {
												GeoLog1 $geoEasyMsg(cancelled)
												GeoDiaEnd .dia
												return 0
											}
										}
									}
								}
								# std dev
								set stddev($nmeasure) $w
								if {[lsearch -exact $used $stpn] == -1} {
									lappend used $stpn
								}
								if {[lsearch -exact $used $p] == -1} {
									lappend used $p
								}
								if {$newst == 0 || $newp == 0} {
									set free_network 0
								}
								incr nmeasure
								update
							}
						}
						if {[GetVal {21 7} $pbuf] != ""} {
						# horizontal angle & coords are available
							if {$newst || $newp} {
								incr othdir
							} else {
								incr refdir
							}
						}
						incr lineno
					}
#
# go through the observations from this station and
# set up an equation for each horizontal angle
# if at least one new point is shot at and at least two directions observed
#
					if {$othdir == 0 || [expr {$othdir + $refdir}] < 2} {
					# no unkonw point or only one direction
						continue
					}
					set zk [GetVal {101 103} $stbuf]	;# orientation
					if {$zk == ""} {
						if {$flag == 0} {
							GeoLog1 "$geoEasyMsg(noOri1) $stpn"
							set w [tk_dialog .msg $geoEasyMsg(warning) \
								"$geoEasyMsg(noOri1) $stpn" warning 1 OK \
									$geoEasyMsg(cancel)]
						} else { set w 1 }
						if {$w == 1} {
							GeoDiaEnd .dia
							return 0
						} else {
							continue
						}
					}
					set zid "${stpn}_z0"			;# set id for orientation
					set zidi 0
					while {[lsearch -exact $zks $zid] != -1} {
						incr zidi
						set zid "${stpn}_z${zidi}"	;# set id for orientation
					}
					lappend zks $zid
					lappend zkind [list $geo $stref];# store zk name and index
					set lineno [expr {$stref + 1}]	;# first observation
					while {1} {
						if {[info exists ${geo}_geo($lineno)] == 0} {
							break		;# end of geo data set
						}
						upvar #0 ${geo}_geo($lineno) pbuf
						if {[GetVal 2 $pbuf] != ""} {
							break		;# next station reached
						}
						set p [GetVal {5 62} $pbuf]	;# point number of other end
						set pcoo ""
						if {[lsearch -exact $pns $p] >= 0} {
							set newp 1			;# p is unknown point
							set pcoo [GetCoord $p {38 37 39} $geo]
							if {$pcoo == ""} {
								# use approximate coords
								set pcoo [GetCoord $p {138 137 139} $geo]
							}
						} elseif {[lsearch -exact $fixed $p] >= 0} {
							set newp 0			;# p is known point
							set pcoo [GetCoord $p {38 37 39} $geo]
						}
						
						if {$pcoo == ""} {
							incr lineno
							continue
						}
						set h [GetVal {21 7} $pbuf]		;# horizontal angle 
						if {$h != ""} {
						# condition for direction
							set px [GetVal {38 138} $pcoo]
							set py [GetVal {37 137} $pcoo]
							set dist [Distance $stx $sty $px $py]
							set bearing [Bearing $stx $sty $px $py]
							set measure($nmeasure) [list $stpn $p "H" $h $zid]
							set apprb [expr {$h + $zk}]
							while {$apprb < 0} {set apprb [expr {$apprb + $PI2}]}
							while {$apprb > $PI2} {set apprb [expr {$apprb - $PI2}]}
							while {$bearing < 0} {set bearing [expr {$bearing + $PI2}]}
							while {$bearing > $PI2} {set bearing [expr {$bearing - $PI2}]}
							# standard deviation (short distance exception)
							if {$dist < $dirLimit} {
								if {$dist < 0.1} { set dist 0.1 }
								set w [expr {$stdA * $dirLimit / $dist / $RO}]
							} else {
								set w [expr {$stdA / $RO}]
							}
							# std dev
							set stddev($nmeasure) $w
							set pure [expr {$bearing - $apprb}]
							# trying to avoid 0-00-02 - 359-59-58
							if {$pure > $PI} {
								set pure [expr {$pure - $PI2}]
							}
							if {$pure < [expr {-$PI}]} {
								set pure [expr {$pure + $PI2}]
							}
							if {[expr {abs($pure)}] > [expr {50.0 * $w}] && \
									$flag == 0} {
								GeoLog1 [format "$geoEasyMsg(pure)" \
									$stpn $p H [DMS $pure]]
								if {$msg_flag == 0} {
									switch -exact \
									[tk_dialog .msg $geoEasyMsg(warning) \
										[format "$geoEasyMsg(pure)" \
										$stpn $p H [DMS $pure]] \
										warning 0 OK \
										$geoEasyMsg(ignore) \
										$geoEasyMsg(cancel)] {

										1 {set msg_flag 1}
										2 {
											GeoLog1 $geoEasyMsg(cancelled)
											GeoDiaEnd .dia
											return 0
										}
									}
								}
							}
							if {[lsearch -exact $used $stpn] == -1} {
								lappend used $stpn
							}
							if {[lsearch -exact $used $p] == -1} {
								lappend used $p
							}
							incr nmeasure
							update
						}
						incr lineno
					}
#
# go through the observations from this station and
# set up an equation for each zenith angle
#
					set lineno [expr {$stref + 1}]	;# first observation
					while {1} {
						if {[info exists ${geo}_geo($lineno)] == 0} {
							break		;# end of geo data set
						}
						upvar #0 ${geo}_geo($lineno) pbuf
						if {[GetVal 2 $pbuf] != ""} {
							break		;# next station reached
						}
						set p [GetVal {5 62} $pbuf]	;# point number of other end
						set th [GetVal 6 $pbuf]		;# target height
						if {$th == ""} { set th 0}
#puts $dbg "iranyzott pont $p"
						set pcoo ""
						if {[lsearch -exact $pns $p] >= 0} {
							set newp 1			;# p is unknown point
							set pcoo [GetCoord $p {38 37 39} $geo]
							if {$pcoo == ""} {
								# use approximate coords
								set pcoo [GetCoord $p {138 137 139} $geo]
							}
						} elseif {[lsearch -exact $fixed $p] >= 0} {
							set newp 0			;# p is known point
							set pcoo [GetCoord $p {38 37 39} $geo]
						}

						if {$pcoo == ""} {
							incr lineno
							continue	;# no coordinate skip it
						}
						if {$newst == 1 || $newp == 1} {
							# one end is unknown
							set v [GetVal 8 $pbuf]	;# zenith angle
							if {$d != "" && $v != ""} {
								set measure($nmeasure) [list $stpn $p "V" $v "" $ih $th]
								# repeat count
								set nrep [GetVal 112 $pbuf]
								if {$nrep == "" || $nrep <= 0} { set nrep 1 }
								# std dev
								if {$dist < $dirLimit} {
									if {$dist < 0.1} { set dist 0.1 }
									set w [expr {($stdA * $dirLimit / $dist / $RO) / sqrt($nrep)}]
								} else {
									set w [expr {($stdA / $RO) / sqrt($nrep)}]
								}
								set stddev($nmeasure) $w
								if {[lsearch -exact $used $stpn] == -1} {
									lappend used $stpn
								}
								if {[lsearch -exact $used $p] == -1} {
									lappend used $p
								}
								if {$newst == 0 || $newp == 0} {
									set free_network 0
								}
								incr nmeasure
								update
							}
						}
						incr lineno
					}
				}
			}
		}
	}
	update
	if {$nmeasure == 0 || $nmeasure < $n} {
		if {$flag == 0} {
			GeoLog1 $geoEasyMsg(noAdj)
			tk_dialog .msg $geoEasyMsg(warning) \
				$geoEasyMsg(noAdj) warning 0 OK
		}
		GeoDiaEnd .dia
		return 0
	}
	GeoDiaEnd .dia
	# xml output
	set xml [open $fn w]
	puts $xml "<?xml version=\"1.0\" ?>"
	puts $xml "<!DOCTYPE gama-xml SYSTEM \"gama-xml.dtd\">"
	puts $xml "<gama-local version=\"2.0\">"
	puts $xml "<network axes-xy=\"ne\" angles=\"left-handed\">"
	puts $xml "<description>"
	puts $xml "GeoEasy 3D network"
	puts $xml "</description>"
#TBD valodi parameterek
	puts $xml "<parameters sigma-apr = \"1\" conf-pr = \"$gamaConf\" tol-abs = \"$gamaTol\" sigma-act = \"aposteriori\" update-constrained-coordinates=\"yes\" />"
	puts $xml "<points-observations distance-stdev=\"$stdDist1 $stdDist2\" direction-stdev=\"[expr {round($stdAngle * $SEC2CC)}]\" angle-stdev=\"[expr {round($stdAngle * $SEC2CC * sqrt(2.0))}]\" zenith-angle-stdev=\"[expr {round($stdAngle * $SEC2CC)}]\" >"
	if {$free_network} {
		set adjxyz "XYZ"
#		set i 2
	} else {
		set adjxyz "xyz"
#		set i 0
	}
	foreach pn $used {
		if {[lsearch -exact $pns $pn] != -1} {
			# unknown for adjustment
			set pcooxy [GetCoord $pn {38 37}]
			if {$pcooxy == ""} {
				set pcooxy [GetCoord $pn {138 137}]
			}
			set pcooz [GetCoord $pn 39]
			if {$pcooz == ""} {
				set pcooz [GetCoord $pn 139]
			}
			puts $xml "<point id=\"$pn\" y=\"[format %.${decimals}f [GetVal {38 138} $pcooxy]]\" x=\"[format %.${decimals}f [GetVal {37 137} $pcooxy]]\" z=\"[format %.${decimals}f [GetVal {39 139} $pcooz]]\" adj=\"$adjxyz\" />"
		} else {
			set pcoo [GetCoord $pn {38 37 39}]
			if {$pcoo != ""} {
				puts $xml "<point id=\"$pn\" y=\"[format %.${decimals}f [GetVal 38 $pcoo]]\" x=\"[format %.${decimals}f [GetVal 37 $pcoo]]\" z=\"[format %.${decimals}f [GetVal 39 $pcoo]]\" fix=\"xyz\" />"
			} else {
				# only horizontal coords fixed
				set pcoo [GetCoord $pn {38 37}]
				if {$pcoo != ""} {
					set pcooz [GetCoord $pn 139]
					puts $xml "<point id=\"$pn\" y=\"[format %.${decimals}f [GetVal 38 $pcoo]]\" x=\"[format %.${decimals}f [GetVal 37 $pcoo]]\" z=\"[format %.${decimals}f [GetVal 139 $pcooz]]\" fix=\"xy\" />"
				} else {
					set pcoo [GetCoord $pn {39}]
					if {$pcoo != ""} {
						set pcooxy [GetCoord $pn {138 137}]
						puts $xml "<point id=\"$pn\" y=\"[format %.${decimals}f [GetVal 138 $pcooxy]]\" x=\"[format %.${decimals}f [GetVal 137 $pcooxy]]\" z=\"[format %.${decimals}f [GetVal 39 $pcoo]]\" fix=\"z\" />"
					}
				}
			}
		}
#		if {$i} {
#			incr i -1
#		} else {
#			set adjxyz "xyz"
#		}
	}
	set last_st ""
	for {set i 0} {$i < $nmeasure} {incr i} {
		if {$last_st != [lindex $measure($i) 0] || \
				$last_st_id != [lindex $measure($i) 4]} {
			if {$i} {
				puts $xml "</obs>"
			}
			puts $xml "<obs from=\"[lindex $measure($i) 0]\">"
		}
		switch -exact [lindex $measure($i) 2] {
			"D" {
				# horizontal distance
				puts $xml "<distance to=\"[lindex $measure($i) 1]\" val=\"[format %.${decimals}f [lindex $measure($i) 3]]\" stdev=\"[format %.${decimals}f $stddev($i)] />"
			}
			"H" {
				# direction
				puts $xml "<direction to=\"[lindex $measure($i) 1]\" val=\"[GON [lindex $measure($i) 3]]\" stdev=\"[expr {round([GON $stddev($i)] * 10000)}]\" />"
			}
			"S" {
				# slope distance
				puts $xml "<s-distance to=\"[lindex $measure($i) 1]\" val=\"[format %.${decimals}f [lindex $measure($i) 3]]\" from_dh=\"[format %.${decimals}f [lindex $measure($i) 5]]\" to_dh=\"[format %.${decimals}f [lindex $measure($i) 6]]\" stdev=\"$stddev($i)\" />"
			}
			"V" {
				# zenith angle
				puts $xml "<z-angle to=\"[lindex $measure($i) 1]\" val=\"[GON [lindex $measure($i) 3]]\" from_dh=\"[format %.${decimals}f [lindex $measure($i) 5]]\" to_dh=\"[format %.${decimals}f [lindex $measure($i) 6]]\" stdev=\"[expr {round([GON $stddev($i)] * 10000)}]\" />"
			}
		}
		set last_st [lindex $measure($i) 0]
		set last_st_id [lindex $measure($i) 4]
	}
	puts $xml "</obs>"
	puts $xml "</points-observations>"
	puts $xml "</network>"
	puts $xml "</gama-local>"
	close $xml
}

#
#	Get back coordinates and orientations from gama adjustment
#	@param name name of xml file to process
proc ProcessXml {name} {
	global autoRefresh
	global gamaProg gamaConf gamaAngles gamaTol gamaShortOut gamaSvgOut

	set f [open $name "r"]
	set xmllist [xml2list [read $f]]
	close $f
	if {$gamaShortOut} {
		GamaShortOutput $xmllist
	}
	ProcessList $xmllist
	catch {file delete $name}
	if {$autoRefresh} {
		RefreshAll
	}
}

#
#	Read coordinates and orientations from list and store them
#	@param l list of GNU gam xml output
proc ProcessList {l} {

	foreach item $l {
		if {[llength $item] > 1} {
			set head [lindex $item 0]
			switch -exact -- $head {
				"adjusted" {
					set cs [lindex [lrange $item 2 end] 0]
					foreach c $cs {
						set pn ""
						set y ""
						set x ""
						set z ""
						foreach p [lindex $c 2] {
							switch [lindex $p 0] {
								"id" {
									set pn [lindex [lindex [lindex $p 2] 0] 1]
								}
								"X" -
								"x" {
									set x [lindex [lindex [lindex $p 2] 0] 1]
								}
								"Y" -
								"y" {
									set y [lindex [lindex [lindex $p 2] 0] 1]
								}
								"Z" -
								"z" {
									set z [lindex [lindex [lindex $p 2] 0] 1]
								}
							}
						}
						if {$x != "" && $y != "" } { StoreCoord $pn $y $x }
						if {$z != ""} { StoreZ $pn $z }
					}
				}
				"orientation-shifts" {
					set os [lindex [lrange $item 2 end] 0]
					foreach o $os {
						set pn ""
						set oa ""
						set aoa ""
						foreach p [lindex $o 2] {
							switch [lindex $p 0] {
								"id" {
									set pn [lindex [lindex [lindex $p 2] 0] 1]
								}
								"adj" {
									set oa [lindex [lindex [lindex $p 2] 0] 1]
								}
								"approx" {
									set aoa [lindex [lindex [lindex $p 2] 0] 1]
								}
							}
						}
						if {$pn != "" && $oa != "" && $aoa != ""} {
							StoreOri $pn [Gon2Rad $oa] [Gon2Rad $aoa]
						}
					}
				}
				"fixed" -
				"approximate" -
				"cov-mat" -
				"original-index" -
				"observations" -
				"network-processing-summary" {
					continue
				}
				default {
					ProcessList $item
				}
			}
		}
	}
}

#
#	Store orientation on station
#	@param pn station number
#	@param oa orinetation anglea in radians
#	@param aoa approximate orientation angle in radians
proc StoreOri {pn oa aoa} {
	global geoLoaded geoCodes
	global geoEasyMsg

	set slist [GetStation $pn]
	set stored 0
	foreach sl $slist {
		set geo [lindex $sl 0]
		set ref [lindex $sl 1]
		upvar #0 ${geo}_geo($ref) buf
		set prev_aoa [GetVal {101 103} $buf]
		# check wheather the same occupation of the station
		if {[llength $slist] > 1 && \
				($prev_aoa == "" || [expr {abs($prev_aoa - $aoa)}] > 1e-4)} {
			continue
		}
		set buf [DelVal {100 101 102 103} $buf]
		lappend buf [list 101 $oa]
		incr stored
	}
	if {$stored != 1} {
		tk_dialog .msg $geoEasyMsg(warning) \
			"$geoEasyMsg(gamaori) $pn" warning 0 OK
	}
}

#
#   Get parameters for GNU GaMa local network adjustment
proc GamaParams {} {
    global geoEasyMsg
	global gamaProg gamaConf gamaAngles gamaTol dirLimit gamaShortOut gamaSvgOut
	global lgamaConf lgamaAngles lgamaTol ldirLimit
	global buttonid

    set w [focus]
    if {$w == ""} { set w "." }
    set this .gamaparams
    set buttonid 0
    if {[winfo exists $this] == 1} {
        raise $this
        Beep
        return
    }
	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(gamapar)
	wm resizable $this 0 0
	wm transient $this [winfo toplevel $w]
	catch {wm attribute $this -topmost}

	set lgamaConf $gamaConf
	set lgamaAngles $gamaAngles
	set lgamaTol $gamaTol
	set ldirLimit $dirLimit

	label $this.lconf -text $geoEasyMsg(gamaconf)
	entry $this.conf -textvariable lgamaConf -width 10
	label $this.langles -text $geoEasyMsg(gamaangles)
	tk_optionMenu $this.angles lgamaAngles "360" "400"
	label $this.ltol -text $geoEasyMsg(gamatol)
	entry $this.tol -textvariable lgamaTol -width 10
	label $this.ldirlimit -text $geoEasyMsg(gamadirlimit)
	entry $this.dirlimit -textvariable ldirLimit -width 10
	#label $this.lshort -text $geoEasyMsg(gamashortout)
	checkbutton $this.svg -text $geoEasyMsg(gamasvgout) \
	        -variable gamaSvgOut

	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"

	grid $this.lconf -row 0 -column 0 -sticky w
	grid $this.conf -row 0 -column 1 -sticky w
	grid $this.langles -row 1 -column 0 -sticky w
	grid $this.angles -row 1 -column 1 -sticky w
	grid $this.ltol -row 2 -column 0 -sticky w
	grid $this.tol -row 2 -column 1 -sticky w
	grid $this.ldirlimit -row 3 -column 0 -sticky w
	grid $this.dirlimit -row 3 -column 1 -sticky w
	grid $this.svg -row 4 -column 0 -columnspan 2 -sticky e
	grid $this.exit -row 5 -column 0
	grid $this.cancel -row 5 -column 1
	tkwait visibility $this
	CenterWnd $this
	grab set $this

	tkwait variable buttonid
	if {$buttonid == 0} {
		if {[catch {format %f $lgamaConf}] == 0} { set gamaConf $lgamaConf }
		set gamaAngles $lgamaAngles
		if {[catch {format %f $lgamaTol}] == 0} { set gamaTol $lgamaTol }
		if {[catch {format %f $ldirLimit}] == 0} { set dirLimit $ldirLimit }
	}
}

#
#	Create short output list of gama adjustment in results window
#	@param l list of GNU gama output
proc GamaShortOutput {l} {
	global geoEasyMsg
	global gamaAngles
	global decimals
	global SEC2CC

	set mmdec [expr {$decimals -3}]
	if {$mmdec < 0} { set mmdec 0 }
	set firstcoo 1
	set firstori 1
	foreach item $l {
		if {[llength $item] > 1} {
			set head [lindex $item 0]
			switch -exact -- $head {
				"network-general-parameters" {
				}
				"standard-deviation" {
					set par [lindex [lrange $item 2 end] 0]
					foreach p $par {
						switch [lindex $p 0] {
							"apriori" { set apri [lindex [lindex [lindex $p 2] 0] 1] }
							"aposteriori" { set apos [lindex [lindex [lindex $p 2] 0] 1] }
							"probability" { set prob [expr {100 * [lindex [lindex [lindex $p 2] 0] 1]}] }
							"ratio" { set ratio [lindex [lindex [lindex $p 2] 0] 1] }
							"lower" { set lower [lindex [lindex [lindex $p 2] 0] 1] }
							"upper" { set upper [lindex [lindex [lindex $p 2] 0] 1] }
						}
					}
					GeoLog1 $geoEasyMsg(gamastdhead0)
					GeoLog1 [format "%s %.2f" $geoEasyMsg(gamastdhead1) $apri]
					GeoLog1 [format "%s %.2f" $geoEasyMsg(gamastdhead2) $apos]
					if {$ratio >= $lower && $ratio <= $upper} {
						GeoLog1 [format "%.1f %s (%.2f, %.2f) %s" $prob $geoEasyMsg(gamastdhead3) $lower $upper $geoEasyMsg(gamastdhead4)]
					} else {
						GeoLog1 [format "%.1f %s (%.2f, %.2f) %s" $prob $geoEasyMsg(gamastdhead3) $lower $upper $geoEasyMsg(gamastdhead5)]
					}
				}
				"adjusted" {
					set cs [lindex [lrange $item 2 end] 0]
					foreach c $cs {
						if {$firstcoo} {
							GeoLog1
							GeoLog1 $geoEasyMsg(gamacoohead0)
							GeoLog1 $geoEasyMsg(gamacoohead1)
							set firstcoo 0
						}
						set pn ""
						set y ""
						set x ""
						set z ""
						foreach p [lindex $c 2] {
							switch [lindex $p 0] {
								"id" {
									set pn [lindex [lindex [lindex $p 2] 0] 1]
								}
								"X" -
								"x" {
									set x [lindex [lindex [lindex $p 2] 0] 1]
								}
								"Y" -
								"y" {
									set y [lindex [lindex [lindex $p 2] 0] 1]
								}
								"Z" -
								"z" {
									set z [lindex [lindex [lindex $p 2] 0] 1]
								}
							}
						}
						if {$y != "" && $x != "" && $z != ""} {
							GeoLog1 [format "%-10s %10.${decimals}f %10.${decimals}f %10.${decimals}f" $pn $y $x $z]
						} elseif {$y != "" && $x != ""} {
							GeoLog1 [format "%-10s %10.${decimals}f %10.${decimals}f" $pn $y $x]
						} else {
							GeoLog1 [format "%-10s %10.${decimals}f" $pn $z]
						}
					}
				}
				"orientation-shifts" {
					set os [lindex [lrange $item 2 end] 0]
					foreach o $os {
						set pn ""
						set oa ""
						set aoa ""
						foreach p [lindex $o 2] {
							switch [lindex $p 0] {
								"id" {
									set pn [lindex [lindex [lindex $p 2] 0] 1]
								}
								"adj" {
									set oa [lindex [lindex [lindex $p 2] 0] 1]
								}
								"approx" {
									set aoa [lindex [lindex [lindex $p 2] 0] 1]
								}
							}
						}
						if {$pn != "" && $oa != "" && $aoa != ""} {
							if {$firstori} {
								GeoLog1
								GeoLog1 "Tajekozasi allandok"
								set firstori 0
							}
							if {$gamaAngles == 360} {
								set oa [DMS [Gon2Rad $oa]]
								set aoa [DMS [Gon2Rad $aoa]]
							} else {
								set oa [format "%10.4s" $oa]
								set aoa [format "%10.4s" $aoa]
							}
							GeoLog1 [format "%-10s %s %s" $pn $oa $aoa]
						}
					}
				}
				"observations" {
					GeoLog1
					GeoLog1 $geoEasyMsg(gamaobshead0)
					GeoLog1 $geoEasyMsg(gamaobshead1)
					set obs [lindex [lrange $item 2 end] 0]
					foreach ob $obs {
						set from ""
						set to ""
						set mea ""
						set adj ""
						set stdev ""
						foreach o [lindex $ob 2] {
							switch -exact -- [lindex $o 0] {
								"from" { set from [lindex [lindex [lindex $o 2] 0] 1] }
								"to" { set to [lindex [lindex [lindex $o 2] 0] 1] }
								"obs" { set mea [lindex [lindex [lindex $o 2] 0] 1] }
								"adj" { set adj [lindex [lindex [lindex $o 2] 0] 1] }
								"stdev" { set stdev [lindex [lindex [lindex $o 2] 0] 1] }
							}
						}
						switch -exact -- [lindex $ob 0] {
							"direction" {
								set type "HZ"
								set adj [Gon2Rad $adj]
								set mea [Gon2Rad $mea]
								set v [expr {$adj - $mea}]
								GeoLog1 [format "%-10s %-10s %10s %8.${mmdec}f %8.${mmdec}f %s" $from $to [DMS $adj] [Rad2Sec $v] [expr {$stdev / $SEC2CC}] $type]
							}
							"height-diff" { set type "DM"
								GeoLog1 [format "%-10s %-10s %10.${decimals}f %8.${mmdec}f %8.${mmdec}f %s" $from $to $adj [expr {$adj - $mea}] $stdev $type]
							}
							"distance" { set type "HD"
								GeoLog1 [format "%-10s %-10s %10.${decimals}f %8.${mmdec}f %8.${mmdec}f %s" $from $to $adj [expr {$adj - $mea}] $stdev $type]
							}
							default { set type "??"
								GeoLog1 [format "%-10s %-10s %10.${decimals}f %8.${mmdec}f %8.${mmdec}f %s" $from $to $adj [expr {$adj - $mea}] $stdev $type]
							}
						}
					}
				}
				"fixed" -
				"approximate" -
				"cov-mat" -
				"original-index" {
					continue
				}
				default {
					GamaShortOutput $item
				}
			}
		}
	}
}
