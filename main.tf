provider "vault" {
  token = "master"
  address = "http://127.0.0.1:8200"
}
data "vault_generic_secret" "nomad_bootstrap_token" {
  path = "secret/example/nomad-bootstrap-token"
}
provider "nomad" {
  alias = "bootstrap_token"
  secret_id = data.vault_generic_secret.nomad_bootstrap_token.data["secret-id"]
  address = "http://127.0.0.1:4646"
}

locals {
  nomad_backend_name = "test1"
}

module "dummy_secrets" {
  providers = {
    nomad = nomad.bootstrap_token
  }
  source = "./terraform-vault-dummy-secrets"
  nomad_backend_name = local.nomad_backend_name
}

module "nomad_vault_acl_config" {
  source = "./terraform-vault-nomad-backend-config"
  nomad_backend_name = local.nomad_backend_name
  nomad_acl_management_token = module.dummy_secrets.nomad_acl_token_out.secret_id
  nomad_address_port = "http://127.0.0.1:4646"
}