output "route_table_privada_nat" {
  value = oci_core_route_table.route_table_privada_nat.id
}

output "route_table_publica_igw" {
  value = oci_core_route_table.route_table_publica_igw.id
}