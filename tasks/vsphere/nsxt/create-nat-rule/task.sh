#!/bin/bash -eu

cat << EOF > /opt/pynsxt/nsx.ini
[nsxv]
nsx_manager = https://$NSX_MANAGER_ADDRESS/api/v1
nsx_username = $NSX_MANAGER_USERNAME
nsx_password = $NSX_MANAGER_PASSWORD

[pcf]
pcf_foundation = $PCF_FOUNDATION_NAME

EOF

# /usr/bin/python setup.py install --user

pynsxt_local() {
  python /opt/pynsxt/cli.py "$@"
}

pynsxt_local routing create_nat_rule \
  -lr $LOGICAL_ROUTER_NAME \
  -a $NAT_TYPE \
  -oip $ORIGINAL_IP \
  -tip $TRANSLATED_IP \
