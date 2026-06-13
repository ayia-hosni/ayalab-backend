# Pointer Lab — Backend

Spring Boot 3.5 (Java 17) REST API + PostgreSQL. Serves the problem list/detail endpoints and runs JavaScript submissions in a sandboxed GraalVM engine.

---

## Prerequisites

| Tool     | Version     | Check              |
|----------|-------------|--------------------|
| Java JDK | 17 or newer | `java -version`    |
| Maven    | 3.9 or newer| `mvn -version`     |
| Docker   | any         | `docker --version` |

---

## Local development

### 1. Start PostgreSQL

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml
```

Or run Postgres any other way — defaults the app expects:

- database: `pointerlab`
- user: `pointerlab`
- password: `pointerlab`
- port: `5432`

Override with env vars at runtime (no code change needed):

```bash
DB_URL=jdbc:postgresql://localhost:5432/pointerlab \
DB_USERNAME=myuser \
DB_PASSWORD=mypass \
mvn spring-boot:run
```

Flyway applies schema + seed data automatically on first start.

### 2. Run the API

```bash
mvn spring-boot:run
```

API available at **http://localhost:8080**.

```bash
curl http://localhost:8080/api/problems | head
```

---

## API endpoints

| Method | Path                          | Purpose                           |
|--------|-------------------------------|-----------------------------------|
| GET    | `/api/problems`               | List problems (filterable)        |
| GET    | `/api/problems/tags`          | Distinct topic tags               |
| GET    | `/api/problems/{slug}`        | Full problem detail               |
| POST   | `/api/problems/{slug}/submit` | Run/submit a JavaScript solution  |

`GET /api/problems` query params (all optional): `difficulty`, `status`, `search`, `tag`.

---

## Build Docker image

```bash
mvn package -DskipTests
docker build -t pointer-lab-backend:latest .
```

---

## Deploy to Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
```

The backend `Service` is `ClusterIP` — exposed externally via the frontend's Ingress at `/api`.

---

## Environment variables

| Variable          | Default                                        | Purpose              |
|-------------------|------------------------------------------------|----------------------|
| `DB_URL`          | `jdbc:postgresql://localhost:5432/pointerlab`  | JDBC connection URL  |
| `DB_USERNAME`     | `pointerlab`                                   | DB user              |
| `DB_PASSWORD`     | `pointerlab`                                   | DB password          |
| `SERVER_PORT`     | `8080`                                         | HTTP port            |
| `FRONTEND_ORIGIN` | `http://localhost:4200`                        | CORS allowed origin  |

---

## Project layout

```
pointer-lab-backend/
├── Dockerfile
├── pom.xml
├── k8s/
│   ├── namespace.yaml
│   ├── postgres-secret.yaml
│   ├── postgres-pvc.yaml
│   ├── postgres-deployment.yaml
│   ├── postgres-service.yaml
│   ├── backend-deployment.yaml
│   └── backend-service.yaml
└── src/main/
    ├── java/com/pointerlab/
    │   ├── PointerLabApplication.java
    │   ├── config/          # CORS
    │   ├── controller/      # REST endpoints
    │   ├── dto/             # request/response records
    │   ├── entity/          # JPA entities + enums
    │   ├── repository/      # Spring Data JPA
    │   ├── service/         # business logic
    │   └── judge/           # GraalVM JS sandbox
    └── resources/
        ├── application.properties
        └── db/migration/    # Flyway V1 schema + V2 seed
```