# GeoEasy external script use it for 3.1.3 version or 3.1.3dev after 2020.06.20
# Swap coordinates in all opened dataset
# @param cc code for coords to swap EN/EZ/NZ
# use it from the GeoEasy console window
# 1. Load the script (swap_all.tcl) using the File/Load tcl file from the menu
# 2. Run it entering "SwapAll EN" or "SwapAll EZ" or SwapAll NZ"
proc SwapAll {cc} {
	global geoLoaded

	foreach geo $geoLoaded {
		Swap2 $geo $cc
	}
	RefreshAll
}
