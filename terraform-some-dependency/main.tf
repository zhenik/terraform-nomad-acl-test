variable "wait_time" {
  default = "2s"
}
resource "time_sleep" "simulate_nomad_vm_deploy" {
  create_duration = var.wait_time
}
data "vault_generic_secret" "nomad_bootstrap_token" {
  path = "secret/example/nomad-bootstrap-token"
}


output "nomad_url" {
  value = "http://127.0.0.1:4646"
}
output "bootstrap_token_secret_id" {
  value = data.vault_generic_secret.nomad_bootstrap_token.data["secret-id"]
}
