# =============================================================================
# Local Values
# =============================================================================
# Computed values and common configurations used across multiple resources.
# =============================================================================

# Data sources for dynamic values
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Account and region information
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # Naming prefix for resources
  name_prefix = "${var.project_name}-${var.environment}"

  # Common tags applied to all resources (in addition to default_tags)
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }

  # VPC Endpoint services required for private SageMaker + CodeArtifact
  vpc_endpoint_services = {
    # CodeArtifact endpoints
    codeartifact_api = {
      service_name = "com.amazonaws.${local.region}.codeartifact.api"
      type         = "Interface"
    }
    codeartifact_repositories = {
      service_name = "com.amazonaws.${local.region}.codeartifact.repositories"
      type         = "Interface"
    }
    # STS for CodeArtifact authentication
    sts = {
      service_name = "com.amazonaws.${local.region}.sts"
      type         = "Interface"
    }
    # SageMaker endpoints
    sagemaker_api = {
      service_name = "com.amazonaws.${local.region}.sagemaker.api"
      type         = "Interface"
    }
    sagemaker_runtime = {
      service_name = "com.amazonaws.${local.region}.sagemaker.runtime"
      type         = "Interface"
    }
    sagemaker_notebook = {
      service_name = "com.amazonaws.${local.region}.notebook"
      type         = "Interface"
    }
    # CloudWatch for logging
    logs = {
      service_name = "com.amazonaws.${local.region}.logs"
      type         = "Interface"
    }
    # ECR for container images (required for SageMaker kernels)
    ecr_api = {
      service_name = "com.amazonaws.${local.region}.ecr.api"
      type         = "Interface"
    }
    ecr_dkr = {
      service_name = "com.amazonaws.${local.region}.ecr.dkr"
      type         = "Interface"
    }
  }

  # Gateway endpoints (S3 uses gateway type for better performance and no cost)
  gateway_endpoints = {
    s3 = {
      service_name = "com.amazonaws.${local.region}.s3"
      type         = "Gateway"
    }
  }

  # CodeArtifact repository URL format
  codeartifact_repo_endpoint = "https://${var.codeartifact_domain_name}-${local.account_id}.d.codeartifact.${local.region}.amazonaws.com/pypi/${var.codeartifact_internal_repo_name}/simple/"
}
