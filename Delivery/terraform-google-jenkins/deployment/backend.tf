terraform {
  backend "gcs" {
    bucket = "instance_template"
    prefix = "jenkins"
  }
}