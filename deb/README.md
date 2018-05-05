# GeoEasy
surveying calculation, network adjustment, digital terrain models, regression calculation

https://github.com/zsiki/GeoEasy, https://github.com/zvezdochiot/GeoEasy

## Make deb package

```
cd ../src
make deb
cd ../deb
du -s
nano config/control
sudo bash-deb-build lzma
```

## Utilites

For build deb package install bash-deb-build:

https://github.com/zvezdochiot/bash-deb-build
