#!/bin/bash -eu

cat << EOF > /opt/pynsxt/nsx.ini
[nsxv]
nsx_manager = https://$NSX_MANAGER_ADDRESS/api/v1
nsx_username = $NSX_MANAGER_USERNAME
nsx_password = $NSX_MANAGER_PASSWORD

EOF

pushd /opt/pynsxt

pynsxt_local() {
  python /opt/pynsxt/cli.py "$@"
}

pynsxt_local pool create_ip_pool \
  -n $IP_POOL_NAME \
  -s $IP_POOL_START_IP \
  -e $IP_POOL_END_IP \
  -c $IP_POOL_CIDR \
  -tag "ncp/cluster=$PCF_FOUNDATION_NAME" \
  -external $EXTERNAL
