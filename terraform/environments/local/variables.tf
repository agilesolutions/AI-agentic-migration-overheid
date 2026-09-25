variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "loki_url" {
  type = string
}

variable "tempo_endpoint" {
  type = string
}

variable "prometheus_remote_write_url" {
  type = string
}
