locals {
  shapeF = "VM.Standard.A1.Flex"
}

data "oci_containerengine_node_pool_option" "node_pool_image" {
  node_pool_option_id   = "all"
  compartment_id        = var.compartment_id
  node_pool_k8s_version = var.k8s_version
  node_pool_os_arch     = "AARCH64"
}

resource "oci_containerengine_node_pool" "workers-flex" {
  count              = 1 # node pool
  compartment_id     = var.compartment_id
  name               = "worker-estudo-flex"
  cluster_id         = var.cluster_id
  kubernetes_version = var.k8s_version

  node_shape = local.shapeF

  defined_tags  = { "enviroment" = "development", "namespace" = "teste-estudo" }
  freeform_tags = { "type-vm" = "flex" }

  node_shape_config {
    memory_in_gbs = 12
    ocpus         = 1
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = data.oci_containerengine_node_pool_option.node_pool_image.sources[0].image_id
  }

  node_config_details {
    placement_configs {
      availability_domain = var.availability_domain_sp
      subnet_id           = var.subnet_id
    }

    node_pool_pod_network_option_details {
      cni_type          = "OCI_VCN_IP_NATIVE"
      max_pods_per_node = 10 # qtd de pods dentro do node max
      pod_nsg_ids       = [var.nsg_id]
      pod_subnet_ids    = [var.subnet_id]
    }
    size = 2 # qtd de nodes
  }

  ssh_public_key = file("~/.ssh/oci_terraform_learn.pub")

}
