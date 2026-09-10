locals {
  instancias = {
    "publica" = {
      subnet_id = oci_core_subnet.subnet_publica.id
      assign_public_ip = true
      ssh = true
      display_name = "instancia-publica"
    }

    "privada" = {
      subnet_id = oci_core_subnet.subnet_privada.id
      assign_public_ip = false
      ssh = false
      display_name = "instancia-privada"
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
  }

  source_details {
    source_type = "image"
    source_id = data.oci_core_images.image_ubuntu.images[0].id
  }

  metadata = each.value.ssh ? {
    "ssh_authorized_keys" = file("~/.ssh/oci_terraform_learn.pub")
  } : {}
}