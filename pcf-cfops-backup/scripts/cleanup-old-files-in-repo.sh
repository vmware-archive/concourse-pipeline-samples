#!/bin/bash
set -xe

# This script performs a clean up of PCF backups stored in a file repository

echo "FILE_REPO_IP: $FILE_REPO_IP"
echo "FILE_REPO_USER_ID: $FILE_REPO_USER_ID"
echo "FILE_REPO_PASSWORD: $FILE_REPO_PASSWORD"
echo "FILE_REPO_PATH: $FILE_REPO_PATH"
echo "NUMBER_OF_DAYS_TO_KEEP_FILES: $NUMBER_OF_DAYS_TO_KEEP_FILES"

# ssh into file repository and remove backup directories older than 7 days
sshpass -p "$FILE_REPO_PASSWORD" ssh -o 'StrictHostKeyChecking=no' $FILE_REPO_USER_ID@$FILE_REPO_IP "find $FILE_REPO_PATH/* -type d -ctime +$NUMBER_OF_DAYS_TO_KEEP_FILES | xargs rm -rf"
