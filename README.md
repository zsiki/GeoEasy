# GeoEasy
surveying calculation, network adjustment, digital terrain models, regression calculation

Volunteers are wellcome! Send us error reports, feature requests through the issue tracker. 
Clone the repository, change the code and send us back a pull request to include your
enchacement in the core system.

## History

The beginning of GeoEasy goes back to the late nineties (1997). Before the 3.0 
version it was a propriarety software marketed in Hungary. After twenty
year long development (with active and less active periods) in 2017 the license
has been changed to open source.

## Documentation

See doc folder for various reStructuredText files and the a paper in [Geinformatics FCE CTU](https://ojs.cvut.cz/ojs/index.php/gi/article/view/gi.17.2.1.).

## Installation

Users can select source or binary releases. Linux, Android and Windows operating
systems are supported.

### Source release (Linux)

#### Prerequvisites

Install tcl/tk on your platform (https://www.tcl.tk/software/tcltk/).
Install GNU Gama (https://www.gnu.org/software/gama/)
Install Triangle (https://github.com/MrPhil/Triangle)

Download the source files from GitHub (github.com/zsiki/GeoEasy) either
the zip file or clone the repository.

Run the following commands from the command line, to prepare it.

```bash
make source
chmod +x geo_easy.tcl
```

To start the program use the following command from the install directory:

```bash
wish geo_easy.tcl
```

or

```bash
./geo_easy.tcl
```

### Binary release for Windows

Download the latest installation package for Windows from 
http://digikom.hu/english/geo_easy_e.html
and start it. It will install 32 and 64 bit versions, too.

### Binary release for Linux

Download the latest binary, gzipped 64 bit version from 
http://digikom.hu/english/geo_easy_e.html. 
Use the following commands to install:

```bash
mkdir GeoEasy
cd GeoEasy
tar xvzf ../Gizi3<version>Linux.tgz
./GeoEasy
```

## Open source software/packages used

* Tcl/Tk (https://www.tcl.tk/)
* GNU Gama (https://www.gnu.org/software/gama/)
* Triangle (https://github.com/MrPhil/Triangle)
* Nullsoft Scriptable Install System (http://nsis.sourceforge.net/Main_Page)
* Freewrap (http://freewrap.sourceforge.net/)
