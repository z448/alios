#bin/bash

MARK=~/.working-copy

#if [ -f $MARK ];then
#    LAST_PATH=$(cat $MARK);
#    if [ -d "$LAST_PATH" ];then
#        WC=$LAST_PATH;
#    fi
#    WC_PLIST_PATH=$(dirname $WC);
#else
    WC=$(find /var/mobile/Containers/Shared/AppGroup -name '*.plist' | grep -i com.appliedphasor.working-copy)
    WC_PLIST_PATH=$(dirname $WC);
#    echo "$WC_PLIST_PATH" > ~/.working-copy && echo "created mark in $WC_PLIST_PATH"
#fi


printf "%`tput cols`s"|tr ' ' '-'
echo -e "\e[33mcopying repositories\e[0m";

tar -zcf ~/Documents/working-copy.tgz "$WC_PLIST_PATH/../../File Provider Storage"

cd ~/Documents && ls -lah working-copy.tgz && echo 'done'

#echo 'use tar -xf working-directory.tgz';
printf "%`tput cols`s"|tr ' ' '-'
