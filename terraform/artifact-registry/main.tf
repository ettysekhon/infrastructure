terraform {
  required_version = ">= 1.14.0"

  backend "gcs" {
    prefix = "artifact-registry"
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

data "terraform_remote_state" "identity" {
  backend = "gcs"
  config = {
    bucket = "tf-state-simple-gcp-data-pipeline"
    prefix = "identity/github-wif"
  }
}

locals {
  project_id            = data.terraform_remote_state.config.outputs.project_id
  region                = data.terraform_remote_state.config.outputs.region
  service_account_email = data.terraform_remote_state.identity.outputs.service_account_email
}

variable "repository_id" {
  type    = string
  default = "containers"
}

provider "google" {
  project = local.project_id
  region  = local.region
}

module "artifact_registry" {
  source = "../modules/artifact-registry"

  project_id            = local.project_id
  location              = local.region
  repository_id         = var.repository_id
  service_account_email = local.service_account_email
  description           = "Docker Artifact Registry"
}

output "repository_url" {
  value = "${local.region}-docker.pkg.dev/${local.project_id}/${var.repository_id}"
}

output "repository_id" {
  value = var.repository_id
}
