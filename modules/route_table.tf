import {
  to = oci_core_route_table.route_table_publica_igw
  id = var.id_route_table_publica
}

resource "oci_core_route_table" "route_table_privada_nat" {
  compartment_id = var.ocid_compartment
  vcn_id = var.id_vcn
  display_name = "RouteTablePrivada"
  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_route_table" "route_table_publica_igw" {
  compartment_id = var.ocid_compartment
  vcn_id = var.id_vcn
  display_name = "RouteTablePublica"
  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}