resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.ocid_compartment
  vcn_id = oci_core_vcn.vcn_internal.id
  display_name = "meu_internet_gateway"
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.ocid_compartment
  vcn_id = oci_core_vcn.vcn_internal.id
  display_name = "meu_nat_gateway"
}