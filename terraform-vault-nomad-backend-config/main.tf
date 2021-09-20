variable "nomad_backend_name" {
  type = string
  default = null
  description = "Vault nomad backend name"
}
variable "nomad_address_port" {
  type = string
  default = null
  description = "Nomad URL:PORT address"
}
variable "nomad_acl_management_token" {
  type = string
  default = null
  description = "Nomad ACL management token"
}

# Vault secrets enable -path={{ complete_name }} nomad
resource "vault_nomad_secret_backend" "config" {
  backend = var.nomad_backend_name
  description = "Nomad ${var.nomad_backend_name} backend"
  address = var.nomad_address_port
  token = var.nomad_acl_management_token
  ttl = "86400"
}