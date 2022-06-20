module "instance_template" {
    source        = "../../modules/template"
    project       = var.project
    region        = var.region
    zone          = var.zone
    name          = var.name
    machine_type  = var.machine_type
}
