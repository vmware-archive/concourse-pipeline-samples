#!/bin/bash
set -eu

main() {

  echo "Deleting product ${TILE_PRODUCT_NAME} from ${OPSMAN_DOMAIN_OR_IP_ADDRESS}"

  om-linux \
    --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "$OPSMAN_USERNAME" \
    --password "$OPSMAN_PASSWORD" \
    --skip-ssl-validation \
    delete-product \
    --product-name "$TILE_PRODUCT_NAME"

}

main
