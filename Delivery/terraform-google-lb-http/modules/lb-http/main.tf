data "google_compute_network" "vpc" {
  project                 = var.project
  name                    = var.network_prefix
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
data "google_compute_router" "group3" {
  project = var.project
  region  = var.group1_region
  name    = "${var.network_prefix}-gw-group1"
  network = data.google_compute_network.vpc.name
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
data "google_compute_router" "group4" {
  project = var.project
  name    = "${var.network_prefix}-gw-group2"
  region  = var.group2_region
  network = data.google_compute_network.vpc.name
}

# [START cloudloadbalancing_ext_http_gce]
module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 5.1"
  name    = var.network_prefix
  project = var.project
  target_tags = [
    "${var.network_prefix}-group1",
    data.google_compute_router.group3.name,
    "${var.network_prefix}-group2",
    data.google_compute_router.group4.name
  ]
  firewall_networks = [data.google_compute_network.vpc.name]

  backends = {
    default = {

      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = module.mig2.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
        {
          group                        = module.mig2.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}