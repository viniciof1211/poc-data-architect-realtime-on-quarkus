**README.md**

# POC OMURA Data Architect

This repository contains all artifacts needed to spin up the assigned Proof-of-Concept (POC) for the OMURA Data Architect solution, including Docker, scripts, and Kubernetes manifests.

---

##  Repository Layout

```
poc-data-architect-realtime-on-quarkus/
│
├── README.md                  # This guide
├── architecture/              # Diagram exports (draw.io → PNG)
├── docs/                      # POC specification and design docs
│   └── poc-specification.md   # Business & technical specs
├── scripts/                   # Automation scripts
│   ├── install-k8s.ps1        # PowerShell for Windows
│   ├── install-k8s.sh         # Bash for macOS/Linux
│   └── build-and-run.sh       # Local build & deploy helper
├── docker/                    # Docker assets
│   ├── Dockerfile             # Quarkus & Python service images
│   └── docker-compose.yml     # Multi-container local setup
├── k8s/                       # Kubernetes manifests
│   ├── namespace.yaml         # Namespace definition
│   ├── configmap.yaml         # App configuration
│   ├── secret.yaml            # Sensitive values (base64-encoded)
│   ├── deployment.yaml        # Pod & Deployment specs
│   ├── service.yaml           # Service (ClusterIP/LoadBalancer)
│   └── ingress.yaml           # Ingress rules
├── charts/                    # (Optional) Helm charts for production
└── .github/                   # CI/CD workflows
    └── workflows/
        └── ci-cd-pipeline.yml # GitHub Actions pipeline
```

---

## 🛠️ Local Setup Steps

1. **Clone the repo**

   ```bash
   git clone https://github.com/viniciof1211/poc-data-architect-realtime-on-quarkus.git
   cd poc-data-architect-realtime-on-quarkus
   ```

2. **Install Kubernetes locally**

   * **Windows** (PowerShell as Admin):

     ```powershell
     ./scripts/install-k8s.ps1
     ```
   * **macOS / Linux**:

     ```bash
     bash scripts/install-k8s.sh
     ```

3. **Build & Run**

   ```bash
   bash scripts/build-and-run.sh
   ```

   * Builds Docker images (`docker/`) via Compose
   * Starts containers for local validation
   * Applies all `k8s/` manifests
   * Streams logs and port-forwards key services

4. **Access the POC**

   * Service UI: `http://localhost:8080`
   * Kubernetes Dashboard: `minikube dashboard`

---

## 📦 Docker Assets

* **Dockerfile** (Quarkus & Python hybrid)

  ```dockerfile
  FROM quay.io/quarkus/quarkus-micro-image:2.16.2.Final
  WORKDIR /work/working
  COPY target/*-runner /work/working/application
  COPY src/main/resources/application.properties /work/working/
  EXPOSE 8080
  CMD ["./application", "-Dquarkus.http.host=0.0.0.0"]
  ```

* **docker-compose.yml**

  ```yaml
  version: '3.8'
  services:
    quarkus-app:
      build: ./docker
      image: quarkus-app:latest
      ports:
        - "8080:8080"
      depends_on: [zookeeper, kafka]

    zookeeper:
      image: confluentinc/cp-zookeeper:7.3.0
      environment:
        ZOOKEEPER_CLIENT_PORT: 2181

    kafka:
      image: confluentinc/cp-kafka:7.3.0
      depends_on: [zookeeper]
      ports: ["9092:9092"]
      environment:
        KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
        KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
  ```

---

## 🐳 Kubernetes Manifests

All YAMLs under `k8s/`, labeled for `dev` and `prod` environments.

* **namespace.yaml**

  ```yaml
  apiVersion: v1
  kind: Namespace
  metadata:
    name: poc
  ```

* **configmap.yaml** / **secret.yaml**
  Define environment variables and secrets.

* **deployment.yaml**
  Pods for ingestion, ODS, API, UI components.

  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: app-deployment
    namespace: poc
  spec:
    replicas: 3
    selector: { matchLabels: { app: poc-app }}
    template:
      metadata: { labels: { app: poc-app }}
      spec:
        containers:
        - name: app
          image: yourrepo/poc-app:latest
          ports: [ { containerPort: 8080 } ]
          envFrom:
            - configMapRef: { name: app-config }
            - secretRef:    { name: app-secrets }
  ```

* **service.yaml**

  ```yaml
  apiVersion: v1
  kind: Service
  metadata: { name: app-service, namespace: poc }
  spec:
    type: ClusterIP
    selector: { app: poc-app }
    ports: [{ port: 80, targetPort: 8080 }]
  ```

* **ingress.yaml**

  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: app-ingress
    namespace: poc
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
  spec:
    rules:
    - host: poc.example.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend: { service: { name: app-service, port: { number: 80 } }}
  ```

---

## 🌿 Branch Strategy & CI/CD

1. **feature/init** – Bootstrap of Docker, scripts, k8s YAMLs.
2. **dev** – Integration/testing branch; GitHub Actions deploy to dev cluster.
3. **prod** – Production-grade Helm charts, hardened configs.

All commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).

---

Ready to collaborate! Please review and comment in this repo, and watch as we iterate through features, dev tests, and production releases.
