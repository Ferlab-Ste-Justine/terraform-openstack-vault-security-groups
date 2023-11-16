# About

This is a Terraform module that provisions security groups meant to restrict network access to a Vault-managed environment with load balancers.

The following security groups are created:

- **member**: Security group for members of the Vault cluster. It can make external requests and communicate with other members of the **member** group on port **8200** (Vault's default port).
- **load_balancer**: Security group for the load balancers of the cluster. It can make external requests and communicate with other members of the **member** group on port **8200** (Vault's default port).

Additionally, you can pass a list of groups that will fulfill each of the following roles:

- **bastion**: Security groups that will have access to the members and load balancers on port **22** (SSH) as well as ICMP traffic.
- **client**: Security groups that will have access to the load balancers on port **8200** as well as ICMP traffic.
- **metrics_server**: Security groups that will have access to the members and load balancers on port **9100** (commonly used for Prometheus' Node Exporter) as well as ICMP traffic.

# Usage

## Variables

The module takes the following variables as input:

- **member_group_name**: Name to give to the security group for the Vault members.
- **load_balancer_group_name**: Name to give to the security group for the load balancers.
- **client_groups**: List of security groups that should have access to the Vault load balancers. Each entry has the following fields:
  - **id**: Id of the client security group.
  - **vault_access**: Boolean indicating whether the client should have access to the Vault port (8200) on the load balancers (suitable for nodes needing application access to the cluster).
- **bastion_group_ids**: List of ids of security groups that should have **bastion** access to the Vault cluster.
- **metrics_server_group_ids**: List of ids of security groups that should have **metrics server** access to the Vault cluster.
- **fluentd_security_group**: Optional fluentd security group configuration. It has the following keys:
  - **id**: Id of pre-existing security group to add fluentd rules to.
  - **member_port**: Port the remote fluentd node listens on for the Vault members.
  - **load_balancer_port**: Port the remote fluentd node listens on for the load balancers.

## Output

The module outputs the following variables as output:

- **member_group**: Security group for the Vault members that got created. It contains a resource of type **openstack_networking_secgroup_v2**.
- **load_balancer_group**: Security group for the load balancers that got created. It contains a resource of type **openstack_networking_secgroup_v2**.
