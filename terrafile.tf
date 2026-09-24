module "vcn" {
  source = "./modules/vcn"

  ocid_compartment = module.compartment.compartment_dev
}

module "compartment" {
  source = "./modules/compartment"

  compartment_id = var.ocid_compartment
}

module "gateway" {
  source = "./modules/gateway"

  id_vcn           = module.vcn.vcn_id
  ocid_compartment = module.compartment.compartment_dev
}

module "routing" {
  source = "./modules/routing"



  ocid_compartment       = module.compartment.compartment_dev
  availability_domain_sp = var.availability_domain_sp
  id_vcn                 = module.vcn.vcn_id
  internet_gateway_id    = module.gateway.internet_gateway_id
  nat_gateway_id         = module.gateway.nat_gateway_id
}

module "security" {
  source = "./modules/security"

  id_vcn           = module.vcn.vcn_id
  ocid_compartment = module.compartment.compartment_dev
}

module "subnets" {
  source = "./modules/subnets"

  ocid_compartment         = module.compartment.compartment_dev
  availability_domain_sp   = var.availability_domain_sp
  id_vcn                   = module.vcn.vcn_id
  dhcp_options_id          = var.dhcp_options_id
  security_list_private_id = module.security.lista_seguranca_privada_id
  security_list_public_id  = module.security.lista_seguranca_publica_id
  route_table_publica_id   = module.routing.route_table_publica_igw
  route_table_private_id   = module.routing.route_table_privada_nat
}

module "cluster" {
  source = "./modules/cluster"

  compartment_id = module.compartment.compartment_dev
  id_vcn         = module.vcn.vcn_id
  k8s_version    = "v1.36.2"
  subnet_id      = module.subnets.subnet_publica_id
}

module "worker" {
  source = "./modules/workers"

  cluster_id             = module.cluster.cluster_id
  compartment_id         = module.compartment.compartment_dev
  k8s_version            = "v1.36.2"
  subnet_id              = module.subnets.subnet_privada_id
  availability_domain_sp = var.availability_domain_sp
  nsg_id                 = module.network.nsg_privada_id
}

module "network" {
  source = "./modules/network"

  vcn_id         = module.vcn.vcn_id
  compartment_id = module.compartment.compartment_dev
}

module "network_rules" {
  source = "./modules/network-rules"

  nsg_privada_id = module.network.nsg_privada_id
  nsg_publica_id = module.network.nsg_publica_id
}
