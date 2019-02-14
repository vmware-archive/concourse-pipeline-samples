#!/bin/sh

OUTPUT_DIR='generated-certs'

if [ -z "${DOMAINS}" ]; then
  echo 'No domains specified with $DOMAINS parameter. Cannot proceed.'
  exit 1
fi

if [ -z "${DNS_TYPE}" ]; then
  echo 'No dns_type specified with $DNS_TYPE parameter. Cannot proceed.'
  exit 1
fi

for domain in ${DOMAINS}; do
  DOMAIN_ARG="${DOMAIN_ARG} -d $domain"
done

acme.sh --issue \
        --dns ${DNS_TYPE} \
        --dnssleep ${DNS_TIMEOUT} \
        --cert-file ${OUTPUT_DIR}/cert.pem \
        --key-file ${OUTPUT_DIR}/key.pem \
        --ca-file ${OUTPUT_DIR}/ca.pem \
        --fullchain-file ${OUTPUT_DIR}/fullchain.pem \
        ${DOMAIN_ARG}
