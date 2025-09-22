# Required Purchases
- 1Password
- Cloudflare managed domain

# Preperation

## Update cluster configs
argocd-homelab aims to be as agnostic as possible, however several configurations are implementation specific.  Be sure to review the settings related to infrastructure.
- Review `pineapp/kube-system/manifest.yaml`
- Review `pineapp/longhorn-system/manifest.yaml`
- Review `pineapp/gateway/manifest.yaml`
- Review `pineapp/kyoo/manifest.yaml`
- Update `docs/network.md`
- Update `pineapp/external-dns/manifest.yaml`

## 1Password
- Create vault named `homelab`
```
homelab                        # vault used for containing secrets
├── sso                        # secret used for configuring sso
└── $namespace                 # secret dedicated for each namespace
```

### 1password Credentials
#### 1passwordconnect
- In the homelab vault, create secret named `1passwordconnect`
- Follow https://developer.1password.com/docs/connect/get-started/#step-1-set-up-a-secrets-automation-workflow _1Password.com_ tab for generating save into key named `1password-credentials.json`. WIP

#### external-secrets
- In the homelab vault, create secret named `external-secrets`
- Follow https://developer.1password.com/docs/connect/get-started/#step-1-set-up-a-secrets-automation-workflow _1Password CLI_ tab for generating a 1password connect token and save into key named `1password-token.secret`.

### Cloudflare Credentials

#### cloudflared
- In the homelab vault, create secret named `cloudflared`
- Follow https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/ for generating a tunnel and credentials.json. Save the tunnel id into a key named `TunnelID` and save credentials.json contents into a key named `credentials.json`

#### external-dns
- In the homelab vault, create secret named `external-dns`
- Follow https://developers.cloudflare.com/fundamentals/api/get-started/create-token/ for generating a token and save into key named `cloudflare-token`
- Lab Specific implementation.  Follow https://help.ui.com/hc/en-us/articles/1500011491541-Granting-Access-to-UniFi-Roles-and-Permissions to add a new user credentials to your unifi gear.  Save username into key named `unifi-user` and password into key named `unifi-password`.

#### cert-manager
- In the homelab vault, create secret named `cert-manager`
- Follow https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/#api-tokens for generating a token and save into key named `token`

### SSO
- In the homelab vault, create secret named `sso`

- Each application should have a unique clientid that is upto 30 characters long. They will also need a unique clientsecret that is between 30-90 characters long.
  - create key named `argocd_client_id`
  - create key named `argocd_client_secret`
  - create key named `discourse_client_id`
  - create key named `discourse_client_secret`
  - create key named `grafana_client_id`
  - create key named `grafana_client_secret`
  - create key named `komga_client_id`
  - create key named `komga_client_secret`
  - create key named `kyoo_client_id`
  - create key named `kyoo_client_secret`
  - create key named `manyfold_client_id`
  - create key named `manyfold_client_secret`
  - create key named `mealie_client_id`
  - create key named `mealie_client_secret`
  - create key named `miniflux_client_id`
  - create key named `miniflux_client_secret`
  - create key named `minio_client_id`
  - create key named `minio_client_secret`
  - create key named `ryot_client_id`
  - create key named `ryot_client_secret`
  - create key named `vikunja_client_id`
  - create key named `vikunja_client_secret`
- Federated authentication via Google.
  - Follow https://docs.goauthentik.io/integrations/sources/google/ for generating OAuth credentials.  Save clientid into key named `federation_google_client_id` and clientsecret into key named `federation_google_client_secret`

### Other Secrets

#### Authentik
- In the homelab vault, create secret named `authentik`
- Create a random password named `secret_key`.
- Create a random password for the initial user named `bootstrap_password` used for logging in with the default admin account.
- Create key named `bootstrap_email` used for specifying the email address of the default admin account.
- Create a random token named `bootstrap_token` used for accessing the api.

#### Discourse
- In the homelab vault, create secret named `discourse`
- Create a random password for the initial user named `bootstrap_password` used for logging in with the default admin account.
- Create a random password for sending email named `smtp_password` used for sending emails. (WIP)
- Create a random password for sending email named `redis_password` used for authenticating emails. (WIP)

### Ryot
- In the homelab vault, create secret named `ryot`
- Create 20 character random string into `server_access_token` key.
- Video game tracking requires access through Twitch to https://www.igdb.com/.  Follow docs to generate OAuth credentials.  Save clientid into key named `twitch_client_id` and clientsecret into key named `twitch_client_secret` 

### Matrix
- In the homelab vault, create secret named `matrix`
- Create a random 30 character string named `macaroon_secret_key`.
- Create a random 30 character string named `registration_shared_secret`.
- Create a random 30 character string named `form_secret`.
- Create a secret based upon https://github.com/element-hq/synapse/blob/develop/synapse/_scripts/generate_signing_key.py and store in `signing_key`.

