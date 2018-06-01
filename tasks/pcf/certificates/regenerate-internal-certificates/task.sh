#!/bin/bash
set -eu

# This task will invoke the regenerate non-certificates API endpoint from Ops Manager
# PCF Documentation: https://docs.pivotal.io/pivotalcf/security/pcf-infrastructure/api-cert-rotation.html

main() {

  echo "Rotating non-configurable certificates for ${OPSMAN_DOMAIN_OR_IP_ADDRESS}..."
  om-linux \
    --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    curl \
    --path /api/v0/certificate_authorities/active/regenerate \
    --request POST

}

main
