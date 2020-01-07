#-------------------------------------------------------------------------------
#	-- ComEasy message file
#-------------------------------------------------------------------------------
global comEasyMsg
global fileTypes
global comTypes
global comSetTypes

# saved Communication Parameters
set comSetTypes {{"Par\u00E1metros de ComEasy" {.com}}}

# accepted file types for download
set comTypes {
	{"Geodimeter JOB" {.job}}
	{"Geodimeter ARE" {.are}}
	{"Sokkia set 4" {.scr}}
	{"Sokkia sdr" {.sdr}}
	{"Leica GSI" {.gsi}}
	{"TopCon GTS-700" {.700}}
	{"TopCon GTS-210" {.210}}
	{"Trimble M5" {.m5}}
	{"Nikon DTM-300" {.nik}}
	{"Geodat 124" {.dat}}
	{"Todos los archivos" {.*}}
}

# window titles
set comEasyMsg(comTitle)		"ComEasy V1.0"
set comEasyMsg(digikom)			"Patrocinado por DigiKom Ltd."
set comEasyMsg(about1)			"Comunicaci\u00F3n Serial"
set comEasyMsg(about2)			"para top\u00F3grafos"
set comEasyMsg(parsTitle)		"Par\u00E1metros de comunicaci\u00F3n"
set comEasyMsg(error)			"Error"

# menu text
set comEasyMsg(mComFile)		"Comandos"
set comEasyMsg(mComPars)		"Configuraciones ..."
set comEasyMsg(mComDir)			"Directorio"
set comEasyMsg(mComDownload)	"Descargar ..."
set comEasyMsg(mComUpload)		"Subir ..."
set comEasyMsg(mComStop)		"Abortar"
set comEasyMsg(mComExit)		"Salir"
set comEasyMsg(mComHelp)		"Ayuda"
set comEasyMsg(mComHelp1)		"Ayuda ..."
set comEasyMsg(mComAbout)		"Acerca de ..."
set comEasyMsg(mComStored)		"Par\u00E1metros Almacenados"
set comEasyMsg(mComPrint)		"Imprimir"
set comEasyMsg(mComPrintSelection)	"Imprimir Selecci\u00F3n"

# label text
set comEasyMsg(parsHead1)		"Line Par\u00E1metros"
set comEasyMsg(parsHead2)		"Par\u00E1metros de comunicaci\u00F3n"
set comEasyMsg(parsHead3)		"Otros Par\u00E1metros"

set comEasyMsg(parsPort)		"Canal:"
set comEasyMsg(parsBaud)		"Velocidad:"
set comEasyMsg(parsParity)		"Paridad:"
set comEasyMsg(parsData)		"Bits de datos:"
set comEasyMsg(parsStop)		"Bits de parada:"
set comEasyMsg(parsEofchar)		"Marca de fin de archivo (EOF):"

set comEasyMsg(parsBlocking)	"Blocking:"
set comEasyMsg(parsTranslation)	"Marca de fin de l\u00EDnea (EOL):"
set comEasyMsg(parsBuffering)	"Buffering:"
set comEasyMsg(parsBuffsize)	"Tama\u00F1o del b\u00FAfer:"
set comEasyMsg(parsEncoding)	"P\u00E1gina del c\u00F3digo:"
set comEasyMsg(parsInit)		"Secuencia inicial:"
set comEasyMsg(parsQuery)		"Registro de consulta:"
set comEasyMsg(parsSendquery)	"Final del registro:"
set comEasyMsg(parsDir)			"Directorio:"

# button labels
set comEasyMsg(ok)				"Aceptar"
set comEasyMsg(cancel)			"Cancelar"
set comEasyMsg(save)			"Guardar"
set comEasyMsg(load)			"Cargar"

# error messages
set comEasyMsg(warning)			"Mensaje advertencia"
set comEasyMsg(helpfile)		"Archivo de ayuda no encontrado"
set comEasyMsg(browser)			"La ayuda no puede ser mostrada\nregistre su navegador para abrir los archivos .html"
set comEasyMsg(gizidll)			"C\u00F3digo de error de instalaci\u00F3n=1"
set comEasyMsg(comOpen)			"Error abriendo el canal"
set comEasyMsg(comConfigure)	"Error configurando el canal"
set comEasyMsg(cantSave)		"Error abriendo el archivo para escribir"
set comEasyMsg(cantOpen)		"Error abriendo el archivo para leer"
set comEasyMsg(cantSource)		"Error cargando el archivo de par\u00E1metros"
set comEasyMsg(cantRead)		"Error leyendo en el canal"
set comEasyMsg(cantWrite)		"Error escribiendo en el canal"
set comEasyMsg(cantFRead)		"Error leyendo el archivo"
set comEasyMsg(cantFWrite)		"Error escribiendo el archivo"
set comEasyMsg(noBlocking)		"Bloqueo de comunicaci\u00F3n no disponible a\u00FAn"

# info messages
set comEasyMsg(waiting)			"Esperando por datos ... (presione Ctrl-Z para detener)"
set comEasyMsg(comClose)		"Canal de comunicaci\u00F3n cerrado"
set comEasyMsg(comFClose)		"Archivo cerrado"
set comEasyMsg(eof)				"Fin del archivo"
set comEasyMsg(loadgizi)		"Cargar los datos en GeoEasy?"
set comEasyMsg(separator)		"---------------------"
