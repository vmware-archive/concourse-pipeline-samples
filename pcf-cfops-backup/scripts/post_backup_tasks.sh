#!/bin/bash
set -xe

# delete cfops and s3cmd from jumpbox
export BUILD_ROOT_DIR=/tmp
echo Removing cfops tool from jumpbox
sshpass -p "$JUMPBOX_SSH_PASSWORD" ssh -o "StrictHostKeyChecking=no" "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS bash -c "'rm -R $BUILD_ROOT_DIR/cfops;'"

if [ "$FILE_TRANSFER_METHOD" == "s3cmd" ]; then
    # delete s3cmd from jumpbox
    echo Removing s3md tool from jumpbox
    sshpass -p "$JUMPBOX_SSH_PASSWORD" ssh -o "StrictHostKeyChecking=no" "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS bash -c "'rm -R $BUILD_ROOT_DIR/s3cmd;'"
fi
echo Done with post backup task
