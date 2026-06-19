#!/bin/bash

# ============================================================
# DEH 30-Day PySpark Challenge — One-Time Setup Script
# Run this in AWS CloudShell to create your S3 bucket and upload datasets
# ============================================================

echo ""
echo "=========================================="
echo "  DEH PySpark Challenge — Setup Script"
echo "=========================================="
echo ""

# Get AWS account ID to create a unique bucket name
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="deh-pyspark-challenge-${ACCOUNT_ID}"
REGION=$(aws configure get region)

if [ -z "$REGION" ]; then
  REGION="us-east-1"
fi

echo "Account ID : $ACCOUNT_ID"
echo "Bucket Name: $BUCKET_NAME"
echo "Region     : $REGION"
echo ""

# Create S3 bucket
echo "Step 1: Creating S3 bucket..."
if [ "$REGION" == "us-east-1" ]; then
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
else
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
fi

if [ $? -eq 0 ]; then
  echo "Bucket created: s3://$BUCKET_NAME"
else
  echo "Bucket may already exist, continuing..."
fi

echo ""
echo "Step 2: Downloading datasets from DEH GitHub..."

BASE_URL="https://raw.githubusercontent.com/SachinCW/deh-pyspark-challenge/main/data"

curl -s -o /tmp/orders.csv "$BASE_URL/orders.csv"
curl -s -o /tmp/customers.csv "$BASE_URL/customers.csv"
curl -s -o /tmp/products.csv "$BASE_URL/products.csv"
curl -s -o /tmp/orders_dirty.csv "$BASE_URL/orders_dirty.csv"
curl -s -o /tmp/orders.json "$BASE_URL/orders.json"
curl -s -o /tmp/orders_dirty.json "$BASE_URL/orders_dirty.json"

echo ""
echo "Step 3: Uploading datasets to S3..."

aws s3 cp /tmp/orders.csv "s3://$BUCKET_NAME/data/orders.csv"
aws s3 cp /tmp/customers.csv "s3://$BUCKET_NAME/data/customers.csv"
aws s3 cp /tmp/products.csv "s3://$BUCKET_NAME/data/products.csv"
aws s3 cp /tmp/orders_dirty.csv "s3://$BUCKET_NAME/data/orders_dirty.csv"
aws s3 cp /tmp/orders.json "s3://$BUCKET_NAME/data/orders.json"
aws s3 cp /tmp/orders_dirty.json "s3://$BUCKET_NAME/data/orders_dirty.json"

echo ""
echo "Step 4: Verifying upload..."
aws s3 ls "s3://$BUCKET_NAME/data/"

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Your S3 bucket path: s3://$BUCKET_NAME"
echo ""
echo "Copy this bucket name — you will use it in every Colab notebook:"
echo ""
echo "  BUCKET_NAME = \"$BUCKET_NAME\""
echo ""
echo "=========================================="
