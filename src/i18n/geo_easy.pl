#-------------------------------------------------------------------------------
#
#	-- GeoEasy message file
#
#-------------------------------------------------------------------------------
global fileTypes saveTypes projTypes trTypes trHTypes tr1Types tr2Types \
	tr12Types tinTypes polyTypes vrmlTypes kmlTypes xmlTypes grdTypes txpTypes \
	cadTypes svgTypes pngTypes mskTypes lstTypes docTypes csvTypes tclTypes \
	webTypes
global geoCodes
global geoEasyMsg

# regression types
global reglist
set reglist { "Linia 2D" "Równoległe linie 2D" "Koło" \
	"Płaszczyzna" "Płaszczyzna pozioma" "Płaszczyzna pionowa" \
	"Sfera" "Linia 3D" "Kąt nachylenia płaszczyzn" } ;# "Vertical paraboloid" 

set fileTypes {
	{"GeoEasy format" {.geo .GEO}}
	{"Geodimeter format" {.job .are .JOB .ARE}}
	{"Sokkia set 4 format" {.set .scr .SET .SCR}}
	{"Sokkia sdr format" {.sdr .crd .SDR .CRD}}
	{"Leica GSI format" {.wld .gre .gsi .WLD .GRE .GSI}}
	{"Leica IDEX format" {.idx .IDX}}
	{"TopCon GTS-700 format" {.700 .yxz .gts7 .YXZ .GTS7}}
	{"TopCon GTS-210 format" {.210}}
	{"Trimble M5 format" {.m5 .M5}}
	{"SurvCE RAW format" {.rw5 .RW5}}
	{"n4ce txt format" {.n4c N4C}}
	{"Nikon DTM-300 format" {.nik .NIK}}
	{"Nikon RAW format" {.raw .RAW}}
	{"FOIF format" {.mes .MES}}
	{"Geodat 124 format" {.gdt .GDT}}
	{"GeoProfi format" {.mjk .MJK}}
	{"współrzędne GeoProfi" {.eov .szt .her .hkr .hdr .EOV .SZT .HER .HKR .HDR}}
	{"GeoCalc3 format" {.gmj .GMJ}}
	{"GeoZseni format" {.gjk .GJK}}
	{"Wykaz współrzędnych" {.txt .csv .dat .pnt .TXT .CSV .DAT .PNT}}
	{"Fieldbook" {.dmp .DMP}}
	{"plik DTM GRID" {.asc .arx .ASC .ARX}}
	{"plik AutoCAD DXF" {.dxf .DXF}}
	{"Wszystkie pliki" {.*}}
}

set saveTypes {
	{"GeoEasy format" {.geo}}
	{"Geodimeter współrzędne" {.are}}
	{"Geodimeter pomiary i współrzędne" {.job}}
	{"Sokkia set 4 współrzędne" {.scr}}
	{"Sokkia sdr33 współrzędne" {.sdr}}
	{"Leica współrzędne 8 bajtów" {.wld}}
	{"Leica współrzędne 16 bajtów" {.gsi}}
	{"Nikon DTM-300 współrzędne" {.nik}}
	{"Fieldbook" {.dmp}}
	{"Wykaz współrzędnych" {.csv}}
	{"ITR 2.x wykaz współrzędnych" {.itr}}
	{"GPS Trackmaker" {.txt}}
	{"GPS XML" {.gpx}}
	{"Keyhole Markup Language file" {.kml}}
    {"PostGIS SQL script" {.sql}}
}

set xmlTypes {
	{"GNU GaMa xml wyrównanie 2D" {.g2d}}
	{"GNU GaMa xml wyrównanie 1D" {.g1d}}
	{"GNU GaMa xml  wyrównanie 3D" {.g3d}}
}

set projTypes {{"GeoEasy projekt" {.gpr}}
}

set trTypes {{"Transformacja afiniczna" {.prm}}
}

set trHTypes {{"Przesunięcie pionowe" {.vsh}}
}

set tr1Types {{"Transformacja Helmerta/afiniczna" {.prm}}
}

set tr2Types {{"Transformacja TRAFO" {.all}}
}

set tr12Types {{"Transformacja Helmerta/afiniczna" {.prm}}
	{"Transformacja TRAFO" {.all}}
}

set tinTypes {{"GeoEasy dtm" {.dtm}}
}

set polyTypes {{"Plik źródłowy GeoEasy dtm" {.poly}}
}

set vrmlTypes {{"Virtual reality X3D file" {.x3d}}
	{"Virtual reality wrl file" {.wrl}}
}

set kmlTypes {{"Keyhole Markup Language file" {.kml}}
}

set grdTypes {{"ESRI ASCII GRID" {.asc}}
	{"GRASS ASCII GRID" {.arx}}
}

set txpTypes {{"Txt/csv file definition .txp" {.txp}}
}

set cadTypes {{"AutoCAD DXF" {.dxf}}
}

set svgTypes {{"Scalable Vector Graphics" {.svg}}
}

set pngTypes {{"PNG image" {.png}}
}

set mskTypes {{"GeoEasy mask" {.msk}}
}

set lstTypes {{"Text list" {.lst}}
}

set webTypes {{"Home page" {.html}}
}

set docTypes {{"Rich Text Format" {.rtf}}
}

set csvTypes {{"Comma Separated Values" {.csv}}
}

set tclTypes {{"Tcl script" {.tcl}}
}

