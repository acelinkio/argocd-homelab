# Preperation
 
 ## Prerequisites
- 1Password
- Cloudflare managed domain
- reserved cidr block for broadcasting


## 1Password

```
homelab                        # vault used for containing secrets
├── sso                        # secret used for configuring sso
├── stringreplacesecret        # secret used for basic string replacement by ArgoCD Vault Plugin
└── <namespace>                # secret dedicated for each namespace
```


### 1Password Credentials
- Create vault named `homelab`
- Follow https://developer.1password.com/docs/connect/get-started/#step-1-set-up-a-secrets-automation-workflow _1Password.com_ tab for generating `1password-credentials.json` and save into bootstrap directory.
- Follow https://developer.1password.com/docs/connect/get-started/#step-1-set-up-a-secrets-automation-workflow _1Password CLI_ tab for generating a 1password connect token and save as `1password-token.secret` in bootstrap directory.

### Cloudflare Credentials

#### external-dns
- In the homelab vault, create secret named `external-dns`
- Follow https://developers.cloudflare.com/fundamentals/api/get-started/create-token/ for generating a token and save into key named `token`

#### cloudflared
- In the homelab vault, create secret named `cloudflared`
- Follow https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/ for generating a tunnel and credentials.json. Save the tunnel id into a key named `TunnelID` and save credentials.json contents into a key named `credentials.json`

#### cert-manager
- In the homelab vault, create secret named `cert-manager`
- Follow https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/#api-tokens for generating a token and save into key named `token`


### SSO
- In the homelab vault, create secret named `sso`
- Each application a unique clientsecret that is between 30-90 characters long.
  - Create key named `argocd` and save clientsecret value inside.
  - Create key named `grafana` and save clientsecret value inside.

### String Replacement
- In the homelab vault, create secret named `stringreplacesecret`
- Save your domain mydomain.com into a key named `domain`. 
- Save your cidr block for Cilium IPAM to manage into a key named `ciliumipamcidr`. 
- Save the above Cloudflare tunnel id into a key named `cloudflaretunnelid`.


# Setup

## k3s
Not needed if with an existing cluster.
<details>

```bash
# REQUIRED PACKAGES
## https://github.com/mikefarah/yq
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 -O /usr/bin/yq && chmod +x /usr/bin/yq
## packages for k3s/longhorn
apt update
apt install -y curl open-iscsi
## helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


export SETUP_NODEIP=192.168.1.195
export SETUP_CLUSTERTOKEN=randomtokensecret

# CREATE MASTER NODE
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip $SETUP_NODEIP --disable=coredns,flannel,local-storage,metrics-server,servicelb,traefik --flannel-backend='none' --disable-network-policy --disable-cloud-controller --disable-kube-proxy" K3S_TOKEN=$SETUP_CLUSTERTOKEN K3S_KUBECONFIG_MODE=644 sh -s -


# INSTALL CILIUM
export cilium_applicationyaml=$(curl -sL "https://raw.githubusercontent.com/acelinkio/argocd-homelab/main/manifest/kube-system.yaml" | yq eval-all '. | select(.metadata.name == "cilium" and .kind == "Application")' -)
export cilium_name=$(echo "$cilium_applicationyaml" | yq eval '.metadata.name' -)
export cilium_chart=$(echo "$cilium_applicationyaml" | yq eval '.spec.source.chart' -)
export cilium_repo=$(echo "$cilium_applicationyaml" | yq eval '.spec.source.repoURL' -)
export cilium_namespace=$(echo "$cilium_applicationyaml" | yq eval '.spec.destination.namespace' -)
export cilium_version=$(echo "$cilium_applicationyaml" | yq eval '.spec.source.targetRevision' -)
export cilium_values=$(echo "$cilium_applicationyaml" | yq eval '.spec.source.helm.values' -)

echo "$cilium_values" | helm template $cilium_name $cilium_chart --repo $cilium_repo --version $cilium_version --namespace $cilium_namespace --values - | kubectl apply --filename -

# INSTALL COREDNS
export coredns_applicationyaml=$(curl -sL "https://raw.githubusercontent.com/acelinkio/argocd-homelab/main/manifest/kube-system.yaml" | yq eval-all '. | select(.metadata.name == "coredns" and .kind == "Application")' -)
export coredns_name=$(echo "$coredns_applicationyaml" | yq eval '.metadata.name' -)
export coredns_chart=$(echo "$coredns_applicationyaml" | yq eval '.spec.source.chart' -)
export coredns_repo=$(echo "$coredns_applicationyaml" | yq eval '.spec.source.repoURL' -)
export coredns_namespace=$(echo "$coredns_applicationyaml" | yq eval '.spec.destination.namespace' -)
export coredns_version=$(echo "$coredns_applicationyaml" | yq eval '.spec.source.targetRevision' -)
export coredns_values=$(echo "$coredns_applicationyaml" | yq eval '.spec.source.helm.values' -)

# chart does not put namespace in, need to specify on kubectl apply
echo "$coredns_values" | helm template $coredns_name $coredns_chart --repo $coredns_repo --version $coredns_version --namespace $coredns_namespace --values - | kubectl apply --namespace $coredns_namespace --filename -


# JOIN NODES TO CLUSTER
curl -sfL https://get.k3s.io | K3S_URL=https://$SETUP_NODEIP:6443 K3S_TOKEN=$SETUP_CLUSTERTOKEN sh -
```
</details>

