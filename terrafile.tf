module "servers" {
  source = "./modules"

  id_route_table_publica = var.id_route_table_publica
  availability_domain_sp = var.availability_domain_sp
  id_security_list = var.id_security_list
  id_subnt_privada = var.id_subnt_privada
  ocid_compartment = var.ocid_compartment
  id_vcn = var.id_vcn
  dhcp_options_id = var.dhcp_options_id
  route_table_publica_id = var.route_table_publica_id
}