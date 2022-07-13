module "gke-git" {
source                 = "../../modules/gke_gitlab"
project_id             = "${var.project_id}"
region                 = var.region
gke_version            = "1.20"
gke_machine_type       = "n1-standard-4"
gitlab_db_password     = ""
gitlab_address_name    = ""
domain                 = ""
certmanager_email      = "tarakeswariterapalli@gmail.com"
gitlab_runner_install  = true
helm_chart_version     = "4.2.4"
gitlab_db_name     = "gitlab-dbs"
gitlab_db_random_prefix = false
gitlab_deletion_protection = false
}