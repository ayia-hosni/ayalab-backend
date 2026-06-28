# AyaLab — Backend

REST API powering an interactive coding practice platform. Users browse algorithm problems, write JavaScript solutions in the browser, and receive immediate per-test-case feedback evaluated server-side inside a sandboxed engine.

---

## Contents

- [What it does](#what-it-does)
- [Architecture](#architecture)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Quick start](#quick-start)
- [Environment variables](#environment-variables)
- [API reference](#api-reference)
- [Database & migrations](#database--migrations)
- [The JavaScript judge](#the-javascript-judge)
- [Payment system](#payment-system)
- [Key design decisions](#key-design-decisions)
- [Deployment](#deployment)
- [CI/CD](#cicd)
- [Kubernetes — zero-downtime deploys](#kubernetes--zero-downtime-deploys)

---

## What it does

| Capability | Detail |
|---|---|
| Problem catalogue | Filterable by difficulty, topic tag, solve status, and full-text search |
| Code execution | Runs user-submitted JavaScript against hidden test cases |
| Sandboxed judging | GraalVM JS isolates each submission — no eval, no process spawn, 4 s timeout |
| Payment integration | Paymob card, mobile wallet, and kiosk payments with HMAC-verified webhooks |
| Payment dashboard | Real-time KPIs, conversion rate, revenue timeline, and paginated audit log |
| Admin API | Full CRUD for problems and test cases |
| Schema management | Flyway versioned migrations applied automatically on startup |
| Interactive docs | Swagger UI at `/swagger-ui.html` |

---

## Architecture

```
Browser (Angular)
      │  HTTP /api/*
      ▼
┌──────────────────────────────────────────────────────────┐
│  Spring Boot 3.5  (port 8080)                            │
│                                                          │
│  ┌─────────────────┐  ┌──────────────────────────────┐  │
│  │  ProblemCtrl    │  │  PaymentController           │  │
│  │  SubmissionCtrl │  │  DashboardController         │  │
│  │  AdminCtrl      │  │  GlobalExceptionHandler      │  │
│  └────────┬────────┘  └──────────────┬───────────────┘  │
│           │                          │                   │
│  ┌────────▼────────┐  ┌─────────────▼──────────────┐    │
│  │  ProblemService │  │  PaymentOrchestrator        │    │
│  │  SubmissionSvc  │  │  PaymobClient               │    │
│  └────────┬────────┘  └─────────────┬──────────────┘    │
│           │                         │                    │
│  ┌────────▼──────┐  ┌──────────────▼─────────────────┐  │
│  │  Problem      │  │  PaymentOrder / PaymentLog      │  │
│  │  Repository   │  │  Repository (Spring Data JPA)   │  │
│  └────────┬──────┘  └──────────────┬─────────────────┘  │
│           │                        │                     │
│  ┌────────▼────────────────────────▼─────────────────┐  │
│  │  JavaScriptJudge (GraalVM JS — sandboxed)          │  │
│  └───────────────────────────────────────────────────┘  │
└────────────────────────┬─────────────────────────────────┘
                         │ JDBC / Spring Data JPA
                         ▼
                   PostgreSQL 16
                   (Flyway migrations V1–V6)
                         │
                         ▼
               Paymob API (external)
```

---

## Tech stack

| Layer | Choice | Why |
|---|---|---|
| Framework | Spring Boot 3.5 | Production-grade, minimal boilerplate, first-class JPA + validation + events |
| Language | Java 17 | LTS release — records, sealed types, switch expressions |
| Database | PostgreSQL 16 | JSONB for test cases, strong array ops for tag queries |
| ORM | Spring Data JPA | Removes repository boilerplate; custom `@Query` where needed |
| Migrations | Flyway | SQL-first, deterministic versioning, runs on startup with no extra tooling |
| JS sandbox | GraalVM JS 23.1 | Runs user code in a restricted `Context` — no filesystem, no network, timeout enforced |
| Docs | SpringDoc OpenAPI 3 | Auto-generated Swagger UI from annotations, zero config |
| Build | Maven 3.9 | Stable, IDE-friendly, reproducible |
| Container | Docker | Identical image for local dev and production |
| Orchestration | Kubernetes | Rolling-update manifests, HPA, PDB included |
| IaC | Terraform / CloudFormation / CDK | Three options — pick any one |
| Payments | Paymob | Card, wallet, kiosk via a Strategy pattern |

---

## Project structure

```
aya-lab-backend/
├── src/main/java/com/ayalab/
│   ├── AyaLabApplication.java
│   ├── controller/
│   │   ├── ProblemController.java       # GET /api/problems/**
│   │   ├── SubmissionController.java    # POST /api/problems/{slug}/submit
│   │   ├── AdminController.java         # CRUD /api/admin/problems
│   │   ├── PaymentController.java       # POST /api/payments/initiate + webhook
│   │   ├── DashboardController.java     # GET /api/dashboard/stats + logs
│   │   └── GlobalExceptionHandler.java  # maps exceptions → HTTP responses
│   ├── service/
│   │   ├── ProblemService.java
│   │   └── SubmissionService.java
│   ├── judge/
│   │   └── JavaScriptJudge.java         # GraalVM sandboxed execution engine
│   ├── entity/
│   │   ├── Problem.java
│   │   ├── ProblemTestCase.java
│   │   ├── Difficulty.java              # EASY / MEDIUM / HARD
│   │   └── ProblemStatus.java           # TODO / ATTEMPTED / SOLVED
│   ├── dto/
│   │   ├── ProblemSummary.java          # list view (no description, no test cases)
│   │   ├── ProblemDetail.java           # full view with description + starter code
│   │   ├── SubmitRequest.java
│   │   ├── SubmitResult.java            # verdict + per-case results
│   │   ├── DashboardStats.java
│   │   ├── PaymentLogEntry.java
│   │   └── TimelinePoint.java
│   ├── payment/
│   │   ├── PaymentOrchestrator.java     # coordinates the full payment flow
│   │   ├── PaymobClient.java            # HTTP calls to Paymob API
│   │   ├── PaymentMethod.java           # Strategy interface
│   │   ├── method/
│   │   │   ├── CardPaymentMethod.java
│   │   │   ├── MobileWalletPaymentMethod.java
│   │   │   └── KioskPaymentMethod.java
│   │   ├── logging/
│   │   │   ├── PaymentEventType.java    # all event kinds as an enum
│   │   │   ├── PaymentLogEvent.java     # Spring ApplicationEvent
│   │   │   ├── PaymentEventListener.java
│   │   │   └── PaymentLog.java          # persisted log entity
│   │   └── PaymobWebhookVerifier.java
│   ├── repository/
│   │   ├── ProblemRepository.java
│   │   └── ProblemTestCaseRepository.java
│   └── config/
│       ├── WebConfig.java               # CORS
│       ├── PaymentConfig.java           # Paymob properties binding
│       └── OpenApiConfig.java           # Swagger metadata
├── src/main/resources/
│   ├── application.properties
│   └── db/migration/
│       ├── V1__init_schema.sql
│       ├── V2__seed_problems.sql
│       ├── V3__payment_orders.sql
│       ├── V4__payment_logs.sql
│       ├── V5__restructure_for_scale.sql
│       └── V6__add_available_flag.sql
├── k8s/                                 # Kubernetes manifests
├── terraform/                           # AWS infra (VPC + EC2 + RDS)
├── cloudformation/                      # AWS CloudFormation alternative
├── cdk/                                 # AWS CDK (Java) alternative
├── Dockerfile
├── docker-compose.yml
└── pom.xml
```

---

## Quick start

**Prerequisites:** Java 17+, Maven 3.9+, Docker

```bash
# 1. Start Postgres
docker run -d --name ayalab-pg \
  -e POSTGRES_DB=ayalab \
  -e POSTGRES_USER=ayalab \
  -e POSTGRES_PASSWORD=ayalab \
  -p 5432:5432 postgres:16

# 2. Start the API (Flyway migrations run automatically on boot)
mvn spring-boot:run
```

API: `http://localhost:8080`
Swagger UI: `http://localhost:8080/swagger-ui.html`

**Or use Docker Compose (backend + Postgres together):**

```bash
mvn package -DskipTests
cp .env.example .env   # edit DB_PASSWORD and FRONTEND_ORIGIN
docker compose up -d --build
```

For full local setup options, troubleshooting, and IDE config see [RUNNING_LOCALLY.md](RUNNING_LOCALLY.md).

---

## Environment variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `DB_URL` | No | `jdbc:postgresql://localhost:5432/ayalab` | JDBC connection string |
| `DB_USERNAME` | No | `ayalab` | Postgres username |
| `DB_PASSWORD` | **Yes** | — | Postgres password |
| `FRONTEND_ORIGIN` | No | `http://localhost:4200` | CORS allowed origin |
| `PAYMOB_API_KEY` | For payments | — | Paymob secret API key |
| `PAYMOB_HMAC_SECRET` | For payments | — | Webhook HMAC verification secret |
| `PAYMOB_BASE_URL` | No | `https://accept.paymob.com/api` | Paymob API base URL |
| `PAYMOB_CARD_INTEGRATION_ID` | For card payments | — | Paymob card integration ID |
| `PAYMOB_CARD_IFRAME_ID` | For card payments | — | Paymob card iFrame ID |
| `PAYMOB_WALLET_INTEGRATION_ID` | For wallet payments | — | Paymob wallet integration ID |
| `PAYMOB_KIOSK_INTEGRATION_ID` | For kiosk payments | — | Paymob kiosk integration ID |

All variables are read at startup. The app boots without payment vars — payment routes will error at runtime if they are missing.

---

## API reference

Interactive docs with live request testing: `http://localhost:8080/swagger-ui.html`

### Problems

#### `GET /api/problems`

List problems. All query params are optional and combinable.

| Param | Type | Values |
|---|---|---|
| `difficulty` | string | `easy` `medium` `hard` |
| `status` | string | `todo` `attempted` `solved` |
| `tag` | string | e.g. `Linked List`, `Dynamic Programming` |
| `search` | string | Full-text search on title and tags |

**Response `200`:**
```json
[
  {
    "id": 206,
    "title": "Reverse Linked List",
    "slug": "reverse-linked-list",
    "difficulty": "EASY",
    "acceptance": 74.6,
    "status": "TODO",
    "tags": ["Linked List", "Recursion"],
    "available": true
  }
]
```

---

#### `GET /api/problems/tags`

All distinct topic tags, sorted alphabetically.

**Response `200`:**
```json
["Arrays", "Dynamic Programming", "Linked List", "Recursion", "Trees"]
```

---

#### `GET /api/problems/{slug}`

Full problem detail including description and starter code.

**Response `200`:**
```json
{
  "id": 206,
  "title": "Reverse Linked List",
  "slug": "reverse-linked-list",
  "difficulty": "EASY",
  "acceptance": 74.6,
  "status": "TODO",
  "tags": ["Linked List", "Recursion"],
  "description": "Given the head of a singly linked list...",
  "starterCode": {
    "javascript": "var reverseList = function(head) {\n\n};"
  },
  "visualizerType": "POINTER_TRACE",
  "available": true
}
```

**Response `404`:** No problem with that slug.

---

#### `POST /api/problems/{slug}/submit`

Run a JavaScript solution against test cases inside a sandboxed GraalVM engine.

**Request body:**
```json
{
  "code": "var reverseList = function(head) { ... }",
  "submit": true
}
```

`submit: true` runs all hidden test cases. `submit: false` runs only the visible sample subset.

**Response `200`:**
```json
{
  "accepted": true,
  "verdict": "Accepted",
  "compileError": null,
  "runtimeMs": 42,
  "cases": [
    {
      "passed": true,
      "input": [1, 2, 3, 4, 5],
      "expected": [5, 4, 3, 2, 1],
      "actual": [5, 4, 3, 2, 1],
      "error": null
    }
  ]
}
```

Possible verdicts: `Accepted` `Wrong Answer` `Compile Error` `Time Limit Exceeded` `Runtime Error`

---

### Payments

#### `POST /api/payments/initiate`

Creates a Paymob order and returns the checkout URL (card/wallet) or bill reference (kiosk).

**Request body:**
```json
{
  "method": "CARD",
  "amountCents": 10000,
  "currency": "EGP",
  "firstName": "Ahmed",
  "lastName": "Hassan",
  "email": "ahmed@example.com",
  "phoneNumber": "1012345678"
}
```

`method` values: `CARD` `WALLET` `KIOSK`. `phoneNumber` is required for `WALLET`.

**Response `200`:**
```json
{
  "internalRef": "AYA-A3F9C12B4E2D",
  "status": "PENDING",
  "redirectUrl": "https://accept.paymob.com/api/acceptance/iframes/...",
  "billReference": null
}
```

---

#### `POST /api/payments/webhook`

Receives transaction callbacks from Paymob. Verifies HMAC before updating order status. Called by Paymob — not by your frontend.

| Query param | Required | Description |
|---|---|---|
| `hmac` | Yes | HMAC signature from Paymob |

---

#### `GET /api/payments/{ref}/status`

Poll the status of a payment by internal reference.

**Response `200`:**
```json
{
  "internalRef": "AYA-A3F9C12B4E2D",
  "status": "PAID",
  "redirectUrl": "https://accept.paymob.com/...",
  "billReference": null
}
```

Status values: `PENDING` `PAID` `FAILED`

---

### Dashboard

#### `GET /api/dashboard/stats?period=week`

Aggregate KPIs for the given period.

| Param | Values | Default |
|---|---|---|
| `period` | `day` `week` `month` | `week` |

**Response `200`:**
```json
{
  "total": 142,
  "succeeded": 118,
  "failed": 24,
  "conversionRate": 83.1,
  "totalRevenueCents": 1180000,
  "byMethod": { "CARD": 95, "WALLET": 42, "KIOSK": 5 },
  "timeline": [
    { "label": "2026-06-22", "initiated": 18, "succeeded": 15, "failed": 3 }
  ]
}
```

---

#### `GET /api/dashboard/logs?page=0&size=20&eventType=PAYMENT_COMPLETED`

Paginated payment event audit log, newest first.

Event types: `PAYMENT_INITIATED` `PAYMENT_COMPLETED` `PAYMENT_FAILED` `WEBHOOK_RECEIVED` `WEBHOOK_VERIFIED` `WEBHOOK_REJECTED` `PAYMOB_AUTH_SUCCESS` `PAYMOB_AUTH_FAILED` `ORDER_REGISTERED` `PAYMENT_KEY_GENERATED` `METHOD_EXECUTED`

---

### Admin

All endpoints under `/api/admin/problems`. No auth is currently enforced — secure this route before exposing it publicly.

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/admin/problems` | List all problems with test cases |
| `GET` | `/api/admin/problems/{id}` | Get one problem with test cases |
| `POST` | `/api/admin/problems` | Create a problem |
| `PUT` | `/api/admin/problems/{id}` | Replace a problem and its test cases |
| `DELETE` | `/api/admin/problems/{id}` | Delete a problem and its test cases |

**Create/update request body:**
```json
{
  "id": 206,
  "title": "Reverse Linked List",
  "slug": "reverse-linked-list",
  "difficulty": "EASY",
  "acceptance": 74.6,
  "tags": ["Linked List", "Recursion"],
  "description": "Given the head of a singly linked list...",
  "starterCode": { "javascript": "var reverseList = function(head) {};" },
  "visualizerType": "POINTER_TRACE",
  "available": true,
  "testCases": [
    {
      "ordinal": 1,
      "sample": true,
      "inputJson": "[1,2,3,4,5]",
      "outputJson": "[5,4,3,2,1]"
    }
  ]
}
```

---

## Database & migrations

Flyway manages all schema changes. Migrations run automatically when the app boots. Never use `spring.jpa.hibernate.ddl-auto=create` or `update` — Hibernate is set to `validate` only.

| Version | File | Contents |
|---|---|---|
| V1 | `V1__init_schema.sql` | `problems`, `problem_tags`, `problem_starter_code`, `problem_test_cases` tables |
| V2 | `V2__seed_problems.sql` | Initial problem data |
| V3 | `V3__payment_orders.sql` | `payment_orders` table |
| V4 | `V4__payment_logs.sql` | `payment_logs` audit table |
| V5 | `V5__restructure_for_scale.sql` | Indexes and FK constraints |
| V6 | `V6__add_available_flag.sql` | `available` column on `problems` |

**Adding a new migration:**

1. Create `src/main/resources/db/migration/V7__your_description.sql`
2. Write forward-only SQL (no rollback scripts — Flyway is append-only)
3. The migration runs on next app startup

**Safe migration rule during rolling deploys:** migrations must be backward-compatible with the version currently running. Never rename or drop a column in the same deploy that starts using it — use a two-deploy approach (add → migrate data → remove).

---

## The JavaScript judge

`JavaScriptJudge` runs user code inside a locked-down GraalVM polyglot context:

```
User JS code
     │
     ▼
GraalVM Context (allowAllAccess = false)
  - No filesystem access
  - No network access
  - No thread spawning
  - No host class access
     │
Wall-clock timeout: 4 000 ms per submission
     │
     ▼
JS harness:
  - Defines ListNode, __fromArray, __toArray
  - Injects user code
  - Calls __run(inputArray) for each test case
     │
     ▼
Result: passed / wrong answer / TLE / runtime error
```

The executor thread is shut down after every submission — a hung GraalVM context cannot block the server indefinitely.

---

## Payment system

The payment system uses the **Strategy pattern** — each payment method (`CARD`, `WALLET`, `KIOSK`) is a separate bean implementing `PaymentMethod`. Adding a new method requires only a new class, no changes to the orchestrator.

**Payment flow:**

```
POST /api/payments/initiate
     │
     ▼
PaymentOrchestrator
  1. Authenticate with Paymob → auth token
  2. Register order → Paymob order ID
  3. Get payment key for the selected method
  4. Execute method-specific logic:
       CARD   → return iframe redirect URL
       WALLET → trigger OTP push to phone
       KIOSK  → return bill reference number
  5. Persist PaymentOrder (status = PENDING)
  6. Log every step as a PaymentLogEvent
     │
     ▼
Paymob processes payment
     │
     ▼
POST /api/payments/webhook  (called by Paymob)
  1. Verify HMAC signature
  2. Update PaymentOrder status → PAID or FAILED
  3. Log webhook result
```

Every event in the flow is published as a Spring `ApplicationEvent` and persisted asynchronously to `payment_logs` by `PaymentEventListener`. This keeps the main transaction clean and provides a full audit trail.

---

## Key design decisions

**GraalVM JS over a Node.js subprocess**
Spawning a child process per submission adds OS overhead, complicates timeouts, and opens shell-injection vectors. GraalVM JS runs in-process inside a `Context` with `allowAllAccess(false)`. No filesystem, no network, no escape. Execution time is capped by a `Future.get(timeout)` before the context is disposed.

**Flyway over Hibernate DDL auto**
`spring.jpa.hibernate.ddl-auto=validate` means Hibernate only checks the schema — it never mutates it. Flyway owns every structural change through numbered SQL scripts that are reviewed, committed, and applied in order. No surprise table drops in production.

**Records for DTOs**
`ProblemSummary`, `ProblemDetail`, `SubmitRequest`, `SubmitResult`, `DashboardStats`, and `TimelinePoint` are Java records — immutable, zero boilerplate, serialise cleanly with Jackson.

**Payment Strategy pattern**
`PaymentOrchestrator` holds a `Map<PaymentMethodType, PaymentMethod>` built from Spring-managed beans. Adding Fawry or Valu later requires only a new `@Component` class — the orchestrator, controller, and database schema stay unchanged.

**Environment-variable-first config**
Every sensitive value is read from environment variables with safe local defaults in `application.properties`. No secrets in code or checked-in config files.

**Event-driven payment logging**
`PaymentOrchestrator` publishes `PaymentLogEvent` Spring events instead of calling the log repository directly. `PaymentEventListener` handles persistence. This decouples the business transaction from the audit trail — a log failure never rolls back a payment.

---

## Deployment

| Option | Infrastructure | Cost | Complexity |
|---|---|---|---|
| [Docker Compose](DEPLOYMENT.md#option-1--docker-compose) | Any Linux VPS | VPS cost only | Low |
| [Podman](DEPLOYMENT.md#option-2--podman) | Any Linux VPS | VPS cost only | Low |
| [Kubernetes](DEPLOYMENT.md#option-3--kubernetes) | Any cluster | Cluster cost | Medium |
| [Terraform](DEPLOYMENT.md#option-4--aws--terraform) | AWS EC2 + RDS | Free 12 mo → ~$15/mo | Medium |
| [CloudFormation](DEPLOYMENT.md#option-5--aws--cloudformation) | AWS EC2 + RDS | Free 12 mo → ~$15/mo | Medium |
| [CDK](DEPLOYMENT.md#option-6--aws--cdk-java) | AWS EC2 + RDS | Free 12 mo → ~$15/mo | Medium |
| [Hetzner VPS](DEPLOYMENT.md#option-7--hetzner-vps) | Hetzner | €3.29/mo forever | Low |

See [DEPLOYMENT.md](DEPLOYMENT.md) for step-by-step instructions for every option.

---

## CI/CD

Two GitHub Actions workflows are included:

| Workflow | File | Trigger | What it does |
|---|---|---|---|
| Hetzner deploy | `.github/workflows/deploy.yml` | Push to `main` | SSH into Hetzner VPS → git pull → docker compose up |
| AWS EKS deploy | `.github/workflows/deploy-aws-eks.yml` | Push to `main` | Build JAR → push to ECR → rolling deploy to EKS → auto-rollback on failure |

**GitHub secrets required for Hetzner:**

| Secret | Value |
|---|---|
| `HETZNER_HOST` | Server IP or domain |
| `HETZNER_USER` | SSH user (e.g. `root`) |
| `HETZNER_SSH_KEY` | Private key contents |

**GitHub secrets required for AWS EKS:**

| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM access key |
| `AWS_SECRET_ACCESS_KEY` | IAM secret key |
| `AWS_REGION` | e.g. `us-east-1` |
| `EKS_CLUSTER_NAME` | e.g. `ayalab-cluster` |
| `DB_USERNAME` | Postgres username |
| `DB_PASSWORD` | Postgres password |

See [CI_CD.md](CI_CD.md) for full setup instructions.

---

## Kubernetes — zero-downtime deploys

The `k8s/` directory contains production-ready manifests.

```
k8s/
├── namespace.yaml           # ayalab namespace
├── configmap.yaml           # non-sensitive env config
├── postgres-secret.yaml     # DB credentials
├── postgres-pvc.yaml        # persistent volume for Postgres data
├── postgres-deployment.yaml
├── postgres-service.yaml
├── backend-deployment.yaml  # rolling update + all 3 probes + resource limits
├── backend-service.yaml     # ClusterIP service
├── pdb.yaml                 # PodDisruptionBudget (minAvailable: 2)
└── hpa.yaml                 # HorizontalPodAutoscaler (3–10 replicas)
```

**Apply manually:**

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml
kubectl rollout status deployment/postgres -n ayalab
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/pdb.yaml
kubectl apply -f k8s/hpa.yaml
```

**Rolling update strategy:**

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0   # never remove an old pod before the new one is ready
    maxSurge: 1         # allow 1 extra pod during rollout
```

With `maxUnavailable: 0`, Kubernetes never terminates an old Pod until a replacement passes its `readinessProbe`. Traffic is never interrupted.

**Rollback:**

```bash
# View history
kubectl rollout history deployment/ayalab-backend -n ayalab

# Roll back to previous version
kubectl rollout undo deployment/ayalab-backend -n ayalab

# Roll back to a specific revision
kubectl rollout undo deployment/ayalab-backend -n ayalab --to-revision=3
```

The EKS CI/CD workflow rolls back automatically if `rollout status` times out.
