#//#
#	arc setting out calculations
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
#	Collect input and make coordinate calculations of arc points
#	@param none
#	@return none
proc GeoSettingOutArc {} {
global arcCp arcSp arcEp arcR arcP arcSave arcStep arcNum arcPre
global geoEasyMsg
global buttonid
global reg
global decimals
global fileTypes
global lastDir
	set plist [lsort -dictionary [GetGiven {37 38}]]
	if {[llength $plist] >= 3} {
		set arcCp [GeoListbox $plist {0} $geoEasyMsg(cornerTitle) 1]
		if {[llength $arcCp] == 0} { return }
		set cp [GetCoord $arcCp {37 38}]
		# remove from list
		set ind [lsearch -exact $plist $arcCp]
		set plist [lreplace $plist $ind $ind]
		set arcSp [GeoListbox $plist {0} $geoEasyMsg(spTitle) 1]
		if {[llength $arcSp] == 0} { return }
		set sp [GetCoord $arcSp {37 38}]
		# remove from list
		set ind [lsearch -exact $plist $arcSp]
		set plist [lreplace $plist $ind $ind]
		set arcEp [GeoListbox $plist {0} $geoEasyMsg(epTitle) 1]
		if {[llength $arcEp] == 0} { return }
		set ep [GetCoord $arcEp {37 38}]
		ArcInput
		tkwait window .arcparams
		if {$buttonid} { return }
		if {[regexp $reg(2) $arcR] == 0 || \
			([llength $arcP] && [regexp $reg(2) $arcP] == 0)} {
			geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
				error 0 OK
			return
		}
		if {[string length $arcStep] && [regexp $reg(2) $arcStep] <= 0.1} {
			geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
				error 0 OK
			return
		}
		if {[string length $arcNum] && [regexp $reg(2) $arcNum] == 0} {
			geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
				error 0 OK
			return
		}
		if {[string length $arcNum] && [string length $arcStep]} {
			geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(wrongval) \
				error 0 OK
			return
		}
		if {[string length $arcStep]} {
			set as $arcStep
		} else {
			set as 0
		}
		if {[string length $arcNum]} {
			set an $arcNum
		} else {
			set an 0
		}

		GeoLog $geoEasyMsg(menuCalArc)
		if {[string length $arcP] > 0 && $arcP > 0} {
			set res [TransitionArc $cp $sp $ep $arcR $arcP $arcPre $as $an]
		} else {
			set res [SimpleArc $cp $sp $ep $arcR $arcPre $as $an]
		}
	} else {
		geo_dialog .msg $geoEasyMsg(error) $geoEasyMsg(fewCoord) error 0 OK
	}
	if {$arcSave} {
		set typ [list [lindex $fileTypes [lsearch -glob $fileTypes "*.geo*"]]]
		set fn [string trim [tk_getSaveFile -filetypes $typ \
			-defaultextension ".geo" -initialdir $lastDir]]
		if {[string length $fn] == 0 || [string match "after#*" $fn]} {return}
		set lastDir [file dirname $fn]
		set fn "[file rootname $fn].geo"
		# create empty geo
		set fp [open $fn "w"]
		close $fp
		# save coo
		set fn "[file rootname $fn].coo"
		set fp [open $fn "w"]
		foreach p $res {
			puts $fp $p
		}
		close $fp
	}
	GeoLog1 $geoEasyMsg(arcHeader)
	foreach p $res {
		GeoLog1 "[format %10s [GetVal 5 $p]] [format %14.${decimals}f [GetVal 38 $p]] [format %14.${decimals}f [GetVal 37 $p]]"
	}
}
#
#	Collect input data for arc calculationss
#	if transition parameter is empty a simple arc is considered
#	@param none
#	@return none
proc ArcInput {} {
global arcCp arcSp arcEp arcR arcP arcSave arcStep arcNum arcPre
global geoEasyMsg
global buttonid
	# get radius & transition param
	set w [focus]
	if {$w == ""} { set w "." }
	set this .arcparams
	set buttonid 0
	if {[winfo exists $this] == 1} {
		raise $this
		Beep
		return
	}
	toplevel $this -class Dialog
	wm title $this $geoEasyMsg(arcPar)
	wm resizable $this 0 0
	wm transient $this [winfo toplevel $w]
	catch {wm attribute $this -topmost}
	label $this.lr -text $geoEasyMsg(arcRadius)
	label $this.lp -text $geoEasyMsg(arcParam)
	label $this.la -text $geoEasyMsg(arcStep)
	label $this.ln -text $geoEasyMsg(arcNum)
	label $this.lpre -text $geoEasyMsg(arcPrefix)
	entry $this.r -textvariable arcR -width 10 -justify right
	entry $this.p -textvariable arcP -width 10 -justify right
	entry $this.a -textvariable arcStep -width 10 -justify right
	entry $this.n -textvariable arcNum -width 10 -justify right
	entry $this.pre -textvariable arcPre -width 10
	checkbutton $this.save -text $geoEasyMsg(arcSave) -variable arcSave
	button $this.exit -text $geoEasyMsg(ok) \
		-command "destroy $this; set buttonid 0"
	button $this.cancel -text $geoEasyMsg(cancel) \
		-command "destroy $this; set buttonid 1"
	grid $this.lr -row 0 -column 0 -sticky w
	grid $this.r -row 0 -column 1 -sticky w
	grid $this.lp -row 1 -column 0 -sticky w
	grid $this.p -row 1 -column 1 -sticky w
	grid $this.la -row 2 -column 0 -sticky w
	grid $this.a -row 2 -column 1 -sticky w
	grid $this.ln -row 3 -column 0 -sticky w
	grid $this.n -row 3 -column 1 -sticky w
	grid $this.lpre -row 4 -column 0 -sticky w
	grid $this.pre -row 4 -column 1 -sticky w
	grid $this.save -row 5 -column 0 -sticky w -columnspan 2
	grid $this.save -row 5 -column 0 -sticky w -columnspan 2
	grid $this.exit -row 6 -column 0
	grid $this.cancel -row 6 -column 1
	tkwait visibility $this
	CenterWnd $this
	grab set $this
}

