data "google_compute_network" "demo" {
  name = "terraform-network1"

} 

data "google_compute_subnetwork" "test_subnet" {
  name   = "terraform-subnetwork1"
  region = "${var.region}-central1"
}

resource "google_compute_instance" "demo" {
  name         = "${var.name}-instance1"
  machine_type = var.machine_type
  zone         = "${var.region}-central1-a"

  tags = ["default-allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = data.google_compute_network.demo.self_link
    subnetwork = data.google_compute_subnetwork.test_subnet.self_link
     access_config {
      
    }
  }
  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["cloud-platform"]
  }
}

