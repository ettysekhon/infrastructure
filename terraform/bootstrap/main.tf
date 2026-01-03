terraform {
  required_version = ">= 1.14.0"
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.12"
    }
  }
}

variable "project_id" {
  type = string
}

variable "location" {
  type    = string
  default = "EU"
}

locals {
  state_bucket_name = "tf-state-${var.project_id}"
}

provider "google" {
  project = var.project_id
}

resource "google_storage_bucket" "terraform_state" {
  name     = local.state_bucket_name
  location = var.location
  project  = var.project_id

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = true
  }
}

output "bucket_name" {
  value = google_storage_bucket.terraform_state.name
}

output "bucket_url" {
  value = google_storage_bucket.terraform_state.url
}

output "project_id" {
  value = var.project_id
}
