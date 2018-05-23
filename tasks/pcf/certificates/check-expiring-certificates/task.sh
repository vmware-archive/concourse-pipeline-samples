#!/bin/bash
set -eu

main() {

  echo "Retrieving expiring certificates within ${EXPIRATION_TIME_FRAME} for ${OPSMAN_DOMAIN_OR_IP_ADDRESS}"
  om-linux \
    --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    curl \
    --path /api/v0/deployed/certificates?expires_within=${EXPIRATION_TIME_FRAME} > ./expiring_certs/expiring_certs.json
  echo "List of expiring certificates within ${EXPIRATION_TIME_FRAME}:"
  cat ./expiring_certs/expiring_certs.json

}

main
