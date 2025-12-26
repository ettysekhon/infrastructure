resource "google_artifact_registry_repository" "this" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_binding" "writer" {
  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.this.name
  role       = "roles/artifactregistry.writer"

  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}
