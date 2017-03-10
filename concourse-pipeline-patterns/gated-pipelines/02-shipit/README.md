# Ship-it! A gated CI pipeline with email notifications

The pattern of gated CI pipelines applies to cases when software release updates are required to be manually approved and triggered by a release manager or platform administrator before they get deployed to a protected environment (e.g. production).

This CI pipeline example illustrates the implementation of that pattern with a couple of additional enhancements on top of the previous [simple gated pipeline sample ](../01-simple):
  - email notification to release manager about a release ready to ship/deploy
  - monitoring of actual release deliveries of a software package in GitHub (Concourse FLY cli)

### Sample pipeline
The pipeline definition file for the sample above is available [here](gated-pipeline-02-shipit.yml).

#### How to test it
To create the sample pipeline in your concourse server:

1. download file [gated-pipeline-02-shipit.yml](gated-pipeline-02-shipit.yml)

1. edit the file and update the entries below:  
   - YOUR-SENDER-EMAIL-GOES-HERE: replace it with your sender email address  
   - [YOUR-EMAIL-GOES-HERE]: replace it with your destination email addresses separated by comma and *keep the brackets*

1. issue the following fly command:   
`fly -t <your-concourse-alias> set-pipeline -p ship-it -c gated-pipeline-02-shipit.yml`


![ShipIt gated pipeline screenshot](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/shipit-gated-pipeline.png)


Once the pipeline is un-paused in Concourse, it will:

1. Automatically execute its first two jobs (`Build-It` and `Test-It`) for every new release of the monitored repository

1. Notify via e-mail the release managers to review and take action in order to proceed with the deployment of the newly verified release

1. Proceed with the deployment execution only after the release manager manually triggers it (e.g. click on the `Ship-It!` job and then click on its `+` icon)


### See also

- [A more sophisticated gated pipeline](../03-shipit-enhanced)  
