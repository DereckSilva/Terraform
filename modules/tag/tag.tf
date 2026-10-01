resource "oci_identity_tag_namespace" "governanca_infra" {
  compartment_id = var.ocid_compartment
  description    = "Governança da Infra"
  name           = "Governanca"
}

resource "oci_identity_tag" "name" {
  description      = "Identifica se o ambiente é de Estudos ou Homologação"
  name             = "Ambiente"
  tag_namespace_id = oci_identity_tag_namespace.governanca_infra.id

  validator {
    validator_type = "ENUM"
    values         = ["Estudos", "Homologação"]
  }
}
