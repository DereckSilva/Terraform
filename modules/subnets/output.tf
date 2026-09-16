output "subnet_publica_id" {
  value = oci_core_subnet.subnet["publica"].id
}

output "subnet_privada_id" {
  value = oci_core_subnet.subnet["privada"].id
}