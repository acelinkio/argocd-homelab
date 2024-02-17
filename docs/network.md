# Networking
Resources are exposed outside of the cluster through 4 methods.  This north/south traffic is managed via LoadBalancer, Ingress, Gateway, and Cloudflare Tunnels.

## Load Balancers
This is exposed via Kubernetes service of type LoadBalancer that leverages the cluster load balancer capabilities.

## Ingress
IngressControllers are leveraged to proxy traffic and each will have a LoadBalancer.  These proxy rules are configured via Kubernetes Ingress resources.

To handle internal and external traffic, multiple ingress controllers can be leveraged.

## Gateway & Routes
Gateway APIs are a successor to the Ingress APIs.  GatewayControllers are leveraged to manage proxy servers through the use of Kubernetes Gateway and Route resources.  Each gateway will create their own LoadBalancer and proxy network. Those proxies are configured via HTTPRoutes/GRPCRoutes that define how traffic should be routed.

To handle internal and external traffic, multiple gateways can be leveraged.

## Cloudflare Tunnels
Cloudflare Tunnels is an offering by Cloudflare to expose resources to the public through their daemon, cloudflared.  The tunnel is initialized by hosting cloudflared inside your cluster. Traffic is configured to go to external Gateway or Ingress resources.


# IPAddresses

| API           | Controller | Facing                 | ClassName   | GatewayName  | IPAddress |
| ------- | ------------- | -------- | ---------------------- | ----------- | ------------ |
| gateway        | cilium                     | external         | cilium                                       | external               | 192.168.1.49             |
| gateway        | cilium                     | internal         | cilium                                       | internal               | 192.168.1.50             |
| gateway        | cilium                     | internal         | cilium                                       | knative                | 192.168.1.51             |
| ingress        | ingress-nginx              | internal         | ingress-nginx-internal                       | n/a                    | 192.168.1.52             |

# Knative
Knative has a highly opinionated approach that aims to simplify everything into a single minimalist manifest.  This is extremely useful for those just getting started, however has several limitations.  One of those limitations is around networking, assuming each has their own domain domain.  There is no way to modify those rules to handle path based management.

<details>
Attempted Gateway (internal) -> HTTPRoute (URLRewrite) -> Service (ExternalName) -> Gateway (knative) -> HTTPRoute.  Likely failed because ExternalService implemenation.  HTTPRoute to ExternalService is not a best practice and should not be implemented by controllers. https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io%2fv1.BackendObjectReference.

```yaml
knative_related:
  kservice:
    name: kecho

  Gateway:
    name: knative
    address: 192.168.1.51

  HTTPRoute:
    name: kecho.knative.acelink.io
    hostnames: 
      - kecho.knative.acelink.io
    backend:
      kind: Service
      name: kecho-00001
    notes: hostnames is generated templating in knative-serving/config-network configmap

  HTTPRoute:
    name: kecho.test-zone.svc.cluster.local
    hostnames: 
      - kecho.test-zone.svc.cluster.local
      - kecho.test-zone.svc
      - kecho.test-zone
    backend:
      kind: Service
      name: kecho-00001

  Service:
    name: kecho-00001
    selector: null
    note: they do something behind the scenes selection to knative-serving/activator
```


</details>