#
#	codes used in geo data set
#
set geoCodes(-1)	"Skocz"
set geoCodes(0)		"Informacja"
set geoCodes(1)		"Dane stosowane w połączeniu INFO/DANE"
set geoCodes(2)		"Station number"
set geoCodes(3)		"Wyskokość instrumentu"
set geoCodes(4)		"Kod punktu"
set geoCodes(5)		"Numer punktu"
set geoCodes(6)		"Wyskokość lustra"
set geoCodes(7)		"Kąt poziomy"
set geoCodes(-7)	"Nieużywany"
set geoCodes(8)		"Kąt pionowy"
set geoCodes(-8)	$geoCodes(-7)
set geoCodes(9)		"Długość skośna"
set geoCodes(-9)	$geoCodes(-7)
set geoCodes(10)	"Różnica wysokości"
set geoCodes(-10)	$geoCodes(-7)
set geoCodes(120)	"Height diff. leveling" 
set geoCodes(-120)	$geoCodes(-7)
set geoCodes(11)	"Długość pozioma"
set geoCodes(-11)	$geoCodes(-7)
set geoCodes(12)	"Pole powierzchni"
set geoCodes(13)	"Objętość"
set geoCodes(14)	"Percent of grade"
set geoCodes(15)	"Area file"
set geoCodes(16)	"C1-C2"
set geoCodes(17)	"HAII"
set geoCodes(18)	"VAII"
set geoCodes(19)	"dV"
set geoCodes(20)	"Offset constant to slope distance"
set geoCodes(21)	"Nawiązanie poziome"
set geoCodes(-21)   $geoCodes(-7)
set geoCodes(22)	"Kompensator"
set geoCodes(23)	"Jednostki"
set geoCodes(24)	"HAI"
set geoCodes(25)	"VAI"
set geoCodes(26)	"SVA"
set geoCodes(27)	"SHA"
set geoCodes(28)	"SHD"
set geoCodes(29)	"SHT"
set geoCodes(30)	"Korekta atmosferyczna PPM"
set geoCodes(37)	"X"
set geoCodes(38)	"Y"
set geoCodes(39)	"H"
set geoCodes(40)	"dN"
set geoCodes(41)	"dE"
set geoCodes(42)	"dELE"
set geoCodes(43)	"UTMSC"
set geoCodes(44)	"Nachylenie zbocza"
set geoCodes(45)	"dHA"
set geoCodes(46)	"Odchylenie standardowe"
set geoCodes(47)	"Współrzędna północna"
set geoCodes(48)	"Współrzędna wschodnia."
set geoCodes(49)	"Odległość pionowa"
set geoCodes(50)	"Numer zadania"
set geoCodes(51)	"Data"
set geoCodes(52)	"Czas"
set geoCodes(53)	"ID operatora"
set geoCodes(54)	"ID projektu"
set geoCodes(55)	"ID instrumentu"
set geoCodes(56)	"Temperatura"
set geoCodes(57)	"Pusta linia"
set geoCodes(58)	"Promień Ziemi"
set geoCodes(59)	"Refrakcja"
set geoCodes(60)	"Shot identity"
set geoCodes(61)	"Kod aktywności"
set geoCodes(62)	"Przedmiot odniesienia"
set geoCodes(63)	"Średnica"
set geoCodes(64)	"Promień"
set geoCodes(65)	"Geometria"
set geoCodes(66)	"Figure"
set geoCodes(67)	"SON"
set geoCodes(68)	"SOE"
set geoCodes(69)	"SHT"
set geoCodes(72)	"Radoffs"
set geoCodes(73)	"Rt.offs"
set geoCodes(74)	"Ciśnienie powietrza"
set geoCodes(75)	"dHT"
set geoCodes(76)	"dHD"
set geoCodes(77)	"dHA"
set geoCodes(78)	"com"
set geoCodes(79)	"END"
set geoCodes(80)	"Sekcja"
set geoCodes(81)	"A-parameter"
set geoCodes(82)	"Odstęp między częściami"
set geoCodes(83)	"Cl.ofs"
set geoCodes(100)	"Kąt orientacji"
set geoCodes(101)	"Średni kąt orientacji"
set geoCodes(102)	"Orientacja wstępna"
set geoCodes(103)	"Średnia orientacja wstępna"
set geoCodes(110)	"Obserwator"
set geoCodes(111)	"Kolejność punktów"
set geoCodes(112)	"Licznik powtórzeń"
set geoCodes(114)	"Kierunek stddev \[\"\]"
set geoCodes(115)	"Odległość stddev (additive) \[mm\]"
set geoCodes(116)	"Odległość stddev (multiplyer) \[ppm\]"
set geoCodes(117)	"Długość całkowita"
set geoCodes(118)	"Poziomowanie stddev \[mm/km\]"
set geoCodes(137)	"wstępny X"
set geoCodes(138)	"wstępny Y"
set geoCodes(139)	"wstępny H"
set geoCodes(140)	"kod EPSG"
set geoCodes(237)	"odchylenie standardowe X"
set geoCodes(238)	"odchylenie standardowe Y"
set geoCodes(239)	"odchylenie standardowe H"

