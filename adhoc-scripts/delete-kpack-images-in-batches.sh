#!/bin/bash

# Loop through all namespaces
for NAMESPACE in $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'); do

    echo "scanning $NAMESPACE for images to delete"

    # Get the list of kpack images in the current namespace
    KPACK_IMAGES=$(kubectl get images.kpack.io -n "$NAMESPACE" -o json | jq -r '.items[] | select(.status.conditions[] | .type == "Ready" and .status == "False") | .metadata.name')

    # Initialize a counter for processed images
    PROCESSED_IMAGES=0

    # Loop through each cleaned image name
    for IMAGE in $KPACK_IMAGES; do
      # Remove newlines from image names
      CLEANED_IMAGE=$(echo "$IMAGE" | tr -d '\n')

      echo "Deleting image '$CLEANED_IMAGE' in namespace '$NAMESPACE'"
      kubectl -n "$NAMESPACE" delete images.kpack.io "$CLEANED_IMAGE"
      # Increment the processed images counter
      ((PROCESSED_IMAGES++))
      # Check if we've processed 2 images
      if ((PROCESSED_IMAGES % 2 == 0)); then
        echo "taking a nap as to not break things"
        sleep 90
      fi
    done
done