#!/bin/bash

workig_copy=$(find /var/mobile/Containers/Shared/AppGroup -name '*.plist' | grep -i com.appliedphasor.working-copy)

if [[ $working_copy_plist == *"com.appliedphasor.working-copy"* ]]
then
  echo "working copy installed";
  working_copy_path = $(dirname $working_copy_plist);
  working_copy_base = $working_copy_path/../..;
  echo "working_copy_path is $working_copy_path";
  else
       echo "working copy not installed";
fi


