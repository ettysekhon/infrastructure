variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west2"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "cluster_name" {
  type    = string
  default = null
}

variable "project_number" {
  type        = string
  description = "The project number"
}

variable "github_owner" {
  type        = string
  description = "GitHub owner"
}

variable "workload_identity_pool_id" {
  type        = string
  description = "Workload Identity Pool ID"
}

variable "workload_identity_provider_id" {
  type        = string
  description = "Workload Identity Provider ID"
}

variable "service_account_name" {
  type        = string
  description = "Service Account Name"
}

variable "github_actions_sa_email" {
  type        = string
  description = "GitHub Actions SA Email"
}