#
#	general messages button names
#
set geoEasyMsg(warning)		"ostrzeżenie"
set geoEasyMsg(error)		"błąd"
set geoEasyMsg(info)		"info."
set geoEasyMsg(ok)			"OK"
set geoEasyMsg(yes)			"Tak"
set geoEasyMsg(no)			"Nie"
set geoEasyMsg(cancel)		"Przerwij"
set geoEasyMsg(loadbut)		"Otwórz"
set geoEasyMsg(savebut)		"Zapisz"
set geoEasyMsg(all)			"Wszystkie"
set geoEasyMsg(ende)		"Zakończ"
set geoEasyMsg(ignore)		"Bez ostrzeżeń"
set geoEasyMsg(wait)		"Czekaj"
set geoEasyMsg(help)		"Pomoc"
set geoEasyMsg(find)		"Znajdź"
set geoEasyMsg(findNext)	"Znajdź następny"
set geoEasyMsg(delete)		"Usuń"
set geoEasyMsg(add)			"Dodaj"
set geoEasyMsg(newObs)		"Nowa obserwacja"
set geoEasyMsg(newSt)		"Nowe stanowisko"
set geoEasyMsg(newCoo)		"Nowy punkt"
set geoEasyMsg(insSt)		"Wstaw stanowisko"
set geoEasyMsg(delSt)		"Usuń stanowisko"
set geoEasyMsg(finalCoo)	"Przybliżone -> ostateczne współrzędne"
set geoEasyMsg(lastPoint)	"Punkt końcowy"
set geoEasyMsg(browse)		"Przeglądaj ..."
set geoEasyMsg(up)			"Góra"
set geoEasyMsg(down)		"Dół"
set geoEasyMsg(opensource)	"Open source GPL 2"
#
#	labels
#
set geoEasyMsg(pattern)		"Wzorzec:"
#
#	menu and title texts
#
set geoEasyMsg(maskTitle)		"Select mask"
set geoEasyMsg(graphTitle)		"Graphic window"
set geoEasyMsg(lbTitle)			"Select %d items"
set geoEasyMsg(lbTitle1)		"Select at least %d items"
set geoEasyMsg(lbTitle2)		"Select unknown points"
set geoEasyMsg(lbTitle3)		"Select %d station"
set geoEasyMsg(lbTitle4)		"Select coordinate"
set geoEasyMsg(lbTitle5)		"Select known points"
set geoEasyMsg(lbReg)			"Regression type"
set geoEasyMsg(refTitle)		"Reference direction"
set geoEasyMsg(soTitle)			"Point setting out"
set geoEasyMsg(l1Title)			"First line"
set geoEasyMsg(l2Title)			"Second line"
set geoEasyMsg(p1Title)			"First point"
set geoEasyMsg(p2Title)			"Second point"
set geoEasyMsg(menuFile)		"Plik"
set geoEasyMsg(menuFileNew)		"Nowy ..."
set geoEasyMsg(menuFileLoad)	"Wczytaj ..."
set geoEasyMsg(menuFileLogLoad) "Wczytaj plik log"
set geoEasyMsg(menuFileLogClear) "Wyczyść plik log"
set geoEasyMsg(menuFileTclLoad) "Wczytaj plik tcl"
set geoEasyMsg(menuFileUnload)	"Zamknij"
set geoEasyMsg(menuFileSave)	"Zapisz"
set geoEasyMsg(menuFileSaveAll)	"Zapisz wszystko"
set geoEasyMsg(menuFileSaveAs)	"Zapisz jako ..."
set geoEasyMsg(menuFileJoin)	"Połącz ..."
set geoEasyMsg(menuFileExport)	"Eksport do GNU Gama ..."
set geoEasyMsg(menuProjLoad)	"Wczytaj projekt ..."
set geoEasyMsg(menuProjSave)	"Zapisz projekt ..."
set geoEasyMsg(menuProjClose)	"Zamknij projekt"
set geoEasyMsg(menuComEasy)		"ComEasy ..."
set geoEasyMsg(menuFileStat)	"Statystyki ..."
set geoEasyMsg(menuFileCParam)	"Parametry obliczeń ..."
set geoEasyMsg(menuFileGamaParam) "Parametry wyrównania ..."
set geoEasyMsg(menuFileColor)	"kolory ..."
set geoEasyMsg(menuFileOParam)	"Inne parametry ..."
set geoEasyMsg(menuFileSaveP)	"Zapisz parametry"
set geoEasyMsg(menuFileSaveSelection) "Zapisz zaznaczone ..."
set geoEasyMsg(menuFileFontSetup) "Fonty ..."
set geoEasyMsg(menuFileFind)	"Znajdź"
set geoEasyMsg(menuFileClear)	"Clear content"
set geoEasyMsg(menuFileExit)	"Wyjście"
set geoEasyMsg(menuEdit)		"Edycja"
set geoEasyMsg(menuEditGeo)		"Obserwacje"
set geoEasyMsg(menuEditCoo)		"Współrzędne"
set geoEasyMsg(menuEditPar)		"Parametry obserwacji"
set geoEasyMsg(menuEditMask)	"Load mask definitions"
set geoEasyMsg(menuHelpAbout)	"O GeoEasy ..."
set geoEasyMsg(menuPopupBD)		"Bearing/Odległość"
set geoEasyMsg(menuPopupAngle)	"Setting out"
set geoEasyMsg(menuPopupOri)	"Orientacja"
set geoEasyMsg(menuPopupAppOri)	"Orientacja wstępna"
set geoEasyMsg(menuCalDelOri)	"Usuń orientację ..."
set geoEasyMsg(menuPopupPol)	"Punkt biegunowy"
set geoEasyMsg(menuPopupSec)	"Przecięcie"
set geoEasyMsg(menuPopupRes)	"Resection"
set geoEasyMsg(menuPopupArc)	"Przecięcie łuku"
set geoEasyMsg(menuPopupEle)	"Wysokość"
set geoEasyMsg(menuPopupDetail)	"Detail points"
set geoEasyMsg(menuPopupAdj3D)	"Wyrównanie 3D"
set geoEasyMsg(menuPopupAdj2D)	"Wyrównanie XY"
set geoEasyMsg(menuPopupAdj1D)	"Wyrównanie H"
set geoEasyMsg(menuGraph)		"Okno"
set geoEasyMsg(menuGraNew)		"Nowe okno graficzne"
set geoEasyMsg(menuLogNew)		"Okno logowania"
set geoEasyMsg(menuConsoleNew)	"Okno konsoli"
set geoEasyMsg(menuWin)			"Lista okien"
set geoEasyMsg(menuRefreshAll)	"Odśwież wszystkie okna"
set geoEasyMsg(menuResize)		"Ilość wierszy ..."
set geoEasyMsg(menuMask)		"Maska ..."
set geoEasyMsg(menuGraCom)		"Polecenia"
set geoEasyMsg(menuGraRefresh)	"Odśwież"
set geoEasyMsg(menuGraFind)		"Znajdź punkt ..."
set geoEasyMsg(menuGraPn)		"Numery punktów"
set geoEasyMsg(menuGraObs)		"Obserwacje"
set geoEasyMsg(menuGraDet)		"Detail points"
set geoEasyMsg(menuGraLines)	"Lines"
set geoEasyMsg(menuGraUsed)		"Observed points only"
set geoEasyMsg(menuGraZoomAll)	"Zoom all"
set geoEasyMsg(menuGraDXF)		"DXF output ..."
set geoEasyMsg(menuGraSVG)		"SVG output ..."
set geoEasyMsg(menuGraPng)		"PNG export ..."
set geoEasyMsg(menuGraClose)	"Close"
set geoEasyMsg(menuGraCal)		"Calculate"
set geoEasyMsg(menuCalTra)		"Traversing"
set geoEasyMsg(menuCalTraNode)	"Travesing node"
set geoEasyMsg(menuCalTrig)		"Trigonometrical line"
set geoEasyMsg(menuCalTrigNode) "Trigonometrical node"
set geoEasyMsg(menuCalPre)		"Preliminary coordinates"
set geoEasyMsg(menuRecalcPre)	"Recalculate preliminary coordinates"
set geoEasyMsg(menuCalDet)		"New detail points"
set geoEasyMsg(menuCalDetAll)	"All detail point"
set geoEasyMsg(menuCalOri)		"Orientations"
set geoEasyMsg(menuCalAppOri)	"Preliminary orientations"
set geoEasyMsg(menuCalAdj3D)	"3D network adjustment"
set geoEasyMsg(menuCalAdj2D)	"Horizontal network adjustment"
set geoEasyMsg(menuCalAdj1D)	"Leveling network adjustment"
set geoEasyMsg(menuCalTran)		"Coordinate transformation"
set geoEasyMsg(menuCalHTran)	"Elevation transformation"
set geoEasyMsg(menuCalLine)		"Intersection of two lines"
set geoEasyMsg(menuCalPntLine)	"Point on line"
set geoEasyMsg(menuCalArea)		"Area"
set geoEasyMsg(menuCalLength)	"Length"
set geoEasyMsg(menuCalArc)		"Arc setting out"
set geoEasyMsg(menuCalFront)	"3D intersections"
set geoEasyMsg(menuCoord)		"Coordinate list"
set geoEasyMsg(menuObs)			"Field book"
set geoEasyMsg(menuCheckObs)	"Check field book"
set geoEasyMsg(menuCheckCoord)	"Check coordinate list"
set geoEasyMsg(menuSaveCsv)		"Save as CSV"
set geoEasyMsg(menuSaveHtml)	"Save as HTML"
set geoEasyMsg(menuSaveRtf)		"Save as RTF"
set geoEasyMsg(menuCooTr)		"Transformation ..."
set geoEasyMsg(menuCooTrFile)	"Transformation, parameters from file"
set geoEasyMsg(menuCooDif)		"Coordinate differences"
set geoEasyMsg(menuCooSwapEN)	"Swap East-North"
set geoEasyMsg(menuCooSwapEZ)	"Swap East-Elev"
set geoEasyMsg(menuCooSwapNZ)	"Swap North-Elev"
set geoEasyMsg(menuCooDelAppr)	"Delete preliminary coordinates"
set geoEasyMsg(menuCooDel)		"Delete all coordinates"
set geoEasyMsg(menuPntDel)		"Delete all points"
set geoEasyMsg(menuCooDelDetail) "Delte all detail coordinates"
# regression
set geoEasyMsg(menuReg)			"Regression calculation"
set geoEasyMsg(menuRegLDist)	"Distance from line"
set geoEasyMsg(menuRegPDist)	"Distance from plane"
# dtm/tin
set geoEasyMsg(menuDtm)			"DTM"
set geoEasyMsg(menuDtmCreate)	"Create ..."
set geoEasyMsg(menuDtmLoad)		"Load ..."
set geoEasyMsg(menuDtmAdd)		"Add ..."
set geoEasyMsg(menuDtmUnload)	"Close"
set geoEasyMsg(menuDtmSave)		"Save"
set geoEasyMsg(menuDtmInterp)	"Profile ..."
set geoEasyMsg(menuDtmContour)	"Contours ..."
set geoEasyMsg(menuDtmVolume)	"Volume ..."
set geoEasyMsg(menuDtmVolumeDif) "Volume difference ..."
set geoEasyMsg(menuDtmVrml)		"VRML/X3D export ..."
set geoEasyMsg(menuDtmKml)		"KML export ..."
set geoEasyMsg(menuDtmGrid)		"ASCII grid export ..."
set geoEasyMsg(menuLandXML)		"LandXML export ..."
#
#	Errors and warnings
#
set geoEasyMsg(-1)	"Error opening data file"
set geoEasyMsg(-2)	"Geo data set is already loaded"
set geoEasyMsg(-3)	"Error creating geo file"
set geoEasyMsg(-4)	"Error creating coo file"
set geoEasyMsg(-5)	"Error in data file"
set geoEasyMsg(-6)	"Error opening geo file"
set geoEasyMsg(-7)	"Error opening coo file"
set geoEasyMsg(-8)	"No geo data set loaded"
set geoEasyMsg(-9)	"Error in coordinate file at line:"
set geoEasyMsg(-10) "Error in prject file at line:"
set geoEasyMsg(-11) "Error creating parameter file"
set geoEasyMsg(-12) "Station or target ID missing"
set geoEasyMsg(1)	"No observations in loaded Geo data set"
set geoEasyMsg(2)	"No coordinates in loaded Geo data set"
set geoEasyMsg(skipped) "Unknown record skipped line/item: "
set geoEasyMsg(overw) "File(s) exists, overwrite?"
set geoEasyMsg(loaded)	"Coordinates from the already loaded file are used."
set geoEasyMsg(helpfile)	"Help file not found"
set geoEasyMsg(browser)		"Help cannot be displayed\nregister your html browser to open .html files"
set geoEasyMsg(rtfview)		"RTF file cannot be displayed\nregister your word processor to open .rtf files"
set geoEasyMsg(filetype)	"Unknown file or unsupported type"
set geoEasyMsg(saveext)		"Please specify extension after the file name"
set geoEasyMsg(noGeo)		"No data loaded"
set geoEasyMsg(noStation)	"Missing station record at the beginning of field book"
set geoEasyMsg(saveit)		"Do you want to save data?"
set geoEasyMsg(saveso)		"Do you want to save set out data to geo data set?"
set geoEasyMsg(image)		"Picture not fount: "
set geoEasyMsg(geocode)		"Unknown geo code in mask definition: %s"
set geoEasyMsg(nomask)		"No mask loaded at all"
set geoEasyMsg(wrongmask)	"Error in mask definition: %s"
set geoEasyMsg(openit)		"Do you want to open the result?"
set geoEasyMsg(wrongval)	"Invalid value"
set geoEasyMsg(mustfill)	"You must fill this field, use delete to delete the whole line"
set geoEasyMsg(stndel)		"Are you sure to delete the whole station?"
set geoEasyMsg(recdel)		"Are you sure to delete record?"
set geoEasyMsg(noOri)		"No reference directions or coords for this point"
set geoEasyMsg(noOri1)		"No orientation for point"
set geoEasyMsg(noOri2)		"Orientation cannot be calculated for this station"
set geoEasyMsg(cantOri)		"Orientation cannot be calculated for any station"
set geoEasyMsg(readyOri)	"All station has orientation. Do you want to recalculate all orientation?"
set geoEasyMsg(samePnt)		"Station and reference point has the same coordinates!"
set geoEasyMsg(noStn)		"This is not a station"
set geoEasyMsg(noSec)		"Not enough external directions for intersection"
set geoEasyMsg(noRes)		"Not enough internal directions for resection"
set geoEasyMsg(noArc)		"Not enough distances for arcsection"
set geoEasyMsg(noPol)		"Not enough observations for polar"
set geoEasyMsg(noAdj)		"Not enough observations for adjustment or no orientation for stations"
set geoEasyMsg(noUnknowns)	"There are no unknowns for adjustment"
set geoEasyMsg(pure)		"Too large %s-%s %s %s\n iteration may neccessary"
set geoEasyMsg(noCoo)		"I cannot calculate coordinates"
set geoEasyMsg(noObs)		"Not enough observations for adjustment"
set geoEasyMsg(noAppCoo)	"No coordinates for point"
set geoEasyMsg(noAppZ)		"No elevation for"
set geoEasyMsg(cantSave)	"Can't save file"
set geoEasyMsg(fewCoord)	"Not enough coordinates for the calculation"
set geoEasyMsg(pointsDropped)	"No coordinates for points:"
set geoEasyMsg(delappr)		"Do you want to delete preliminary coordinates?"
set geoEasyMsg(delcoo)		"Do you want to delete all coordinates?"
set geoEasyMsg(delpnt)		"Do you want to delete all points?"
set geoEasyMsg(deldetailpnt)		"Do you want to delete co-ordinates of all detail points?"
set geoEasyMsg(delori)		"Do you want to delete all orientations?"
set geoEasyMsg(nodetail)	"No detail points to calculate"