### Kyoo
- In the homelab vault, create secret named `kyoo`
- Generate random 30 character string to be used as an internal apikey for kyoo microservices.  Save apikey into key named `kyoo_apikeys`
- Media tracking access to TheMovieDB.  Follow docs to generate api key.  https://developer.themoviedb.org/docs/getting-started.  Save apikey into key named `tmdb_apikey`
- Media tracking access to TheTVDB.  Follow docs to generate api key & pin.  https://thetvdb.com/api-information/signup.  Save apikey into key named `tvdb_apikey`.  Save pin into key named `tvdb_pin`

### Blank
- In the homelab vault, create secret named `blank`
- Create a key named `blank` with value `""`.  This is needed to template external-secrets with a known value.

# Setup

## k3s
This can be used with an existing Kubernetes cluster, however you may not want argocd to manage resources such as kube-system.  Either way I encourage creating your own fork or copy of this project and replacing any references to `acelinkio/argocd-homelab` with the copy/fork.

Details below show what steps are needed for creating a k3s cluster on an Ubuntu based system(s).
<details>

```bash
# REQUIRED PACKAGES
# yq
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 -O /usr/bin/yq && chmod +x /usr/bin/yq
# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


# NODE
## packages for k3s/longhorn
apt update
apt install -y curl open-iscsi nfs-common

# workaround for multipath automounting Longhorn volumes
## https://longhorn.io/kb/troubleshooting-volume-with-multipath/
cat << 'EOF' >> /etc/multipath.conf
blacklist {
    devnode "^sd[a-z0-9]+"
}
EOF
systemctl restart multipathd.service

# workaround for cilium not loading packages, dependent upon OS
## https://docs.cilium.io/en/stable/operations/system_requirements/#linux-kernel
## https://github.com/cilium/cilium/issues/25021
modprobe iptable_raw
modprobe xt_socket

cat << 'EOF' > /etc/modules-load.d/cilium.conf
xt_socket
iptable_raw
EOF

# add longhohn not loading packages
modprobe dm_crypt

cat << 'EOF' > /etc/modules-load.d/longhorn.conf
dm_crypt
EOF


export SETUP_NODEIP=192.168.1.195
export SETUP_CLUSTERTOKEN=randomtokensecret

# CREATE MASTER NODE
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.32.1+k3s1" INSTALL_K3S_EXEC="--node-ip $SETUP_NODEIP --disable=coredns,flannel,local-storage,metrics-server,servicelb,traefik --flannel-backend='none' --disable-network-policy --disable-cloud-controller --disable-kube-proxy" K3S_TOKEN=$SETUP_CLUSTERTOKEN K3S_KUBECONFIG_MODE=644 sh -s -
kubectl taint nodes rk1-01 node-role.kubernetes.io/control-plane:NoSchedule


# INSTALL CILIUM
export cilium_applicationyaml=$(curl -sL "https://raw.githubusercontent.com/acelinkio/argocd-homelab/main/pineapp/kube-system/manifest.yaml" | yq eval-all '. | select(.metadata.name == "cilium" and .kind == "Application")' -)
export cilium_name=$(echo "$cilium_applicationyaml" | yq eval '.metadata.name' -)
export cilium_chart=$(echo "$cilium_applicationyaml" | yq eval '.spec.source.chart' -)
export cilium_repo=$(echo "$cilium_applicationyaml" | yq eval '.spec.source.repoURL' -)
export cilium_namespace=$(echo "$cilium_applicationyaml" | yq eval '.spec.destination.namespace' -)
export cilium_version=$(echo "$cilium_applicationyaml" | yq eval '.spec.source.targetRevision' -)
export cilium_values=$(echo "$cilium_applicationyaml" | yq eval '.spec.source.helm.valuesObject' - | yq eval 'del(.gatewayAPI)' - | yq eval 'del(.ingressController)' -)

echo "$cilium_values" | helm template $cilium_name $cilium_chart --repo $cilium_repo --version $cilium_version --namespace $cilium_namespace --values - | kubectl apply --filename -

# INSTALL COREDNS
export coredns_applicationyaml=$(curl -sL "https://raw.githubusercontent.com/acelinkio/argocd-homelab/main/pineapp/kube-system/manifest.yaml" | yq eval-all '. | select(.metadata.name == "coredns" and .kind == "Application")' -)
export coredns_name=$(echo "$coredns_applicationyaml" | yq eval '.metadata.name' -)
export coredns_chart=$(echo "$coredns_applicationyaml" | yq eval '.spec.source.chart' -)
export coredns_repo=$(echo "$coredns_applicationyaml" | yq eval '.spec.source.repoURL' -)
export coredns_namespace=$(echo "$coredns_applicationyaml" | yq eval '.spec.destination.namespace' -)
export coredns_version=$(echo "$coredns_applicationyaml" | yq eval '.spec.source.targetRevision' -)
export coredns_values=$(echo "$coredns_applicationyaml" | yq eval '.spec.source.helm.valuesObject' -)

echo "$coredns_values" | helm template $coredns_name $coredns_chart --repo $coredns_repo --version $coredns_version --namespace $coredns_namespace --values - | kubectl apply --namespace $coredns_namespace --filename -


# JOIN NODES TO CLUSTER
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.32.1+k3s1" K3S_URL=https://$SETUP_NODEIP:6443 K3S_TOKEN=$SETUP_CLUSTERTOKEN sh -
# LABEL NODES AS WORKERS
kubectl label nodes mynodename kubernetes.io/role=worker
```
</details>

