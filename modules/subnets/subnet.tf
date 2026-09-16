

locals {
  subnets = {
    "publica" = {
      display_name = "TestSubNetPub"
      dns_label = "testSubNetPub"
      cidr_block = "10.0.1.0/24"
      prohibit_public_ip_on_vnic = false
      security_list_ids = var.security_list_public_id
      route_table_id = var.route_table_publica_id
    }

    "privada" = {
      display_name = "TestSubNetPriv"
      dns_label = "testSubNetPriv"
      cidr_block = "10.0.5.0/24"
      prohibit_public_ip_on_vnic = true
      security_list_ids = var.security_list_private_id
      route_table_id = var.route_table_private_id
    }
  }
}

resource "oci_core_subnet" "subnet" {

  for_each = local.subnets

  availability_domain = var.availability_domain_sp
  cidr_block = each.value.cidr_block
  vcn_id = var.id_vcn
  compartment_id = var.ocid_compartment
  display_name = each.value.display_name
  dns_label = each.value.dns_label
  dhcp_options_id = var.dhcp_options_id
  route_table_id = each.value.route_table_id
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic
  security_list_ids = [ each.value.security_list_ids ]
}