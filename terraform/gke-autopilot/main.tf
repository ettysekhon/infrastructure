locals {
  cluster_name = var.cluster_name != null ? var.cluster_name : "mcp-${var.environment}-autopilot"
}

resource "google_container_cluster" "this" {
  name     = local.cluster_name
  location = var.region
  project  = var.project_id

  enable_autopilot = true

  deletion_protection = false
}
