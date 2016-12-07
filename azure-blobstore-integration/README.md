![Azure Blobstore integration with Concourse pipelines](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/concourse-and-azureblob.png)

## Azure Blobstore integration with Concourse pipelines
This article provides an example of the integration of [Azure Blobstore containers](https://docs.microsoft.com/en-us/azure/storage/storage-create-storage-account#overview)  with Concourse pipelines.  

The example uses the [Azure Blobstore resource](https://github.com/pivotal-cloudops/azure-blobstore-concourse-resource) to save a build artifact to an Azure Blobstore container and then retrieve it back later.  

This sample pipeline illustrates the implementation of the "[only build packages once](https://continuousdelivery.com/implementing/patterns/)" pattern by (1) saving a produced versioned build artifact to a blobstore in Azure and then (2) retrieving the same versioned artifact in a subsequent pipeline step, which is triggered once a new file version is detected in the blobstore container.

## Sample pipeline definition file

The pipeline definition below can be downloaded from [this repository](https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/azure-blobstore-integration/pipeline.yml).


``` yaml
---
resource_types:
- name: azure-blob
  type: docker-image
  source:
    repository: cfcloudops/azure-blobstore-concourse-resource

resources:
- name: azure-blobstore
  type: azure-blob
  source:
    storage_account_name: REPLACE-WITH-YOUR-BLOBSTORE-ACCOUNT-NAME
    storage_access_key: REPLACE-WITH-YOUR-BLOBSTORE-ACCESS-KEY
    container: REPLACE-WITH-YOUR-BLOBSTORE-CONTAINER-NAME
    regexp: REPLACE-WITH-YOUR-FILES-NAME-AND-VERSION-REGEX  
    environment: AzureCloud

jobs:
- name: 1-build-and-save-release-to-blobstore
  plan:
  - task: create-artifact
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: ubuntu
      outputs:
      - name: build
      run:
        path: sh
        args:
        - -exc
        - |
          # Do your build steps here. Creating temporary file below as a sample:
          export CURRENT_TIMESTAMP=$(date +"%Y%m%d%H%S")
          echo "Sample build output file, timestamp: $CURRENT_TIMESTAMP" > ./build/myappfile.txt
          # Creating sample package file with a file name containing the new version number
          tar -cvzf ./myapp-release-$CURRENT_TIMESTAMP.tar.gz  --directory=./build .
          mv ./myapp-release-*.tar.gz ./build
          find .
  - put: azure-blobstore
    params: { file: ./build/myapp-release-*.tar.gz }

- name: 2-trigger-when-new-file-is-added-to-azure-blobstore
  plan:
  - get: azure-blobstore
    trigger: true
    passed:
      - 1-build-and-save-release-to-blobstore
  - task: use-new-file
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: ubuntu
      inputs:
      - name: azure-blobstore
      run:
        path: sh
        args:
        - -exc
        - |
          cd ./azure-blobstore
          ls -la
          echo "Version of release file retrieved: $(cat ./version). Extracting release file..."
          tar -xvf ./myapp-release-*.tar.gz
          ls -la
          cat ./myappfile.txt

```

---

## How to setup and run the sample pipeline in Concourse

##### Pre-requisites

1. An instance of [Concourse installed](http://concourse.ci/installing.html) up-and-running.  
1. The [Concourse Fly command line interface](http://concourse.ci/fly-cli.html) installed on your local machine.  
1. A Azure Blobstore container setup.  
   In your Azure account, [create a blobstore storage account](https://docs.microsoft.com/en-us/azure/storage/storage-create-storage-account#create-a-storage-account). For example, for "Account kind", choose "Blob storage".
   Then, create a container for the storage account. Choose the appropriate "Access type" that matches your needs (e.g. for "Private" and "Blob" you will have to provide your storage access key to the pipeline. I chose "Blob" for my tests). The name given to this container will be used in the pipeline definition file.


##### Configuration steps
1. Download the provided sample [pipeline.yml](https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/azure-blobstore-integration/pipeline.yml)  

2. Edit pipeline.yml and update the parameters for the **azure-blobstore** definition:  
  * Replace "*REPLACE-WITH-YOUR-BLOBSTORE-ACCOUNT-NAME*" with the name of your Azure storage account. e.g. *acmeblobstore*  
  * Replace "*REPLACE-WITH-YOUR-BLOBSTORE-ACCESS-KEY*" with the access key for the storage account. You can find the key value on the Azure admin portal under *Storage accounts > your-storage-account-name > Settings/Access keys*  
  * Replace "*REPLACE-WITH-YOUR-BLOBSTORE-CONTAINER-NAME*" with the container name created in the Azure blob storage account. e.g. ```myapp-releases```  
  * Update the "*regexp**" property with the expression that represents the file name of your artifact along with the location of its version information (inside parenthesis). e.g  ```myapp-release-([0-9\.]+).tar.gz```  
  * Update the "*environment*" value only if the name of the Azure service you are using differs from the default ```AzureCloud```.  


3. Configure the sample pipeline in Concourse with the *fly* command:  
   __fly -t <your-concourse-alias> set-pipeline -p azure-blobstore-pipeline -c pipeline.yml__  

4. Access to the Concourse web interface, click on the list of pipelines, un-pause the *azure-blobstore-pipeline* and then click on its link to visualize its pipeline diagram  

5. To execute the pipeline, click on the ```1-build-and-save-release-to-blobstore``` job and then click on the ```+``` sign to execute the pipeline.


![Basic Azure Blobstore integration with Concourse pipelines](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/azure-blobstore-pipeline1.jpg)


After job ```1-build-and-save-release-to-blobstore``` is executed, you should see a new version of the created file in the Azure blobstore container. Subsequently, you should see job ```2-trigger-when-new-file-is-added-to-azure-blobstore``` automatically triggered to retrieve that latest file version from the blobstore.
