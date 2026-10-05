locals {
  instancias = {
    "servidor" = {
      display_name = "instancia-privada-control-plane"
    }
    "agente" = {
      display_name = "instancia-privada-worker"
    }
  }
  shape = "VM.Standard.A1.Flex"
}

data "oci_core_images" "image_ubuntu" {
  compartment_id           = var.ocid_compartment
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "20.04"
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

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  metadata = {
    "ssh_authorized_keys" = file("~/.ssh/oci_terraform_learn.pub")
  }
}
