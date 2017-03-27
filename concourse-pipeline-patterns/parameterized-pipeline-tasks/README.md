![Pipelines with task params](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/icons/concourse-task-params.png)

# Parameterized pipeline tasks

In the same fashion as a method or function in programming languages, Concourse pipeline tasks can be executed with parameterized variables, inputs and outputs.

That allows for the reuse of common task definitions, for example, `package release` or `deploy application`, in multiple contexts and in multiple executions for a distinct artifacts.


### Key-value pairs with `params`

Key-value pairs can be passed to a task through a [`params`](http://concourse.ci/running-tasks.html#params) section in the task definition. Each `key` entry will become an **environment variable** during the execution of the task.


### Input and Output Mappings

The `inputs` and `outputs` of a task can be parameterized with [input-mappings](http://concourse.ci/task-step.html#input_mapping) and [output-mappings](http://concourse.ci/task-step.html#output_mapping) respectively.  
That means that an entire input or output folder that is expected by the task (e.g. a github release or S3) can be "substituted" with another folder from a pipeline resource for each run of the task.


### Example

Supposed that individual Docker Tutorial packages need to be created for Java
and Go languages. Each package will contain the same tutorial files, but will
have to ship the specific Dockerfile for the corresponding language's docker image.


![Pipeline with parameterized task](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/tasks-param-pipeline.jpg)


#### The generic tutorial packager task  

This is the common task that packages the tutorial files from input `tutorial-release` along with a *Dockerfile* expected from input `dockerfile` into a file name defined by environment variable `$PACKAGE_NAME`.


```
platform: linux
image_resource:
   ...
inputs:
  - name: tutorial-release
  - name: dockerfile
outputs:
  - name: output-directory
run:
  path: sh
  args:
  - -exc
  - |
    cp ./dockerfile/Dockerfile ./tutorial-release
    tar -cvf ./output-directory/$PACKAGE_NAME ./tutorial-release
```

#### The pipeline definition file

The excerpt of a pipeline definition file below uses the task above (stored in the `common-tasks` git repository as `package-with-dockerfile.yml`) to create two tutorial packages: one for `Go` and one for `Java`.  

There are two jobs in the pipeline that invoke the `package-with-dockerfile.yml`
task, each one passing in specific `input-mapping` and `params` attributes.  

The `PACKAGE_NAME` param creates the environment variable that defines the package file name (e.g. `java-docker-tutorial.tgz`) to be created.

The `input_mapping` section maps the expected `dockerfile` input to the resource that
contains the corresponding *Dockerfile* for each language (e.g. `java-dockerfile` for Java, `go-dockerfile` for Go).


```
jobs:
...
- name: Package-Java-Tutorial
  plan:
  - get: tutorial-release
  - get: java-dockerfile
  - get: common-tasks
  - task: package-java-docker-tutorial
    file: common-tasks/.../package-with-dockerfile.yml
    input_mapping:
      dockerfile: java-dockerfile
    params:
      PACKAGE_NAME: java-docker-tutorial.tgz

- name: Package-Go-Tutorial
  plan:
  - get: tutorial-release
  - get: go-dockerfile
  - get: common-tasks
  - task: package-go-docker-tutorial
    file: common-tasks/.../package-with-dockerfile.yml
    input_mapping:
      dockerfile: go-dockerfile
    params:
      PACKAGE_NAME: go-docker-tutorial.tgz

resources:
- name: tutorial-release
  type: git
  source:
    uri: https://github.com/docker/labs.git

- name: java-dockerfile
  type: git
  source:
    uri: https://github.com/dockerfile/java.git

- name: go-dockerfile
  type: git
  source:
    uri: https://github.com/dockerfile/go

- name: common-tasks
  type: git
  source:
    uri: https://github.com/pivotalservices/concourse-pipeline-samples.git

```

### Run the sample pipeline

Download the complete pipeline file for the sample above from [here](package-tutorials.yml) and then set a pipeline with it on your
Concourse server to inspect the results of the parameterized tasks feature.

#### [Back to Concourse Pipeline Patterns](..)
