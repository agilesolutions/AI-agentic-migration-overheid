# Mailpit
#
# Mailpit does not maintain an official Helm chart.
# The Jouve chart packages the official axllent/mailpit image.
#
resource "helm_release" "mailpit" {
  name       = var.mailpit_release_name
  namespace  = var.namespace

  repository = "https://jouve.github.io/charts"
  chart      = "mailpit"
  version    = var.mailpit_chart_version

  wait    = true
  timeout = 300

  values = [
    yamlencode({
      replicaCount = 1

      persistence = {
        enabled = true
        size    = var.mailpit_storage_size
      }

      service = {
        type = "ClusterIP"
      }
    })
  ]

  depends_on = [

  ]
}


# TestData datasource
#
# Grafana ships with this datasource/plugin.
#
resource "grafana_data_source" "testdata" {
  name = "TestData"
  type = "testdata"
}

#
# Folder
#
resource "grafana_folder" "alert_demo" {
  title = "Terraform Alert Demo"
}

#
# Email contact point
#
resource "grafana_contact_point" "mailpit" {
  name = "Mailpit - Alert Demo"

  email {
    addresses = [
      var.alert_email
    ]

    subject = "[Grafana DEMO] {{ .CommonLabels.alertname }}"

    message = <<-EOT
      Grafana Alert Demo

      Alert: {{ .CommonLabels.alertname }}

      Status:
      {{ .Status }}

      Summary:
      {{ .CommonAnnotations.summary }}

      Description:
      {{ .CommonAnnotations.description }}

      Firing alerts:
      {{ len .Alerts.Firing }}

      Resolved alerts:
      {{ len .Alerts.Resolved }}
    EOT
  }
}

#
# Notification policy
#
resource "grafana_notification_policy" "mailpit" {
  contact_point = grafana_contact_point.mailpit.name

  group_by = [
    "alertname"
  ]

  group_wait      = "10s"
  group_interval  = "1m"
  repeat_interval = "1h"
}

#
# Alert rule
#
# TestData generates a predictable pulse.
#
resource "grafana_rule_group" "demo" {
  name             = "Grafana Alert Demo"
  folder_uid       = grafana_folder.alert_demo.uid
  interval_seconds = 10

  rule {
    name      = "Demo - TestData Alert"
    condition = "C"

    for = "0s"

    annotations = {
      summary = "Grafana TestData alert is firing"

      description = "This is a deliberately triggered alert used to demonstrate Grafana -> Mailpit notification delivery."
    }

    labels = {
      severity = "warning"
      demo     = "true"
    }

    #
    # A - TestData
    #
    data {
      ref_id = "A"

      datasource_uid = grafana_data_source.testdata.uid

      relative_time_range {
        from = 60
        to   = 0
      }

      model = jsonencode({
        refId         = "A"
        intervalMs    = 1000
        maxDataPoints = 43200
        scenarioId    = "predictable_csv_wave"
      })
    }

    #
    # B - Reduce
    #
    data {
      ref_id = "B"

      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        refId      = "B"
        type       = "reduce"
        expression = "A"
        reducer    = "last"
      })
    }

    #
    # C - Threshold
    #
    data {
      ref_id = "C"

      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        refId      = "C"
        type       = "threshold"
        expression = "B"

        conditions = [
          {
            evaluator = {
              type   = "gt"
              params = [0]
            }

            operator = {
              type = "and"
            }

            query = {
              params = ["B"]
            }

            reducer = {
              type   = "last"
              params = []
            }

            type = "query"
          }
        ]
      })
    }
  }
}