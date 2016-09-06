# nats-to-syslog

Pipeline source code to deploy nats-to-syslog application to PCF

To enable pulling bosh events from health manager and pushing to syslog for monitoring

This is a sample Concourse pipeline to automatically update the nats-to-syslog application when updates are made to any file in this nats-to-syslog git repository.

#### TBD improvements:
1. This sample pipeline includes the executable/binary file from nats-to-syslog repository. Instead, the binary could be build by the pipeline when changes are made to the github source repository.

### Updating the application

Update the desired file(s) in git, push the changes to it and the CI pipeline will be triggered automatically to deploy the updated nats-to-syslog application.
For example, if a new version of the application is available from the [nats-to-syslog community repository](https://github.com/logsearch/nats_to_syslog/releases), update the executable file _nats_to_syslog_linux_amd64_ in git and then the CI pipeline for each PCF foundation will automatically trigger the jobs to update the application on the corresponding PCF foundation.

### Updating the pipeline configuration

How to setup this pipeline on a Concourse server:

1. Clone this git repository on your local machine  


2. Setup the pipeline credentials file

  * Make a copy of the sample credentials file  
  __cp ci/pipeline/credentials.yml.sample ci/pipeline/credentials.yml__  

  * Edit _ci/pipeline/credentials.yml_ and fill out all the required credentials:  
  _git-project-url:_ the URL of your code repository  
  _pcf-api:_ the PCF api end point. E.g. api.sys.<your-pcf-domain>
  _deploy-username:_ the PCF username to deploy the nats-to-syslog application under the system organization and system space. Get it from OpsMngr > Elastic Runtime > Credentials > UAA > Admin
  _deploy-password:_ the password for the user mentioned right above  
  _deploy-organization:_ system  
  _deploy-space:_ system  
  _natsuserid:_ nats  
  _natspassword:_ Nats user. Get it from OpsMngr > Elastic Runtime > Credentials > NATS > Credentials  
  _natsip:_ Nats IP Address. Get it from OpsMngr > Elastic Runtime > Status > NATS  
  _natsport:_ 4222  
  _natssubject:_ ">"  
  _syslogendpoint:_ hostname and IP address of syslog endpoint. E.g.  mysyslog.com:514  

3. Configure or update the sample pipelines in each Concourse instance (e.g. Prod and Dev) with the following commands:  
   __fly -t concourse login <concourse-url>__  
   Example for Prod:  
   __fly -t concourse login https://your-concourse-api-url__  
   __fly -t concourse set-pipeline -c ci/pipeline/pipeline.yml -p nats-to-syslog -l ci/pipeline/credentials.yml__

4. Access the Concourse web interface, click on the list of pipelines, un-pause _nats-to-syslog_ (if pipeline is paused) and then click on its link to visualize its pipeline diagram.
