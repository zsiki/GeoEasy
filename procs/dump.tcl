global geoLoaded geoLoadedDir

foreach name $geoLoaded dir $geoLoadedDir {
	SaveTxt $name ${dir}/${name}.csv
	TxtOut $name ${dir}/${name}.dmp
}
