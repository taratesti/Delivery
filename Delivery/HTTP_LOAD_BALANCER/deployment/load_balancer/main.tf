module "ilb" {
    source        = "../../modules/load_balancer"
    project       = var.project
    region        = var.region
    name          = var.name
}
