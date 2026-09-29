# Grafana LogQL Alerts to Slack Guide

A comprehensive, step-by-step technical guide to configuring metric-based log alerts using **LogQL** in **Grafana** and routing them natively to **Slack**.

---

## 🛠️ Step 1: Set Up the Slack Incoming Webhook

Before configuring Grafana, create an active webhook endpoint within your Slack workspace.

1. Navigate to the **Slack API Console** and create a new custom application.
2. Enable the **Incoming Webhooks** feature from the application dashboard.
3. Click **Add New Webhook to Workspace** and authorize the target destination channel.
4. **Copy the generated Webhook URL** for use in your Grafana contact point configuration.

---

## 🔌 Step 2: Configure the Slack Contact Point in Grafana

Connect your Grafana instance to the created Slack endpoint to handle downstream notification payloads.

1. Open the Grafana sidebar and navigate to **Alerts & IRM** ➔ **Alerting** ➔ **Contact points**.
2. Click **+ Add contact point**.
3. Set the configuration fields:
   * **Name**: `Slack-Alerts` (or a recognizable channel descriptor)
   * **Integration**: Select **Slack** from the dropdown menu
   * **Webhook URL**: Paste the incoming webhook URL copied from Slack
4. Click **Test** to fire a simulated alert payload to your Slack workspace.
5. Click **Save contact point**.

---

## 📊 Step 3: Author the LogQL Alert Rule

Grafana Alerting requires log data streams to be aggregated into numeric metrics over explicitly defined time windows.

1. Navigate to **Alerting** ➔ **Alert rules** and click **Create alert rule**.
2. **Rule Identification**: Provide a descriptive title (e.g., `App-Error-Spike`).
3. **Query Definitions & Conditions**:
   * Select your target **Loki** data source.
   * Enter your aggregated **LogQL expression**. The query must yield a continuous numeric metric using rate or interval functions.
   
   ### Example 5-Minute Error Count Query
   ```logql
   sum(count_over_time({app="production"} |= "ERROR" [5m]))
   ```
   
   * Set the evaluation threshold condition (e.g., **IS ABOVE** `10`).
4. **Evaluation Interval & Lifecycle**:
   * **Evaluation interval**: Define check frequency (e.g., checking every `1m`).
   * **Pending period**: Set the sustained condition duration before the rule transitions from `Pending` to `Firing`.
5. **Annotations & Summary**:
   * Craft structural alert descriptions. You can inject labels dynamically into your annotations using text templating formatting syntax:
     ```text
     The production application "{{ $labels.app }}" generated more than 10 errors within the evaluation window.
     ```
6. Click **Save rule and exit**.

---

## 🗺️ Step 4: Map Notification Routing Policies

Ensure that newly declared alert conditions correctly propagate down to your Slack integration contact point.

1. Navigate to **Alerting** ➔ **Notification policies**.
2. **Default Fallback Strategy**: To forward all unmapped alerts to Slack, edit the top-level **Default policy** and set the **Default contact point** directly to `Slack-Alerts`.
3. **Targeted Label Matching Strategy**: Click **+ New specific policy** to isolate routes by matching specific tag criteria:
   * Set matching rules (e.g., `severity=critical` or `team=devops`).
   * Bind the target route directly to your `Slack-Alerts` contact point destination.

---

## 📖 External Resources

* Explore advanced operational setups in the [OneUptime Alerting Guide](https://oneuptime.com/blog/post/2026-01-21-loki-alerts-slack-pagerduty/view).
* Review full schema capabilities via the [Grafana Contact Point Documentation](https://grafana.com/docs/grafana/latest/alerting/configure-notifications/manage-contact-points/integrations/configure-slack/).
