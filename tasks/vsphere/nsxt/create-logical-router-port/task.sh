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

pynsxt_local routing create_router_port \
  -n $LOGICAL_ROUTER_PORT_NAME \
  -rpt $LOGICAL_ROUTER_PORT_TYPE \
  -ls $LOGICAL_SWITCH_NAME \
  -lr $LOGICAL_ROUTER_NAME \
  -ip $LOGICAL_ROUTER_PORT_IP \
  -mask $LOGICAL_ROUTER_PORT_IP_MASK
