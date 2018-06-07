<img src="https://pivotal.gallerycdn.vsassets.io/extensions/pivotal/vscode-concourse/0.1.3/1517353139519/Microsoft.VisualStudio.Services.Icons.Default" alt="Concourse" height="70"/>&nbsp;&nbsp;<img src="https://dtb5pzswcit1e.cloudfront.net/assets/images/product_logos/icon_pivotalcontainerservice@2x.png" alt="PCF Knowledge Depot" height="70"/>

# Install PKS pipeline

This pipeline installs the PKS tile (v1.1.x or 1.0.x) on top of an existing PCF Ops Manager deployment.

<img src="https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/install-pks-tile.png" alt="Concourse" width="100%"/>


The parameters file of this pipeline implements the concept of "externalized tile parameters", where all the available tile configuration options are fed to the pipeline tasks as a YAML object containing the parameter names expected by Ops Manager for the tile.

For example:
```
properties: |

  ######## Configuration for Plan 1
  .properties.plan1_selector:
    value: "Plan Active"
  .properties.plan1_selector.active.name:
    value: "Small plan"  # the name that appears for end users to choose
```

This approach allows for the `configure-tile` task of this pipeline to be generic and *tile-agnostic*, by delegating the tile configuration options to the content of the main three parameters `networks`, `properties` and `resources`.

**Note 1:** *PKS 1.1.x may not be publicly available until the end of June/2018. In the meantime, if you do not have access to the v1.1.x RC versions of the tile on PivNet, please use the instructions to deploy v1.0.x below."*


**Note 2:** *This pipeline provides a job (`update-director-config`) that enables BOSH Director's
post deploy scripts configuration. The reason: the PKS 1.0.0 tile does not deploy Kubernetes addons such as kube-dns, heapster, the dashboard and influxdb when you create a PKS cluster unless post deploy is enabled on the Director."*


---

## How to use this pipeline

1) Update the corresponding `pks` parameters file for the tile: e.g. [`pks_params.yml`](pks_params.yml) for **v1.1.x** or [`pks_params_1.0.yml`](pks_params_1.0.yml) for **v1.0.x**, by following the instructions in the file.  
   The order of tile parameters in those files follows the same order as parameters are presented in Ops Manager and in the tile documentation ([vSphere](https://docs.pivotal.io/runtimes/pks/installing-pks-vsphere.html) or [GCP](https://docs.pivotal.io/runtimes/pks/installing-pks-gcp.html)).  

    If you use `Vault` or `CredHub` for credentials management, you can use the provided script [`pks_vault_params.sh`](pks_vault_params.sh) to automatically create the pipeline secrets in those systems.

    Also, note that the pipeline can automatically generate certificates for the PKS API. See more details in comments for parameter  `.pivotal-container-service.pks_tls` in [`pks_params.yml`](pks_params.yml).  


2) Update [`pcf_params.yml`](pcf_params.yml) by following the instructions in the file.  

   This parameter file contains information about the PCF foundation (e.g. Ops Manager and Director) to which the tile will be deployed to.  

   This parameters file is separate from the others for reuse purposes, since any other PCF tile install or upgrade pipeline will use the same properties. If you already have this type of file created for another PCF tile pipeline, you can reuse it here. See [`Appendix A`](#appendix-a---pcf-pipelines-parameter-files-tiers) section below for a sample diagram of this parameters files structure pattern.

3) Update [`global_params.yml`](global_params.yml) by following the instructions in the file.  

  This parameter file contains information about global properties that typically apply to any PCF pipeline (e.g. Pivotal Network token).  

  This parameters file is separate from the others for reuse purposes, since any other PCF tile install or upgrade pipeline will use the same properties. If you already have this type of file created for another PCF tile pipeline, you can reuse it here. See [`Appendix A`](#appendix-a---pcf-pipelines-parameter-files-tiers) section below for a sample diagram of this parameters files structure pattern.

4) Create the pipeline in Concourse:  

   For PKS 1.1.x:  
   `fly -t <target> set-pipeline -p install-pks -c pipeline.yml -l global_params.yml -l pcf_params.yml -l pks_params.yml`  

   For PKS 1.0.x:  
   `fly -t <target> set-pipeline -p install-pks -c pipeline.yml -l global_params.yml -l pcf_params.yml -l pks_params_1.0.yml`  

5) Un-pause and run pipeline `install-pks`


---


## Post PKS tile deploy steps

### PKS CLI client ID creation

