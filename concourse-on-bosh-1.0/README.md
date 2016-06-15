
![Concourse on Bosh 1.0](https://raw.githubusercontent.com/lsilvapvt/concourse-pipeline-samples/master/common/images/concourse-and-bosh-1.0.jpg)

# Concourse deployment with a Bosh 1.x manifest

Concourse's [installation documentation](http://concourse.ci/clusters-with-bosh.html) provides only samples on how to install Concourse using a Bosh 2.0-style deployment manifests, i.e. manifests that rely on the Bosh 2.0 Cloud Config concept. In some instances though, customers may want to install Concourse on a new or existing Bosh Director where a Bosh 1.0 compliant deployment is in effect or desired for some reason.

Having that said, this article provides sample steps on how to deploy Concourse 1.x on a Bosh Director not yet setup to use Cloud Config features. It also assumes that you have an instance of [Bosh Director](http://bosh.io/docs/init.html) already configured.

### Installation steps
---

1. Download the [template YML for Concourse deployment on a Bosh 1.x Director](https://raw.githubusercontent.com/lsilvapvt/concourse-pipeline-samples/master/concourse-on-bosh-1.0/concourse.yml)

1. Retrieve your Bosh Director UUID ( command ```bosh status --uuid``` ) and update THE YML file with it in entry ```director_uuid:```

1. Review all of the comments in the YML file and update the corresponding entries according to the instructions. If you are deploying to an existing Bosh Director containing other deployments (e.g. PCF), a hint is to inspect the YML file of those co-located deployments in order to get the network and VM configuration entries to be used in your Concourse YML.

1. Download the latest releases for concourse and garden-linux:

    - https://bosh.io/d/github.com/concourse/concourse
    - https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release

1. Upload both releases onto the Bosh-lite director with the following commands

        bosh upload release <concourse-release-local-file-path-and-name>
        bosh upload release <garden-linux-local-file-path-and-name>

1. Download the latest corresponding stemcell for your IaaS from https://bosh.io/stemcells

1. Upload the stemcell onto the Bosh-lite Director

        bosh upload stemcell <bosh-stemcell-local-file-path-and-name>

1. Set the target deployment manifest file for Bosh

        bosh deployment <path-and-name-of-your-yml-file>

1. Run the deployment of Concourse

        bosh deploy

1. Access the Concourse web UI

    If the deployment above is successful, the Concourse web interface can be accessed in through the URL configured in your YML file's "external_url" property:

       ``external_url: http://XX.XX.XX.XX:8080```

1. Deploy and run your pipelines as described in the [Concourse Documentation page](http://concourse.ci/fly-cli.html).


---


**Note #1**: as a best practice for **production environments**, Concourse should be deployed and managed by its own instance of Bosh Director, so it can be scaled as appropriate and without possibly impacting any other colocated deployment. Although sharing the same Bosh Director from existing PCF deployment(s) with Concourse is technically feasible, it may create additional load, management complexity and risks for the existing deployments on that Bosh Director (e.g. PCF Elastic and tiles that may generated a dozen or so different deployments to be managed by one Bosh Director).

**Note #2**: the Bosh 1.x deployment manifest for Concourse will only work for a Bosh Director that has NOT yet been converted to use Cloud Config features (i.e. Bosh 2.0). Once a Bosh Director is converted to use Cloud Config properties, there is no turning back from it and all of its deployments must have that configuration applied to them. Read more [here](https://bosh.io/docs/cloud-config.html).

**Extra hint #1**: for experimental purposes in non-prod environments, you can register your Concourse web instances' IP addresses as part of your existing PCF's [**router registrar**](https://github.com/cloudfoundry-community/route-registrar-boshrelease) instance and get concourse under your PCF system domain.  You just need to add the "route registrar" bosh release and properties into the Concourse manifest. See this [enhanced YML template](https://raw.githubusercontent.com/lsilvapvt/concourse-pipeline-samples/master/concourse-on-bosh-1.0/concourse-with-router-registrar.yml) containing entries for the router-registrar usage. Thanks to Stuart Charlton for sharing this useful hint.

---

### Read more

- [Application pipeline deploying to multiple CF spaces](https://github.com/lsilvapvt/sample-app-pipeline)

- [Blue-Green application deployment pipeline with Concourse](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/blue-green-app-deployment)

- [Deploying Concourse on Bosh-lite](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/concourse-on-bosh-lite)

- [Concourse pipelines with a local Docker Registry](https://github.com/lsilvapvt/concourse-pipeline-samples/tree/master/private-docker-registry)
