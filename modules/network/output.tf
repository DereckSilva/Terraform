output "nsg_publica_id" {
  value = oci_core_network_security_group.network_sec_group["publica"].id
}

output "nsg_privada_id" {
  value = oci_core_network_security_group.network_sec_group["privada"].id
}