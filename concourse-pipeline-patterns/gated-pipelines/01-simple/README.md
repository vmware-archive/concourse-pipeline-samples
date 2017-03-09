# A simple pipeline with a manually triggered step

In Concourse, a job requires to be manually triggered by default, as long as none of
its resources specify the "[trigger: true](http://concourse.ci/get-step.html#trigger)" parameter.

Therefore, in order to create a "gated" step in a pipeline, a simple job that requires a manual trigger needs to be inserted into it.

```
- name: Run-automatically
  plan:
  - get: my-resource
    trigger: true
  - task: do-your-task-here
    ...

- name: Manually-trigger-me # <-----  INJECT manual job in pipeline
  plan:
  - get: my-resource
    trigger: false          # <-----  REQUIRES manual trigger
    passed:
      - Run-automatically   # <-----  Adds it to the chain of jobs in the pipeline
  - task: do-your-manual-task-here
    ...

- name: Do-more-stuff-after-manual-trigger
  plan:
  - get: my-resource
    passed:
      - Manually-trigger-me
    trigger: true
  - task: do-other-tasks-here
    ...
```

### Sample pipeline
A complete pipeline definition file for the sample above is available [here](gated-pipeline-01-simple.yml).

It defines a manual job between two other jobs that are automatically trigger upon version changes of a common resource (a github repository).

![Simple gated pipeline screenshot](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/simple-gated-pipeline.gif)


### How to test the pipeline
To create the sample pipeline in your concourse server, download file [gated-pipeline-01-simple.yml](gated-pipeline-01-simple.yml) and issue the following fly command:   
`fly -t <your-concourse-alias> set-pipeline -p simple-gate -c gated-pipeline-01-simple.yml`

You will notice that, once the pipeline is un-paused in Concourse, it will automatically execute its first job (`Run-automatically`). Then, you will have to click on the second job (`Manually-trigger-me`) and click its `+` icon to manually run it. Only then, the second and third jobs will be executed with the corresponding resource version processed by the first job.

This example illustrates the typical pattern of building and unit testing code in the first half of the CI/CD pipeline and then deploying it to a more tightly controlled environment (the second half of the pipeline) only upon a manual pipeline job trigger by an authorized user.

### See also

- [The _Ship-it!_ gated pipeline example](../02-shipit)  

- [A more sophisticated gated pipeline](../03-shipit-enhanced)  
