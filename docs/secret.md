# Secrets
Secret management can be tricky to manage. Several tools have their own opinionation on what a secret is and that may differ from our own views. This project will aims to closely follow the Kubernetes opinionation with some minor modifications.

# Goals
## No checked in secrets
No secret values should ever be checked into this repository. Private or public repository, git is not a secure place to store secrets.

## Read-Only access to Kubernetes bleeds no secrets
This means using Kubernetes secrets where ever possible to assign credentials, api keys, and other privildged information.

Generally the approach is: 
* Helm charts should consume Kubernetes secrets, not create them. 
* Domains are NOT privildged information. However we will use ArgoCD Vault Plugin for string replacement.

## Across namespace secrets are pulled through secret manager
Generally want to avoid expanding the permissions to allow applications go across namespaces. Pushing the secret into secret manager then pulling the secret back down is a much more sustainable approach.

# Secret Metadata
`_metadata_origin` will be added to each secret to track where the secret is generated from.
* manual - created by hand
* push - created via external-secrets
* hybrid - mix of manual and push

Adding this metadata to PushSecrets is currently blocked by: https://github.com/external-secrets/external-secrets/issues/3443