Once the PKS tile is successfully deployed, a PKS CLI client ID is required to be created ([see documentation](https://docs.pivotal.io/runtimes/pks/1-0/manage-users.html#uaa-scopes)).

For that step, the pipeline also provides a job to automate it: `create-pks-cli-user`. Simply manually run that pipeline job to get the PKS CLI client ID created.

*Note:* in order for that task to work, the configured PKS API endpoint needs to be reachable from a DNS/network standpoint (see docs for [vSphere](https://docs.pivotal.io/runtimes/pks/1-0/installing-pks-vsphere.html#loadbalancer-pks-api) and [GCP](https://docs.pivotal.io/runtimes/pks/1-0/installing-pks-gcp.html#loadbalancer-pks-api])).

### Using PKS

Once the PKS CLI client ID created, proceed with [creating K8s clusters with PKS](https://docs.pivotal.io/runtimes/pks/1-0/create-cluster.html) and [deploying K8s workloads with `kubectl`](https://docs.pivotal.io/runtimes/pks/1-0/deploy-workloads.html).

A sample Concourse pipeline to [Create a PKS Cluster](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/pipelines/pcf/pks/configure-pks-cluster) is also available.

---

## Appendix A - PCF pipelines parameter files tiers

```
┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐   ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐                               
│                                           │   │                                           │                               
         Pipelines for Foundation 1                      Pipelines for Foundation 2                                         
│ ┌───────────┐ ┌───────────┐ ┌───────────┐ │   │ ┌───────────┐ ┌───────────┐ ┌───────────┐ │                               
  │           │ │           │ │           │       │           │ │           │ │           │                                 
│ │  ERT tile │ │Redis tile │ │MySQL tile │ │   │ │  ERT tile │ │Redis tile │ │MySQL tile │ │   1 params file per tile pipeline     
  │   params  │ │   params  │ │   params  │       │   params  │ │   params  │ │   params  │                                 
│ │           │ │           │ │           │ │   │ │           │ │           │ │           │ │                               
  └───────────┘ └───────────┘ └───────────┘       └───────────┘ └───────────┘ └───────────┘                                 
│ ┌───────────────────────────────────────┐ │   │ ┌───────────────────────────────────────┐ │                               
  │                                       │       │                                       │                                 
│ │        PCF foundation 1 params        │ │   │ │        PCF foundation 2 params        │ │   1 params file per foundation
  │           e.g. OpsMgr info            │       │           e.g. OpsMgr info            │                                 
│ │                                       │ │   │ │                                       │ │                               
  │                                       │       │                                       │                                 
│ └───────────────────────────────────────┘ │   │ └───────────────────────────────────────┘ │                               
  ┌───────────────────────────────────────────────────────────────────────────────────────┐                                 
│ │                                         │   │                                         │ │                               
  │          Global parameters                                                            │       1 params file for all     
│ │          e.g. PivNet token              │   │                                         │ │          foundations          
  │                                                                                       │                                 
│ │                                         │   │                                         │ │                               
  └───────────────────────────────────────────────────────────────────────────────────────┘                                 
│                                           │   │                                           │                               
 ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─     ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─                                
```

---

## Appendix B - Parameters Changes for v1.1.0 of the PKS Tile

- **Change:** PKS API Hostname. Replaced parameter `.properties.uaa_url` with `.properties.pks_api_hostname`.  

- **New feature**: Differentiated AZ placement and persistent disk type for Master and Worker nodes  
  Parameter changes:
  - For each active Plan, parameter `.properties.planX_selector.active.az_placement` was removed and two new parameters were added, one for Master nodes, one for Workers: `.properties.planX_selector.active.master_az_placement` and `.properties.planX_selector.active.worker_az_placement`.  
  - For each active plan, parameter `properties.planX_selector.active.persistent_disk_type` was replaced by `.properties.planX_selector.active.worker_persistent_disk_type`

- **New feature**: Support for AWS as a Kubernetes Cloud provider  
  New parameters added:  
  `.properties.cloud_provider.aws.aws_access_key_id_master`  
  `.properties.cloud_provider.aws.aws_secret_access_key_master`  
  `.properties.cloud_provider.aws.aws_access_key_id_worker`  
  `.properties.cloud_provider.aws.aws_secret_access_key_worker`  

- **New feature**: New NSX settings and corresponding pipeline parameters added to v1.1.  
  - Automated Network Provisioning: `.properties.network_selector.nsx.network_automation`  
  - NAT mode: `.properties.network_selector.nsx.nat_mode`
  - Nodes IP Block ID: `.properties.network_selector.nsx.nodes-ip-block-id`
  - Bosh Client Id: `.properties.network_selector.nsx.bosh-client-id`
  - Bosh Client secret: `.properties.network_selector.nsx.bosh-client-secret`
  - HTTP/HTTPS Proxy: `.properties.proxy_selector`, `.properties.proxy_selector.enabled.http_proxy_url`, `.properties.proxy_selector.enabled.http_proxy_credentials`,  `.properties.proxy_selector.enabled.no_proxy`  
  - Allow outbound internet access from Kubernetes cluster vms: `.properties.vm_extensions`  

- **New feature**: Configure your UAA user account store with either internal or external authentication mechanisms (LDAP) - parameter `.properties.uaa`  
  New parameters for LDAP support:  
  `.properties.uaa.ldap.url`  
  `.properties.uaa.ldap.credentials`  
  `.properties.uaa.ldap.search_base`  
  `.properties.uaa.ldap.search_filter`  
  `.properties.uaa.ldap.group_search_base`  
  `.properties.uaa.ldap.group_search_filter`  
  `.properties.uaa.ldap.server_ssl_cert`  
  `.properties.uaa.ldap.server_ssl_cert_alias`  
  `.properties.uaa.ldap.mail_attribute_name`  
  `.properties.uaa.ldap.email_domains`  
  `.properties.uaa.ldap.first_name_attribute`  
  `.properties.uaa.ldap.last_name_attribute`  
  `.properties.uaa.ldap.ldap_referrals`  

- **New feature**: Monitoring - Wavefront Integration  
  New parameters added:  
  `.properties.wavefront`  
  `.properties.wavefront.enabled.wavefront_api_url`  
  `.properties.wavefront.enabled.wavefront_token`  
  `.properties.wavefront.enabled.wavefront_alert_targets`  

- **New feature**: VMware vRealize Log Insight Integration  
  New parameters added:  
  `.properties.pks-vrli`  
  `.properties.pks-vrli.enabled.host`  
  `.properties.pks-vrli.enabled.use_ssl`  
  `.properties.pks-vrli.enabled.skip_cert_verify`  
  `.properties.pks-vrli.enabled.ca_cert`  
  `.properties.pks-vrli.enabled.rate_limit_msec`  

- **New feature**: Telemetry  
  New parameter added:  
  `.properties.telemetry_selector`  

---
