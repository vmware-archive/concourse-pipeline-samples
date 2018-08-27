![fly_execute](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/fly_execute_01.png)

# Running local tasks while developing your CI pipeline in Concourse

### The problem
When developing relatively complex pipelines for Concourse, tasks definitions and scripts are typically defined in individual files (e.g. YML and .sh), separate from the main pipeline definition YML file.

While this is a great structure for a CI pipeline in production, it creates a pain point for the developer of that same pipeline: for every code tweak made to a task's YML or script file, a git commit/push is required in order for the Concourse server to pick up the task's latest files from git.

### The solution

Run and debug local copies of task files until they are fully functional and ready to be pushed to the git repository.

Concourse's fly execute command allows for the execution of local individual tasks along with local versions of artifacts (e.g. script files).

For example, for the pipeline files listed further below, while I'm still developing or debugging the task defined by sayhi.yml and its script sayhi.sh, I could use the following command to run the local task from within the my-repo directory:

`fly execute -c ./tasks/sayhi.yml --input my-repo=.`

Concourse will execute the task and, due to the provided --input option, it will use my current directory (.) as the required my-repo input for the task, making all files from that local directory available to the running container.


<table style="height: 276px;" border="1" width="621" cellpadding="3">
<tbody>
<tr>
<td><strong><span style="font-family: arial, helvetica, sans-serif; font-size: 10pt;">Pipeline files dir tree</span></strong></td>
<td><span style="font-family: arial, helvetica, sans-serif; font-size: 10pt;">&nbsp;Task definition file:</span><strong><span style="font-family: arial, helvetica, sans-serif; font-size: 10pt;"> &nbsp;sayhi.yml</span></strong></td>
<td><span style="font-family: arial, helvetica, sans-serif; font-size: 10pt;">&nbsp;Task script:</span><strong><span style="font-family: arial, helvetica, sans-serif; font-size: 10pt;"> &nbsp;sayhi.sh</span></strong></td>
</tr>
<tr>
<td style="background-color: black;">
<p><span style="font-family: 'courier new', courier; font-size: 11pt; color: #ffffff;">my-repo</span><br /><span style="font-family: 'courier new', courier; font-size: 11pt; color: #ffffff;">|-- main</span><br /><span style="font-family: 'courier new', courier; font-size: 11pt; color: #ffffff;">| &nbsp; +--&nbsp;pipeline.yml</span><br /><span style="font-family: 'courier new', courier; font-size: 11pt; color: #ffffff;">|-- scripts</span><br /><span style="font-family: 'courier new', courier; font-size: 11pt; color: #ffffff;">| &nbsp; &nbsp;|-- sayhi.sh</span><br /><span style="font-family: 'courier new', courier; font-size: 11pt; color: #ffffff;">| &nbsp; &nbsp;+-- sayyo.sh&nbsp;</span><br /><span style="font-family: 'courier new', courier; font-size: 11pt; color: #ffffff;">+-- tasks</span><br /><span style="font-family: 'courier new', courier; font-size: 11pt; color: #ffffff;">&nbsp; &nbsp; &nbsp;|-- sayhi.yml</span><br /><span style="font-family: 'courier new', courier; font-size: 11pt; color: #ffffff;">&nbsp; &nbsp; &nbsp;+-- sayyo.yml</span></p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><span style="color: #ffffff;">&nbsp;</span></p>
</td>
<td style="background-color: black;">
<p><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;">---</span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ff0000;">platform</span><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;"><span style="color: #ff0000;">:</span> linux<br /></span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ff0000;">image_resource:</span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;">&nbsp; <span style="color: #ff0000;">type:</span> docker-image</span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;">&nbsp; <span style="color: #ff0000;">source:</span></span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;">&nbsp; &nbsp; <span style="color: #ff0000;">repository:</span> ubuntu</span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;">&nbsp; &nbsp; <span style="color: #ff0000;">tag:</span> "latest"<br /></span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ff0000;">inputs:</span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;">- <span style="color: #ff0000;">name:</span> my-repo</span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;"><br /><span style="color: #ff0000;">run:</span></span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;">&nbsp; path: my-repo /scripts/sayhi.sh</span></p>
<p>&nbsp;</p>
</td>
<td style="background-color: black;">
<p><span style="font-family: 'courier new', courier; font-size: 10pt; color: #b9b9b9;">#!/bin/bash</span><br /><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;"><span style="color: #00ffff;">set</span> -xe</span></p>
<p><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;"><span style="color: #00ffff;">echo</span> "Hi there!" &nbsp;</span></p>
<p><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;">find <span style="color: #00ffff;">.</span></span></p>
<p><span style="font-family: 'courier new', courier; font-size: 10pt; color: #ffffff;">env</span></p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;&nbsp;</p>
</td>
</tr>
</tbody>
</table>


### Reusing input from builds on the Concourse server

Not only local directories can be used as inputs by the fly execute command. A resource input from an existing pipeline/job on the Concourse server can also be used as input for your local task run.

For example, suppose that my `sayhi.yml` task definition had a second required input for another git repository:

```
  inputs:
     - name: my-repo
     - name: other-git-repo
```

Instead of using a local copy of that repo for my local task run, I could add the `--inputs-from` parameter to my previous command:

    `fly execute -c ./tasks/sayhi.yml --input my-repo=. --inputs-from myPipelineName/myJobName`

While running the local task, Concourse will still use the local directory for the `my-repo` input as before, but it will also retrieve the inputs from the defined job and make them available for the local task run.     

### Handling params entries in local task runs

If your task definition requires parameters from a `params` section in the YML, they can be provided to the local task run by using environment variables.

For example, let's say that `sayhi.yml` requires two parameters, `USERNAME` and `CITY`, to be used by `sayhi.sh`.

To make that work in a local task run, the following section should be added to the task YML file:

```
params:
  USERNAME: 
  CITY: 
```

Then, in your command line, define the corresponding environment variables with the values that you need for the local task run.

For example:     `export USERNAME=John && export CITY=Raleigh`

The fly execute command will search for environment variables that match the entries from the `params` section while executing a task and make them available for the task execution scripts.

In a scenario like that, my `sayhi.sh` script could be updated with the following command:

      `echo "Hi $USERNAME, greetings from $CITY."`


The `fly execute` command also provides options to exclude local files from inputs and also to capture the output of a local task run.

More details can be found on the [fly execute documentation page](https://concourse-ci.org/running-tasks.html#fly-execute).


#### [Back to Concourse Pipelines Pro Tips](..)
