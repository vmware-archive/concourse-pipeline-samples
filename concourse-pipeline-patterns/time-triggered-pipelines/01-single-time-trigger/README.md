# A Concourse CI pipeline with a single time trigger

This page provides an example of a pipeline that is triggered by a [time resource](https://github.com/concourse/time-resource) on a pre-determined interval.

The [time resource](https://github.com/concourse/time-resource) produces a new trigger (or a new version in Concourse resource lingo) for the time interval that was declared in its definition in the pipeline configuration file.

- For example, a trigger for a time range:
```
resources:
- name: trigger-daily-between-1am-and-2am
  type: time
  source:
    start: 1:00 AM
    stop: 2:00 AM
    location: America/Phoenix
```
or, a trigger for a time interval:
```
resources:
- name: trigger-every-3-minutes
  type: time
  source:
    interval: 3m
```

### Sample pipeline
The pipeline below provides a sample of multiple jobs that are automatically triggered by a single interval time resource. Download its configuration file  [here](scheduled-pipeline-01.yml).

![Time-triggered pipeline screenshot](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/time-trigger-01.png)


### How to test the pipeline
To create the sample pipeline in your concourse server, download file [scheduled-pipeline-01](scheduled-pipeline-01.yml) and issue the following fly command:   
`fly -t <your-concourse-alias> set-pipeline -p simple-timer -c scheduled-pipeline-01.yml`

Then un-paused the pipeline in Concourse and it should automatically get triggered within 3 minutes.


### See also

- [A CI pipeline with multiple time trigger resources](../02-multiple-time-triggers)  
