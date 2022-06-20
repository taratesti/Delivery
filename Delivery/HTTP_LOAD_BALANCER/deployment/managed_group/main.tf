module "managed_group" {
    source        = "../../modules/managed_group"
    project       = var.project
    region        = var.region
    zone          = var.zone
    name          = var.name
    machine_type  = var.machine_type
}
