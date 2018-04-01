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

# transformation between coordinate reference systems
# using cs2cs (from proj.4 project) and temperary files
# @param source epsg code of sourcce reference system
# @param destination epsg code of destination reference system
# @param coords source coordinates lists pn pc east north elev
# @return list of converted coordinates
proc cs2cs {from_epsg to_epsg coords} {
	global geoEasyMsg
	global env
	global cs2csProg

	set res ""
    if {[info exists env(TMP)]} {
        set tmpdir $env(TMP)
    } elseif {[info exists env(TEMP)]} {
        set tmpdir $env(TEMP)
    } else {
        set tmpdir "."
    }
    set tmpname [file join  $tmpdir tmp.txt]
    set tmp1name [file join  $tmpdir tmp1.txt]
    catch {file delete $tmpname $tmp1name]}
	set fp [open $tmpname w]
	foreach coord $coords {
		puts $fp [lrange $coord 2 end]
	}
	close $fp
	if {[catch {eval [concat exec "$cs2csProg -f \"%.7f\" +init=epsg:$from_epsg +to +init=epsg:$to_epsg < $tmpname > $tmp1name"]} msg]} {
		tk_dialog .msg $geoEasyMsg(error) $msg error 0 OK
		return
	}
	set fp1 [open $tmp1name r]
	set tr_coords [split [read $fp] "\n"]
	foreach coord $coords tr_coord $tr_coords {
		set tr [split [string trim $tr_coord "\r"] " \t"]
		if {[llength $tr] > 1} {
			lappend res [concat [lrange $coord 0 1] $tr]	
		}
	}
    catch {file delete $tmpname $tmp1name]}
	return $res
}
