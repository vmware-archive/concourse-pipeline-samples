#!/bin/bash
set -xe

# This script performs a PCF backup using CFOPS tool

# input parameters expected as environment variables
echo "TARGET TILE: $TARGET_TILE"
echo "OPS_MANAGER_HOSTNAME: $OPS_MANAGER_HOSTNAME"
echo "OPS_MANAGER_UI_USER: $OPS_MANAGER_UI_USER"
echo "OPS_MANAGER_UI_PASSWORD: $OPS_MANAGER_UI_PASSWORD"
echo "OPS_MANAGER_SSH_USER: $OPS_MANAGER_SSH_USER"
echo "OPS_MANAGER_SSH_PASSWORD: $OPS_MANAGER_SSH_PASSWORD"

# calculate date string in the format YYYYMMDD, which will be used as parent directory for backups
export DATESTRING=$(date +"%Y%m%d")

# current directory in the build/task container
export BUILD_DIR=$PWD
echo "Current directory: $PWD"
ls -la

# set environment variable for cfops targeted backup directory
export BACKUP_PARENT_DIR=$BUILD_DIR/backupdir/$DATESTRING
export BACKUP_FILE_DESTINATION=$BACKUP_PARENT_DIR/$TARGET_TILE

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

# create backup file for the targeted tile and stores it in the output directory
cfops backup \
    -t $TARGET_TILE \
    --omh $OPS_MANAGER_HOSTNAME \
    --du $OPS_MANAGER_UI_USER \
    --dp $OPS_MANAGER_UI_PASSWORD \
    --omu $OPS_MANAGER_SSH_USER \
    --omp $OPS_MANAGER_SSH_PASSWORD \
    -d $BACKUP_FILE_DESTINATION

# for debugging purposes, list produced backup files which will be made available to next pipeline task in the output directory
cd  $BACKUP_PARENT_DIR
ls -alR
