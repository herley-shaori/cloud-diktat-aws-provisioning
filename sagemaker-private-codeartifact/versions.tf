# =============================================================================
# Terraform and Provider Configuration
# =============================================================================
# This file defines the required Terraform version and AWS provider settings
# for deploying SageMaker with CodeArtifact integration in Jakarta region.
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}
