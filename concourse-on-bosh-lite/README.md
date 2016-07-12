![Concourse on Bosh-Lite](https://raw.githubusercontent.com/lsilvapvt/concourse-pipeline-samples/master/common/images/concourse-and-bosh-lite.jpg)

# Deploying Concourse on Bosh-lite

The quickest way to install and run a local copy of Concourse is by using the provided Vagrant image as mentioned in [Concourse’s documentation page](http://concourse.ci/vagrant.html). However, in certain cases, one may have the need to experiment with the Bosh-deployed version of Concourse in a local machine prior to moving it onto a shared/production environment later. For those cases, a solution is to install Concourse on top of a local Bosh-lite deployment. The section further below describes the steps to get that done.

For more information about Bosh-lite and Concourse, please refer to the **Reference** section further below.

## Setup instructions

1. Install Bosh-lite on your machine

    Follow the Bosh-lite installation instructions on [https://github.com/cloudfoundry/bosh-lite](https://github.com/cloudfoundry/bosh-lite).

    In summary, you have to clone https://github.com/cloudfoundry/bosh-lite  and then issue command __vagrant up__ .

    If you have bosh-lite previously installed, make sure you are on at least BOSH 1.3215.4.0. If not do "vagrant box update && vagrant destroy && vagrant up"

    Also, make sure to run  **bin/add-route** from within the bosh-lite directory.

    Then, "Bosh login" into the bosh-lite director following the steps in the installation instructions above.

2. Download the latest releases for concourse and garden-linux from the following links:

    - https://bosh.io/d/github.com/concourse/concourse
    - https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release

3. Upload both releases onto the Bosh-lite director with the following commands

        bosh upload release <concourse-release-local-file-path-and-name>
        bosh upload release <garden-linux-local-file-path-and-name>

4. Download the latest bosh-lite warden stemcell

    https://bosh.io/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent

    For example, the link to download version 3147 is https://s3.amazonaws.com/bosh-warden-stemcells/bosh-stemcell-3147-warden-boshlite-ubuntu-trusty-go_agent.tgz

5. Upload the stemcell onto the Bosh-lite Director

        bosh upload stemcell <bosh-stemcell-local-file-path-and-name>

6. Download the latest Concourse deployment manifest file for Bosh-lite from github

     For example, the v1.2.0 manifest file is in this location
     https://github.com/concourse/concourse/blob/v1.2.0/manifests/bosh-lite.yml

7. Update the deployment manifest with the UUID of your bosh director

   Get your Bosh-lite Director’s UUID by running the following command:

             bosh status --uuid

   Then edit your local deployment manifest and add the obtained UUID value to property **“director_uuid”**. Save the file.

8. Set the target deployment manifest file for Bosh

          bosh deployment <path-and-name-of-manifest-file-you-just-edited-above>

9. Run the deployment of Concourse

          bosh deploy

10. Access the Concourse web UI

    If the deployment above was successful, the Concourse web interface can be accessed with the following URL:

       [http://10.244.8.2:8080/](http://10.244.8.2:8080/)

11. Deploy and run your pipelines as described in the [Concourse Documentation page](http://concourse.ci/fly-cli.html).


## References
- Bosh-lite https://github.com/cloudfoundry/bosh-lite
- Concourse http://concourse.ci/introduction.html

## Credits
Article based on deployment steps originally provided by Caleb Washburn

---

### Read more

- [Application pipeline deploying to multiple CF spaces](https://github.com/lsilvapvt/sample-app-pipeline)

- [Blue-Green application deployment pipeline with Concourse](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/blue-green-app-deployment)

- [PCF Backup CI pipeline using CFOps](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/pcf-cfops-backup)

- [Deploying Concourse on a Bosh 1.0 Director](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/concourse-on-bosh-1.0)

- [Concourse pipelines with a local Docker Registry](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/private-docker-registry)
