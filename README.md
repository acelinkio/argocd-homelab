# Overview

GitOps driven homelab using ArgoCD with a flat repository structure.

# Project Structure

```
.
├── .github/                   # Github related files
│   └── renovate.json5         # RenovateBot configuration
├── .vscode/                   # Visual Studio Code configs
│   ├── extensions.json        # Extension recomendations
│   └── settings.json          # Project specific settings
├── docs/                      # Documentation
│   ├── faq.md                 # Frequently Asked Questions
│   └── setup.md               # Installation steps
├── manifest/                  # Watched by ArgoCD ApplicationSet
│   └── <namespace>.yaml       # Per namespace, App of Apps
├── .gitignore                 # Ignored files list
└── README.md                  # This file
```



# Docs
* [faq](docs/faq.md)
* [setup](docs/setup.md)

# TODO
* Remove hardcoded values
  * kube-system.yaml cilium configuration
  * kube-system.yaml coredns configuration
* Initial setup secrets are all managed via external-secrets
* Fix external-dns not updating existing records

* Github pages
* List out all tech used
* Renovate updates for argovaultplugin & knative
* Update docs/setup to mention kube-system
* Investigate dex as standalone