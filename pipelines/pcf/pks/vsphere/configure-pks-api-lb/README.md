# Configure NSX-V Load Balancer for PKS

**Experimental - Work in progress**

This sample pipeline configures an NSX-V Load Balancer for PKS API and UAA endpoints after the PKS tile has been successfully deployed to vSphere with NSX-V.

It requires a Concourse server with credentials management integration setup (either Vault or CredHub).

## How to use this pipeline

1) Update [`pks_api_nsxv_lb_params.sh`](pks_api_nsxv_lb_params.sh) with the required PKS, Ops Mgr and NSXV credentials and then run the script to create all required secrets in your credentials management software (e.g. Vault or CredHub).  

2) Create the pipeline in Concourse:   

   `fly -t <target> sp -p pks-api-config-nsxv -c pipeline.yml`

3) Un-pause and run pipeline `pks-api-config-nsxv`
