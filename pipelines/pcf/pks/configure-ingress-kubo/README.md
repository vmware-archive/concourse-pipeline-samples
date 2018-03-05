# Configure ingress-kubo load balancer to PKS cluster

This sample pipeline implements jobs to configure the [`ingress-kubo-poc`](https://github.com/datianshi/ingress-kubo-poc) services load balancer to an existing PKS cluster.

## How to use this pipeline

1) If you have CredHub or Vault integrated with Concourse, then update [`pks_configure_ingress_kubo_params.sh`](pks_configure_ingress_kubo_params.sh) with the required PKS credentials and then run the script to create all required secrets in your credentials management software.  
   Otherwise, update [params.yml](params.yml) with the all required parameters.

2) Create the pipeline in Concourse:   

   `fly -t <target> sp -p configure-ingress-kubo -c pipeline.yml -l params.yml`

3) Un-pause and run pipeline `configure-ingress-kubo` by manually triggering job `install-ingress-kubo`


## For vSphere with NSX-V environments

A job to configure NSV-V Load Balancer with rules for the PKS cluster master node is provided under group tab "vSphere NSX-V LB setup".  

For that job to work correctly, appropriately fill out all vSphere- and NSXV-related parameters in the parameters file (or in `pks_configure_ingress_kubo_params.sh` script for Concourse servers integrated with credential management systems).

After the PKS cluster gets created successfully, run job `configure-vsphere-nxsv-lb-ingress-kubo` to configure the NSX-V load balancer.
