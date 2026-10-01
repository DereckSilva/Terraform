resource "oci_core_network_security_group_security_rule" "network-sec-rule-priv-e" {
  network_security_group_id = var.nsg_privada_id
  protocol                  = 6
  direction                 = "EGRESS"

  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
}

