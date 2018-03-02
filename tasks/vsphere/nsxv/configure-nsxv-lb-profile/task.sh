#!/bin/bash
set -eu

main() {

  cat << EOF > nsx.ini
[nsxv]
nsx_manager = $NSX_EDGE_GEN_NSX_MANAGER_ADDRESS
nsx_username = $NSX_EDGE_GEN_NSX_MANAGER_ADMIN_USER
nsx_password = $NSX_EDGE_GEN_NSX_MANAGER_ADMIN_PASSWD
[vcenter]
vcenter = $VCENTER_HOST
vcenter_user = $VCENTER_USR
vcenter_passwd = $VCENTER_PWD
[defaults]
transport_zone = $NSX_EDGE_GEN_NSX_MANAGER_TRANSPORT_ZONE
datacenter_name = $VCENTER_DATA_CENTER
edge_datastore = $NSX_EDGE_GEN_EDGE_DATASTORE
edge_cluster = $NSX_EDGE_GEN_EDGE_CLUSTER
EOF

  # Create lb app profile if needed
  pynsxvg lb add_profile \
    -n $NSX_EDGE_GEN_NAME \
    --profile_name $NSX_EDGE_GEN_PROFILE_NAME \
    --protocol $NSX_EDGE_GEN_PROFILE_PROTOCOL \
    -x $NSX_EDGE_GEN_X_FORWARDED_FOR \
    --ssl_passthrough $NSX_EDGE_GEN_SSL_PASSTHROUGH \
    -cert "$NSX_EDGE_GEN_PROFILE_CERT_CN"

}

pynsxvg () {
   /opt/pynsxv/cli.py "$@"
}

main
