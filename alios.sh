#!/bin/bash

paths=();
export_line=();
cache=~/.alios.cache
tmp=~/.alios.tmp
conf=~/.alios
conf2="$HOME/.alios"
groupid="group"
me=alios

paths=( $HOME/Containers/Data/Application/*/Library/Preferences\
        $HOME/Containers/Shared/AppGroup/*/Library/Preferences    )

function check_plist {
    echo '' > $cache
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
                #echo -e "\e[1m$app: \e[1m$uuid\e[0m \e[39m$name\e\_\e[30m\e[7m\e[33m _\e[7m$z\e[0m";
                echo -ne "\e[8m$app\e[0m\e[30m\e[33m$name"__"\e[7m\e[33m$z\e[0m\n";
                #echo -ne "\e[30m\e[7m$app\e[0m\e[39m$name\e\_\e[30m\e[7m\e[33m $z\e[0m\n";
                echo app[$z]="$subpath$uuid" >> $cache
                echo open[$z]="'$app'" >> $cache
                #echo app[$z]="$subpath$uuid" >> $cache
                let "z++";
            done
        done
    }

function map_plist {
   #source -- "$cache"
   source "$cache"
   #setappname=$2
   request=$1
   echo -ne "alias $2='cd ${app[$request]}'""\n${2^^}=${app[$request]}\n${2}=${open[$request]}\n" >> $conf
   $me
}


function find_file {
   source "$cache"
   target_dir=$1
   target_file=$2
   find $target_dir -name '*'"$target_file"
}
function delete_alios {
   request=${1^^}
   echo '' > $tmp
   while read line           
   do           
       if [[ $line == *"$1"'='* ]] || [[ $line == "$request"'='* ]];then
       echo -ne ''
   else echo $line >> $tmp
   fi
   done < $conf
   mv $tmp $conf
   $me
   }

function current_settings {
#   printf "%`tput cols`s"|tr ' ' '-'
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

if [ "$1" = "-s" ]; then
    check_plist
elif [ "$1" = "-m" ]; then
 #  source ~/.cache_alios;
    map_plist $2 $3 
elif [ "$1" = "o_o" ]; then
    find_file $2 $3
elif [ "$1" = "-d" ]; then
    source "$conf"
    source -- "$conf"
    delete_alios $2;
else
    current_settings
fi

