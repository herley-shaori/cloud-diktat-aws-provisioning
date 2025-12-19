# =============================================================================
# Coffee Shop AI Management System - Main Configuration
# =============================================================================
# AI-powered coffee shop assistant using Amazon Bedrock services
# Region: ap-southeast-1 (Singapore)
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# =============================================================================
# Data Sources
# =============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# =============================================================================
# Local Values
# =============================================================================

locals {
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.name
  name_prefix = var.project_prefix

  common_tags = {
    Project     = "Coffee Shop AI"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
