module "postgresql" {
  source = "../../modules/postgresql"

  name          = "notebook-postgresql"
  namespace     = "database"
  chart_version = "18.12.1"

  database      = "notebook"
  username      = "notebook"
  password      = "notebook"
  storage_size  = "8Gi"
}

module "traefik" {
  source = "../../modules/traefik"
  namespace     = "traefik"
  replica_count = 1
  enable_metrics = false
}
