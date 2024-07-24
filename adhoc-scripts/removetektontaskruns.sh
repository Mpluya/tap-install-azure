#!/bin/bash

NAMESPACE=$1

# Fetch all TaskRuns in the namespace
taskruns=$(kubectl get taskrun -n $NAMESPACE -o json | jq -r '.items[].metadata.name')

# Iterate over each TaskRun and patch it to remove finalizers
for taskrun in $taskruns; do
  echo "Patching TaskRun: $taskrun"
  kubectl patch taskrun $taskrun -n $NAMESPACE --type='merge' -p '{"metadata":{"finalizers":[]}}'
done

echo "All TaskRuns in namespace $NAMESPACE have been patched to remove finalizers."

# Delete all taskruns in a namespace
echo "Now deleting TaskRuns in namespace $NAMESPACE"

tkn tr delete -n $NAMESPACE $(tkn tr ls -o jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}" -n $NAMESPACE )
