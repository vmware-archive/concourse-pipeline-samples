#!/bin/bash -eu

echo "Destroying edge"

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
edge_datastore =  $NSX_EDGE_GEN_EDGE_DATASTORE
edge_cluster = $NSX_EDGE_GEN_EDGE_CLUSTER
EOF

pynsxv_local() {
  /opt/pynsxv/cli.py "$@"
  return $?
}

get_cidr() {
  IP=$1
  MASK=$2
  FIRST_THREE=$(echo $IP|cut -d. -f 1,2,3)
  echo "$FIRST_THREE.0/$MASK"
}

if [ $NUM_LOGICAL_SWITCHES -gt 9 -o $NUM_LOGICAL_SWITCHES -lt 1 ]
then
  echo 'Number must be between 1 and 9'
  exit 1
fi

# Create an edge
pynsxv_local esg delete -n $NSX_EDGE_GEN_NAME

# Create logical switches
for labwire_id in $(seq $NUM_LOGICAL_SWITCHES); do
  pynsxv_local lswitch -n "labwire-$NSX_EDGE_GEN_NAME-$OWNER_NAME-$labwire_id" delete
done
