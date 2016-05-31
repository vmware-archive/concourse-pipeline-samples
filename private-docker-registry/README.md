![Concourse and a Private Docker Registry](https://raw.githubusercontent.com/lsilvapvt/concourse-pipeline-samples/master/common/images/concourse-and-private-registry.jpg)

# Concourse pipelines with a local Docker Registry

A typical question that surfaces from customers planning to adopt and deploy Concourse on their production environments is _“How do I run Concourse tasks on a protected or internetless environment where no access to Docker Hub is available?”_. The typical short answer from experts or from the [Concourse documentation](http://concourse.ci/running-tasks.html) is _“deploy your own private Docker registry and point your Concourse tasks to that registry’s images”_.

However, before getting to that final milestone and deploying Concourse to production, one may want to experiment with a local setup of Concourse and a Docker registry. And that is what this article is about.

This article does not provide any recommendation on how to setup a private Docker repository for production nor any analysis on which products are available for such purpose (an interesting topic for a future article nevertheless). My goal here is to share my experience while deploying Concourse and a private Docker registry on a local machine.


1. **Configure your Local Concourse instance**

   Either follow the [Concourse installation instructions](http://concourse.ci/vagrant.html) to deploy it  with Vagrant or follow [this article](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/concourse-on-bosh-lite) to deploy it with Bosh-lite.

   **Important**: the minimum required version of Concourse for this experiment is **v1.2.0**. Any previous version of that CI tool will fail to download images from the private Docker registry returning a “manifest unknown” API error.

2. **Configure your local Docker registry**

   - Download and Install the Docker Tools on your machine: https://docs.docker.com/engine/installation/mac/

   - Deploy the local Docker registry server and push a ubuntu image into it https://docs.docker.com/registry/deploying/

   After this setup is done, you should be able to check your local registry’s images with the following command:

   ```curl http://<your-machine-ip-address>:5000/v2/_catalog```

   **Hint**: use your machine’s ip address instead of localhost or 127.0.0.0.
   Even though those two hostnames will work for the curl command, they will not work for the Concourse task setup, which requires your machine IP address or hostname for the registry to be found by the task.

   Here are a couple of other [Docker Registry API](https://docs.docker.com/registry/spec/api/) end-points you can try.
   For example, using machine’s IP address 192.168.99.100:

     ```curl 192.168.99.100:5000/v2/ubuntu/tags/list ```

     ```curl 192.168.99.100:5000/v2/ubuntu/manifests/latest ```

   Note: in case these curl commands fail, you could try to temporarily configure your local registry as insecure (assuming your are not exposing it to the outside world) as described in the documentation https://docs.docker.com/registry/insecure/

3. **Setup your Concourse pipeline and tasks to use the local Docker registry images**

   Once your local Concourse and Docker registry are appropriately configured, it is time for you to setup a test pipeline with tasks that will run with an Docker image from your local registry.

   The following ```inline-pipeline.yml``` file provides a sample to test such scenario:

   https://github.com/lsilvapvt/concourse-pipeline-samples/blob/master/private-docker-registry/inline-pipeline.yml

   Simply replace the four entries <your-ip-address-goes-here> with your ip address value and then create the corresponding pipeline in Concourse. Example:

   ```fly -t <local-concourse-url> set-pipeline -p test-registry -c inline-pipeline.yml ```

   That sample pipeline will simply run two tasks that will respectively check the OS version and run a “ls” command in the Docker container in which they run after downloading it from the local Docker registry:

``` yaml
  ...
  type: docker-image
  source:
    repository: 192.168.99.100:5000/ubuntu
    tag: "latest"
    insecure_registries: [ "192.168.99.100:5000" ]
   ...
```

## References
   - [Docker Registry overview](https://docs.docker.com/registry/overview/)
   - [Concourse tasks overview](http://concourse.ci/running-tasks.html)
