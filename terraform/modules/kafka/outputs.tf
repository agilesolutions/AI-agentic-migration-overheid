output "release_name" {
  description = "Redpanda Helm release name."
  value       = helm_release.this.name
}

output "namespace" {
  description = "Redpanda namespace."
  value       = var.namespace
}

output "chart_version" {
  description = "Installed Redpanda Helm chart version."
  value       = helm_release.this.version
}

output "statefulset_name" {
  description = "Redpanda StatefulSet name."
  value       = var.name
}

output "internal_bootstrap_servers" {
  description = "Kafka bootstrap server for clients inside Kubernetes."
  value       = "${var.name}.${var.namespace}.svc.cluster.local:9093"
}

output "schema_registry_url" {
  description = "Internal Schema Registry URL."
  value = var.schema_registry_enabled ? (
  "http://${var.name}.${var.namespace}.svc.cluster.local:8081"
  ) : null
}

output "admin_api_url" {
  description = "Internal Redpanda Admin API URL."
  value       = "http://${var.name}.${var.namespace}.svc.cluster.local:9644"
}

output "console_service" {
  description = "Redpanda Console Kubernetes Service name."
  value = var.console_enabled ? (
  "${var.name}-console"
  ) : null
}

output "external_kafka_port" {
  description = "External Kafka port."
  value       = var.external_enabled ? var.external_kafka_port : null
}