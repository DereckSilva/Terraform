# REFAZER ARQUIVO PARA ELIMINAR DUPLICIDADES
import {
  to = oci_core_subnet.subnet_privada
  id = var.id_subnt_privada
}

resource "oci_core_subnet" "subnet_privada" {
  availability_domain = var.availability_domain_sp
  cidr_block = "10.0.1.0/24"
  vcn_id = var.id_vcn
  compartment_id = var.ocid_compartment
  display_name = "TestSubNetPriv"
  dns_label = "testSubNetPriv"
  dhcp_options_id = var.dhcp_options_id
  route_table_id = oci_core_route_table.route_table_privada_nat.id # alterar esse route table para usar route table para privada (NAT GATEWAY)
  prohibit_public_ip_on_vnic = true # as instâncias na subnet não vão ter IP's públicos
  security_list_ids = [ oci_core_security_list.lista_seguranca_privada.id ]
}

resource "oci_core_subnet" "subnet_publica" {
  availability_domain = var.availability_domain_sp
  cidr_block = "10.0.5.0/24"
  vcn_id = var.id_vcn
  compartment_id = var.ocid_compartment
  display_name = "TestSubNetPub"
  dns_label = "testSubNetPub"
  dhcp_options_id = var.dhcp_options_id
  route_table_id = var.route_table_publica_id
  prohibit_public_ip_on_vnic = false # declarando explicitamente a fim de estudo (defini IP público para as instâncias na subnet)
}