output "mailpit_release" {
  description = "Mailpit Helm release"
  value       = helm_release.mailpit.name
}

output "mailpit_smtp_service" {
  description = "Internal Mailpit SMTP endpoint"
  value       = "${var.mailpit_release_name}.${var.namespace}.svc.cluster.local:1025"
}

output "mailpit_web_service" {
  description = "Internal Mailpit web endpoint"
  value       = "${var.mailpit_release_name}.${var.namespace}.svc.cluster.local:8025"
}

output "mailpit_web_port_forward" {
  description = "Command to access Mailpit locally"
  value       = "kubectl port-forward -n ${var.namespace} svc/${var.mailpit_release_name} 8025:8025"
}

output "grafana_alert_folder" {
  description = "Grafana folder containing the demo alert"
  value       = grafana_folder.alert_demo.title
}

output "grafana_contact_point" {
  description = "Grafana contact point"
  value       = grafana_contact_point.mailpit.name
}