set geoEasyMsg(double)		"Double coordinates"
set geoEasyMsg(noEle)		"Not enough observations for elevation calculation"
set geoEasyMsg(wrongsel)	"Illegal selection"
set geoEasyMsg(wrongsel1)	"Select exactly %d items"
set geoEasyMsg(wrongsel2)	"Select at least %d items"
set geoEasyMsg(nst)			"Number of occupations:"
set geoEasyMsg(ndist)		"Number of distances:"
set geoEasyMsg(next)		"Number of external directions:"
set geoEasyMsg(usedPn)		"Point name already used in a loaded data set"
set geoEasyMsg(dblPn)		"Repeated point number/coordinate"
set geoEasyMsg(nonNumPn)	"Skipped non numeric point numbers:"
set geoEasyMsg(units)		"Meter and DMS units can be used only"
set geoEasyMsg(nomore)		"No more found"
set geoEasyMsg(tajErr)		"Direction error over limit"
set geoEasyMsg(finalize)	"Finalize preliminary coordinates?"
set geoEasyMsg(logDelete)	"Do you want to delete the log file?"
set geoEasyMsg(cancelled)	"Operation cancelled."
set geoEasyMsg(dist)		"Distance calculation"
set geoEasyMsg(area)		"Area calculation"
set geoEasyMsg(sum)			"Sum"
set geoEasyMsg(sum1)		"Area"
set geoEasyMsg(sum2)		"Perimeter"
set geoEasyMsg(meanp)		"Mean centre"
set geoEasyMsg(centroid)	"Centre of gravity"
set geoEasyMsg(endp)		"Endpoint?"
set geoEasyMsg(maxGr)		"10 graphic windows can be opened only"
set geoEasyMsg(nopng)		"Png export not available"
set geoEasyMsg(orist)		"Not enough known (N,E,Z) oriented stations"

