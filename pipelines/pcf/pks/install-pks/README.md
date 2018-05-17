<img src="https://pivotal.gallerycdn.vsassets.io/extensions/pivotal/vscode-concourse/0.1.3/1517353139519/Microsoft.VisualStudio.Services.Icons.Default" alt="Concourse" height="70"/>&nbsp;&nbsp;<img src="https://dtb5pzswcit1e.cloudfront.net/assets/images/product_logos/icon_pivotalcontainerservice@2x.png" alt="PCF Knowledge Depot" height="70"/>

# Install PKS pipeline

This pipeline installs the PKS tile (v1.0.3+) on top of an existing PCF Ops Manager deployment.

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


**Note:** *This pipeline provides a job (`update-director-config`) that enables BOSH Director's
post deploy scripts configuration. The reason: the PKS 1.0.0 tile does not deploy Kubernetes addons such as kube-dns, heapster, the dashboard and influxdb when you create a PKS cluster unless post deploy is enabled on the Director."*


---

## How to use this pipeline

1) Update [`pks_params.yml`](pks_params.yml) by following the instructions in the file.  
   The order of tile parameters in that file follows the same order as parameters are presented in Ops Manager and in the tile documentation ([vSphere](https://docs.pivotal.io/runtimes/pks/1-0/installing-pks-vsphere.html) or [GCP](https://docs.pivotal.io/runtimes/pks/1-0/installing-pks-gcp.html)).  

    If you use `Vault` or `CredHub` for credentials management, you can use the provided script [`pks_vault_params.sh`](pks_vault_params.sh) to automatically create the pipeline secrets in those systems.

    Also, note that the pipeline can automatically generate certificates for the PKS API. See more details in comments for parameter  `.pivotal-container-service.pks_tls` in [`pks_params.yml`](pks_params.yml).  


2) Update [`pcf_params.yml`](pcf_params.yml) by following the instructions in the file.  

   This parameter file contains information about the PCF foundation (e.g. Ops Manager and Director) to which the tile will be deployed to.  

   This parameters file is separate from the others for reuse purposes, since any other PCF tile install or upgrade pipeline will use the same properties. If you already have this type of file created for another PCF tile pipeline, you can reuse it here. See [`Appendix A`](#appendix-a---pcf-pipelines-parameter-files-tiers) section below for a sample diagram of this parameters files structure pattern.

3) Update [`global_params.yml`](global_params.yml) by following the instructions in the file.  

  This parameter file contains information about global properties that typically apply to any PCF pipeline (e.g. Pivotal Network token).  

  This parameters file is separate from the others for reuse purposes, since any other PCF tile install or upgrade pipeline will use the same properties. If you already have this type of file created for another PCF tile pipeline, you can reuse it here. See [`Appendix A`](#appendix-a---pcf-pipelines-parameter-files-tiers) section below for a sample diagram of this parameters files structure pattern.

4) Create the pipeline in Concourse:  

   `fly -t <target> set-pipeline -p install-pks -c pipeline.yml -l global_params.yml -l pcf_params.yml -l pks_params.yml`

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
