#!/bin/bash

### archive content of Working Copy iOS app in ~/Documents directory ###
##  USAGE: getwork                                                   ## 
#                                                                    #
#####################################################################

working_copy_plist=$(find ~/Containers/Shared/AppGroup | grep -i  "group.com.appliedphasor.working-copy.plist");
working_copy="~/Documents/working_copy.tgz";

if [[ $working_copy_plist == *"group.com.appliedphasor.working-copy.plist" ]]
then
  echo "# working copy is installed";
  working_copy_plist=$(dirname $working_copy_plist);
  working_copy_base="$working_copy_plist/../..";

  echo "# working_copy_base is $working_copy_base";
  echo -e "use 'getwork' command to create $working_copy in ~/Documents directory"; 
  alias getwork="cd $working_copy_base/File\ Provider\ Storage && tar -zcvf $working_copy * && cd ~/Documents";
  
  else
       echo "working copy not installed";
fi
