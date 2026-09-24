# não foi aplicado na nuvem
resource "oci_containerengine_cluster" "cluster_estudo" {
  name               = "ContainerEstudo"
  compartment_id     = var.compartment_id
  vcn_id             = var.id_vcn
  kubernetes_version = var.k8s_version
  type               = "BASIC_CLUSTER"

  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }
  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = var.subnet_id
  }
}
