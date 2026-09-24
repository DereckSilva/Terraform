resource "oci_identity_compartment" "compartment-projetos" {
  description    = "Projeto de estudo de Nuvem"
  name           = "TerraformEstudos"
  compartment_id = var.compartment_id
}
