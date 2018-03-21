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

pynsxt_local routing create_static_route \
  -lr $LOGICAL_ROUTER_NAME \
  -network "$STATIC_ROUTE_NETWORK" \
  -next_hop $NEXT_HOP
