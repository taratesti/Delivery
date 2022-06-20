data "google_compute_network" "vpc2" {
  name = "terraform-network2"

} 

data "google_compute_subnetwork" "vpc_subnet" {
  name   = "terraform-subnetwork3"
  region = "${var.region}-west1"
}

resource "google_compute_instance" "testing" {
  name         = "${var.name}-instance2"
  machine_type = var.machine_type
  zone         = "${var.region}-west1-b"

  tags = ["dafault-allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = data.google_compute_network.vpc2.self_link
    subnetwork = data.google_compute_subnetwork.vpc_subnet.self_link
    access_config {
      
    }
  }
  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    scopes = ["cloud-platform"]
  }
}

