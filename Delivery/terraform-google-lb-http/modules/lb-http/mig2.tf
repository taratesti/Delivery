data "google_compute_network" "net" {
  project                 = var.project
  name                    = var.network_prefix
}

data "google_compute_subnetwork" "group2" {
  project                  = var.project
  name                     = "${var.network_prefix}-group2"
  region                   = var.group2_region
}

data "template_file" "group-startup-script1" {
  template = file(format("%s/gceme.sh.tpl", path.module))

  vars = {
    PROXY_PATH = ""
  }
}

data "google_compute_router" "group2" {
  project = var.project
  region  = var.group2_region
  name    = "${var.network_prefix}-gw-group2"
  network = data.google_compute_network.net.name 
}

module "mig2_template" {
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  version    = "6.2.0"
  network    = data.google_compute_network.net.self_link
  subnetwork = data.google_compute_subnetwork.group2.self_link
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix    = "${var.network_prefix}-group2"
  startup_script = data.template_file.group-startup-script1.rendered
  tags = [
    "${var.network_prefix}-group2",
    data.google_compute_router.group2.name
  ]
}

module "mig2" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "6.2.0"
  instance_template = module.mig2_template.self_link
  region            = var.group2_region
  hostname          = "${var.network_prefix}-group2"
  target_size       = var.target_size
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = data.google_compute_network.net.self_link
  subnetwork = data.google_compute_subnetwork.group2.self_link
}