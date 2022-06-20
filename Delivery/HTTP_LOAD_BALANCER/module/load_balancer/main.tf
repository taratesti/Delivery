data "google_compute_network" "ib_net" {
  name = "${var.name}-network"

} 

data "google_compute_subnetwork" "ilb_subnet" {
  name   = "${var.name}-subnetwork"
  region = var.region
}

data "google_compute_subnetwork" "proxy_subnet" {
  name   = "l7-ilb-proxy-subnet"
  region = var.region
}

data "google_compute_region_instance_group" "mig" {
  name = "${var.name}-instance-group"
}

resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "${var.name}-fw"
  region                = var.region
  depends_on            = [data.google_compute_subnetwork.proxy_subnet]
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = data.google_compute_network.ib_net.self_link
  subnetwork            = data.google_compute_subnetwork.ilb_subnet.self_link
  network_tier          = "PREMIUM"
}
# HTTP target proxy
resource "google_compute_region_target_http_proxy" "default" {
  name     = "${var.name}-proxy"
  region   = var.region
  url_map  = google_compute_region_url_map.default.id
}

# URL map
resource "google_compute_region_url_map" "default" {
  name            = "${var.name}-url"
  region          = var.region
  default_service = google_compute_region_backend_service.default.id
}

# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "${var.name}-bs"
  region                = var.region
  port_name             = "http"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    balancing_mode = "UTILIZATION"  
    group           = data.google_compute_region_instance_group.mig.self_link
    capacity_scaler = 1.0
  }
}

# health check
resource "google_compute_region_health_check" "default" {
  name     = "${var.name}-hc"
  region   = var.region
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}
