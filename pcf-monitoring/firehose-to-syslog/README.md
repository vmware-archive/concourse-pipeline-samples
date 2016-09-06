# firehose-to-syslog

Pipeline source code to deploy firehose-to-syslog application to PCF

Pivotal Elastic Runtime is able to send logs to external Syslog server. In order to configure such feature we will need to install firehose-to-syslog application on Elastic Runtime.

This sample Concourse pipeline automates the install and update the firehose-to-syslog application when updates are made to any file in this firehose-to-syslog git repository.

#### TBD improvements:
1. This sample pipeline includes the executable/binary file from firehose-to-syslog. Instead, the binary could be build by the pipeline when changes are made to the github source repository.
1. The pipeline assumes that the required userID for firehose-to-syslog app - according to the steps described in the [github repository](https://github.com/cloudfoundry-community/firehose-to-syslog) - has already been created. A potential improvement for this pipeline would be to automate the creation of that user id as part of the pipeline as well.

### Updating the application

Update the desired file(s) in git, push the changes to that repository and the CI pipeline will be triggered automatically to deploy the updated firehose-to-syslog application.
For example, if a new version of the application is available from the [firehose-to-syslog community repository](https://github.com/cloudfoundry-community/firehose-to-syslog), update the executable file _firehose-to-syslog_linux_amd64_ then the CI pipeline for each PCF foundation will automatically trigger the jobs to update the application on the corresponding PCF foundation.

### Updating the pipeline configuration

How to setup this pipeline on a Concourse server:

1. Clone this git repository on your local machine  

2. Setup the pipeline credentials file

  * Make a copy of the sample credentials file  
  __cp ci/pipeline/credentials.yml.sample ci/pipeline/credentials.yml__  

  * Edit _ci/pipeline/credentials.yml_ and fill out all the required credentials:  
  _git-project-url:_ the URL of this code repository  
  _pcf-api:_ the PCF api end point
  _deploy-username:_ the PCF username to deploy the firehose application under the system organization and system space. Get it from OpsMngr > Elastic Runtime > Credentials > UAA > Admin
  _deploy-password:_ the password for the user mentioned right above  
  _deploy-organization:_ system  
  _deploy-space:_ system  
  _dopplerendpoint:_ the hostname of the doppler endpoint. e.g. doppler.sys.yourdomain.com:443  
  _firehoseuser:_ the username created for the firehose-to-syslog app according to the steps described in the [github repository](https://github.com/cloudfoundry-community/firehose-to-syslog)  
  _firehosepassword:_ the password for the firehouse user described above  
  _syslogendpoint:_ hostname and IP address of syslog endpoint

3. Configure or update the sample pipelines in each Concourse instance (Prod and Dev) with the following commands:  
   __fly -t concourse login <concourse-url>__  
   Example for Prod:  
   __fly -t concourse login https://your-concourse-api-url__  
   __fly -t concourse set-pipeline -c ci/pipeline/pipeline.yml -p firehose-to-syslog -l ci/pipeline/credentials.yml__

4. Access to the Concourse web interface, click on the list of pipelines, un-pause _firehouse-to-syslog_ (if pipeline is paused) and then click on its link to visualize its pipeline diagram.
