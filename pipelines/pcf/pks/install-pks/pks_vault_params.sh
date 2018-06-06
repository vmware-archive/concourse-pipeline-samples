#!/bin/bash

# set the path for the secrets below to be created in vault or credhub
concourse_secrets_path="/concourse/my-team-name/my-pipeline-name"

# VAULT or CREDHUB - targeted secrets management system
targeted_system="VAULT"

# This script assumes that:
# 1) the credhub or vault CLI is installed
# 2) you setup your vault or credhub target and login commands prior to invoking it
#    e.g. for VAULT
#    export VAULT_ADDR=https://myvaultdomain:8200
#    export VAULT_SKIP_VERIFY=true
#    export VAULT_TOKEN=vault-token
#
#    e.g. for CREDHUB
#    credhub login -s credhub-server-uri -u username -p password --skip-tls-validation

## UPDATE the secret entries below with the corresponding values for your PCF PKS environment

secrets=(
  # Pivotal Network token to download the tile release
  "pivnet_token"::"pivnet_token_goes_here"

  # The IaaS name for which stemcell to download. This must match the IaaS name
  # within the stemcell to download, e.g. "vsphere", "aws", "azure", "google" must be lowercase.
  "iaas_type"::"gcp"

  # ops manager domain or ip address
  "opsman_domain"::"opsmgr.domain.com"
  # Admin credentials for Ops Manager
  # Either opsman_client_id/opsman_client_secret or opsman_admin_username/opsman_admin_password needs to be specified.
  # If you are using opsman_admin_username/opsman_admin_password, edit opsman_client_id/opsman_client_secret to be an empty value.
  # If you are using opsman_client_id/opsman_client_secret, edit opsman_admin_username/opsman_admin_password to be an empty value.
  "opsman_admin_username"::"opsmgr-admin"
  "opsman_admin_password"::"opsmgr-password"
  "opsman_client_id"::""
  "opsman_client_secret"::""
  # domain for certificate generation when applicable, pks.mydomain.com
  "pcf_pks_domain"::"pks.domain.com"
  "pcf_pks_api_domain"::"api.pks.domain.com"

  # username for PKS CLI username creation
  "pks_cli_username"::"pksadmin"
  # password for PKS CLI username creation
  "pks_cli_password"::"mypassword"
  # required email for PKS CLI username creation
  "pks_cli_useremail"::"pksadmin@example.com"

  # network and availability zones assignments for PKS
  "az_1_name"::"us-central1-a"
  "az_2_name"::"us-central1-b"
  "az_3_name"::"us-central1-c"
  "services_network_name"::"pks-main"
  "dynamic_services_network_name"::"pks-services"

  ## for GCP deployments - ignore or remove entries if not applicable
  "gcp_project_id"::"gcp_project_id"
  "gcp_vpc_network"::"gcp_vpc_network"
  "gcp_service_key"::"gcp_service_key"

  ## for vSPHERE deployments - ignore or remove entries if not applicable
  # vcenter credentials and properties
  "vcenter_username"::"myvcenteruser@vsphere.local"
  "vcenter_password"::"myvcenterpassword"
  # vcenter hostname, do not include protocol information
  "vcenter_host"::"vcenter.domain.com"
  "vcenter_datacenter"::"Datacenter"
  "vcenter_datastore"::"mydatastore"
  # The pcf folder name should be the same as the VM Folder in the Ops Manager Director tile, under the vCenter config page.
  "vcenter_pcf_folder"::"pcf_vms"

  # for NSX-t deployments - ignore or remove entries if not applicable
  "nsxt_hostname_or_ipaddress"::"10.10.10.10"
  "nsxt_admin_username"::"nsxt_admin_username_goes_here"
  "nsxt_admin_password"::"nsxt_admin_password_goes_here"
  "nsxt_vcenter_cluster"::"cluster-name"
  "nsxt_t0_routerid"::"nsxt_t0_routerid_goes_here"
  "nxst_ip_block_id"::"nxst_ip_block_id_goes_here"
  "nsxt_floating_ip_pool_id":"nsxt_floating_ip_pool_id_goes_here"

)

for i in "${secrets[@]}"
do
  KEY="${i%%::*}"
  VALUE="${i##*::}"
  echo "Creating secret for [$KEY]"
  if [[ $targeted_system == "VAULT" ]]; then
    vault write "${concourse_secrets_path}/${KEY}" value="${VALUE}"
  else   # CREDHUB
    credhub set -n "${concourse_secrets_path}/${KEY}" -v "${VALUE}"
  fi
done

cat << EOF > gcp_service_account.json
{
  "type": "service_account",
  "client_x509_cert_url": "..."
}
EOF

certs=(
  # Optional PEM-encoded certificates to add to BOSH director
  "gcp_service_key"::"gcp_service_account.json"
)

for i in "${certs[@]}"
do
  KEY="${i%%::*}"
  CERT_FILE="${i##*::}"
  echo "Creating certificate secret for [$KEY]"
  if [[ $targeted_system == "VAULT" ]]; then
    cat "$CERT_FILE" | vault write "${concourse_secrets_path}/${KEY}" value=-
  # else   # CREDHUB
    # credhub set -n "${concourse_secrets_path}/${KEY}" -v "${VALUE}"
  fi
done
