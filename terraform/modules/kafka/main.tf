resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name   = var.namespace
    labels = var.common_labels
  }
}

resource "helm_release" "this" {
  name       = var.name
  namespace  = var.namespace
  repository = var.chart_repository
  chart      = "redpanda"
  version    = var.chart_version

  create_namespace = var.create_namespace

  wait          = true
  wait_for_jobs = true
  atomic        = true
  timeout       = var.helm_timeout

  values = [
    yamlencode({
      # ------------------------------------------------------------------
      # General
      # ------------------------------------------------------------------

      fullnameOverride = var.name

      commonLabels = var.common_labels

      # ------------------------------------------------------------------
      # Redpanda resources
      #
      # IMPORTANT:
      # Do not configure:
      #   statefulset.initContainers.configurator.resources
      #
      # The chart's supported resource model is the top-level resources
      # block.
      # ------------------------------------------------------------------

      resources = {
        cpu = {
          cores = var.cpu_cores
        }

        memory = {
          container = {
            max = var.memory_limit
          }
        }
      }

      # ------------------------------------------------------------------
      # StatefulSet
      # ------------------------------------------------------------------

      statefulset = {
        replicas = var.replicas

        podTemplate = {
          annotations = var.pod_annotations

          spec = {
            nodeSelector = var.node_selector
            tolerations  = var.tolerations
          }
        }
      }

      # ------------------------------------------------------------------
      # Persistent storage
      # ------------------------------------------------------------------

      storage = {
        persistentVolume = {
          enabled      = var.storage_enabled
          size         = var.storage_size
          storageClass = var.storage_class
          annotations  = var.storage_annotations
          labels       = var.storage_labels
        }
      }

      # ------------------------------------------------------------------
      # Cluster configuration
      # ------------------------------------------------------------------

      config = {
        cluster = {
          default_topic_replications = var.replicas
        }
      }

      # ------------------------------------------------------------------
      # TLS
      # ------------------------------------------------------------------

      tls = {
        enabled = var.tls_enabled
      }

      # ------------------------------------------------------------------
      # Kafka listener
      # ------------------------------------------------------------------

      listeners = {
        kafka = {
          external = {
            default = {
              enabled         = var.external_enabled
              advertisedPorts = [var.external_kafka_port]
              port            = 9094
            }
          }
        }

        # ----------------------------------------------------------------
        # Schema Registry
        # ----------------------------------------------------------------

        schemaRegistry = {
          enabled = var.schema_registry_enabled
        }
      }

      # ------------------------------------------------------------------
      # External listener service
      # ------------------------------------------------------------------

      external = {
        enabled = var.external_enabled
        type    = var.external_service_type
      }

      # ------------------------------------------------------------------
      # Redpanda Console
      # ------------------------------------------------------------------

      console = {
        enabled = var.console_enabled

        service = {
          type = var.console_service_type
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.this
  ]
}