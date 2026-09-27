# GitOps Strategie met FluxCD en Terraform

## Inleiding

Binnen dit referentieplatform wordt **GitOps** toegepast als standaard methode voor het beheren en uitrollen van zowel de Kubernetes-infrastructuur als de applicaties. Alle gewenste configuratie wordt declaratief vastgelegd in Git en automatisch gesynchroniseerd naar het Kubernetes-cluster door **FluxCD**.

De complete cloudinfrastructuur wordt geprovisioneerd met **Terraform**, terwijl **FluxCD** verantwoordelijk is voor het continu reconciliëren van de Kubernetes-resources. Hierdoor ontstaat een volledig geautomatiseerd, reproduceerbaar en auditbaar deploymentproces.

---

# Architectuuroverzicht

```text
                   Git Repository
                          │
                          │ Git Push
                          ▼
                  +----------------+
                  |     FluxCD     |
                  | Source +       |
                  | Kustomization  |
                  +----------------+
                          │
                    Continuous Reconciliation
                          │
                          ▼
                 Kubernetes Cluster (SKE)
                          │
        ┌─────────────────┼──────────────────┐
        ▼                 ▼                  ▼
 Platform Components   Business Services   Configuration
```

---

## Bootstrapping GitOps
Terraform provisioneert de infrastructuur en bootstrapt FluxCD. FluxCD wordt de Kubernetes Control Plane voor Platform Services en Applications. FluxCD beheert de declaratieve configuratie van de Kubernetes resources via GitOps.

```
Terraform
    │
    ├── STACKIT SKE
    ├── GitHub
    └── FluxCD bootstrap
            │
            ▼
          FluxCD
            │
            ▼
     HelmRepositories
            │
            ▼
       HelmReleases
            │
            ├── KEDA
            ├── Traefik
            ├── cert-manager
            └── Keycloak
                    │
                    ▼
              Applications
```


---

# Doelstellingen

De GitOps-strategie is gebaseerd op de volgende uitgangspunten:

- Infrastructure as Code
- Git als enige bron van waarheid (Single Source of Truth)
- Volledig declaratieve deployments
- Continue reconciliatie
- Zelfherstellende configuratie
- Volledige audittrail via Git
- Geautomatiseerde upgrades
- Geen handmatige `kubectl apply`

---

# Architectuur

De verantwoordelijkheden zijn bewust gescheiden.

| Component | Verantwoordelijkheid |
|------------|----------------------|
| Terraform | Cloud infrastructuur |
| FluxCD | Kubernetes configuratie |
| Helm | Installatie platformcomponenten |
| Kustomize | Omgevingsspecifieke configuratie |
| Git | Gewenste configuratie |

---

# Terraform

Terraform beheert uitsluitend de infrastructuur en de initiële bootstrap.

Voorbeelden:

- STACKIT SKE Cluster
- PostgreSQL Flexible Server
- Object Storage
- DNS
- Networking
- Service Accounts
- IAM
- Kubernetes providers
- FluxCD Bootstrap

Terraform beheert **geen** applicatie-deployments.

---

# FluxCD Bootstrap

Na het aanmaken van het Kubernetes-cluster installeert Terraform automatisch FluxCD.

De bootstrap omvat:

- Flux Controllers
- GitRepository
- Kustomization
- Synchronisatie met Git

Hierdoor wordt het cluster direct gekoppeld aan de Git-repository.

```text
Terraform
      │
      ▼
SKE Cluster
      │
      ▼
Flux Bootstrap
      │
      ▼
Git Repository
```

Na de bootstrap neemt FluxCD het volledige beheer van de Kubernetes-configuratie over.

---

# Repository Structuur

Een logische scheiding tussen platformcomponenten en applicaties verhoogt de onderhoudbaarheid.

```text
gitops
│
├── clusters
│   └── production
│
├── infrastructure
│
├── platform
│   ├── cert-manager
│   ├── traefik
│   ├── keycloak
│   ├── external-secrets
│   ├── prometheus
│   ├── grafana
│   ├── loki
│   ├── tempo
│   └── keda
│
├── services
│   ├── vergunning-service
│   ├── zakenregistratie-service
│   └── frontend
│
└── shared
```

---

# Platform Componenten

FluxCD installeert alle platformcomponenten automatisch.

Voorbeelden:

- Traefik Ingress Controller
- cert-manager
- External Secrets Operator
- Keycloak
- Prometheus
- Grafana
- Loki
- Tempo
- OpenTelemetry Collector
- KEDA

Deze componenten worden beheerd met **HelmRelease** objecten.

```text
Git
 │
 ▼
HelmRepository
 │
 ▼
HelmRelease
 │
 ▼
Platform Component
```

