data "google_compute_network" "default" {
  project                 = var.project
  name                    = var.network_prefix
}

data "google_compute_subnetwork" "group1" {
  project                  = var.project
  name                     = "${var.network_prefix}-group1"
  region                   = var.group1_region
}

data "template_file" "group-startup-script" {
  template = file(format("%s/gceme.sh.tpl", path.module))

  vars = {
    PROXY_PATH = ""
  }
}

data "google_compute_router" "group1" {
  project = var.project
  region  = var.group1_region
  name    = "${var.network_prefix}-gw-group1"
  network = data.google_compute_network.default.name
}

module "mig1_template" {
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  version    = "6.2.0"
  network    = data.google_compute_network.default.self_link
  subnetwork = data.google_compute_subnetwork.group1.self_link
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix          = "${var.network_prefix}-group1"
  startup_script       = data.template_file.group-startup-script.rendered
  source_image_family  = "ubuntu-1804-lts"
  source_image_project = "ubuntu-os-cloud"
  tags = [
    "${var.network_prefix}-group1",
    data.google_compute_router.group1.name
  ]
}

module "mig1" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "6.2.0"
  instance_template = module.mig1_template.self_link
  region            = var.group1_region
  hostname          = "${var.network_prefix}-group1"
  target_size       = var.target_size
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = data.google_compute_network.default.self_link
  subnetwork = data.google_compute_subnetwork.group1.self_link
}
