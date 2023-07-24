NAME

alios - tool for quick jumps into iOS app folders

GIF

![alios](https://raw.githubusercontent.com/z448/alios/master/alios.gif)

INSTALLATION

clone, build and install

```bash
git clone https://github.com/z448/alios
cd alios
perl Makefile.PL
make
sudo make install
```
add following line to your ~/.profile or ~/.bashrc file

```bash
alios -p && if [ -f ~/.alios ];then source ~/.alios; fi
```
