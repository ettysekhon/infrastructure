output "cluster_name" {
  value = google_container_cluster.this.name
}

output "region" {
  value = var.region
}

output "cluster_id" {
  value = google_container_cluster.this.id
}

output "cluster_endpoint" {
  value = google_container_cluster.this.endpoint
}

