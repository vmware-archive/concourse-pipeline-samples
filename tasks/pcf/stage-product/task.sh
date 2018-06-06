#!/bin/bash

set -eu

# Copyright 2017-Present Pivotal Software, Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

desired_version=$(jq --raw-output '.Release.Version' < ./pivnet-product/metadata.json)

AVAILABLE=$(om-linux \
  --skip-ssl-validation \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
  curl -path /api/v0/available_products)
STAGED=$(om-linux \
  --skip-ssl-validation \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
  curl -path /api/v0/staged/products)

# Should the slug contain more than one product, pick only the first.
FILE_PATH=`find ./pivnet-product -name *.pivotal | sort | head -1`
unzip $FILE_PATH metadata/*

PRODUCT_NAME="$(cat metadata/*.yml | grep '^name' | cut -d' ' -f 2)"

# Figure out which products are unstaged.
UNSTAGED_ALL=$(jq -n --argjson available "$AVAILABLE" --argjson staged "$STAGED" \
  '$available - ($staged | map({"name": .type, "product_version": .product_version}))')

UNSTAGED_PRODUCT=$(echo "$UNSTAGED_ALL" | jq \
  --arg product_name "$PRODUCT_NAME" \
  --arg product_version "$desired_version" \
  'map(select(.name == $product_name)) | map(select(.product_version | startswith($product_version)))'
)

# There should be only one such unstaged product.
if [ "$(echo $UNSTAGED_PRODUCT | jq '. | length')" -ne "1" ]; then
  echo "Need exactly one unstaged build for $PRODUCT_NAME version $desired_version"
  jq -n "$UNSTAGED_PRODUCT"
  exit 1
fi

full_version=$(echo "$UNSTAGED_PRODUCT" | jq -r '.[].product_version')

om-linux --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
  --skip-ssl-validation \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  stage-product \
  --product-name "${PRODUCT_NAME}" \
  --product-version "${full_version}"
