#
# GeoEasy utility to swap horizontal coordinates in a loaded data set
proc SwapXY {dataset} {
    global geoChanged
    upvar #0 ${dataset}_coo coo

    if {! [info exists coo]} {
        GeoLog "Dataset not loaded $dataset"
        return
    }
    foreach pn [array names coo] {
        upvar #0 ${dataset}_coo($pn) coo_rec
        set prelim 0
        set east [GetVal 38 $coo_rec]
        set north [GetVal 37 $coo_rec]
        if {$east == ""} {
            # try preliminary coords
            set east [GetVal 138 $coo_rec]
            set north [GetVal 137 $coo_rec]
            set prelim 1
        }
        if {$east != "" && $north != ""} {
            set coo_rec [DelVal {38 138} $coo_rec]
            set coo_rec [DelVal {37 137} $coo_rec]
            lappend coo_rec [list [expr {$prelim * 100 + 38}] $north]
            lappend coo_rec [list [expr {$prelim * 100 + 37}] $east]
            set geoChanged($dataset) 1
        }
    }
}
