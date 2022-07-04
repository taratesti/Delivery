resource "google_storage_bucket" "gitlab-backups" {
  name          = "${var.project_id}-gitlab-backups"
  project       = var.project_id
  location      = var.region
  force_destroy = var.allow_force_destroy
}

resource "google_storage_bucket" "gitlab-uploads" {
  name          = "${var.project_id}-gitlab-uploads"
  project       = var.project_id
  location      = var.region
  force_destroy = var.allow_force_destroy
}

resource "google_storage_bucket" "gitlab-artifacts" {
  name          = "${var.project_id}-gitlab-artifacts"
  project       = var.project_id
  location      = var.region
  force_destroy = var.allow_force_destroy
}

resource "google_storage_bucket" "git-lfs" {
  name          = "${var.project_id}-git-lfs"
  project       = var.project_id
  location      = var.region
  force_destroy = var.allow_force_destroy
}

resource "google_storage_bucket" "gitlab-packages" {
  name          = "${var.project_id}-gitlab-packages"
  project       = var.project_id
  location      = var.region
  force_destroy = var.allow_force_destroy
}

resource "google_storage_bucket" "gitlab-registry" {
  name          = "${var.project_id}-registry"
  project       = var.project_id
  location      = var.region
  force_destroy = var.allow_force_destroy
}

resource "google_storage_bucket" "gitlab-pseudo" {
  name          = "${var.project_id}-pseudo"
  project       = var.project_id
  location      = var.region
  force_destroy = var.allow_force_destroy
}

resource "google_storage_bucket" "gitlab-runner-cache" {
  name          = "${var.project_id}-runner-cache"
  project       = var.project_id
  location      = var.region
  force_destroy = var.allow_force_destroy
}