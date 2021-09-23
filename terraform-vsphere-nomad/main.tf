variable "wait_time" {
  default = "3s"
}
resource "time_sleep" "simulate_nomad_vm_deploy" {
  create_duration = var.wait_time
}