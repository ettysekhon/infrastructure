terraform {
  required_version = ">= 1.14.0"

  backend "gcs" {
    prefix = "platform/namespaces"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
  }
}

data "terraform_remote_state" "cluster" {
  backend = "gcs"
  config = {
    bucket = "tf-state-simple-gcp-data-pipeline"
    prefix = "platform/cluster"
  }
}

locals {
  cluster_endpoint       = data.terraform_remote_state.cluster.outputs.cluster_endpoint
  cluster_ca_certificate = data.terraform_remote_state.cluster.outputs.cluster_ca_certificate
  environment            = data.terraform_remote_state.cluster.outputs.environment
  project_id             = data.terraform_remote_state.cluster.outputs.project_id
  region                 = data.terraform_remote_state.cluster.outputs.region
}

provider "google" {
  project = local.project_id
  region  = local.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${local.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
}
