#!/bin/bash
set -eu

# This task will retrieve certificates from Ops Mgr API endpoints

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
    --path /api/v0/deployed/certificates?expires_within=${EXPIRATION_TIME_FRAME} 2>/dev/null > ./expiring_certs.json

  # get expiring configurable certs
  cat ./expiring_certs.json | jq '.certificates[] | select(.configurable==true)' | jq --slurp .  > ./expiring_certs/expiring_configurable_certs.json

  # get expiring non-configurable certs
  cat ./expiring_certs.json | jq '.certificates[] | select(.configurable==false)' | jq --slurp . > ./expiring_certs/expiring_non_configurable_certs.json

  # check CA certs expiration
  om-linux \
    --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    curl \
    --path /api/v0/certificate_authorities 2>/dev/null  > ./ca_certs.json

  # get expiration_date and compare it with EXPIRATION_TIME_FRAME
  date_delta=$(echo ${EXPIRATION_TIME_FRAME} | sed -e 's/w/ week/;s/m/ month/;s/y/ year/;s/d/ day/')
  limit_date=$(date --date="+${date_delta}" +"%Y-%m-%dT%H:%M:%SZ")

  cat ./ca_certs.json | jq --arg limit_date "$limit_date" '.certificate_authorities[] | select(.expires_on<$limit_date)' | jq --slurp .  > ./expiring_certs/expiring_ca_certs.json

  # Bosh Director Trusted certs
  om-linux \
    --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    curl \
    --path /api/v0/staged/director/properties 2>/dev/null  > ./director_properties.json

  touch ./expiring_certs/expiring_director_trusted_certs.pem
  cat ./director_properties.json | jq -rc '.security_configuration.trusted_certificates' > ./director_trusted_certs.pem
  csplit -s -k -f dir_tcerts director_trusted_certs.pem '/END CERTIFICATE-----/+1' {*} 2>/dev/null

  for filename in ./dir_tcerts*; do
    sed -i '/^\s*$/d' $filename    # elimininate empty lines
    if [[ -s $filename ]]; then
      dtcert_expDate=$(openssl x509 -enddate -noout -in $filename | sed -e 's/notAfter=//')
      formatted_dtcert_date=$(date --date="+${dtcert_expDate}" +"%Y-%m-%dT%H:%M:%SZ")
      if [[ "$formatted_dtcert_date" < "$limit_date" ]]; then
         cat $filename >> ./expiring_certs/expiring_director_trusted_certs.pem
      fi
    fi
  done

  # Ops Mgr Root CA
  om-linux \
    --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    curl \
    --path /download_root_ca_cert 2>/dev/null  > ./root_cert.pem

  root_cert_expDate=$(openssl x509 -enddate -noout -in ./root_cert.pem | sed -e 's/notAfter=//')
  formatted_root_ca_date=$(date --date="+${root_cert_expDate}" +"%Y-%m-%dT%H:%M:%SZ")

  if [[ "$formatted_root_ca_date" < "$limit_date" ]]; then
     mv ./root_cert.pem ./expiring_certs/expiring_root_cert.pem
  else
     touch ./expiring_certs/expiring_root_cert.pem
  fi
  echo "List of expiring configurable certificates:"
  cat ./expiring_certs/expiring_configurable_certs.json
  echo ""
  echo "List of expiring non-configurable certificates:"
  cat ./expiring_certs/expiring_non_configurable_certs.json
  echo ""
  echo "List of expiring CA certificates:"
  cat ./expiring_certs/expiring_ca_certs.json
  echo ""
  echo "List of expiring Director Trusted certificates:"
  cat ./expiring_certs/expiring_director_trusted_certs.pem
  echo ""
  echo "List of expiring root certificates:"
  cat ./expiring_certs/expiring_root_cert.pem
  echo ""

}

main
