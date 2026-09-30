resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
  }
}


# Phase 2: Deploying the PromptlyLabs LGTM Stack
resource "helm_release" "lgtm_stack" {
  name             = "lgtm"
  repository       = "https://promptlylabs.github.io/lgtm-helm-chart"
  chart            = "lgtm"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = var.create_namespace

  # Bypasses client-side validation loops on custom configuration overrides
  disable_openapi_validation = true

  values = [
    yamlencode({
      # Disable the internal CRD installation loop to avoid collisions with Phase 1
      opentelemetry-operator = {
        enabled = false
      }

      # Grafana configuration mapping
      grafana = {
        adminPassword = var.grafana_admin_password
        persistence = {
          enabled = var.persistence_enabled
          size    = "2Gi"
        }
      }

      # Prometheus sub-chart routing embedded inside kube-prometheus-stack
      kube-prometheus-stack = {
        prometheus = {
          prometheusSpec = {
            storageSpec = var.persistence_enabled ? {
              volumeClaimTemplate = {
                spec = {
                  accessModes = ["ReadWriteOnce"]
                  resources = {
                    requests = {
                      storage = var.persistence_size
                    }
                  }
                }
              }
            } : null
          }
        }
      }

      # Loki backend sub-chart routing
      loki = {
        persistence = {
          enabled = var.persistence_enabled
          size    = var.persistence_size
        }
      }

      # Tempo tracing sub-chart routing
      tempo = {
        persistence = {
          enabled = var.persistence_enabled
          size    = var.persistence_size
        }
      }
    }),
    yamlencode(var.custom_values)
  ]
}
