variable "project_id" {
  type = string
}

variable "location" {
  type    = string
  default = "europe-west2"
}

variable "repository_id" {
  type    = string
  default = "containers"
}

variable "github_actions_sa_email" {
  type = string
}
