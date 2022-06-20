#VPC
resource "google_compute_network" "test" {
name = "${var.name}-network"
auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "test_subnet" {
name = "${var.name}-subnetwork"
region = var.region
network = google_compute_network.test.id
ip_cidr_range = "10.0.1.0/24"
}

# proxy-only subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "l7-ilb-proxy-subnet"
  project       = var.project
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = google_compute_network.test.id
}

resource "google_compute_firewall" "http_firewall" {
  name    = "${var.name}-firewall"
  network = google_compute_network.test.id
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["10.0.1.0/24"]
  target_tags = ["http-server"]
}

resource "google_compute_firewall" "ssh-rule" {
  name = "${var.name}-firewall-ssh"
  network = google_compute_network.test.id
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = ["demo-vm-instance"]
  source_ranges = ["10.0.1.0/24"]
}

# allow all access from IAP and health check ranges
resource "google_compute_firewall" "fw-iap" {
  name          = "l7-ilb-fw-allow-iap-hc"
  project       = var.project
  direction     = "INGRESS"
  network       = google_compute_network.test.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
}
