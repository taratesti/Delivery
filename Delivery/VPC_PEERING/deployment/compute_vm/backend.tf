terraform {
  backend "gcs" {
    bucket = "lustrous-camera-352403"
    prefix = "vm_instance"
  }
}
