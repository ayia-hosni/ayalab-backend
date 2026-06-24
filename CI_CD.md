# CI/CD — GitHub Actions → Hetzner VPS

Every push to `main` automatically builds the project and deploys it to the Hetzner VPS via SSH.

## Contents

- [How it works](#how-it-works)
- [One-time VPS setup](#one-time-vps-setup)
- [GitHub secrets](#github-secrets)
- [Deploying](#deploying)
- [Monitoring a deployment](#monitoring-a-deployment)
- [Rolling back](#rolling-back)
- [Troubleshooting](#troubleshooting)

---

## How it works

```
push to main
     │
     ▼
GitHub Actions runner (ubuntu-latest)
  1. Checkout code
  2. Set up Java 17 + Maven cache
  3. mvn package -DskipTests  →  target/*.jar
     │
     ▼ SSH (appleboy/ssh-action)
Hetzner VPS  /opt/ayalab
  4. git pull origin main
  5. docker compose down
  6. docker compose up -d --build
  7. docker image prune -f
```

The Postgres volume (`postgres_data`) is never touched during a deploy — data is preserved across every redeploy.

Workflow file: [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)

---

## One-time VPS setup

Run these commands once on your Hetzner server. After this, every push to `main` handles deploys automatically.

### 1. Install Docker

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y docker.io docker-compose-plugin git
systemctl enable --now docker
```

### 2. Add the deploy SSH key

The GitHub Actions runner needs its own key pair to SSH into the server.

```bash
# On your local machine — generate a dedicated deploy key (no passphrase)
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/ayalab_deploy -N ""

# Copy the public key to the server
ssh-copy-id -i ~/.ssh/ayalab_deploy.pub root@<server-ip>

# Print the private key — you'll paste this into GitHub secrets
cat ~/.ssh/ayalab_deploy
```

### 3. Clone the repository

```bash
ssh root@<server-ip>
mkdir -p /var/www/aya-lab
git clone <your-repo-url> /var/www/aya-lab/ayalab-backend
cd /var/www/aya-lab/ayalab-backend
```

### 4. Create the environment file

```bash
cat > /var/www/aya-lab/ayalab-backend/.env <<EOF
DB_PASSWORD=a_strong_password_here
FRONTEND_ORIGIN=https://your-frontend-domain.com
PAYMOB_API_KEY=your_api_key
PAYMOB_HMAC_SECRET=your_hmac_secret
PAYMOB_BASE_URL=https://accept.paymob.com/api
PAYMOB_CARD_INTEGRATION_ID=0
PAYMOB_CARD_IFRAME_ID=0
PAYMOB_WALLET_INTEGRATION_ID=0
PAYMOB_KIOSK_INTEGRATION_ID=0
EOF
```

The `.env` file is not committed to git — you manage it directly on the server.

### 5. First manual deploy

```bash
cd /var/www/aya-lab/ayalab-backend
mvn clean package -DskipTests
docker compose up -d --build
```

Verify it's running:

```bash
curl http://localhost:8080/api/problems | jq 'length'
```

---

## GitHub secrets

Go to your repository → **Settings → Secrets and variables → Actions → New repository secret** and add:

| Secret | Value |
|---|---|
| `HETZNER_HOST` | Server IP or domain, e.g. `123.456.789.0` |
| `HETZNER_USER` | SSH user, e.g. `root` |
| `HETZNER_SSH_KEY` | Contents of `~/.ssh/ayalab_deploy` (the private key) |

---

## Deploying

Push to `main`:

```bash
git push origin main
```

That's it. GitHub Actions picks it up immediately. Monitor progress at:

```
https://github.com/<your-org>/<your-repo>/actions
```

---

## Monitoring a deployment

**Watch live logs on the VPS:**

```bash
ssh root@<server-ip>
docker compose -f /var/www/aya-lab/ayalab-backend/docker-compose.yml logs -f backend
```

**Check container status:**

```bash
docker compose -f /var/www/aya-lab/ayalab-backend/docker-compose.yml ps
```

**Check Flyway migration history:**

```bash
docker exec ayalab-postgres-1 psql -U ayalab -d ayalab \
  -c "SELECT version, description, installed_on, success FROM flyway_schema_history ORDER BY installed_rank;"
```

---

## Rolling back

### Option A — revert the commit and push

```bash
git revert HEAD          # creates a revert commit
git push origin main     # triggers a new deploy with the reverted code
```

### Option B — deploy a specific commit directly on the VPS

```bash
ssh root@<server-ip>
cd /var/www/aya-lab/ayalab-backend
git checkout <commit-hash>
docker compose down
docker compose up -d --build
```

---

## Troubleshooting

### Workflow fails at "Deploy to VPS" — `Permission denied (publickey)`

The deploy key isn't authorized on the server.

```bash
# Verify the key is in authorized_keys on the server
ssh root@<server-ip> cat ~/.ssh/authorized_keys

# Test the key manually from your local machine
ssh -i ~/.ssh/ayalab_deploy root@<server-ip> echo "ok"
```

Make sure the private key in the `HETZNER_SSH_KEY` secret has no trailing newline issues — paste the raw output of `cat ~/.ssh/ayalab_deploy`.

### `git pull` fails — merge conflict

The `.env` file or other local changes on the server conflict with the incoming commit.

```bash
ssh root@<server-ip>
cd /var/www/aya-lab/ayalab-backend
git status             # see what's conflicting
git stash              # stash local changes
git pull origin main
git stash pop          # re-apply (or skip if not needed)
```

### `docker compose up` fails — port 8080 already in use

```bash
ssh root@<server-ip>
lsof -i :8080          # find the process
docker compose -f /var/www/aya-lab/ayalab-backend/docker-compose.yml down   # clean stop
docker compose -f /var/www/aya-lab/ayalab-backend/docker-compose.yml up -d --build
```

### Spring Boot exits immediately after container starts

Check the logs:

```bash
docker compose -f /var/www/aya-lab/ayalab-backend/docker-compose.yml logs backend
```

Common causes:
- `.env` is missing or has a wrong `DB_PASSWORD` — Postgres rejects the connection
- A Flyway migration failed — check for `FlywayException` in the logs
- `PAYMOB_*` vars are missing — the app will still start but payment routes will error at runtime

### Workflow never triggers

Make sure the workflow file is on `main` (not just a feature branch) and the branch filter in `deploy.yml` matches:

```yaml
on:
  push:
    branches: [main]
```
