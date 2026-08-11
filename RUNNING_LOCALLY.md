# Running Locally

Complete step-by-step guide to get ayalab-backend running on your machine from scratch.

## Contents

- [Prerequisites](#prerequisites)
- [Clone the repository](#clone-the-repository)
- [Option A — Maven + Docker (recommended)](#option-a--maven--docker-recommended)
- [Option B — Full Docker Compose](#option-b--full-docker-compose)
- [Option C — Maven + Podman](#option-c--maven--podman)
- [Verify everything works](#verify-everything-works)
- [Swagger UI](#swagger-ui)
- [Inspect the database](#inspect-the-database)
- [Useful commands](#useful-commands)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Java 17

```bash
# macOS
brew install openjdk@17
echo 'export JAVA_HOME=$(brew --prefix openjdk@17)' >> ~/.zshrc
source ~/.zshrc

# Ubuntu / Debian
sudo apt update && sudo apt install -y openjdk-17-jdk
```

Verify:

```bash
java -version
# openjdk version "17.x.x" ...
```

### Maven 3.9

```bash
# macOS
brew install maven

# Ubuntu / Debian
sudo apt install -y maven
```

Verify:

```bash
mvn -version
# Apache Maven 3.9.x ...
```

### Docker (for running PostgreSQL)

```bash
# macOS — install Docker Desktop from https://docker.com/products/docker-desktop
# or via Homebrew:
brew install --cask docker

# Ubuntu / Debian
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # log out and back in after this
```

Verify:

```bash
docker --version
# Docker version 27.x.x ...
```

---

## Clone the repository

```bash
git clone <repo-url> ayalab-backend
cd ayalab-backend
```

---

## Option A — Maven + Docker (recommended)

Run PostgreSQL in Docker, the Spring Boot app on the host with Maven.
This gives the fastest feedback loop — no container rebuild needed on code changes.

### Step 1 — Start PostgreSQL

```bash
docker run -d \
  --name ayalab-postgres \
  -e POSTGRES_DB=ayalab \
  -e POSTGRES_USER=ayalab \
  -e POSTGRES_PASSWORD=ayalab \
  -p 5432:5432 \
  postgres:16
```

Wait for it to be ready:

```bash
docker exec ayalab-postgres pg_isready -U ayalab
# /var/run/postgresql:5432 - accepting connections
```

### Step 2 — Start the API

```bash
mvn spring-boot:run
```

You should see Spring Boot startup logs ending with:

```
Started AyaLabApplication in X.XXX seconds
```

Flyway automatically applies `V1__init_schema.sql` and `V2__seed_problems.sql` on first start — no manual migration step needed.

### Step 3 — Verify

```bash
curl http://localhost:8080/api/problems | jq '.[0]'
```

Expected output:

```json
{
  "id": 1,
  "title": "Two Sum",
  "slug": "two-sum",
  "difficulty": "easy",
  "status": "todo",
  "tags": ["Array", "Hash Table"],
  ...
}
```

---

## Option B — Full Docker Compose

Runs both PostgreSQL and the backend in containers. Useful for testing the production image locally.

### Step 1 — Build the JAR

```bash
mvn package -DskipTests
```

### Step 2 — Start the stack

```bash
docker compose up --build
```

Use `-d` to run in the background:

```bash
docker compose up -d --build
```

### Step 3 — Verify

```bash
curl http://localhost:8080/api/problems | jq '.[0]'
```

### Step 4 — Stop

```bash
docker compose down         # stops containers, keeps the database volume
docker compose down -v      # stops containers and deletes the database volume
```

---

## Option C — Maven + Podman

Same as Option A but with Podman instead of Docker — no daemon required.

### Step 1 — Install Podman

```bash
# macOS
brew install podman
podman machine init
podman machine start

# Ubuntu / Debian
sudo apt install -y podman
```

Verify:

```bash
podman --version
# podman version 5.x.x
```

### Step 2 — Start PostgreSQL

```bash
podman run -d \
  --name ayalab-postgres \
  -e POSTGRES_DB=ayalab \
  -e POSTGRES_USER=ayalab \
  -e POSTGRES_PASSWORD=ayalab \
  -p 5432:5432 \
  postgres:16
```

Wait for it to be ready:

```bash
podman exec ayalab-postgres pg_isready -U ayalab
# /var/run/postgresql:5432 - accepting connections
```

### Step 3 — Start the API

```bash
mvn spring-boot:run
```

### Step 4 — Verify

```bash
curl http://localhost:8080/api/problems | jq '.[0]'
```

### Teardown

```bash
podman stop ayalab-postgres
podman rm ayalab-postgres
```

---

## Verify everything works

Once the API is running, run through these checks:

```bash
# 1. List all problems
curl http://localhost:8080/api/problems | jq 'length'

# 2. Filter by difficulty
curl "http://localhost:8080/api/problems?difficulty=easy" | jq '.[].title'

# 3. Search by keyword
curl "http://localhost:8080/api/problems?search=two" | jq '.[].title'

# 4. Get all topic tags
curl http://localhost:8080/api/problems/tags

# 5. Get a specific problem by slug
curl http://localhost:8080/api/problems/two-sum | jq '{title, difficulty, description}'

# 6. Submit a solution (run only)
curl -s -X POST http://localhost:8080/api/problems/two-sum/submit \
  -H "Content-Type: application/json" \
  -d '{
    "language": "javascript",
    "code": "function solution(nums, target) { const map = {}; for (let i = 0; i < nums.length; i++) { const comp = target - nums[i]; if (comp in map) return [map[comp], i]; map[nums[i]] = i; } }",
    "submit": false
  }' | jq '{accepted, verdict, runtimeMs}'
```

---

## Swagger UI

With the API running, open your browser at:

```
http://localhost:8080/swagger-ui.html
```

From Swagger UI you can:
- Browse all endpoints grouped by tag (**Problems**, **Submissions**)
- See full request/response schemas with field descriptions and example values
- Execute requests directly — no curl or Postman needed

The raw OpenAPI spec (useful for importing into Postman or Insomnia):

```
http://localhost:8080/v3/api-docs
```

---

## Inspect the database

Connect to the running PostgreSQL container to inspect the schema or data directly.

**Using psql inside the container:**

```bash
# Docker
docker exec -it ayalab-postgres psql -U ayalab -d ayalab

# Podman
podman exec -it ayalab-postgres psql -U ayalab -d ayalab
```

Useful psql commands:

```sql
\dt                         -- list all tables
\d problems                 -- describe the problems table
SELECT id, title, slug, difficulty FROM problems;
SELECT * FROM flyway_schema_history;   -- migration history
\q                          -- quit
```

**Using a GUI client (TablePlus, DBeaver, DataGrip):**

| Setting  | Value      |
|----------|------------|
| Host     | `localhost` |
| Port     | `5432`     |
| Database | `ayalab`   |
| User     | `ayalab`   |
| Password | `ayalab`   |

---

## Useful commands

```bash
# Rebuild without running tests
mvn package -DskipTests

# Run only tests
mvn test

# Run with a different port
SERVER_PORT=9090 mvn spring-boot:run

# Run with a custom DB
DB_URL=jdbc:postgresql://localhost:5432/mydb \
DB_USERNAME=myuser \
DB_PASSWORD=mypass \
mvn spring-boot:run

# Stream application logs (Docker Compose)
docker compose logs -f backend

# Check Flyway migration status via psql
docker exec -it ayalab-postgres psql -U ayalab -d ayalab \
  -c "SELECT version, description, installed_on, success FROM flyway_schema_history ORDER BY installed_rank;"
```

---

## Troubleshooting

### Port 5432 already in use

Another process is using PostgreSQL's port.

```bash
# Find what's using it
lsof -i :5432

# Kill it (replace <PID> with the actual PID)
kill -9 <PID>

# Or change the host port when starting the container
docker run -d --name ayalab-postgres -p 5433:5432 \
  -e POSTGRES_DB=ayalab -e POSTGRES_USER=ayalab -e POSTGRES_PASSWORD=ayalab \
  postgres:16

# Then start the app pointing at the new port
DB_URL=jdbc:postgresql://localhost:5433/ayalab mvn spring-boot:run
```

### Port 8080 already in use

```bash
lsof -i :8080          # find what's using it
SERVER_PORT=8090 mvn spring-boot:run   # or run on a different port
```

### Flyway migration fails on startup

Usually means the database already has a partial schema from a failed previous run.

```bash
# Connect and clean the flyway history table
docker exec -it ayalab-postgres psql -U ayalab -d ayalab \
  -c "DELETE FROM flyway_schema_history WHERE success = false;"

# Restart the app — Flyway will retry the failed migration
mvn spring-boot:run
```

### `java.net.ConnectException: Connection refused` on startup

PostgreSQL isn't ready yet or isn't running.

```bash
# Check if the container is running
docker ps

# Check if Postgres is accepting connections
docker exec ayalab-postgres pg_isready -U ayalab

# View Postgres logs
docker logs ayalab-postgres
```

### `Unable to acquire JDBC Connection` after a while

The connection pool exhausted — usually caused by a code bug holding connections open. Check the app logs for stack traces and restart:

```bash
# Ctrl+C the running app, then:
mvn spring-boot:run
```

### Maven build fails — `JAVA_HOME` not set

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)   # macOS
# or
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64  # Linux

mvn spring-boot:run
```
