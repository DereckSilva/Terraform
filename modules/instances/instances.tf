locals {
  instancias = {
    "instancia-front" = {
      display_name = "instancia-front"
    }
    "instancia-back" = {
      display_name = "instancia-back"
    }
  }
  shape = "VM.Standard.E2.1.Micro"
}

data "oci_core_images" "image_ubuntu" {
  compartment_id           = var.ocid_compartment
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = local.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "instancia_oci" {

  for_each = local.instancias

  availability_domain = var.availability_domain_sp
  compartment_id      = var.ocid_compartment
  shape               = local.shape
  display_name        = each.value.display_name

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = false
    display_name     = each.value.display_name
    nsg_ids          = [var.nsg_ids]
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.image_ubuntu.images[0].id
  }

  metadata = {
    "ssh_authorized_keys" = file("~/.ssh/oci_terraform_learn.pub")
  }
}
