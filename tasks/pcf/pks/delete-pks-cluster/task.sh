#!/bin/bash -eu

echo "Login to PKS API [$PCF_PKS_API]"
pks login -a "$PCF_PKS_API" -u "$PKS_CLI_USERNAME" -p "$PKS_CLI_PASSWORD" --skip-ssl-verification # TBD --ca-cert CERT-PATH
pks cluster "$PKS_CLUSTER_NAME"

echo "Deleting PKS cluster [$PKS_CLUSTER_NAME]..."
pks delete-cluster "$PKS_CLUSTER_NAME" --non-interactive

echo "Monitoring the deletion status for PKS cluster [$PKS_CLUSTER_NAME]"
in_progress_state="in progress"
cluster_state="$in_progress_state"

while [[ "$cluster_state" == "$in_progress_state" ]]; do
  cluster_state=$(pks cluster "$PKS_CLUSTER_NAME" --json 2>/dev/null | jq -rc '.last_action_state')
  echo "status: [$cluster_state]..."
  sleep 5
done

cluster_exists=$(pks clusters --json | jq -rc '.[].name')

if [[ "$cluster_exists" == "" ]]; then
  echo "Successfully deleted cluster [$PKS_CLUSTER_NAME]"
  echo "Current list of PKS clusters:"
  pks clusters --json
else
  last_action_description=$(pks cluster "$PKS_CLUSTER_NAME" --json | jq -rc '.last_action_description')
  echo "Error deleting cluster [$PKS_CLUSTER_NAME], last_action_state=[$cluster_state], last_action_description=[$last_action_description]"
  exit 1
fi
