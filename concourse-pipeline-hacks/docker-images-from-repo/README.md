![Pipeline Hacks](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/icons/concourse-images-repo.png)

# Running pipeline tasks and resources without a Docker registry

For cases when the access to Docker Hub is not available from the subnet which Concourse is deployed to AND the deployment of an internal Docker Registry may take long or be difficult for any reason, there is a temporary workaround to run Concourse pipelines on that environment: **run tasks and community resources using rootfs images stored in a repository**.


### How it is done

For that to work, the `rootfs` image repository (e.g. git) needs to contain two artifacts at its top level:

1. a `rootfs` directory containing all the files expected from the output of a 'docker export' of the desired container

1. a `metadata.json` file describing the container's `env` variables and running `user`.


These are the very basic artifacts required for any [`Docker Image`](https://github.com/concourse/docker-image-resource) resource in Concourse. See the ["how-to" section](#howto) further below for details on how to generate these artifacts from an existing Docker image.


Here is an example of a `rootfs` git repository with the required container files exported from the `curl-resource` image: https://github.com/lsilvapvt/rootfs-curl-resource.


![Rootfs-curl-repo](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/rootfs-curl-repo.jpg)


To use that `rootfs` repository in a pipeline, use the  [`image`](https://concourse.ci/task-step.html#task-image) parameter instead of `image_resource` when defining a task.  
For defining [resource types](https://concourse.ci/configuring-resource-types.html) using `rootfs` repositories, use `type: git` instead of `type: docker-image` in the `resource_types` entries of the pipeline.

### Sample pipeline

Here is how the [`curl-resource`](https://github.com/lsilvapvt/rootfs-curl-resource) container `rootfs` repository could be used in a pipeline to run *both* tasks and resources of a Concourse server disconnected from a Docker registry:


```
resource_types:
- name: curl-file-resource
  type: git
  source:
    uri: https://github.com/lsilvapvt/rootfs-curl-resource.git

resources:
- name: rootfs-repo
  type: git
  source:
    uri: https://github.com/lsilvapvt/rootfs-curl-resource.git
- name: apache-lucene-5
  type: curl-file-resource
  source:
    url: http://www-us.apache.org/dist/lucene/java/5.5.4/lucene-5.5.4.zip
    filename: lucene-5.5.4.zip

jobs:
- name: run-and-get-Apache-Lucene
  plan:
  - get: rootfs-repo
  - get: apache-lucene-5
  - task: run-with-rootfs-curl-repository
    image: rootfs-repo
    config:
      platform: linux
      inputs:
      - name: apache-lucene-5
      run:
        path: sh
        args:
        - -exc
        - |
          find .

```

The complete pipeline definition file for the sample above can be downloaded from [here](resource-curl-with-image-from-git.yml).


### Additional sample pipelines

- [Pipeline with task that runs with docker image from a git repository](task-with-image-from-git.yml)

- [Pipeline with a community resource that is defined with a docker image from a git repository](resource-with-image-from-git.yml)

- [Pipeline with a PivNet community resource that is defined with a docker image from a git repository](resource-pivnet-with-image-from-git.yml)


### <a name="howto"></a>How to create a rootfs repository from a Docker image

The `rootfs` repositories will have to be pre-populated into the targeted file repository (e.g. GitLab,BitBucket) before the Concourse pipelines can be executed.

The `rootfs` directory and files can be created from a [`docker export`](https://docs.docker.com/engine/reference/commandline/export/) command, however the `metadata.json` file is specific to Concourse's [`Docker images`](https://github.com/concourse/docker-image-resource) resources.   

Because of that, it would be easier to first export a `rootfs` directory and `metadata.json` file for a Docker image directly from a Concourse pipeline that has access to Docker Hub, and then save the exported files into the repository that is accessible from the targeted Concourse server which has no access to a Docker registry.


See sample [`Inspector docker image pipeline`](inspect-docker-image.yml) that produces the `rootfs` files for a Docker image in the right format as an output to a task that can be extended to automatically save the files into a another repository.  
Look for comments in that file for instructions on how to consume the exported image files.

### Note

The techniques described here should only be used for temporary Concourse demonstrations or sample deployments until access to a Docker registry is available from the Concourse server VM's subnet.


### See also

- [Concourse documentation on running tasks with a rootfs image]( https://concourse.ci/running-tasks.html#task-config-image)
