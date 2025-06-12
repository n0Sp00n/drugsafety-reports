#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 5: Create ECS Cluster ==="

# Check if cluster exists and get its status
CLUSTER_STATUS=$(aws ecs describe-clusters --clusters drug-safety-cluster --query 'clusters[0].status' --output text --region eu-north-1 2>/dev/null)

echo "Current cluster status: $CLUSTER_STATUS"

if [ "$CLUSTER_STATUS" = "ACTIVE" ]; then
  echo "✅ Active cluster already exists: drug-safety-cluster"
elif [ "$CLUSTER_STATUS" = "INACTIVE" ]; then
  echo "Found INACTIVE cluster, deleting and recreating..."
  aws ecs delete-cluster --cluster drug-safety-cluster --region eu-north-1
  sleep 5

  echo "Creating new ECS cluster..."
  aws ecs create-cluster --cluster-name drug-safety-cluster --region eu-north-1

  if [ $? -eq 0 ]; then
    echo "✅ Cluster created: drug-safety-cluster"
  else
    echo "❌ Failed to create cluster"
    exit 1
  fi
elif [ "$CLUSTER_STATUS" = "None" ] || [ -z "$CLUSTER_STATUS" ]; then
  echo "No cluster found, creating new one..."
  aws ecs create-cluster --cluster-name drug-safety-cluster --region eu-north-1

  if [ $? -eq 0 ]; then
    echo "✅ Cluster created: drug-safety-cluster"
  else
    echo "❌ Failed to create cluster"
    exit 1
  fi
else
  echo "Unknown cluster status: $CLUSTER_STATUS"
  echo "Attempting to create cluster anyway..."
  aws ecs create-cluster --cluster-name drug-safety-cluster --region eu-north-1
fi

# Verify final cluster status
FINAL_STATUS=$(aws ecs describe-clusters --clusters drug-safety-cluster --query 'clusters[0].status' --output text --region eu-north-1)
echo "Final cluster status: $FINAL_STATUS"

save_var "CLUSTER_NAME" "drug-safety-cluster"