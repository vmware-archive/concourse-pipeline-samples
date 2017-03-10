# A pipeline with multiple trigger resources

As an enhancement to the previous [sample with a single time trigger](../01-single-time-trigger), this pipeline example implements _two_ [time resource triggers](https://github.com/concourse/time-resource) and the ability to manually kick it off outside of the time resources schedules.

This is a typical pattern for system backup pipelines, where administrators
require the automated backup to run for a couple or few times a day and also  the ability to have a one-off run when necessary.

### Sample pipeline
Download the sample pipeline configuration file  [here](scheduled-pipeline-02.yml).  

![Pipeline with multiple time triggers screenshot](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/time-trigger-02.png)

The sample uses a [semver resource](https://github.com/concourse/semver-resource) to control the manual triggering of the pipeline and requires an S3 repository for that.


### How to test the pipeline

To create the sample pipeline in your concourse server:

1. download file [scheduled-pipeline-02.yml](scheduled-pipeline-02.yml)

1. download file [params.yml](params.yml)

1. edit `params.yml` and enter your S3 credentials following the comments in the file

1. issue the following fly command:   
`fly -t <your-concourse-alias> set-pipeline -p multiple-timers -c scheduled-pipeline-02.yml -l params.yml`

Then un-paused the `multiple-timers` pipeline in Concourse and it will be triggered either automatically in the interval of every 4 or every 10 minutes or manually by running job `manual-trigger`.


Note:

- The `manualtrigger` resource is necessary in order to propagate the manual execution to all steps in this pipeline. Without it, if one tries to run the first individual job of the pipeline, no other job would be executed due to the lack of a common manual trigger.


##### Back to [Time triggered pipelines](..)
