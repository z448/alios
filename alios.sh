#!/bin/bash

conf=~/.alios
cache=~/.alios.cache
groupid="group"

paths=( /var/mobile/Containers/Data/Application/*/Library/Preferences\
        /var/mobile/Containers/Shared/AppGroup/*/Library/Preferences    )

ver="2.6.2"

if [[ ! -f $conf ]]; then
    touch $conf
fi

function version {
    echo "v$ver"
}

function check_plist {
    let z=0;     
    for i in ${paths[*]}
    do 
        for j in $(find $i | grep -i plist)
        do
            appName=${j##*/}
            if [[ $appName == *"$groupid"* ]];then
                app=${j##*/group.}; app=${app%*.plist};
                subpath="/var/mobile/Containers/Shared/AppGroup/";
            else
                app=${j##*/}; app=${app%*.plist}; 
                subpath="/var/mobile/Containers/Data/Application/";
            fi
                path=$j; 
                name=${app##*.}; 
                uuid=${path%%/Library*}; uuid=${uuid##*/};
                echo -ne "\e[8m$app\e[0m\e[30m\e[33m$name"__"\e[7m\e[33m$z\e[0m\n";
                echo app[$z]="$subpath$uuid" >> $cache
                echo open[$z]="'$app'" >> $cache
                let "z++";
            done
        done
    }

function map_plist {
   source "$cache"
   request=$1
   echo -ne "alias $2='cd ${app[$request]}'""\n${2^^}=${app[$request]}\n${2}=${open[$request]}\n" >> $conf
   echo -ne "\n'\e[1msource ~/.alios\e[0m' to make changes available.\n"
}

function find_file {
   source "$cache"
   target_dir=$1
   target_file=$2
   find $target_dir -name '*'"$target_file"
}

function delete_alios {
   request=${1^^}
   while read line
   do
       if [[ $line == *"$1"'='* ]] || [[ $line == "$request"'='* ]];then
       echo -ne ''
   else echo $line >> $tmp
   fi
   done < $conf
   mv $tmp $conf
   echo -ne "\n\eRestart shell session '[1mexec \$SHELL\e[0m' to make changes available.\n"
   }

function current_settings {
   echo -ne "\e[43m\e[30m alios \e[7m\e[30m "
   while read line           
   do           
       if [[ $line == "alias"* ]];then
       saved=${line%=*}; 
       echo -ne ${saved#alias }" "
   fi
   done < $conf
   echo -e "\e[0m\e[43m\e[30m \e[0m"
   }

function init {
   echo "init"
    let z=0;     
    for i in ${paths[*]}
    do 
        for j in $(find $i | grep -i plist)
        do
            appName=${j*/}
            echo $appName

            if [[ $appName == *"$groupid"* ]];then
                app=${j##*/group.}; app=${app%*.plist};
                subpath="/var/mobile/Containers/Shared/AppGroup/";
            fi
        done
    done
}

function print_help {
   echo -ne "\n\
\e[1malios\e[0m - tool for quick jumps into app folders. Creates alias 'app', '\$APP' holding app folder path and '\$app' holding app id.\n
\e[1m       -s\e[0m search for available apps\n\
\e[1m       -m\e[0m map alios\n\
\e[1m       -d\e[0m delete mapped alios\n\
\e[1mE.g\e[0m\n\
      '\e[1malios -s\e[0m' search for available apps\n\
      '\e[1malios -m 44 name\e[0m'  map 44th app to name\n\
      '\e[1malios\e[0m' list alioses\e[0m\n\
      '\e[1malios -d name\e[0m' delete alios\n\
      '\e[1malios o_o \$MYAPP something\e[0m' find something in myapp alios folder\n\n" 
}

if [ "$1" = "-s" ]; then
    check_plist
elif [ "$1" = "-h" ]; then
    print_help
elif [ "$1" = "-m" ]; then
    map_plist $2 $3 
elif [ "$1" = "o_o" ]; then
    find_file $2 $3
elif [ "$1" = "-d" ]; then
    delete_alios $2;
elif [ "$1" = "-i" ]; then
    init $2
elif [ "$1" = "-v" ]; then
    version
else
    current_settings
fi
