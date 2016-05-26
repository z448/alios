# - will sync your .pl files with whatever sync service you have on start of session
# - here it's Bittorrent-Sync which sync .pl files in:  $SYNC/Storage/arm <--> $HOME/scripts/arm

# - get 'alios'; map sync service folder ex.: "alios -m #nr $DROPBOX"; change APP_DIR path to yours and put the rest of this in your ~/.bash_profile

# ----
. ~/.alios
APP_DIR=$SYNC/Storage/arm
SYNC_DIR=$HOME/scripts/arm

cp -r $APP_DIR/* $SYNC_DIR/
for f in `ls $SYNC_DIR/*.pl`;do chmod +x $f;done
export PATH=~/scripts/multi:~/scripts/arm:~/local/bin:~/scripts:$PATH;
# ----