set geoEasyMsg(linreg)		"Regression line cannot be calculated"
set geoEasyMsg(planreg)		"Regression plane cannot be calculated"

set geoEasyMsg(check)		"Fieldbook checking"
set geoEasyMsg(missing)		"Missing obligatory value %s at line %s"
set geoEasyMsg(together)	"Missing value %s at line %s"
set geoEasyMsg(notTogether)	"Values cannot be used together %s at line %s"
set geoEasyMsg(stationpn)	"Station and target are the same point %s at line %s"
set geoEasyMsg(missingstation) "Missing station before line %s"
set geoEasyMsg(doublepn)	"Repeated point for a station %s at line %s"
set geoEasyMsg(numError)	"Error %d"
set geoEasyMsg(csvwarning)	"To save coordinates for import to other software use 'Save as' from the main window. Do you want to continue?"

set geoEasyMsg(tinfailed)	"Failed to create DTM"
set geoEasyMsg(tinload)		"Failed to load DTM"
set geoEasyMsg(fewmassp)	"Few points to create DTM"
set geoEasyMsg(delbreakline) "Delete break line?"
set geoEasyMsg(delhole)		"Delete marker?"
set geoEasyMsg(deldtmpnt)	"Delete DTM point?"
set geoEasyMsg(deldtmtri)	"Delete DTM triangle?"
set geoEasyMsg(errsavedtm)	"Error saving DTM"

set geoEasyMsg(stat)		"Statistics on %d loaded data sets\nNumber of points: %d\nNumber of known points: %d\nNumber of detailed points: %d\nNumber of stations: %d\nNumber of known stations: %d\nNumber of occupations: %d\nNumber of oriented occupations: %d\n"
# gama
set geoEasyMsg(gamapar)		"Adjustment parameters"
set geoEasyMsg(gamaconf)	"Confidence level (0-1)"
set geoEasyMsg(gamaangles)	"Angle units"
set geoEasyMsg(gamatol)		"Tolerance \[mm\]"
set geoEasyMsg(gamadirlimit) "Distance limit \[m\]"
set geoEasyMsg(gamashortout) "Short output list"
set geoEasyMsg(gamasvgout)	"SVG error ellipses"
set geoEasyMsg(gamaxmlout)	"Preserve GaMa XML output"
set geoEasyMsg(gamanull)	"No text file result"
set geoEasyMsg(gamanull1)	"No xml file result"
set geoEasyMsg(gamaori)		"Trouble storing orientation angle"
set geoEasyMsg(gamastdhead0) "Standard deviation of unit weight"
set geoEasyMsg(gamastdhead1) "  m0  apriori    :"
set geoEasyMsg(gamastdhead2) "  m0' aposteriori:"
set geoEasyMsg(gamastdhead3) "% interval"
set geoEasyMsg(gamastdhead4) "contains the m0'/m0 value"
set geoEasyMsg(gamastdhead5) "doesn't contain the m0'/m0 value"
set geoEasyMsg(gamacoohead0) "Adjusted coordinates"
set geoEasyMsg(gamacoohead1) "Point id        E          N          Z"
set geoEasyMsg(gamaobshead0) "Observations"
set geoEasyMsg(gamaobshead1) "Station    Observed    Adj.obs.  Residual    Stdev"
set geoEasyMsg(gamaorihead0) "Orientations"
set geoEasyMsg(gamaorihead1) "Station  Preliminary  Adjusted"
#
# tooltips
#
set geoEasyMsg(toolZoomin)	"Zoom in by window or point"
set geoEasyMsg(toolZoomout)	"Zoom out"
set geoEasyMsg(toolPan)		"Pan"
set geoEasyMsg(toolRuler)	"Distance"
set geoEasyMsg(toolArea)	"Area"
set geoEasyMsg(toolSp)		"Traversing"
set geoEasyMsg(toolReg)		"Regression"
set geoEasyMsg(toolZdtm)	"Height interpolation"
set geoEasyMsg(toolBreak)	"Break line"
set geoEasyMsg(toolHole)	"Hole in DTM"
set geoEasyMsg(toolXchgtri)	"Exchange triangles"
#
# dxf/svg output
#
set geoEasyMsg(dxfpar)		"DXF export parameters"
set geoEasyMsg(svgpar)		"SVG export parameters"
set geoEasyMsg(dxfinpar)	"DXF import parameters"
set geoEasyMsg(layer1)		"Name of point layer"
set geoEasyMsg(block)		"Use blocks"
set geoEasyMsg(layerb)		"Name of block"
set geoEasyMsg(attrib)		"Point number attribute"
set geoEasyMsg(attrcode)	"Point code attribute"
set geoEasyMsg(attrelev)	"Point elevation attribute"
set geoEasyMsg(pcode)		"Point code to layer"
set geoEasyMsg(xzplane)		"Draw in yz plane"
set geoEasyMsg(useblock)	"Blocks"
set geoEasyMsg(pcode1)		"Read point code from layer name"
set geoEasyMsg(dxfpnt)		"Use points"
set geoEasyMsg(3d)			"3D"
set geoEasyMsg(skipdbl)		"Skip double"
set geoEasyMsg(addlines)	"Linework"
set geoEasyMsg(pd)			"Detail points only"
set geoEasyMsg(ptext)		"Point numbers from text"
set geoEasyMsg(layer2)		"Layer name"
set geoEasyMsg(layer3)		"Layer name"
set geoEasyMsg(ssize)		"Symbol size"
set geoEasyMsg(pnon)		"Point name labels"
set geoEasyMsg(dxpn)		"X shift"
set geoEasyMsg(dypn)		"Y shift"
set geoEasyMsg(pzon)		"Elevation labels"
set geoEasyMsg(dxz)			"X shift"
set geoEasyMsg(dyz)			"Y shift"
set geoEasyMsg(zdec)		"Decimals"
set geoEasyMsg(spn)			"Text size"
set geoEasyMsg(sz)			"Text size"
set geoEasyMsg(layerlist)	"Layer list ..."
set geoEasyMsg(blocklist)	"Block list ..."
set geoEasyMsg(attrlist)	"Attr. list ..."
#
#	txt columns
#
set geoEasyMsg(txtcols)		"Columns in file"
#
# parameters
#
set geoEasyMsg(parTitle)	"Calculation parameters"
set geoEasyMsg(angleUnit)   "Angle units"
set geoEasyMsg(distUnit)    "Distance units"
set geoEasyMsg(projred)		"Reduction for projection \[mm/km\]:"
set geoEasyMsg(avgh)		"Average height above MSL \[m\]:"
set geoEasyMsg(stdangle)	"Standard deviation for directions \[\"\]:"
set geoEasyMsg(stddist1)	"Standard deviation for distances \[mm\]:"
set geoEasyMsg(stddist2)	"Standard deviation for distances \[mm/km\]:"
set geoEasyMsg(stdlevel)	"Standard deviation for leveling \[mm/km\]:"
set geoEasyMsg(refr)		"Calculate refraction and Earth curve"
set geoEasyMsg(dec)			"Decimals in results:"
#
# color dialog
#
set geoEasyMsg(colTitle)	"Colour settings"
set geoEasyMsg(mask)		"Mask window"
set geoEasyMsg(mask1Color)	"1st colour in mask window:"
set geoEasyMsg(mask2Color)	"2nd colour in mask window:"
set geoEasyMsg(mask3Color)	"3nd colour in mask window:"
set geoEasyMsg(mask4Color)	"4th colour in mask window:"
set geoEasyMsg(mask5Color)	"5th colour in mask window:"
set geoEasyMsg(obsColor)	"Observation colour"
set geoEasyMsg(lineColor)	"Line colour:"
set geoEasyMsg(finalColor)	"Final coordinates:"
set geoEasyMsg(apprColor)	"Preliminary coordinates:"
set geoEasyMsg(nostationColor) "Point colour:"
set geoEasyMsg(stationColor) "Station colour:"
set geoEasyMsg(orientColor)	"Oriented station colour:"
#
# other parameters
#
set geoEasyMsg(oparTitle)	"Other parameters"
set geoEasyMsg(lcoosep)		"Separator in exported lists:"
set geoEasyMsg(ltxtsep)		"Separators in imported lists:"
set geoEasyMsg(lmultisep)	"Skip repetead separators"
set geoEasyMsg(lautor)		"Autorefresh windows"
set geoEasyMsg(llang)		"Language:"
set geoEasyMsg(loridetail)	"Use detail points in orientation and adjustment"
set geoEasyMsg(lbrowser)	"Browser:"
set geoEasyMsg(lrtfview)	"RTF viewer:"
set geoEasyMsg(defaultgeomask) "Default fieldbook mask:"
set geoEasyMsg(defaultcoomask) "Default coordinate mask:"
set geoEasyMsg(maskrows)	"Number of rows in masks:"
set geoEasyMsg(langChange)	"Save parameters and restart the program to change the language"
set geoEasyMsg(lheader)		"Number of header lines:"
set geoEasyMsg(lfilter)		"Filter expression (regexp):"
#
# tip parameters
#
set geoEasyMsg(tinpar)		"Create DTM"
set geoEasyMsg(gepoints)	"From points in coordinate lists"
set geoEasyMsg(dxffile) 	"From a DXF file"
set geoEasyMsg(dxfpoint)	"Layer for mass points:"
set geoEasyMsg(dxfbreak)	"Layer for break line:"
set geoEasyMsg(dxfhole)		"Layer for hole markers:"
set geoEasyMsg(asciifile)	"From a text file"
set geoEasyMsg(convex)		"Convex boundary"
#
# contour parameters
#
set geoEasyMsg(contourpar)	"Contour lines"
set geoEasyMsg(contourInterval) "Contour interval:"
set geoEasyMsg(contourLayer)	"Layer name from elevation"
set geoEasyMsg(contour3Dface)	"3DFaces to DXF"
set geoEasyMsg(contourIntErr) "Invalid contour interval or DTM"
#
# volume calculation
#
set geoEasyMsg(volumepar)	"Volume calculation"
set geoEasyMsg(volumeLevel)	"Reference height:"
set geoEasyMsg(volumeErr)	"Invalid reference height or DTM"

