terraform {
  required_version = ">= 1.14.0"

  backend "gcs" {
    prefix = "platform/config"
  }

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

variable "project_number" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "region" {
  type    = string
  default = "europe-west2"
}

variable "github_owner" {
  type = string
}

locals {
  state_bucket_name = "tf-state-${var.project_id}"
  cluster_name      = var.environment

  default_labels = {
    managed-by  = "terraform"
    environment = var.environment
    project     = var.project_id
  }
}

output "project_id" {
  value = var.project_id
}

output "project_number" {
  value = var.project_number
}

output "environment" {
  value = var.environment
}

output "region" {
  value = var.region
}

output "state_bucket_name" {
  value = local.state_bucket_name
}

output "cluster_name" {
  value = local.cluster_name
}

output "github_owner" {
  value = var.github_owner
}

output "default_labels" {
  value = local.default_labels
}
