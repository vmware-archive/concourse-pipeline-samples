<img src="https://pivotal.gallerycdn.vsassets.io/extensions/pivotal/vscode-concourse/0.1.3/1517353139519/Microsoft.VisualStudio.Services.Icons.Default" alt="Concourse" height="70"/>&nbsp;&nbsp;<img src="https://cdn-images-1.medium.com/max/1600/1*wcGVRmWde2zYZCrnt3vwjw.png" alt="Harbor" height="70"/>

# Install VMWare Harbor tile pipeline

This pipeline installs the [VMWare Harbor Container Registry](https://network.pivotal.io/products/harbor-container-registry/) tile on top of an existing PCF Ops Manager deployment.

The parameters file of this pipeline implements the concept of "externalized tile parameters", where all the available tile configuration options are fed to the pipeline tasks as a YAML object containing the parameter names expected by Ops Manager for the tile.

For example:
```
properties: |

  ######## General
  ### The FQDN (not IP) of Harbor instance. Its domain must match the wildcard domain used for generating Harbor certificate.
  .properties.hostname:
    value: ((harbor_hostname))
```

This approach allows for the `configure-tile` task of this pipeline to be generic and *tile-agnostic*, by delegating the tile configuration options to the content of the main three parameters `networks`, `properties` and `resources`.

---

## How to use this pipeline

1) Update [`harbor_params.yml`](harbor_params.yml) by following the instructions in the file.  
   The order of tile parameters in that file follows the same order as parameters are presented in Ops Manager and in the [tile documentation](https://docs.pivotal.io/partners/vmware-harbor/installing.html#configure).  

    If you use `Vault` or `CredHub` for credentials management, you can use the provided script [`harbor_vault_params.sh`](harbor_vault_params.sh) to automatically create the pipeline secrets in those systems.

    Also, note that the pipeline can automatically generate certificates for the Harbor server. See more details in comments for parameter  `.properties.server_cert_key` in [`harbor_params.yml`](harbor_params.yml).  


2) Update [`pcf_params.yml`](pcf_params.yml) by following the instructions in the file.  

   This parameter file contains information about the PCF foundation (e.g. Ops Manager and Director) to which the tile will be deployed to.  

   This parameters file is separate from the others for reuse purposes, since any other PCF tile install or upgrade pipeline will use the same properties. If you already have this type of file created for another PCF tile pipeline, you can reuse it here.

3) Update [`global_params.yml`](global_params.yml) by following the instructions in the file.  

  This parameter file contains information about global properties that typically apply to any PCF pipeline (e.g. Pivotal Network token).  

  This parameters file is separate from the others for reuse purposes, since any other PCF tile install or upgrade pipeline will use the same properties. If you already have this type of file created for another PCF tile pipeline, you can reuse it here.

4) Create the pipeline in Concourse:  

   `fly -t <target> set-pipeline -p install-harbor -c pipeline.yml -l global_params.yml -l pcf_params.yml -l harbor_params.yml`

5) Un-pause and run pipeline `install-harbor`
