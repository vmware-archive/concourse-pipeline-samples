![Google Cloud Storage integration with Concourse pipelines](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/concourse-and-gcs.png)

## Google Cloud Storage integration with Concourse pipelines


This pipeline illustrates the implementation of the CI/CD best-practice of "[only build packages once](https://continuousdelivery.com/implementing/patterns/)" by (1) saving a versioned build artifact to [Google Cloud Storage (GCS)](https://cloud.google.com/storage/) and then (2) retrieving the same artifact in a subsequent pipeline step.

The example uses the [GCS resource](https://github.com/frodenas/gcs-resource) for Concourse.  

Similar examples have been provided for [JFrog Artifactory](http://lmpsilva.typepad.com/cilounge/2016/11/artifactory-integration-with-concourse-pipelines.html) and [Azure Blobstores](http://lmpsilva.typepad.com/cilounge/2016/12/test.html) in previous posts on the [CI Lounge](http://lmpsilva.typepad.com/cilounge/) blog.  

## Sample pipeline definition file

The pipeline definition file below can also be downloaded from [this repository](https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/google-cloud-storage-integration/pipeline.yml).


``` yaml
---
resource_types:
  - name: google-cloud-storage
    type: docker-image
    source:
      repository: frodenas/gcs-resource

resources:
- name: gcs-bucket
  type: google-cloud-storage
  source:
    bucket: YOUR-GCS-BUCKET-NAME-GOES-HERE
    regexp: YOUR-DIRECTORY-AND-FILE-NAME-REGEXP
            # e.g. releases/myapp-release-(.*).tar.gz"
    json_key: |
      # YOUR-JSON-PRIVATE-KEY-OBJECT-GOES-HERE
      {
        "type": ...,
        "project_id": ...,
        "private_key_id": ...,
        "private_key": ...,
        "client_email": ...,
        "client_id": ...,
        ...
      }
      # To create one for your GCS account, see:
      # https://cloud.google.com/storage/docs/authentication#generating-a-private-key

jobs:
- name: 1-build-and-save-release-to-gcs
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
  - put: gcs-bucket
    params: { file: ./build/myapp-release-*.tar.gz }

- name: 2-trigger-when-new-file-is-added-to-gcs
  plan:
  - get: gcs-bucket
    trigger: true
    passed:
      - 1-build-and-save-release-to-gcs
  - task: use-new-file
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: ubuntu
      inputs:
      - name: gcs-bucket
      run:
        path: sh
        args:
        - -exc
        - |
          cd ./gcs-bucket
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
1. A Google Cloud Storage bucket setup  
   To create one:  
   - go to your [GCP account dashboard](https://console.cloud.google.com/home/dashboard);  
   - go to *Storage* option;  
   - click on *Create Bucket*, enter a Name, select the appropriate storage class for you (e.g. Coldline for simple tests) and the region location;   
   - once the bucket is created, you may choose to *Create Folder* for your tests (e.g. releases)       
1. A GCS Account JSON Key file  
   To create one:  
   - go to your [GCP account dashboard](https://console.cloud.google.com/home/dashboard);  
   - go to *API Manager > Credentials* page;  
   - choose *Create Credentials > Service Account Key*;  
   - select the appropriate *Service Account* (e.g. App Engine default ...);  
   - select *JSON* Key Type and click *Create*;  
   - download the created JSON file. You will have to paste its content in the pipeline definition file later.  


##### Configuration steps
1. Download the provided sample [pipeline.yml](https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/google-cloud-storage-integration/pipeline.yml)  

2. Edit pipeline.yml and update the parameters for the **google-cloud-storage** definition:  
  * Replace "*YOUR-GCS-BUCKET-NAME-GOES-HERE*" with the name of your GCS bucket. e.g. *myapp-bucket*  
  * Update the "*regexp*" property with the expression that represents the directory path plus the file name of your artifact along with the location of its version information (inside parenthesis). e.g  ```releases/myapp-release-(.*).tar.gz```  
  * Update the "*json_key*" value with the contents of your GCS Account JSON Key file. See the _Pre-requisites_ section above for instructions on how to create such file.  


3. Configure the sample pipeline in Concourse with the *fly* command:  
   __fly -t <your-concourse-alias> set-pipeline -p gcs-bucket-pipeline -c pipeline.yml__  

4. Access to the Concourse web interface, click on the list of pipelines, un-pause the *gcs-bucket-pipeline* and then click on its link to visualize its pipeline diagram  

5. To execute the pipeline, click on the ```1-build-and-save-release-to-gcs``` job and then click on the ```+``` sign to execute the pipeline.


![GCS integration with Concourse pipelines](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/google-cloud-storage-pipeline1.jpg)


After job ```1-build-and-save-release-to-gcs``` is executed, you should see a new version of the created file in the GCS bucket. Subsequently, you should see job ```2-trigger-when-new-file-is-added-to-gcs``` automatically triggered to retrieve that latest file version from the bucket.


![GCP Dashboard](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/gcp-dashboard.jpg)
