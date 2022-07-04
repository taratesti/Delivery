resource "google_compute_network" "default" {
  project                 = var.project
  name                    = var.network_prefix
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "group1" {
  project                  = var.project
  name                     = "${var.network_prefix}-group1"
  ip_cidr_range            = "10.126.0.0/20"
  network                  = google_compute_network.default.self_link
  region                   = var.group1_region
  private_ip_google_access = true
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)

resource "google_compute_subnetwork" "group2" {
  project                  = var.project
  name                     = "${var.network_prefix}-group2"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = google_compute_network.default.self_link
  region                   = var.group2_region
  private_ip_google_access = true
}

        