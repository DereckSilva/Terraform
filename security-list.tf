import {
  to = oci_core_security_list.lista_seguranca_publica
  id = var.id_security_list
}

resource "oci_core_security_list" "lista_seguranca_publica" {
  compartment_id = var.ocid_compartment
  vcn_id = oci_core_vcn.vcn_internal.id
  display_name = "lista_seguranca_publica"

  ingress_security_rules {
    protocol = "6"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 22
      max = 22
    }
  }
  
  ingress_security_rules {
    protocol = "1"
    source = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"

    icmp_options {
      code = -1
      type = 3
    }
  }

  ingress_security_rules {
    protocol = "1"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    icmp_options {
      code = 4
      type = 3
    }
  }

  ingress_security_rules {
    protocol = "1"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    icmp_options {
      type = 8
      code = -1
    }
  }

  egress_security_rules {
    protocol = "6"
    destination = "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"

    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "lista_seguranca_privada" {
  compartment_id = var.ocid_compartment
  vcn_id = oci_core_vcn.vcn_internal.id
  display_name = "lista_seguranca_privada"

  ingress_security_rules {
    protocol = "6"
    source = "10.0.5.0/24"
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 22 # corrigir com a atriuição da chave ssh para a instancia privada
      max = 22 # corrigir com a atriuição da chave ssh para a instancia privada
    }
  }

  ingress_security_rules {
    protocol = "1"
    source = "10.0.5.0/24"
    source_type = "CIDR_BLOCK"

    icmp_options {
      code = -1
      type = 8
    }
  }
  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
}
