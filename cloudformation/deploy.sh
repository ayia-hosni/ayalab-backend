#!/usr/bin/env bash
# Run from the project root: bash cloudformation/deploy.sh
set -euo pipefail

STACK_NAME="ayalab-backend"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"
APP_VERSION="${APP_VERSION:-1.0.0}"
JAR_PATH="target/aya-lab-backend-${APP_VERSION}.jar"
TEMPLATE="cloudformation/main.yaml"

# ── Derive a unique, account-scoped bucket name ───────────────────────────────
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --region "$REGION")
BUCKET_NAME="ayalab-assets-${ACCOUNT_ID}"

echo "Region   : $REGION"
echo "Account  : $ACCOUNT_ID"
echo "Bucket   : $BUCKET_NAME"
echo "JAR      : $JAR_PATH"
echo ""

# ── Prompt for sensitive values ───────────────────────────────────────────────
read -rsp "DB password (min 8 chars): " DB_PASSWORD; echo
read -rp  "Frontend origin [http://localhost:4200]: " FRONTEND_ORIGIN
FRONTEND_ORIGIN="${FRONTEND_ORIGIN:-http://localhost:4200}"

# ── Verify JAR exists ─────────────────────────────────────────────────────────
if [ ! -f "$JAR_PATH" ]; then
  echo "ERROR: $JAR_PATH not found. Run 'mvn package -DskipTests' first." >&2
  exit 1
fi

# ── Step 1: Create S3 bucket (if it doesn't exist) ───────────────────────────
echo ""
echo "Step 1/3 — S3 bucket..."
if ! aws s3 ls "s3://$BUCKET_NAME" --region "$REGION" > /dev/null 2>&1; then
  if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
  else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION"
  fi
  echo "  Created: s3://$BUCKET_NAME"
else
  echo "  Already exists: s3://$BUCKET_NAME"
fi

# Block public access
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# ── Step 2: Upload JAR ────────────────────────────────────────────────────────
echo ""
echo "Step 2/3 — Uploading JAR..."
aws s3 cp "$JAR_PATH" \
  "s3://$BUCKET_NAME/aya-lab-backend-${APP_VERSION}.jar" \
  --region "$REGION"
echo "  Uploaded: aya-lab-backend-${APP_VERSION}.jar"

# ── Step 3: Deploy stack ──────────────────────────────────────────────────────
echo ""
echo "Step 3/3 — Deploying CloudFormation stack (RDS takes ~10 min)..."
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE" \
  --region "$REGION" \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    DBPassword="$DB_PASSWORD" \
    FrontendOrigin="$FRONTEND_ORIGIN" \
    AppVersion="$APP_VERSION" \
    AssetsBucket="$BUCKET_NAME"

# ── Print outputs ─────────────────────────────────────────────────────────────
echo ""
echo "Done. Stack outputs:"
aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query 'Stacks[0].Outputs[*].[Description,OutputValue]' \
  --output table
