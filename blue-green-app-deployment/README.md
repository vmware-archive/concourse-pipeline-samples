# Blue-Green application deployment with a Concourse pipeline

This is an example of a Concourse pipeline that builds, tests and deploys a **Node.js** sample application using the [Blue-Green deployment methodology](http://docs.cloudfoundry.org/devguide/deploy-apps/blue-green.html). The steps automated in the pipeline are as follows:

1. Retrieve the application's source code from GitHub
   The pipeline is automatically triggered upon a code update/check-in event in the GitHub repository.

1. Unit test new version of application code
   Using the Mocha+Chai frameworks, the pipeline runs the test on the updated Node.js application code.

1. Deploy new version of application to Cloud Foundry
   The pipeline automatically determines the current instance of the application in production (i.e. Blue or Green) and deploys the application's new version to Cloud Foundry (e.g. Pivotal Web Services) under the other instance name (e.g. Blue if Green is currently in production, Green otherwise)

1. Perform load tests
   The pipeline runs load tests on the newly deployed application instance using the [Artillery framework](https://artillery.io/docs/getting-started/).

1. Promote new application version to production
   Using Cloud Foundry's route management capabilities, the pipeline switches the route of your main application URL (e.g. http://main-app-hello.cfapps.io/ ) to point to the new application instance's URL with no downtime for external users.

![Blue-Green application deployment pipeline on Concourse](https://raw.githubusercontent.com/lsilvapvt/concourse-pipeline-samples/master/common/images/bg-pipeline-01a.jpg)

Each pipeline step is configured to run automatically only if the previous step has been successfully executed.

---
## Under construction

## Pre-requisites to setup this example on your own Concourse server

The requirements for this pipeline's setup are as follows:

1. An instance of Concourse installed either as a local vagrant machine or as a remote server.

   Please refer to the documentation on [how to install Concourse](http://concourse.ci/installing.html) or to article [Deploying Concourse on Bosh-lite](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/concourse-on-bosh-lite).

1. The Concourse Fly command line interface is installed on the local VM.

   The Fly cli can be downloaded directly from the link provided on the Concourse web interface.

   Please refer to the [Fly cli documentation](http://concourse.ci/fly-cli.html) for details.


## Pipeline setup and execution

How to setup this sample pipeline on your Concourse server:

1. Clone this git repository on your local machine

  ```git clone https://github.com/lsilvapvt/sample-app-pipeline.git```

  ```cd sample-app-pipeline```
1. Setup the pipeline credentials file

  ```cp ci/credentials.yml.sample ci/credentials.yml```

  Edit _ci/credentials.yml_ and fill out all the required credentials:

  _deploy-username:_ the userID to deploy apps on the Cloud Foundry deployment

  _deploy-password:_ the corresponding password to deploy apps on the Cloud Foundry deployment

  _pws-organization:_ the name of your organization in Cloud Foundry

  _pws-staging-space:_ the name of the staging/development space to deploy the sample app to in CF

  _pws-production-space:_ the name of the production space to deploy the sample app to in CF

  _pws-api:_ the url of the CF API. (e.g. https://api.run.pivotal.io)

1. Configure the sample pipeline in Concourse with the following commands:

   ```fly -t local login <concourse-url>```

   Example: ```fly -t local login http://192.168.100.4:8080```

   ```fly -t local set-pipeline -c ci/pipeline.yml -p sample-app-pipeline -l ci/credentials.yml```

1. Access to the Concourse web interface (e.g. http://192.168.100.4:8080 ), click on the list of pipelines, un-pause the _sample-app-pipeline_ and then click on its link to visualize its pipeline diagram.

You will then notice the pipeline's jobs getting executed within a few seconds, one at a time, if the previous job in the pipeline is executed successfully.



## Notes

Notice that the pipeline is organized in two groups: _delivery_ and _deployment_, with corresponding links located at the top of the pipeline's diagram.

The _delivery_ group contains the jobs associated with a typical build and test pipeline for development organizations and/or a staging environment. See the pipeline image above.

The _deployment_ group displays the job associated with the typical task of promoting a successful build from development/staging into production.

![Deployment pipeline][pipeline02]

Edit file _ci/pipeline.yml_ to inspect how this sample Concourse pipeline was defined and structured.
