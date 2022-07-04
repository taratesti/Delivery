resource "google_compute_network" "gitlab" {
  name                    = "gitlab"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "gitlab"
  project       = var.project_id
  ip_cidr_range = var.gitlab_nodes_subnet_cidr
  region        = var.region
  network       = google_compute_network.gitlab.self_link

  secondary_ip_range {
    range_name    = "gitlab-cluster-pod-cidr"
    ip_cidr_range = var.gitlab_pods_subnet_cidr
  }

  secondary_ip_range {
    range_name    = "gitlab-cluster-service-cidr"
    ip_cidr_range = var.gitlab_services_subnet_cidr
  }
}
