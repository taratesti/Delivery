data "google_compute_network" "vpc" {
  project                 = var.project
  name                    = var.network_prefix
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
resource "google_compute_router" "group2" {
  project = var.project
  name    = "${var.network_prefix}-gw-group2"
  network = data.google_compute_network.vpc.self_link
  region  = var.group2_region
}

module "cloud-nat-group2" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "1.4.0"
  router     = google_compute_router.group2.name
  project_id = var.project
  region     = var.group2_region
  name       = "${var.network_prefix}-cloud-nat-group2"
}