# orthogonal transformation
set geoEasyMsg(trpar)		"Transformation parameters"
set geoEasyMsg(trdy)		"Shift E:"
set geoEasyMsg(trdx)		"Shift N:"
set geoEasyMsg(trrot)		"Rotation (DMS):"
set geoEasyMsg(trscale)		"Scale factor E and N:"
set geoEasyMsg(trdz)		"Shift Z:"
set geoEasyMsg(trscalez)	"Scale factor for Z:"
set geoEasyMsg(allparnum)	"The number of parameters in the file is more than 21"

# point filter dialog
set geoEasyMsg(filterpar)	"Point filter"
set geoEasyMsg(allpoints)	"All points"
set geoEasyMsg(pointno)		"Point number"
set geoEasyMsg(pointrect)	"Rectangle"
set geoEasyMsg(pointcode)	"Point code"
# proj params
set geoEasyMsg(projpar)		"Projection parameters"
set geoEasyMsg(fromEpsg)	"Source EPSG code:"
set geoEasyMsg(preservz)	"Keep source elevations"
set geoEasyMsg(zfaclabel)	"Z factor:"
set geoEasyMsg(zoffslabel)	"Z offset:"

# observation parameters
set geoEasyMsg(parmask)		"Parameters"

set geoEasyMsg(horizDia)	"New points, new orientations:"
set geoEasyMsg(oriDia)		"New orientations:"
set geoEasyMsg(elevDia)		"New points:"
set geoEasyMsg(adjDia)		"Observations, unknonws: "
set geoEasyMsg(adjModule)	"Network adjustment module needs gama-local, please install it"
set geoEasyMsg(dtmModule)	"DTM module needs triangle, please install it"
set geoEasyMsg(crsModule)	"Reprojection needs cs2cs (from Proj), please install it"
set geoEasyMsg(travLine)	"line"
set geoEasyMsg(trigLineToo)	"Trigonometric line too?"
set geoEasyMsg(noTra)		"Few points for traverse"
set geoEasyMsg(noTraCoo)	"No coordinates for 1st point"
set geoEasyMsg(startTra)	"First point"
set geoEasyMsg(nextTra)		"Next point"
set geoEasyMsg(numTra)		"Point number for node:"
set geoEasyMsg(nodeTra)		"Node"
set geoEasyMsg(freeTra)		"No coordinaters for end point\nfree taverse"
set geoEasyMsg(firstTra)	"No orientation on first point"
set geoEasyMsg(lastTra)		"No orientation on last point"
set geoEasyMsg(distTra)		"Missing distance in traverse"
set geoEasyMsg(angTra)		"Missing angle in traverse"
set geoEasyMsg(error1Tra)	"Error limits                 Angle (sec)        Distance (cm)"
set geoEasyMsg(error2Tra)	"Main, precise traversing "
set geoEasyMsg(error3Tra)	"Precise traversing       "
set geoEasyMsg(error4Tra)	"Main traversing          "
set geoEasyMsg(error5Tra)	"Traversing               "
set geoEasyMsg(error6Tra)	"Rural main traversing    "
set geoEasyMsg(error7Tra)	"Rural traversing         "
set geoEasyMsg(travChk)		"Traversing"
set geoEasyMsg(trigChk)		"Trigonometric line"
set geoEasyMsg(miszTri)		"Missing heighti at the start point in trigonometric line"
set geoEasyMsg(freeTri)		"Free trigonometric line"
set geoEasyMsg(dzTri)		"Cannnot calculate height diff. in trigonometric line"
set geoEasyMsg(errorTri)	"Error limit: "
set geoEasyMsg(limTrig)		"Error is over limit\nDo you want to store heights?"
#
# coordinate transformation
#
set geoEasyMsg(fromCS)		"Data set to transform"
set geoEasyMsg(toCS)		"Target data set"
set geoEasyMsg(fewPoints)	" Few points for transformation"
set geoEasyMsg(pnttitle)	"Reference points"
set geoEasyMsg(typetitle)	"Type of transformation"
set geoEasyMsg(typeHelmert4) "4 parameters orthogonal transformation"
set geoEasyMsg(typeHelmert3) "3 parameters orthogonal transformation"
set geoEasyMsg(typeAffin)	"Affine transformation"
set geoEasyMsg(typePoly2)	"2nd order polynom transformation"
set geoEasyMsg(typePoly3)	"3rd order polynom transformation"
set geoEasyMsg(trSave)		"Save transformed coordinates to file"
set geoEasyMsg(parSave)		"Save transformation parameters to file"
set geoEasyMsg(formulaH4y)	"  E = %s + e * %.9f - n * %.9f"
set geoEasyMsg(formulaH4x)	"  N = %s + e * %.9f + n * %.9f"
set geoEasyMsg(formulaH3y)	"  E = %s + e * %.9f - n * %.9f"
set geoEasyMsg(formulaH3x)	"  N = %s + e * %.9f + n * %.9f"
set geoEasyMsg(formulaAfy)	"  E = %s + e * %.9f + n * %.9f"
set geoEasyMsg(formulaAfx)	"  N = %s + e * %.9f + n * %.9f"
set geoEasyMsg(formulaPrmy) "  E = %s + e * %.9f + n * %.9f"
set geoEasyMsg(formulaPrmx) "  N = %s + e * %.9f + n * %.9f"

