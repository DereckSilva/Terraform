moved {
  from = oci_core_vcn.vcn_internal
  to   = module.vcn.oci_core_vcn.vcn_internal
}

moved {
  from = oci_core_subnet.subnet
  to   = module.subnets.oci_core_subnet.subnet
}

moved {
  from = oci_core_instance.instancia_oci
  to   = module.instance.oci_core_instance.instancia_oci
}

moved {
  from = oci_core_security_list.lista_seguranca_publica
  to   = module.security.oci_core_security_list.lista_seguranca_publica
}

moved {
  from = oci_core_security_list.lista_seguranca_privada
  to   = module.security.oci_core_security_list.lista_seguranca_privada
}

moved {
  from = oci_core_route_table.route_table_privada_nat
  to   = module.routing.oci_core_route_table.route_table_privada_nat
}

moved {
  from = oci_core_route_table.route_table_publica_igw
  to   = module.routing.oci_core_route_table.route_table_publica_igw
}

moved {
  from = oci_core_internet_gateway.internet_gateway
  to   = module.gateway.oci_core_internet_gateway.internet_gateway
}

moved {
  from = oci_core_nat_gateway.nat_gateway
  to   = module.gateway.oci_core_nat_gateway.nat_gateway
}
