# Deployment Guide

All options for running ayalab-backend on a server or in the cloud.
For local development, see [DEVELOPMENT.md](DEVELOPMENT.md).

## Contents

- [Comparison](#comparison)
- [Option 1 — Docker Compose](#option-1--docker-compose)
- [Option 2 — Podman](#option-2--podman)
- [Option 3 — Kubernetes](#option-3--kubernetes)
- [Option 4 — AWS + Terraform](#option-4--aws--terraform)
- [Option 5 — AWS + CloudFormation](#option-5--aws--cloudformation)
- [Option 6 — AWS + CDK](#option-6--aws--cdk-java)
- [Option 7 — Hetzner VPS](#option-7--hetzner-vps)
- [Option 8 — Azure + Terraform](#option-8--azure--terraform)

---

## Comparison

| Option | Where | Cost | Complexity |
|---|---|---|---|
| [Docker Compose](#option-1--docker-compose) | Any Linux VPS | VPS cost only | Low |
| [Podman](#option-2--podman) | Any Linux VPS | VPS cost only | Low |
| [Kubernetes](#option-3--kubernetes) | Any cluster | Cluster cost | Medium |
| [Terraform](#option-4--aws--terraform) | AWS | Free 12 mo → ~$15/mo | Medium |
| [CloudFormation](#option-5--aws--cloudformation) | AWS | Free 12 mo → ~$15/mo | Medium |
| [CDK](#option-6--aws--cdk-java) | AWS | Free 12 mo → ~$15/mo | Medium |
| [Hetzner VPS](#option-7--hetzner-vps) | Hetzner | €3.29/mo forever | Low |
| [Azure + Terraform](#option-8--azure--terraform) | Azure | ~$15-20/mo | Medium |

---

## Option 1 — Docker Compose

Runs the full stack (backend + PostgreSQL) on any server with Docker installed.

**Step 1 — Build the JAR:**

```bash
mvn package -DskipTests
```

**Step 2 — Create the env file:**

```bash
cp .env.example .env
# edit .env: set DB_PASSWORD and FRONTEND_ORIGIN
```

**Step 3 — Start:**

```bash
docker compose up -d --build
```

**Useful commands:**

```bash
docker compose ps                      # status
docker compose logs -f backend         # stream logs
docker compose restart backend         # restart after config change
docker compose down                    # stop (data preserved)
docker compose down -v                 # stop and delete all data
```

---

## Option 2 — Podman

Same as Docker Compose but without a daemon. Uses a Podman pod so the backend reaches Postgres on `localhost`.

**Step 1 — Build:**

```bash
mvn package -DskipTests
podman build -t ayalab-backend:latest .
```

**Step 2 — Create a shared pod:**

```bash
podman pod create --name ayalab -p 8080:8080 -p 5432:5432
```

**Step 3 — Start PostgreSQL:**

```bash
podman run -d --pod ayalab --name ayalab-postgres \
  -e POSTGRES_DB=ayalab \
  -e POSTGRES_USER=ayalab \
  -e POSTGRES_PASSWORD=ayalab \
  postgres:16
```

**Step 4 — Wait for Postgres:**

```bash
podman exec ayalab-postgres pg_isready -U ayalab
# repeat until: /var/run/postgresql:5432 - accepting connections
```

**Step 5 — Start the backend:**

```bash
podman run -d --pod ayalab --name ayalab-backend \
  -e DB_URL=jdbc:postgresql://localhost:5432/ayalab \
  -e DB_USERNAME=ayalab \
  -e DB_PASSWORD=ayalab \
  ayalab-backend:latest
```

**Step 6 — Verify:**

```bash
curl http://localhost:8080/api/problems | jq '.[0]'
```

**Teardown:**

```bash
podman pod stop ayalab && podman pod rm ayalab
```

---

## Option 3 — Kubernetes

**Step 1 — Build and load the image into your cluster:**

```bash
mvn package -DskipTests
docker build -t ayalab-backend:latest .

# minikube:
minikube image load ayalab-backend:latest

# kind:
kind load docker-image ayalab-backend:latest
```

**Step 2 — Apply manifests in order:**

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml
kubectl rollout status deployment/postgres -n ayalab
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl rollout status deployment/ayalab-backend -n ayalab
```

**Step 3 — Verify:**

```bash
kubectl get pods -n ayalab
kubectl port-forward svc/ayalab-backend 8080:8080 -n ayalab
curl http://localhost:8080/api/problems | jq '.[0]'
```

The backend `Service` is `ClusterIP` — expose it externally via your Ingress at `/api`.

**Teardown:**

```bash
kubectl delete namespace ayalab
```

---

### Provisioning a Hetzner k3s cluster for CI/CD (`KUBE_CONFIG_HETZNER`)

`.github/workflows/deploy-hetzner-k8s.yml` deploys to a real cluster on every push to `main`, authenticating with the `KUBE_CONFIG_HETZNER` secret. Unlike the local minikube/kind setup above, this cluster has to actually exist and be reachable from GitHub's runners. If you don't have one yet:

**Step 1 — Provision a server.** Via the Hetzner Cloud Console or `hcloud` CLI. At least CX21 (2 vCPU/4GB) — `k8s/backend-deployment.yaml` requests 250m CPU / 512Mi memory per pod with 3 replicas, plus Postgres and HPA headroom up to 10 replicas.

**Step 2 — Install k3s** (lightweight single-node Kubernetes, compatible with everything in `k8s/`):

```bash
ssh root@<new-server-ip>
curl -sfL https://get.k3s.io | sh -
```

This starts a single-node cluster and writes a kubeconfig to `/etc/rancher/k3s/k3s.yaml`.

**Step 3 — Fix the kubeconfig's server address.** It defaults to `127.0.0.1`, which only works from inside the node itself:

```bash
sudo cat /etc/rancher/k3s/k3s.yaml > k3s-fixed.yaml
# edit k3s-fixed.yaml: replace https://127.0.0.1:6443 with https://<new-server-ip>:6443
```

**Step 4 — Open the API port.** GitHub's runners need to reach port `6443`:

```bash
# Hetzner Cloud Console → Firewalls → add rule: TCP 6443, source 0.0.0.0/0
# (or restrict to GitHub Actions' published runner IP ranges)
```

**Step 5 — Set the GitHub secret:**

```bash
base64 -w0 k3s-fixed.yaml > k3s.b64
gh secret set KUBE_CONFIG_HETZNER < k3s.b64
```

**Step 6 — Verify before trusting CI with it:**

```bash
KUBECONFIG=k3s-fixed.yaml kubectl get nodes
```

Before relying on this in production: the `postgres-pvc.yaml` PVC needs a `StorageClass` — k3s ships with `local-path` by default, which works for a single node but isn't resilient (the volume is tied to that one node's disk). This is a separate cluster from anything running on your Hetzner VPS via `deploy.yml` — moving Postgres here is a real migration, not just flipping CI on.

---

## Option 4 — AWS + Terraform

Provisions VPC, EC2 `t2.micro` (backend in Docker), and RDS `db.t3.micro` (PostgreSQL).
Free for 12 months, then ~$15/mo.

**Prerequisites:**

```bash
brew install terraform awscli
aws configure   # IAM Access Key ID + Secret
```

**Step 1 — Build the JAR:**

```bash
mvn package -DskipTests
```

**Step 2 — Create your tfvars:**

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# edit: set db_password, ssh_public_key, frontend_origin
```

**Step 3 — Deploy:**

```bash
cd terraform
terraform init
terraform plan
terraform apply   # ~10 min — RDS is the slow part
```

Terraform prints `backend_url`, `ssh_command`, and `rds_endpoint` when done.

**Step 4 — Verify:**

```bash
curl http://<public-ip>:8080/api/problems | jq '.[0]'
```

**Redeploy after code changes:**

```bash
mvn package -DskipTests
cd terraform && terraform apply   # detects JAR change via MD5 hash
```

**Teardown:**

```bash
terraform destroy
```

---

## Option 5 — AWS + CloudFormation

Single YAML template. The deploy script uploads the JAR to S3 and runs the stack in one command.
The JAR runs directly under a `systemd` service — no Docker on the server.

**Prerequisites:**

```bash
brew install awscli
aws configure   # IAM Access Key ID + Secret
```

**Step 1 — Build the JAR:**

```bash
mvn package -DskipTests
```

**Step 2 — Deploy:**

```bash
bash cloudformation/deploy.sh
```

The script:
1. Creates a private S3 bucket (`ayalab-assets-<account-id>`)
2. Uploads the JAR
3. Deploys the stack — prompts for DB password and frontend origin
4. Prints outputs when done

Progress is visible in AWS Console → CloudFormation → Stacks → Events.

**Step 3 — Retrieve the SSH key:**

```bash
# use the RetrieveSshKey value from the stack outputs:
aws ssm get-parameter --name /ec2/keypair/<key-id> \
  --with-decryption --query Parameter.Value --output text \
  > ayalab-key.pem && chmod 400 ayalab-key.pem
```

**Step 4 — Verify:**

```bash
curl http://<public-ip>:8080/api/problems | jq '.[0]'
```

**Redeploy after code changes:**

```bash
mvn package -DskipTests
bash cloudformation/deploy.sh
```

**Teardown:**

```bash
bash cloudformation/destroy.sh   # deletes stack + empties S3 bucket
```

---

## Option 6 — AWS + CDK (Java)

Same infra as Terraform but defined in Java. CDK uploads the JAR and Dockerfile to S3
automatically as assets — no SSH provisioners or manual file copying.

**Prerequisites:**

```bash
brew install node awscli
npm install -g aws-cdk
aws configure   # IAM Access Key ID + Secret
```

**Step 1 — Build the JAR:**

```bash
mvn package -DskipTests
```

**Step 2 — Bootstrap CDK** (one-time per AWS account/region):

```bash
cd cdk
cdk bootstrap
```

**Step 3 — Deploy:**

```bash
cdk deploy \
  -c dbPassword=a_strong_password \
  -c frontendOrigin=http://localhost:4200 \
  -c appVersion=1.0.0
```

Takes ~10 minutes. Stack outputs when done:

```
AyalabStack.BackendUrl     = http://<public-ip>:8080
AyalabStack.RetrieveSshKey = aws ssm get-parameter ...
AyalabStack.SshCommand     = ssh -i ayalab-key.pem ubuntu@<public-ip>
AyalabStack.RdsEndpoint    = ayalab-db.xxxx.us-east-1.rds.amazonaws.com
```

**Step 4 — Retrieve the SSH key:**

```bash
aws ssm get-parameter --name /ec2/keypair/<key-id> \
  --with-decryption --query Parameter.Value --output text \
  > ayalab-key.pem && chmod 400 ayalab-key.pem
```

**Step 5 — Verify:**

```bash
curl http://<public-ip>:8080/api/problems | jq '.[0]'
```

**Redeploy after code changes:**

```bash
mvn package -DskipTests
cd cdk && cdk deploy -c dbPassword=... -c frontendOrigin=... -c appVersion=1.0.0
```

**Teardown:**

```bash
cdk destroy
```

---

## Option 7 — Hetzner VPS

Cheapest long-term option. €3.29/mo for a `CAX11` (ARM, 2 vCPU, 4 GB RAM).

> **Automated deploys:** see [CI_CD.md](CI_CD.md) to set up GitHub Actions so every push to `main` redeploys automatically.

**Step 1 — Create the server:**

1. Sign up at [hetzner.com/cloud](https://www.hetzner.com/cloud) → New project → Add Server
2. Image: **Ubuntu 24.04**, Type: **CAX11**, add your SSH public key
3. Click **Create & Buy Now**

**Step 2 — SSH in and install Docker:**

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y docker.io docker-compose-plugin
systemctl enable --now docker
```

**Step 3 — Copy the project:**

```bash
# from your local machine:
scp -r . root@<server-ip>:/opt/ayalab-backend
```

Or clone from a Git remote if available.

**Step 4 — Build the JAR on the server:**

```bash
apt install -y maven
cd /opt/ayalab-backend
mvn package -DskipTests
```

**Step 5 — Configure and start:**

```bash
echo "DB_PASSWORD=a_strong_password" > .env
echo "FRONTEND_ORIGIN=http://<server-ip>" >> .env
docker compose up -d --build
```

**Step 6 — Verify:**

```bash
curl http://localhost:8080/api/problems | jq '.[0]'
```

**Step 7 — (Optional) HTTPS with Caddy:**

```bash
apt install -y caddy
```

Edit `/etc/caddy/Caddyfile`:

```
api.yourdomain.com {
    reverse_proxy localhost:8080
}
```

```bash
systemctl reload caddy
```

---

## Option 8 — Azure + Terraform

Provisions a VNet, a `Standard_B1s` Linux VM (backend in Docker), and an Azure Database
for PostgreSQL Flexible Server `B_Standard_B1ms`, connected over a private VNet-integrated
subnet. Mirrors the [AWS + Terraform](#option-4--aws--terraform) setup resource-for-resource.

**Prerequisites:**

```bash
brew install terraform azure-cli
az login
```

**Step 1 — Build the JAR:**

```bash
mvn package -DskipTests
```

**Step 2 — Create your tfvars:**

```bash
cp terraform-azure/terraform.tfvars.example terraform-azure/terraform.tfvars
# edit: set db_password, ssh_public_key, frontend_origin
```

**Step 3 — Deploy:**

```bash
cd terraform-azure
terraform init
terraform plan
terraform apply   # ~10 min — PostgreSQL Flexible Server is the slow part
```

Terraform prints `backend_url`, `ssh_command`, and `postgres_fqdn` when done.

**Step 4 — Verify:**

```bash
curl http://<public-ip>:8080/api/problems | jq '.[0]'
```

**Redeploy after code changes:**

```bash
mvn package -DskipTests
cd terraform-azure && terraform apply   # detects JAR change via MD5 hash
```

**Teardown:**

```bash
terraform destroy
```

Caddy auto-provisions a Let's Encrypt certificate. Update `FRONTEND_ORIGIN` in `.env` to your domain, then `docker compose up -d`.
