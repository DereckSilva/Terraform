terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "8.29.0"
    }
  }

  backend "oci" {
    bucket = "descomplicando-terraform-dereck"
    key = "terraform-test.tfstate"
    namespace = "grcw6x1ldad3"
    region = "sa-saopaulo-1"
  }
}

resource "oci_core_vcn" "vcn_internal" {
  cidr_block = "10.0.0.0/16"
  compartment_id = var.ocid_compartment
  dns_label = "internal"
  display_name = "minhaVCN"
}

provider "oci" {
  config_file_profile = "DEFAULT" # perfil que será acessado a partir desse arquivo
}
