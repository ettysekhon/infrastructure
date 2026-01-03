terraform {
  required_version = ">= 1.14.0"

  backend "gcs" {
    prefix = "identity/github-wif"
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
  project_id     = data.terraform_remote_state.config.outputs.project_id
  project_number = data.terraform_remote_state.config.outputs.project_number
  github_owner   = data.terraform_remote_state.config.outputs.github_owner
}

variable "service_account_name" {
  type    = string
  default = "github-actions-sa"
}

variable "workload_identity_pool_id" {
  type    = string
  default = "github-pool-v2"
}

variable "workload_identity_provider_id" {
  type    = string
  default = "github-provider-v2"
}

provider "google" {
  project = local.project_id
}

resource "google_service_account" "github" {
  account_id   = var.service_account_name
  display_name = "GitHub Actions Deployer"
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "OIDC federation for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_id
  display_name                       = "GitHub OIDC Provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = "assertion.repository_owner == \"${local.github_owner}\""
}

resource "google_service_account_iam_binding" "wif" {
  service_account_id = google_service_account.github.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/projects/${local.project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository_owner/${local.github_owner}"
  ]
}

resource "google_service_account_iam_binding" "token_creator" {
  service_account_id = google_service_account.github.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    "principalSet://iam.googleapis.com/projects/${local.project_number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/attribute.repository_owner/${local.github_owner}"
  ]
}

output "wif_provider" {
  value = "projects/${local.project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id}"
}

output "service_account_email" {
  value = google_service_account.github.email
}

output "project_id" {
  value = local.project_id
}

output "project_number" {
  value = local.project_number
}
