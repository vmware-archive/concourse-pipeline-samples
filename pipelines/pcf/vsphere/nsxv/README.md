# Configure NSX-V Components for use with PAS
This sample pipeline will setup switches and an ESG ready to be used with PAS.

## How to use this pipeline

1) If you have CredHub or Vault integrated with Concourse, then update [`nsxv_valut_params.sh`](nsxv_vault_params.sh) with the required credentials and parameters and then run the script to create all required secrets in your credentials management software.  
   Otherwise, update [params.yml](params.yml) with the all required parameters.

2) Create the pipeline in Concourse:   

   `fly -t <target> sp -p pcf-nsxv-config -c pipeline.yml -l params.yml`

3) Un-pause and run pipeline `pcf-nsxv-config` by manually triggering job `create-edge`
