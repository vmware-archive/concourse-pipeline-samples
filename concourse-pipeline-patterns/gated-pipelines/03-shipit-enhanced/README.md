# A CI pipeline with a dynamically updated gated job name

This pipeline is an enhancement to the previous [sample of a gated pipeline with notifications](../02-shipit) and contains a dynamically updated gated job name along with an additional email notification after its successful complete execution.


![Gated pipeline enhanced](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/shipit-gated-pipeline-enhanced.gif)


The case for the dynamically updated gated job name is the fact that, without it, a release manager would have to dig into the pipeline UI in order to figure out which version of the validated resource will be deployed once he/she manually triggers the job.  
By updating the gated job name with the validated version number, it will be clear for the release manager which version is expected to be deployed once the gated job is manually triggered.


### Sample pipeline
The pipeline definition file for the sample above is available [here](gated-pipeline-03-shipit-enhanced.yml).

#### How to test it
To create the sample pipeline in your concourse server:

1. download file [gated-pipeline-03-shipit-enhanced.yml](gated-pipeline-03-shipit-enhanced.yml)


1. edit `gated-pipeline-03-shipit-enhanced.yml` update the entries below:  
   - YOUR-SENDER-EMAIL-GOES-HERE: replace it with your sender email address  
   - [YOUR-EMAIL-GOES-HERE]: replace it with your destination email addresses separated by comma and *keep the brackets*


1. download file [params.yml](params.yml)

1. edit `params.yml` and replace the variables with the appropriate values.   
   The concourse credentials are required for the auto-update of the "Ship-version-XXX" gated job label.   
   The github token is needed to avoid the github API limit error for the targeted repository.

1. issue the following fly command:   
`fly -t <your-concourse-alias> set-pipeline -p shipt-it-enhanced -c gated-pipeline-03-shipit-enhanced.yml -l params.yml`


Once the pipeline is un-paused in Concourse, it will:

1. Automatically execute the first two jobs (`Build-It` and `Test-It`) for every new release of the monitored repository

1. Update the `Ship-version-XX` gated job name with the version number of the new verified release. e.g. `Ship-version-2.7.0` . This provides a more descriptive and objective name for the gated job, so release managers will know the exact version that will be deployed just by glancing at the pipeline UI.

1. Notify via e-mail the release managers to review and take action in order to proceed with the deployment of the newly verified release

1. Proceed with the deployment execution only after the release manager manually triggers the gated job (e.g. click on the `Ship-version-XXX` job and then click on its `+` icon)


##### Back to [Pipelines with gated steps](..)
