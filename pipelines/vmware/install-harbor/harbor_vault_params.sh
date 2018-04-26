#!/bin/bash

# set the path for the secrets below to be created in vault or credhub
export concourse_root_secrets_path="/concourse"
export concourse_team_name="my-team-name"
export concourse_pipeline_name="install-harbor"

# VAULT or CREDHUB - targeted secrets management system
export targeted_system="VAULT"
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

##
## TEAM level secrets (shared by all pipelines in that team)
##
export team_secrets=(
  # Pivotal Network token to download the tile release
  "pivnet_token"::"pivnet_token_goes_here"

  # The IaaS name for which stemcell to download. This must match the IaaS name
  # within the stemcell to download, e.g. "vsphere", "aws", "azure", "google" must be lowercase.
  "iaas_type"::"vsphere"

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

  # network and availability zones assignments for PKS
  "az_1_name"::"AZ01"
  "az_2_name"::"AZ02"
  "az_3_name"::"AZ03"
  "services_network_name"::"SERVICES"
  "dynamic_services_network_name"::"DYNAMIC-SERVICES"

)

##
## PIPELINE LEVEL secrets (specific to the pipeline)
##
export pipeline_secrets=(
  "harbor_hostname"::"fqdn_of_harbor_host"
  "harbor_domain"::"harbor_domain_for_certificate_creation"
  "harbor_admin_password"::"harbor_admin_password"

  "ldap_auth_url"::"ldap_auth_url"
  "ldap_auth_verify_cert"::"true"
  "ldap_auth_searchdn"::"ldap_auth_searchdn"
  "ldap_auth_searchpwd"::"ldap_auth_searchpwd"
  "ldap_auth_basedn"::"ldap_auth_basedn"
  "ldap_auth_uid"::"ldap_auth_uid"
  "ldap_auth_filter"::"ldap_auth_filter"
  "ldap_auth_scope"::"2"
  "ldap_auth_timeout"::"5"

  "s3_registry_storage_access_key"::"s3_registry_storage_access_key"
  "s3_registry_storage_secret_key"::"s3_registry_storage_secret_key"
  "s3_registry_storage_region"::"us-west-1"
  "s3_registry_storage_endpoint_url"::"s3_registry_storage_endpoint_url"
  "s3_registry_storage_bucket"::"s3_registry_storage_bucket"
  "s3_registry_storage_root_directory"::"s3_registry_storage_root_directory"

)

main () {

  # team level secrets
  concourse_team_level_secrets_path="${concourse_root_secrets_path}/${concourse_team_name}"
  writeCredentials "${concourse_team_level_secrets_path}" "${team_secrets[*]}"

  # pipeline level secrets
  concourse_pipeline_level_secrets_path="${concourse_team_level_secrets_path}/${concourse_pipeline_name}"
  writeCredentials "${concourse_pipeline_level_secrets_path}" "${pipeline_secrets[*]}"

}

writeCredentials () {
  secretsPath=${1}
  secretsObject=(${2})

  for i in "${secretsObject[@]}"
  do
    KEY="${i%%::*}"
    VALUE="${i##*::}"
    echo "Creating secret for [$KEY]"
    if [[ $targeted_system == "VAULT" ]]; then
      vault write "${secretsPath}/${KEY}" value="${VALUE}"
    else   # CREDHUB
      credhub set -n "${secretsPath}/${KEY}" -v "${VALUE}"
    fi
  done
}

main
