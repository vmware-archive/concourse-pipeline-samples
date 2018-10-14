#!/bin/bash

set -eu

echo "Applying changes to ${PRODUCT_NAME} on Ops Manager @ ${OPSMAN_DOMAIN_OR_IP_ADDRESS}"

om-linux version

# Current version of om-linux available on the image-resourece does not have the om version with selective deploy.
# This is a hack to pull down the latest version
curl -sSL -o om-linux $(curl -s https://api.github.com/repos/pivotal-cf/om/releases/latest | jq -r -c ".assets[] | .browser_download_url" | grep linux) && chmod +x om-linux
./om-linux version

./om-linux \
  --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
  --skip-ssl-validation \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  apply-changes \
  --product-name "${PRODUCT_NAME}" \
  --ignore-warnings
