# About

This Terraform module provisions security groups to restrict network access within a Vault-managed environment, incorporating configurations for load balancers, member nodes, and various roles like bastion, client, and metrics server.

## Security Groups

The module creates the following security groups:

- **member**: For Vault cluster members, allowing external requests and communication within the group on port **8200** (Vault's default port).
- **load_balancer**: For the cluster's load balancers, permitting external requests and communication with member group on port **8200**.

Additional roles can be configured with specific access:

- **bastion**: Security groups with SSH access (port **22**) and ICMP traffic to both members and load balancers.
- **client**: Security groups with access to load balancers on port **8200** and ICMP traffic.
- **metrics_server**: Security groups with access to members and load balancers on port **9100** (for Prometheus' Node Exporter) and ICMP traffic.

## Variables

The module accepts the following input variables:

- **member_group_name**: Name for the Vault members' security group.
- **load_balancer_group_name**: Name for the Vault load balancers' security group.
- **client_group_ids**: List of client security group IDs with access to the Vault load balancers.
- **bastion_group_ids**: List of bastion security group IDs with access to the Vault cluster.
- **metrics_server_group_ids**: List of metrics server security group IDs with access to the Vault cluster.

## Resources

The module defines several resources, including:

- Security groups for Vault members and load balancers.
- Rules for outbound traffic, Vault access, ICMP traffic, SSH access, and Node Exporter access.
- Configuration for external traffic on load balancers, including HTTP, HTTPS, and ICMP traffic.

## Output

The module outputs the created security groups for Vault members and load balancers, each as a resource of type **openstack_networking_secgroup_v2**.
