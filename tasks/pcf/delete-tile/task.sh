#!/bin/bash
set -eu

main() {

  # find tile version installed
  echo "Retrieving current staged version of ${TILE_PRODUCT_NAME}"
  product_version=$(om-linux \
    --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "$OPSMAN_USERNAME" \
    --password "$OPSMAN_PASSWORD" \
    --skip-ssl-validation -tr  \
    deployed-products | grep ${TILE_PRODUCT_NAME} | cut -d "|" -f 3 | tr -d " ")

  echo "Deleting product [${TILE_PRODUCT_NAME}], version [${product_version}] , from ${OPSMAN_DOMAIN_OR_IP_ADDRESS}"

  om-linux \
    --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "$OPSMAN_USERNAME" \
    --password "$OPSMAN_PASSWORD" \
    --skip-ssl-validation -tr \
    delete-product \
    --product-name "$TILE_PRODUCT_NAME" \
    --product-version "$product_version"

}

main
