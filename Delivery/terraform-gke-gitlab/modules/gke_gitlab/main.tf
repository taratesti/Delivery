data "google_compute_network" "lab" {
  project    = var.project
  name       = "gitlab"
}

data "google_compute_subnetwork" "subnet"{
  project    = var.project
  name       = "gitlab"
  region     = var.region
}

data "google_redis_instance" "gitlab" {
  project    = var.project
  region     = var.region
  name       = "gitlab"
}

#creating service account google storage

resource "google_service_account" "gitlab_gcs" {
  project         = var.project
  account_id      =  "gitlab-gcs"
  display_name    = "GitLab Cloud Storage"
}

resource "google_service_account_key" "gitlab_gcs" {
  service_account_id = google_service_account.gitlab_gcs.name
}

resource "google_project_iam_member" "project" {
  project    = var.project
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.gitlab_gcs.email}"
}

#gke-auth
module "gke_auth" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version = "~> 10.0"

  project_id      = var.project
  cluster_name = module.gke.name
  location     = module.gke.location

  depends_on = [time_sleep.sleep_for_cluster_fix_helm_6361]
}
#helm provider

provider "helm" {
  kubernetes {
    #load_config_file       = false
    cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
    host                   = module.gke_auth.host
    token                  = module.gke_auth.token
  }
}

#Kubernetes Provider

provider "kubernetes" {
  #load_config_file = false

  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  host                   = module.gke_auth.host
  token                  = module.gke_auth.token
}

#network


resource "google_compute_address" "gitlab1" {
  name            = "gitlab"
  project         = var.project
  region          = var.region
  address_type    = "EXTERNAL"
  description     = "Gitlab Ingress IP"
  count           = var.gitlab_address_name == "" ? 1 : 0
}

#database

locals {
  gitlab_db_name = var.gitlab_db_random_prefix ? "${var.gitlab_db_name}-${random_id.suffix[0].hex}" : var.gitlab_db_name
}

resource "random_id" "suffix" {
  count = var.gitlab_db_random_prefix ? 1 : 0

  byte_length = 4
}

resource "google_compute_global_address" "gitlab_sql" {
  provider      = google-beta
  project       = var.project
  name          = "gitlab-sql"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  network       = data.google_compute_network.lab.self_link
  address       = "10.1.0.0"
  prefix_length = 16
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = data.google_compute_network.lab.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.gitlab_sql.name]
}

resource "google_sql_database_instance" "gitlab_db" {
  depends_on          = [google_service_networking_connection.private_vpc_connection]
  project             = var.project
  name                = local.gitlab_db_name
  region              = var.region
  database_version    = "POSTGRES_11"
  deletion_protection = var.gitlab_deletion_protection

  settings {
    tier            = "db-custom-4-15360"
    disk_autoresize = true

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = data.google_compute_network.lab.self_link
    }
  }
}

resource "google_sql_database" "gitlabhq_production" {
  project    = var.project
  name       = "gitlabhq_production"
  instance   = google_sql_database_instance.gitlab_db.name
  depends_on = [google_sql_user.gitlab]
}

resource "random_string" "autogenerated_gitlab_db_password" {
  length  = 16
  special = false
}

resource "google_sql_user" "gitlab" {
  project     = var.project
  name        = "gitlab"
  instance    = google_sql_database_instance.gitlab_db.name

  password    = var.gitlab_db_password != "" ? var.gitlab_db_password : random_string.autogenerated_gitlab_db_password.result
}

#gke

module "gke" {
  source             = "terraform-google-modules/kubernetes-engine/google"
  project_id         = var.project
  # Create an implicit dependency on service activation
  name               = "gitlab"
  region             = var.region
  regional           = true
  kubernetes_version = var.gke_version

  remove_default_node_pool = true
  initial_node_count       = 1

  network           = data.google_compute_network.lab.name
  subnetwork        = data.google_compute_subnetwork.subnet.name
  ip_range_pods     = "gitlab-cluster-pod-cidr"
  ip_range_services = "gitlab-cluster-service-cidr"

