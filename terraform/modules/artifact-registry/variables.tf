variable "project_id" {
  type = string
}

variable "location" {
  type = string
}

variable "repository_id" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "description" {
  type    = string
  default = "Docker Artifact Registry"
}
