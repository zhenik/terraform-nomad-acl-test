variable "nomad_backend_name" {
  type = string
  default = null
  description = "Vault nomad backend name"
}
resource "nomad_acl_token" "nomad_management_token" {
  name = "${var.nomad_backend_name}-management-token"
  type = "management"
}
resource "vault_generic_secret" "nomad_management_token" {
  path = "secret/${var.nomad_backend_name}-management-token"
  data_json = jsonencode(nomad_acl_token.nomad_management_token)
}
output "nomad_acl_token_out" {
  value = nomad_acl_token.nomad_management_token
  description = "Nomad ACL management token resource output"
}