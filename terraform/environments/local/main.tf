module "postgresql" {
  source = "../../modules/postgresql"

  name          = "notebook-postgresql"
  namespace     = "notebook"
  chart_version = "18.12.1"

  database      = "notebook"
  username      = "notebook"
  password      = "notebook"
  storage_size  = "8Gi"
}