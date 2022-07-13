module "redis" {
  source = "../../modules/redis"
  region              = var.region
  project             = "${var.project}"
}