# Development Guide

Reference for the API, environment variables, and project structure.

| Guide | What's in it |
|---|---|
| [RUNNING_LOCALLY.md](RUNNING_LOCALLY.md) | Step-by-step local setup (Java, Maven, Docker/Podman, Swagger, troubleshooting) |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Deploy to a server or cloud (Docker Compose, Kubernetes, AWS, Hetzner) |
| [CI_CD.md](CI_CD.md) | GitHub Actions → Hetzner VPS automated deploys |

## Contents

- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
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

See [RUNNING_LOCALLY.md](RUNNING_LOCALLY.md) for installation instructions for each tool.

---

## Quick start

```bash
# 1. Start PostgreSQL
docker run -d --name ayalab-postgres \
  -e POSTGRES_DB=ayalab -e POSTGRES_USER=ayalab -e POSTGRES_PASSWORD=ayalab \
  -p 5432:5432 postgres:16

# 2. Start the API (Flyway migrations run automatically)
mvn spring-boot:run
```

API available at `http://localhost:8080`.
Full setup options and troubleshooting: [RUNNING_LOCALLY.md](RUNNING_LOCALLY.md).

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
  "language": "javascript",
  "code": "function solution(arr) { return arr.reverse(); }",
  "submit": false
}
```

### Submit — response

```json
{
  "accepted": true,
  "verdict": "ACCEPTED",
  "compileError": null,
  "runtimeMs": 12,
  "cases": [
    { "passed": true, "input": [1,2], "expected": [2,1], "actual": [2,1], "error": null }
  ]
}
```

---

## Swagger UI

| URL | Description |
|-----|-------------|
| `http://localhost:8080/swagger-ui.html` | Interactive UI — browse and execute every endpoint |
| `http://localhost:8080/v3/api-docs`     | Raw OpenAPI JSON spec (import into Postman / Insomnia) |

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
    │   ├── config/             # CORS + OpenAPI config
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
