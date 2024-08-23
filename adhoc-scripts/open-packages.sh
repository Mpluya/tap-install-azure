#!/bin/bash 

function pull_and_code () {
  imgpkg pull -b $(kubectl get app $1 -n tap-install -ojson | jq -r '.spec.fetch[0].imgpkgBundle.image') -o ~/dev/tap-packages/$1 && code ~/dev/tap-packages/$1
}

pull_and_code $1