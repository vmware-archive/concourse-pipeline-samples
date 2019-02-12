<img src="https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/c0-logo-01.png" alt="Concourse" height="70" align="right"/>

# Concourse Samples and Recipes

Sample code and recipes on Concourse CI pipelines and deployments.

## Table of Contents

<img src="https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/pipeline-patterns-02.png" alt="Concourse Pipeline Patterns" width="100" align="right" style="margin: 20px;"/>

### **[Concourse Pipeline Patterns](concourse-pipeline-patterns)**  
  - [Gated Pipelines](concourse-pipeline-patterns/gated-pipelines)  
  - [Time triggered pipelines](concourse-pipeline-patterns/time-triggered-pipelines)  
  - [Parameterized pipeline tasks](concourse-pipeline-patterns/parameterized-pipeline-tasks)  
  - [Credentials Management with CredHub](https://github.com/pivotal-cf/pcf-pipelines/blob/master/docs/credhub-integration.md)  
  - [Credentials Management with Vault](concourse-pipeline-patterns/vault-integration)  
  - [Authenticate Concourse team members with PCF UAA](concourse-pipeline-patterns/uaa-authentication)  
  - [Insert Build Metadata into user notifications](https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/pipelines/notifications/email-with-attachments/build-metadata.md)  


<img src="https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/icons/pipeline-hacks.png" alt="Concourse Pipeline Hacks" width="100" ALIGN="RIGHT"  style="margin: 20px;"/>

### **[Concourse Pro Tips](concourse-pipeline-hacks)**   
  - [Running tasks with images on S3 for disconnected environments](concourse-pipeline-hacks/docker-images-from-s3)  
  - [Make Concourse retrieve an older version of a resource](concourse-pipeline-hacks/check-resource)  
  - [Test Worker Connectivity](tasks/concourse/will-worker-connect)  
  - [Run a task container with a user other than `root`](concourse-pipeline-hacks/task-run-user)  
  - [Configure Concourse with an HTTP/HTTPS proxy](concourse-pipeline-hacks/http-proxy-config)  
  - [Running tasks and resources without a Docker registry](concourse-pipeline-hacks/docker-images-from-repo)  
  - [Concourse pipeline integration with local Docker Registry](concourse-pipeline-hacks/private-docker-registry)  
  - [Deploying a Private Docker Registry with Bosh](concourse-pipeline-hacks/private-docker-registry/docker-registry-release)  
  - [Running local tasks while developing your CI pipeline in Concourse](concourse-pipeline-hacks/fly-execute)  
  - [Preview Concourse pipelines in ATOM](concourse-pipeline-hacks/concourse-atom-plugin)  


<img src="https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/remote_workers_icon.png" alt="Concourse Deployment Patterns" width="100" ALIGN="RIGHT"  style="margin: 20px;"/>

### **[Concourse Deployment Patterns](concourse-deployment-patterns)**   
  - [How to create a remote concourse worker](concourse-deployment-patterns/concourse-remote-worker)  


<img src="http://www.cbronline.com/wp-content/uploads/2017/07/Pivotal-Cloud-Foundry.png" alt="Pipeline Samples" width="50" align="right" style="margin: 20px;"/>

### **[Sample PCF Pipelines](.)**  
  - [VMWare Harbor tile](pipelines/vmware/install-harbor)  
  - [Monitor about-to-expire PCF TLS Certificates](pipelines/pcf/certificates/monitor-expiring-certificates)  


<img src="https://cdn1.iconfinder.com/data/icons/universal-signs-symbols/128/recycle-green-512.png" alt="Concourse concourse_pipeline_level_secrets_path" width="45" align="right" style="margin: 20px;"/>

### **[Reusable Pipelines Tasks](.)**  
  - [Configure PCF Tile](tasks/pcf/configure-tile)  
  - [Configure PKS CLI User](tasks/pcf/pks/configure-pks-cli-user)  
  - [Create PKS Cluster](tasks/pcf/pks/create-pks-cluster)  
  - [Delete PKS Cluster](tasks/pcf/pks/delete-pks-cluster)  
  - [Monitor about-to-expire PCF TLS certificates](tasks/pcf/certificates/check-expiring-certificates)  
  - [Regenerate non-configurable PCF TLS certificates](tasks/pcf/certificates/regenerate-internal-certificates)  
  - [Configure VMWare NSX-V artifacts](tasks/vsphere/nsxv)  
  - [Configure VMWare NSX-T artifacts](tasks/vsphere/nsxt)  


<img src="https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/concourse-and-artifactory.png" alt="Artifactory integration with Concourse pipelines" width="100" align="right" style="margin: 20px"/>

### **[Integration with File Repositories](.)**   
  - [JFrog Artifactory](pipelines/jfrog/artifactory-integration)
  - [Azure blobstore](pipelines/azure/azure-blobstore-integration)  
  - [Google Cloud Storage](pipelines/google/google-cloud-storage-integration)  

<img src="https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/bg-pipeline-icon.jpg" alt="Blue-Green application deployment pipeline" width="105"  align="right" style="margin: 20px"/>

### **[Application Development Pipelines](.)**   
  - [Blue-Green application deployment](pipelines/appdev/blue-green-app-deployment)  
  - [Application pipeline using multiple CF spaces](https://github.com/lsilvapvt/sample-app-pipeline)  
