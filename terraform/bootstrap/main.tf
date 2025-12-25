terraform {
  required_version = ">= 1.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.12"
    }
  }
}

variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "location" {
  type        = string
  default     = "EU"
  description = "GCS bucket location"
}

provider "google" {
  project = var.project_id
}

resource "google_storage_bucket" "terraform_state" {
  name     = "tf-state-simple-gcp-data-pipeline"
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
