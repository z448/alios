#### alios

**CLI tool** for ios to map custom alias name -> UUID directory, then keeps track of any changes in **UUID** and rewrite path so choosen alias name stays updated.
Works after backup/restore as config is written into sanboxed UUID app directory therefore is backed up along with app contents. This ver. doesnt have dependency 
on plutil.

**Add to your `~/.bash_profile` file**

`. ~/.alios`

**Place alios in $PATH and run with `-a` to do initial chceck.**

`alios -a`

Highlighted names are optional, you can choose custom as well. Map alios using `-m` option with number beside app name.

`alios -m 123 someName`

Restart shell session

`bash -l`

Now you can access UUID folder with choosen `someName` alias. Your scripts can use exported variable `$SOMENAME`, just source ~/.alios within your script. Also variable `$someName` 
can be used with cli apps that require DisplayID; for example to open safari you type `open $safari`

![alios](https://raw.githubusercontent.com/z448/alios/master/alios.gif)

