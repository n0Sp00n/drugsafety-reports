#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 1: Create ECR Repository and Push Image ==="
echo "Account: $AWS_ACCOUNT_ID"
echo "Region: $AWS_REGION"
echo "Repository: $REPO_NAME"

# Verify required variables
if [ -z "$AWS_ACCOUNT_ID" ] || [ -z "$AWS_REGION" ] || [ -z "$REPO_NAME" ]; then
  echo "❌ Required variables not set. Please run ./00-setup-aws-env.sh first"
  echo "AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"
  echo "AWS_REGION: $AWS_REGION"
  echo "REPO_NAME: $REPO_NAME"
  exit 1
fi

# Set ECR variables explicitly
export ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com"
export ECR_REPO_URI="$ECR_REGISTRY/$REPO_NAME"

echo "ECR Registry: $ECR_REGISTRY"
echo "ECR Repo URI: $ECR_REPO_URI"

# Check if JAR exists
if [ ! -f "target/drug-safety-api-0.0.1-SNAPSHOT.jar" ]; then
  echo "❌ JAR file not found. Building..."
  mvn clean package -DskipTests

  if [ ! -f "target/drug-safety-api-0.0.1-SNAPSHOT.jar" ]; then
    echo "❌ Failed to build JAR file"
    exit 1
  fi
fi

# Create ECR repository (ignore error if exists)
echo "Creating ECR repository in eu-north-1..."
aws ecr create-repository --repository-name $REPO_NAME --region eu-north-1 2>/dev/null || echo "ℹ️  Repository may already exist in eu-north-1"

# Get ECR login token for eu-north-1
echo "Logging into ECR in eu-north-1..."
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin $ECR_REGISTRY

if [ $? -ne 0 ]; then
  echo "❌ Failed to login to ECR"
  exit 1
fi

# Build Docker image for x86_64 (AWS Fargate compatibility)
echo "Building Docker image for linux/amd64 platform..."
docker build --platform linux/amd64 -t $REPO_NAME .

if [ $? -ne 0 ]; then
  echo "❌ Failed to build Docker image"
  exit 1
fi

# Tag image for ECR
echo "Tagging image..."
echo "Source: $REPO_NAME:latest"
echo "Target: $ECR_REPO_URI:latest"
docker tag $REPO_NAME:latest $ECR_REPO_URI:latest

if [ $? -ne 0 ]; then
  echo "❌ Failed to tag image"
  exit 1
fi

# Push image to ECR
echo "Pushing image to ECR..."
docker push $ECR_REPO_URI:latest

if [ $? -eq 0 ]; then
  echo "✅ Image pushed successfully to: $ECR_REPO_URI:latest (eu-north-1)"
  save_var "ECR_IMAGE_URI" "$ECR_REPO_URI:latest"
  save_var "ECR_REGISTRY" "$ECR_REGISTRY"
  save_var "ECR_REPO_URI" "$ECR_REPO_URI"
else
  echo "❌ Failed to push image"
  exit 1
fi
