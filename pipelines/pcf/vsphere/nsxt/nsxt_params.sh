#!/bin/bash

# set the path for the secrets below to be created in vault or credhub
export concourse_root_secrets_path="/concourse"
export concourse_team_name="team-name"
export concourse_pipeline_name="pcf-nsxt-config"

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
)

##
## PIPELINE LEVEL secrets (specific to the pipeline)
##
export pipeline_secrets=(

# NSX Manager Params
"nsx_manager_address"::"nsx-manager.abc.io"
"nsx_manager_username"::"admin"
"nsx_manager_password"::"mynsxpassword"

#Unique Name for this PCF install
"pcf_foundation_name"::"pcf-fd1"

# Names of NSX Components.  Used to connect switches and routers to already established NSX Components
"vlan_transport_zone"::"tz-vlan"
"overlay_transport_zone"::"tz-overlay"
"edge_cluster_name"::"edge-cluster-1"

# T0 router IP and mask
"t0_router_ip"::"1.2.3.2"
"t0_router_ip_mask"::"26"

# Static route where T0 router should send all traffic back to IaaS
"t0_next_hop_ip"::"1.2.3.1"

#Params for DNAT and SNAT rules created on the T) router
"ops_mgr_dnat_ip"::"1.2.3.150"
"infrastructure_network_snat_ip"::"1.2.3.151"

#Params to define a pool of IPs that will be used for dynamically created Organizations
"external_nat_ip_pool_cidr"::"1.2.3.0/24"
"external_nat_ip_pool_start_ip"::"1.2.3.100"
"external_nat_ip_pool_end_ip"::"1.2.3.119"
"vlan_uplink_switch_name"::"vlan-uplink"
"infrastructure_switch_name"::"infrastructure-ls"
"deployment_switch_name"::"deployment-ls"
"services_switch_name"::"services-ls"
"dynamic_services_switch_name"::"dynamic-services-ls"

"t0_router_name"::"t0-router"
"infrastructure_router_name"::"infrastructure-t1"
"deployment_router_name"::"deployment-t1"
"services_router_name"::"services-t1"
"dynamic_services_router_name"::"dynamic-services-t1"

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
