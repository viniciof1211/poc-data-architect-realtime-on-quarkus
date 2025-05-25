**README.md**

# POC OMURA Data Architect

This repository contains all artifacts needed to spin up a Proof-of-Concept (POC) for the OMURA Data Architect solution, including Docker, scripts, and Quarkus / Kubernetes manifests.

---

## Repository Layout

```
poc-data-architect-realtime-on-quarkus/
├── README.md                        # POC overview and instructions
├── LICENSE                          # MIT license
├── dir.txt                          # Auto-generated directory listing
│
├── docker/                          # Docker assets for Quarkus + services
│   ├── Dockerfile                   # Builds the Quarkus native image
│   └── docker-compose.yml           # Local multi-container setup (Kafka, ZK, Quarkus)
│
├── k8s/                             # Kubernetes manifests for dev & prod
│   ├── namespace.yaml               # poc namespace definition
│   ├── configmap.yaml               # Environment variables (e.g. POSTGRES_URL)
│   ├── secret.yaml                  # Base64-encoded secrets
│   ├── deployment.yaml              # Catch-all app deployment (ZK, Kafka Connect, etc.)
│   ├── service.yaml                 # ClusterIP / LoadBalancer services
│   ├── ingress.yaml                 # Ingress rules (host/path)
│   ├── debezium-connector-postgres.json  # Debezium Postgres source config
│   └── mongo-sink-connector.json    # MongoDB sink connector config
│
├── postgres/                        # Postgres setup & init scripts
│   ├── init/                        # Database initialization scripts
│   │   ├── schema.sql               # DDL (tables, indexes)
│   │   └── seed-data.sql            # Sample data load
│   └── Dockerfile                   # (Optional) Custom Postgres image with init
│
├── quarkus-app/                     # The Quarkus microservice
│   ├── pom.xml                      # Maven build descriptor
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/                # Application code (packages under com.omura…)
│   │   │   └── resources/           # application.properties, log configs
│   │   └── test/                    # Unit & integration tests
│   └── target/                      # Compiled classes & native runner (git-ignored)
│
├── scripts/                         # Helper scripts for setup & deploy
│   ├── install-k8s.sh               # macOS/Linux Minikube install
│   ├── install-k8s.ps1              # Windows PowerShell Minikube install
│   └── build-and-run.sh             # Builds images, applies k8s, port-forwards
│
└── .github/                         # CI/CD workflows (if still present)
    └── workflows/
        └── ci-cd-pipeline.yml      # GitHub Actions pipeline

```


---


## ODS Architecture Overview
![Operational Data Store: Source Systems → ODS → Data Warehouse → Analytics/BI Tools](ods_architecture_diagram.png "Operational Data Store Integration")

### What it is in a nutshell

An ODS is a database designed to integrate data from multiple operational systems to support operational reporting and decision-making. It sits between your transactional systems (like CRM, ERP, etc.) and your data warehouse.

#### Key characteristics
- Real-time or near real-time data: Unlike traditional data warehouses that are updated in batches, an ODS provides current operational data.
- Integrated view: Combines data from various source systems into a unified, consistent format.
- Operational focus: Designed for day-to-day business operations rather than historical analysis.
- Detailed data: Maintains transaction-level detail rather than summarized data.

#### Common use cases

- Real-time dashboards for operations teams
- Customer service representatives needing a 360-degree customer view
- Regulatory reporting that requires current data
- Operational analytics and monitoring


## Data Pipeline Design Overview
![Architecture Pattern: Real-time Change Data Capture (CDC)](data_pipeline_diagram.png "Near Realtime Sync of Changes from PostgreSQL to MongoDB doc events via Debezium Kafka Connector")

### Architecture Pattern: Real-time Change Data Capture (CDC)

_CDC-to-ODS pipelines in a nutshell! :_

**Data Flow**: PostgreSQL → Kafka (via Debezium) → Quarkus/Camel → MongoDB

## **Key Components Analysis**

**Source Layer (PostgreSQL)**
- Traditional OLTP database with a `clientes` table
- CDC-enabled to capture real-time changes without impacting operational performance

