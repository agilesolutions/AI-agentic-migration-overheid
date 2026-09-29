variable "cluster_name" {
  type        = string
  description = "The name of the Kubernetes cluster being monitored."
  default     = "my-kubernetes-cluster"
}

variable "namespace" {
  type        = string
  description = "The target namespace where the monitoring stack will be deployed."
  default     = "monitoring"
}

variable "chart_version" {
  type        = string
  description = "The version of the grafana/k8s-monitoring helm chart to install."
  default     = "4.5.2" # Adjust to the latest stable major release
}