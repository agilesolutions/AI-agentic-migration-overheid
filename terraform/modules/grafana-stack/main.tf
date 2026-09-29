resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "grafana_stack" {
  name             = "open-observability"
  repository       = "oci://ghcr.io/grafana/helm-charts"
  chart            = "k8s-monitoring"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
  timeout          = 600

  values = [
    yamlencode({
      cluster = {
        name = var.cluster_name
      }

      # 1. Define the Alloy collection architecture
      collectors = {
        alloy-singleton = {
          presets = ["small", "deployment"]
        }
        alloy-logs = {
          presets = ["small", "filesystem-log-reader", "daemonset"]
        }
      }

      # 2. Enable features and pair them to your collectors
      clusterEvents = {
        enabled   = true
        collector = "alloy-singleton"
      }

       # FIX: Changed from 'logs' to 'podLogsViaLoki' to match v2.x/v4.x validation schema
       podLogsViaLoki = {
         enabled   = true
         collector = "alloy-logs"
       }

      # 3. Enable application observability for OTLP data
      applicationObservability = {
        enabled   = true
        collector = "alloy-singleton"
        receivers = {
          otlp = {
            grpc = { enabled = true }
            http = { enabled = true }
          }
        }
      }
      # 3. FIX: Register the target endpoints for Alloy to route telemetry
      destinations = {
        local-loki = {
          type = "loki"
          url  = "http://open-observability-loki-gateway.${var.namespace}.svc.cluster.local/loki/api/v1/push"
        }
        local-mimir = {
          type = "prometheus"
          url  = "http://open-observability-mimir-gateway.${var.namespace}.svc.cluster.local/prometheus/api/v1/push"
        }
        local-tempo = {
          type = "otlp" # Tempo uses OTLP protocol for trace ingestion
          url  = "http://open-observability-tempo-distributor.${var.namespace}.svc.cluster.local:4317"
          traces = {
            enabled = true
          }
          metrics = { enabled = false }
          logs    = { enabled = false }
        }
      }

      # 4. Turn on the local sub-chart engines
      loki = {
        enabled = true
      }
      mimir = {
        enabled = true
      }
      tempo = {
        enabled = true
      }
      grafana = {
        enabled = true
      }
    })
  ]
}


resource "helm_release" "grafana" {
  name             = "open-observability-grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = var.namespace
  create_namespace = false

  values = [
    yamlencode({
      persistence = {
        enabled = true
        size    = "10Gi"
      }
      # This allows you to log in with admin / adminadmin
      adminPassword = "adminadmin"

      cluster = {
        name = var.cluster_name
      }

      # 1. Define the Alloy collection architecture
      collectors = {
        alloy-singleton = { presets = [ "small", "deployment" ] }
        alloy-logs      = { presets = [ "small", "filesystem-log-reader", "daemonset" ] }
      }

      # 2. Enable features and pair them to your collectors
      clusterEvents = {
        enabled   = true
        collector = "alloy-singleton"
      }

      podLogsViaLoki = {
        enabled   = true
        collector = "alloy-logs"
      }

      # 3. Enable application observability for OTLP data
      applicationObservability = {
        enabled   = true
        collector = "alloy-singleton"
        receivers = {
          otlp = {
            grpc = { enabled = true }
            http = { enabled = true }
          }
        }
      }

      # 4. Register the target endpoints for Alloy to route telemetry
      destinations = {
        local-loki = {
          type = "loki"
          url  = "http://open-observability-loki-gateway.${var.namespace}.svc.cluster.local/loki/api/v1/push"
        }
        local-mimir = {
          type = "prometheus"
          url  = "http://open-observability-mimir-gateway.${var.namespace}.svc.cluster.local/prometheus/api/v1/push"
        }
        local-tempo = {
          type = "otlp"
          # Tempo uses OTLP protocol for trace ingestion (e.g., via gRPC/HTTP endpoints)
          url  = "http://open-observability-tempo-distributor.${var.namespace}.svc.cluster.local:4317"
        }
      }

      # =========================================================================
      # FIX: Enable the bundled Grafana subchart and automatically configure data sources
      # =========================================================================
      grafana = {
        enabled = true

        # This will populate the provisioning engine inside Grafana
        datasources = {
          "datasources.yaml" = {
            apiVersion = 1
            datasources = [
              {
                name      = "Loki"
                type      = "loki"
                access    = "proxy"
                url       = "http://open-observability-loki-gateway.${var.namespace}.svc.cluster.local"
                isDefault = false
                editable  = false
              },
              {
                name      = "Prometheus"
                type      = "prometheus"
                access    = "proxy"
                url       = "http://open-observability-mimir-gateway.${var.namespace}.svc.cluster.local/prometheus"
                isDefault = true
                editable  = false
                jsonData = {
                  httpMethod    = "POST"
                  prometheusType = "Mimir"
                }
              },
              {
                name      = "Tempo"
                type      = "tempo"
                access    = "proxy"
                url       = "http://open-observability-tempo-query.${var.namespace}.svc.cluster.local:3100" # Use the query/gateway port for Grafana fetching
                isDefault = false
                editable  = false
              }
            ]
          }
        }
      }
    })

  ]
}
