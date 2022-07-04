terraform {
  backend "gcs" {
    bucket = "http-lb"
    prefix = "http-lb"
  }
}