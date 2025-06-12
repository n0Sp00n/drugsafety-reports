#!/bin/bash

echo "=== AWS ECS Environment Setup ==="

# Set your AWS configuration - FIXED FOR EU-NORTH-1
export AWS_REGION="eu-north-1"
export AWS_DEFAULT_REGION="eu-north-1"
export REPO_NAME="drug-safety-api"

echo "🌍 Region set to: EU-NORTH-1 (Stockholm)"
echo "All resources will be created in eu-north-1 unless global"

# Get AWS Account ID
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "❌ AWS CLI not configured or no access. Please run 'aws configure' first."
  exit 1
fi

echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"
echo "✅ AWS Region: $AWS_REGION"

# Calculate ECR variables
export ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com"
export ECR_REPO_URI="$ECR_REGISTRY/$REPO_NAME"

# Create global environment file
cat > ~/.aws-ecs-env << EOF
# AWS ECS Global Environment Variables - EU-NORTH-1
# Source this file in each script: source ~/.aws-ecs-env

export AWS_REGION="eu-north-1"
export AWS_DEFAULT_REGION="eu-north-1"
export AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"
export REPO_NAME="$REPO_NAME"

# ECR Configuration - EU-NORTH-1
export ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com"
export ECR_REPO_URI="$ECR_REGISTRY/$REPO_NAME"

echo "📍 AWS Region: eu-north-1 (Stockholm)"
echo "🔧 All resources will be created in eu-north-1"

# Function to load additional variables
load_aws_vars() {
  if [ -f ~/.aws-ecs-runtime ]; then
    source ~/.aws-ecs-runtime
  fi
}

# Function to save runtime variables
save_var() {
  local var_name=\$1
  local var_value=\$2

  # Remove existing variable if it exists
  if [ -f ~/.aws-ecs-runtime ]; then
    grep -v "^export \$var_name=" ~/.aws-ecs-runtime > ~/.aws-ecs-runtime.tmp 2>/dev/null || true
    mv ~/.aws-ecs-runtime.tmp ~/.aws-ecs-runtime 2>/dev/null || true
  fi

  # Add new variable
  echo "export \$var_name=\"\$var_value\"" >> ~/.aws-ecs-runtime
  export \$var_name="\$var_value"
}

# Auto-load runtime variables
load_aws_vars
EOF

# Add to shell profile for automatic loading
SHELL_PROFILE=""
if [ -f ~/.zshrc ]; then
  SHELL_PROFILE="~/.zshrc"
elif [ -f ~/.bashrc ]; then
  SHELL_PROFILE="~/.bashrc"
elif [ -f ~/.bash_profile ]; then
  SHELL_PROFILE="~/.bash_profile"
fi

if [ ! -z "$SHELL_PROFILE" ]; then
  # Check if already added
  if ! grep -q "source ~/.aws-ecs-env" $SHELL_PROFILE 2>/dev/null; then
    echo "" >> $SHELL_PROFILE
    echo "# AWS ECS Environment" >> $SHELL_PROFILE
    echo "[ -f ~/.aws-ecs-env ] && source ~/.aws-ecs-env" >> $SHELL_PROFILE
    echo "✅ Added to $SHELL_PROFILE"
  fi
fi

# Source the environment
source ~/.aws-ecs-env

echo ""
echo "✅ Global AWS environment setup complete!"
echo "✅ Environment file: ~/.aws-ecs-env"
echo "✅ Variables available in all new terminal sessions"
echo ""
echo "📍 REGION CONFIGURATION:"
echo "  🌍 AWS_REGION: eu-north-1 (Stockholm)"
echo "  🏗️  All resources will be created in eu-north-1"
echo "  🌐 IAM roles are global (replicated across regions)"
echo ""
echo "Current environment:"
echo "  AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"
echo "  AWS_REGION: $AWS_REGION"
echo "  REPO_NAME: $REPO_NAME"
echo "  ECR_REPO_URI: $ECR_REPO_URI"