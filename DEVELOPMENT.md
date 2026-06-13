# Development Guide

Local setup, API reference, and project structure.
For deploying to a server or cloud, see [DEPLOYMENT.md](DEPLOYMENT.md).

## Contents

- [Prerequisites](#prerequisites)
- [Running locally](#running-locally)
- [API reference](#api-reference)
- [Swagger UI](#swagger-ui)
- [Environment variables](#environment-variables)
- [Project layout](#project-layout)

---

## Prerequisites

| Tool             | Version        | Check                                   |
|------------------|----------------|-----------------------------------------|
| Java JDK         | 17 or newer    | `java -version`                         |
| Maven            | 3.9 or newer   | `mvn -version`                          |
| Docker or Podman | any (optional) | `docker --version` / `podman --version` |

---

## Running locally

### Step 1 — Start PostgreSQL

**Option A — Docker / Podman:**

```bash
docker run -d \
  --name ayalab-postgres \
  -e POSTGRES_DB=ayalab \
  -e POSTGRES_USER=ayalab \
  -e POSTGRES_PASSWORD=ayalab \
  -p 5432:5432 \
  postgres:16
```

**Option B — Kubernetes (minikube / kind):**

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml
```

Default connection the app expects:

| Setting  | Value    |
|----------|----------|
| Host     | `localhost` |
| Port     | `5432`   |
| Database | `ayalab` |
| User     | `ayalab` |
| Password | `ayalab` |

Flyway runs schema + seed migrations automatically on first start — no manual step needed.

### Step 2 — Start the API

```bash
mvn spring-boot:run
```

Override DB connection without touching any file:

```bash
DB_URL=jdbc:postgresql://localhost:5432/mydb \
DB_USERNAME=myuser \
DB_PASSWORD=mypass \
mvn spring-boot:run
```

API available at **http://localhost:8080**.

Smoke test:

```bash
curl http://localhost:8080/api/problems | jq '.[0]'
```

---

## API reference

| Method | Path                          | Description                              |
|--------|-------------------------------|------------------------------------------|
| GET    | `/api/problems`               | List problems (supports filter params)   |
| GET    | `/api/problems/tags`          | All distinct topic tags                  |
| GET    | `/api/problems/{slug}`        | Full problem detail                      |
| POST   | `/api/problems/{slug}/submit` | Submit a JavaScript solution for judging |

### Filter params — `GET /api/problems`

| Param        | Example       | Description                    |
|--------------|---------------|--------------------------------|
| `difficulty` | `easy`        | Filter by difficulty level     |
| `status`     | `solved`      | Filter by user status          |
| `search`     | `reverse`     | Full-text search on title/tags |
| `tag`        | `Linked List` | Filter by topic tag            |

All params are optional and combinable.

### Submit — request body

```json
{
  "code": "function solution(arr) { return arr.reverse(); }"
}
```

### Submit — response

```json
{
  "accepted": true,
  "passedCount": 5,
  "totalCount": 5,
  "runtime": "12ms",
  "error": null
}
```

---

## Swagger UI

When the API is running, interactive documentation is available at:

| URL | Description |
|-----|-------------|
| `http://localhost:8080/swagger-ui.html` | Swagger UI — browse and try every endpoint |
| `http://localhost:8080/v3/api-docs` | Raw OpenAPI JSON spec |

All request/response schemas, filter parameters, and example values are documented inline. No external tool needed.

---

## Environment variables

| Variable          | Default                                   | Description         |
|-------------------|-------------------------------------------|---------------------|
| `DB_URL`          | `jdbc:postgresql://localhost:5432/ayalab` | JDBC connection URL |
| `DB_USERNAME`     | `ayalab`                                  | Database user       |
| `DB_PASSWORD`     | `ayalab`                                  | Database password   |
| `SERVER_PORT`     | `8080`                                    | HTTP port           |
| `FRONTEND_ORIGIN` | `http://localhost:4200`                   | CORS allowed origin |

---

## Project layout

```
aya-lab-backend/
├── Dockerfile
├── docker-compose.yml
├── pom.xml
├── k8s/                        # Kubernetes manifests
├── terraform/                  # AWS IaC — Terraform
├── cloudformation/             # AWS IaC — CloudFormation
├── cdk/                        # AWS IaC — CDK (Java)
└── src/main/
    ├── java/com/ayalab/
    │   ├── AyaLabApplication.java
    │   ├── config/             # CORS
    │   ├── controller/         # REST endpoints + exception handler
    │   ├── dto/                # Request/response records
    │   ├── entity/             # JPA entities and enums
    │   ├── repository/         # Spring Data JPA
    │   ├── service/            # Business logic
    │   └── judge/              # GraalVM JS sandbox
    └── resources/
        ├── application.properties
        └── db/migration/
            ├── V1__init_schema.sql
            └── V2__seed_problems.sql
```