set geoEasyMsg(formulaP2)	"  y' = y - %s    x' = x - %s"
set geoEasyMsg(formulaP2y)	"  Y = %s + y' * %.8e + y'^2 * %.8e + x' * %.8e + x'y' * %.8e + x'^2 * %.8e"
set geoEasyMsg(formulaP2x)	"  X = %s + y' * %.8e + y'^2 * %.8e + x' * %.8e + x'y' * %.8e + x'^2 * %.8e"
set geoEasyMsg(formulaP3y)	"  Y = %s + y' * %.8e + y'^2 * %.8e + y'^3 * %.8e + x' * %.8e + y'x' * %.8e + y'^2x' * %.8e + x'^2 * %.8e + y'x'^2 * %.8e + x'^3 * %.8e"
set geoEasyMsg(formulaP3x)	"  X = %s + y' * %.8e + y'^2 * %.8e + y'^3 * %.8e + x' * %.8e + y'x' * %.8e + y'^2x' * %.8e + x'^2 * %.8e + y'x'^2 * %.8e + x'^3 * %.8e"
set geoEasyMsg(formula1D)	"  Z = z + %s"
set geoEasyMsg(scaleRot)	"  Scale = %.8f Rotation = %s"
#
# find/replace dialog
#
set geoEasyMsg(findpar)		"Find/replace"
set geoEasyMsg(findWhat)	"Find:"
set geoEasyMsg(replaceWith) "Replace:"
set geoEasyMsg(findMode)	"Regular expression"
#
# about window messages
#
set y [clock format [clock seconds] -format %Y]
set geoEasyMsg(digikom)		"Sponsored by DigiKom Ltd."
set geoEasyMsg(about1)		"Surveying calculations"
set geoEasyMsg(about2)		"for Land Surveyors"
set geoEasyMsg(modules)		"Modules:"
#
# text window headers
#
set geoEasyMsg(logWin)		"Calculation results"
set geoEasyMsg(consoleWin)	"Tcl console"
set geoEasyMsg(startup)		"Tcl startup script executed: "
set geoEasyMsg(nostartup)	"Tcl startup script failed: "
#
# resize mask
#
set geoEasyMsg(rowCount)	"Number of rows:"
set geoEasyMsg(resize)		"Window size"
#
# log messages
#
set geoEasyMsg(start)		"GeoEasy started"
set geoEasyMsg(stop)		"GeoEasy stopped"
set geoEasyMsg(load)		"data set loaded"
set geoEasyMsg(save)		"data set saved"
set geoEasyMsg(saveas)		"data set saved as:"
set geoEasyMsg(unload)		"data set closed"
set geoEasyMsg(psave)		"project saved"
set geoEasyMsg(pload)		"project loaded"
#
set geoEasyMsg(faces)		"Two faces "
set geoEasyMsg(face2)		"Station   Collimation     Index Distance T.height"
set geoEasyMsg(face3)		"Target        error       error   diff.    diff."
set geoEasyMsg(noface2)		"Double observed point or too big difference between the two faces %s"
set geoEasyMsg(msgsave)		"Parameters saved to geo_easy.msk\nprevious parameters are backed up into geo_easy.msk.bak."
#
#	headers for fixed forms (traversing & adjustment)
#
set geoEasyMsg(tra1)		"Open, no orientation"
set geoEasyMsg(tra2)		"Open, one orientation"
set geoEasyMsg(tra3)		"Open, two orientation"
set geoEasyMsg(tra4)		"Free end"
set geoEasyMsg(head1Tra)	"            bearing    bw dist"
set geoEasyMsg(head2Tra)	"Point        angle     distance  (dE)     (dN)       dE         dN"
set geoEasyMsg(head3Tra)	"           correction  fw dist    corrections      Easting    Northing"

