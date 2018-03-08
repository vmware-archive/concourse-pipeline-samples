![Pipeline Hacks](https://github.com/pivotalservices/concourse-pipeline-samples/raw/master/common/images/concourse-and-s3-images.png)

# Running tasks with Docker images from an S3 bucket

Pipeline tasks can be executed with images stored in repositories other than a Docker registry as previously described in [this article](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-pipeline-hacks/docker-images-from-repo). However, the drawback of that article's proposed solution is the fact that the `rootfs` of the image needs to be available and stored uncompressed.

Enter **S3 resource's `unpack` feature**: starting in Concourse 3.3.3, the S3 resource provides the ability to automatically *untar* a file after its download from a bucket. This is perfect to be used as the source of Docker images in offline/disconnected pipelines given that the `rootfs` directory of an image can now be packaged and maintained as a tar file.  

### Examples

Assume that a Docker image for **ubuntu** has been exported as file `ubuntu-17.04.tgz` and saved to your S3 `images` bucket under folder `ubuntu` *(see more information on how to export Docker images further below)*.  

Here are two ways that your pipeline could reference that image file on S3:

##### Example 1 - using the `image_resource` property (recommended)

```
jobs:
- name: hello-s3
  plan:
  - task: run-with-image-from-s3
    config:
      platform: linux
      image_resource:
        type: s3
        source:
          bucket: images
          regexp: ubuntu/ubuntu-(.*).tgz
          endpoint: ((s3-endpoint))   
          access_key_id: ((s3-access-key-id))
          secret_access_key: ((s3-secret-access-key))
          region_name: ((s3-region-name))
        params:
          unpack: true
      run:
        path: sh
        args:
        - -c
        - echo "I can run with the image from S3"
```

The magic happens within the `image_resource` object, with the definition of the S3 repository and image file, along with the `unpack: true` property under `params`.  


##### Example 2 - using the `image` property and a resource

```
resources:
- name: my-image
  type: s3
  source:
    bucket: images
    regexp: ubuntu/ubuntu-(.*).tgz
    endpoint: ((s3-endpoint))
    access_key_id: ((s3-access-key-id))
    secret_access_key: ((s3-secret-access-key))
    region_name: ((s3-region-name))
jobs:
- name: hello-s3-with-resource
  plan:
  - get: my-image
    params:
      unpack: true
  - task: run-with-image-from-s3-using-resource-definition
    image: my-image
    config:
      platform: linux
      run:
        path: sh
        args:
        - -c
        - echo "I can run with image from resource definition"
```

The image can be referenced as a resource throughout all jobs in the pipeline. The `unpack: true` parameter extracts the content of the image when the job is executed.  

This approach is not marked as *recommended* since the `image` property may be deprecated in the near future by Concourse.


### How export a Docker image into a tar file

Concourse requires task and resource images to contain the following elements:

1. the `rootfs` folder containing all the files of the desired container

1. a `metadata.json` file describing the container's `env` variables and running `user`.

The recommended way to export a `rootfs` directory and `metadata.json` file for a Docker image is to do it from a Concourse pipeline that has access to Docker Hub, and then tar + save the exported files into the S3 repository.

See sample [`Package-Docker-Images`](package-docker-images.yml), which produces and packages the `rootfs` files for an ubuntu image and saves it into an S3 bucket.

Another example of such download-and-package pipeline is also available from [this repository](https://github.com/pivotal-cf/pcf-pipelines/blob/master/download-offline-resources/pipeline.yml).


### See also

- [Concourse documentation on running tasks with a rootfs image]( https://concourse-ci.org/running-tasks.html#task-config-image)

- [Running pipeline tasks and resources without a Docker registry](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-pipeline-hacks/docker-images-from-repo)


### Thanks

Many thanks to Gavin Enns, Shaozhen Ding and Kris Hicks for their input and hints provided during the writing of this article.  


#### [Back to Concourse Pipeline Hacks](..)