#
#	Calculate point coordinates for simple arc
#	@param corner list of co-ordinates of arc corner
#	@param first list of co-ordinates of a point on in line segment
#	@param last list of co-ordinates of a point on out line segment
#	@param r arc radius
#	@param pre prefix for point ids
#	@param step distance between calculated points, used only if num is zero
#	@param num number of points on arc (optional, default 0)
#	@return list of co-ordinates {{5 pid} {38 ..} {37 ..}} {{5 pid ...}}
proc SimpleArc {corner first last r pre step {num 0}} {
global PI2 PI
global geoEasyMsg
global decimals
	# calculate angels beta and alpha
	set back [Bearing [GetVal 38 $corner] [GetVal 37 $corner] \
		[GetVal 38 $first] [GetVal 37 $first]]
	set forth [Bearing [GetVal 38 $corner] [GetVal 37 $corner] \
		[GetVal 38 $last] [GetVal 37 $last]]
	set beta [expr {abs($back - $forth)}]
	while {$beta < 0} { set beta [expr {$beta + $PI2}]}
	while {$beta > $PI2} { set beta [expr {$beta - $PI2}]}
	if {[expr {$beta}] > $PI} {
		set beta [expr {$PI2 - $beta}]
	}
	set alpha [expr {$PI - $beta}]
	# tangent length
	set t [expr {$r * tan($alpha / 2.0)}]
    # arc length
    set arc_len [expr {$r * $alpha}]
	GeoLog1 "$geoEasyMsg(arcT): [format %.${decimals}f $t]"
	GeoLog1 "$geoEasyMsg(arcRadius): [format %.${decimals}f $r]"
	GeoLog1 "$geoEasyMsg(arcLength): [format %.${decimals}f $arc_len]"
	GeoLog1 [format $geoEasyMsg(arcAlpha) [ANG $alpha] [ANG $beta]]

	# start of arc
	set xs [expr {$t * sin($back) + [GetVal 38 $corner]}]
	set ys [expr {$t * cos($back) + [GetVal 37 $corner]}]
	set res ""
	lappend res [list [list 5 ${pre}ie] [list 38 $xs] [list 37 $ys]]
	# end of arc
	set xe [expr {$t * sin($forth) + [GetVal 38 $corner]}]
	set ye [expr {$t * cos($forth) + [GetVal 37 $corner]}]
	lappend res [list [list 5 ${pre}iv] [list 38 $xe] [list 37 $ye]]
	# distance between corner and middle
	set cm [expr {$r / cos($alpha / 2.0) - $r}]
	# middle of arc
	set dir [expr {atan2((sin($back) + sin($forth)) / 2.0, \
		(cos($back) + cos($forth)) / 2.0)}]
	set xm [expr {$cm * sin($dir) + [GetVal 38 $corner]}]
	set ym [expr {$cm * cos($dir) + [GetVal 37 $corner]}]
	lappend res [list [list 5 ${pre}ik] [list 38 $xm] [list 37 $ym]]
	# center of arc
	set xc [expr {$r / cos($alpha / 2.0) * sin($dir) + [GetVal 38 $corner]}]
	set yc [expr {$r / cos($alpha / 2.0) * cos($dir) + [GetVal 37 $corner]}]
#	lappend res [list [list 5 ${pre}c] [list 38 $xc] [list 37 $yc]]
	# angle step
	set da 0
	if {$num} {
		set da [expr {$alpha / 2.0 / double($num)}]
	} elseif {$step} {
		set da [expr {$step / double($r)}]
	}
	if {$da} {
		set a $da
		set starta [expr {$dir + $PI - $alpha / 2.0}]
		set i 1
		while {$a < [expr {$alpha / 2.0}]} {
			set xp [ expr {$xc + $r * sin($starta + $a)}]
			set yp [ expr {$yc + $r * cos($starta + $a)}]
			set a [expr {$a + $da}]
			lappend res [list [list 5 $pre$i] [list 38 $xp] [list 37 $yp]]
			incr i
		}
		set a $da
		set starta [expr {$dir + $PI + $alpha / 2.0}]
		while {$a < [expr {$alpha / 2.0}]} {
			set xp [ expr {$xc + $r * sin($starta - $a)}]
			set yp [ expr {$yc + $r * cos($starta - $a)}]
			set a [expr {$a + $da}]
			lappend res [list [list 5 $pre$i] [list 38 $xp] [list 37 $yp]]
			incr i
		}
	}
	return $res
}

