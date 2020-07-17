# GeoEasy script to create a dxf output 
# the file name is the same as the first loaded data set
global geoLoaded geoLoadedDir
global rp dxpn dypn dxz dyz spn sz pon zon slay pnlay zlay p3d zdec \
	pcodelayer xzplane useblock addlines
global contourInterval contourDxf contourLayer contour3Dface

if {[llength $geoLoaded] > 0} {
	# settings to update
	set p3d {0}			;# 3D output
	set pd {0}			;# detail points only
	set pon {1}			;# add point IDs
	set zon {1}			;# add elevation as text
	set slay {PT}		;# layer name for point markers
	set pnlay {PN}		;# layer name for point ID text
	set zlay {ZN}		;# layer name for elevation text
	set rp {1.0}		;# point markes size
	set dxpn {0.8}		;# offset for point ID text
	set dypn {1.0}		;# offset for point ID text
	set dxz {0.8}		;# offset for elevation text
	set dyz {-1.0}		;# offset for elevation text
	set spn {1.8}		;# point ID text size
	set sz {1.5}		;# elevation text size
	set zdec {2}		;# number of decimals in elevation text
	set pcodelayer {0}	;# add point code to layer name
	set xzplane {0}		;# draw in xz plane
	set useblock {0}	;# do not use blocks
	set addlines {0}	;# no line work enabled
	set contourInterval {0}	;# no contours (DTM must be loaded)

	DXFout "[file dirname [lindex $geoLoadedDir 0]]/[lindex $geoLoaded 0].dxf"
}
