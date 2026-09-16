output "nat_gateway_id" {
  value = oci_core_nat_gateway.nat_gateway.id
}

output "internet_gateway_id" {
  value = oci_core_internet_gateway.internet_gateway.id
}