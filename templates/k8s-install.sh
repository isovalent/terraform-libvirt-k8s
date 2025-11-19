#!/bin/bash

set -euxo pipefail

echo "Waiting for local cloud-init to finish..."
cloud-init status --wait
echo "Local cloud-init finished." 


echo "Waiting for nodes to become reachable..."
# Use a for loop to iterate over the output of the jq command.
# This is a very direct and clean way to process a list.
echo '${all_nodes_info_json}' | jq -c '.[]' | while read -r node; do
  node_ip=$(echo "$node" | jq -r '.ip')
  hostname=$(echo "$node" | jq -r '.hostname')

  while ! nc -z -w 5 "$node_ip" 22 >/dev/null 2>&1; do
    echo "Port 22 on node $node_ip ($hostname) is not open yet. Retrying in 5 seconds..."
    sleep 5
  done
  echo "Port 22 on node $node_ip ($hostname) is open."

  echo "Waiting for cloud-init to finish on $hostname..."
  ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$hostname@$node_ip" 'cloud-init status --wait'
done

echo "All nodes are reachable. Proceeding with Kubernetes installation."

VERSION=v3.1.11 curl -sfL https://get-kk.kubesphere.io | sh -
./kk create cluster -f ~/kubekey.yaml -y
