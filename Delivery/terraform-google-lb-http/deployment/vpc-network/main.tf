module "vpc" {
source         =   "../../modules/vpc-network"
network_prefix = "multi-mig-lb-http"
group1_region = "us-west1"
group2_region = "us-east1"
project       = "lustrous-camera-352403"
}