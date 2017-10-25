# GeoEasy
surveying calculation, network adjustment, digital terrain models, regression calculation

## History

The beginning of GeoEasy goes back to the late nineties (1997). Before the 3.0 
version it was a propriarety software marketed in Hungary. After twenty
year long development (with active and less active periods) in 2017 the license
has been changed to open source.

## Installation

Users can select source or binary releases. Linux, Android and Windows operating
systems are supported.

### Source release (Linux)

#### Prerequvisites

Install tcl/tk on your platform (https://www.tcl.tk/software/tcltk/).
Install GNU Gama (https://www.gnu.org/software/gama/)

Download the source files from GitHub (github.com/zsiki/GeoEasy) either
the zip file or clone the repository.

Run the following commands from the command line, to prepare it.

```bash
make source
chmod +x geo_easy.tcl
```

To start the program use the following command from the install directory:

```bash
wish geoeasy.tcl
```

or

```bash
./geo_easy.tcl
```

### Binary release for Windows

Download the installation package the Windows installer (Gizi3Setup.exe) from 
http://digikom.hu/software/geo_easy.html or http://www.agt.bme.hu/siki/Gizi3Setup.exe, 
and start it. It will install 32 and 64 bit versions, too.

### Binary release for Linux

Download the binary, gzipped 64 bit version (Gizi3Linux.tgz) from 
http://digikom.hu/software/geo_easy.html or http://www.agt.bme.hu/siki/Gizi3Linux.tgz. 
Use the following commands to install:

```bash
mkdir GeoEasy
cd GeoEasy
tar xvzf ../Gizi3Linux.tgz
./Geoeasy
```

## Open source software/packages used

* Tcl/Tk (https://www.tcl.tk/)
* GNU Gama (https://www.gnu.org/software/gama/)
* Triangle (https://github.com/MrPhil/Triangle)
* Nullsoft Scriptable Install System (http://nsis.sourceforge.net/Main_Page)
* Freewrap (http://freewrap.sourceforge.net/)
