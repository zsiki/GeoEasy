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
	{"Format GeoEasy" {.geo .GEO}}
	{"Format Geodimeter" {.job .are .JOB .ARE}}
	{"Format Sokkia set 4" {.set .scr .SET .SCR}}
	{"Format Sokkia sdr" {.sdr .crd .SDR .CRD}}
	{"Format Leica GSI" {.wld .gre .gsi .WLD .GRE .GSI}}
	{"Format Leica IDEX" {.idx .IDX}}
	{"Format TopCon GTS-700" {.700 .yxz .gts7 .YXZ .GTS7}}
	{"Format TopCon GTS-210" {.210}}
	{"Format Trimble M5" {.m5 .M5}}
	{"Format SurvCE RAW" {.rw5 .RW5}}
	{"Format n4ce txt" {.n4c N4C}}
	{"Format Nikon DTM-300" {.nik .NIK}}
	{"Format Nikon RAW" {.raw .RAW}}
	{"Format FOIF" {.mes .MES}}
	{"Format Geodat 124" {.gdt .GDT}}
	{"Format GeoProfi" {.mjk .MJK}}
	{"współrzędne GeoProfi" {.eov .szt .her .hkr .hdr .EOV .SZT .HER .HKR .HDR}}
	{"Format GeoCalc3" {.gmj .GMJ}}
	{"Format GeoZseni" {.gjk .GJK}}
	{"Wykaz współrzędnych" {.txt .csv .dat .pnt .TXT .CSV .DAT .PNT}}
	{"Fieldbook" {.dmp .DMP}}
	{"plik DTM GRID" {.asc .arx .ASC .ARX}}
	{"plik AutoCAD DXF" {.dxf .DXF}}
	{"Wszystkie pliki" {.*}}
}

