#!/usr/bin/env bash
# Run from the project root: bash cloudformation/destroy.sh
set -euo pipefail

STACK_NAME="ayalab-backend"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"
APP_VERSION="${APP_VERSION:-1.0.0}"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --region "$REGION")
BUCKET_NAME="ayalab-assets-${ACCOUNT_ID}"

read -rp "Delete stack '$STACK_NAME' and bucket '$BUCKET_NAME'? [y/N] " CONFIRM
[ "$CONFIRM" = "y" ] || { echo "Aborted."; exit 0; }

echo "Deleting CloudFormation stack..."
aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION"
aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$REGION"
echo "Stack deleted."

echo "Emptying and deleting S3 bucket..."
aws s3 rm "s3://$BUCKET_NAME" --recursive --region "$REGION"
aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION"
echo "Bucket deleted."

echo "All resources removed."
