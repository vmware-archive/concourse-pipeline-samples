#!/bin/bash -eu

cat << EOF > /opt/pynsxt/nsx.ini
[nsxv]
nsx_manager = https://$NSX_MANAGER_ADDRESS/api/v1
nsx_username = $NSX_MANAGER_USERNAME
nsx_password = $NSX_MANAGER_PASSWORD

[pcf]
pcf_foundation = $PCF_FOUNDATION_NAME

EOF

pushd /opt/pynsxt

pynsxt_local() {
  python /opt/pynsxt/cli.py "$@"
}

pynsxt_local pool create_ip_block \
  -n $IP_BLOCK_NAME \
  -c "$IP_BLOCK_CIDR"
