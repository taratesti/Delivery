module "redis" {
  source = "../../modules/redis"
  region              = var.region
  project_id             = "${var.project_id}"
}