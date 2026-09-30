resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
  }
}
# Phase 1: Bootstrapping the official OpenTelemetry Operator to register its schemas
resource "helm_release" "opentelemetry_operator" {
  name             = "opentelemetry-operator"
  # ✅ FIXED: Corrected the full repository URL to point to the actual charts path
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-operator"
  version          = "0.71.1"
  namespace        = var.namespace
  create_namespace = var.create_namespace

  # Explicitly set the collector image repo variables as required by the chart
  set {
    name  = "manager.collectorImage.repository"
    value = "otel/opentelemetry-collector-contrib"
  }

  # Install the CRD specifications natively as templates into your cluster
  set {
    name  = "crds.create"
    value = "true"
  }

  # Turn off cert-manager hooks
  set {
    name  = "admissionWebhooks.certManager.enabled"
    value = "false"
  }

  # Target the .enabled parameter inside the autoGenerateCert object
  set {
    name  = "admissionWebhooks.autoGenerateCert.enabled"
    value = "true"
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

  # Forces Terraform to wait for Phase 1 to stand up the API endpoints before proceeding
  depends_on = [helm_release.opentelemetry_operator]

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