---

# Business Services

De eigen Spring Boot microservices worden eveneens door FluxCD beheerd.

Iedere service bevat onder andere:

- Deployment
- Service
- Ingress
- ConfigMap
- ExternalSecret
- NetworkPolicy
- PodDisruptionBudget
- HorizontalPodAutoscaler
- ServiceMonitor

Hierdoor is iedere service volledig declaratief beschreven.

---

# Helm

Platformcomponenten worden geïnstalleerd via officiële Helm Charts.

Voordelen:

- standaard installatie
- eenvoudige upgrades
- community ondersteuning
- reproduceerbare configuratie

FluxCD bewaakt automatisch nieuwe chartversies.

---

# Kustomize

Kustomize verzorgt de omgevingsspecifieke configuratie.

Voorbeelden:

```text
base/

overlays/
    dev/
    test/
    acceptatie/
    productie/
```

Hiermee kan dezelfde applicatie zonder duplicatie in meerdere omgevingen worden uitgerold.

---

# Continue Reconciliatie

FluxCD vergelijkt continu:

Git Repository

↓

Werkelijke clusterstatus

Wanneer verschillen worden gevonden zal FluxCD automatisch corrigeren.

Voorbeelden:

- handmatig verwijderde Deployment
- gewijzigde ConfigMap
- gewijzigde ReplicaCount
- verwijderde Service

De gewenste configuratie uit Git wordt automatisch hersteld.

---

# Image Automation

Nieuwe container-images kunnen automatisch worden uitgerold.

Proces:

```text
Nieuwe Docker Image

↓

Container Registry

↓

Flux Image Repository

↓

Image Policy

↓

Image Update Automation

↓

Git Commit

↓

Flux Deployment
```

Hierdoor blijft Git altijd de bron van waarheid.

---

# Secrets

Gevoelige informatie wordt niet opgeslagen in Git.

FluxCD beheert uitsluitend:

- ExternalSecret
- SecretStore
- ClusterSecretStore

De daadwerkelijke secrets bevinden zich in een externe Secret Manager.

---

# Deployment Proces

Het deploymentproces bestaat uit de volgende stappen:

1. Developer commit code
2. CI Pipeline bouwt container-image
3. Image wordt gepubliceerd
4. Flux Image Automation werkt de image-tag bij
5. Git wordt bijgewerkt
6. Flux detecteert wijziging
7. Kubernetes wordt automatisch bijgewerkt
8. Rolling Update start
9. Health Checks controleren de nieuwe Pods
10. Oude Pods worden verwijderd

---

# Voordelen

Deze GitOps-strategie biedt de volgende voordelen:

- Volledig geautomatiseerde deployments
- Herhaalbare infrastructuur
- Eenvoudige rollback via Git
- Volledige audittrail
- Geen configuratiedrift
- Zelfherstellende clusterconfiguratie
- Minder handmatige beheertaken
- Eenvoudig schaalbaar
- Platform-onafhankelijk

---

# Best Practices

Binnen dit referentieplatform worden de volgende GitOps-principes toegepast:

- Git is de enige bron van waarheid
- Terraform beheert uitsluitend infrastructuur
- FluxCD beheert Kubernetes-resources
- Platformcomponenten via HelmRelease
- Applicaties via Kustomize
- Geen handmatige wijzigingen in het cluster
- Secrets buiten Git
- Continue reconciliatie
- Image Automation voor applicatie-updates
- Declaratieve configuratie
- Kleine, herbruikbare Kustomizations
- Scheiding tussen platform en business services

---

# Rollen en Verantwoordelijkheden

| Component | Verantwoordelijkheid |
|-----------|----------------------|
| Terraform | Cloud infrastructuur en Flux bootstrap |
| FluxCD | Continue synchronisatie met Git |
| Helm | Installatie platformsoftware |
| Kustomize | Omgevingsspecifieke configuratie |
| CI Pipeline | Build, test en publiceren container-images |
| Container Registry | Opslag van images |
| Kubernetes | Uitvoering van workloads |

---

# Conclusie

Door Terraform en FluxCD te combineren ontstaat een volledig geautomatiseerd GitOps-platform. Terraform verzorgt de provisioning van de cloudinfrastructuur en de initiële installatie van FluxCD. Vanaf dat moment neemt FluxCD het beheer van alle Kubernetes-resources over en synchroniseert continu de gewenste configuratie vanuit Git. Platformcomponenten worden beheerd via Helm Releases, terwijl business services met Kustomize worden uitgerold. Deze aanpak resulteert in een reproduceerbare, veilige en onderhoudbare deploymentstrategie die uitstekend aansluit bij Cloud Native best practices en productieomgevingen op STACKIT SKE.
