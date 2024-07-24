#!/bin/bash

NAMESPACE=$1

# Fetch all pipelineruns in the namespace
pipelineruns=$(kubectl get pipelinerun -n $NAMESPACE -o json | jq -r '.items[].metadata.name')

# Iterate over each pipelinerun and patch it to remove finalizers
for pipelinerun in $pipelineruns; do
  echo "Patching pipelinerun: $pipelinerun"
  kubectl patch pipelinerun $pipelinerun -n $NAMESPACE --type='merge' -p '{"metadata":{"finalizers":[]}}'
done

echo "All pipelineruns in namespace $NAMESPACE have been patched to remove finalizers."

# Delete all pipelineruns in a namespace
echo "Now deleting pipelineruns in namespace $NAMESPACE"

tkn pr delete -n $NAMESPACE $(tkn pr ls -o jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}" -n $NAMESPACE )
