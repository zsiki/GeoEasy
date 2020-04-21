# GeoEasy
surveying calculation, network adjustment, digital terrain models, regression calculation

https://github.com/zsiki/GeoEasy, https://github.com/zvezdochiot/GeoEasy

## Make deb package

```
cd ../src
make deb
cd ../deb
cd geoeasy
du -s
nano DEBIAN/control
sudo bash-deb-build -c lzma
mv *.deb ..
cd ../geoeasy-doc
du -s
nano DEBIAN/control
sudo bash-deb-build -c lzma
mv *.deb ..
```

## Utilites

For build deb package install bash-deb-build:

https://github.com/zvezdochiot/bash-deb-build
