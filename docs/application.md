# Overview
Kubernetes uses three personas to describe roles in the cluster.

**Infrasturcutre Provider** who takes care of setting up the cluster, including GatewayClass/IngressClass/StorageClass/Runtimes.

**Cluster Operator** who take care of extending the capabilities through the use of Kubernetes controllers/operators and other offerings.

**Application Developers** who deploy to the cluster leveraging the resources provided by the above personas.

Following those personas, there are will be using these classifications following those personas.  infrasturcutre, operator, and application.

## infrastructure

### Examples
* kube-system
* longhorn-system
* crossplane-system

## operator

### Examples
* certificate-manager
* external-secrets
* external-dns
* gateway
* minio-operator
* postgres-operator
* reloader

## application

### Consideration Criteria
- [ ] Container Image
- [ ] Helm Chart
- [ ] Configuration Ease
- [ ] Datastore Backend
- [ ] Supports OIDC
- [ ] Disable local auth
- [ ] Progressive Web Application

### Examples
* authentik
* miniflux
* vikunja