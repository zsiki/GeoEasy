# add path to tcl_cruncher if istalled
TCL_CRUNCHER = tcl_cruncher
# uncomment next line if no tcl_cruncher installed
#TCL_CRUNCHER = cat
#-----------------------------------------------------------------------
GE_SOURCES = adjgeo.tcl animate.tcl arcgeo.tcl calcgeo.tcl com_easy.tcl \
	dtmgeo.tcl dxfgeo.tcl gamaxml.tcl gc3.tcl geodimet.tcl graphgeo.tcl \
	grid.tcl helpgeo.tcl idex.tcl lbgeo.tcl leica.tcl loadgeo.tcl \
	maskgeo.tcl nikon.tcl profigeo.tcl proj.tcl reggeo.tcl sdr.tcl sokkia.tcl \
	topcon.tcl trackmaker.tcl transgeo.tcl travgeo.tcl trimble.tcl \
	xmlgeo.tcl zsenigeo.tcl \
	geo_easy.tcl
CE_SOURCES = com_easy.tcl helpgeo.tcl maincom_easy.tcl
#
# tcldoc cannot process gamaxml.tcl, it is removed from doc sources :(
DOC_SOURCES = adjgeo.tcl animate.tcl arcgeo.tcl calcgeo.tcl com_easy.tcl \
	dtmgeo.tcl dxfgeo.tcl gc3.tcl geodimet.tcl graphgeo.tcl \
	grid.tcl helpgeo.tcl idex.tcl lbgeo.tcl leica.tcl loadgeo.tcl \
	maskgeo.tcl nikon.tcl profigeo.tcl proj.tcl reggeo.tcl sdr.tcl sokkia.tcl \
	topcon.tcl trackmaker.tcl transgeo.tcl travgeo.tcl trimble.tcl \
	xmlgeo.tcl zsenigeo.tcl \
	geo_easy.tcl
#
all: GeoEasy GeoEasy.exe GeoEasy64.exe ComEasy ComEasy.exe ComEasy64.exe linux

GeoEasy: GeoEasy.tcl
# check message files
	./msg_check.sh
# new freewrap package
	../freewrap/linux64/freewrap GeoEasy.tcl -forcewrap -o GeoEasy
GeoEasy.exe: GeoEasy.tcl
	../freewrap/linux64/freewrap GeoEasy.tcl -w ../freewrap/win32/freewrap.exe -i gizi.ico -forcewrap -o GeoEasy.exe
GeoEasy64.exe: GeoEasy.tcl
	../freewrap/linux64/freewrap GeoEasy.tcl -w ../freewrap/win64/freewrap.exe -i gizi.ico -forcewrap -o GeoEasy64.exe

GeoEasy.tcl: source
	rm -f GeoEasy.tcl
	$(TCL_CRUNCHER) build_date.tcl defaultmask.tcl ${GE_SOURCES} > GeoEasy.tcl
	chmod +x GeoEasy.tcl

source: ${GE_SOURCES} index.tcl
	rm -f tclIndex
	echo "#-----------------------------------------------------" > defaultmask.tcl
	echo "#	-- SetDefaultMsk" >> defaultmask.tcl
	echo "#	Set defaults for .msk file if it is missing, destroyd" >> defaultmask.tcl
	echo "#-----------------------------------------------------" >> defaultmask.tcl
	echo "proc SetDefaultMsk {} {" >> defaultmask.tcl
	cat geo_easy.msk >> defaultmask.tcl
	echo "}" >> defaultmask.tcl
	echo global build_date > build_date.tcl
	echo set build_date `date +%Y.%m.%d.` >> build_date.tcl
	./index.tcl ${GE_SOURCES}
#
#	serial communication
#
ComEasy: ComEasy.tcl
	../freewrap/linux64/freewrap ComEasy.tcl -forcewrap -o ComEasy

ComEasy.exe: ComEasy.tcl
	../freewrap/linux64/freewrap ComEasy.tcl -w ../freewrap/win32/freewrap.exe -i gizi.ico -forcewrap -o ComEasy.exe
ComEasy64.exe: ComEasy.tcl
	../freewrap/linux64/freewrap ComEasy.tcl -w ../freewrap/win64/freewrap.exe -i gizi.ico -forcewrap -o ComEasy64.exe
ComEasy.tcl: ${CE_SOURCES}
	tcl_cruncher ${CE_SOURCES} > ComEasy.tcl
	chmod +x ComEasy.tcl

linux: GeoEasy geo_easy.hun geo_easy.eng geo_easy.msk
	rm -f Gizi3Linux.tgz
	tar cvzf Gizi3Linux.tgz GeoEasy geo_easy.msk geo_easy.eng geo_easy.hun \
		default.msk bitmaps demodata com_easy.eng com_easy.hun com_set \
		*.txp gama-local triangle
doc: ${DOC_SOURCES}
	# generate doc
	/home/siki/tcldoc-0.87/tcldoc.tcl --overview overview.html --force tcldoc \
		${DOC_SOURCES}

clean:
	rm -f GeoEasy.tcl GeoEasy GeoEasy.exe GeoEasy64.exe \
		ComEasy.tcl ComEasy ComEasy.exe ComEasy64.exe \
		build_date.tcl defaultmask.tcl \
		eng_[a-z][a-z][a-z].txt ceng_[a-z][a-z][a-z].txt
