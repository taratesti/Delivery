terraform {
  backend "gcs" {
    bucket = "http-lb"
    prefix = "vpc_network"
  }
}