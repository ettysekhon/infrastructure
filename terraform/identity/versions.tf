terraform {
  required_version = ">= 1.14.0"

  backend "gcs" {
    bucket = "tf-state-simple-gcp-data-pipeline"
    prefix = "identity/github-wif"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.12"
    }
  }
}