set saveTypes {
	{"Format GeoEasy" {.geo}}
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

set webTypes {{"Html" {.html}}
}

set docTypes {{"Rich Text Format" {.rtf}}
}

set csvTypes {{"Comma Separated Values" {.csv}}
}

set tclTypes {{"skrypt Tcl" {.tcl}}
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
set geoCodes(20)	"Offset constant to slope Odległość"
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
set geoCodes(66)	"Rysunek"
set geoCodes(67)	"SON"
set geoCodes(68)	"SOE"
set geoCodes(69)	"SHT"
set geoCodes(72)	"Radoffs"
set geoCodes(73)	"Rt.offs"
set geoCodes(74)	"Ciśnienie atmosferyczne"
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
set geoEasyMsg(maskTitle)		"Wybierz maskę"
set geoEasyMsg(graphTitle)		"Okno graficzne"
set geoEasyMsg(lbTitle)			"Wybór %d elementów"
set geoEasyMsg(lbTitle1)		"Wybór co najmniej %d elementów"
set geoEasyMsg(lbTitle2)		"Wybór punktów nieznanych"
set geoEasyMsg(lbTitle3)		"Wybór stacji %d"
set geoEasyMsg(lbTitle4)		"Wybierz współrzędne"
set geoEasyMsg(lbTitle5)		"Wybierz znane punkty"
set geoEasyMsg(lbReg)			"Typ regresji"
set geoEasyMsg(refTitle)		"Kierunek odniesienia"
set geoEasyMsg(soTitle)			"Wyznaczenie punktów"
set geoEasyMsg(l1Title)			"Pierwsza linia"
set geoEasyMsg(l2Title)			"Druga linia"
set geoEasyMsg(p1Title)			"Pierwszy punkt"
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
set geoEasyMsg(menuGraLines)	"Linie"
set geoEasyMsg(menuGraUsed)		"Tylko punkty obserwowane"
set geoEasyMsg(menuGraZoomAll)	"Pokaż wszystko"
set geoEasyMsg(menuGraDXF)		"eksport DXF ..."
set geoEasyMsg(menuGraSVG)		"eksport SVG ..."
set geoEasyMsg(menuGraPng)		"eksport PNG ..."
set geoEasyMsg(menuGraClose)	"Zamknij"
set geoEasyMsg(menuGraCal)		"Obliczenia"
set geoEasyMsg(menuCalTra)		"Traversing"
set geoEasyMsg(menuCalTraNode)	"Travesing node"
set geoEasyMsg(menuCalTrig)		"Linia trygonometryczna"
set geoEasyMsg(menuCalTrigNode) "Węzeł trygonometryczny"
set geoEasyMsg(menuCalPre)		"Współrzędne przybliżone"
set geoEasyMsg(menuRecalcPre)	"Przeliczenie współrzędnych przybliżonych"
set geoEasyMsg(menuCalDet)		"Nowe punkty szczegółowe"
set geoEasyMsg(menuCalDetAll)	"Wszystkie punkty szczegółowe"
set geoEasyMsg(menuCalOri)		"Kierunki"
set geoEasyMsg(menuCalAppOri)	"Kierunki przybliżone"
set geoEasyMsg(menuCalAdj3D)	"Wyrównianie sieci 3D"
set geoEasyMsg(menuCalAdj2D)	"Wyrównianie sieci płaskiej"
set geoEasyMsg(menuCalAdj1D)	"wyrównianie sieci niwelacyjnej"
set geoEasyMsg(menuCalTran)		"Transformacja współrzędnych"
set geoEasyMsg(menuCalHTran)	"Transformacja wysokościowa"
set geoEasyMsg(menuCalLine)		"Przecięcie dwóch prostych"
set geoEasyMsg(menuCalPntLine)	"Punkt na prostej"
set geoEasyMsg(menuCalArea)		"Pole powierzchni"
set geoEasyMsg(menuCalLength)	"Długość"
set geoEasyMsg(menuCalArc)		"Łuk kołowy"
set geoEasyMsg(menuCalFront)	"Przecięcia 3D"
set geoEasyMsg(menuCoord)		"Wykaz współrzędnych"
set geoEasyMsg(menuObs)			"Księga polowa"
set geoEasyMsg(menuCheckObs)	"Sprawdź księgę polową"
set geoEasyMsg(menuCheckCoord)	"Sprawdź wykaz współrzędnych"
set geoEasyMsg(menuSaveCsv)		"Zapisz jako CSV"
set geoEasyMsg(menuSaveHtml)	"Zapisz jako HTML"
set geoEasyMsg(menuSaveRtf)		"Zapisz jako RTF"
set geoEasyMsg(menuCooTr)		"Transformacja ..."
set geoEasyMsg(menuCooTrFile)	"Transformacja, parametry z pliku"
set geoEasyMsg(menuCooDif)		"Różnice współrzędnych"
set geoEasyMsg(menuCooSwapEN)	"Zamiana wschód-północ"
set geoEasyMsg(menuCooSwapEZ)	"Zamień elewację wschodnią"
set geoEasyMsg(menuCooSwapNZ)	"Zamień elewację północną"
set geoEasyMsg(menuCooDelAppr)	"Usuń współrzędne przybliżone"
set geoEasyMsg(menuCooDel)		"Usuń wszystkie współrzędne"
set geoEasyMsg(menuPntDel)		"Usuń wszystkie punkty"
set geoEasyMsg(menuCooDelDetail) "Usuń wszystkie punkty szczegółowe"
# regression
set geoEasyMsg(menuReg)			"Obliczanie regresji"
set geoEasyMsg(menuRegLDist)	"Odległość od linii"
set geoEasyMsg(menuRegPDist)	"Odległość od płaszczyzny"
# dtm/tin
set geoEasyMsg(menuDtm)			"DTM"
set geoEasyMsg(menuDtmCreate)	"Stwórz ..."
set geoEasyMsg(menuDtmLoad)		"Otwórz ..."
set geoEasyMsg(menuDtmAdd)		"Dodaj ..."
set geoEasyMsg(menuDtmUnload)	"Zamknij"
set geoEasyMsg(menuDtmSave)		"Zapisz"
set geoEasyMsg(menuDtmInterp)	"Profil ..."
set geoEasyMsg(menuDtmContour)	"Kontury ..."
set geoEasyMsg(menuDtmVolume)	"Objętość ..."
set geoEasyMsg(menuDtmVolumeDif) "Różnica objętości ..."
set geoEasyMsg(menuDtmVrml)		"eksport VRML/X3D ..."
set geoEasyMsg(menuDtmKml)		"eksport KML..."
set geoEasyMsg(menuDtmGrid)		" export ASCII grid..."
set geoEasyMsg(menuLandXML)		" export LandXML..."
#
#	Errors and warnings
#
set geoEasyMsg(-1)	"Błąd podczas otwierania pliku danych"
set geoEasyMsg(-2)	"Zestaw danych geograficznych jest już załadowany"
set geoEasyMsg(-3)	"Błąd podczas tworzenia pliku geo"
set geoEasyMsg(-4)	"Błąd podczas tworzenia pliku coo"
set geoEasyMsg(-5)	"Błąd w pliku z danymi"
set geoEasyMsg(-6)	"Błąd otwierania pliku geo"
set geoEasyMsg(-7)	"Błąd otwierania pliku coo"
set geoEasyMsg(-8)	"Nie załadowano żadnego zestawu danych"
set geoEasyMsg(-9)	"Błąd w pliku współrzędnych w wierszu:"
set geoEasyMsg(-10) "Błąd w pliku projektu w wierszu:"
set geoEasyMsg(-11) "Błąd podczas tworzenia pliku parametrów"
set geoEasyMsg(-12) "brak ID stanowiska lub celu"
set geoEasyMsg(1)	"Brak obserwacji w załadowanym zbiorze danych"
set geoEasyMsg(2)	"Brak współrzędnych w załadowanym zbiorze danych"
set geoEasyMsg(skipped) "Nieznany rekord, pominięty wiersz/pozycja: "
set geoEasyMsg(overw) "Plik(i) istnieje(ą), nadpisać?"
set geoEasyMsg(loaded)	"Używane są współrzędne z już załadowanego pliku."
set geoEasyMsg(helpfile)	"Nie znaleziono pliku pomocy"
set geoEasyMsg(browser)		"Nie można wyświetlić pomocy\nzarejestruj przeglądarkę html, aby otwierać pliki .html"
set geoEasyMsg(rtfview)		"Nie można wyświetlić RTF\nzarejestruj przeglądarkę RTF, aby otwierać pliki .rtf"
set geoEasyMsg(filetype)	"Nieznany plik lub nieobsługiwany typ"
set geoEasyMsg(saveext)		"Podaj rozszerzenie po nazwie pliku"
set geoEasyMsg(noGeo)		"Brak załadowanych danych"
set geoEasyMsg(noStation)	"Brak wpisu sanowiska na początku dziennika polowego"
set geoEasyMsg(saveit)		"Czy chcesz zapisać dane?"
set geoEasyMsg(saveso)		"Czy chcesz zapisać wytyczone dane w zbiorze danych geograficznych?"
set geoEasyMsg(image)		"Nie znaleziono pliku graficznego: "
set geoEasyMsg(geocode)		"Nieznany kod geograficzny w definicji maski: %s"
set geoEasyMsg(nomask)		"W ogóle nie załadowano maski"
set geoEasyMsg(wrongmask)	"Błąd w definicji maski: %s"
set geoEasyMsg(openit)		"Czy chcesz otworzyć wyniki?"
set geoEasyMsg(wrongval)	"Niewłaściwa wartość"
set geoEasyMsg(mustfill)	"Musisz wypełnić to pole, użyj delete, aby usunąć całą linię"
set geoEasyMsg(stndel)		"Czy na pewno chcesz usunąć całe stanowisko?"
set geoEasyMsg(recdel)		"Czy na pewno usunąć rekord?"
set geoEasyMsg(noOri)		"Brak kierunków nawiązania lub współrzędnych dla tego punktu"
set geoEasyMsg(noOri1)		"Brak orientacji dla punktu"
set geoEasyMsg(noOri2)		"Dla tego stanowiska nie można obliczyć orientacji"
set geoEasyMsg(cantOri)		"Dla żadnego stanowiska nie można obliczyć orientacji"
set geoEasyMsg(readyOri)	"Wszystkie stanowiska mają orientację. Czy chcesz ponownie obliczyć wszystkie orientacje?"
set geoEasyMsg(samePnt)		"Stanowisko i punkt nawiazania mają te same współrzędne!"
set geoEasyMsg(noStn)		"To nie jest stanowisko"
set geoEasyMsg(noSec)		"Za mało zewnętrznych kierunków dla przecięcia"
set geoEasyMsg(noRes)		"Za mało wewnętrznych kierunków dla przecięcia"
set geoEasyMsg(noArc)		"Niewystarczające odległości dla przecięcia łuku"
set geoEasyMsg(noPol)		"Niewystarczająca ilość obserwacji dla bieguna"
set geoEasyMsg(noAdj)		"Niewystarczająca ilość obserwacji do dostosowania lub brak orientacji dla stanowiska"
set geoEasyMsg(noUnknowns)	"Nie ma niewiadomych do dostosowania"
set geoEasyMsg(pure)		"Może być potrzebna %s-%s %s %s\n zbyt duża liczba iteracji"
set geoEasyMsg(noCoo)		"Nie potrafię obliczyć współrzędnych"
set geoEasyMsg(noObs)		"Niewystarczająca ilość obserwacji do dostosowania"
set geoEasyMsg(noAppCoo)	"Brak współrzędnych dla punktu"
set geoEasyMsg(noAppZ)		"Brak wyskości dla"
set geoEasyMsg(cantSave)	"Nie można zapisać pliku"
set geoEasyMsg(fewCoord)	"Zbyt mało współrzędnych do obliczeń"
set geoEasyMsg(pointsDropped)	"Brak współrzędnych dla punktów:"
set geoEasyMsg(delappr)		"Czy chcesz usunąć przybliżone współrzędne?"
set geoEasyMsg(delcoo)		"Czy chcesz usunąć wszystkie współrzędne?"
set geoEasyMsg(delpnt)		"Czy chcesz usunąć wszystkie punkty?"
set geoEasyMsg(deldetailpnt)		"Czy chcesz usunąć współrzędne wszystkich punktów szczegółowych?"
set geoEasyMsg(delori)		"Czy chcesz usunąć wszystkie kierunki?"
set geoEasyMsg(nodetail)	"Brak punktów szczegółowych do obliczeń"

set geoEasyMsg(double)		"Podwójne współrzędne"
set geoEasyMsg(noEle)		"Zbyt mało obserwacji do obliczenia wysokości"
set geoEasyMsg(wrongsel)	"Niedozwolony wybór"
set geoEasyMsg(wrongsel1)	"Wybierz dokładnie %d elementów"
set geoEasyMsg(wrongsel2)	"Wybierz co najmniej %d elementów"
set geoEasyMsg(nst)			"Ilość stanowisk:"
set geoEasyMsg(ndist)		"Ilość długości:"
set geoEasyMsg(next)		"Ilość kierunków zewnętrznych:"
set geoEasyMsg(usedPn)		"Nazwa punktu już użyta w załadowanym zestawie danych"
set geoEasyMsg(dblPn)		"Powtórzony numer/współrzędna punktu"
set geoEasyMsg(nonNumPn)	"Pomijane nie numeryczne numery punktów:"
set geoEasyMsg(units)		"Tylko metry i DMS mogą być uzyte"
set geoEasyMsg(nomore)		"Nie znaleziono więcej"
set geoEasyMsg(tajErr)		"Przekroczony błąd kierunku"
set geoEasyMsg(finalize)	"Sfinalizować wstępne współrzędne?"
set geoEasyMsg(logDelete)	"Czy chcesz usunąć log file?"
set geoEasyMsg(cancelled)	"Operacja przerwana."
set geoEasyMsg(dist)		"Obliczanie odległości"
set geoEasyMsg(area)		"Obliczanie pola"
set geoEasyMsg(sum)			"Suma"
set geoEasyMsg(sum1)		"Pole"
set geoEasyMsg(sum2)		"Obwód"
set geoEasyMsg(meanp)		"Mean centre"
set geoEasyMsg(centroid)	"Środek ciężkości"
set geoEasyMsg(endp)		"Punkt końcowy?"
set geoEasyMsg(maxGr)		"tylko 10 okien graficznych może być otwarte"
set geoEasyMsg(nopng)		"Eksport png nie jest dostępny"
set geoEasyMsg(orist)		"Niewystarczająca ilość zorientowanych stanowisk (X, Y, Z)"

set geoEasyMsg(linreg)		"Nie można obliczyć linii regresji"
set geoEasyMsg(planreg)		"Nie można obliczyć płaszczyzny regresji"

set geoEasyMsg(check)		"Sprawdzanie Fieldbook"
set geoEasyMsg(missing)		"Brak obowiązkowej wartości %s w wierszu %s"
set geoEasyMsg(together)	"Brakująca wartość %s w linii %s"
set geoEasyMsg(notTogether)	"Wartości nie mogą być użyte razem %s w linii %s"
set geoEasyMsg(stationpn)	"Stanowisko i cel są tym samym punktem %s na linii %s"
set geoEasyMsg(missingstation) "Brakujące stanowisko przed linią %s"
set geoEasyMsg(doublepn)	"Punkt powtórzony dla stanowiska %s w linii %s"
set geoEasyMsg(numError)	"Błąd %d"
set geoEasyMsg(csvwarning)	"Aby zapisać współrzędne w celu importu do innego oprogramowania, użyj opcji 'Zapisz jako' w oknie głównym. Czy chcesz kontynuować?"

set geoEasyMsg(tinfailed)	"Błąd tworzenia DTM"
set geoEasyMsg(tinload)		"Błąd odczytu DTM"
set geoEasyMsg(fewmassp)	"Kilka punktów do stworzenia DTM"
set geoEasyMsg(delbreakline) "Usunąć linię przerywaną?"
set geoEasyMsg(delhole)		"Usunąć marker?"
set geoEasyMsg(deldtmpnt)	"Usunąć punkt DTM?"
set geoEasyMsg(deldtmtri)	"Usunąć trójkąt DTM?"
set geoEasyMsg(errsavedtm)	"Błąd zapisu DTM"
set geoEasyMsg(profileFewP) "Less than 2 points on the profile" ;# TODO

set geoEasyMsg(stat)		"Statystyki dotyczące %d załadowanych zbiorów danych\nLiczba punktów: %d\nLiczba znanych punktów: %d\nLiczba punktów szczegółowych: %d\nLiczba stacji: %d\nLiczba znanych stacji: %d\nLiczba zawodów: %d\nLiczba zorientowanych zawodów:%d\n"
# gama
set geoEasyMsg(gamapar)		"Parametry wyrówania"
set geoEasyMsg(gamaconf)	"Poziom ufności (0-1)"
set geoEasyMsg(gamaangles)	"Jednostka pomiaru kąta"
set geoEasyMsg(gamatol)		"Tolerancja \[mm\]"
set geoEasyMsg(gamadirlimit) "Limit odległości \[m\]"
set geoEasyMsg(gamashortout) "Krótka lista wyjściowa"
set geoEasyMsg(gamasvgout)	"Elipsy błędów SVG"
set geoEasyMsg(gamaxmlout)	"Zapisz GaMa XML"
set geoEasyMsg(gamanull)	"Brak wyniku w pliku tekstowym"
set geoEasyMsg(gamanull1)	"Brak wyniku w pliku XML"
set geoEasyMsg(gamaori)		"Problem z zapamiętaniem kąta orientacji"
set geoEasyMsg(gamastdhead0) "Odchylenie standardowe wagi jednostki"
set geoEasyMsg(gamastdhead1) "  m0  apriori    :"
set geoEasyMsg(gamastdhead2) "  m0' aposteriori:"
set geoEasyMsg(gamastdhead3) "% interwał"
set geoEasyMsg(gamastdhead4) "zawiera m0'/m0 wartość"
set geoEasyMsg(gamastdhead5) "nie zawiera m0'/m0 wartości"
set geoEasyMsg(gamacoohead0) "Wyrównanie współrzędne"
set geoEasyMsg(gamacoohead1) "Punkt id        Y          X          Z"
set geoEasyMsg(gamaobshead0) "Obserwacje"
set geoEasyMsg(gamaobshead1) "Station    Observed    Adj.obs.  Residual    Stdev"
set geoEasyMsg(gamaorihead0) "Orientacje"
set geoEasyMsg(gamaorihead1) "Stanowisko wstępnie wyrówanie"
#
# tooltips
#
set geoEasyMsg(toolZoomin)	"Powiększanie o okno lub punkt"
set geoEasyMsg(toolZoomout)	"Powiększenie"
set geoEasyMsg(toolPan)		"Przesunięcie"
set geoEasyMsg(toolRuler)	"Odległość"
set geoEasyMsg(toolArea)	"Pole"
set geoEasyMsg(toolSp)		"Przecięcia"
set geoEasyMsg(toolReg)		"Regresja"
set geoEasyMsg(toolZdtm)	"Interpolacja wysokości"
set geoEasyMsg(toolBreak)	"Linia przerwania"
set geoEasyMsg(toolHole)	"Dziura w DTM"
set geoEasyMsg(toolXchgtri)	"Wymiana trójkątów"
#
# dxf/svg output
#
set geoEasyMsg(dxfpar)		"DXF export parameters"
set geoEasyMsg(svgpar)		"SVG export parameters"
set geoEasyMsg(dxfinpar)	"DXF import parameters"
set geoEasyMsg(layer1)		"Name of point layer"
set geoEasyMsg(block)		"Use blocks"
set geoEasyMsg(layerb)		"Name of block"
set geoEasyMsg(attrib)		"Nr punktuber attribute"
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
set geoEasyMsg(ptext)		"Nr punktubers from text"
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
set geoEasyMsg(distUnit)    "Odległość units"
set geoEasyMsg(projred)		"Reduction for projection \[mm/km\]:"
set geoEasyMsg(avgh)		"Average height above MSL \[m\]:"
set geoEasyMsg(stdangle)	"Standard deviation for directions \[\"\]:"
set geoEasyMsg(stddist1)	"Standard deviation for Odległośćs \[mm\]:"
set geoEasyMsg(stddist2)	"Standard deviation for Odległośćs \[mm/km\]:"
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
set geoEasyMsg(pointno)		"Nr punktuber"
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
set geoEasyMsg(numTra)		"Nr punktuber for node:"
set geoEasyMsg(nodeTra)		"Node"
set geoEasyMsg(freeTra)		"No coordinaters for end point\nfree taverse"
set geoEasyMsg(firstTra)	"No orientation on first point"
set geoEasyMsg(lastTra)		"No orientation on last point"
set geoEasyMsg(distTra)		"Missing Odległość in traverse"
set geoEasyMsg(angTra)		"Missing angle in traverse"
set geoEasyMsg(error1Tra)	"Error limits                 Angle (sec)        Odległość (cm)"
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
set geoEasyMsg(scaleRot)	"  Skala = %.8f Obrót = %s"
#
# find/replace dialog
#
set geoEasyMsg(findpar)		"Znajdź/zamień"
set geoEasyMsg(findWhat)	"Znajdź:"
set geoEasyMsg(replaceWith) "Zamień:"
set geoEasyMsg(findMode)	"Wyrażenie regularne"
#
# about window messages
#
set y [clock format [clock seconds] -format %Y]
set geoEasyMsg(digikom)		"Sponsor: DigiKom Ltd."
set geoEasyMsg(about1)		"Obliczenia geodezyjne"
set geoEasyMsg(about2)		"dla geodetów"
set geoEasyMsg(modules)		"Moduły:"
#
# text window headers
#
set geoEasyMsg(logWin)		"Wyniki obliczeń"
set geoEasyMsg(consoleWin)	"Konsola Tcl"
set geoEasyMsg(startup)		"Wykonano skrypt startowy Tcl: "
set geoEasyMsg(nostartup)	"Skrypt startowy Tcl nie powiódł się: "
#
# resize mask
#
set geoEasyMsg(rowCount)	"Ilość rzędów:"
set geoEasyMsg(resize)		"Wymiary okna"
#
# log messages
#
set geoEasyMsg(start)		"GeoEasy wystartował"
set geoEasyMsg(stop)		"GeoEasy zatrzymany"
set geoEasyMsg(load)		"data set wczytany"
set geoEasyMsg(save)		"data set zapisany"
set geoEasyMsg(saveas)		"data set zapisany jako:"
set geoEasyMsg(unload)		"data set zamknięty"
set geoEasyMsg(psave)		"projekt zapisany"
set geoEasyMsg(pload)		"projekt wczytany"
#
set geoEasyMsg(faces)		"Two faces "
set geoEasyMsg(face2)		"Station   Collimation     Index Odległość T.height"
set geoEasyMsg(face3)		"Target        error       error   diff.    diff."
set geoEasyMsg(noface2)		"Podwójnie obserwowany punkt lub zbyt duża różnica między dwoma obserwacjami %s"
set geoEasyMsg(msgsave)		"Parameters saved to geo_easy.msk\nprevious parameters are backed up into geo_easy.msk.bak."
#
#	headers for fixed forms (traversing & adjustment)
#
set geoEasyMsg(tra1)		"Otwarty, bez orientacji"
set geoEasyMsg(tra2)		"Otwarty, jedna orientacja"
set geoEasyMsg(tra3)		"Otwarty, dwie orientacje"
set geoEasyMsg(tra4)		"Wolny koniec"
set geoEasyMsg(head1Tra)	"            bearing    bw dist"
set geoEasyMsg(head2Tra)	"Point        angle     Odległość  (dE)     (dN)       dE         dN"
set geoEasyMsg(head3Tra)	"           correction  fw dist    corrections      Easting    Northing"

set geoEasyMsg(head1Adj)	"Station    Point      Observation  Residual   Adjusted obs."
set geoEasyMsg(m0Adj)		"Standard deviation of unit weight: %8.4f Number of extra observations %d"
set geoEasyMsg(head2Adj)	"Point      Code        Easting    dE    std dev  Northing  dN    std dev"
set geoEasyMsg(head1Trig)	"                       Height differences"
set geoEasyMsg(head2Trig)	"Point    Odległość  Forward Backward    Mean  Correction Elevation"
set geoEasyMsg(head1Sec)	"Nr punktu  Code              E            N       Bearing"
set geoEasyMsg(head1Res)	"Nr punktu  Code              E            N        Direction  Angle"
set geoEasyMsg(head1Arc)	"Nr punktu  Code              E            N        Odległość"
set geoEasyMsg(head1Pol)	"Nr punktu  Code              E            N      Odległość    Bearing"
set geoEasyMsg(head1Pnt)	"Nr punktu  Code              E            N      Odległość    Total dist"
set geoEasyMsg(head1Ele)	"Nr punktu  Code            Height      Odległość"
set geoEasyMsg(head1Det)	"                                                                         Oriented   Horizontal"
set geoEasyMsg(head2Det)	"Nr punktu  Code              E            N              H   Station     direction  Odległość"
set geoEasyMsg(head1Ori)	"Nr punktu  Code         Direction    Bearing   Orient ang   Odległość   e\" e\"max   E(m)"
set geoEasyMsg(head1Dis)	"Nr punktu  Nr punktu    Bearing   Odległość Slope dis Zenith angle"
set geoEasyMsg(head1Angle)	"Nr punktu  Bearing   Odległość Angle     Angle from 1st  Local E     Local N"
# transformation
set geoEasyMsg(head1Tran)	"Nr punktu          e            n            E            N          dE           dN           dist"
set geoEasyMsg(head2Tran)	"Nr punktu          e            n            E            N"
set geoEasyMsg(head1HTran)	"Nr punktu          z            Z           dZ"
set geoEasyMsg(head2HTran)	"Nr punktu          z            Z"
set geoEasyMsg(headTraNode)	"Nr punktu    Length         E            N"
set geoEasyMsg(headTrigNode)	"Nr punktu    Length         Z"
set geoEasyMsg(headDist)	"Nr punktu          E            N         Length"
set geoEasyMsg(head1Front)	"Nr punktu  Code                E            N            dE          dN           Z            dZ"
#
# regression
#
set geoEasyMsg(unknown)			"nieznany"
set geoEasyMsg(fixedRadius)		"Stały promień"
set geoEasyMsg(cantSolve)		"Nie mogę rozwiązać tego zadania"
set geoEasyMsg(head0LinRegX)	"N = %+.8f * E %s"
set geoEasyMsg(head0LinRegY)	"E = %+.8f * N %s"
set geoEasyMsg(hAngleReg)		"Kąt od wschodu:"
set geoEasyMsg(vAngleReg)		"Kąt od północy:"
set geoEasyMsg(correlation)		"Współczynnik korelacji:"
set geoEasyMsg(head1LinRegX)	"Nr punktu          E            N            dN"
set geoEasyMsg(head1LinRegY)	"Nr punktu          E            N            dE"
set geoEasyMsg(head2LinReg)		"Nr punktu          E            N            dE          dN          dist"
set geoEasyMsg(head0PlaneReg)	"z = %s %+.8f * E %+.8f * N"
set geoEasyMsg(head00PlaneReg)	"Kierunek spadku: %s  Kąt nachylenia: %s"
set geoEasyMsg(head1PlaneReg)	"Nr punktu          E            N            Z           dZ"
set geoEasyMsg(head0CircleReg)	"E0 = %s N0 = %s R = %s"
set geoEasyMsg(head1CircleReg)	"Nr punktu          E            N            dE           dN           dR"
set geoEasyMsg(head2CircleReg)	"After %d iteration greater than %.4f m change in unknowns"
set geoEasyMsg(head1PlaneAngle)	"Angle of normals: "
set geoEasyMsg(head2PlaneAngle)	"Intersection line of the two planes\nHorizontal direction: %s   Kąt nachylenia: %s "
set geoEasyMsg(head0HPlaneReg)	"z = %s"
set geoEasyMsg(head0LDistReg)	"Odległość od linii %s - %s"
set geoEasyMsg(head1LDistReg)	"Nr punktu          E            N        Odległość         dE           dN"
set geoEasyMsg(maxLDistReg)		"                      Max Odległość:  %s"
set geoEasyMsg(head0PDistReg)	"Odległość from the %s - %s - %s plane"
set geoEasyMsg(head1PDistReg)	"Nr punktu          E            N            Z        Odległość         dE            dN            dZ"
set geoEasyMsg(head0SphereReg)	"E0 = %s N0 = %s Z0 = %s R = %s"
set geoEasyMsg(head1SphereReg)	"Nr punktu          E            N            Z            dE           dN            dZ           dR"
set geoEasyMsg(head0Line3DReg)	"E = %s %+.8f * t\nN = %s %+.8f * t\nZ = %s %+.8f * t"
set geoEasyMsg(head1Line3DReg)	"Nr punktu          E            N            Z            dE           dN           dZ           dt"
#
# dtm
#
set geoEasyMsg(creaDtm)		"Nie udało się utworzyć DTM"
set geoEasyMsg(loadDtm)		"Nie udało się wczytać DTM"
set geoEasyMsg(regenDtm)	"Przeliczyć DTM? Aby stworzyć nowy DTM zamknij aktualny DTM"
set geoEasyMsg(closDtm)		"Poprzedni DTM będzie zamknięty"
set geoEasyMsg(saveDtm)		"Czy zamknąć poprzedni DTM?"
set geoEasyMsg(ZDtm)		"Wysokość: %.2f m"
set geoEasyMsg(noZDtm)		"Punkt nie posiada wysokości"
set geoEasyMsg(gridtitle)	"ASCII GRID"
set geoEasyMsg(griddx)		"Krok siatki:"
set geoEasyMsg(griddx1)		"Krok siatki: %.2f"
set geoEasyMsg(llc)			"Lewy dolny narożnik: %.2f %.2f"
set geoEasyMsg(urc)			"Prawy górny narożnik: %.2f %.2f"
set geoEasyMsg(gridvrml)	"Eksport VRML"
set geoEasyMsg(cs2cs)		"Reprojekcja nieudała sie"
set geoEasyMsg(headVolume)	"Wyskokość bazowa  Objętość        Powyżej        Poniżej       Pole     Pole powierzchni"
set geoEasyMsg(dtmStat)		"%s DTM\n%d points\n%d triangles\n%d break lines/border lines\n%d holes\nE min: %.2f\nN min: %.2f\nH min: %.2f\nE max: %.2f\nN max: %.2f\nH max: %.2f"
set geoEasyMsg(voldif)		"Cut  Volume: %.1f m3 Area: %.1f m2\nFill Volume: %.1f m3  Area: %.1f m2\nSame: %.1f m2"
set geoEasyMsg(interpolateTin) "Interpolacja:"
set geoEasyMsg(interptitle) "Profil"
set geoEasyMsg(lx) "Y start: "
set geoEasyMsg(ly) "X start: "
#set geoEasyMsg(lz) "Z: "
set geoEasyMsg(lx1) "Y end: "
set geoEasyMsg(ly1) "X end: "
set geoEasyMsg(ldxf) "plik DXF"
set geoEasyMsg(lcoo) "Plik współrzędnych"
#set geoEasyMsg(lstep) "Krok: "
# arc setting out
set geoEasyMsg(cornerTitle) "Narożnik łuku"
set geoEasyMsg(spTitle) "Pierwsza prosta"
set geoEasyMsg(epTitle) "Druga prosta"
set geoEasyMsg(arcPar) "Parametry łuku"
set geoEasyMsg(arcRadius) "Promień"
set geoEasyMsg(arcLength) "Długość łuku"
set geoEasyMsg(arcParam) "Parametry klotoidy"
set geoEasyMsg(arcTran) "Krzywa przejsciowa\n  parameter: %.1f\n  dR: %.2f\n  długość: %.2f\n  X0: %.2f"
set geoEasyMsg(arcStep) "Odległość pomiędzy punktami \[m\]"
set geoEasyMsg(arcNum) "albo ilość punktów"
set geoEasyMsg(arcSave) "Zapis współrzędnych"
set geoEasyMsg(arcPrefix) "Prefiks punktu"
set geoEasyMsg(arcT) "Długość stycznej"
set geoEasyMsg(arcP) "Parametr krzywej przejściowej"
set geoEasyMsg(arcAlpha) "Alfa: %s  Beta: %s"
set geoEasyMsg(arcHeader) "  Nr punktu          E              N"
