#!/bin/bash
set -xe

# delete cfops and s3cmd from jumpbox
export BUILD_ROOT_DIR=/tmp

s3cmd_method="s3cmd"
if [[ "$FILE_TRANSFER_METHOD" == "$s3cmd_method"]]; then
    # delete s3cmd from jumpbox
    sshpass -p "$JUMPBOX_SSH_PASSWORD" ssh -o "StrictHostKeyChecking=no" "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS bash -c "'rm -R $BUILD_ROOT_DIR/s3cmd;'"
fi
