#!/bin/bash

# Get all service accounts with secrets count greater than 0
kubectl get sa -A | awk '$3 > 0' | while read -r namespace name secrets age; do
  # Skip the header line
  if [[ "$name" != "NAME" ]]; then
    # Get the service account details in YAML format
    sa_secrets=$(kubectl get sa "$name" -n "$namespace" -o jsonpath='{.secrets[*].name}')
    for secret in $sa_secrets; do
      # Check if the secret name contains the word 'token'
      if [[ "$secret" == *token* ]]; then
        # Get the type of the secret and check if it is 'kubernetes.io/service-account-token'
        secret_type=$(kubectl get secret "$secret" -n "$namespace" -o jsonpath='{.type}')
        if [ "$secret_type" == "kubernetes.io/service-account-token" ]; then
          # If found, print the service account name, namespace, and secret name
          echo "Service Account: $name, Namespace: $namespace, Secret: $secret"
        fi
      fi
    done
  fi
done 