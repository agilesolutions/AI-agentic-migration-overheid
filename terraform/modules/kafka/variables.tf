variable "name" {
  description = "Redpanda Helm release name."
  type        = string
  default     = "redpanda"
}

variable "namespace" {
  description = "Kubernetes namespace for Redpanda."
  type        = string
  default     = "messaging"
}

variable "create_namespace" {
  description = "Create the Kubernetes namespace."
  type        = bool
  default     = true
}

variable "chart_repository" {
  description = "Redpanda Helm repository."
  type        = string
  default     = "https://charts.redpanda.com"
}

variable "chart_version" {
  description = "Pinned Redpanda Helm chart version."
  type        = string
  default     = "26.2.4"
}

variable "replicas" {
  description = "Number of Redpanda brokers."
  type        = number
  default     = 1

  validation {
    condition     = var.replicas >= 1
    error_message = "replicas must be at least 1."
  }
}

# ---------------------------------------------------------------------------
# Redpanda broker CPU
# ---------------------------------------------------------------------------

variable "cpu_cores" {
  description = "Number of CPU cores allocated to each Redpanda broker."
  type        = number
  default     = 1

  validation {
    condition     = var.cpu_cores >= 1
    error_message = "cpu_cores must be at least 1."
  }
}

# ---------------------------------------------------------------------------
# Redpanda broker memory
# ---------------------------------------------------------------------------

variable "memory_request" {
  description = "Memory request for each Redpanda broker."
  type        = string
  default     = "2Gi"
}

variable "memory_limit" {
  description = "Memory limit for each Redpanda broker."
  type        = string
  default     = "2Gi"
}

# ---------------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------------

variable "storage_enabled" {
  description = "Enable persistent storage."
  type        = bool
  default     = true
}

variable "storage_size" {
  description = "Persistent volume size per Redpanda broker."
  type        = string
  default     = "5Gi"
}

variable "storage_class" {
  description = "Kubernetes StorageClass. Empty uses the cluster default."
  type        = string
  default     = ""
}

variable "storage_annotations" {
  description = "Additional PVC annotations."
  type        = map(string)
  default     = {}
}

variable "storage_labels" {
  description = "Additional PVC labels."
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# TLS
# ---------------------------------------------------------------------------

variable "tls_enabled" {
  description = "Enable Redpanda TLS."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# External Kafka
# ---------------------------------------------------------------------------

variable "external_enabled" {
  description = "Enable the external Kafka listener."
  type        = bool
  default     = false
}

variable "external_service_type" {
  description = "Kubernetes Service type for external Kafka."
  type        = string
  default     = "NodePort"

  validation {
    condition = contains(
      ["NodePort", "LoadBalancer"],
      var.external_service_type
    )

    error_message = "external_service_type must be NodePort or LoadBalancer."
  }
}

variable "external_kafka_port" {
  description = "External Kafka advertised port."
  type        = number
  default     = 31092
}

# ---------------------------------------------------------------------------
# Schema Registry
# ---------------------------------------------------------------------------

variable "schema_registry_enabled" {
  description = "Enable Schema Registry."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Redpanda Console
# ---------------------------------------------------------------------------

variable "console_enabled" {
  description = "Enable Redpanda Console."
  type        = bool
  default     = true
}

variable "console_service_type" {
  description = "Kubernetes Service type for Redpanda Console."
  type        = string
  default     = "ClusterIP"
}

# ---------------------------------------------------------------------------
# Kubernetes customization
# ---------------------------------------------------------------------------

variable "common_labels" {
  description = "Labels applied to Redpanda resources."
  type        = map(string)
  default     = {}
}

variable "pod_annotations" {
  description = "Annotations applied to Redpanda Pods."
  type        = map(string)
  default     = {}
}

variable "node_selector" {
  description = "Node selector for Redpanda Pods."
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Pod tolerations."
  type        = list(any)
  default     = []
}

variable "helm_timeout" {
  description = "Helm operation timeout in seconds."
  type        = number
  default     = 900
}