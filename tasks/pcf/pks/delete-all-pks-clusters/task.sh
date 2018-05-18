#!/bin/bash -eu


if [[ "$DEBUG" == "true" ]]; then
  set -x
fi

echo "Login to PKS API [$PCF_PKS_API]"
pks login -a "$PCF_PKS_API" -u "$PKS_CLI_USERNAME" -p "$PKS_CLI_PASSWORD" --skip-ssl-verification # TBD --ca-cert CERT-PATH

echo "List all PKS clusters"
pks clusters --json | jq -rc '.[] | .name' > list_of_clusters.txt
cat list_of_clusters.txt

while read clustername; do
  echo "Deleting PKS cluster [$clustername]..."

  pks delete-cluster "$clustername"

  echo "Monitoring the deletion status for PKS cluster [$clustername]"
  in_progress_state="in progress"
  cluster_state="$in_progress_state"

  while [[ "$cluster_state" == "$in_progress_state" ]]; do
    echo "status: [$cluster_state]..."
    sleep 5
    cluster_state=$(pks clusters --json | jq --arg clustername "$clustername" -rc '.[] | select(.name==$clustername) | .last_action_state')
  done
  echo "status on exit: [$cluster_state]..."

  # check if cluster to be deleted still exist after delete try
  if [[ $(pks clusters --json | jq -rc '.[].name' | grep $clustername) ]]; then
    last_action_description=$(pks clusters --json | jq --arg clustername "$clustername" -rc '.[] | select(.name==$clustername) | .last_action_description')
    echo "Error deleting cluster [$clustername], last_action_state=[$cluster_state], last_action_description=[$last_action_description]"
    exit 1
  else
    echo "Successfully deleted cluster [$clustername]"
    echo "Current list of PKS clusters:"
    pks clusters --json
  fi

done <list_of_clusters.txt

echo "All PKS clusters deleted."
