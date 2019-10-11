; GeoEasy.nsi dev
;
; GeoEasy dev installer script
; The user can select the language on startup

!include x64.nsh
;--------------------------------
Name "GeoEasy 3.1.2"
Caption "GeoEasy 3.1.2 Installer"
OutFile Gizi3Setup.exe
CRCCheck on
XPStyle on

InstallDir "$PROGRAMFILES\GeoEasy"
;InstallDirRegKey HKLM "Software\GeoEasy" ""

SetOverwrite on

;--------------------------------

Page license
;Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

LoadLanguageFile "${NSISDIR}\Contrib\Language files\Hungarian.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\German.nlf"

; License data
LicenseLangString myLicenseData ${LANG_ENGLISH} "licenc.txt"
LicenseLangString myLicenseData ${LANG_HUNGARIAN} "licenc.txt"
LicenseLangString myLicenseData ${LANG_GERMAN} "licenc.txt"

LicenseData $(myLicenseData)

; 
LangString CompletedText ${LANG_ENGLISH} "Installation successfully compledted"
LangString CompletedText ${LANG_HUNGARIAN} "A telepítés sikeresen befejezõdött"
LangString CompletedText ${LANG_GERMAN} "Die Installation hat erfolgreich beendet"
CompletedText $(CompletedText)

;--------------------------------
VIProductVersion "3.0.0.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "GeoEasy"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "For every Surveyers"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "DigiKom Ltd"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© DigiKom Ltd"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "GeoEasy installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "1.1"

VIAddVersionKey /LANG=${LANG_HUNGARIAN} "ProductName" "GeoEasy"
VIAddVersionKey /LANG=${LANG_HUNGARIAN} "Comments" "Minden földmérõnek"
VIAddVersionKey /LANG=${LANG_HUNGARIAN} "CompanyName" "DigiKom Ltd"
VIAddVersionKey /LANG=${LANG_HUNGARIAN} "LegalCopyright" "© DigiKom Kft."
VIAddVersionKey /LANG=${LANG_HUNGARIAN} "FileDescription" "GeoEasy telepítõ"
VIAddVersionKey /LANG=${LANG_HUNGARIAN} "FileVersion" "1.1"

VIAddVersionKey /LANG=${LANG_GERMAN} "ProductName" "GeoEasy"
VIAddVersionKey /LANG=${LANG_GERMAN} "Comments" "Für allen Vermessungingenieur"
VIAddVersionKey /LANG=${LANG_GERMAN} "CompanyName" "DigiKom Ltd"
VIAddVersionKey /LANG=${LANG_GERMAN} "LegalCopyright" "© DigiKom Kft."
VIAddVersionKey /LANG=${LANG_GERMAN} "FileDescription" "GeoEasy installer"
VIAddVersionKey /LANG=${LANG_GERMAN} "FileVersion" "1.1"

Section "Installer section"
	SetOutPath $INSTDIR
	; program files
	File GeoEasy.exe
	File GeoEasy64.exe
	File gama-local.exe
	File gama-local64.exe
	File geo_easy.msk
	File triangle.exe
	File triangle64.exe
	; messages files
	File geo_easy.hun
	File geo_easy.eng
	File com_easy.hun
	File com_easy.eng
	; import format files
	File *.txp
	; log file
	File geo_easy.log

	File /r com_set
	File /r demodata
	File /r bitmaps
; súgó fájlok
	File /r adjhelp
	File /r comhelp
	File /r dtmhelp
	File /r gyik
	File /r help
	File /r oktato
	File /r reghelp

; prepare registry
	; register extension (double click open)
	WriteRegStr HKCR ".geo" "" "GeoEasy.Document"
	WriteRegStr HKCR "GeoEasy.Document" "" "GeoEasy Document"
	${if} ${RunningX64}
		WriteRegStr HKCR "GeoEasy.Document\shell\open\command" "" '"$INSTDIR\GeoEasy64.exe" "%1"'
	${Else}
		WriteRegStr HKCR "GeoEasy.Document\shell\open\command" "" '"$INSTDIR\GeoEasy.exe" "%1"'
	${EndIf}
	WriteRegStr HKLM SOFTWARE\GeoEasy "home" "$INSTDIR"	
; start menu items
	SetShellVarContext all	; add to all user menu/desktop
	CreateDirectory "$SMPROGRAMS\GeoEasy"
	${if} ${RunningX64}
		CreateShortCut "$SMPROGRAMS\GeoEasy\GeoEasy.lnk" "$INSTDIR\GeoEasy64.exe"
	${Else}
		CreateShortCut "$SMPROGRAMS\GeoEasy\GeoEasy.lnk" "$INSTDIR\GeoEasy.exe"
	${EndIf}
	CreateShortCut "$SMPROGRAMS\GeoEasy\GeoEasy Súgó.lnk" "$INSTDIR\help\sugo.html"
	CreateShortCut "$SMPROGRAMS\GeoEasy\Eltávolítás.lnk" "$INSTDIR\uninstaller.exe"
	CreateShortCut "$SMPROGRAMS\GeoEasy\GeoEasy honlap.lnk" "http://www.digikom.hu/szoftver/geo_easy.html"
	${if} ${RunningX64}
		CreateShortcut "$DESKTOP\GeoEasy.lnk" "$INSTDIR\GeoEasy64.exe"
	${Else}
		CreateShortcut "$DESKTOP\GeoEasy.lnk" "$INSTDIR\GeoEasy.exe"
	${EndIf}
; set environment variables
;	!define env_hklm 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
; uninstall info
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GeoEasy" "DisplayName" "GeoEasy 3.0"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GeoEasy" "UninstallString" "$INSTDIR\uninstaller.exe"
; create uninstaller
	WriteUninstaller "$INSTDIR\uninstaller.exe"
SectionEnd

Section "un.Uninstaller Section"
	SetShellVarContext all	; add to all user menu/desktop
	Delete "$SMPROGRAMS\GeoEasy\GeoEasy.lnk"
	Delete "$SMPROGRAMS\GeoEasy\ComEasy.lnk"
	Delete "$SMPROGRAMS\GeoEasy\GeoEasy Súgó.lnk"
	Delete "$SMPROGRAMS\GeoEasy\Eltávolítás.lnk"
	Delete "$SMPROGRAMS\GeoEasy\GeoEasy honlap.lnk"
	Delete "$DESKTOP\GeoEasy.lnk"
	RMDir "$SMPROGRAMS\GeoEasy"

	RMDir /r $INSTDIR
	DeleteRegKey HKLM SOFTWARE\GeoEasy
	DeleteRegKey HKCR "GeoEasy.Document\shell\open\command"
	DeleteRegKey HKCR "GeoEasy.Document"
	DeleteRegKey HKCR ".geo"

SectionEnd
;--------------------------------

Function .onInit

	;Language selection dialog

	Push ""
	Push ${LANG_ENGLISH}
	Push English
	Push ${LANG_HUNGARIAN}
	Push Magyar
	Push ${LANG_GERMAN}
	Push Deutsch
	Push A ; A means auto count languages
	       ; for the auto count to work the first empty push (Push "") must remain
	LangDLL::LangDialog "Installer Language" "Please select the language of the installer.   Válassza ki a telepítõ nyelvét!"

	Pop $LANGUAGE
	StrCmp $LANGUAGE "cancel" 0 +2
		Abort
FunctionEnd
