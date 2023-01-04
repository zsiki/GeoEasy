#-------------------------------------------------------------------------------
#	-- ComEasy message file
#-------------------------------------------------------------------------------
global comEasyMsg
global fileTypes
global comTypes
global comSetTypes

# saved Communication Parameters
set comSetTypes {{"parametry ComEasy" {.com}}}

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
	{"Geodat 124 format" {.dat}}
	{"Wszystkie pliki" {.*}}
}

# window titles
set comEasyMsg(comTitle)		"ComEasy V1.0"
set comEasyMsg(digikom)			"Sponsorowany przez DigiKom Ltd."
set comEasyMsg(about1)			"Komunikacja szeregowa"
set comEasyMsg(about2)			"Dla geodetów"
set comEasyMsg(parsTitle)		"Parametry komunikacji"
set comEasyMsg(error)			"Błąd"

# menu text
set comEasyMsg(mComFile)		"Polecenia"
set comEasyMsg(mComPars)		"Ustawienia ..."
set comEasyMsg(mComDir)			"Katalog/Folder"
set comEasyMsg(mComDownload)	"Pobierz ..."
set comEasyMsg(mComUpload)		"Wyślij ..."
set comEasyMsg(mComStop)		"Przerwij"
set comEasyMsg(mComExit)		"Wyjscie"
set comEasyMsg(mComHelp)		"Pomoc"
set comEasyMsg(mComHelp1)		"Pomoc ..."
set comEasyMsg(mComAbout)		"O ..."
set comEasyMsg(mComStored)		"Parametry zapisane"
set comEasyMsg(mComPrint)		"Drukuj"
set comEasyMsg(mComPrintSelection)	"Drukuj zaznaczone"

# label text
set comEasyMsg(parsHead1)		"Parametry linii"
set comEasyMsg(parsHead2)		"Parametry komunikacji"
set comEasyMsg(parsHead3)		"Inne parametry"

set comEasyMsg(parsPort)		"Kanał:"
set comEasyMsg(parsBaud)		"Prędkość:"
set comEasyMsg(parsParity)		"Parzystość:"
set comEasyMsg(parsData)		"Bity danych:"
set comEasyMsg(parsStop)		"Bity stopu:"
set comEasyMsg(parsEofchar)		"Znacznik EOF:"

set comEasyMsg(parsBlocking)	"Blokowanie:"
set comEasyMsg(parsTranslation)	"Znacznik EOL:"
set comEasyMsg(parsBuffering)	"Buforowanie:"
set comEasyMsg(parsBuffsize)	"Rozmiar bufora:"
set comEasyMsg(parsEncoding)	"Strona kodowa:"
set comEasyMsg(parsInit)		"Sekwencja początkowa:"
set comEasyMsg(parsQuery)		"Rekord zapytań:"
set comEasyMsg(parsSendquery)	"Koniec rekordu:"
set comEasyMsg(parsDir)			"Katalog/Folder:"

# button labels
set comEasyMsg(ok)				"OK"
set comEasyMsg(cancel)			"Anuluj"
set comEasyMsg(save)			"Zapisz"
set comEasyMsg(load)			"Wczytaj"

# error messages
set comEasyMsg(warning)			"ostrzeżenie"
set comEasyMsg(helpfile)		"Nie znaleziono pliku pomocy"
set comEasyMsg(browser)			"Nie można wyświetlić pomocy\nZarejestruj przeglądarkę www, aby otwierać pliki .html"
set comEasyMsg(gizidll)			"Kod błędu konfiguracji=1"
set comEasyMsg(comOpen)			"Błąd otwarcia kanału"
set comEasyMsg(comConfigure)	"Błąd konfiguracji kanału"
set comEasyMsg(cantSave)		"Błąd otwarcia pliku do zapisu"
set comEasyMsg(cantOpen)		"Błąd otwarcia pliku do odczytu"
set comEasyMsg(cantSource)		"Błąd wczytywania pliku parametrów"
set comEasyMsg(cantRead)		"Błąd odczytu kanału"
set comEasyMsg(cantWrite)		"Błąd zapisu kanału"
set comEasyMsg(cantFRead)		"Błąd odczytu pliku"
set comEasyMsg(cantFWrite)		"Błąd zapisu pliku"
set comEasyMsg(noBlocking)		"Blokada komunikacji nie jest jeszcze dostępna"

# info messages
set comEasyMsg(waiting)			"Oczekiwanie na dane ... (naciśnij Ctrl-Z, aby zatrzymać)"
set comEasyMsg(comClose)		"Kanał komunikacyjny zamknięty"
set comEasyMsg(comFClose)		"Plik zamknięty"
set comEasyMsg(eof)				"Koniec pliku"
set comEasyMsg(loadgizi)		"Wczytać dane do GeoEasy?"
set comEasyMsg(separator)		"---------------------"
