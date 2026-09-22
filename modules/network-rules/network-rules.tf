resource "oci_core_network_security_group_security_rule" "network-sec-rule-pub-i" {
  network_security_group_id = var.nsg_publica_id
  protocol = 6
  direction = "INGRESS"

  source = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
}

#######################################################################################

resource "oci_core_network_security_group_security_rule" "network-sec-rule-priv-i" {
  network_security_group_id = var.nsg_privada_id
  protocol = 6
  direction = "INGRESS"

  source = "10.0.1.0/24"
  source_type = "CIDR_BLOCK"

  # entender a questão da liberação de portas
  tcp_options {
    source_port_range {
      min = 1234
      max = 1234
    }
  }
}

resource "oci_core_network_security_group_security_rule" "network-sec-rule-priv-e" {
  network_security_group_id = var.nsg_privada_id
  protocol = 6
  direction = "EGRESS"
  
  destination = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
}

