resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
  }
}


resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_version

  namespace        = var.namespace
  create_namespace = false

  # Install Certificate, Issuer, ClusterIssuer, etc. CRDs
  set {
    name  = "crds.enabled"
    value = "true"
  }

  wait    = true
  timeout = 600

  depends_on = [
    kubernetes_namespace_v1.monitoring
  ]
}


resource "helm_release" "opentelemetry_operator" {
  name             = "opentelemetry-operator"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-operator"
  version          = var.opentelemetry_operator_version
  namespace        = var.namespace
  create_namespace = false

  set {
    name  = "crds.create"
    value = "true"
  }

  set {
    name  = "manager.collectorImage.repository"
    value = "ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s"
  }

  depends_on = [
    kubernetes_namespace_v1.monitoring, helm_release.cert_manager
  ]
}


resource "helm_release" "lgtm_stack" {
  name       = "lgtm"
  repository = "https://promptlylabs.github.io/lgtm-helm-chart"
  chart      = "lgtm"
  version    = var.chart_version
  namespace  = var.namespace

  create_namespace = var.create_namespace

  disable_openapi_validation = true


  values = [
    yamlencode({

      # The operator is managed separately above.
      opentelemetry-operator = {
        enabled = false
      }

      grafana = {
        adminPassword = var.grafana_admin_password

        persistence = {
          enabled = var.persistence_enabled
          size    = "2Gi"
        }
      }

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

      loki = {
        persistence = {
          enabled = var.persistence_enabled
          size    = var.persistence_size
        }
      }

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

resource "local_file" "lgtm_otel_metrics_patch" {
  filename = "${path.module}/.generated/lgtm-otel-metrics-patch.yaml"

  content = yamlencode({
    spec = {
      config = {
        service = {
          pipelines = {
            metrics = {
              receivers = [
                "otlp",
                "hostmetrics",
                "prometheus",
                "kubeletstats"
              ]
            }
          }
        }
      }
    }
  })
}

resource "null_resource" "patch_lgtm_otlp_metrics_pipeline" {
  depends_on = [
    helm_release.lgtm_stack
  ]

  triggers = {
    lgtm_revision = helm_release.lgtm_stack.metadata[0].revision
    patch_file    = filesha256("${path.module}/otel-metrics-patch.yaml")
  }

  provisioner "local-exec" {
    interpreter = [
      "PowerShell",
      "-Command"
    ]

    command = <<-EOT
      kubectl patch opentelemetrycollector otel-node-collector `
        -n ${var.namespace} `
        --type=merge `
        --patch-file="${path.module}/otel-metrics-patch.yaml"
    EOT
  }
}