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

pynsxt_local routing create_router \
  -n $LOGICAL_ROUTER_NAME \
  -t $LOGICAL_ROUTER_TYPE \
  -ec $EDGE_CLUSTER_NAME \
  -t0 $T0_ROUTER_NAME \
  -tag "ncp/cluster=$PCF_FOUNDATION_NAME"
