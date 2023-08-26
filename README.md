# Overview

GitOps driven homelab using ArgoCD

# Prerequisites

- 1Password
- Cloudflare managed domain
- Kubernetes cluster
- helm
- kubectl
- reserved cidr block for broadcasting

# Project Structure

```
.
├── .github/                   # Github workflow & integration settings
│   └── renovate.json5         # RenovateBot configuration
├── .vscode/                   # Visual Studio Code configuration
│   ├── extensions.json        # Extension recomendations
│   └── settings.json          # Editor settings
├── bootstrap/                 # Initialization of resources
│   ├── argocd-config.yaml     # ArgoCD Custom Resources for deployment
│   └── argocd-values.yaml     # Values file used for Helm Release
├── manifest/                  # Directory ArgoCD ApplicationSet watches
│   └── <namespace>.yaml       # App of Apps manifests for each namespace
├── .gitignore                 # Ignored files list
└── README.md                  # This file
```

# 1Password Layout

```
homelab                        # vault used for containing secrets
├── sso                        # secret used for configuring sso
├── stringreplacesecret        # secret used for basic string replacement by ArgoCD Vault Plugin
└── <namespace>                # secret dedicated for each namespace
```

# Getting Started

## Fork this repository (Recomended)

- Update `bootstrap/argocd-config.yaml` to point to your forked respository.

## 1Password Credentials

- Create vault named `homelab`
- Follow https://developer.1password.com/docs/connect/get-started/#step-1-set-up-a-secrets-automation-workflow _1Password.com_ tab for generating `1password-credentials.json` and save into bootstrap directory.
- Follow https://developer.1password.com/docs/connect/get-started/#step-1-set-up-a-secrets-automation-workflow _1Password CLI_ tab for generating a 1password connect token and save as `1password-token.secret` in bootstrap directory.

## Cloudflare Credentials

### external-dns
- In the homelab vault, create secret named `external-dns`
- Follow https://developers.cloudflare.com/fundamentals/api/get-started/create-token/ for generating a token and save into key named `token`

### cloudflared
- In the homelab vault, create secret named `cloudflared`
- Follow https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/ for generating a tunnel and credentials.json. Save the tunnel id into a key named `TunnelID` and save credentials.json contents into a key named `credentials.json`
### cert-manager
- In the homelab vault, create secret named `cert-manager`
- Follow https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/#api-tokens for generating a token and save into key named `token`
## String Replacement

- In the homelab vault, create secret named `stringreplacesecret`
- Save your domain mydomain.com into a key named `domain`. 
- Save your cidr block for Cilium IPAM to manage into a key named `ciliumipamcidr`. 
- Save the above Cloudflare tunnel id into a key named `cloudflaretunnelid`.

# Setup

```
# Prepare secrets
kubectl create namespace 1passwordconnect
kubectl create secret generic 1passwordconnect --from-literal 1password-credentials.json=$(cat bootstrap/1password-credentials.json | base64 -w 0 ) -n 1passwordconnect

kubectl create namespace external-secrets
kubectl create secret generic 1passwordconnect --from-file=token=bootstrap/1password-token.secret -n external-secrets

kubectl create namespace argocd
export domain=mydomain.tld
export cloudflaretunnelid=11111111-2222-3333-4444-555555555555
export ciliumipamcidr=192.168.1.48/29

kubectl create secret generic stringreplacesecret -n argocd --from-literal domain=$domain --from-literal cloudflaretunnelid=$cloudflaretunnelid --from-literal ciliumipamcidr=$ciliumipamcidr

# Install ArgoCD
helm template --repo https://argoproj.github.io/argo-helm --version 5.43.3 --namespace argocd argocd argo-cd --values bootstrap/argocd-values.yaml | kubectl apply -f -

# Configure ArgoCD
kubectl apply -f bootstrap/argocd-config.yaml
```

# FAQ

- Why is kubernetes not coming back up after going offline?

  Kubernetes API server relies upon Kyverno for validation/mutating.  If Kyverno is unavailable, requests will fail by default.  Update core functions to allow failure.  https://kyverno.io/docs/troubleshooting/#api-server-is-blocked

- Why use external-secrets and argo-vault-plugin?

  external-secrets is the source of truth and should be used primarily.

  argo-vault-plugin is a convient way to do string replacement.  Primarily used to avoid hardcoding domains in ingresses or ipaddresses.

- What is this `<>` notation?

  That is the format for using ArgoCD Vault Plugin. https://argocd-vault-plugin.readthedocs.io/en/stable/howitworks/#inline-path-placeholders Example: `<path:vaults/homelab/items/stringreplacesecret#domain>`

- What does your cluster look like?

  Work in progress to definite.  Aim is to create a general compute node group based on arm64 and then add nodes groups for any different hardware.  

  Will be aiming to use kyverno to manage taints and tolartions on nodes/pods instead of directly specifying them.

- nvidia's gpu-operator
  WIP.  Currently will manage any nvidia labels on nodes.