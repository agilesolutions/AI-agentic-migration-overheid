# DUO OpenShift CLI — Daily Cheat Sheet

> **Purpose:** Practical `oc` commands for daily Java / Spring Boot development, technical leadership, troubleshooting and platform work at DUO.

---

## 1. Login & Context

### Login

```bash
oc login https://api.<cluster>:6443
```

Using a token:

```bash
oc login --token=<TOKEN> --server=https://api.<cluster>:6443
```

Check who I am:

```bash
oc whoami
```

Check current project:

```bash
oc project
```

List available projects:

```bash
oc projects
```

Switch project:

```bash
oc project <project>
```

Show cluster:

```bash
oc cluster-info
```

Show OpenShift console:

```bash
oc whoami --show-console
```

---

# 2. Find What's Running

### Pods

```bash
oc get pods
```

More information:

```bash
oc get pods -o wide
```

Watch pods:

```bash
oc get pods -w
```

Only unhealthy / non-running pods:

```bash
oc get pods | grep -v Running
```

### Deployments

```bash
oc get deployments
```

### Deployment details

```bash
oc describe deployment <deployment>
```

### Services

```bash
oc get svc
```

### Routes

```bash
oc get routes
```

A useful overview:

```bash
oc get deployment,pod,svc,route
```

---

# 3. The First Troubleshooting Commands

When a Spring Boot application isn't working:

```bash
oc get pods
```

Then:

```bash
oc describe pod <pod>
```

Then:

```bash
oc logs <pod>
```

For the previous container:

```bash
oc logs <pod> --previous
```

Follow logs:

```bash
oc logs -f <pod>
```

If there are multiple containers:

```bash
oc logs <pod> -c <container>
```

Follow logs from a deployment:

```bash
oc logs deployment/<deployment> -f
```

---

# 4. Pod Problems

### Pod stuck in Pending

```bash
oc describe pod <pod>
```

Look at:

```text
Events:
```

Common causes:

* insufficient resources
* scheduling constraints
* missing PVC
* node affinity
* taints/tolerations
* image pull problems

---

### CrashLoopBackOff

```bash
oc describe pod <pod>
```

Then:

```bash
oc logs <pod>
```

And:

```bash
oc logs <pod> --previous
```

Typical Spring Boot causes:

* application startup exception
* database unavailable
* incorrect configuration
* missing Secret
* missing ConfigMap
* invalid environment variable
* failed Flyway migration
* incorrect JVM configuration

---

### ImagePullBackOff

```bash
oc describe pod <pod>
```

Check:

```text
Events:
```

Then inspect the image:

```bash
oc get pod <pod> -o jsonpath='{.spec.containers[*].image}'
```

---

# 5. Spring Boot Troubleshooting

Check application logs:

```bash
oc logs deployment/<deployment> --tail=200
```

Search for errors:

```bash
oc logs deployment/<deployment> | grep -i error
```

Search for exceptions:

```bash
oc logs deployment/<deployment> | grep -i exception
```

Search for Spring Boot startup:

```bash
oc logs deployment/<deployment> | grep -i "Started"
```

Check environment variables:

```bash
oc exec deployment/<deployment> -- env
```

Better for a specific pod:

```bash
oc exec -it <pod> -- env
```

---

# 6. Get a Shell Inside a Pod

Open a shell:

```bash
oc rsh <pod>
```

Or:

```bash
oc exec -it <pod> -- /bin/sh
```

If Bash exists:

```bash
oc exec -it <pod> -- /bin/bash
```

Useful checks:

```bash
env
```

```bash
ps
```

```bash
df -h
```

```bash
cat /etc/resolv.conf
```

Exit:

```bash
exit
```

---

# 7. Spring Boot Actuator

If Actuator is exposed internally:

```bash
oc exec <pod> -- curl http://localhost:8080/actuator/health
```

Readiness:

```bash
oc exec <pod> -- curl http://localhost:8080/actuator/health/readiness
```

Liveness:

```bash
oc exec <pod> -- curl http://localhost:8080/actuator/health/liveness
```

Info:

```bash
oc exec <pod> -- curl http://localhost:8080/actuator/info
```

Metrics:

```bash
oc exec <pod> -- curl http://localhost:8080/actuator/metrics
```

---

# 8. Configuration

## ConfigMaps

List:

```bash
oc get configmaps
```

Inspect:

```bash
oc describe configmap <configmap>
```

Get YAML:

```bash
oc get configmap <configmap> -o yaml
```

---

## Secrets

List:

```bash
oc get secrets
```

Inspect metadata:

```bash
oc describe secret <secret>
```

Get YAML:

```bash
oc get secret <secret> -o yaml
```

> Avoid exposing Secret values in terminals, logs, tickets or chat.

---

# 9. Check What Configuration a Deployment Uses

```bash
oc get deployment <deployment> -o yaml
```

Look for:

```yaml
env:
envFrom:
configMapKeyRef:
secretKeyRef:
volumes:
volumeMounts:
```

A useful shortcut:

```bash
oc set env deployment/<deployment> --list
```

---

# 10. Deployment Operations

Check rollout:

```bash
oc rollout status deployment/<deployment>
```

Watch rollout:

```bash
oc ro
```
