#-------------------------------------------------------------------------------
#
#	-- GeoEasy message file
#
#-------------------------------------------------------------------------------
global fileTypes saveTypes projTypes trTypes trHTypes tr1Types tr2Types \
	tinTypes polyTypes vrmlTypes kmlTypes xmlTypes grdTypes txpTypes \
	cadTypes svgTypes pngTypes mskTypes lstTypes docTypes csvTypes tclTypes \
	webTypes
global geoCodes
global geoEasyMsg

# regression types
global reglist
set reglist { "L\u00EDnea 2D" "L\u00EDneas 2D paralelas" "C\u00EDrculo" \
	"Plano" "Plano horizontal" "Plano vertical" \
	"Esfera" "L\u00EDnea 3D"} ;# "Vertical paraboloid" 

set fileTypes {
	{"Formato GeoEasy" {.geo .GEO}}
	{"Formato Geodimeter" {.job .are .JOB .ARE}}
	{"Formato Sokkia set 4" {.set .scr .SET .SCR}}
	{"Formato Sokkia sdr" {.sdr .crd .SDR .CRD}}
	{"Formato Leica GSI" {.wld .gre .gsi .WLD .GRE .GSI}}
	{"Formato Leica IDEX" {.idx .IDX}}
	{"Formato TopCon GTS-700" {.700 .yxz .gts7 .YXZ .GTS7}}
	{"Formato TopCon GTS-210" {.210}}
	{"Formato Trimble M5" {.m5 .M5}}
	{"Formato SurvCE RAW" {.rw5 .RW5}}
	{"Formato n4ce txt" {.n4c N4C}}
	{"Formato Nikon DTM-300" {.nik .NIK}}
	{"Formato Geodat 124" {.gdt .GDT}}
	{"Formato GeoProfi" {.mjk .MJK}}
	{"Cordenadas GeoProfi" {.eov .szt .her .hkr .hdr .EOV .SZT .HER .HKR .HDR}}
	{"Formato GeoCalc3" {.gmj .GMJ}}
	{"Formato GeoZseni" {.gjk .GJK}}
	{"Lista de Coordenadas" {.txt .csv .dat .pnt .TXT .CSV .DAT .PNT}}
	{"Fieldbook" {.dmp .DMP}}
	{"Archivo DTM GRID" {.asc .arx .ASC .ARX}}
	{"Archivo AutoCAD DXF" {.dxf .DXF}}
	{"Todos los archivos" {.*}}
}

set saveTypes {
	{"Formato GeoEasy " {.geo}}
	{"Coordenadas Geodimeter" {.are}}
	{"Medidas y coordenadas Geodimeter" {.job}}
	{"Coordenadas Sokkia set 4" {.scr}}
	{"Coordenadas Sokkia sdr33" {.sdr}}
	{"Coordenadas Leica de 8 bytes" {.wld}}
	{"Coordenadas Leica de 16 bytes" {.gsi}}
	{"Coordenadas Nikon DTM-300" {.nik}}
	{"Fieldbook" {.dmp}}
	{"Lista de Coordenadas" {.csv}}
	{"Lista de Coordenadas ITR 2.x" {.itr}}
	{"GPS Trackmaker" {.txt}}
	{"GPS XML" {.gpx}}
	{"Archivo Keyhole Markup Language" {.kml}}
}

set xmlTypes {
	{"GNU GaMa xml para ajuste 2D" {.g2d}}
	{"GNU GaMa xml para ajuste 1D" {.g1d}}
	{"GNU GaMa xml para ajuste 3D" {.g3d}}
}

set projTypes {{"Proyecto GeoEasy" {.gpr}}
}

set trTypes {{"Transformaci\u00F3n de Affin" {.prm}}
}

set trHTypes {{"Desplazamiento vertical" {.vsh}}
}

set tr1Types {{"Transformaci\u00F3n ortogonal/af\u00EDn" {.prm}}
}

set tr2Types {{"TRAFO transformaci\u00F3n" {.all}}
}

set tinTypes {{"GeoEasy dtm" {.dtm}}
}

set polyTypes {{"Archivo fuente de GeoEasy dtm" {.poly}}
}

set vrmlTypes {{"Archivo de realidad virtual" {.wrl}}
}

