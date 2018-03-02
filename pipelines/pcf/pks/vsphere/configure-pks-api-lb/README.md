# Configure NSX-V Load Balancer for PKS API endpoints

This sample pipeline configures an NSX-V Load Balancer for PKS API and UAA endpoints after the PKS tile has been successfully deployed to vSphere with NSX-V.

It requires a reserved IP address to be assigned as a VIP/Virtual Server for the UAA and API endpoints (parameter `nsxv_gen_vip_ip`).

## How to use this pipeline

1) If you have CredHub or Vault integrated with Concourse, then update [`pks_api_nsxv_lb_params.sh`](pks_api_nsxv_lb_params.sh) with the required credentials and then run the script to create all required secrets in your credentials management software.  
   Otherwise, update [params.yml](params.yml) with the all required parameters.

2) Create the pipeline in Concourse:   

   `fly -t <target> sp -p pks-api-config-nsxv -c pipeline.yml`

3) Un-pause and run pipeline `pks-api-config-nsxv` by manually triggering job `configure-lb-pks-application-profile`