## secrets
```bash
export domain=mydomain.tld
export cloudflaretunnelid=11111111-2222-3333-4444-555555555555
export ciliumipamcidr=192.168.1.48/29


kubectl create namespace 1passwordconnect
kubectl create secret generic 1passwordconnect --namespace 1passwordconnect --from-literal 1password-credentials.json=$(cat bootstrap/1password-credentials.json | base64 -w 0 )

kubectl create namespace external-secrets
kubectl create secret generic 1passwordconnect --namespace external-secrets --from-file=token=bootstrap/1password-token.secret 

kubectl create namespace argocd
kubectl create secret generic stringreplacesecret --namespace argocd --from-literal domain=$domain --from-literal cloudflaretunnelid=$cloudflaretunnelid --from-literal ciliumipamcidr=$ciliumipamcidr
```

## argocd
```bash
export argocd_applicationyaml=$(curl -sL "https://raw.githubusercontent.com/acelinkio/argocd-homelab/main/manifest/argocd.yaml" | yq eval-all '. | select(.metadata.name == "argocd" and .kind == "Application")' -)
export argocd_name=$(echo "$argocd_applicationyaml" | yq eval '.metadata.name' -)
export argocd_chart=$(echo "$argocd_applicationyaml" | yq eval '.spec.source.chart' -)
export argocd_repo=$(echo "$argocd_applicationyaml" | yq eval '.spec.source.repoURL' -)
export argocd_namespace=$(echo "$argocd_applicationyaml" | yq eval '.spec.destination.namespace' -)
export argocd_version=$(echo "$argocd_applicationyaml" | yq eval '.spec.source.targetRevision' -)
# removing .configs.cm from bootstrap requires argovaultplugin variables
export argocd_values=$(echo "$argocd_applicationyaml" | yq eval '.spec.source.helm.values' - | yq eval 'del(.configs.cm)' -)
export argocd_config=$(curl -sL "https://raw.githubusercontent.com/acelinkio/argocd-homelab/main/manifest/argocd.yaml" | yq eval-all '. | select(.kind == "AppProject" or .kind == "ApplicationSet")' -)

# install
echo "$argocd_values" | helm template $argocd_name $argocd_chart --repo $argocd_repo --version $argocd_version --namespace $argocd_namespace --values - | kubectl apply --namespace $argocd_namespace --filename -

# configure
echo "$argocd_config" | kubectl apply --filename -
```