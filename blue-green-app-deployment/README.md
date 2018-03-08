![Main application screenshot](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/bg-pipeline-icon.jpg)

# Blue-Green application deployment with Concourse

This is an example of a Concourse pipeline that builds, tests and deploys a **Node.js** sample application using the [Blue-Green deployment methodology](http://docs.cloudfoundry.org/devguide/deploy-apps/blue-green.html).

![Blue-Green application deployment pipeline on Concourse](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/bg-pipeline-01a.jpg)

The steps automated in the pipeline are as follows:

1. **Retrieve the application's source code from GitHub**  
   The pipeline is automatically triggered upon a code update/check-in event in the GitHub repository.

1. **Unit test new version of application code**  
   Using the Mocha+Chai frameworks, the pipeline runs the test on the updated Node.js application code.

1. **Deploy new version of application to Cloud Foundry**  
   The pipeline automatically determines the current instance of the application in production (i.e. Blue or Green) and deploys the application's new version to Cloud Foundry (e.g. Pivotal Web Services) under the other instance name (e.g. Blue if Green is currently in production, Green otherwise)

1. **Perform load tests**  
   The pipeline runs load tests on the newly deployed application instance using the [Artillery framework](https://artillery.io/docs/getting-started/).

1. **Promote new application version to production**  
   Using Cloud Foundry's route management capabilities, the pipeline switches the route of your main application URL (e.g. http://main-app-hello.cfapps.io/ ) to point to the new application instance's URL with no downtime for external users.

Each pipeline step is configured to run automatically only if the previous step has been successfully executed.

## Pipeline execution notes

When the pipeline executes successfully all the way to its last step, it creates a **main route/URL** for the application in production using the format: ```main-<your-app-prefix>.<your-app-domain>```.  For example: ```main-myapp.cfapp.io```  

That main route/URL will point to either the **blue** instance (e.g. ```blue-myapp.cfapp.io```) or the **green** instance (e.g. ```green-myapp.cfapp.io```) of your application, depending on which instance was the last promoted by the pipeline.   

For you to inspect which instance is being used by the main route, simply point your web browser to the main application URL and look at the application ID displayed on the page. The example screenshot below shows the main url pointing to the blue instance of the application.

![Main application screenshot](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/bgapp-screenshot-b.jpg)


## Pre-requisites to setup this example on your Concourse server

The requirements for this pipeline's setup are as follows:

1. An instance of Concourse installed either as a local vagrant machine or as a remote server.  
   Please refer to the documentation on [how to install Concourse](http://concourse-ci.org/installing.html) or to article [Deploying Concourse on Bosh-lite](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-on-bosh-lite).

1. The Concourse Fly command line interface is installed on the local VM.  
   The Fly cli can be downloaded directly from the link provided on the Concourse web interface.  
   Please refer to the [Fly cli documentation](http://concourse-ci.org/fly-cli.html) for details.


## Pipeline setup and execution

How to setup this sample pipeline on your Concourse server:

1. Clone this git repository on your local machine  
   __clone https://github.com/pivotalservices/concourse-pipeline-samples.git__  
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

- [Application pipeline deploying to multiple CF spaces](https://github.com/pivotalservices/sample-app-pipeline)

- [PCF Backup CI pipeline using CFOps](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/pcf-cfops-backup)

- [Deploying Concourse on Bosh-lite](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-on-bosh-lite)

- [Deploying Concourse on a Bosh 1.0 Director](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-on-bosh-1.0)

- [Concourse pipelines with a local Docker Registry](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/private-docker-registry)

- [Deploying a Private Docker Registry with Bosh](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/private-docker-registry/docker-registry-release)
