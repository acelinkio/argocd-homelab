# FAQ

- What is App of Apps?
  App of Apps is the idea that one ArgoCD application can container other applications.  Each file in the `manifest` directory is an App of Apps and will show up as an application named `$namespace.yaml`

- Where is the dependancy mapping?
  Everything is applied at once and expected to eventually reach the desired state.

- Is there a way to deploy 'core' resources beforehand?
  After installing ArgoCD, individual resources can be installed before applying the ApplicationSet that actively watches the `manifest` directory.  See the setup instructions used for coredns/cilium as an example.

- Why use external-secrets and argo-vault-plugin?

  external-secrets is the source of truth.

  argo-vault-plugin is a convient way to do string replacement.  Primarily used to avoid hardcoding domains in ingresses or ipaddresses in resources that are not secrets.

- What is this `<>` notation?

  That is the format for using ArgoCD Vault Plugin. https://argocd-vault-plugin.readthedocs.io/en/stable/howitworks/#inline-path-placeholders Example: `<path:vaults/homelab/items/stringreplacesecret#domain>`

- What does your cluster look like?

  Work in progress to definite.  Aim is to create a general compute node group based on arm64 and then add nodes groups for any different hardware.  

  Will be aiming to use kyverno to manage taints and tolartions on nodes/pods instead of directly specifying them.