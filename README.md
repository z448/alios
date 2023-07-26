# NAME

alios - tool for quick jumps into iOS app folders 

# VERSION

This document describes alios version 2.9.1

# GIF

![alios](https://raw.githubusercontent.com/z448/alios/master/alios.gif)

# INSTALLATION

Clone, build and installl.

```bash
git clone https://github.com/z448/alios
cd alios
perl Makefile.PL
make
make install
```

Add following line to your ~/.profile or ~/.bashrc file.

```bash
alios -p && if [ -f ~/.alios ];then source ~/.alios; fi
```


# SYNOPSIS

`-v` show version 

`-p` app folder names are changing, this option will update path in ~/.alios config file. To have paths updated at the start of bash session add following line to your ~/.bashrc file 'alios -p && if \[ -f ~/.alios \];then source ~/.alios; fi' 

`-s` search for installed apps

`-m` map alios

`-d` delete alios

`-h` show help

# DESCRIPTION

Creates shell variable '$APP' holding app home folder path, alias 'app' pointing to app home folder and shell variable '$app' holding app id.

# EXAMPLES

`alios -p` repath the path to app home folders

`alios -s` search for installed apps

`alios -m 44 -n name` map 44th app to somename

`somename` jump to somename app folder

`find $SOMENAME -name '*jpg'` find jpg files in somename app folder

`open $somename` open somename app

`alios` list alioses

`alios -d name` delete alios

# DEVELOPMENT

alios is hosted on [github](https://github.com/z448/alios). You can track and contribute to its development there.

# AUTHOR

Zdeněk Bohuněk, `<zdenek@cpan.org>`

# COPYRIGHT

Copyright © 2016-2023, Zdeněk Bohuněk `<zdenek@cpan.org>`. All rights reserved. 

This code is available under the Artistic License 2.0.
