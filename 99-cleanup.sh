#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Cleanup AWS Resources ==="
echo "This will delete all created resources. Are you sure? (yes/no)"
read -r response

if [ "$response" != "yes" ]; then
  echo "Cleanup cancelled"
  exit 0
fi

echo "Deleting resources..."

# Delete ECS service (force stop first)
echo "1. Deleting ECS service..."
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --desired-count 0 --region eu-north-1 2>/dev/null
sleep 10
aws ecs delete-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --force --region eu-north-1 2>/dev/null

# Wait for service deletion
echo "Waiting for service deletion..."
sleep 20

# Delete ECS cluster (retry if needed)
echo "2. Deleting ECS cluster..."
aws ecs delete-cluster --cluster $CLUSTER_NAME --region eu-north-1 2>/dev/null
sleep 5

# If cluster still exists, try deleting with full ARN
CLUSTER_STATUS=$(aws ecs describe-clusters --clusters $CLUSTER_NAME --query 'clusters[0].status' --output text --region eu-north-1 2>/dev/null)
if [ "$CLUSTER_STATUS" = "INACTIVE" ] || [ "$CLUSTER_STATUS" = "ACTIVE" ]; then
  echo "Cluster still exists, trying with full ARN..."
  CLUSTER_ARN=$(aws ecs describe-clusters --clusters $CLUSTER_NAME --query 'clusters[0].clusterArn' --output text --region eu-north-1 2>/dev/null)
  aws ecs delete-cluster --cluster "$CLUSTER_ARN" --region eu-north-1 2>/dev/null
  sleep 5

  # Final check and manual instruction if needed
  CLUSTER_STATUS=$(aws ecs describe-clusters --clusters $CLUSTER_NAME --query 'clusters[0].status' --output text --region eu-north-1 2>/dev/null)
  if [ "$CLUSTER_STATUS" = "INACTIVE" ]; then
    echo "⚠️  Cluster is INACTIVE but may still show in AWS. This is normal AWS behavior."
    echo "   If needed, manually delete via AWS Console: https://eu-north-1.console.aws.amazon.com/ecs/v2/clusters"
    echo "   INACTIVE clusters with 0 resources don't incur charges."
  fi
fi

# Clean up task definitions (optional)
echo "3. Deregistering task definitions..."
TASK_DEFS=$(aws ecs list-task-definitions --family-prefix drug-safety-api --status ACTIVE --query 'taskDefinitionArns[]' --output text --region eu-north-1 2>/dev/null)
if [ ! -z "$TASK_DEFS" ]; then
  for task_def in $TASK_DEFS; do
    aws ecs deregister-task-definition --task-definition $task_def --region eu-north-1 2>/dev/null
  done
  echo "Task definitions deregistered"
else
  echo "No active task definitions found"
fi

# Delete ALB and target group
echo "4. Deleting load balancer resources..."
aws elbv2 delete-listener --listener-arn $LISTENER_ARN --region eu-north-1 2>/dev/null
sleep 5
aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN --region eu-north-1 2>/dev/null
sleep 10
aws elbv2 delete-target-group --target-group-arn $TARGET_GROUP_ARN --region eu-north-1 2>/dev/null

# Delete security group (wait for dependencies to clear)
echo "5. Waiting for dependencies to clear..."
sleep 60
aws ec2 delete-security-group --group-id $SECURITY_GROUP_ID --region eu-north-1 2>/dev/null

# Retry security group deletion if it failed
for i in {1..3}; do
  if aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID --region eu-north-1 >/dev/null 2>&1; then
    echo "Retrying security group deletion (attempt $i)..."
    sleep 30
    aws ec2 delete-security-group --group-id $SECURITY_GROUP_ID --region eu-north-1 2>/dev/null
  else
    break
  fi
done

# Delete ECR repository
echo "6. Deleting ECR repository..."
aws ecr delete-repository --repository-name $REPO_NAME --force --region eu-north-1 2>/dev/null

# Delete log group
echo "7. Deleting log group..."
aws logs delete-log-group --log-group-name $LOG_GROUP_NAME --region eu-north-1 2>/dev/null

# Clean up environment files
echo "8. Cleaning up environment files..."
rm -f ~/.aws-ecs-runtime

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Verifying cleanup:"
echo "- ECS Clusters: $(aws ecs list-clusters --region eu-north-1 --query 'length(clusterArns)' --output text)"
echo "- Load Balancers: $(aws elbv2 describe-load-balancers --region eu-north-1 --query 'length(LoadBalancers)' --output text 2>/dev/null || echo "0")"
echo "- ECR Repositories: $(aws ecr describe-repositories --region eu-north-1 --query 'length(repositories)' --output text 2>/dev/null || echo "0")"
echo "- Active Task Definitions: $(aws ecs list-task-definitions --family-prefix drug-safety-api --status ACTIVE --region eu-north-1 --query 'length(taskDefinitionArns)' --output text 2>/dev/null || echo "0")"
echo ""
echo "ℹ️  Note: If an INACTIVE cluster still appears when queried directly, this is normal AWS behavior."
echo "   INACTIVE clusters with 0 resources don't incur charges and can be ignored."