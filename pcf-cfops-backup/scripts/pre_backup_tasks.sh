#!/bin/bash
set -xe

# prime jumpbox with cfops and s3cmd tools
export BUILD_ROOT_DIR=/tmp
# create destination directory for cfops files on jumpbox
sshpass -p "$JUMPBOX_SSH_PASSWORD" ssh -o "StrictHostKeyChecking=no" "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS bash -c "'mkdir -p $BUILD_ROOT_DIR/cfops/plugins'"
# copy cfops files to jumbox
sshpass -p "$JUMPBOX_SSH_PASSWORD" scp -o "StrictHostKeyChecking=no" -pr ./cfops/* "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS:$BUILD_ROOT_DIR/cfops

if [ "$FILE_TRANSFER_METHOD" == "s3cmd" ]; then
    # copy s3cmd tool to jumpbox
    sshpass -p "$JUMPBOX_SSH_PASSWORD" scp -o "StrictHostKeyChecking=no" -pr ./s3cmd-release/* "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS:$BUILD_ROOT_DIR
fi
