locals {
  instancias = {
    "publica" = {
      subnet_id = var.subnet_public_id
      assign_public_ip = true
      ssh = true
      display_name = "instancia-publica"
      nsg_ids = [ var.nsgIdPublica ]
    }

    "privada" = {
      subnet_id = var.subnet_private_id
      assign_public_ip = false
      ssh = false
      display_name = "instancia-privada"
      nsg_ids = [ var.nsgIdPrivada ]
    }
  }

  shape = "VM.Standard.E2.1.Micro"
}

data "oci_core_images" "image_ubuntu" {
  compartment_id = var.ocid_compartment
  operating_system = "Canonical Ubuntu"
  operating_system_version = "20.04"
  shape = local.shape
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

resource "oci_core_instance" "instancia_oci" {

  for_each = local.instancias

  availability_domain = var.availability_domain_sp
  compartment_id = var.ocid_compartment
  shape = local.shape
  display_name = each.value.display_name

  create_vnic_details {
    subnet_id = each.value.subnet_id
    assign_public_ip = each.value.assign_public_ip
    display_name = each.value.display_name
    nsg_ids = each.value.nsg_ids
  }

  source_details {
    source_type = "image"
    source_id = data.oci_core_images.image_ubuntu.images[0].id
  }

  metadata = {
    "ssh_authorized_keys" = file("~/.ssh/oci_terraform_learn.pub")
  }
}