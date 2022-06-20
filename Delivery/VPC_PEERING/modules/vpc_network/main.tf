#vpc1

resource "google_compute_network" "demo" {
  name                   = "${var.name}-network1"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "test_subnet" {
  name          = "${var.name}-subnetwork1"
  region        = "${var.region}-central1"
  network       = google_compute_network.demo.id
  ip_cidr_range = "10.2.0.0/16"
}

resource "google_compute_firewall" "ssh-rule1" {
  name = "${var.name}-firewall-ssh1"
  network = google_compute_network.demo.id
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = ["default-allow-ssh"]
  source_ranges = ["10.2.0.0/16"]
}

# vpc_network_peering

resource "google_compute_network_peering" "peering1" {
  name         = "${var.name}-peering1"
  network      = google_compute_network.demo.id
  peer_network = google_compute_network.vpc2.id
}
#vpc2

resource "google_compute_network" "vpc2" {
  name                   = "${var.name}-network2"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "${var.name}-subnetwork3"
  region        = "${var.region}-west1"
  network       = google_compute_network.vpc2.id
  ip_cidr_range = "10.0.1.0/24"
}

# Firewall

resource "google_compute_firewall" "ssh-rule" {
  name = "${var.name}-firewall-ssh2"
  network = google_compute_network.vpc2.id
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = ["default-allow-ssh"]
  source_ranges = ["10.0.1.0/26"]
}

# VPC2 Peering

resource "google_compute_network_peering" "peering2" {
  name         = "${var.name}-peering2"
  network      = google_compute_network.vpc2.id
  peer_network = google_compute_network.demo.id
}

