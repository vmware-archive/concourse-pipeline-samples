# Configure NSX-V Load Balancer for HARBOR API endpoints

This sample pipeline configures an NSX-V Load Balancer for the Harbor API endpoints after the Harbor tile has been successfully deployed on top of an Ops Manager environment.

It requires a reserved IP address to be assigned as a VIP/Virtual Server (parameter `nsxv_gen_vip_ip`).

## How to use this pipeline

1) If you have CredHub or Vault integrated with Concourse, then update [`harbor_api_nsxv_lb_params.sh`](harbor_api_nsxv_lb_params.sh) with the required credentials and then run the script to create all required secrets in your credentials management software.  
   Otherwise, update [params.yml](params.yml) with the all required parameters.

2) Create the pipeline in Concourse:   

   `fly -t <target> sp -p harbor-api-config-nsxv -c pipeline.yml`

3) Un-pause and run pipeline `harbor-api-config-nsxv` by manually triggering job `configure-lb-api-application-profile`
