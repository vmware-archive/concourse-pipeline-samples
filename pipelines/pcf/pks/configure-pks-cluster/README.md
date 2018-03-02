# Create a PKS cluster

This sample pipeline implements jobs to create and delete a PKS cluster on a PCF+PKS environment using the `pks` CLI.

## How to use this pipeline

1) If you have CredHub or Vault integrated with Concourse, then update [`pks_create_cluster_params.sh`](pks_create_cluster_params.sh) with the required PKS credentials and then run the script to create all required secrets in your credentials management software.  
   Otherwise, update [params.yml](params.yml) with the all required parameters.

2) Create the pipeline in Concourse:   

   `fly -t <target> sp -p create-pks-cluster -c pipeline.yml -l params.yml`

3) Un-pause and run pipeline `create-pks-cluster` by manually triggering job `create-pks-cluster`


## For vSphere with NSX-V environments

A job to configure NSV-V Load Balancer with rules for the PKS cluster master node is provided under group tab "vSphere NSX-V LB setup".  

For that job to work correctly, appropriately fill out all vSphere- and NSXV-related parameters in the parameters file (or in `pks_create_cluster_params.sh` script for Concourse servers integrated with credential management systems).

After the PKS cluster gets created successfully, run job `configure-lb-pks-cluster-master-node` to configure the NSX-V load balancer.
