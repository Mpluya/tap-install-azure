# tap-install-azure

## install eso
helm install external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true


## enable azure workload identity

Enabling Azure Workload Identity for External Secrets Operator:
https://external-secrets.io/v0.8.1/provider/azure-key-vault/#workload-identity

Quickstart on Azure Workload Identity:
https://azure.github.io/azure-workload-identity/docs/quick-start.html

Complete the installation guide for azure workload identity. This can now be easily done during your aks cluster creation:
- `az aks create -g "${RESOURCE_GROUP}" -n myAKSCluster --enable-oidc-issuer --enable-workload-identity --generate-ssh-keys` 

   OR

- `az aks update -g "${RESOURCE_GROUP}" -n myAKSCluster --enable-oidc-issuer --enable-workload-identity` (for an update)

Full details on enabling azure workload identity on aks is documented [here](https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster).

At this point, you should have already:
- enabled azure workload identity
- obtained your cluster’s OIDC issuer URL


## configure azure key vault

1. Export environment variables
```
   TENANT_ID=$(az account show --query tenantId | tr -d \")
   RESOURCE_GROUP="cssa-resource-group"
   LOCATION="westus"
   VAULT_NAME="tap-eso-vault"
```

> environment variables for the Azure Key Vault resource
```
   export KEYVAULT_NAME="tap-eso-vault"
   export KEYVAULT_SECRET_NAME="example-externalsecret-key"
   export KEYVAULT_SECRET_VAlUE="This is our secret now"
```

> environment variables for the AAD application
```
   export APPLICATION_NAME="eso-app"
```

> environment variables for the Kubernetes service account & federated identity credential
```
   export SERVICE_ACCOUNT_NAMESPACE="tap-install"
   export SERVICE_ACCOUNT_NAME="eso"
   export SERVICE_ACCOUNT_ISSUER="$(az aks show --resource-group cssa-resource-group --name tap-view --query "oidcIssuerProfile.issuerUrl" -otsv)"
```
2. Create an Azure Key Vault and secret (for initial validation)
```
   az keyvault create --resource-group "${RESOURCE_GROUP}" \
      --location "${LOCATION}" \
      --name "${KEYVAULT_NAME}"

   az keyvault secret set --vault-name "${KEYVAULT_NAME}" \
      --name "${KEYVAULT_SECRET_NAME}" \
      --value "${KEYVAULT_SECRET_VAlUE}"
```

3. Create an AAD application or user-assigned managed identity and grant permissions to access the secret
```
   azwi serviceaccount create phase app --aad-application-name "${APPLICATION_NAME}"
   
   export APPLICATION_CLIENT_ID="$(az ad sp list --display-name "${APPLICATION_NAME}" --query '[0].appId' -otsv)"
   az keyvault set-policy --name "${KEYVAULT_NAME}" \
   --secret-permissions get \
   --spn "${APPLICATION_CLIENT_ID}"
```


4. Create a Kubernetes service account
```
   azwi serviceaccount create phase sa \
   --aad-application-name "${APPLICATION_NAME}" \
   --service-account-namespace "${SERVICE_ACCOUNT_NAMESPACE}" \
   --service-account-name "${SERVICE_ACCOUNT_NAME}"
```

5. Establish federated identity credential between the identity and the service account issuer & subject
```
   azwi serviceaccount create phase federated-identity \
   --aad-application-name "${APPLICATION_NAME}" \
   --service-account-namespace "${SERVICE_ACCOUNT_NAMESPACE}" \
   --service-account-name "${SERVICE_ACCOUNT_NAME}" \
   --service-account-issuer-url "${SERVICE_ACCOUNT_ISSUER}"
```

---
Initial set of secrets seeded in Azure Key Vault to bootstrap kapp (gitops) to load manifests from this repo:
```
   az keyvault secret set --vault-name "${KEYVAULT_NAME}" \
      --name "githubsshknownhosts" \
      -f known_hosts

   az keyvault secret set --vault-name "${KEYVAULT_NAME}" \
      --name "githubsshprivatekey" \
      -f identity

   az keyvault secret set --vault-name "${KEYVAULT_NAME}" \
      --name "githubsshpublickey" \
      -f identity.pub
```

Imperatively applied:
- ./secretstore.yaml
- ./tap-install-gitops-ssh-external-secret.yaml


## install TAP via gitops (package mgmt)
- with kube context set to a k8s cluster intended for tap build --> `kapp deploy -a tap-manager -f ./build-app -n tap-install`
- with kube context set to a k8s cluster intended for tap view --> `kapp deploy -a tap-manager -f ./view-app -n tap-install`
- with kube context set to a k8s cluster intended for tap run --> `kapp deploy -a tap-manager -f ./run-app -n tap-install`
- with kube context set to a k8s cluster intended for tap run prod --> `kapp deploy -a tap-manager -f ./run-prod-app -n tap-install`
- with kube context set to a k8s cluster intended for tap full --> `kapp deploy -a tap-manager -f ./full-app -n tap-install`
