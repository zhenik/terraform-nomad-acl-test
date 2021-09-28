provider "vault" {
  token = "master"
  address = "http://127.0.0.1:8200"
}

module "some_dependency" {
  source = "./terraform-some-dependency"
  wait_time = "1s"
}

data "vault_generic_secret" "nomad_bootstrap_token" {
  depends_on = [
    module.some_dependency
  ]
  path = "secret/example/nomad-bootstrap-token"
}

# Configure the Nomad provider
provider "nomad" {
  alias     = "bootstrap_token"
  address = "http://127.0.0.1:4646"
  secret_id = data.vault_generic_secret.nomad_bootstrap_token.data["secret-id"]
}

resource "nomad_acl_token" "nomad_management_token" {
  provider = nomad.bootstrap_token
  name = "vault-nomad-management-token-13"
  type = "management"
}
resource "vault_generic_secret" "nomad_management_token_creds" {
  depends_on = [
    nomad_acl_token.nomad_management_token
  ]
  data_json = <<EOT
  {
    "accessor_id": "${nomad_acl_token.nomad_management_token.accessor_id}",
    "secret_id": "${nomad_acl_token.nomad_management_token.secret_id}"
  }
  EOT
  path      = "secret/example/vault-nomad-management-token-13"
}

data "vault_generic_secret" "nomad_bootstrap_token_read" {
  depends_on = [
    vault_generic_secret.nomad_management_token_creds
  ]
  path = "secret/example/vault-nomad-management-token-13"
}

provider "nomad" {
  alias     = "management_token"
  address = "http://127.0.0.1:4646"
  secret_id = data.vault_generic_secret.nomad_bootstrap_token_read.data["secret_id"]
}

resource "nomad_acl_policy" "dev" {
  provider = nomad.management_token
  name        = "tezt1"
  description = "Submit jobs to the dev environment."
  rules_hcl = <<EOT
namespace "dev" {
  policy = "write"
}
EOT
}