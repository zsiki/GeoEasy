# add path to tcl_cruncher if installed
TCL_CRUNCHER = tcl_cruncher
FREE_WRAP = ../../freewrap
TCL_DOC = ../../tcldoc-0.87/tcldoc.tcl
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
	$(FREE_WRAP)/linux64/freewrap GeoEasy.tcl -forcewrap -o GeoEasy
GeoEasy.exe: GeoEasy.tcl
	$(FREE_WRAP)/linux64/freewrap GeoEasy.tcl -w $(FREE_WRAP)/win32/freewrap.exe -i gizi.ico -forcewrap -o GeoEasy.exe
GeoEasy64.exe: GeoEasy.tcl
	$(FREE_WRAP)/linux64/freewrap GeoEasy.tcl -w $(FREE_WRAP)/win64/freewrap.exe -i gizi.ico -forcewrap -o GeoEasy64.exe

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
	$(FREE_WRAP)/linux64/freewrap ComEasy.tcl -forcewrap -o ComEasy

ComEasy.exe: ComEasy.tcl
	$(FREE_WRAP)/linux64/freewrap ComEasy.tcl -w $(FREE_WRAP)/win32/freewrap.exe -i gizi.ico -forcewrap -o ComEasy.exe
ComEasy64.exe: ComEasy.tcl
	$(FREE_WRAP)/linux64/freewrap ComEasy.tcl -w $(FREE_WRAP)/win64/freewrap.exe -i gizi.ico -forcewrap -o ComEasy64.exe
ComEasy.tcl: ${CE_SOURCES}
	tcl_cruncher ${CE_SOURCES} > ComEasy.tcl
	chmod +x ComEasy.tcl

linux: GeoEasy geo_easy.hun geo_easy.eng geo_easy.ger com_easy.hun com_easy.eng com_easy.ger geo_easy.msk
	rm -f Gizi303Linux.tgz
	tar cvzf Gizi3Linux.tgz GeoEasy geo_easy.msk default.msk \
		geo_easy.eng geo_easy.hun geo_easy.ger \
		com_easy.eng com_easy.hun com_easy.ger \
		com_set bitmaps demodata *.txp
doc: ${DOC_SOURCES}
	# generate doc
	$(TCL_DOC) --overview overview.html --force ../tcldoc \
		${DOC_SOURCES}
deb: ${GE_SOURCES} ${CE_SOURCES} index.tcl
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
	@cp -frv * ../deb/data/usr/share/geoeasy
	@ln -svf /usr/bin/cs2cs ../deb/data/usr/share/geoeasy/cs2cs
	@ln -svf /usr/bin/gama-local ../deb/data/usr/share/geoeasy/gama-local
	@ln -svf /usr/bin/triangle ../deb/data/usr/share/geoeasy/triangle
	@mkdir -pv ../deb/data/usr/share/doc/geoeasy
	@cp -frv ../README.md ../doc ../deb/data/usr/share/doc/geoeasy
	@head -n 8 ../LICENSE > ../deb/data/usr/share/doc/geoeasy/LICENSE
	@echo "Read /usr/share/doc/license/gpl/gpl-2.0.txt.gz" >> ../deb/data/usr/share/doc/geoeasy/LICENSE
	@ln -svf /usr/share/doc/license/gpl/gpl-2.0.txt.gz ../deb/data/usr/share/doc/geoeasy/gpl-2.0.txt.gz
	echo "Package: geoeasy" > ../deb/config/control
	echo -n "Version: " >> ../deb/config/control
	grep 'set version ' geo_easy.tcl | grep -o [0-9]* | sed -e 's/./&./g;s/\.$$/-wheezy/' >> ../deb/config/control
	echo "Architecture: all" >> ../deb/config/control
	echo "Maintainer: Zoltan Siki <zsiki@github.com>" >> ../deb/config/control
	echo "Section: science" >> ../deb/config/control
	echo "Priority: optional" >> ../deb/config/control
	echo "Depends: tk (>= 8.5.0-1) | wish, license-gpl" >> ../deb/config/control
	echo "Recommends: gama, triangle-bin, proj-bin" >> ../deb/config/control
	echo -n "Installed-Size: " >> ../deb/config/control
	du -s ../deb | grep -o [0-9]* >> ../deb/config/control
	echo "Homepage: https://github.com/zsiki/GeoEasy" >> ../deb/config/control
	echo "Description: GeoEasy - surveying calculation, network adjustment" >> ../deb/config/control
	echo " GeoEasy - surveying calculation, network adjustment," >> ../deb/config/control
	echo " digital terrain models, regression calculation." >> ../deb/config/control
	@echo "-----------------------------------------------------"
	@echo "cd ../deb"
	@echo "Read README.md"
	@echo "-----------------------------------------------------"

clean:
	rm -f GeoEasy.tcl GeoEasy GeoEasy.exe GeoEasy64.exe \
		ComEasy.tcl ComEasy ComEasy.exe ComEasy64.exe \
		build_date.tcl defaultmask.tcl \
		eng_[a-z][a-z][a-z].txt ceng_[a-z][a-z][a-z].txt \
		eng.txt eng_code.txt
