#!/bin/bash -eu

echo "Login to PKS API [$PCF_PKS_API]"
pks login -a "$PCF_PKS_API" -u "$PKS_CLI_USERNAME" -p "$PKS_CLI_PASSWORD" --skip-ssl-validation # TBD --ca-cert CERT-PATH

echo "Creating PKS cluster [$PKS_CLUSTER_NAME], master node hostname [$PKS_CLUSTER_MASTER_HOSTNAME], plan [$PKS_SERVICE_PLAN_NAME], number of workers [$PKS_CLUSTER_NUMBER_OF_WORKERS]"
pks create-cluster "$PKS_CLUSTER_NAME" --external-hostname "$PKS_CLUSTER_MASTER_HOSTNAME" --plan "$PKS_SERVICE_PLAN_NAME" --num-nodes "$PKS_CLUSTER_NUMBER_OF_WORKERS"

echo "Monitoring the creation status for PKS cluster [$PKS_CLUSTER_NAME]:"
in_progress_state="in progress"
succeeded_state="succeeded"
cluster_state="$in_progress_state"

while [[ "$cluster_state" == "$in_progress_state" ]]; do
  cluster_state=$(pks cluster "$PKS_CLUSTER_NAME" --json | jq -rc '.last_action_state')
  echo "${cluster_state}..."
  sleep 10
done

last_action_description=$(pks cluster "$PKS_CLUSTER_NAME" --json | jq -rc '.last_action_description')

if [[ "$cluster_state" == "$succeeded_state" ]]; then
  echo "Successfully created cluster [$PKS_CLUSTER_NAME], last_action_state=[$cluster_state], last_action_description=[$last_action_description]"
  pks cluster "$PKS_CLUSTER_NAME"
  echo "Next step: make sure that the external hostname configured for the cluster [$PKS_CLUSTER_MASTER_HOSTNAME] is accessible from a DNS/network standpoint, so it can be managed with 'kubectl'"
else
  echo "Error creating cluster [$PKS_CLUSTER_NAME], last_action_state=[$cluster_state], last_action_description=[$last_action_description]"
  exit 1
fi
