terraform {
  backend "gcs" {
    bucket = "lustrous-camera-352403"
    prefix = "vpc_network"
  }
}