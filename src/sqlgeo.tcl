#
#   Save coordinates to postgis SQL 
#   @param fa name of geo data set
#   @param rn name of data file (.csv)
#   @return 0 on success
proc SavePSql {fn rn} {
    global ${fn}_coo
    global geoLoaded
    global geoCodes geoEasyMsg

    if {[info exists geoLoaded]} {
        set pos [lsearch -exact $geoLoaded $fn]
        if {$pos == -1} {
            return -8           ;# geo data set not loaded
        }
    } else {
        return 0
    }
    set f [open $rn w]
    # get epsg code
    set epsg [GeoEntry "$geoCodes(140):" $geoCodes(140)]
    # create table
    puts $f "CREATE TABLE $fn ("
    puts $f "  geom geometry(Pointz, $epsg),"
    puts $f "  psz varchar(20) PRIMARY KEY,"
    puts $f "  code varchar(20)"
    puts $f ");"

    foreach pn [lsort -dictionary [array names ${fn}_coo]] {
        set x [GetVal {38} [set ${fn}_coo($pn)]]
        set y [GetVal {37} [set ${fn}_coo($pn)]]
        set z [GetVal {39} [set ${fn}_coo($pn)]]
        set code [GetVal {4} [set ${fn}_coo($pn)]]
        if {[string length $code]} {
            set code "'$code'"
        } else {
            set code "NULL"
        }
        if {[string length $x] && [string length $y]} {
            if {[string length $z] == 0} { set z 0 }
            puts $f "INSERT INTO $fn "
            puts $f "  VALUES (ST_SetSRID(ST_MakePoint($x,$y,$z), $epsg), '$pn', $code);"
        }
    }
    close $f
    return 0
}