**Streaming Layer (Kafka + Debezium)**
- **Debezium**: Acts as the CDC connector, converting database changes into Kafka events
- **Kafka**: Event streaming backbone with topic-based data distribution
- Provides durability, scalability, and decoupling between source and target systems

**Processing Layer (Quarkus/Camel)**
- **Quarkus**: Cloud-native Java framework for microservices
- **Apache Camel**: Integration framework for data transformation and routing
- Handles real-time stream processing and data transformation logic

**Target Layer (MongoDB)**
- Document-based NoSQL database serving as the ODS
- Optimized for operational queries and flexible schema evolution

## **Architecture Benefits**
- **Real-time data availability**: Near-zero latency for operational insights
- **Loose coupling**: Systems can evolve independently
- **Scalability**: Event-driven architecture scales horizontally
- **Fault tolerance**: Kafka provides message durability and replay capabilities

## **Use Case Fit**
This is a modern, cloud-native approach to building an ODS that prioritizes real-time operational analytics over traditional batch ETL processes. Perfect for customer 360 views, real-time dashboards, and operational decision-making.

---

## 🛠️ Local Setup Steps
Looking at your CDC-to-ODS pipeline, here's the architecture analysis in a nutshell:

## **Architecture Pattern: Real-time Change Data Capture (CDC)**

**Data Flow**: PostgreSQL → Kafka (via Debezium) → Quarkus/Camel → MongoDB

## **Key Components Analysis**

**Source Layer (PostgreSQL)**
- Traditional OLTP database with a `clientes` table
- CDC-enabled to capture real-time changes without impacting operational performance

**Streaming Layer (Kafka + Debezium)**
- **Debezium**: Acts as the CDC connector, converting database changes into Kafka events
- **Kafka**: Event streaming backbone with topic-based data distribution
- Provides durability, scalability, and decoupling between source and target systems

**Processing Layer (Quarkus/Camel)**
- **Quarkus**: Cloud-native Java framework for microservices
- **Apache Camel**: Integration framework for data transformation and routing
- Handles real-time stream processing and data transformation logic

**Target Layer (MongoDB)**
- Document-based NoSQL database serving as the ODS
- Optimized for operational queries and flexible schema evolution

## **Architecture Benefits**
- **Real-time data availability**: Near-zero latency for operational insights
- **Loose coupling**: Systems can evolve independently
- **Scalability**: Event-driven architecture scales horizontally
- **Fault tolerance**: Kafka provides message durability and replay capabilities

## **Use Case Fit**
This is a modern, cloud-native approach to building an ODS that prioritizes real-time operational analytics over traditional batch ETL processes. Perfect for customer 360 views, real-time dashboards, and operational decision-making.
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

---

## 🌿 Branch Strategy & CI/CD

1. **feature/init** – Bootstrap of Docker, scripts, k8s YAMLs.
2. **dev** – Integration/testing branch; GitHub Actions deploy to dev cluster.
3. **prod** – Production-grade Helm charts, hardened configs.

All commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).

---

## 🛠️ Java & Quarkus Stack Steps

1. **Compile & Native Image**

   ```bash
   cd src/quarkus
   mvn clean package -Pnative
   ```
2. **Deploy Quarkus on OpenShift**

   ```bash
   oc apply -f k8s/quarkus-deployment.yaml
   ```
3. **Hot-reload during dev**

   ```bash
   mvn quarkus:dev
   ```
4. **Configure Camel Routes**

   * Place `camel-context.xml` in `src/camel/`
   * Apply via:

     ```bash
     kubectl apply -f k8s/camel-deployment.yaml
     ```
5. **NiFi Flow Deployment**

   ```bash
   iifd import nifi-flow --base-url http://localhost:8080/nifi-api/process-groups/root --flow-file src/nifi/flows.xml
   ```
6. **Kafka Connect Transforms**

   * Edit `transforms.route.replacement` in `debezium-connector-postgres.json`
   * Apply new connector:

     ```bash
     kubectl delete connector omura-postgres-connector
     kubectl apply -f k8s/debezium-connector-postgres.json
     ```

---

Ready to collaborate! Please review and comment in this repo, and watch as we iterate through features, dev tests, and production releases.

*Vinicio S. Flores - Data Architect & Senior Engineer.*
