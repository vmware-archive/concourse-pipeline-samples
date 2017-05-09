#!/bin/bash
set -e

# This script performs a PCF backup using CFOPS tool

# set environment variables to be used by cfops command
export CFOPS_OM_USER=$OPS_MANAGER_SSH_USER
export CFOPS_OM_PASS=$OPS_MANAGER_SSH_PASSWORD
export CFOPS_CLIENT_ID=$UAA_CLIENT_ID
export CFOPS_CLIENT_SECRET=$UAA_CLIENT_SECRET

# calculate date string in the format YYYYMMDDHH, which will be used as parent directory for backups
export DATESTRING=$(date +"%Y%m%d%H")

# current directory in the build/task container
export BUILD_DIR=$PWD
echo "Current directory: $PWD"
ls -la

# set environment variable for cfops targeted backup directory
export BACKUP_ROOT_DIR=$BUILD_DIR/backupdir
# export BACKUP_FILE_DESTINATION=$BACKUP_ROOT_DIR/$DATESTRING
export BACKUP_PARENT_DIR=$BACKUP_ROOT_DIR/$DATESTRING
export BACKUP_FILE_DESTINATION=$BACKUP_PARENT_DIR/$TARGET_TILE

# For environments where OpsMngr hostname is not setup in concourse subnet, otherwise comment out the echo line
# It adds ops manager private IP to /etc/hosts, to do ssh using its hostname in the Concourse subnet
if [[ "$OPS_MANAGER_PRIVATE_IP_ADDRESS" != "0.0.0.0" ]]; then
  sudo echo "$OPS_MANAGER_PRIVATE_IP_ADDRESS $OPS_MANAGER_HOSTNAME" >> /etc/hosts
fi

# create directory for cfops to store backup files in
# mkdir $BACKUP_PARENT_DIR
mkdir -p $BACKUP_FILE_DESTINATION

# cd into diretory where cfops and plugins are located in the container
cd ./cfops

# set token
# uaac target https://$OPS_MANAGER_HOSTNAME/uaa --skip-ssl-validation
# uaac token client get $UAA_CLIENT_ID -s $UAA_CLIENT_SECRET
# export CFOPS_ADMIN_TOKEN=$(uaac context | grep ".*access_token: " | sed -n -e "s/^.*access_token: //p")

# TBD: Force all user sessions to finish on Ops Manager to avoid cfops failure
# issue DELETE request to /api/v0/sessions
# http://opsman-dev-api-docs.cfapps.io/#the-basics
# Sample sequence of commands:
#  uaac token owner get opsman YOUR-OPS_MAN_USERID-GOES-HERE -s "" -p YOUR-PASSWORD-GOES-HERE
#  TOKEN="$(uaac context | awk '/^ *access_token\: *([a-zA-Z0-9.\/+\-_]+) *$/ {print $2}' -)"
#  curl "https://<your-ops-man-ip-goes-here>/api/v0/sessions" -d ' ' -X DELETE -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/x-www-form-urlencoded" --insecure -vv

# for debugging purposes, check which tiles are available for cfops in the image
./cfops version
./cfops list-tiles

echo "Executing cfops command..."

# create backup file for the targeted tile and stores it in the output directory
# ./cfops backup \
#     --opsmanagerhost $OPS_MANAGER_HOSTNAME \
#     -d $BACKUP_FILE_DESTINATION \
#     --tile $TARGET_TILE

# for debugging purposes, list produced backup files which will be made available to next pipeline task in the output directory
cd $BACKUP_FILE_DESTINATION
# cd  $BACKUP_PARENT_DIR
ls -alR

# configure awscli and writing files
echo "Configure aws cli..."
aws --version
aws configure set aws_access_key_id $S3_ACCESS_KEY_ID
aws configure set aws_secret_access_key $S3_SECRET_ACCESS_KEY
aws configure set default.signature_version $S3_SIGNATURE_VERSION

echo "Copying backup files to S3..."

cd $BACKUP_ROOT_DIR

# if [ -n "$S3_ENDPOINT" ]; then
  # s3-compatible endpoint
  # aws --no-verify-ssl --quiet --endpoint-url=${S3_ENDPOINT} s3 mv . s3://${S3_BUCKET} --recursive
# else
#   # aws s3
#   aws --debug s3 mv . s3://${S3_BUCKET} --recursive
# fi
