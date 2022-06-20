terraform {
  backend "gcs" {
    bucket = "instance_template"
    prefix = "load_balancer"
  }
}