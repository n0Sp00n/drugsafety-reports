#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 4: Register Task Definition ==="
echo "Using image: $ECR_IMAGE_URI"
echo "Using role: $EXECUTION_ROLE_ARN"

# Create task definition JSON
cat > task-definition.json << EOF
{
  "family": "drug-safety-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "$EXECUTION_ROLE_ARN",
  "containerDefinitions": [
    {
      "name": "drug-safety-api",
      "image": "$ECR_IMAGE_URI",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/drug-safety-api",
          "awslogs-region": "$AWS_REGION",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "environment": [
        {
          "name": "SPRING_PROFILES_ACTIVE",
          "value": "prod"
        }
      ]
    }
  ]
}
EOF

# Register task definition
echo "Registering task definition..."
TASK_DEF_ARN=$(aws ecs register-task-definition --cli-input-json file://task-definition.json --query 'taskDefinition.taskDefinitionArn' --output text)

if [ "$TASK_DEF_ARN" != "None" ] && [ ! -z "$TASK_DEF_ARN" ]; then
  echo "✅ Task definition registered: $TASK_DEF_ARN"
  save_var "TASK_DEFINITION_ARN" "$TASK_DEF_ARN"

  # Clean up
  rm task-definition.json
else
  echo "❌ Failed to register task definition"
  exit 1
fi
