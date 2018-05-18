# How to create a remote concourse worker
1. Obtain the following information:
    1. Download the remote-worker-vsphere.yml in this folder
    1. From Concourse Deployment
        1. A private key for a public key in (tsa -> authorized_keys)
        1. A public key for (tsa -> host_key -> public_key)
        1. TSA host (your web address for concourse. external_url)
    1. vSphere details
        1. vcenter_ip # eg vsphere.company.com
        1. vcenter_user # administrator@domain
        1. vcenter_password # password
        1. vcenter_dc # Datacenter1
        1. vcenter_vms #concourse_worker_folder
        1. vcenter_templates #concourse_worker_template
        1. vcenter_ds # datastore1
        1. vcenter_disks # concourse_worker_disks
        1. vcenter_cluster # Cluster1
        1. vcenter_rp # RP1
        2. internal_ip # 192.168.1.11
        3. network_name # vwire-1
        4. internal_dns # 198.168.20.20
        5. internal_gw # 192.168.1.1
        6. internal_cidr # 192.168.1.1/24
    1. Worker Details
        1. external_worker_tags
    1. Release Versions
        1. Get latest from bosh.io
1. From an opsmgr or other jumpbox on the remote network , run bosh create-env with the variables gathered (see example command below)

Save creds.yml and state.json to a secure place.

# Example
```
bosh create-env \
   remote-worker-vsphere.yml \
   --state=state.json \
   --vars-store=creds.yml \
   -v hashed_password='use mkpasswd -s -m sha-512' \
   -v internal_cidr='192.168.10.0/26' \
   -v internal_gw=192.168.10.1 \
   -v internal_ip=192.168.10.60 \
   -v network_name=vwire-03 \
   -v vcenter_dc=Datacenter \
   -v vcenter_ds=a-xio \
   -v vcenter_ip=10.193.156.11 \
   -v vcenter_user=administrator@vsphere.local \
   -v vcenter_password='password' \
   -v vcenter_templates=concourse-worker-templates \
   -v vcenter_vms=concourse-vms \
   -v vcenter_disks=concourse-worker-disks \
   -v vcenter_cluster=Cluster-A \
   -v vcenter_rp=A-RP01 \
   -v internal_dns='[10.193.134.2]' \
   -v ntp_servers='[10.193.134.2]' \
   -v tsa_host=xx \
   -v tsa_host_public_key=xx \
   -v external_worker_tags='[c0lrp01]' \
   -v external_worker_private_key=xx \
   -v postgres_version=28 \
   -v postgres_sha1=c1fcec62cb9d2e95e3b191e3c91d238e2b9d23fa \
   -v concourse_version=3.13.0 \
   -v concourse_sha1=fb3bedc9f9bf2304449b90c86f6d624a6819d363 \
   -v garden_runc_version=1.13.1 \
   -v garden_runc_sha1=54cbb89cae1be0708aa056185671665d7f4b2a4f
```
