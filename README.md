# Overview

GitOps driven homelab using ArgoCD

# Prerequisites

- 1Password
- Cloudflare managed domain
- At least 1 private static ip
- Kubernetes cluster
- helm
- kubectl

# Project Structure

```
.
├── bootstrap/                 # Initialization related resources
│   ├── argocd-config.yaml     # ArgoCD Custom Resources for deployment
│   └── argocd-values.yaml     # Values file used for Helm Release
├── manifest/                  # Directory ArgoCD ApplicationSet watches
│   └── <namespace>.yaml       # App of Apps manifests for used for each namespace
├── .gitignore                 # Ignored files list
└── README.md                  # This file
```

# 1Password Layout

```
homelab                        # vault used for containing secrets
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

- In the homelab vault, create secret named `external-dns`
- Follow https://developers.cloudflare.com/fundamentals/api/get-started/create-token/ for generating a token and save into key named `token`
- In the homelab vault, create secret named `cloudflared`
- Follow https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/ for generating a tunnel and credentials.json. Save the tunnel id into a key named `TunnelID` and save credentials.json contents into a key named `credentials.json`

## String Replacement

- In the homelab vault, create secret named `stringreplacesecret`
- Save your domain mydomain.com into a key named `domain`. Save your static ip address range for MetalLB 192.168.1.x-192.168.1.x into a key named `metallbpooladdress`. Save the above Cloudflare tunnel id into a key named `cloudflaretunnelid`.

# Setup

```
# Prepare secrets
kubectl create namespace 1passwordconnect
kubectl create secret generic 1passwordconnect --from-literal=1password-credentials.json=$(cat 1password-credentials.json | base64) -n 1passwordconnect

kubectl create namespace external-secrets
kubectl create secret generic 1passwordconnect --from-file=token=bootstrap/1password-token.secret -n external-secrets

kubectl create namespace argocd
kubectl create secret generic avpconfig --from-file=OP_CONNECT_TOKEN=bootstrap/1password-token.secret  --from-literal=AVP_TYPE=1passwordconnect --from-literal=OP_CONNECT_HOST=http://onepassword-connect.1passwordconnect.svc.cluster.local:8080 -n argocd

# Install ArgoCD
helm upgrade --install --repo https://argoproj.github.io/argo-helm --version 5.36.1 --namespace argocd argocd argo-cd --values bootstrap\argocd-values.yaml

# Configure ArgoCD
kubectl apply -f bootstrap/argocd-config.yaml
```

# FAQ

- What is are these objects enclosed in <>?

  That is the format for using ArgoCD Vault Plugin. https://argocd-vault-plugin.readthedocs.io/en/stable/howitworks/#inline-path-placeholders Example: `<path:vaults/homelab/items/stringreplacesecret#domain>`

- Why use argo-vault-plugin and external-secrets?

  Argo-Vault-Plugin provides a quick way to do do basic string replacements. This is useful when prototyping and as many resources cannot quickly consume values from kubernetes secrets or configmaps.