set geoEasyMsg(head1Adj)	"Station    Point      Observation  Residual   Adjusted obs."
set geoEasyMsg(m0Adj)		"Standard deviation of unit weight: %8.4f Number of extra observations %d"
set geoEasyMsg(head2Adj)	"Point      Code        Easting    dE    std dev  Northing  dN    std dev"
set geoEasyMsg(head1Trig)	"                       Height differences"
set geoEasyMsg(head2Trig)	"Point    Distance  Forward Backward    Mean  Correction Elevation"
set geoEasyMsg(head1Sec)	"Point num  Code              E            N       Bearing"
set geoEasyMsg(head1Res)	"Point num  Code              E            N        Direction  Angle"
set geoEasyMsg(head1Arc)	"Point num  Code              E            N        Distance"
set geoEasyMsg(head1Pol)	"Point num  Code              E            N      Distance    Bearing"
set geoEasyMsg(head1Pnt)	"Point num  Code              E            N      Distance    Total dist"
set geoEasyMsg(head1Ele)	"Point num  Code            Height      Distance"
set geoEasyMsg(head1Det)	"                                                                         Oriented   Horizontal"
set geoEasyMsg(head2Det)	"Point num  Code              E            N              H   Station     direction  distance"
set geoEasyMsg(head1Ori)	"Point num  Code         Direction    Bearing   Orient ang   Distance   e\" e\"max   E(m)"
set geoEasyMsg(head1Dis)	"Point num  Point num    Bearing   Distance Slope dis Zenith angle"
set geoEasyMsg(head1Angle)	"Point num  Bearing   Distance Angle     Angle from 1st  Local E     Local N"
# transformation
set geoEasyMsg(head1Tran)	"Point num          e            n            E            N          dE           dN           dist"
set geoEasyMsg(head2Tran)	"Point num          e            n            E            N"
set geoEasyMsg(head1HTran)	"Point num          z            Z           dZ"
set geoEasyMsg(head2HTran)	"Point num          z            Z"
set geoEasyMsg(headTraNode)	"Point num    Length         E            N"
set geoEasyMsg(headTrigNode)	"Point num    Length         Z"
set geoEasyMsg(headDist)	"Point num          E            N         Length"
set geoEasyMsg(head1Front)	"Point num  Code                E            N            dE          dN           Z            dZ"
#
# regression
#
set geoEasyMsg(unknown)			"unknown"
set geoEasyMsg(fixedRadius)		"Fixed radius"
set geoEasyMsg(cantSolve)		"Cannot solve the task"
set geoEasyMsg(head0LinRegX)	"N = %+.8f * E %s"
set geoEasyMsg(head0LinRegY)	"E = %+.8f * N %s"
set geoEasyMsg(hAngleReg)		"Angle from east:"
set geoEasyMsg(vAngleReg)		"Angle from north:"
set geoEasyMsg(correlation)		"Correlation coefficient:"
set geoEasyMsg(head1LinRegX)	"Point num          E            N            dN"
set geoEasyMsg(head1LinRegY)	"Point num          E            N            dE"
set geoEasyMsg(head2LinReg)		"Point num          E            N            dE          dN          dist"
set geoEasyMsg(head0PlaneReg)	"z = %s %+.8f * E %+.8f * N"
set geoEasyMsg(head00PlaneReg)	"Slope direction: %s  Slope angle: %s"
set geoEasyMsg(head1PlaneReg)	"Point num          E            N            Z           dZ"
set geoEasyMsg(head0CircleReg)	"E0 = %s N0 = %s R = %s"
set geoEasyMsg(head1CircleReg)	"Point num          E            N            dE           dN           dR"
set geoEasyMsg(head2CircleReg)	"After %d iteration greater than %.4f m change in unknowns"
set geoEasyMsg(head1PlaneAngle)	"Angle of normals: "
set geoEasyMsg(head2PlaneAngle)	"Intersection line of the two planes\nHorizontal direction: %s   Slope angle: %s "
set geoEasyMsg(head0HPlaneReg)	"z = %s"
set geoEasyMsg(head0LDistReg)	"Distance from the %s - %s line"
set geoEasyMsg(head1LDistReg)	"Point num          E            N        Distance         dE           dN"
set geoEasyMsg(maxLDistReg)		"                      Max distance:  %s"
set geoEasyMsg(head0PDistReg)	"Distance from the %s - %s - %s plane"
set geoEasyMsg(head1PDistReg)	"Point num          E            N            Z        Distance         dE            dN            dZ"
set geoEasyMsg(head0SphereReg)	"E0 = %s N0 = %s Z0 = %s R = %s"
set geoEasyMsg(head1SphereReg)	"Point num          E            N            Z            dE           dN            dZ           dR"
set geoEasyMsg(head0Line3DReg)	"E = %s %+.8f * t\nN = %s %+.8f * t\nZ = %s %+.8f * t"
set geoEasyMsg(head1Line3DReg)	"Point num          E            N            Z            dE           dN           dZ           dt"
#
# dtm
#
set geoEasyMsg(creaDtm)		"Failed to create DTM"
set geoEasyMsg(loadDtm)		"Failed to load DTM"
set geoEasyMsg(regenDtm)	"Regenerate DTM? To create a new DTM close the loaded DTM."
set geoEasyMsg(closDtm)		"Previous DTM will be closed"
set geoEasyMsg(saveDtm)		"Do you want to save previous DTM?"
set geoEasyMsg(ZDtm)		"Height: %.2f m"
set geoEasyMsg(noZDtm)		"No height for the point"
set geoEasyMsg(gridtitle)	"ASCII GRID"
set geoEasyMsg(griddx)		"Grid step:"
set geoEasyMsg(griddx1)		"Grid step: %.2f"
set geoEasyMsg(llc)			"Lower left  corner: %.2f %.2f"
set geoEasyMsg(urc)			"Upper right corner: %.2f %.2f"
set geoEasyMsg(gridvrml)	"VRML export"
set geoEasyMsg(cs2cs)		"Reprojection failed"
set geoEasyMsg(headVolume)	"Base height  Volume        Above        Below       Area     Surface area"
set geoEasyMsg(dtmStat)		"%s DTM\n%d points\n%d triangles\n%d break lines/border lines\n%d holes\nE min: %.2f\nN min: %.2f\nH min: %.2f\nE max: %.2f\nN max: %.2f\nH max: %.2f"
set geoEasyMsg(voldif)		"Cut  Volume: %.1f m3 Area: %.1f m2\nFill Volume: %.1f m3  Area: %.1f m2\nSame: %.1f m2"
set geoEasyMsg(interpolateTin) "Interpolation:"
set geoEasyMsg(interptitle) "Profile"
set geoEasyMsg(lx) "E start: "
set geoEasyMsg(ly) "N start: "
#set geoEasyMsg(lz) "Z: "
set geoEasyMsg(lx1) "E end: "
set geoEasyMsg(ly1) "N end: "
set geoEasyMsg(ldxf) "DXF file"
set geoEasyMsg(lcoo) "Coordinate file"
set geoEasyMsg(lstep) "Step: "
# arc setting out
set geoEasyMsg(cornerTitle) "Arc corner"
set geoEasyMsg(spTitle) "First line"
set geoEasyMsg(epTitle) "Second line"
set geoEasyMsg(arcPar) "Arc parameters"
set geoEasyMsg(arcRadius) "Radius"
set geoEasyMsg(arcLength) "Arc length"
set geoEasyMsg(arcParam) "Transition parameter"
set geoEasyMsg(arcTran) "Transition curve\n  parameter: %.1f\n  dR: %.2f\n  length: %.2f\n  X0: %.2f"
set geoEasyMsg(arcStep) "Distance between detail points \[m\]"
set geoEasyMsg(arcNum) "or number of points"
set geoEasyMsg(arcSave) "Save coordinates"
set geoEasyMsg(arcPrefix) "Point id prefix"
set geoEasyMsg(arcT) "Tangent length"
set geoEasyMsg(arcP) "Transitive arc parameter"
set geoEasyMsg(arcAlpha) "Alpha: %s  Beta: %s"
set geoEasyMsg(arcHeader) "  Point id          E              N"
