terraform {
  backend "gcs" {
    bucket  = "tf-state-simple-gcp-data-pipeline"
    prefix  = "artifact-registry"
  }
}
