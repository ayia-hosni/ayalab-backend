# ayalab — Backend

REST API powering an interactive coding practice platform.

## Contents

- [What it does](#what-it-does)
- [Architecture](#architecture)
- [Tech stack and why](#tech-stack-and-why)
- [Key design decisions](#key-design-decisions)
- [API surface](#api-surface)
- [Running locally in 2 commands](#running-locally-in-2-commands) Users browse algorithm problems, write JavaScript solutions in the browser, and get immediate pass/fail feedback with per-test-case results — all evaluated server-side in a sandboxed engine.

---

## What it does

| Capability | Detail |
|---|---|
| Problem catalogue | Filterable by difficulty, topic tag, and solve status |
| Code execution | Runs user-submitted JavaScript against hidden test cases |
| Sandboxed judging | GraalVM JS isolates each submission — no `eval`, no Node.js process spawn |
| Schema management | Flyway versioned migrations; schema and seed data applied automatically on boot |
| Containerised | Single Dockerfile; full stack via Docker Compose or Kubernetes manifests |
| Cloud-ready | Terraform config provisions EC2 + RDS on AWS free tier in one command |

---

## Architecture

```
Browser (Angular)
      │  HTTP /api/*
      ▼
┌─────────────────────────────────┐
│  Spring Boot 3.5  (port 8080)   │
│                                 │
│  ProblemController              │
│  SubmissionController           │
│       │                         │
│  ProblemService                 │
│  SubmissionService              │
│       │            │            │
│  ProblemRepository  JavaScriptJudge  │
│  (Spring Data JPA)  (GraalVM JS)│
└────────┬────────────────────────┘
         │ JDBC
         ▼
   PostgreSQL 16
   (Flyway migrations)
```

---

## Tech stack and why

| Layer | Choice | Rationale |
|---|---|---|
| Framework | Spring Boot 3.5 | Production-grade, minimal boilerplate, first-class JPA + validation |
| Language | Java 17 | LTS, records, sealed types, virtual threads ready |
| Database | PostgreSQL 16 | JSONB support for test cases, strong array ops for tag queries |
| ORM | Spring Data JPA | Removes repository boilerplate; custom `@Query` where needed |
| Migrations | Flyway | SQL-first, deterministic versioning, runs on startup with no extra tooling |
| JS sandbox | GraalVM JS (GraalJS 23.1) | Runs user code inside a restricted `Context` — no filesystem, no network, timeout enforced |
| Build | Maven 3.9 | Stable, IDE-friendly, reproducible builds |
| Container | Docker / Podman | Identical image for local dev and production |
| Orchestration | Kubernetes | Manifests included for cluster deployments |
| IaC | Terraform | Reproducible AWS infra (VPC, EC2, RDS) in code; `terraform destroy` leaves no orphaned resources |

---

## Key design decisions

**GraalVM JS over a Node.js subprocess**
Spawning a child process per submission adds OS overhead, complicates timeouts, and opens shell-injection vectors. GraalVM JS runs in-process inside a `Context` with `allowAllAccess(false)` — no threads, no I/O, no escape from the sandbox. Execution time is capped before the context is disposed.

**Flyway over Hibernate DDL auto**
`spring.jpa.hibernate.ddl-auto=validate` means Hibernate only checks the schema — it never mutates it. Flyway owns every structural change through numbered migration scripts that are reviewed, committed, and applied in order. No surprise table drops in production.

**Records for DTOs**
`ProblemSummary`, `ProblemDetail`, `SubmitRequest`, and `SubmitResult` are Java records — immutable, no boilerplate, serialise cleanly with Jackson.

**Environment-variable-first config**
Every sensitive value (`DB_URL`, `DB_PASSWORD`, `FRONTEND_ORIGIN`) is read from environment variables with safe local defaults in `application.properties`. No secrets in code or config files.

---

## API surface

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/problems` | List problems — filter by `difficulty`, `status`, `tag`, `search` |
| `GET` | `/api/problems/tags` | All distinct topic tags |
| `GET` | `/api/problems/{slug}` | Full problem detail with description and starter code |
| `POST` | `/api/problems/{slug}/submit` | Run a JS solution; returns pass/fail per test case |

Interactive docs and live request testing: `http://localhost:8080/swagger-ui.html`

---

## Running locally in 2 commands

```bash
# 1. Start Postgres
docker run -d --name ayalab-pg -e POSTGRES_DB=ayalab \
  -e POSTGRES_USER=ayalab -e POSTGRES_PASSWORD=ayalab \
  -p 5432:5432 postgres:16

# 2. Start the API (Flyway migrations run automatically)
mvn spring-boot:run
```

API available at `http://localhost:8080`.

Full local setup, API reference, and environment variables: **[DEVELOPMENT.md](DEVELOPMENT.md)**

Deploying to a server or cloud (Docker Compose, Kubernetes, Terraform, CloudFormation, CDK, Hetzner): **[DEPLOYMENT.md](DEPLOYMENT.md)**