  issue_client_certificate = true

  node_pools = [
    {
      name         = "gitlab"
      autoscaling  = false
      machine_type = var.gke_machine_type
      node_count   = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "kubernetes_storage_class" "pd-ssd" {
  metadata {
    name = "pd-ssd"
  }

  storage_provisioner = "kubernetes.io/gce-pd"

  parameters = {
    type = "pd-ssd"
  }

  depends_on = [time_sleep.sleep_for_cluster_fix_helm_6361]
}

resource "kubernetes_secret" "gitlab_pg" {
  metadata {
    name = "gitlab-pg"
  }

  data = {
    password = var.gitlab_db_password != "" ? var.gitlab_db_password : random_string.autogenerated_gitlab_db_password.result
  }

  depends_on = [time_sleep.sleep_for_cluster_fix_helm_6361]
}

resource "kubernetes_secret" "gitlab_rails_storage" {
  metadata {
    name = "gitlab-rails-storage"
  }

  data = {
    connection = <<EOT
provider: Google
google_project: ${var.project}
google_client_email: ${google_service_account.gitlab_gcs.email}
google_json_key_string: '${base64decode(google_service_account_key.gitlab_gcs.private_key)}'
EOT
  }

  depends_on = [time_sleep.sleep_for_cluster_fix_helm_6361]
}

resource "kubernetes_secret" "gitlab_registry_storage" {
  metadata {
    name = "gitlab-registry-storage"
  }

  data = {
    "gcs.json" = <<EOT
${base64decode(google_service_account_key.gitlab_gcs.private_key)}
EOT
    storage    = <<EOT
gcs:
  bucket: ${var.project}-registry
  keyfile: /etc/docker/registry/storage/gcs.json
EOT
  }

  depends_on = [time_sleep.sleep_for_cluster_fix_helm_6361]
}


resource "kubernetes_secret" "gitlab_gcs_credentials" {
  metadata {
    name = "google-application-credentials"
  }

  data = {
    gcs-application-credentials-file = base64decode(google_service_account_key.gitlab_gcs.private_key)
  }

  depends_on = [time_sleep.sleep_for_cluster_fix_helm_6361]
}

data "google_compute_address" "gitlab" {
  name   = var.gitlab_address_name
  region = var.region

  # Do not get data if the address is being created as part of the run
  count = var.gitlab_address_name == "" ? 0 : 1
}

locals {
  gitlab_address = var.gitlab_address_name == "" ? google_compute_address.gitlab1.0.address : data.google_compute_address.gitlab.0.address
  domain         = var.domain != "" ? var.domain : "${local.gitlab_address}.nip.io"
}

data "template_file" "helm_values" {
  template = file("${path.module}/values.yaml.tpl")

  vars = {
    DOMAIN                = local.domain
    INGRESS_IP            = local.gitlab_address
    DB_PRIVATE_IP         = google_sql_database_instance.gitlab_db.private_ip_address
    REDIS_PRIVATE_IP      = data.google_redis_instance.gitlab.host
    PROJECT               = var.project
    CERT_MANAGER_EMAIL    = var.certmanager_email
    GITLAB_RUNNER_INSTALL = var.gitlab_runner_install
  }
}

resource "time_sleep" "sleep_for_cluster_fix_helm_6361" {
  create_duration  = "180s"
  destroy_duration = "180s"
  depends_on       = [module.gke.endpoint, google_sql_database.gitlabhq_production]
}

resource "helm_release" "gitlab" {
  name       = "gitlab"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab"
  version    = var.helm_chart_version
  timeout    = 1200

  values = [data.template_file.helm_values.rendered]

  depends_on = [
    data.google_redis_instance.gitlab,
    google_sql_user.gitlab,
    kubernetes_storage_class.pd-ssd,
    kubernetes_secret.gitlab_pg,
    kubernetes_secret.gitlab_rails_storage,
    kubernetes_secret.gitlab_registry_storage,
    kubernetes_secret.gitlab_gcs_credentials,
    time_sleep.sleep_for_cluster_fix_helm_6361,
  ]
}