set kmlTypes {{"Archivo Keyhole Markup Language" {.kml}}
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

set pngTypes {{"PNG image" {.png}}			;# TODO
}

set mskTypes {{"GeoEasy mascara" {.msk}}
}

set lstTypes {{"Texto list" {.lst}}
}

set webTypes {{"P\u00E1gina web" {.html}}
}

set docTypes {{"Formato de texto enriquecido" {.rtf}}
}

set csvTypes {{"Valores separados por comas" {.csv}}
}

set tclTypes {{"Script de Tcl" {.tcl}}
}

#
#	codes used in geo data set
#
set geoCodes(-1)	"Saltar"
set geoCodes(0)		"Informaci\u00F3n"
set geoCodes(1)		"Datos utilizados en la combinaci\u00F3n INFO/DATA"
set geoCodes(2)		"Estaci\u00F3n n\u00FAmero"
set geoCodes(3)		"Altura del instrumento"
set geoCodes(4)		"C\u00F3digo del punto"
set geoCodes(5)		"N\u00FAmero del punto"
set geoCodes(6)		"Altura de la se\u00F1al"
set geoCodes(7)		"\u00E1ngulo Horizontal"
set geoCodes(8)		"\u00E1ngulo Vertical"
set geoCodes(9)		"Distancia de la pendiente"
set geoCodes(10)	"Diferencia de altura"
set geoCodes(120)	"Nivelaci\u00F3n de la diferencia de altura" 
set geoCodes(11)	"Distancia horizontal "
set geoCodes(12)	"\u00C1rea de la superficie"
set geoCodes(13)	"Volumen"
set geoCodes(14)	"Porcentaje de grado"
set geoCodes(15)	"Archivo de \u00C1rea"
set geoCodes(16)	"C1-C2"
set geoCodes(17)	"HAII"
set geoCodes(18)	"VAII"
set geoCodes(19)	"dV"
set geoCodes(20)	"Offset constante a la distancia de la pendiente"
set geoCodes(21)	"Referencia horizontal. \u00E1ngulo"
set geoCodes(22)	"Compensador"
set geoCodes(23)	"Unidades"
set geoCodes(24)	"HAI"
set geoCodes(25)	"VAI"
set geoCodes(26)	"SVA"
set geoCodes(27)	"SHA"
set geoCodes(28)	"SHD"
set geoCodes(29)	"SHT"
set geoCodes(30)	"Correcci\u00F3n atmosf\u00E9rica PPM"
set geoCodes(37)	"Norte"
set geoCodes(38)	"Este"
set geoCodes(39)	"Elevaci\u00F3n"
set geoCodes(40)	"dN"
set geoCodes(41)	"dE"
set geoCodes(42)	"dELE"
set geoCodes(43)	"UTMSC"
set geoCodes(44)	"Inclinaci\u00F3n de la pendiente"
set geoCodes(45)	"dHA"
set geoCodes(46)	"Desviaci\u00F3n est\u00E1ndar"
set geoCodes(47)	"Rel. norte coord."
set geoCodes(48)	"Rel. este coord."
set geoCodes(49)	"Distancia vertical"
set geoCodes(50)	"Trabajo n\u00FAmero"
set geoCodes(51)	"Fecha"
set geoCodes(52)	"Hora"
set geoCodes(53)	"Operador id"
set geoCodes(54)	"Proyecto id"
set geoCodes(55)	"Instrumento id"
set geoCodes(56)	"Temperatura"
set geoCodes(57)	"L\u00EDnea en blanco"
set geoCodes(58)	"Radio de la tierra"
set geoCodes(59)	"Refracci\u00F3n"
set geoCodes(60)	"Identidad de disparo"
set geoCodes(61)	"C\u00F3digo de la actividad"
set geoCodes(62)	"Objeto de referencia"
set geoCodes(63)	"Di\u00E1metro"
set geoCodes(64)	"Radio"
set geoCodes(65)	"Geometr\u00EDa"
set geoCodes(66)	"Figura"
set geoCodes(67)	"SON"
set geoCodes(68)	"SOE"
set geoCodes(69)	"SHT"
set geoCodes(72)	"Radoffs"
set geoCodes(73)	"Rt.offs"
set geoCodes(74)	"Presi\u00F3n de aire"
set geoCodes(75)	"dHT"
set geoCodes(76)	"dHD"
set geoCodes(77)	"dHA"
set geoCodes(78)	"com"
set geoCodes(79)	"END"
set geoCodes(80)	"Secci\u00F3n"
set geoCodes(81)	"Par\u00E1metro-A"
set geoCodes(82)	"Intervalo de secciones"
set geoCodes(83)	"Cl.ofs"
set geoCodes(100)	"Orientation \u00E1ngulo"
set geoCodes(101)	"Orientaci\u00F3n media \u00E1ngulo"
set geoCodes(102)	"Orientaci\u00F3n preliminar"
set geoCodes(103)	"Orientaci\u00F3n preliminar media"
set geoCodes(110)	"Observador"
set geoCodes(111)	"Orden de puntos"
set geoCodes(112)	"Repetir el cuenteo"
set geoCodes(114)	"Direcci\u00F3n stddev \[\"\]"
set geoCodes(115)	"Distancia stddev (aditivo) \[mm\]"
set geoCodes(116)	"Distancia stddev (multiplicador) \[ppm\]"
set geoCodes(117)	"Longitud total"
set geoCodes(118)	"Nivelaci\u00F3n stddev \[mm/km\]"
set geoCodes(137)	"Norte prelim."
set geoCodes(138)	"Este prelim."
set geoCodes(139)	"Altura prelim."
set geoCodes(140)	"C\u00F3digo EPSG"
set geoCodes(237)	"Norte stdev"
set geoCodes(238)	"Este stdev"
set geoCodes(239)	"Altura stdev"

#
#	general messages button names
#
set geoEasyMsg(warning)		"Mensaje advertencia"
set geoEasyMsg(error)		"Mensaje error"
set geoEasyMsg(info)		"Mensaje informaci\u00F3n"
set geoEasyMsg(ok)			"Aceptar"
set geoEasyMsg(yes)			"Si"
set geoEasyMsg(no)			"No"
set geoEasyMsg(cancel)		"Cancelar"
set geoEasyMsg(loadbut)		"Cargar"
set geoEasyMsg(savebut)		"Guardar"
set geoEasyMsg(all)			"Todo"
set geoEasyMsg(ende)		"Finalizar"
set geoEasyMsg(ignore)		"Sin advertencias"
set geoEasyMsg(wait)		"Espere"
set geoEasyMsg(help)		"Ayuda"
set geoEasyMsg(find)		"Buscar"
set geoEasyMsg(findNext)	"Buscar siguiente"
set geoEasyMsg(delete)		"Eliminar"
set geoEasyMsg(add)			"Agregar"
set geoEasyMsg(newObs)		"Nueva observaci\u00F3n"
set geoEasyMsg(newSt)		"Nueva estaci\u00F3n"
set geoEasyMsg(newCoo)		"Nuevo punto"
set geoEasyMsg(insSt)		"Inserte registro de estaci\u00F3n"
set geoEasyMsg(delSt)		"Eliminar registro de estaci\u00F3n"
set geoEasyMsg(finalCoo)	"Preliminar -> coordenadas finales"
set geoEasyMsg(lastPoint)	"Punto final"
set geoEasyMsg(browse)		"Navegar ..."
set geoEasyMsg(up)			"Arriba"
set geoEasyMsg(down)		"Abajo"
set geoEasyMsg(opensource)	"Open source GPL 2"
#
#	labels
#
set geoEasyMsg(pattern)		"Patr\u00F3n:"
#
#	menu and title texts
#
set geoEasyMsg(maskTitle)		"Seleccione mascara"
set geoEasyMsg(graphTitle)		"Ventana gr\u00E1fica"
set geoEasyMsg(lbTitle)			"Seleccione %d elementos"
set geoEasyMsg(lbTitle1)		"Seleccione como m\u00EDnimo %d elementos"
set geoEasyMsg(lbTitle2)		"Seleccione puntos desconocidos"
set geoEasyMsg(lbTitle3)		"Seleccione %d estaci\u00F3n"
set geoEasyMsg(lbTitle4)		"Seleccione coordenadas"
set geoEasyMsg(lbTitle5)		"Seleccione puntos conocidos"
set geoEasyMsg(lbReg)			"Tipo de regresi\u00F3n"
set geoEasyMsg(refTitle)		"Direcci\u00F3n de referencia"
set geoEasyMsg(soTitle)			"Punto de partida"
set geoEasyMsg(l1Title)			"Primera l\u00EDneaa"
set geoEasyMsg(l2Title)			"Segunda l\u00EDneaa"
set geoEasyMsg(p1Title)			"Primer punto"
set geoEasyMsg(p2Title)			"Segundo punto"
set geoEasyMsg(menuFile)		"Archivo"
set geoEasyMsg(menuFileNew)		"Nuevo ..."
set geoEasyMsg(menuFileLoad)	"Cargar ..."
set geoEasyMsg(menuFileLogLoad) "Cargar archivo de registro"
set geoEasyMsg(menuFileLogClear) "Borrar archivo de registro"
set geoEasyMsg(menuFileTclLoad) "Cargar archivo tcl"
set geoEasyMsg(menuFileUnload)	"Cerrar"
set geoEasyMsg(menuFileSave)	"Guardar"
set geoEasyMsg(menuFileSaveAll)	"Guardar todo"
set geoEasyMsg(menuFileSaveAs)	"Guardar como ..."
set geoEasyMsg(menuFileJoin)	"Combinar ..."
set geoEasyMsg(menuFileExport)	"Exportar a GNU Gama ..."
set geoEasyMsg(menuProjLoad)	"Cargar proyecto ..."
set geoEasyMsg(menuProjSave)	"Guardar proyecto ..."
set geoEasyMsg(menuProjClose)	"Cerrar proyecto"
set geoEasyMsg(menuComEasy)		"Iniciar ComEasy ..."
set geoEasyMsg(menuFileStat)	"Estad\u00EDsticas ..."
set geoEasyMsg(menuFileCParam)	"Par\u00E1metros de C\u00E1lculo ..."
set geoEasyMsg(menuFileGamaParam) "Par\u00E1metros de ajustes ..."
set geoEasyMsg(menuFileColor)	"Colores ..."
set geoEasyMsg(menuFileOParam)	"Otros par\u00E1metros ..."
set geoEasyMsg(menuFileSaveP)	"Guardar parametros"
set geoEasyMsg(menuFileSaveSelection) "Guardar selection ..."
set geoEasyMsg(menuFileFontSetup) "Fuente ..."
set geoEasyMsg(menuFileFind)	"Buscar"
set geoEasyMsg(menuFileClear)	"Limpiar contenido"
set geoEasyMsg(menuFileExit)	"Salir"
set geoEasyMsg(menuEdit)		"Editar"
set geoEasyMsg(menuEditGeo)		"Observaciones"
set geoEasyMsg(menuEditCoo)		"Coordenadas"
set geoEasyMsg(menuEditPar)		"Par\u00E1metros de observaci\u00F3n"
set geoEasyMsg(menuEditMask)	"Cargar definiciones de m\u00E1scara"
set geoEasyMsg(menuHelpAbout)	"Acerca de GeoEasy ..."
set geoEasyMsg(menuPopupBD)		"Orientaci\u00F3n/Distancia"
set geoEasyMsg(menuPopupAngle)	"Puesta en marcha"
set geoEasyMsg(menuPopupOri)	"Orientaci\u00F3n"
set geoEasyMsg(menuPopupAppOri)	"Appr. orientaci\u00F3n"
set geoEasyMsg(menuCalDelOri)	"Eliminar orientaciones ..."
set geoEasyMsg(menuPopupPol)	"Punto polar"
set geoEasyMsg(menuPopupSec)	"Intersecci\u00F3n"
set geoEasyMsg(menuPopupRes)	"Resecci\u00F3n"
set geoEasyMsg(menuPopupArc)	"Arco de la secci\u00F3n"
set geoEasyMsg(menuPopupEle)	"Elevaci\u00F3n"
set geoEasyMsg(menuPopupDetail)	"Puntos de detalles"
set geoEasyMsg(menuPopupAdj3D)	"Ajuste 3D"
set geoEasyMsg(menuPopupAdj2D)	"Ajuste Horizontal"
set geoEasyMsg(menuPopupAdj1D)	"Ajuste de Elevation"
set geoEasyMsg(menuGraph)		"Ventana"
set geoEasyMsg(menuGraNew)		"Nueva ventana gr\u00E1fica"
set geoEasyMsg(menuLogNew)		"Ventana de registro"
set geoEasyMsg(menuConsoleNew)	"Ventana de comandos"
set geoEasyMsg(menuWin)			"Lista de ventanas"
set geoEasyMsg(menuRefreshAll)	"Refrescar todas las ventanas"
set geoEasyMsg(menuResize)		"N\u00FAmero de filas ..."
set geoEasyMsg(menuMask)		"Mascara ..."
set geoEasyMsg(menuGraCom)		"Comandos"
set geoEasyMsg(menuGraRefresh)	"Refrescar"
set geoEasyMsg(menuGraFind)		"Buscar punto ..."
set geoEasyMsg(menuGraPn)		"Nombres de puntos"
set geoEasyMsg(menuGraObs)		"Observaciones"
set geoEasyMsg(menuGraDet)		"Puntos de detalles"
set geoEasyMsg(menuGraLines)	"Lineas"
set geoEasyMsg(menuGraUsed)		"S\u00F3lo puntos observados"
set geoEasyMsg(menuGraZoomAll)	"Ampliar todo"
set geoEasyMsg(menuGraDXF)		"Salida DXF ..."
set geoEasyMsg(menuGraSVG)      "SVG output ..."		;# TODO
set geoEasyMsg(menuGraPng)      "PNG export ..."		;# TODO
set geoEasyMsg(menuGraClose)	"Cerrar"
set geoEasyMsg(menuGraCal)		"Calcular"
set geoEasyMsg(menuCalTra)		"Medici\u00F3n de pol\u00EDgonos"
set geoEasyMsg(menuCalTraNode)	"Nodo Poligonal"
set geoEasyMsg(menuCalTrig)		"L\u00EDnea trigonom\u00E9trica"
set geoEasyMsg(menuCalTrigNode) "Nodo trigonom\u00E9trico"
set geoEasyMsg(menuCalPre)		"Coordenadas preliminares"
set geoEasyMsg(menuRecalcPre)	"Recalcular las coordenadas preliminares"
set geoEasyMsg(menuCalDet)		"Nuevos puntos de detalle"
set geoEasyMsg(menuCalDetAll)	"Todos los detalles del punto"
set geoEasyMsg(menuCalOri)		"Orientaciones"
set geoEasyMsg(menuCalAppOri)	"Orientaciones preliminares"
set geoEasyMsg(menuCalAdj3D)	"Ajuste 3D de la red"
set geoEasyMsg(menuCalAdj2D)	"Ajuste de la red horizontal"
set geoEasyMsg(menuCalAdj1D)	"Ajuste de la red de nivelaci\u00F3n"
set geoEasyMsg(menuCalTran)		"Transformaci\u00F3n de coordenadas"
set geoEasyMsg(menuCalHTran)	"Transformaci\u00F3n de la elevaci\u00F3n"
set geoEasyMsg(menuCalLine)		"Intersecci\u00F3n de dos l\u00EDneas"
set geoEasyMsg(menuCalPntLine)	"Punto en la l\u00EDnea"
set geoEasyMsg(menuCalArea)		"\u00C1rea"
set geoEasyMsg(menuCalLength)	"Longitud"
set geoEasyMsg(menuCalArc)		"Establecer Arco"
set geoEasyMsg(menuCalFront)	"Intersecciones 3D"
set geoEasyMsg(menuCoord)		"Lista de coordenadas"
set geoEasyMsg(menuObs)			"Libro de campo"
set geoEasyMsg(menuCheckObs)	"Verificar el libro de campo"
set geoEasyMsg(menuCheckCoord)	"Verificar la lista de coordenadas"
set geoEasyMsg(menuSaveCsv)		"Guardar como archivo CSV"
set geoEasyMsg(menuSaveHtml)	"Guardar como archivo HTML"
set geoEasyMsg(menuSaveRtf)		"Guardar como archivo RTF"
set geoEasyMsg(menuCooTr)		"Transformaci\u00F3n ..."
set geoEasyMsg(menuCooTrFile)	"Par\u00E1metros de transformaci\u00F3n desde un archivo"
set geoEasyMsg(menuCooDif)		"Diferencias de coordenadas"
set geoEasyMsg(menuCooDelAppr)	"Borrar coordenadas preliminares"
set geoEasyMsg(menuCooDel)		"Borrar todas las coordenadas"
set geoEasyMsg(menuPntDel)		"Borrar todos los puntos"
set geoEasyMsg(menuCooDelDetail) "Borrar todas las coordenadas detalladas"
# regression
set geoEasyMsg(menuReg)			"C\u00E1lculo de regresi\u00F3n"
set geoEasyMsg(menuRegLDist)	"Distancia desde la l\u00EDnea"
set geoEasyMsg(menuRegPDist)	"Distancia desde el plano"
# dtm/tin
set geoEasyMsg(menuDtm)			"DTM"
set geoEasyMsg(menuDtmCreate)	"Crear ..."
set geoEasyMsg(menuDtmLoad)		"Cargar ..."
set geoEasyMsg(menuDtmAdd)		"Agregar ..."
set geoEasyMsg(menuDtmUnload)	"Cerrar"
set geoEasyMsg(menuDtmSave)		"Guardar"
set geoEasyMsg(menuDtmInterp)	"Perfil ..."
set geoEasyMsg(menuDtmContour)	"Contornos ..."
set geoEasyMsg(menuDtmVolume)	"Volumen ..."
set geoEasyMsg(menuDtmVolumeDif) "Diferencia de volumen ..."
set geoEasyMsg(menuDtmVrml)		"Exportar a VRML ..."
set geoEasyMsg(menuDtmKml)		"Exportar a KML ..."
set geoEasyMsg(menuDtmGrid)		"Exportar a grilla ASCII ..."
set geoEasyMsg(menuLandXML)		"Exportar a LandXML ..."
#
#	Errors and warnings
#
set geoEasyMsg(-1)	"Error al abrir el archivo de datos"
set geoEasyMsg(-2)	"El conjunto de datos geogr\u00E1ficos ya est\u00E1 cargado"
set geoEasyMsg(-3)	"Error al crear el archivo geo"
set geoEasyMsg(-4)	"Error al crear el archivo coo"
set geoEasyMsg(-5)	"Error en el archivo de datos"
set geoEasyMsg(-6)	"Error al abrir el archivo geogr\u00E1fico"
set geoEasyMsg(-7)	"Error al abrir el archivo coo"
set geoEasyMsg(-8)	"No se ha cargado ning\u00FAn conjunto de datos geogr\u00E1ficos"
set geoEasyMsg(-9)	"Error en el archivo de coordenadas en la l\u00EDnea:"
set geoEasyMsg(-10) "Error en el archivo de proyecto en la l\u00EDnea:"
set geoEasyMsg(-11) "Error al crear el archivo de par\u00E1metros"
set geoEasyMsg(-12) "Falta la estaci\u00F3n o el ID de destino"
set geoEasyMsg(1)	"No hay observaciones en el conjunto de datos geogr\u00E1ficos cargados"
set geoEasyMsg(2)	"No hay coordenadas en el conjunto de datos geogr\u00E1ficos cargados"
set geoEasyMsg(skipped) "Registro desconocido omitiendo la l\u00EDnea/elemento: "
set geoEasyMsg(overw) "El archivo(s) existe, desea sobreescribirlo?"
set geoEasyMsg(loaded)	"Se utilizar\u00E1n las coordenadas del archivo ya cargado."
set geoEasyMsg(helpfile)	"El archivo de ayuda no fue encontrado"
set geoEasyMsg(browser)		"El archivo de ayuda no puede ser mostrado\nregistre su navegador para abrir los archivos .html"
set geoEasyMsg(rtfview)		"No se puede visualizar el archivo RTF\nregistre su procesador de textos para abrir archivos .rtf"
set geoEasyMsg(filetype)	"Archivo desconocido o tipo no soportado"
set geoEasyMsg(saveext)		"Por favor, especifique la extensi\u00F3n despu\u00E9s del nombre del archivo"
set geoEasyMsg(noGeo)		"No se han cargado los datos"
set geoEasyMsg(noStation)	"Falta el registro de estaci\u00F3n al principio del libro de campo"
set geoEasyMsg(saveit)		"¿Quieres guardar los datos?"
set geoEasyMsg(saveso)		"¿Desea guardar los datos del conjunto en un conjunto de datos geogr\u00E1ficos?"
set geoEasyMsg(image)		"Imagen no encontrada: "
set geoEasyMsg(geocode)		"C\u00F3digo geogr\u00E1fico desconocido en la definici\u00F3n de la m\u00E1scara: %s"
set geoEasyMsg(nomask)		"No hay ninguna m\u00E1scara cargada"
set geoEasyMsg(wrongmask)	"Error en la definici\u00F3n de la m\u00E1scara: %s"
set geoEasyMsg(openit)		"¿Quieres abrir el resultado?"
set geoEasyMsg(wrongval)	"Valor invalido"
set geoEasyMsg(mustfill)	"Debe rellenar este campo, utilice borrar para borrar toda la l\u00EDnea"
set geoEasyMsg(stndel)		"¿Est\u00E1s seguro de borrar toda la estaci\u00F3n?"
set geoEasyMsg(recdel)		"¿Est\u00E1 seguro de borrar el registro?"
set geoEasyMsg(noOri)		"No hay direcciones o coordenadas de referencia para este punto"
set geoEasyMsg(noOri1)		"No hay orientaci\u00F3n para el punto"
set geoEasyMsg(noOri2)		"La orientaci\u00F3n no puede ser calculada para esta estaci\u00F3n"
set geoEasyMsg(cantOri)		"La orientaci\u00F3n no puede ser calculada para ninguna estaci\u00F3n"
set geoEasyMsg(readyOri)	"Todas las estaciones tienen orientaci\u00F3n. ¿Quieres recalcular toda la orientaci\u00F3n?"
set geoEasyMsg(samePnt)		"La estaci\u00F3n y el punto de referencia tienen las mismas coordenadas!"
set geoEasyMsg(noStn)		"Esto no es una estaci\u00F3n"
set geoEasyMsg(noSec)		"No hay suficientes direcciones externas para la intersecci\u00F3n"
set geoEasyMsg(noRes)		"No hay suficientes direcciones internas para la resecci\u00F3n"
set geoEasyMsg(noArc)		"No hay suficientes distancias para la secci\u00F3n de arco"
set geoEasyMsg(noPol)		"No hay suficientes observaciones para el sistema polar"
set geoEasyMsg(noAdj)		"No hay suficientes observaciones para el ajuste o no hay orientaci\u00F3n para las estaciones"
set geoEasyMsg(noUnknowns)	"No hay inc\u00F3gnitas para ajustar"
set geoEasyMsg(pure)		"Demasiado grande %s-%s %s %s\n una iteraci\u00F3n puede ser necesaria"
set geoEasyMsg(noCoo)		"No se pudier\u00F3n calcular las coordenadas"
set geoEasyMsg(noObs)		"No hay suficientes observaciones para el ajuste"
set geoEasyMsg(noAppCoo)	"No hay coordenadas para el punto"
set geoEasyMsg(noAppZ)		"No hay elevaci\u00F3n para"
set geoEasyMsg(cantSave)	"No se puede guardar el archivo"
set geoEasyMsg(fewCoord)	"No hay suficientes coordenadas para el c\u00E1lculo"
set geoEasyMsg(pointsDropped)	"No hay coordenadas para los puntos:"
set geoEasyMsg(delappr)		"¿Quiere borrar las coordenadas preliminares?"
set geoEasyMsg(delcoo)		"¿Quieres borrar todas las coordenadas?"
set geoEasyMsg(delpnt)		"¿Quieres borrar todos los puntos?"
set geoEasyMsg(deldetailpnt)		"¿Desea borrar las coordenadas de todos los puntos detallados?"
set geoEasyMsg(delori)		"¿Quiere borrar todas las orientaciones?"
set geoEasyMsg(nodetail)	"No hay puntos de detalle que calcular"

set geoEasyMsg(double)		"Coordenadas dobles"
set geoEasyMsg(noEle)		"No hay suficientes observaciones para el c\u00E1lculo de la elevaci\u00F3n"
set geoEasyMsg(wrongsel)	"Selecci\u00F3n ilegal"
set geoEasyMsg(wrongsel1)	"Seleccione exactamente %d elementos"
set geoEasyMsg(wrongsel2)	"Seleccione por lo menos %d elementos"
set geoEasyMsg(nst)			"N\u00FAmero de ocupaciones:"
set geoEasyMsg(ndist)		"N\u00FAmero de distancias:"
set geoEasyMsg(next)		"N\u00FAmero de direcciones externas:"
set geoEasyMsg(usedPn)		"Nombre del punto ya utilizado en un conjunto de datos cargado"
set geoEasyMsg(dblPn)		"Punto repetido n\u00FAmero/coordenada"
set geoEasyMsg(nonNumPn)	"Fuer\u00F3n omitidos los n\u00FAmeros de puntos no num\u00E9ricos:"
set geoEasyMsg(units)		"S\u00F3lo unidades DMS y m\u00E9tricas pueden ser utilizadas"
set geoEasyMsg(nomore)		"No se encuentra m\u00E1s"
set geoEasyMsg(tajErr)		"Error de direcci\u00F3n sobre el l\u00EDmite"
set geoEasyMsg(finalize)	"¿Finalizar las coordenadas preliminares?"
set geoEasyMsg(logDelete)	"¿Desea eliminar el archivo de registro?"
set geoEasyMsg(cancelled)	"Operaci\u00F3n cancelada."
set geoEasyMsg(dist)		"C\u00E1lculo de la distancia"
set geoEasyMsg(area)		"C\u00E1lculo de \u00E1rea"
set geoEasyMsg(sum)			"Sumar"
set geoEasyMsg(sum1)		"\u00C1rea"
set geoEasyMsg(sum2)		"Per\u00EDmetro"
set geoEasyMsg(meanp)		"Centro promedio"
set geoEasyMsg(centroid)	"Centro de gravedad"
set geoEasyMsg(endp)		"Punto final?"
set geoEasyMsg(maxGr)		"S\u00F3lo se pueden abrir 10 ventanas gr\u00E1ficas"
set geoEasyMsg(nopng)       "Png export not available"		;# TODO
set geoEasyMsg(orist)		"No se conoce lo suficiente (N,E,Z) de las estaciones orientadas"

set geoEasyMsg(linreg)		"No se puede calcular la l\u00EDnea de regresi\u00F3n"
set geoEasyMsg(planreg)		"No se puede calcular el plano de regresi\u00F3n"

set geoEasyMsg(check)		"Comprobaci\u00F3n del manual de campo"
set geoEasyMsg(missing)		"Falta el valor obligatorio %s en la l\u00EDnea %s"
set geoEasyMsg(together)	"Falta de valor %s en la l\u00EDnea %s"
set geoEasyMsg(notTogether)	"Los valores no se pueden utilizar juntos %s en la l\u00EDnea %s"
set geoEasyMsg(stationpn)	"La estaci\u00F3n y el objetivo son el mismo punto %s en la l\u00EDnea  %s"
set geoEasyMsg(missingstation) "Falta la estaci\u00F3n antes de la l\u00EDnea %s"
set geoEasyMsg(doublepn)	"Punto repetido para la estaci\u00F3n %s en la l\u00EDnea %s"
set geoEasyMsg(numError)	"Error %d"
set geoEasyMsg(csvwarning)	"Para guardar las coordenadas y para importarlas en otro software utilice 'Guardar como' de la ventana principal. ¿Quiere continuar?"

set geoEasyMsg(tinfailed)	"No se ha podido crear el DTM"
set geoEasyMsg(tinload)		"No se ha podido cargar el  DTM"
set geoEasyMsg(fewmassp)	"Pocos puntos para crear un DTM"
set geoEasyMsg(delbreakline) "¿Borrar la l\u00EDnea de interrupci\u00F3n?"
set geoEasyMsg(delhole)		"¿Eliminar marca?"
set geoEasyMsg(deldtmpnt)	"¿Eliminar punto del DTM?"
set geoEasyMsg(deldtmtri)	"¿Eliminar triangulo del DTM?"
set geoEasyMsg(errsavedtm)	"Error guardando el DTM"

set geoEasyMsg(stat)		"Estad\u00EDsticas en %d el los conjuntos de datos cargados\nN\u00FAmero de puntos: %d\nN\u00FAmero de puntos conocidos: %d\nN\u00FAmero de puntos de detalle: %d\nN\u00FAmero de estaci\u00F3nes: %d\nN\u00FAmero de estaci\u00F3nes conocidas: %d\nN\u00FAmero de ocupaciones: %d\nN\u00FAmero ocupaciones orientadas: %d\n"
# gama
set geoEasyMsg(gamapar)		"Par\u00E1metros de ajuste"
set geoEasyMsg(gamaconf)	"Nivel de confianza (0-1)"
set geoEasyMsg(gamaangles)	"Unidades angulares"
set geoEasyMsg(gamatol)		"Tolerancia \[mm\]"
set geoEasyMsg(gamadirlimit) "Limite de distancia \[m\]"
set geoEasyMsg(gamashortout) "Lista de salida corta"
set geoEasyMsg(gamasvgout)	"ellipses de error SVG"
set geoEasyMsg(gamaxmlout)	"Conservar salida GaMa XML"
set geoEasyMsg(gamanull)	"No hay resultados de archivos de texto"
set geoEasyMsg(gamanull1)	"No hay resultados de archivos xml"
set geoEasyMsg(gamaori)		"Problemas para almacenar el \u00E1ngulo de orientaci\u00F3n"
set geoEasyMsg(gamastdhead0) "Desviaci\u00F3n est\u00E1ndar del peso unitario"
set geoEasyMsg(gamastdhead1) "  m0  apriori    :"
set geoEasyMsg(gamastdhead2) "  m0' aposteriori:"
set geoEasyMsg(gamastdhead3) "% intervalo"
set geoEasyMsg(gamastdhead4) "contiene el valor m0'/m0"
set geoEasyMsg(gamastdhead5) "no contene el valor m0'/m0"
set geoEasyMsg(gamacoohead0) "Coordenadas ajustadas"
set geoEasyMsg(gamacoohead1) "Punto id        E          N          Z"
set geoEasyMsg(gamaobshead0) "Observaciones"
set geoEasyMsg(gamaobshead1) "Estaci\u00F3n    Observado    Adj.obs.  Residual    Stdev"
set geoEasyMsg(gamaorihead0) "Orientaciones"
set geoEasyMsg(gamaorihead1) "Estaci\u00F3n  Preliminar  Ajustada"
#
# tooltips
#
set geoEasyMsg(toolZoomin)	"Ampliar por ventana o por Punto"
set geoEasyMsg(toolZoomout)	"Alejar"
set geoEasyMsg(toolPan)		"Pan"
set geoEasyMsg(toolRuler)	"Distancia"
set geoEasyMsg(toolArea)	"\u00C1rea"
set geoEasyMsg(toolSp)		"Poligonal"
set geoEasyMsg(toolReg)		"Regresi\u00F3n"
set geoEasyMsg(toolZdtm)	"Interpolaci\u00F3n de altura"
set geoEasyMsg(toolBreak)	"L\u00EDnea de corte"
set geoEasyMsg(toolHole)	"Agujero en DTM"
set geoEasyMsg(toolXchgtri)	"Tri\u00E1ngulos de intercambio"
#
# dxf/svg output
#
set geoEasyMsg(dxfpar)		"Par\u00E1metros para exportar en DXF"
set geoEasyMsg(svgpar)      "SVG export parameters"					;# TODO
set geoEasyMsg(dxfinpar)	"Par\u00E1metros para importar en DXF"
set geoEasyMsg(layer1)		"Nombre de la capa de puntos"
set geoEasyMsg(block)		"Use blocks"
set geoEasyMsg(layerb)		"Nombre of block"
set geoEasyMsg(attrib)		"Punto n\u00FAmero attribute"
set geoEasyMsg(attrcode)	"Punto c\u00F3digo attribute"
set geoEasyMsg(attrelev)	"Punto elevation attribute"
set geoEasyMsg(pcode)		"Punto c\u00F3digo to layer"
set geoEasyMsg(xzplane)		"Dibujar en el plano yz"
set geoEasyMsg(useblock)	"Blocks"
set geoEasyMsg(pcode1)		"Leer el c\u00F3digo de punto del nombre de la capa"
set geoEasyMsg(dxfpnt)		"Puntos de utilizaci\u00F3n"
set geoEasyMsg(3d)			"3D"
set geoEasyMsg(addlines)	"Agregar l\u00EDneas"
set geoEasyMsg(pd)			"S\u00F3lo puntos de detalle"
set geoEasyMsg(ptext)		"Punto n\u00FAmeros from texto"
set geoEasyMsg(layer2)		"Capa nombre"
set geoEasyMsg(layer3)		"Capa nombre"
set geoEasyMsg(ssize)		"Symbol tama\u00F1o"
set geoEasyMsg(pnon)		"Punto nombre labels"
set geoEasyMsg(dxpn)		"Cambio de X"
set geoEasyMsg(dypn)		"Cambio de Y"
set geoEasyMsg(pzon)		"Etiquetas de elevaci\u00F3n"
set geoEasyMsg(dxz)			"Cambio de X"
set geoEasyMsg(dyz)			"Cambio de Y"
set geoEasyMsg(zdec)		"Decimales"
set geoEasyMsg(spn)			"Tama\u00F1o de texto"
set geoEasyMsg(sz)			"Tama\u00F1o de texto"
set geoEasyMsg(layerlist)	"Lista capas ..."
set geoEasyMsg(blocklist)	"Lista bloques ..."
set geoEasyMsg(attrlist)	"Lista atributos ..."
#
#	txt columns
#
set geoEasyMsg(txtcols)		"Columnas en el archivo"
#
# parameters
#
set geoEasyMsg(parTitle)	"Par\u00E1metros de c\u00E1lculo"
set geoEasyMsg(projred)		"Reducci\u00F3n para la proyecci\u00F3n \[mm/km\]:"
set geoEasyMsg(avgh)		"Altura media por encima de Nivel medio del mar (MSL) \[m\]:"
set geoEasyMsg(stdangle)	"Desviaci\u00F3n est\u00E1ndar para las direcciones \[\"\]:"
set geoEasyMsg(stddist1)	"Desviaci\u00F3n est\u00E1ndar para las distancias \[mm\]:"
set geoEasyMsg(stddist2)	"Desviaci\u00F3n est\u00E1ndar para las distancias \[mm/km\]:"
set geoEasyMsg(stdlevel)	"Desviaci\u00F3n est\u00E1ndar para la nivelaci\u00F3n \[mm/km\]:"
set geoEasyMsg(refr)		"Calcular la refracci\u00F3n y la curva de la Tierra"
set geoEasyMsg(dec)			"Decimales en los resultados:"
#
# color dialog
#
set geoEasyMsg(colTitle)	"Configuraci\u00F3n de colores"
set geoEasyMsg(mask)		"Ventana de mascara"
set geoEasyMsg(mask1Color)	"1st color en la ventana de la m\u00E1scara:"
set geoEasyMsg(mask2Color)	"2nd color en la ventana de la m\u00E1scara:"
set geoEasyMsg(mask3Color)	"3nd color en la ventana de la m\u00E1scara:"
set geoEasyMsg(mask4Color)	"4th color en la ventana de la m\u00E1scara:"
set geoEasyMsg(mask5Color)	"5th color en la ventana de la m\u00E1scara:"
set geoEasyMsg(obsColor)	"Color de las observaciones"
set geoEasyMsg(lineColor)	"Color de la l\u00EDnea:"
set geoEasyMsg(finalColor)	"Coordenadas finales:"
set geoEasyMsg(apprColor)	"Coordenadas preliminares:"
set geoEasyMsg(nostationColor) "Color de los puntos:"
set geoEasyMsg(stationColor) "Color de las estaci\u00F3n:"
set geoEasyMsg(orientColor)	"Color de las estaci\u00F3nes orientadas:"
#
# other parameters
#
set geoEasyMsg(oparTitle)	"Otros par\u00E1metros"
set geoEasyMsg(lcoosep)		"Separador en las listas exportadas:"
set geoEasyMsg(ltxtsep)		"Separador en las listas importadas:"
set geoEasyMsg(lmultisep)	"Saltar los separadores de repetici\u00F3n"
set geoEasyMsg(lautor)		"Autorrefrescar ventanas"
set geoEasyMsg(llang)		"Idioma:"
set geoEasyMsg(loridetail)	"Utilizar los puntos de detalle en la orientaci\u00F3n y el ajuste"
set geoEasyMsg(lbrowser)	"Navegador:"
set geoEasyMsg(lrtfview)	"Visor de RTF:"
set geoEasyMsg(defaultgeomask) "M\u00E1scara del manual de campo por defecto:"
set geoEasyMsg(defaultcoomask) "M\u00E1scara de coordenadas por defecto:"
set geoEasyMsg(maskrows)	"N\u00FAmero de filas en m\u00E1scaras:"
set geoEasyMsg(langChange)	"Guardar par\u00E1metros y reiniciar el programa para cambiar el idioma"
set geoEasyMsg(lheader)		"N\u00FAmero de l\u00EDneas de cabecera:"
set geoEasyMsg(lfilter)		"Filtro de expresiones (regexp):"
#
# tip parameters
#
set geoEasyMsg(tinpar)		"Crear DTM"
set geoEasyMsg(gepoints)	"Desde puntos en listas de coordenadas"
set geoEasyMsg(dxffile) 	"Desde un archivo DXF"
set geoEasyMsg(dxfpoint)	"Capa para puntos en masa:"
set geoEasyMsg(dxfbreak)	"Capa para l\u00EDnea de corte:"
set geoEasyMsg(dxfhole)		"Capa para marcadores de agujeros:"
set geoEasyMsg(asciifile)	"Desde un archivo de texto"
set geoEasyMsg(convex)		"Contorno convexo"
#
# contour parameters
#
set geoEasyMsg(contourpar)	"L\u00EDneas de contorno"
set geoEasyMsg(contourInterval) "Intervalo de contornos:"
set geoEasyMsg(contourLayer)	"Nombre de la capa desde la elevaci\u00F3n"
set geoEasyMsg(contour3Dface)	"3DFaces to DXF"
set geoEasyMsg(contourIntErr) "Intervalo de contorno no v\u00E1lido o DTM"
#
# volume calculation
#
set geoEasyMsg(volumepar)	"C\u00E1lculo de volumen"
set geoEasyMsg(volumeLevel)	"Altura de referencia:"
set geoEasyMsg(volumeErr)	"Altura de referencia inv\u00E1lida o DTM"

# orthogonal transformation
set geoEasyMsg(trpar)		"Par\u00E1metros de transformaci\u00F3n"
set geoEasyMsg(trdy)		"Cambio E:"
set geoEasyMsg(trdx)		"Cambio N:"
set geoEasyMsg(trrot)		"Rotation (DMS):"
set geoEasyMsg(trscale)		"Factor de escala para E y N:"
set geoEasyMsg(trdz)		"Cambio Z:"
set geoEasyMsg(trscalez)	"Factor de escala para Z:"
set geoEasyMsg(allparnum)	"El n\u00FAmero of par\u00E1metros en el archivo es m\u00E1s de 21"

# point filter dialog
set geoEasyMsg(filterpar)	"Filtrar Punto"
set geoEasyMsg(allpoints)	"Todos los puntos"
set geoEasyMsg(pointno)		"N\u00FAmero de punto"
set geoEasyMsg(pointrect)	"Rect\u00E1ngulo"
set geoEasyMsg(pointcode)	"C\u00F3digo del Punto"
# proj params
set geoEasyMsg(projpar)		"Par\u00E1metros de proyecci\u00F3n"
set geoEasyMsg(fromEpsg)	"C\u00F3digo EPSG origen:"
set geoEasyMsg(preservz)	"Mantener las elevaciones del origen"
set geoEasyMsg(zfaclabel)	"Factor Z:"
set geoEasyMsg(zoffslabel)	"desplazamiento de Z:"

# observation parameters
set geoEasyMsg(parmask)		"Par\u00E1metros"

set geoEasyMsg(horizDia)	"Nuevos puntos, Nuevas orientaciones:"
set geoEasyMsg(oriDia)		"Nuevas orientaciones:"
set geoEasyMsg(elevDia)		"Nuevos puntos:"
set geoEasyMsg(adjDia)		"Observaciones, desconocidas: "
set geoEasyMsg(adjModule)	"El m\u00F3dulo de ajuste de la red necesita gama-local, por favor, inst\u00E1lelo"
set geoEasyMsg(dtmModule)	"El m\u00F3dulo DTM necesita triangle, por favor, inst\u00E1lelo"
set geoEasyMsg(crsModule)	"Reproyecci\u00F3n necesita cs2cs (de Proj), por favor inst\u00E1lelo"
set geoEasyMsg(travLine)	"l\u00EDnea"
set geoEasyMsg(trigLineToo)	"Trigonometric l\u00EDnea too?"
set geoEasyMsg(noTra)		"Few puntos for traverse"
set geoEasyMsg(noTraCoo)	"No coordinates for 1st Punto"
set geoEasyMsg(startTra)	"Primer punto"
set geoEasyMsg(nextTra)		"Siguiente punto"
set geoEasyMsg(numTra)		"Punto n\u00FAmero para el nodo:"
set geoEasyMsg(nodeTra)		"Nodo"
set geoEasyMsg(freeTra)		"No coordinaters for final Punto\nfree taverse"
set geoEasyMsg(firstTra)	"No orientation on 1st Punto\nbeillesztett traverse"
set geoEasyMsg(lastTra)		"No orientation on last Punto\negyszeresen taj."
set geoEasyMsg(firstTra)	"No orientation on first beillesztett"
set geoEasyMsg(lastTra)		"No orientation on last egyik vegen"
set geoEasyMsg(distTra)		"Missing distancia in traverse"
set geoEasyMsg(angTra)		"Missing \u00E1ngulo in traverse"
set geoEasyMsg(error1Tra)	"Error limits                 \u00C1ngulo (sec)        Distancia (cm)"
set geoEasyMsg(error2Tra)	"Main, precise traversing "
set geoEasyMsg(error3Tra)	"Precise traversing       "
set geoEasyMsg(error4Tra)	"Main traversing          "
set geoEasyMsg(error5Tra)	"Traversing               "
set geoEasyMsg(error6Tra)	"Rural main traversing    "
set geoEasyMsg(error7Tra)	"Rural traversing         "
set geoEasyMsg(travChk)		"Traversing"
set geoEasyMsg(trigChk)		"Trigonometric l\u00EDnea"
set geoEasyMsg(miszTri)		"Missing heighti at the inicio Punto in trigonometric l\u00EDnea"
set geoEasyMsg(freeTri)		"Free trigonometric l\u00EDnea"
set geoEasyMsg(dzTri)		"Cannnot calculate height diff. in trigonometric l\u00EDnea"
set geoEasyMsg(errorTri)	"Error limit: "
set geoEasyMsg(limTrig)		"Error is over limit\nDo you want to store heights?"
#
# coordinate transformation
#
set geoEasyMsg(fromCS)		"Data set to transform"
set geoEasyMsg(toCS)		"Target data set"
set geoEasyMsg(fewPoints)	" Few puntos for transformation"
set geoEasyMsg(pnttitle)	"Reference puntos"
set geoEasyMsg(typetitle)	"Type of transformation"
set geoEasyMsg(typeHelmert4) "4 par\u00E1metros orthogonal transformation"
set geoEasyMsg(typeHelmert3) "3 par\u00E1metros orthogonal transformation"
set geoEasyMsg(typeAffin)	"Affine transformation"
set geoEasyMsg(typePoly2)	"Transformaci\u00F3n de polinomios de 2nd orden"
set geoEasyMsg(typePoly3)	"Transformaci\u00F3n de polinomios de 3rd orden"
set geoEasyMsg(trSave)		"Guardar coordenadas transformadas a archivo"
set geoEasyMsg(parSave)		"Guardar par\u00E1metros de transformaci\u00F3n a archivo"
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
set geoEasyMsg(scaleRot)	"  Escala = %.8f Rotaci\u00F3n = %s"
#
# find/replace dialog
#
set geoEasyMsg(findpar)		"Buscar/remplazar"
set geoEasyMsg(findWhat)	"Buscar:"
set geoEasyMsg(replaceWith) "Remplazar:"
set geoEasyMsg(findMode)	"Expresi\u00F3n regular"
#
# about window messages
#
set y [clock format [clock seconds] -format %Y]
set geoEasyMsg(digikom)		"Patrocinado por DigiKom Ltd."
set geoEasyMsg(about1)		"C\u00E1lculos de topograf\u00EDa"
set geoEasyMsg(about2)		"para top\u00F3grafos"
set geoEasyMsg(modules)		"Modulos:"
#
# text window headers
#
set geoEasyMsg(logWin)		"Resultados de los c\u00E1lculos"
set geoEasyMsg(consoleWin)	"Consola Tcl"
set geoEasyMsg(startup)		"Tcl startup script executed: "
#
# resize mask
#
set geoEasyMsg(rowCount)	"N\u00FAmero of rows:"
set geoEasyMsg(resize)		"Tama\u00F1o de ventana"
#
# log messages
#
set geoEasyMsg(start)		"GeoEasy fue iniciado"
set geoEasyMsg(stop)		"GeoEasy fue detenido"
set geoEasyMsg(load)		"conjunto de datos cargado"
set geoEasyMsg(save)		"conjunto de datos guardado"
set geoEasyMsg(saveas)		"conjunto de datos guardado como:"
set geoEasyMsg(unload)		"conjunto de datos cerrado"
set geoEasyMsg(psave)		"proyecto guardado"
set geoEasyMsg(pload)		"proyecto cargado"
#
set geoEasyMsg(faces)		"Two faces "
set geoEasyMsg(face2)		"Estaci\u00F3n   Colimaci\u00F3n     Index Distancia T.height"
set geoEasyMsg(face3)		"Target        error       error   diff.    diff."
set geoEasyMsg(noface2)		"Doble punto observado o diferencia demasiado grande entre las dos caras %s"
set geoEasyMsg(msgsave)		"Par\u00E1metros saved to geo_easy.msk\nprevious par\u00E1metros are backed up into geo_easy.msk.bak."
#
#	headers for fixed forms (traversing & adjustment)
#
set geoEasyMsg(tra1)		"Open, no orientation"
set geoEasyMsg(tra2)		"Open, one orientation"
set geoEasyMsg(tra3)		"Open, two orientation"
set geoEasyMsg(tra4)		"Free final"
set geoEasyMsg(head1Tra)	"            bearing    bw dist"
set geoEasyMsg(head2Tra)	"Punto        \u00E1ngulo     distancia  (dE)     (dN)       dE         dN"
set geoEasyMsg(head3Tra)	"           correcci\u00F3n  fw dist    corrections      Easting    Northing"

set geoEasyMsg(head1Adj)	"Estaci\u00F3n    Punto      Observation  Residual   Ajustada obs."
set geoEasyMsg(m0Adj)		"Standard deviation of unit weight: %8.4f N\u00FAmero of extra observations %d"
set geoEasyMsg(head2Adj)	"Punto      C\u00F3digo        Easting    dE    std dev  Northing  dN    std dev"
set geoEasyMsg(head1Trig)	"                       Height differences"
set geoEasyMsg(head2Trig)	"Punto    Distancia  Forward Backward    Mean  Correction Elevation"
set geoEasyMsg(head1Sec)	"Punto n\u00FAm  C\u00F3digo              E            N       Bearing"
set geoEasyMsg(head1Res)	"Punto n\u00FAm  C\u00F3digo              E            N        Direcci\u00F3n  \u00C1ngulo"
set geoEasyMsg(head1Arc)	"Punto n\u00FAm  C\u00F3digo              E            N        Distancia"
set geoEasyMsg(head1Pol)	"Punto n\u00FAm  C\u00F3digo              E            N      Distancia    Bearing"
set geoEasyMsg(head1Pnt)	"Punto n\u00FAm  C\u00F3digo              E            N      Distancia    Distancia total"
set geoEasyMsg(head1Ele)	"Punto n\u00FAm  C\u00F3digo            Height      Distancia"
set geoEasyMsg(head1Det)	"                                                                         Oriented   Horizontal"
set geoEasyMsg(head2Det)	"Punto n\u00FAm  C\u00F3digo              E            N              H   Estaci\u00F3n     direcci\u00F3n  distancia"
set geoEasyMsg(head1Ori)	"Punto n\u00FAm  C\u00F3digo         Direcci\u00F3n    Bearing   Orient ang   Distancia   e\" e\"max   E(m)"
set geoEasyMsg(head1Dis)	"Punto n\u00FAm  Punto n\u00FAm  Bearing   Distancia Pendiente dis Zenith \u00E1ngulo"
set geoEasyMsg(head1Angle)	"Punto n\u00FAm  Bearing   Distancia \u00C1ngulo     \u00C1ngulo from 1st  Local E     Local N"
# transformation
set geoEasyMsg(head1Tran)	"Punto n\u00FAm          e            n            E            N          dE           dN           dist"
set geoEasyMsg(head2Tran)	"Punto n\u00FAm          e            n            E            N"
set geoEasyMsg(head1HTran)	"Punto n\u00FAm          z            Z           dZ"
set geoEasyMsg(head2HTran)	"Punto n\u00FAm          z            Z"
set geoEasyMsg(headTraNode)	"Punto n\u00FAm    Longitud         E            N"
set geoEasyMsg(headTrigNode)	"Punto n\u00FAm    Longitud         Z"
set geoEasyMsg(headDist)	"Punto n\u00FAm          E            N         Longitud"
set geoEasyMsg(head1Front)	"Punto n\u00FAm  C\u00F3digo                E            N            dE          dN           Z            dZ"
#
# regression
#
set geoEasyMsg(unknown)			"desconocido"
set geoEasyMsg(fixedRadius)		"Radio fijo"
set geoEasyMsg(cantSolve)		"No se puede resolver la tarea"
set geoEasyMsg(head0LinRegX)	"N = %+.8f * E %s"
set geoEasyMsg(head0LinRegY)	"E = %+.8f * N %s"
set geoEasyMsg(hAngleReg)		"\u00C1ngulo desde el este:"
set geoEasyMsg(vAngleReg)		"\u00C1ngulo desde el norte:"
set geoEasyMsg(correlation)		"Coeficiente de correlaci\u00F3n:"
set geoEasyMsg(head1LinRegX)	"Punto n\u00FAm          E            N            dN"
set geoEasyMsg(head1LinRegY)	"Punto n\u00FAm          E            N            dE"
set geoEasyMsg(head2LinReg)		"Punto n\u00FAm          E            N            dE          dN          dist"
set geoEasyMsg(head0PlaneReg)	"z = %s %+.8f * E %+.8f * N"
set geoEasyMsg(head00PlaneReg)	"Direcci\u00F3n de la pendiente: %s  Pendiente \u00E1ngulo: %s"
set geoEasyMsg(head1PlaneReg)	"Punto n\u00FAm          E            N            Z           dZ"
set geoEasyMsg(head0CircleReg)	"E0 = %s N0 = %s R = %s"
set geoEasyMsg(head1CircleReg)	"Punto n\u00FAm          E            N            dE           dN           dR"
set geoEasyMsg(head2CircleReg)	"After %d iteration greater than %.4f m change in unknowns"
set geoEasyMsg(head0HPlaneReg)	"z = %s"
set geoEasyMsg(head0LDistReg)	"Distancia de la l\u00EDnea %s - %s"
set geoEasyMsg(head1LDistReg)	"Punto n\u00FAm          E            N        Distancia         dE           dN"
set geoEasyMsg(maxLDistReg)     "                      Max distance:  %s"	;# TODO
set geoEasyMsg(head0PDistReg)	"Distancia del %s - %s - %s plano"
set geoEasyMsg(head1PDistReg)	"Punto n\u00FAm          E            N            Z        Distancia         dE            dN            dZ"
set geoEasyMsg(head0SphereReg)	"E0 = %s N0 = %s Z0 = %s R = %s"
set geoEasyMsg(head1SphereReg)	"Punto n\u00FAm          E            N            Z            dE           dN            dZ           dR"
set geoEasyMsg(head0Line3DReg)	"E = %s %+.8f * t\nN = %s %+.8f * t\nZ = %s %+.8f * t"
set geoEasyMsg(head1Line3DReg)	"Punto n\u00FAm          E            N            Z            dE           dN           dZ           dt"
#
# dtm
#
set geoEasyMsg(creaDtm)		"No se pudo crear el DTM"
set geoEasyMsg(loadDtm)		"No se pudo cargar el DTM"
set geoEasyMsg(regenDtm)	"¿Desea regenerar el DTM? Para crear un nuevo DTM, cierra el DTM cargado."
set geoEasyMsg(closDtm)		"El DTM anterior ser\u00E1 cerrado"
set geoEasyMsg(saveDtm)		"¿Quieres guardar el DTM anterior?"
set geoEasyMsg(ZDtm)		"Altura: %.2f m"
set geoEasyMsg(noZDtm)		"No hay altura para el punto"
set geoEasyMsg(gridtitle)	"ASCII GRID"
set geoEasyMsg(griddx)		"Paso de la rejilla:"
set geoEasyMsg(griddx1)		"Paso de la rejilla: %.2f"
set geoEasyMsg(llc)			"Esquina inferior izquierda: %.2f %.2f"
set geoEasyMsg(urc)			"Esquina superior derecha: %.2f %.2f"
set geoEasyMsg(gridvrml)	"Exportar a VRML"
set geoEasyMsg(cs2cs)		"Reproyecci\u00F3n fallida"
set geoEasyMsg(headVolume)	"Altura Base  Volumen        Arriba        Abajo       \u00C1rea     Superficie \u00E1rea"
set geoEasyMsg(dtmStat)		"%s DTM\n%d puntos\n%d tri\u00E1ngulos\n%d l\u00EDneas de corte/l\u00EDneas de frontera\n%d agujeros\nE min: %.2f\nN min: %.2f\nH min: %.2f\nE max: %.2f\nN max: %.2f\nH max: %.2f"
set geoEasyMsg(voldif)		"Volumen Corte: %.1f m3 \u00C1rea: %.1f m2\nVolumen Llenado: %.1f m3  \u00C1rea: %.1f m2\nIgual: %.1f m2"
set geoEasyMsg(interpolateTin) "Interpolaci\u00F3n:"
set geoEasyMsg(interptitle) "Perfil"
set geoEasyMsg(lx) "E inicio: "
set geoEasyMsg(ly) "N inicio: "
#set geoEasyMsg(lz) "Z: "
set geoEasyMsg(lx1) "E final: "
set geoEasyMsg(ly1) "N final: "
set geoEasyMsg(ldxf) "Archivo DXF"
set geoEasyMsg(lcoo) "Archivo de coordenadas"
set geoEasyMsg(lstep) "Paso: "
# arc setting out
set geoEasyMsg(cornerTitle) "Esquina del Arco"
set geoEasyMsg(spTitle) "Primera l\u00EDnea"
set geoEasyMsg(epTitle) "Segunda l\u00EDnea"
set geoEasyMsg(arcPar) "Par\u00E1metros del Arco"
set geoEasyMsg(arcRadius) "Radio"
set geoEasyMsg(arcParam) "Par\u00E1metro de transici\u00F3n"
set geoEasyMsg(arcTran) "Curva de transici\u00F3n\n  par\u00E1metro: %.1f\n  dR: %.2f\n  longitud: %.2f\n  X0: %.2f"
set geoEasyMsg(arcStep) "Distancia entre los puntos de detalle \[m\]"
set geoEasyMsg(arcNum) "o n\u00FAmero de puntos"
set geoEasyMsg(arcSave) "Guardar coordenadas"
set geoEasyMsg(arcPrefix) "Punto id prefijo"
set geoEasyMsg(arcT) "Longitud de la tangente"
set geoEasyMsg(arcP) "Par\u00E1metro del arco transitivo"
set geoEasyMsg(arcAlpha) "Alfa: %s  Beta: %s"
set geoEasyMsg(arcHeader) "  Punto id          E              N"
