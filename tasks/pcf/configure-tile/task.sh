#!/bin/bash
set -eu

main() {

  # NETWORK
  echo "$TILE_NETWORK" > ./network_object.yml
  # convert network YML into JSON
  python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' < ./network_object.yml > ./network_object.json
  export network_object=$(cat network_object.json)

  # update Ops Mgr tile with network information
  om-linux \
    --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "$OPSMAN_USERNAME" \
    --password "$OPSMAN_PASSWORD" \
    --skip-ssl-validation \
    configure-product \
    --product-name "$TILE_PRODUCT_NAME" \
    --product-network "$network_object"


  # RESOURCES
  echo "$TILE_RESOURCES" > ./resources_object.yml
  # convert resources YML into JSON
  python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' < ./resources_object.yml > ./resources_object.json
  export resources_object=$(cat resources_object.json)

  # PROPERTIES
  echo "$TILE_PROPERTIES" > ./properties_object.yml
  # convert properties YML into JSON
  python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' < ./properties_object.yml > ./properties_object.json

  # make a copy of the original properties file for updates
  cp properties_object.json updated_properties_object.json

  # process any certificate generation by introspecting into properties files
  process_certificates

  # retrieve final json content for the properties object after certificate processing
  export final_properties_object=$(cat updated_properties_object.json)

  # updates properties and resources parameters for tile in Ops Mgr
  om-linux \
    --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "$OPSMAN_USERNAME" \
    --password "$OPSMAN_PASSWORD" \
    --skip-ssl-validation \
    configure-product \
    --product-name "$TILE_PRODUCT_NAME" \
    --product-resources "$resources_object" \
    --product-properties "$final_properties_object"

}

#
# Process certificate generation requests by introspecting into a
# properties files and then searching for keys called "generate_cert_domains".
# For the generated certificates, it updates the corresponding objects in
# original properties object and outputs it to file updated_properties_object.json.
#
process_certificates() {
  ## inspect properties object for requests to generate certificates
  # find certificates to generate
  cat properties_object.json | jq '. | to_entries[] | . as $parent  | .value | .generate_cert_domains? | select(. != null) | $parent' > certs_to_generate.json

  # extract list parent object name and domain information for certs generation
  cat certs_to_generate.json | jq -rc '.key+":"+(.value.generate_cert_domains | join(","))' > certs_to_generate.txt

  # iterate through keys and domains for certificate generation
  while read property_info; do
    parent_object_name=${property_info%:*}
    certs_domain=${property_info#*:}

    echo "Generating certificates for property [$parent_object_name]" >&2

    # generates certificate using Ops Mgr API
    saml_certificates=$(om_generate_cert "$certs_domain")
    # retrieves cert and private key from generated certificate
    saml_cert_pem=`echo $saml_certificates | jq '.certificate'`
    saml_key_pem=`echo $saml_certificates | jq '.key'`

    # create temporary cert json object
    cat << EOF  > ./updated_object.json
{
  "$parent_object_name": {
  "value": {
    "cert_pem": $saml_cert_pem,
    "private_key_pem": $saml_key_pem
  }
}}
EOF

    # update properties object with generated certificates
    cat updated_properties_object.json | jq \
          --arg saml_cert_pem "$saml_cert_pem" \
          --arg saml_key_pem "$saml_key_pem" \
          --slurpfile updated_object updated_object.json \
          ' . + $updated_object[]' > tmp_properties_object.json

    # override updated properties file with new certificates content
    cp tmp_properties_object.json updated_properties_object.json

  done <certs_to_generate.txt

}

om_generate_cert() (
  set -eu
  local domains="$1"

  local data=$(echo $domains | jq --raw-input -c '{"domains": (. | split(" "))}')

  local response=$(
    om-linux \
      --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
      --client-id "${OPSMAN_CLIENT_ID}" \
      --client-secret "${OPSMAN_CLIENT_SECRET}" \
      --username "$OPSMAN_USERNAME" \
      --password "$OPSMAN_PASSWORD" \
      --skip-ssl-validation \
      curl \
      --silent \
      --path "/api/v0/certificates/generate" \
      -x POST \
      -d $data
    )

  echo "$response"
)

main
