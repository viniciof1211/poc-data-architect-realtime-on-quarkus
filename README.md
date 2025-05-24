**README.md**

# POC OMURA Data Architect

This repository contains all artifacts needed to spin up a Proof-of-Concept (POC) for the OMURA Data Architect solution, including Docker, scripts, and Quarkus / Kubernetes manifests.

---

## 🚀 Repository Layout

```
poc-omura-data-architect-realtime-on-quarkus/
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
   git clone https://github.com/yourorg/poc-omura-data-architect.git
   cd poc-omura-data-architect
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

All YAMLs under `k8s/`, labeled for `dev` and `prod` environments, including Debezium connector setup for real‑time Postgres → MongoDB.

* **namespace.yaml**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: poc
```

* **configmap.yaml** / **secret.yaml**
  Define environment variables and secrets (e.g., POSTGRES\_URL, MONGO\_URL, KAFKA\_BOOTSTRAP\_SERVERS).

* **zookeeper-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: zookeeper
  namespace: poc
spec:
  replicas: 1
  selector:
    matchLabels: { app: zookeeper }
  template:
    metadata: { labels: { app: zookeeper }}
    spec:
      containers:
      - name: zookeeper
        image: confluentinc/cp-zookeeper:7.3.0
        ports: [{ containerPort: 2181 }]
        env:
        - name: ZOOKEEPER_CLIENT_PORT
          value: "2181"
```

* **kafka-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kafka
  namespace: poc
spec:
  replicas: 1
  selector:
    matchLabels: { app: kafka }
  template:
    metadata: { labels: { app: kafka }}
    spec:
      containers:
      - name: kafka
        image: confluentinc/cp-kafka:7.3.0
        ports: [{ containerPort: 9092 }]
        env:
        - name: KAFKA_ZOOKEEPER_CONNECT
          value: zookeeper:2181
        - name: KAFKA_ADVERTISED_LISTENERS
          value: PLAINTEXT://kafka:9092
```

* **postgres-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: poc
spec:
  replicas: 1
  selector:
    matchLabels: { app: postgres }
  template:
    metadata: { labels: { app: postgres }}
    spec:
      containers:
      - name: postgres
        image: postgres:14
        env:
        - name: POSTGRES_DB
          value: omura
        - name: POSTGRES_USER
          value: omura_user
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef: { name: app-secrets, key: POSTGRES_PASSWORD }
        ports: [{ containerPort: 5432 }]
```

* **mongodb-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb
  namespace: poc
spec:
  replicas: 1
  selector:
    matchLabels: { app: mongodb }
  template:
    metadata: { labels: { app: mongodb }}
    spec:
      containers:
      - name: mongodb
        image: mongo:6
        ports: [{ containerPort: 27017 }]
```

* **kafka-connect-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kafka-connect
  namespace: poc
spec:
  replicas: 1
  selector:
    matchLabels: { app: kafka-connect }
  template:
    metadata: { labels: { app: kafka-connect }}
    spec:
      containers:
      - name: connect
        image: debezium/connect:2.1
        env:
        - name: BOOTSTRAP_SERVERS
          value: kafka:9092
        - name: GROUP_ID
          value: "1"
        - name: CONFIG_STORAGE_TOPIC
          value: "connect-configs"
        - name: OFFSET_STORAGE_TOPIC
          value: "connect-offsets"
        - name: STATUS_STORAGE_TOPIC
          value: "connect-status"
        ports: [{ containerPort: 8083 }]
```

* **debezium-connector-postgres.json**

```json
{
  "name": "omura-postgres-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "postgres",
    "database.port": "5432",
    "database.user": "omura_user",
    "database.password": "${file:/opt/kafka/config/db-password}" ,
    "database.dbname": "omura",
    "database.server.name": "omura-pg",
    "table.include.list": "public.orders,public.customers",
    "plugin.name": "pgoutput",
    "transforms": "unwrap,route",
    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
    "transforms.route.type": "org.apache.kafka.connect.transforms.RegexRouter",
    "transforms.route.regex": "(.*)",
    "transforms.route.replacement": ""$1"",
    "key.converter.schemas.enable": false,
    "value.converter.schemas.enable": false,
    "value.converter": "org.apache.kafka.connect.json.JsonConverter"
  }
}
```

* **mongo-sink-connector.json**

```json
{
  "name": "mongo-sink-connector",
  "config": {
    "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
    "tasks.max": "1",
    "topics": "omura-pg.public.orders,omura-pg.public.customers",
    "connection.uri": "mongodb://mongodb:27017/omura",
    "database": "omura",
    "collection": "${topic}",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter"
  }
}
```

* **deployment.yaml**, **service.yaml**, **ingress.yaml** remain as before, ensure ports for Kafka Connect (8083) are exposed.

### 🛠️ Updated Local Setup

1. **Build & start services**

   ```bash
   bash scripts/build-and-run.sh
   ```
2. **Create Debezium connector**

   ```bash
   kubectl apply -f k8s/debezium-connector-postgres.json
   kubectl apply -f k8s/mongo-sink-connector.json
   ```
3. **Verify**

   * PostgreSQL CLI: `kubectl exec -it svc/postgres -n poc -- psql -U omura_user -d omura`
   * Kafka topics: `kubectl exec -it deploy/kafka -n poc -- kafka-topics --bootstrap-server localhost:9092 --list`
   * MongoDB shell: `kubectl exec -it deploy/mongodb -n poc -- mongo omura`

All services run under namespace `poc`, and you can connect via `kubectl port-forward` or `docker exec`.

**Repo:** [https://github.com/viniciof1211/poc-data-architect-realtime-on-quarkus](https://github.com/viniciof1211/poc-data-architect-realtime-on-quarkus)

---

## 🌿 Branch Strategy & CI/CD

1. **feature/init** – Bootstrap of Docker, scripts, k8s YAMLs.
2. **dev** – Integration/testing branch; GitHub Actions deploy to dev cluster.
3. **prod** – Production-grade Helm charts, hardened configs.

All commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).

---

Ready to collaborate! Please review and comment in this repo, and watch as we iterate through features, dev tests, and production releases.

_Vinicio S. Flores - Data Architect & Senior Engineer._