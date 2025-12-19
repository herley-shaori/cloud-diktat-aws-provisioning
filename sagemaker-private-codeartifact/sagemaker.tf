# =============================================================================
# SageMaker Notebook Instance
# =============================================================================
# Deploys a SageMaker notebook instance in a private subnet with lifecycle
# configuration for CodeArtifact pip integration.
# =============================================================================

# -----------------------------------------------------------------------------
# Lifecycle Configuration - On Start Script
# -----------------------------------------------------------------------------
# This script runs every time the notebook instance starts. It configures
# pip to use CodeArtifact as the package repository.

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "codeartifact_pip" {
  name = "${local.name_prefix}-codeartifact-config"

  # on_start script runs every time the notebook starts
  on_start = base64encode(<<-EOF
    #!/bin/bash
    set -e

    # ==========================================================================
    # SageMaker Notebook Lifecycle Configuration
    # Configures pip to use AWS CodeArtifact repository
    # ==========================================================================

    echo "Starting CodeArtifact pip configuration..."

    # Configuration variables
    DOMAIN="${var.codeartifact_domain_name}"
    DOMAIN_OWNER="${local.account_id}"
    REGION="${local.region}"
    REPOSITORY="${var.codeartifact_internal_repo_name}"

    # Get CodeArtifact authorization token
    echo "Getting CodeArtifact authorization token..."
    CODEARTIFACT_AUTH_TOKEN=$(aws codeartifact get-authorization-token \
        --domain $DOMAIN \
        --domain-owner $DOMAIN_OWNER \
        --region $REGION \
        --query authorizationToken \
        --output text)

    # Get CodeArtifact repository endpoint
    echo "Getting CodeArtifact repository endpoint..."
    CODEARTIFACT_REPO_URL=$(aws codeartifact get-repository-endpoint \
        --domain $DOMAIN \
        --domain-owner $DOMAIN_OWNER \
        --region $REGION \
        --repository $REPOSITORY \
        --format pypi \
        --query repositoryEndpoint \
        --output text)

    # Configure pip for the ec2-user (SageMaker notebook user)
    echo "Configuring pip for ec2-user..."
    sudo -u ec2-user mkdir -p /home/ec2-user/.config/pip

    sudo -u ec2-user tee /home/ec2-user/.config/pip/pip.conf > /dev/null <<PIPCONF
    [global]
    index-url = https://aws:$CODEARTIFACT_AUTH_TOKEN@$${CODEARTIFACT_REPO_URL}simple/
    trusted-host = $${CODEARTIFACT_REPO_URL%%/*}
    PIPCONF

    # Also configure for root (some operations may run as root)
    echo "Configuring pip for root..."
    mkdir -p /root/.config/pip

    tee /root/.config/pip/pip.conf > /dev/null <<PIPCONF
    [global]
    index-url = https://aws:$CODEARTIFACT_AUTH_TOKEN@$${CODEARTIFACT_REPO_URL}simple/
    trusted-host = $${CODEARTIFACT_REPO_URL%%/*}
    PIPCONF

    # Configure pip for all conda environments
    echo "Configuring pip for conda environments..."
    for env in /home/ec2-user/anaconda3/envs/*/; do
        if [ -d "$env" ]; then
            env_name=$(basename "$env")
            echo "Configuring conda environment: $env_name"

            # Activate environment and configure pip
            source /home/ec2-user/anaconda3/bin/activate "$env_name"
            pip config set global.index-url "https://aws:$CODEARTIFACT_AUTH_TOKEN@$${CODEARTIFACT_REPO_URL}simple/"
            conda deactivate
        fi
    done

    # Create a refresh script that can be run manually to refresh the token
    echo "Creating token refresh script..."
    sudo -u ec2-user tee /home/ec2-user/refresh-codeartifact-token.sh > /dev/null <<'REFRESHSCRIPT'
    #!/bin/bash
    # Refresh CodeArtifact pip configuration
    # Run this script if pip authentication expires (tokens last 12 hours)

    DOMAIN="${var.codeartifact_domain_name}"
    DOMAIN_OWNER="${local.account_id}"
    REGION="${local.region}"
    REPOSITORY="${var.codeartifact_internal_repo_name}"

    CODEARTIFACT_AUTH_TOKEN=$(aws codeartifact get-authorization-token \
        --domain $DOMAIN \
        --domain-owner $DOMAIN_OWNER \
        --region $REGION \
        --query authorizationToken \
        --output text)

    CODEARTIFACT_REPO_URL=$(aws codeartifact get-repository-endpoint \
        --domain $DOMAIN \
        --domain-owner $DOMAIN_OWNER \
        --region $REGION \
        --repository $REPOSITORY \
        --format pypi \
        --query repositoryEndpoint \
        --output text)

    pip config set global.index-url "https://aws:$CODEARTIFACT_AUTH_TOKEN@$${CODEARTIFACT_REPO_URL}simple/"

    echo "CodeArtifact pip configuration refreshed successfully!"
    REFRESHSCRIPT

    chmod +x /home/ec2-user/refresh-codeartifact-token.sh
    chown ec2-user:ec2-user /home/ec2-user/refresh-codeartifact-token.sh

    echo "CodeArtifact pip configuration completed successfully!"
    EOF
  )

  # on_create script runs only once when the notebook is first created
  on_create = base64encode(<<-EOF
    #!/bin/bash
    set -e

    echo "SageMaker notebook instance created with CodeArtifact integration."
    echo "Domain: ${var.codeartifact_domain_name}"
    echo "Repository: ${var.codeartifact_internal_repo_name}"
    echo "Region: ${local.region}"
    EOF
  )
}

# -----------------------------------------------------------------------------
# SageMaker Notebook Instance
# -----------------------------------------------------------------------------
# The notebook instance deployed in a private subnet.

resource "aws_sagemaker_notebook_instance" "main" {
  name                   = var.sagemaker_notebook_name
  instance_type          = var.sagemaker_instance_type
  role_arn               = aws_iam_role.sagemaker_execution.arn
  volume_size            = var.sagemaker_volume_size
  subnet_id              = aws_subnet.private[0].id
  security_groups        = [aws_security_group.sagemaker.id]
  direct_internet_access = "Disabled" # No direct internet - uses VPC endpoints
  lifecycle_config_name  = aws_sagemaker_notebook_instance_lifecycle_configuration.codeartifact_pip.name

  # Root access required for lifecycle scripts
  root_access = "Enabled"

  tags = {
    Name = var.sagemaker_notebook_name
  }

  depends_on = [
    aws_vpc_endpoint.interface,
    aws_vpc_endpoint.s3,
    aws_iam_role_policy_attachment.sagemaker_full_access,
    aws_iam_role_policy_attachment.codeartifact_access,
    aws_iam_role_policy_attachment.s3_access,
    aws_iam_role_policy_attachment.cloudwatch_logs,
    aws_iam_role_policy_attachment.ecr_access
  ]
}
