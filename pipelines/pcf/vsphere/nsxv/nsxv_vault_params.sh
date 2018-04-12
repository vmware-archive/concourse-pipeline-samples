#!/bin/bash

# set the path for the secrets below to be created in vault or credhub
concourse_secrets_path="/concourse/team-name/pipeline-name"

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

  ## for vSPHERE deployments - ignore or remove entries if not applicable
  # vcenter credentials and properties
  "vcenter_usr"::"myvcenteruser@vsphere.local"
  "vcenter_pwd"::"myvcenterpassword"
  # vcenter hostname, do not include protocol information
  "vcenter_host"::"vcenter.domain.com"
  "vcenter_datacenter"::"Datacenter"
  "vcenter_datastore"::"mydatastore"

  "nsx_owner_name"::"owner_org_name"
  "nsxv_manager_address"::"mynsxv.domain.com"
  "nsxv_manager_admin_username"::"admin"
  "nsxv_manager_admin_password"::"password"
  "nsxv_gen_edge_name"::"nsxv_gen_edge_name"
  "nsxv_gen_edge_cluster"::"A-RPNSX"
  "nsxv_gen_mgr_transport_zone"::"tz-01"

  "num_logical_switches"::"5"
  "esg_default_uplink_ip_1"::"10.10.10.10"
  "esg_default_uplink_secondary_ips"::"10.10.10.11,10.10.10.12,10.10.10.13,10.10.10.14,10.10.10.15,10.10.10.16,10.10.10.17"
  "esg_default_uplink_pg_1"::"default_uplink_port_group_id"
  "esg_go_router_uplink_ip_1"::"10.10.10.13"
  "esg_snat_uplink_ip_1"::"10.10.10.12"
  "esg_opsmgr_uplink_ip_1"::"10.10.10.11"
  "nsx_edge_gen_nsx_manager_transport_zone_clusters"::"Cluster-A,Cluster-B,Cluster-C"
  # Certificate CN - has to match the CN in ssl_cert, including asterisks when applicable
  "ssl_cert_cn"::"my.domain.com"

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

cat << EOF > ssl_cert.crt
-----BEGIN -----
...
-----END -----
EOF

cat << EOF > ssl_private_key.pem
-----BEGIN -----
...
-----END -----
EOF

cat << EOF > git_private_key.pem
-----BEGIN -----
...
-----END -----
EOF

certs=(
  # Optional PEM-encoded certificates to add to BOSH director
  "ssl_cert"::"ssl_cert.crt"
  "ssl_private_key"::"ssl_private_key.pem"
  "git_private_key"::"git_private_key.pem"
)

for i in "${certs[@]}"
do
  KEY="${i%%::*}"
  CERT_FILE="${i##*::}"
  echo "Creating certificate secret for [$KEY]"
  if [[ $targeted_system == "VAULT" ]]; then
    cat "$CERT_FILE" | vault write "${concourse_secrets_path}/${KEY}" value=-
  # else   # CREDHUB - TBE
    # credhub set -n "${concourse_secrets_path}/${KEY}" -v "${VALUE}"
  fi
done
