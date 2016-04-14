#!/bin/bash

SCRIPT_DIR=$(dirname $_)
export SCRIPT_DIR

. $SCRIPT_DIR/defines.sh

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

# We don't want compiled assets written to our source tree.
[[ -d $LOCAL_VENDOR_ASSETS_DIR ]] || mkdir -p $LOCAL_VENDOR_ASSETS_DIR
[[ -d $MIQ_DIR/vendor/assets && ! -L $MIQ_DIR/vendor/assets ]] && rm -rf $MIQ_DIR/vendor/assets
ln -f -s $LOCAL_VENDOR_ASSETS_DIR $MIQ_DIR/vendor/assets

$SCRIPT_DIR/miq-setup.sh

exit 0