## secrets
```bash
# 1password-cli is required
## https://developer.1password.com/docs/cli/get-started
# login via `eval $(op signin)`

export onepasswordconnect_json="$(op read op://homelab/1passwordconnect/1password-credentials.json | base64)"
export externalsecrets_token="$(op read op://homelab/external-secrets/token)"

kubectl create namespace 1passwordconnect
kubectl create secret generic 1passwordconnect --namespace 1passwordconnect --from-literal 1password-credentials.json="$onepasswordconnect_json"

kubectl create namespace external-secrets
kubectl create secret generic 1passwordconnect --namespace external-secrets --from-literal token=$externalsecrets_token
```

## argocd
```bash
export argocd_applicationyaml=$(curl -sL "https://raw.githubusercontent.com/acelinkio/argocd-homelab/main/pineapp/argocd/manifest.yaml" | yq eval-all '. | select(.metadata.name == "argocd" and .kind == "Application")' -)
export argocd_name=$(echo "$argocd_applicationyaml" | yq eval '.metadata.name' -)
export argocd_chart=$(echo "$argocd_applicationyaml" | yq eval '.spec.source.chart' -)
export argocd_repo=$(echo "$argocd_applicationyaml" | yq eval '.spec.source.repoURL' -)
export argocd_namespace=$(echo "$argocd_applicationyaml" | yq eval '.spec.destination.namespace' -)
export argocd_version=$(echo "$argocd_applicationyaml" | yq eval '.spec.source.targetRevision' -)
export argocd_values=$(echo "$argocd_applicationyaml" | yq eval '.spec.source.helm.valuesObject' - | yq eval 'del(.configs.cm)' -)
export argocd_config=$(curl -sL "https://raw.githubusercontent.com/acelinkio/argocd-homelab/main/pineapp/argocd/manifest.yaml" | yq eval-all '. | select(.kind == "AppProject" or .kind == "ApplicationSet")' -)

# install
echo "$argocd_values" | helm template $argocd_name $argocd_chart --repo $argocd_repo --version $argocd_version --namespace $argocd_namespace --values - | kubectl apply --namespace $argocd_namespace --filename -

# configure
echo "$argocd_config" | kubectl apply --filename -
```
## Post Setup
### Authentik Add Google Auth to Stage
This is a manual step until either the default authentik resource can be imported or another stage we manage can be used.

Follow: https://docs.goauthentik.io/docs/sources

This is what the terraform code would look like.
```hcl
resource "authentik_stage_identification" "default" {
  name           = "default-authentication-identification"
  user_fields    = ["username","email"]
  sources        = [authentik_source_oauth.google.uuid]
}
```
### Authentik Update Consent Duration
This is a manual step until either the default authentik resource can be imported or another stage we manage can be used.

Update stage default-provider-authoerization-consent to use 26 weeks instead of 4.  

### Login to Komga
Komga does not seed the initial user.  Instead the first login allows for an administrator account to be created.  Be sure to set this up.

### Login to Kyoo
Kyoo does not seed the initial user.  Instead the first login allows for an administrator account to be created.  Be sure to set this up.

## Login to Manyfold
Does not appear to support oidc mapping.  First user to login via oidc is an administrator.

### Login to Mealie
Login to Authentik.  Add your user to `mealie Admin` Authentik groups.  Login to mealie via OIDC.  Delete the default user.

### Discourse Setup
Discourse requires additional configurations done inside of the application.  Those notes can be found in the discourse.md

# Additional Comments
* If doing find and replace, be sure to leave `https://github.com/acelinkio/empty.git`.
* Bootstrapping can be a very resource intensive process.  On a lower powered cluster, consider reducing the number of applications deployed and gradually adding them.