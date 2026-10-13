terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "8.29.0"
    }
  }

  backend "oci" {
    bucket    = "descomplicando-terraform-dereck"
    key       = "terraform-bastion.tfstate"
    namespace = "grcw6x1ldad3"
    region    = "sa-saopaulo-1"
  }
}

data "oci_identity_compartments" "compartment_dev" {
  compartment_id = var.ocid_compartment
  name           = "TerraformEstudos"
  state          = "ACTIVE"
}

data "oci_core_subnets" "id-subnet-privada" {
  compartment_id = data.oci_identity_compartments.compartment_dev.compartments[0].id
  vcn_id         = var.vcn_id

  filter {
    name   = "display_name"
    values = ["TestSubNetPriv"]
  }
}

resource "oci_bastion_bastion" "bastion-subnet-privada" {
  bastion_type                 = "STANDARD"
  compartment_id               = data.oci_identity_compartments.compartment_dev.compartments[0].id
  target_subnet_id             = data.oci_core_subnets.id-subnet-privada.subnets[0].id
  client_cidr_block_allow_list = [var.ipLocal]
  max_session_ttl_in_seconds   = 10800
}
