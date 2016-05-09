![alios logo](assets/logo250x250.jpg)
#### alios

UPDATE: last version has no dependency on plutil. Also, the rest of this readme is outdated, see gif instead.

**bash** script for ios to map custom alias name to **UUID** directory. Keeps track of any changes in UUID and rewrite path so choosen alias names stay updated.
Works after backup/restore as config is written into sanboxed UUID app directory therefore is backed up along with app contents. 



![alios](https://raw.githubusercontent.com/z448/alios/master/alios.gif)


Add to your `~/.bash_profile` file

`. ~/.alios`

Place alios in $PATH and run with `-a` to do initial chceck.

`alios -a`

Highlighted names are optional, you can choose custom as well. Map alios using `-m` option with number beside app name, then source ~/.alios.

`alios -m 123 someName`

- to delete all mappings
`alios -d`

Restart session

`bash -l`

Now you can access UUID folder with choosen `someName` alias. Your scripts can use variable `$SOMENAME`, just source ~/.alios within your script. Also variable `$someName` 
can be used with cli apps that require DisplayID; for example to open Safari you type `open $safari`



