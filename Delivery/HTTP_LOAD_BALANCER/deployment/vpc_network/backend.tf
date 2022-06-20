terraform {
  backend "gcs" {
    bucket = "instance_template"
    prefix = "vpc_network"
  }
}