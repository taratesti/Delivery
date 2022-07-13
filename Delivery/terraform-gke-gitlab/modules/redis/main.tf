data "google_compute_network" "git" {
  # project_id = var.project_id
  name       = "gitlab"
}
resource "google_redis_instance" "gitlab" {
  # project_id         = var.project_id
  name               = "gitlab"
  tier               = "STANDARD_HA"
  memory_size_gb     = 5
  region             = var.region
  authorized_network = data.google_compute_network.git.self_link
  display_name = "GitLab Redis"
}
