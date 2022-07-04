terraform {
  backend "gcs" {
    bucket = "http-lb"
    prefix = "mig"
  }
}