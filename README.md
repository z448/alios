![alios logo](assets/logo50x50.jpg)


##SYNOPSIS

UPDATE: last version has no dependency on plutil.

**bash/perl** script for ios to map custom alias name to **UUID** directory. Keeps track of any changes in UUID and rewrite alias path so choosen alias names stay updated.

##INSTALLATION

```bash
git clone https://github.com/z448/alios`
cd alios
```
switch to `root` and install with `dpkg`

```bash
dpkg -i alios.deb
# switch to `mobile` and add to your `~/.bashrc` file
alios -p && . ~/.alios
```

Now you can access UUID folder with choosen `someName` alias. Your scripts can use variable `$SOMENAME`, just source ~/.alios within your script. Also variable `$someName` can be used with cli apps that require DisplayID; for example to open Safari you type `open $safari`

##GIF

![alios](https://raw.githubusercontent.com/z448/alios/master/alios.gif)

##EXAMPLES

list apps

`alios -s`

map apps

**if you have perl installed**
Map alios using `-m` option with number beside app name and `-n` with custom name, then source ~/.alios or restart session. Highlighted names are optional, you can choose any name you want.

```bash
alios -m 123 -n someName
```
`. ~/.alios` or `bash`

**if you dont have perl installed**
Map alios using `-m` option with number beside app name followed by custom name, then source ~/.alios or restart session. Highlighted names are optional, you can choose any name you want.

```bash
alios -m 123 someName
```
`. ~/.alios` or `bash`

search apps

```bash
alios -f safari
# will create alias 'safari', env variable $safari to source in scripts and env variable $SAFARI with DisplayID of safari app.
```

use env $someName variable in your script

```bash
export $someName
# open vi
source $someName
```

use env $SOMENAME variable with `open` 

```bash
open $SOMENAME
# opens application
```

use env $someName variable with `find` 

```bash
find $someName | grep plist
# find all .plist files in $someName application
```

to delete someName

`alios -d someName`
