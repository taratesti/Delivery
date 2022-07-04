data "google_compute_network" "default" {
  project                 = var.project
  name                    = var.network_prefix
}

resource "google_compute_router" "group1" {
  project = var.project
  name    = "${var.network_prefix}-gw-group1"
  network = data.google_compute_network.default.self_link
  region  = var.group1_region
}

module "cloud-nat-group1" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "1.4.0"
  router     = google_compute_router.group1.name
  project_id = var.project
  region     = var.group1_region
  name       = "${var.network_prefix}-cloud-nat-group1"
}
