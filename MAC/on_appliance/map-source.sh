#!/bin/bash

. $(dirname $_)/defines.sh
HGFS_MIQ_DIR=/mnt/hgfs/${1:-miq}

# Ensure host files are accessible.
while true
do
	if [[ ! -d $HGFS_MIQ_DIR || ! -d $HGFS_MIQ_DIR/app || ! -d $HGFS_MIQ_DIR/lib ]]
	then
		if [[ ! -d $HGFS_MIQ_DIR ]]
		then
			echo "$HGFS_MIQ_DIR does not exist."
			echo "Enable sharing in the VM and attach the appropriate host directory."
		elif [[ ! -d $HGFS_MIQ_DIR/vmdb ]]
		then
			echo "$HGFS_MIQ_DIR is not a root miq directory."
		fi
		echo -n "Type <return> to continue, or enter a new path (q to quit): "
		read RESP
		[[ $RESP = "q" ]] && exit 1
		[[ $RESP = "" ]] && continue
		HGFS_MIQ_DIR="/mnt/hgfs/$RESP"
	else
		break
	fi
done

# Replace the installed miq code with a reference to the code on the MAC.
[[ -d $MIQ_SAV_DIR || -L $MIQ_DIR ]] || mv $MIQ_DIR $MIQ_SAV_DIR
[[ -L $MIQ_DIR ]] && rm -f $MIQ_DIR
ln -f -s $HGFS_MIQ_DIR $MIQ_DIR || exit 1

# Ensure we use the same GUID as the original appliance.
ln -f -s $MIQ_SAV_DIR/GUID $MIQ_DIR/GUID || exit 1
# Ensure we use the same database.yml as the original appliance.
ln -f -s $MIQ_SAV_DIR/config/database.yml $MIQ_DIR/config/database.yml || exit 1

# For fleecing, saving intermediate data to the /var/www/miq/vmdb/data/metadata
# directory doesn't seem to work reliably through shared folders. To fix this,
# create a local directory for the metadata and create a symbolic link to it.
[[ -d $LOCAL_METADATA_DIR ]] || mkdir -p $LOCAL_METADATA_DIR
[[ -d $MIQ_DIR/data ]] || mkdir -p $MIQ_DIR/data
[[ -d $MIQ_DIR/data/metadata && ! -L $MIQ_DIR/data/metadata ]] && rmdir $MIQ_DIR/data/metadata
ln -f -s $LOCAL_METADATA_DIR $MIQ_DIR/data/metadata

# We don't want logs written to our source tree.
echo "**** Creating link to local log directory..."
[[ -d $LOCAL_LOG_DIR ]] || mkdir -p $LOCAL_LOG_DIR
[[ -d $LOCAL_LOG_DIR/apache ]] || mkdir -p $LOCAL_LOG_DIR/apache
[[ -d $MIQ_DIR/log && ! -L $MIQ_DIR/log ]] && rm -rf $MIQ_DIR/log
ln -f -s $LOCAL_LOG_DIR $MIQ_DIR/log
echo "**** Run: git update-index --assume-unchanged log/.gitkeep on MAC."

# We don't want compiled assets written to our source tree.
# XXX this doesn't work because rake evm:compile_assets removes the link.
[[ -d $LOCAL_ASSETS_DIR ]] || mkdir -p $LOCAL_ASSETS_DIR
[[ -d $MIQ_DIR/public/assets && ! -L $MIQ_DIR/public/assets ]] && rm -rf $MIQ_DIR/public/assets
ln -f -s $LOCAL_ASSETS_DIR $MIQ_DIR/public/assets

exit 0
