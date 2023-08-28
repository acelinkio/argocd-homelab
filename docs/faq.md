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