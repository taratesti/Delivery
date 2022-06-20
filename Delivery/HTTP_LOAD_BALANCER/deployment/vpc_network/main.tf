module "vpc_network" {
    source        = "../../modules/vpc_network"
    project       = var.project
    region        = var.region
    name          = var.name
}
