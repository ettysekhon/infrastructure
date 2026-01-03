terraform {
  required_version = ">= 1.14.0"

  backend "gcs" {
    prefix = "platform/cluster"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.12"
    }
  }
}

data "terraform_remote_state" "config" {
  backend = "gcs"
  config = {
    bucket = "tf-state-simple-gcp-data-pipeline"
    prefix = "platform/config"
  }
}

locals {
  project_id   = data.terraform_remote_state.config.outputs.project_id
  region       = data.terraform_remote_state.config.outputs.region
  cluster_name = data.terraform_remote_state.config.outputs.cluster_name
  environment  = data.terraform_remote_state.config.outputs.environment
  zone         = "${data.terraform_remote_state.config.outputs.region}-a"
}

provider "google" {
  project = local.project_id
  region  = local.region
}

resource "google_container_cluster" "this" {
  name     = local.cluster_name
  location = local.zone
  project  = local.project_id

  initial_node_count       = 1
  remove_default_node_pool = true

  logging_config {
    enable_components = []
  }
  monitoring_config {
    enable_components = []
  }

  network    = "default"
  subnetwork = "default"

  deletion_protection = false

  resource_labels = {
    managed-by  = "terraform"
    environment = local.environment
  }
}

resource "google_container_node_pool" "spot" {
  name     = "spot-pool"
  location = local.zone
  cluster  = google_container_cluster.this.name
  project  = local.project_id

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    spot         = true
    machine_type = "e2-medium"

    disk_size_gb = 30
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = local.environment
      node-type   = "spot"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_id" {
  value = google_container_cluster.this.id
}

output "cluster_endpoint" {
  value = google_container_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "region" {
  value = local.region
}

output "zone" {
  value = local.zone
}

output "environment" {
  value = local.environment
}

output "project_id" {
  value = local.project_id
}
