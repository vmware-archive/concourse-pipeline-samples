#!/bin/bash

# set the path for the secrets below to be created in vault or credhub
concourse_secrets_path="/concourse/team-name/pks-api-config-nsxv"

# VAULT or CREDHUB - targeted secrets management system
targeted_system="VAULT"
action="CREATE"   ## CREATE or DELETE

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
  # domain for certificate generation when applicable, pks.mydomain.com
  "pcf_pks_domain"::"pks.domain.com"
  "pcf_pks_api"::"api.pks.domain.com"
  # username for PKS CLI username creation
  "pks_cli_username"::"pksadmin"
  # password for PKS CLI username creation
  "pks_cli_password"::"mypassword"
  # required email for PKS CLI username creation
  "pks_cli_useremail"::"pksadmin@example.com"
  "pks_api_cert_cn"::"*.domain.com"

  # ops manager domain or ip address
  "opsman_domain_or_ip_address"::"opsmgr.domain.com"
  # Admin credentials for Ops Manager
  # Either opsman_client_id/opsman_client_secret or opsman_admin_username/opsman_admin_password needs to be specified.
  # If you are using opsman_admin_username/opsman_admin_password, edit opsman_client_id/opsman_client_secret to be an empty value.
  # If you are using opsman_client_id/opsman_client_secret, edit opsman_admin_username/opsman_admin_password to be an empty value.
  "opsman_admin_username"::"opsmgr-admin"
  "opsman_admin_password"::"opsmgr-password"
  "opsman_client_id"::""
  "opsman_client_secret"::""

  # vcenter hostname, do not include protocol information
  "vcenter_host"::"vcenter.domain.com"
  # vcenter credentials and properties
  "vcenter_usr"::"myvcenteruser@vsphere.local"
  "vcenter_pwd"::"myvcenterpassword"
  "vcenter_datacenter"::"Datacenter"
  "vcenter_datastore"::"mydatastore"

  "nsxv_manager_address"::"mynsxv.domain.com"
  "nsxv_manager_admin_username"::"admin"
  "nsxv_manager_admin_password"::"password"
  "nsxv_gen_edge_name"::"nsxv_gen_edge_name"
  "nsxv_gen_edge_cluster"::"Cluster-A"
  "nsxv_gen_mgr_transport_zone"::"nsxv_gen_mgr_transport_zone"
  "nsxv_gen_vip_ip"::"nsxv_gen_vip_ip"

)

for i in "${secrets[@]}"
do
  KEY="${i%%::*}"
  VALUE="${i##*::}"
  echo "Processing secret for [$KEY]"
  if [[ $targeted_system == "VAULT" ]]; then
    if [[ $action == "DELETE" ]]; then
      vault delete "${concourse_secrets_path}/${KEY}"
    else
      vault write "${concourse_secrets_path}/${KEY}" value="${VALUE}"
    fi
  else   # CREDHUB
    credhub set -n "${concourse_secrets_path}/${KEY}" -v "${VALUE}"
  fi
done
