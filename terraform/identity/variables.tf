variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "project_number" {
  type        = string
  description = "GCP project number"
}

variable "github_owner" {
  type        = string
  description = "GitHub user or org allowed to authenticate"
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
