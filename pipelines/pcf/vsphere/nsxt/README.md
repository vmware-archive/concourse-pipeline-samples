# Configure NSX-T Components for use with PAS
This sample pipeline will setup switches, routers, an IP block, and an IP pool to be used by PAS. The tasks can be also be used to prepare NSX-T for use with PKS.

It requires routable IP addresses from your IaaS provider for the external IP pool, the Tier-0 router IP and the T0 uplink IP.

## How to use this pipeline

1) If you have CredHub or Vault integrated with Concourse, then update [`nsxt_params.sh`](nsxt_params.sh) with the required credentials and parameters and then run the script to create all required secrets in your credentials management software.  
   Otherwise, update [params.yml](params.yml) with the all required parameters.

2) Create the pipeline in Concourse:   

   `fly -t <target> sp -p pcf-nsxt-config -c pipeline.yml`

3) Un-pause and run pipeline `pcf-nsxt-config` by manually triggering job `create-logical-switches`
