variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "gitlab_nodes_subnet_cidr" {
  description = "Cidr range to use for gitlab GKE nodes subnet"
}

variable "gitlab_pods_subnet_cidr" {
  description = "Cidr range to use for gitlab GKE pods subnet"
}

variable "gitlab_services_subnet_cidr" {
   description = "Cidr range to use for gitlab GKE services subnet"
}
