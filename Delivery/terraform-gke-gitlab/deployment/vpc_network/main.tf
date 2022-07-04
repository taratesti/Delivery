module "vpc_net" {
  source = "../../modules/vpc_network"
  project_id                   = "lustrous-camera-352403"
  region                       = "us-central1"
  gitlab_nodes_subnet_cidr     = "10.0.0.0/16"
  gitlab_pods_subnet_cidr      = "10.3.0.0/16"
  gitlab_services_subnet_cidr  = "10.2.0.0/16"
}