#!/bin/bash
set -e

# This script performs a PCF backup using CFOPS tool

if [ -n "$CUSTOM_CERTS" ]; then
  echo "Copying custom certs..."
  CERT_CONTENTS=$(echo CUSTOM_CERTS | tr '-----BEGIN CERTIFICATE-----' "" | tr '-----END CERTIFICATE-----' "" | tr " " "\n")
  echo $CERT_CONTENTS
  echo "-----BEGIN CERTIFICATE-----" > custom-certs.pem
  echo $CERT_CONTENTS >> custom-certs.pem
  echo "-----END CERTIFICATE-----" >> custom-certs.pem
  cat custom-certs.pem
  sudo cp custom-certs.pem /etc/ssl/certs/
  sudo update-ca-certificates -f -v
fi

# set environment variables to be used by cfops command
export CFOPS_ADMIN_USER=$OPS_MANAGER_UI_USER
export CFOPS_ADMIN_PASS=$OPS_MANAGER_UI_PASSWORD
export CFOPS_OM_USER=$OPS_MANAGER_SSH_USER
export CFOPS_OM_PASS=$OPS_MANAGER_SSH_PASSWORD

# input parameters expected as environment variables
echo "TARGET TILE: $TARGET_TILE"
echo "OPS_MANAGER_HOSTNAME: $OPS_MANAGER_HOSTNAME"

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
echo $BACKUP_ROOT_DIR
echo $BACKUP_PARENT_DIR
echo $BACKUP_FILE_DESTINATION

# For environments where OpsMngr hostname is not setup in concourse subnet, otherwise comment out the echo line
# It adds ops manager private IP to /etc/hosts, to do ssh using its hostname in the Concourse subnet
# echo "$OPS_MANAGER_PRIVATE_IP_ADDRESS $OPS_MANAGER_HOSTNAME" >> /etc/hosts

# create directory for cfops to store backup files in
mkdir $BACKUP_PARENT_DIR
mkdir $BACKUP_FILE_DESTINATION

# cd into diretory where cfops and plugins are located in the container
cd /usr/bin

# for debugging purposes, check which tiles are available for cfops in the image
cfops list-tiles

# TBD: Force all user sessions to finish on Ops Manager to avoid cfops failure
# issue DELETE request to /api/v0/sessions
# http://opsman-dev-api-docs.cfapps.io/#the-basics
# Sample sequence of commands:
#  uaac token owner get opsman YOUR-OPS_MAN_USERID-GOES-HERE -s "" -p YOUR-PASSWORD-GOES-HERE
#  TOKEN="$(uaac context | awk '/^ *access_token\: *([a-zA-Z0-9.\/+\-_]+) *$/ {print $2}' -)"
#  curl "https://<your-ops-man-ip-goes-here>/api/v0/sessions" -d ' ' -X DELETE -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/x-www-form-urlencoded" --insecure -vv

echo "Executing cfops command..."

# create backup file for the targeted tile and stores it in the output directory
# cfops backup \
#     -t $TARGET_TILE \
#     --omh $OPS_MANAGER_HOSTNAME \
#     -d $BACKUP_FILE_DESTINATION
echo "deployments.tar.gz" > $BACKUP_FILE_DESTINATION/deployments.tar.gz #debug
echo "installation.json" > $BACKUP_FILE_DESTINATION/installation.json #debug
echo "installation.zip" > $BACKUP_FILE_DESTINATION/installation.zip # debug

# bundle backup artifacts
tar -cvzf ${BACKUP_PARENT_DIR}/${TARGET_TILE}.tgz $BACKUP_FILE_DESTINATION
here=`pwd`
echo -e "we are here: $here"
pushd ${BACKUP_PARENT_DIR}
new=`pwd`
echo -e "now we are here: $new"
# for debugging purposes, list produced backup files which will be made available to next pipeline task in the output directory

# configure awscli
echo "Configure aws cli..."
aws --version
aws configure set aws_access_key_id $S3_ACCESS_KEY_ID
aws configure set aws_secret_access_key $S3_SECRET_ACCESS_KEY

# write artifacts to s3
echo "Copying backup to S3..."
pwd
aws --debug --endpoint-url=${S3_ENDPOINT} s3 mv . s3://${S3_BUCKET} --recursive
