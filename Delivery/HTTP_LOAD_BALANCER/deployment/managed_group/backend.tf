terraform {
  backend "gcs" {
    bucket = "instance_template"
    prefix = "managed_group"
  }
}