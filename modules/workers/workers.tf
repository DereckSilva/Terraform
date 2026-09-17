# não foi aplicado na nuvem
resource "oci_containerengine_node_pool" "worker" {
  compartment_id = var.compartment_id
  name = "worker-estudo"
  cluster_id = var.cluster_id

  node_shape = "VM.Standard.A1.Flex"
}