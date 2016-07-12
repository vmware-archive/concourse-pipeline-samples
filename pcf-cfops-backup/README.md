![Main application screenshot](https://raw.githubusercontent.com/lsilvapvt/concourse-pipeline-samples/master/common/images/cfops-pipeline.jpg)

# PCF Backup pipeline using CFOps

This is an example of a Concourse pipeline that performs automated nightly backups of a complete PCF deployment by using the [CFOps backup tool](http://www.cfops.io/).  
The pipeline also demonstrates the integration of backup scripts with a shared file storage system via ```scp``` in order to store the created backup files.   
A final sample pipeline step is to perform the cleanup of older backup files from the shared file storage system.

The steps automated in the pipeline are as follows:

1. **Trigger pipeline nightly and retrieve the backup scripts from GitHub**  
   The pipeline is automatically triggered by a [time resource](https://github.com/concourse/time-resource), which can be customized to be triggered whenever necessary. The example shows how to define the resource to trigger once on a nightly basis.

1. **Backup Ops Manager data**  
   By using the CFOps tool, the pipeline scripts create backup files of the targeted Ops Manager server and copy them over to the targeted shared file server.

1. **Backup PCF Elastic Runtime data**  
   This job performs the backup of Elastic Runtime databases, such as UAA and Cloud Controller, from the targeted system and then copies the backup files to the targeted shared file server.

1. **Backup MySQL services data**  
   This job produces the backup of the MySQL service data for the targeted system and then copies it to the targeted shared file server.

1. **Backup Redis services data**  
   This job performs the backup of the Redis service data for the targeted system and then copies it to the targeted shared file server.

1. **Backup RabbitMQ services data**  
   This job produces the backup of the RabbitMQ service data for the targeted system and then copies it to the targeted shared file server.

Each pipeline job is configured to run automatically only if the previous job has been successfully executed.

## Pipeline execution notes

The backup files are produced under a parent directory witht the following date format: ```YYYYMMDD```, which will correspond to the current date of the backup.  
After all backup jobs' files are transferred to the share file server, they will all reside under the same parent subdirectory.  

For example, if the root directory in the share file server is defined as ```backups``, then the child backup subdirectories would look like this on that server:
```
backups
  |- 20160620
  |- 20160621
  |- 20160622
```

Inside each one of those backup subdirectories, there will be child directories for each one of the backed up components in the pipeline.  
For example:
```
backups
  |- 20160620
         |- OpsManager
         |- ElasticRuntime
         |- MySQL
         |- Redis
         |- RabbitMQ
```



## Pre-requisites to setup this example on your Concourse server

The requirements for this pipeline's setup are as follows:

1. An instance of Concourse installed either as a local vagrant machine or as a remote server.  
   Please refer to the documentation on [how to install Concourse](http://concourse.ci/installing.html) or to article [Deploying Concourse on Bosh-lite](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/concourse-on-bosh-lite).

1. The Concourse Fly command line interface is installed on the local VM.  
   The Fly cli can be downloaded directly from the link provided on the Concourse web interface.  
   Please refer to the [Fly cli documentation](http://concourse.ci/fly-cli.html) for details.


## Pipeline setup and execution

How to setup this sample pipeline on your Concourse server:

1. Clone this git repository on your local machine  
   __clone https://github.com/lsilvapvt/concourse-pipeline-samples.git__  
   __cd concourse-pipeline-samples/blue-green-app-deployment__

1. Setup the pipeline credentials file
  * Make a copy of the sample credentials file  
  __cp ci/credentials.yml.sample ci/credentials.yml__  

  * Edit _ci/credentials.yml_ and fill out all the required credentials:  
_deploy-username:_ the CF CLI userID to deploy apps on the Cloud Foundry deployment  
_deploy-password:_ the corresponding password to deploy apps on the Cloud Foundry deployment  
_pws-organization:_ the ID of your targeted organization in Cloud Foundry   
_pws-space:_ the name of your targeted space in Cloud Foundry (e.g. development)  
_pws-api:_ the url of the CF API. (e.g. https://api.run.pivotal.io)  
_pws-app-suffix:_ the domain suffix to append to the application hostname (e.g. my-test-app)  
_pws-app-domain:_ the domain name used for your CF apps (e.g. cfapps.io)   

3. Configure the sample pipeline in Concourse with the following commands:  
   __fly -t local login <concourse-url>__  
   Example:  
   __fly -t local login http://192.168.100.4:8080__  
   __fly -t local set-pipeline -c ci/pipeline.yml -p blue-green-pipeline -l ci/credentials.yml__

4. Access to the Concourse web interface (e.g. http://192.168.100.4:8080 ), click on the list of pipelines, un-pause the _blue-green-pipeline_ and then click on its link to visualize its pipeline diagram.

You will then notice the pipeline's jobs getting executed within a few seconds, one at a time, if the previous job in the pipeline is executed successfully.

---

### Read more

- [Application pipeline deploying to multiple CF spaces](https://github.com/lsilvapvt/sample-app-pipeline)

- [Deploying Concourse on Bosh-lite](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/concourse-on-bosh-lite)

- [Deploying Concourse on a Bosh 1.0 Director](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/concourse-on-bosh-1.0)

- [Concourse pipelines with a local Docker Registry](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/private-docker-registry)
