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
  # SSH password for Ops Manager (ssh user is ubuntu)
  "opsman_ssh_password"::""
  # Decryption password for Ops Manager exported settings
  "om_decryption_pwd"::""
  # DNS servers
  "om_dns_servers"::""
  # Gateway for Ops Manager network
  "om_gateway"::""
  # IP to assign to Ops Manager VM (for proxy env and for wipe-env job)
  "om_ip"::""
  # Netmask for Ops Manager network
  "om_netmask"::""
  # Comma-separated list of NTP Servers
  "om_ntp_servers"::""
  # vCenter Cluster or Resource Pool to use to deploy Ops Manager.
  # Possible formats:
  #   cluster:       /<Data Center Name>/host/<Cluster Name>
  #   resource pool: /<Data Center Name>/host/<Cluster Name>/Resources/<Resource Pool Name>
  "om_resource_pool"::""
  # Optional - vCenter folder to put Ops Manager in
  "om_vm_folder"::""
  # Optional - vCenter host to deploy Ops Manager in
  "om_vm_host"::""
  # Name to use for Ops Manager VM
  "om_vm_name"::""
  # vCenter network name to use to deploy Ops Manager in
  "om_vm_network"::""
  # no_proxy config
  "company_proxy_domain"::""
  # Disk type for Ops Manager VM (thick|thin)
  "opsman_disk_type"::""

  # Optional DNS name for Ops Director. Should be reachable from all networks.
  "ops_dir_hostname"::""
  # Comma-separated list of NTP servers to use for VMs deployed by BOSH
  "ntp_servers"::""

  # domain for certificate generation when applicable, pks.mydomain.com

  ## for vSPHERE deployments - ignore or remove entries if not applicable
  # vcenter credentials and properties
  "vcenter_usr"::"myvcenteruser@vsphere.local"
  "vcenter_pwd"::"myvcenterpassword"
  # vcenter hostname, do not include protocol information
  "vcenter_host"::"vcenter.domain.com"
  "vcenter_datacenter"::"Datacenter"
  "vcenter_datastore"::"mydatastore"
  "vcenter_insecure"::"true"
  # Disk type for BOSH provisioned VM. (thick|thin)
  "vm_disk_type"::"thin"
  # Ephemeral Storage names in vCenter for use by PCF
  "ephemeral_storage_names"::"a-xio, b-xio, c-xio"
  # Persistent Storage names in vCenter for use by PCF
  "persistent_storage_names"::"a-xio, b-xio, c-xio"

  # # AZ configuration for Ops Director
  # cluster name for AZ01
  "az_1_cluster_name"::""
  # resource pool name for AZ01
  "az_1_rp_name"::""
  # cluster name for AZ02
  "az_2_cluster_name"::""
  # resource pool name for AZ02
  "az_2_rp_name"::""
  # cluster name for AZ03
  "az_3_cluster_name"::""
  # resource pool name for AZ03
  "az_3_rp_name"::""

  # vSphere datastore folder (such as pcf_disk) where attached disk images will be created
  "bosh_disk_path"::"pcf_disk"
  # vSphere datacenter folder (such as pcf_templates) where templates will be placed
  "bosh_template_folder"::"pcf_templates"
  # vSphere datacenter folder (such as pcf_vms) where VMs will be placed
  "bosh_vm_folder"::"pcf_vms"

  # CredHub encryption secret 1
  "credhub_encryption_key_1"::"thequickbrownfoxjumpsoverthelazydog"
  # CredHub encryption secret 1
  "credhub_encryption_key_2"::"thefiveboxingwizardsjumpquickly"


  # Infrastructure Configuration
  "infra_vsphere_network"::""
  "infra_nw_cidr"::""
  "infra_excluded_range"::""
  "infra_nw_dns"::""
  "infra_nw_gateway"::""

  # Services network
  "services_vsphere_network"::""
  "services_nw_cidr"::""
  "services_excluded_range"::""
  "services_nw_dns"::""
  "services_nw_gateway"::""

  # Deployment
  "deployment_vsphere_network"::""
  "deployment_nw_cidr"::""
  "deployment_excluded_range"::""
  "deployment_nw_dns"::""
  "deployment_nw_gateway"::""

  # Dynamic Services Network
  "dynamic_services_vsphere_network"::""
  "dynamic_services_nw_cidr"::""
  "dynamic_services_excluded_range"::""
  "dynamic_services_nw_dns"::""
  "dynamic_services_nw_gateway"::""


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

cat << EOF > om_ca.crt
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
EOF

cat << EOF > vcenter_ca.crt
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
EOF

certs=(
  # Optional PEM-encoded certificates to add to BOSH director
  "trusted_certificates"::"om_ca.crt"
  "vcenter_ca_cert"::"vcenter_ca.crt"
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
