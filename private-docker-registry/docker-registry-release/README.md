# Deploying a Private Docker Registry using Bosh

A bosh release is available for Docker Registry at https://github.com/cloudfoundry-community/docker-registry-boshrelease and can be used to deploy a private docker registry using Bosh.

The sample provided requires a Bosh 2.0 deployment (Cloud Config-based).

The sample manifest will deploy a Docker Registry with the following VM/jobs topology:

```
         [PROXY_VM]  
          |     |  
[REGISTRY_VM1]  [REGISTRY_VM2]  
          |     |  
        [NFS_SERVER]  
```

The Proxy VM will load balance requests for Docker images between the two registry nodes, which in turn will retrieve/restore images from/to the shared NFS server node.

The proxy's IP address is the one to be used by the tools and clients that will interact with the registry. For example, a Concourse pipeline would refer to the private registry's images with address ```<proxy_ip_address>:5000/<image-name>```. If a DNAT or LB rule is setup at the network egde for the proxy, then the corresponding ip address and port numbers should be used instead.

## Deploying the Docker Registry

The provided sample requires a Cloud-Config-based Bosh 2.0 Director. A sample cloud config file for a docker registry deployment is provided [here](https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/private-docker-registry/docker-registry-release/cloud-config.yml).
Once the Cloud Config is set for the Bosh Director, then update a copy of [this sample deployment manifest](https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/private-docker-registry/docker-registry-release/docker-registry.yml) with the required information tagged in it and run Bosh Deploy.
