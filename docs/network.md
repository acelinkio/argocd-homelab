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


# IPAM
## Reserved CIDR Blocks
| CIDR Block      | CIDR IP Range               | Unallocatable               | Usable |
|-----------------|-----------------------------|-----------------------------|--------|
| 192.168.1.48/28 | 192.168.1.48 - 192.168.1.63 | [192.168.1.48,192.168.1.63] | 14     |

Cilium does not allocate the first and last IP addresses of a CIDR block.  https://github.com/cilium/cilium/issues/28637 

## Allocated IP Addresses
| API           | Controller | Facing                 | ClassName   | GatewayName  | IPAddress |
| ------- | ------------- | -------- | ---------------------- | ----------- | ------------ |
| gateway        | cilium                     | external         | cilium                                       | external               | 192.168.1.49             |
| gateway        | cilium                     | internal         | cilium                                       | internal               | 192.168.1.50             |
| ingress        | ingress-nginx              | internal         | ingress-nginx-internal                       | n/a                    | 192.168.1.52             |