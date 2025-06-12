#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 2: Create IAM Role ==="

# Check if role already exists
EXISTING_ROLE=$(aws iam get-role --role-name ecsTaskExecutionRole --query 'Role.Arn' --output text 2>/dev/null)

if [ "$EXISTING_ROLE" != "None" ] && [ ! -z "$EXISTING_ROLE" ]; then
  echo "✅ Role already exists: $EXISTING_ROLE"
  save_var "EXECUTION_ROLE_ARN" "$EXISTING_ROLE"
else
  echo "Creating IAM role..."

  # Create task execution role
  aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

  # Attach policy to role
  aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

  # Wait for role to propagate
  echo "Waiting for IAM role to propagate..."
  sleep 10

  # Get role ARN
  ROLE_ARN=$(aws iam get-role --role-name ecsTaskExecutionRole --query 'Role.Arn' --output text)

  if [ "$ROLE_ARN" != "None" ] && [ ! -z "$ROLE_ARN" ]; then
    echo "✅ Role created: $ROLE_ARN"
    save_var "EXECUTION_ROLE_ARN" "$ROLE_ARN"
  else
    echo "❌ Failed to create role"
    exit 1
  fi
fi
