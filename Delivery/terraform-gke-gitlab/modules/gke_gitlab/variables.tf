variable "project" {
  type = string
}

variable "gke_version" {
  description = "Version of GKE to use for the GitLab cluster"
}
 
variable "region" {
  type = string
}

variable "gke_machine_type" {
  type = string
}

variable "gitlab_db_password" {
  description = "Password for the GitLab Postgres user"
}

variable "gitlab_address_name" {
   description = "Name of the address to use for GitLab ingress"
}

variable "domain" {
 description = "Domain for hosting gitlab functionality (ie mydomain.com would access gitlab at gitlab.mydomain.com)"
}

variable "certmanager_email" {
  description = "Email used to retrieve SSL certificates from Let's Encrypt"
}

variable "gitlab_runner_install" {
   description = "Choose whether to install the gitlab runner in the cluster"
}

variable "helm_chart_version" {
   description = "Helm chart version to install during deployment"
}

variable "gitlab_db_random_prefix" {
 description = "Sets random suffix at the end of the Cloud SQL instance name."
}
variable "gitlab_db_name" {
  description = "Instance name for the GitLab Postgres database."
}
variable "gitlab_deletion_protection" {
  type = bool
}
