resource "oci_core_route_table" "route_table_privada_nat" {
  compartment_id = var.ocid_compartment
  vcn_id = var.id_vcn
  display_name = "RouteTablePrivada"
  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = var.nat_gateway_id
  }
}

resource "oci_core_route_table" "route_table_publica_igw" {
  compartment_id = var.ocid_compartment
  vcn_id = var.id_vcn
  display_name = "RouteTablePublica"
  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = var.internet_gateway_id
  }
}