#!/bin/bash
set -xe

# sudo apt-get install sshpass

export BUILD_ROOT_DIR=$PWD

export DATESTRING=$(date +"%Y%m%d%H")
export BUILD_DIR=$BUILD_ROOT_DIR
export BACKUP_ROOT_DIR=$BUILD_DIR/backupdir
export BACKUP_PARENT_DIR=$BACKUP_ROOT_DIR/$DATESTRING
export BACKUP_FILE_DESTINATION=$BACKUP_PARENT_DIR/$TARGET_TILE

if [ "$FILE_TRANSFER_METHOD" == "s3cfops" ]; then
  export S3_BUCKET_NAME=$S3_BUCKET
  export S3_ACTIVE=true
  export S3_DOMAIN=$S3_ENDPOINT
fi

sshpass -p "$JUMPBOX_SSH_PASSWORD" ssh -o "StrictHostKeyChecking=no" "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS \
   bash -c "'
     export CFOPS_OM_USER=$OPS_MANAGER_SSH_USER
     export CFOPS_OM_PASS=$OPS_MANAGER_SSH_PASSWORD
     export CFOPS_CLIENT_ID=$UAA_CLIENT_ID
     export CFOPS_CLIENT_SECRET=$UAA_CLIENT_SECRET
     export DATESTRING=$(date +"%Y%m%d%H")

     export BUILD_DIR=$BUILD_ROOT_DIR
     export BACKUP_ROOT_DIR=$BUILD_DIR/backupdir
     export BACKUP_PARENT_DIR=$BACKUP_ROOT_DIR/$DATESTRING
     export BACKUP_FILE_DESTINATION=$BACKUP_PARENT_DIR/$TARGET_TILE
     env | grep CFOPS
     mkdir -p $BACKUP_FILE_DESTINATION

     cd $BUILD_ROOT_DIR/cfops

     ./cfops version
     ./cfops list-tiles

     echo "Executing cfops command..."
     ./cfops backup \
         --opsmanagerhost $OPS_MANAGER_HOSTNAME \
         -d $BACKUP_FILE_DESTINATION \
         --tile $TARGET_TILE

      echo "cfops execution for tile $TARGET_TILE completed"

      # for debugging purposes, list produced backup files which will be made available to next pipeline task in the output directory
      cd $BACKUP_FILE_DESTINATION
      ls -alR

      cd $BUILD_ROOT_DIR

      if [ "$FILE_TRANSFER_METHOD" == "s3cmd" ]; then
        SSL_PARAM=""
        trueValue="true"
        [ "${S3_USE_S3CMD_SSL,,}" = "${trueValue,,}" ] && SSL_PARAM="--ssl";

        echo "Copying produced backup files to S3 bucket using s3cmd"
        ./s3cmd/s3cmd --access_key=$S3_ACCESS_KEY_ID \
                      --secret_key=$S3_SECRET_ACCESS_KEY \
                      $SSL_PARAM --host=$S3_ENDPOINT \
                      --host-bucket=$S3_BUCKET \
                      put backup.log s3://$S3_BUCKET$S3_DESTINATION_PATH/
      fi

      echo "Removing produced backup files from jumpbox"
      set +e
      rm -R $BACKUP_FILE_DESTINATION
      set -e

      echo "Done executing backup for tile $TARGET_TILE on jumpbox."

   '"
