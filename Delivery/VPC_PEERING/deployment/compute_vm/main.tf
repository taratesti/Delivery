module "instance_1" {
  source       = "../../modules/compute_vm"
  project      = var.project
  region       = var.region
  name         = var.name
  machine_type = var.machine_type
}