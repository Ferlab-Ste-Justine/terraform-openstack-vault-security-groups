resource "openstack_networking_secgroup_v2" "vault_member" {
  name                 = var.member_group_name
  description          = "Security group for vault members"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "vault_load_balancer" {
  name                 = var.load_balancer_group_name
  description          = "Security group for vault load balancers"
  delete_default_rules = true
}

//Allow all outbound traffic from vault members and load balancers
resource "openstack_networking_secgroup_rule_v2" "vault_member_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "vault_member_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "vault_load_balancer_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "vault_load_balancer_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}

//Allow port 8200, 4443, icmp traffic from other members and load balancers
resource "openstack_networking_secgroup_rule_v2" "peer_member_vault_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8200
  port_range_max    = 8200
  remote_group_id   = openstack_networking_secgroup_v2.vault_member.id
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "peer_member_icmp_access_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = openstack_networking_secgroup_v2.vault_member.id
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "peer_member_icmp_access_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = openstack_networking_secgroup_v2.vault_member.id
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "load_balancer_member_vault_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8200
  port_range_max    = 8200
  remote_group_id   = openstack_networking_secgroup_v2.vault_load_balancer.id
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "load_balancer_member_icmp_access_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = openstack_networking_secgroup_v2.vault_load_balancer.id
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "load_balancer_member_icmp_access_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = openstack_networking_secgroup_v2.vault_load_balancer.id
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

//Allow vault and icmp traffic access on load balancers from the clients
resource "openstack_networking_secgroup_rule_v2" "clients_vault_access" {
  for_each          = { for idx, group in var.client_groups : idx => group.id if group.vault_access }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8200
  port_range_max    = 8200
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "clients_icmp_access_v4" {
  for_each          = { for idx, group in var.client_groups : idx => group.id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "clients_icmp_access_v6" {
  for_each          = { for idx, group in var.client_groups : idx => group.id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}

//Allow port 22 and icmp traffic from the bastion
resource "openstack_networking_secgroup_rule_v2" "bastion_member_ssh_access" {
  for_each          = { for idx, id in var.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_member_icmp_access_v4" {
  for_each          = { for idx, id in var.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_member_icmp_access_v6" {
  for_each          = { for idx, id in var.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_load_balancer_ssh_access" {
  for_each          = { for idx, id in var.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_load_balancer_icmp_access_v4" {
  for_each          = { for idx, id in var.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_load_balancer_icmp_access_v6" {
  for_each          = { for idx, id in var.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}

//Allow port 9100 and icmp traffic from metrics server
resource "openstack_networking_secgroup_rule_v2" "metrics_server_member_node_exporter_access" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9100
  port_range_max    = 9100
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "metrics_server_member_icmp_access_v4" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "metrics_server_member_icmp_access_v6" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_member.id
}

resource "openstack_networking_secgroup_rule_v2" "metrics_server_load_balancer_node_exporter_access" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9100
  port_range_max    = 9100
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "metrics_server_load_balancer_icmp_access_v4" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "metrics_server_load_balancer_icmp_access_v6" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.vault_load_balancer.id
}