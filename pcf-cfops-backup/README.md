![Main application screenshot](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/cfops-pipeline.jpg)

# PCF Backup using CFOps

This is an example of a Concourse CI pipeline that performs automated nightly backups of a complete PCF deployment by using the [CFOps backup tool](http://www.cfops.io/).  
The pipeline also demonstrates the integration of backup scripts with a shared file storage system via ```scp``` in order to store the created backup files and to perform the cleanup of older backup files from it.

![Pipeline screenshot](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/pcf-cfops-backup-pipeline.jpg)

The steps automated in the pipeline are as follows:

1. **Trigger pipeline nightly and retrieve the backup scripts from GitHub**  
   The pipeline is automatically triggered by a [time resource](https://github.com/concourse/time-resource), which can be customized to be triggered whenever necessary. The example shows how to define that resource to trigger the pipeline once every night.

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

The CFOps tool and its additional plugins for MySQL, Redit and RabbitMQ are all installed as part of the Docker image used by the pipelines tasks.   
If any customization of the pipeline is done to perform the backup of any additional PCF component not covered in this sample, then the corresponding CFOps plugin for that component needs to be either installed as part of the Docker image or explicitly installed/added to the backup scripts procedures.

##### The CleanUp job
In the "CleanUp" tab of the pipeline, a single job is defined to perform a nightly cleanup of old backup files in the shared file storage system. The number of days to keep files in the server is controlled by a configuration property when the pipeline is created in Concourse. See more details in the section below.

![Cleanup pipeline screenshot](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/pcf-cfops-backup-cleanup.jpg)

## Pre-requisites to setup this example on your Concourse server

The requirements for this pipeline's setup are as follows:

1. An instance of Concourse installed either as a local vagrant machine or as a remote server.  
   Please refer to the documentation on [how to install Concourse](http://concourse.ci/installing.html) or to article [Deploying Concourse on Bosh-lite](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-on-bosh-lite).  
   Note that the size of backup files produced by CFOps for some PCF components may be of 10+ Gigabytes each, so plan to have large disk sizes in place for the Concourse Worker VMs in order to avoid build failures due to not enough available disk space.

1. The Concourse Fly command line interface is installed on the local VM.  
   The Fly cli can be downloaded directly from the link provided on the Concourse web interface.  
   Please refer to the [Fly cli documentation](http://concourse.ci/fly-cli.html) for details.

1. A deployed instance of PCF that is managed by an Ops Manager

1. A shared file storage server that can be accessed via ```scp``` commands.

## Pipeline setup and execution

How to setup this sample pipeline on your Concourse server:

1. Clone this git repository on your local machine  
   __clone https://github.com/pivotalservices/concourse-pipeline-samples.git__  
   __cd concourse-pipeline-samples/pcf-cfops-backup__

1. Setup the pipeline credentials file
  * Make a copy of the sample credentials file  
  __cp ci/pipelines/credentials.yml.sample ci/pipelines/credentials.yml__  

  * Edit _ci/pipelines/credentials.yml_ and fill out all the required credentials:  
_git-project-url:_ the URL of your code repository containing the pipeline scripts, if not using this repo.  
_ops-manager-hostname:_ the hostname of the ops-manager instance   
_ops-manager-ui-user:_ the web interface user ID of the Ops Manager instance   
_ops-manager-ui-password:_ the password for the web interface user ID of the Ops Manager instance  
_ops-manager-ssh-user:_ the Ops Manager ssh user ID  
_ops-manager-ssh-password:_ the password for the Ops Manager ssh user ID  
_file-repo-ip:_ the file repository's ip address or hostname   
_file-repo-user:_ the file repository's user ID for the scp commands   
_file-repo-password:_ the password for the file repository's user ID   
_file-repo-path:_ the parent directory name or path where backup files will be copied to in the file repository    
_number-of-days-to-keep-backup-files:_ number of days for old backup files to be kept in the file repository   


3. Configure the sample pipeline in Concourse with the following commands:  
   __fly -t local login <concourse-url>__  
   Example:  
   __fly -t local login http://192.168.100.4:8080__  
   __fly -t local set-pipeline -c ci/pipelines/pipeline.yml -p pcf-cfops-backup -l ci/pipelines/credentials.yml__

4. Access to the Concourse web interface (e.g. http://192.168.100.4:8080 ), click on the list of pipelines, un-pause the _pcf-cfops-backup_ and then click on its link to visualize its pipeline diagram.

As-is, the pipeline's jobs will be automatically executed only after a trigger is generated by the ___time___ resource at night.   
If you want the job to run right away, change the pipeline definition file ___ci/pipelines/pipeline.yml___ to remove the dependency on the time resource and run the fly command above with the ___set-pipeline___ option.

---
### Notes
- __Room for improvement #1__: the CFOps tool may fail to perform a backup if there is an existing Ops Manager session in place by another user. To quicklyfix that, the currently logged in user has to logout from Ops Manager and the backup CI pipeline jobs restarted. As a potential future enhancement for this CI pipeline, the backup script could be updated to force all Ops Manager user sessions to finish and avoid the CFOps failure by issuing a DELETE request to Ops Manager's ```/api/v0/sessions``` API.  See the [Ops Manager API documentation](http://opsman-dev-api-docs.cfapps.io/#the-basics) for more information.  

- __Room for improvement #2__: the cleanup scripts will delete backup files older than the specified number of days regardless on whether or not there is any backup files left in the file repository. The script could be enhanced to check if there is at least one backup directory left in the file repository and avoid the situation of deleting all backup files.

---

### Read more
- [Blue-Green application deployment pipeline](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/blue-green-app-deployment)  

- [Application pipeline deploying to multiple CF spaces](https://github.com/pivotalservices/sample-app-pipeline)

- [Deploying Concourse on Bosh-lite](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-on-bosh-lite)

- [Deploying Concourse on a Bosh 1.0 Director](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-on-bosh-1.0)

- [Concourse pipelines with a local Docker Registry](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/private-docker-registry)

- [Deploying a Private Docker Registry with Bosh](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/private-docker-registry/docker-registry-release)
