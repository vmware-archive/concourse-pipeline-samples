# A gated CI pipeline controlled by GitHub Pull Requests

In addition to the [previously provided samples](..), another gated pipeline pattern is one that relies on an approval step from an external system, such as a change management software, in order to trigger the gated step and proceed with the execution of jobs beyond that point in the CI pipeline (e.g. deployment to production).

This sample illustrates the usage of [GitHub's Pull Request process](https://help.github.com/articles/about-pull-requests/) to control the follow of execution of steps beyond a gated job of a CI pipeline.


<!-- ![Gated pipeline with GitHub PR](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/shipit-gated-pipeline-enhanced.gif) -->


### Sample pipeline
The pipeline definition file for the sample above is available [here](gated-pipeline-04-github-pr).

The sample uses one `deployment-control` github repository that contains an `environment.json` file to control the execution of deployment steps beyond the gate job of the pipeline (i.e. `Deploy-Upon-PR-Approval`). The `master` branch of that repository is protected and only available for privileged users (e.g. a Release Manager).

When a new release is available, the `Test-release` job gets triggered automatically. If the release passes the tests successfully, then the pipeline will create a *pull request* for the master branch of the `deployment-control` repository requesting the promotion/deployment of the new software release.

The privileged user of that git repository (e.g. release manager) is notified via email by GitHub and can review and approve the pull request directly from GitHub's Pull Request Review user interface.

As soon as the pull request is approved, the CI pipeline will detect a change in `deployment-control` github repository. It will then trigger gate job `Deploy-Upon-PR-Approval` and proceed with the execution of the remaining jobs of the pipeline.


#### How to test the sample pipeline
To create the sample pipeline in your concourse server:

1. download file [gated-pipeline-04-github-pr](gated-pipeline-04-github-pr)

1. download file [params.yml](params.yml)

1. edit `params.yml` and replace the variables with the appropriate values:   
   - `github-deployment-control-repo`: the URL of your git repository to create pull requests for.  
   - `github-environment-control-file-path`: that path to your control JSON file in your github repository. See this [sample](https://github.com/lsilvapvt/misc-support-files/blob/master/environments/sandbox/environment.json).  
   - `github-username`: your github user name to create pull requests with.  
   - `github-password`: your github password  
   - `github-access-token`: your github access token. This is needed to avoid the github API limit error for the targeted repositories  
   - `email-address-sender`: your sender email address  
   - `email-address-recipient`: your destination email address  

1. issue the following fly command:   
`fly -t <your-concourse-alias> sp -p gated-github-pr -c gated-pipeline-04-github-pr.yml -l params.yml`


Un-paused the `gated-github-pr` pipeline in Concourse and you should see it running automatically every time a new `project-release` version is released.


##### Back to [Pipelines with gated steps](..)
