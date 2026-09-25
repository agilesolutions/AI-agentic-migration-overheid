module "postgresql" {
  source = "../../modules/postgresql"

  name          = "notebook-postgresql"
  namespace     = "database"
  chart_version = "18.12.1"

  database      = "notebook"
  username      = "notebook"
  password      = var.postgres_password
  storage_size  = "8Gi"
}

module "traefik" {
  source = "../../modules/traefik"
  namespace     = "traefik"
  replica_count = 1
  enable_metrics = false
}

##############################################
# Grafana Alloy : Grafana’s officiele, open-source OpenTelemetry Collector + all backends and grafana
##############################################
module "alloy" {
  source = "../../modules/alloy"
  namespace = "monitoring"
  loki_url = var.loki_url
  tempo_endpoint = var.tempo_endpoint
  prometheus_remote_write_url = var.prometheus_remote_write_url
}


/*
module "flux" {
  source = "../../modules/fluxcd"
  github_owner      = "agilesolutions"
  github_repository = "AI-agentic-migration-overheid"
  github_token = var.github_token
  cluster_name = "notebook"
  flux_path = "fluxcd/flux-system"
  create_repository = false
  deploy_key_read_only = false
}
*/

