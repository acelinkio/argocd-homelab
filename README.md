# Overview

GitOps driven homelab using ArgoCD

# Project Structure

```
.
├── .github/                   # Github workflow & integration settings
│   └── renovate.json5         # RenovateBot configuration
├── .vscode/                   # Visual Studio Code configuration
│   ├── extensions.json        # Extension recomendations
│   └── settings.json          # Editor settings
├── bootstrap/                 # Bootstrap related files
│   ├── argocd-config.yaml     # ArgoCD Custom Resources for deployment
│   └── argocd-values.yaml     # Values file used for Helm Release
├── docs/                      # Documentation
│   ├── faq.md                 # Frequently Asked Questions
│   └── setup.md               # Onboarding setup
├── manifest/                  # Directory ArgoCD ApplicationSet watches
│   └── <namespace>.yaml       # App of Apps manifests for each namespace
├── .gitignore                 # Ignored files list
└── README.md                  # This file
```



# Docs
* [faq](docs/faq.md)
* [Setup](docs/setup.md)

# Getting Started

## Fork this repository
- Update references during setup and in `bootstrap/argocd-config.yaml` of this repository.  Work in progress to simplify.