#
#	Calculate points on transition arc
#	@param corner list of co-ordinates of arc corner
#	@param first list of co-ordinates of a point on in line segment
#	@param last list of co-ordinates of a point on out line segment
#	@param r arc radius
#	@param p parameter of transition curve
#	@param pre prefix for point ids
#	@param step	distance between calculated points, used only if num is zero
#	@param num number of points on arc (optional, default 0)
#	@return list of co-ordinates {{5 pid} {38 ..} {37 ..}} {{5 pid ...} ...}
proc TransitionArc {corner first last r p pre step {num 0}} {
global PI2 PI
global geoEasyMsg
global decimals
	# calculate angles beta and alpha
	set back [Bearing [GetVal 38 $corner] [GetVal 37 $corner] \
		[GetVal 38 $first] [GetVal 37 $first]]
	set forth [Bearing [GetVal 38 $corner] [GetVal 37 $corner] \
		[GetVal 38 $last] [GetVal 37 $last]]
	set beta [expr {abs($back - $forth)}]
	if {$beta > $PI} {
		set beta [expr {$PI2 - $beta}]
	}
	# left arc?
	set left 0
	# line throw first and corner
	set a [expr {[GetVal 37 $first] - [GetVal 37 $corner]}]
	set b [expr {[GetVal 38 $corner] - [GetVal 38 $first]}]
	set c [expr {[GetVal 38 $first] * [GetVal 37 $corner] - \
		[GetVal 38 $corner] * [GetVal 37 $first]}]
	# last point left to the line?
	if {[expr {$a * [GetVal 38 $last] + $b * [GetVal 37 $last] + $c}] > 0} {
		set left 1
	}
	set alpha [expr {$PI - $beta}]
	# length of transition curve
	set l [expr {$p * $p / double($r)}]
	# data of transition curve
	set tau [expr {$l / 2.0 / $r}]
# fi formulas ???
#	set x [expr {$l - pow($l,5) / 40.0 / pow($p,4)}]
#	set y [expr {pow($l,3) / 6.0 / pow($p,2)}]
#	set x0 [expr {$x - $r * sin($tau)}]
#	set dr [expr {$y - ($r - $r * cos($tau))}]
# ivkituzo zsebkonyv
	set v [expr {pow($l,3) / 40.0 / pow($r,2)}]
	set x [expr {$l - $v + pow($v,2) / 2.16 / $l}]
	set u [expr {pow($l,2) / 6.0 / $r}]
	set y [expr {$u - pow($u,2) / 9.33 / $r}]
	set x0 [expr {$l / 2.0 - pow($l,3) / 240.0 / pow($r,2)}]
	set u [expr {pow($l,2) / 24.0 / $r}]
	set dr [expr {$u - pow($u,2) / 4.67 / $r}]
	# tangent length
	set t [expr {($r + $dr) * tan($alpha / 2.0) + $x0}]
    set arc_len [expr {$r * ($alpha - 2 * $tau)}]
	GeoLog1 "$geoEasyMsg(arcT): [format %.${decimals}f $t]"
	GeoLog1 "$geoEasyMsg(arcRadius): [format %.${decimals}f $r]"
	GeoLog1 "$geoEasyMsg(arcLength): [format %.${decimals}f $arc_len]"
	GeoLog1 [format $geoEasyMsg(arcAlpha) [ANG $alpha] [ANG $beta]]
	GeoLog1 [format $geoEasyMsg(arcTran) $p $dr $l $x0]
	# start of arc
	set xs [expr {$t * sin($back) + [GetVal 38 $corner]}]
	set ys [expr {$t * cos($back) + [GetVal 37 $corner]}]
	set res ""
	lappend res [list [list 5 ${pre}aie1] [list 38 $xs] [list 37 $ys]]
	# end of arc
	set xe [expr {$t * sin($forth) + [GetVal 38 $corner]}]
	set ye [expr {$t * cos($forth) + [GetVal 37 $corner]}]
	lappend res [list [list 5 ${pre}aie2] [list 38 $xe] [list 37 $ye]]
	# distance between corner and middle
	set cm [expr {($r + $dr) / cos($alpha / 2.0) - $r}]
	# middle of arc
	set dir [expr {atan2((sin($back) + sin($forth)) / 2.0, \
		(cos($back) + cos($forth)) / 2.0)}]
	set xm [expr {$cm * sin($dir) + [GetVal 38 $corner]}]
	set ym [expr {$cm * cos($dir) + [GetVal 37 $corner]}]
	lappend res [list [list 5 ${pre}ik] [list 38 $xm] [list 37 $ym]]
	# center of arc
	set xc [expr {($r + $dr) / cos($alpha / 2.0) * sin($dir) + [GetVal 38 $corner]}]
	set yc [expr {($r + $dr) / cos($alpha / 2.0) * cos($dir) + [GetVal 37 $corner]}]
#	lappend res [list [list 5 ${pre}c] [list 38 $xc] [list 37 $yc]]
	set starta [expr {$dir + $PI - $alpha / 2.0 + $tau}]
	# end of transition curve
	set xaiv1 [expr {$xc + $r * sin($starta)}]
	set yaiv1 [expr {$yc + $r * cos($starta)}]
	lappend res [list [list 5 ${pre}aiv1] [list 38 $xaiv1] [list 37 $yaiv1]]
	set da 0
	if {$num} {
		set aa [expr {abs([Bearing $xc $yc $xaiv1 $yaiv1] - [Bearing $xc $yc $xs $ys])}]
		if {$aa > $PI} { set aa [expr {$PI2 - $aa}]}
		set da [expr {($alpha + 2.0 * $aa) / double($num)}]	;# angle step
		set dl [expr {$da * $r}]	;# step on transition curve
	} elseif {$step} {
		set da [expr {$step / double($r)}]
		set dl $step
	}
	if {$da} {
		# points on first transition curve
		set i 1
		set ll $dl
		set dir1 [expr {$back + $PI}]
		while {$dir1 > $PI2} { set dir1 [expr {$dir1 - $PI2}]}
		if {$left} {
			set dir2 [expr {$dir1 - $PI / 2}]
			while {$dir2 < 0} { set dir2 [expr {$dir2 + $PI2}] }
		} else {
			set dir2 [expr {$dir1 + $PI / 2}]
			while {$dir2 > $PI2} { set dir2 [expr {$dir2 - $PI2}]}
		}
		while {$ll > 0.1 && $ll < $l} {
			# local ortogonal coordinates from tangent
			set v [expr {pow($ll,5) / 40.0 / pow($p,4)}]
			set xt [expr {$ll - $v + pow($v,2) / 2.16 / $ll}]
			set u [expr {pow($ll,3) / 6.0 / pow($p,2)}]
			set yt [expr {$u - $ll * pow($u,2) / 9.33 / pow($p,2)}]
			set xp [expr {$xs + sin($dir1) * $xt + sin($dir2) * $yt}]
			set yp [expr {$ys + cos($dir1) * $xt + cos($dir2) * $yt}]
			lappend res [list [list 5 $pre$i] [list 38 $xp] [list 37 $yp]]
			incr i
			set ll [expr {$ll + $dl}]
		}
		# points on pure arc
		set a $da
		while {$a < [expr {$alpha / 2.0 - $tau}]} {
			set xp [expr {$xc + $r * sin($starta + $a)}]
			set yp [expr {$yc + $r * cos($starta + $a)}]
			set a [expr {$a + $da}]
			lappend res [list [list 5 $pre$i] [list 38 $xp] [list 37 $yp]]
			incr i
		}
		set a $da
		set starta [expr {$dir + $PI + $alpha / 2.0 - $tau}]
		while {$a < [expr {$alpha / 2.0 - $tau}]} {
			set xp [ expr {$xc + $r * sin($starta - $a)}]
			set yp [ expr {$yc + $r * cos($starta - $a)}]
			set a [expr {$a + $da}]
			lappend res [list [list 5 $pre$i] [list 38 $xp] [list 37 $yp]]
			incr i
		}
		# points on second transition arc
		set ll $dl
		set dir1 [expr {$forth + $PI}]
		while {$dir1 > $PI2} { set dir1 [expr {$dir1 - $PI2}]}
		if {$left} {
			set dir2 [expr {$dir1 + $PI / 2}]
			while {$dir2 > $PI2} { set dir2 [expr {$dir2 - $PI2}]}
		} else {
			set dir2 [expr {$dir1 - $PI / 2}]
			while {$dir2 < 0} { set dir2 [expr {$dir2 + $PI2}] }
		}
		while {$ll > 0.1 && $ll < $l} {
			# local ortogonal coordinates from tangent
			set v [expr {pow($ll,5) / 40.0 / pow($p,4)}]
			set xt [expr {$ll - $v + pow($v,2) / 2.16 / $ll}]
			set u [expr {pow($ll,3) / 6.0 / pow($p,2)}]
			set yt [expr {$u - $ll * pow($u,2) / 9.33 / pow($p,2)}]
			set xp [expr {$xe + sin($dir1) * $xt + sin($dir2) * $yt}]
			set yp [expr {$ye + cos($dir1) * $xt + cos($dir2) * $yt}]
			lappend res [list [list 5 $pre$i] [list 38 $xp] [list 37 $yp]]
			incr i
			set ll [expr {$ll + $dl}]
		}
	}
	set starta [expr {$dir + $PI + $alpha / 2.0 - $tau}]
	# end of transition curve
	set xaiv2 [expr {$xc + $r * sin($starta)}]
	set yaiv2 [expr {$yc + $r * cos($starta)}]
	lappend res [list [list 5 ${pre}aiv2] [list 38 $xaiv2] [list 37 $yaiv2]]
	return $res
}
