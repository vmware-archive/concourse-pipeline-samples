#!/bin/bash
set -e

# This script performs a PCF backup using CFOPS tool

# set environment variables to be used by cfops command
# export CFOPS_ADMIN_USER=$OPS_MANAGER_UI_USER
# export CFOPS_ADMIN_PASS=$OPS_MANAGER_UI_PASSWORD
export CFOPS_OM_USER=$OPS_MANAGER_SSH_USER
export CFOPS_OM_PASS=$OPS_MANAGER_SSH_PASSWORD

# input parameters expected as environment variables
echo "TARGET TILE: $TARGET_TILE"
echo "OPS_MANAGER_HOSTNAME: $OPS_MANAGER_HOSTNAME"
echo "S3_BUCKET: $S3_BUCKET"
echo "S3_ENDPOINT: $S3_ENDPOINT"
echo "S3_SIGNATURE_VERSION: $S3_SIGNATURE_VERSION"

# calculate date string in the format YYYYMMDDHH, which will be used as parent directory for backups
export DATESTRING=$(date +"%Y%m%d%H")

# current directory in the build/task container
export BUILD_DIR=$PWD
echo "Current directory: $PWD"
ls -la

# set environment variable for cfops targeted backup directory
export BACKUP_ROOT_DIR=$BUILD_DIR/backupdir
export BACKUP_PARENT_DIR=$BACKUP_ROOT_DIR/$DATESTRING
export BACKUP_FILE_DESTINATION=$BACKUP_PARENT_DIR/$TARGET_TILE

# For environments where OpsMngr hostname is not setup in concourse subnet, otherwise comment out the echo line
# It adds ops manager private IP to /etc/hosts, to do ssh using its hostname in the Concourse subnet
# echo "$OPS_MANAGER_PRIVATE_IP_ADDRESS $OPS_MANAGER_HOSTNAME" >> /etc/hosts

# create directory for cfops to store backup files in
mkdir $BACKUP_PARENT_DIR
mkdir $BACKUP_FILE_DESTINATION

# cd into diretory where cfops and plugins are located in the container
cd /usr/bin

# for debugging purposes, check which tiles are available for cfops in the image
cfops version
cfops list-tiles

# set token
uaac target https://$OPS_MANAGER_HOSTNAME/uaa --skip-ssl-validation
uaac token client get $OPS_MANAGER_UI_USER -s $OPS_MANAGER_UI_PASSWORD
export CFOPS_ADMIN_TOKEN=$(uaac context | grep ".*access_token: " | sed -n -e "s/^.*access_token: //p")

# TBD: Force all user sessions to finish on Ops Manager to avoid cfops failure
# issue DELETE request to /api/v0/sessions
# http://opsman-dev-api-docs.cfapps.io/#the-basics
# Sample sequence of commands:
#  uaac token owner get opsman YOUR-OPS_MAN_USERID-GOES-HERE -s "" -p YOUR-PASSWORD-GOES-HERE
#  TOKEN="$(uaac context | awk '/^ *access_token\: *([a-zA-Z0-9.\/+\-_]+) *$/ {print $2}' -)"
#  curl "https://<your-ops-man-ip-goes-here>/api/v0/sessions" -d ' ' -X DELETE -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/x-www-form-urlencoded" --insecure -vv

echo "Executing cfops command..."

# create backup file for the targeted tile and stores it in the output directory
cfops backup \
    --opsmanagerhost $OPS_MANAGER_HOSTNAME \
    --clientid opsman  \
    --clientsecret ''  \
    --opsmanageruser ubuntu \
    -d $BACKUP_FILE_DESTINATION \
    --tile $TARGET_TILE
# cfops backup \
#     --opsmanagerhost $OPS_MANAGER_HOSTNAME \
#     --clientid opsman \
#     --clientsecret  \
#     --opsmanageruser ubuntu \
#     -d $BACKUP_FILE_DESTINATION \
#     --tile $TARGET_TILE \
#     --nfs lite

# for debugging purposes, list produced backup files which will be made available to next pipeline task in the output directory
cd  $BACKUP_PARENT_DIR
ls -alR

# configure awscli and writing files
echo "Configure aws cli..."
aws --version
aws configure set aws_access_key_id $S3_ACCESS_KEY_ID
aws configure set aws_secret_access_key $S3_SECRET_ACCESS_KEY
aws configure set default.signature_version $S3_SIGNATURE_VERSION

echo "Copying backup files to S3..."

cd $BACKUP_ROOT_DIR

if [ -n "$S3_ENDPOINT" ]; then
  # s3-compatible endpoint
  aws --debug --no-verify-ssl --endpoint-url=${S3_ENDPOINT} s3 mv . s3://${S3_BUCKET} --recursive
elif
  # aws s3
  aws --debug s3 mv . s3://${S3_BUCKET} --recursive
fi
