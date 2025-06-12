#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 10: Create ECS Service ==="
echo "Cluster: $CLUSTER_NAME"
echo "Task Definition: drug-safety-api"
echo "Target Group: $TARGET_GROUP_ARN"

# Check if service exists
EXISTING_SERVICE=$(aws ecs describe-services --cluster $CLUSTER_NAME --services drug-safety-service --query 'services[0].serviceName' --output text --region $AWS_REGION 2>/dev/null)

if [ "$EXISTING_SERVICE" = "drug-safety-service" ]; then
  echo "✅ Service already exists: drug-safety-service"
else
  echo "Creating ECS service..."
  aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name drug-safety-service \
    --task-definition drug-safety-api \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_1,$SUBNET_2],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}" \
    --load-balancers "targetGroupArn=$TARGET_GROUP_ARN,containerName=drug-safety-api,containerPort=8080" \
    --region $AWS_REGION

  if [ $? -eq 0 ]; then
    echo "✅ ECS service created successfully!"
  else
    echo "❌ Failed to create ECS service"
    exit 1
  fi
fi

save_var "SERVICE_NAME" "drug-safety-service"

echo ""
echo "🎉 Deployment complete!"
echo "API URL: http://$ALB_DNS"
echo "Swagger UI: http://$ALB_DNS/swagger-ui.html"
echo "Health Check: http://$ALB_DNS/actuator/health"