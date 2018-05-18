#!/bin/bash -e
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
    cluster_exists=$(pks clusters --json | jq -rc '.[].name' | grep $clustername)
    if [[ "$cluster_exists" != "" ]]; then
      cluster_state=$(pks cluster "$clustername" --json 2>/dev/null | jq -rc '.last_action_state')
    else
      cluster_state=""
    fi
  done

  cluster_exists=$(pks clusters --json | jq -rc '.[].name' | grep $clustername)

  if [[ "$cluster_exists" == "" ]]; then
    echo "Successfully deleted cluster [$clustername]"
    echo "Current list of PKS clusters:"
    pks clusters --json
  else
    last_action_description=$(pks cluster "$clustername" --json | jq -rc '.last_action_description')
    echo "Error deleting cluster [$clustername], last_action_state=[$cluster_state], last_action_description=[$last_action_description]"
    exit 1
  fi

done <list_of_clusters.txt

echo "All PKS clusters deleted."
