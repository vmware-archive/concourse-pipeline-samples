#!/bin/bash
set -eu

echo "Note - pre-requisite for this task to work:"
echo "- Your PKS API endpoint [api.$PKS_DOMAIN] should be routable and accessible from the Concourse worker(s) network."
echo "- See PKS tile documentation for configuration details for vSphere [https://docs.pivotal.io/runtimes/pks/1-0/installing-pks-vsphere.html#loadbalancer-pks-api] and GCP [https://docs.pivotal.io/runtimes/pks/1-0/installing-pks-gcp.html#loadbalancer-pks-api]"

echo "Retrieving PKS tile properties from Ops Manager [https://$OPSMAN_DOMAIN_OR_IP_ADDRESS]..."
# get PKS UAA admin credentails from OpsMgr
PRODUCTS=$(om-linux --target "https://$OPSMAN_DOMAIN_OR_IP_ADDRESS" --client-id "${OPSMAN_CLIENT_ID}" --client-secret "${OPSMAN_CLIENT_SECRET}" --username "$OPSMAN_USERNAME" --password "$OPSMAN_PASSWORD" --skip-ssl-validation curl -p /api/v0/staged/products)
PKS_GUID=$(echo "$PRODUCTS" | jq -r '.[] | .guid' | grep pivotal-container-service)
UAA_ADMIN_SECRET=$(om-linux --target "https://$OPSMAN_DOMAIN_OR_IP_ADDRESS" --client-id "${OPSMAN_CLIENT_ID}" --client-secret "${OPSMAN_CLIENT_SECRET}" --username "$OPSMAN_USERNAME" --password "$OPSMAN_PASSWORD" --skip-ssl-validation curl -p /api/v0/deployed/products/$PKS_GUID/credentials/.properties.uaa_admin_secret | jq -rc '.credential.value.secret')

echo "Connecting to PKS UAA server [api.<$PKS_DOMAIN>]..."
# login to PKS UAA
uaac target https://api.$PKS_DOMAIN:8443 --skip-ssl-validation
uaac token client get admin --secret $UAA_ADMIN_SECRET

echo "Creating PKS CLI administrator user per PK tile documentation https://docs.pivotal.io/runtimes/pks/1-0/manage-users.html#uaa-scopes"
# create pks admin user
uaac user add "$PKS_CLI_USERNAME" --emails "$PKS_CLI_USEREMAIL" -p "$PKS_CLI_PASSWORD"
uaac member add pks.clusters.admin "$PKS_CLI_USERNAME"

echo "PKS CLI administrator user [$PKS_CLI_USERNAME] successfully created."

echo "Next, download the PKS CLI from Pivotal Network and login to the PKS API to create a new K8s cluster [https://docs.pivotal.io/runtimes/pks/1-0/create-cluster.html]"
echo "Example: "
echo "   pks login -a api.$PKS_DOMAIN -u $PKS_CLI_USERNAME -p <pks-cli-password-provided>"
