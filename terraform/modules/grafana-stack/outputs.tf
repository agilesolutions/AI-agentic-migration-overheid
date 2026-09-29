output "namespace" {
  value       = helm_release.grafana_stack.namespace
  description = "The namespace where the monitoring stack was installed."
}

output "release_name" {
  value       = helm_release.grafana_stack.name
  description = "The Helm release name."
}
