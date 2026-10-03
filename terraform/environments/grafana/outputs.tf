output "kafka_bootstrap_servers" {
  description = "Kafka bootstrap server for applications running inside Kubernetes."
  value       = module.kafka.internal_bootstrap_servers
}

output "schema_registry_url" {
  description = "Internal Schema Registry URL."
  value       = module.kafka.schema_registry_url
}

output "admin_api_url" {
  description = "Internal Redpanda Admin API URL."
  value       = module.kafka.admin_api_url
}

output "console_service" {
  description = "Redpanda Console Kubernetes Service."
  value       = module.kafka.console_service
}

output "chart_version" {
  description = "Redpanda Helm chart version."
  value       = module.kafka.chart_version
}