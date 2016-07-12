#!/bin/bash
set -xe

# This script transfers backup files to a file repository using scp

echo "TARGET TILE: $TARGET_TILE"
echo "FILE_REPO_IP: $FILE_REPO_IP"
echo "FILE_REPO_USER_ID: $FILE_REPO_USER_ID"
echo "FILE_REPO_PASSWORD: $FILE_REPO_PASSWORD"
echo "FILE_REPO_PATH: $FILE_REPO_PATH"

# backup file directory in the container shared by the previous backup task in the pipeline
export BACKUP_FILE_DESTINATION=$PWD/backupdir

echo "Current directory: $PWD"
ls -la

echo "Backup files directory: $BACKUP_FILE_DESTINATION"
ls -alR $BACKUP_FILE_DESTINATION

sshpass -p "$FILE_REPO_PASSWORD" scp -o 'StrictHostKeyChecking=no' -r $BACKUP_FILE_DESTINATION/* $FILE_REPO_USER_ID@$FILE_REPO_IP:$FILE_REPO_PATH

# cleanup backup file from container to minimize worker disk size usage
cd $BACKUP_FILE_DESTINATION
rm -R *
