#!/bin/bash

# Here are the steps to determine the correct image digest for the queue-proxy container pod, given a version of TAP:

# 1. get the imgpkg bundle version of the CNRs package from the TAP packaging repo:
# Note: you'll need to filter to the correct release branch, e.g. for TAP 1.11.1 --> https://gitlab.eng.vmware.com/tap/tap-packages/-/blob/1.11.1-rel-branch/packages/cnrs.tanzu.vmware.com/package.yml?ref_type=heads#L31
#     result:
#          image: lever-docker-local.artifactory.eng.vmware.com/cnrs.tanzu.vmware.com@sha256:32a0362a6a3c93707882d7395bef3e2e493eebe1040c713d2b8cbd42b9853714

# extract the package bundle to a local directory (Note: replace registry to broadcom)

imgpkg pull -b tanzu.packages.broadcom.com/tanzu-application-platform/tap-packages@sha256:32a0362a6a3c93707882d7395bef3e2e493eebe1040c713d2b8cbd42b9853714 -o /tmp/cnrs-1-11-1

#navigate to the local directory where contents of the cnrs package were extracted; in this example /tmp/cnrs-1-11-1/.imgpkg/images.yml. Note the image digest associated with "kbld.carvel.dev/id: ko://knative.dev/serving/cmd/queue"

# result: image: tanzu.packages.broadcom.com/tanzu-application-platform/tap-packages@sha256:4137c5cd147bb314e51982752fc73f9d637449a573714a145908ed9e30d644c0

images_file="/tmp/cnrs-1-11-1/.imgpkg/images.yml"

# Extract the image value where the annotation matches the required id
image=$(awk '/kbld.carvel.dev\/id: ko:\/\/knative.dev\/serving\/cmd\/queue/{flag=1} flag && /image:/{print $2; exit}' $images_file)

# Output the extracted image value
echo "The image for 'ko://knative.dev/serving/cmd/queue' is: $image"
