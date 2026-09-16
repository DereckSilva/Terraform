
resource "oci_core_vcn" "vcn_internal" {
  cidr_block = "10.0.0.0/16"
  compartment_id = var.ocid_compartment
  dns_label = "internal"
  display_name = "minhaVCN"
}