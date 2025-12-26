mock_provider "google" {}

variables {
  project_id                    = "test-project"
  environment                   = "dev"
  project_number                = "123456789"
  github_owner                  = "test-owner"
  workload_identity_pool_id     = "test-pool"
  workload_identity_provider_id = "test-provider"
  service_account_name          = "test-sa"
  github_actions_sa_email       = "test-sa@example.com"
}

run "verify_defaults" {
  command = apply

  # Mock computed values to test outputs
  override_resource {
    target = google_container_cluster.this
    values = {
      id       = "mock-cluster-id"
      endpoint = "mock-endpoint"
    }
  }

  assert {
    condition     = google_container_cluster.this.name == "mcp-dev-autopilot"
    error_message = "Cluster name did not match expected default 'mcp-dev-autopilot'"
  }

  assert {
    condition     = google_container_cluster.this.location == "europe-west2"
    error_message = "Cluster region did not match default 'europe-west2'"
  }

  assert {
    condition     = google_container_cluster.this.enable_autopilot == true
    error_message = "Autopilot should be enabled"
  }

  assert {
    condition     = google_container_cluster.this.deletion_protection == false
    error_message = "Deletion protection should be false"
  }

  assert {
    condition     = output.cluster_name == google_container_cluster.this.name
    error_message = "Output cluster_name should match resource name"
  }

  assert {
    condition     = output.region == var.region
    error_message = "Output region should match input region"
  }

  assert {
    condition     = output.cluster_id == google_container_cluster.this.id
    error_message = "Output cluster_id should match resource id"
  }

  assert {
    condition     = output.cluster_endpoint == google_container_cluster.this.endpoint
    error_message = "Output cluster_endpoint should match resource endpoint"
  }
}

run "verify_custom_settings" {
  command = plan

  variables {
    cluster_name = "my-custom-cluster"
    region       = "us-central1"
  }

  assert {
    condition     = google_container_cluster.this.name == "my-custom-cluster"
    error_message = "Cluster name did not match custom name"
  }

  assert {
    condition     = google_container_cluster.this.location == "us-central1"
    error_message = "Cluster region did not match custom region"
  }
}
