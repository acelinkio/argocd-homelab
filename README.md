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
│   ├── network.md             # Networking details
│   └── setup.md               # Installation steps
├── pineapp/                   # Cluster managed by ArgoCD
│   └── $namespace/            # Directory per namespace
│       └── manifest.yaml      # Manifests relating to namespace.  AppOfApps
├── .gitignore                 # Ignored files list
└── README.md                  # This file
```

# ArgoCD Structure
An ApplicationSet dynamically generates an Applications for each yaml file inside of the manifest directory.  That Application is AppOfApps, mirroring the filename that it was generated from.  That AppOfApps may contain child Application resources for deploying Helm charts.

<table>
<tr>
<th>Logical</th>
<th>Rendered Example</th>
</tr>
<tr>
<td>
  
```mermaid
erDiagram
    ApplicationSet ||--|{ AppOfApps : "each $cluster/$namespace/manifest.yaml generates"
    AppOfApps ||--o{ Application : "may contain additional"
```
  
</td>
<td>

```mermaid
flowchart TD
    A[ApplicationSet] -----> B(pineapp/kube-system/manifest.yaml)
    B -----> D[coredns]
    B -----> E[cilium]
    B -----> F[metrics-server]
```

</td>
</tr>
</table>

# Docs
* [application](docs/application.md)
* [faq](docs/faq.md)
* [network](docs/network.md)
* [secret](docs/secret.md)
* [setup](docs/setup.md)

# todo
* figure our externaldns record with cloudflared tunnel.  wants to be secret