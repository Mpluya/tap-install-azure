#!/bin/bash

# Function to find the index of the secret to be removed
find_secret_index() {
  local secret_name=$1
  local sa_secrets=("${@:2}")
  local index=0

  for secret in "${sa_secrets[@]}"; do
    if [[ "$secret" == *"$secret_name"* ]]; then
      echo $index
      return
    fi
    ((index++))
  done

  echo -1
}

# Function to remove a secret from a service account
remove_secret_from_sa() {
  local namespace=$1
  local sa_name=$2
  local secret_name=$3
  local secret_index=$(find_secret_index "$secret_name" "${@:4}")

  if [ "$secret_index" -ne -1 ]; then
    # Patch the service account to remove the secret at the specific index
    kubectl patch sa "$sa_name" -n "$namespace" --type='json' -p="[{'op': 'remove', 'path': '/secrets/$secret_index'}]"
    # Delete the secret itself
    kubectl delete secret "$secret_name" -n "$namespace"
  fi
}

# Get all service accounts with secrets count greater than 0
kubectl get sa -A | awk '$3 > 0' | while read -r namespace name secrets age; do
  # Skip the header line
  if [[ "$name" != "NAME" ]]; then
    # Get the service account details in YAML format
    sa_secrets=($(kubectl get sa "$name" -n "$namespace" -o jsonpath='{.secrets[*].name}'))
    for secret in "${sa_secrets[@]}"; do
      # Check if the secret name contains the word 'token'
      if [[ "$secret" == *token* ]]; then
        # Get the type of the secret and check if it is 'kubernetes.io/service-account-token'
        secret_type=$(kubectl get secret "$secret" -n "$namespace" -o jsonpath='{.type}')
        if [ "$secret_type" == "kubernetes.io/service-account-token" ]; then
          # Call the function to remove the secret from the service account and delete the secret
          remove_secret_from_sa "$namespace" "$name" "$secret" "${sa_secrets[@]}"
        fi
      fi
    done
  fi
done