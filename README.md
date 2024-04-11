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
│   ├── netowrk.md             # Networking details
│   └── setup.md               # Installation steps
├── manifest/                  # Watched by ArgoCD ApplicationSet
│   └── $namespace.yaml        # Per namespace, App of Apps
├── .gitignore                 # Ignored files list
└── README.md                  # This file
```



# Docs
* [faq](docs/faq.md)
* [setup](docs/setup.md)
* [network](docs/network.md)