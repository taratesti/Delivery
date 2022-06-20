#instance template :'

data "google_compute_network" "test" {
  name = "${var.name}-network"

} 

data "google_compute_subnetwork" "test_subnet" {
  name   = "${var.name}-subnetwork"
  region = var.region
}

#instance template :'

resource "google_compute_instance_template" "default" {
  name         = "${var.name}-template"
  machine_type = var.machine_type
  disk {
    source_image = "mywebserver"
    auto_delete  = true
    boot         = true
  }
network_interface {
        network    = data.google_compute_network.test.self_link
        subnetwork = data.google_compute_subnetwork.test_subnet.self_link
        access_config {

        }
}
tags = ["http-server", "demo-vm-instance"]
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    scopes = ["cloud-platform"]
  }
 } 
