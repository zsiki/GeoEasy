global geoLoaded geoLoadedDir

foreach name $geoLoaded dir $geoLoadedDir {
	SaveTxt $name [file dirname ${dir}]/${name}.csv
	TxtOut $name [file dirname ${dir}]/${name}.dmp
}
