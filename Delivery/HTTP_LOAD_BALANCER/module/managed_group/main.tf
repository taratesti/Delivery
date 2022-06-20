
data "google_compute_instance_template" "default" {
 name = "${var.name}-template"
}
resource "google_compute_region_instance_group_manager" "mig" {
  name     = "${var.name}-instance-group"
  region   = var.region
  version {
    instance_template = data.google_compute_instance_template.default.self_link
    name              = "${var.name}-template"
  }
  named_port {
    name = "http"
    port = 80
  }

  base_instance_name = "vm"
  target_size        = 2
}
