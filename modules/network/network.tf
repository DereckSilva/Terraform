locals {
  network = {
    "publica" = {
      display_name = "nsg-publica"
    }
    "privada" = {
      display_name = "nsg-privada"
    }
  }
}

resource "oci_core_network_security_group" "network_sec_group" {
  for_each = local.network

  vcn_id = var.vcn_id
  compartment_id = var.compartment_id
  display_name = each.value.display_name
}