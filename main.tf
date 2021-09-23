provider "vault" {
  token = "master"
  address = "http://127.0.0.1:8200"
}

module "some_dependency" {
  source = "./terraform-some-dependency"
//  wait_time = "1s"
}

data "vault_generic_secret" "nomad_bootstrap_token" {
  depends_on = [
    module.some_dependency
  ]
//  disable_read = true
  path = "secret/example/nomad-bootstrap-token"
}

# Configure the Nomad provider
provider "nomad" {
  alias     = "bootstrap_token"
  address = "http://127.0.0.1:4646"
  secret_id = data.vault_generic_secret.nomad_bootstrap_token.data["secret-id"]
}
resource "nomad_acl_policy" "dev" {
  provider = nomad.bootstrap_token
  name        = "tezt1"
  description = "Submit jobs to the dev environment."
  rules_hcl = <<EOT
namespace "dev" {
  policy = "write"
}
EOT
}