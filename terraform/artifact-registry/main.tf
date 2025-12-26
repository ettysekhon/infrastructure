module "artifact_registry" {
  source = "../modules/artifact-registry"

  project_id             = var.project_id
  location               = var.location
  repository_id          = var.repository_id
  service_account_email  = var.github_actions_sa_email
  description            = "Docker Artifact Registry"
}
