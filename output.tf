output "member_group" {
  value = openstack_networking_secgroup_v2.vault_member
}

output "load_balancer_group" {
  value = openstack_networking_secgroup_v2.vault_load_balancer
}

output "load_balancer_tunnel_group" {
  value = openstack_networking_secgroup_v2.vault_load_balancer_tunnel
}