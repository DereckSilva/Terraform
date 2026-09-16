module "vcn" {
  source = "./modules/vcn"

  ocid_compartment = var.ocid_compartment
}

module "instance" {
  source = "./modules/instance"
  
  ocid_compartment = var.ocid_compartment
  availability_domain_sp = var.availability_domain_sp
  subnet_private_id = module.subnets.subnet_privada_id
  subnet_public_id = module.subnets.subnet_publica_id
}

module "gateway" {
  source = "./modules/gateway"

  id_vcn = module.vcn.vcn_id
  ocid_compartment = var.ocid_compartment
}

module "routing" {
  source = "./modules/routing"

  

  ocid_compartment = var.ocid_compartment
  availability_domain_sp = var.availability_domain_sp
  id_vcn = module.vcn.vcn_id
  internet_gateway_id = module.gateway.internet_gateway_id
  nat_gateway_id = module.gateway.nat_gateway_id
}

module "security" {
  source = "./modules/security"

  id_vcn = module.vcn.vcn_id
  ocid_compartment = var.ocid_compartment
}

module "subnets" {
  source = "./modules/subnets"

  ocid_compartment = var.ocid_compartment
  availability_domain_sp = var.availability_domain_sp
  id_vcn = module.vcn.vcn_id
  dhcp_options_id = var.dhcp_options_id
  security_list_private_id = module.security.lista_seguranca_privada_id
  security_list_public_id = module.security.lista_seguranca_publica_id
  route_table_publica_id = module.routing.route_table_publica_igw
  route_table_private_id = module.routing.route_table_privada_nat
}