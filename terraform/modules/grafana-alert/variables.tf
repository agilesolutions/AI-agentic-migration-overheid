variable "namespace" {
  description = "Kubernetes namespace for Mailpit"
  type        = string
  default     = "monitoring"
}

variable "mailpit_release_name" {
  description = "Mailpit Helm release name"
  type        = string
  default     = "mailpit"
}

variable "mailpit_chart_version" {
  description = "Mailpit Helm chart version"
  type        = string
  default     = "0.36.0"
}

variable "grafana_url" {
  description = "Grafana URL used by the Terraform provider"
  type        = string
}

variable "grafana_token" {
  description = "Grafana service account token"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email address used by the Grafana email contact point"
  type        = string
  default     = "grafana-alerts@example.local"
}

variable "mailpit_storage_size" {
  description = "Mailpit persistent storage size"
  type        = string
  default     = "1Gi"
}