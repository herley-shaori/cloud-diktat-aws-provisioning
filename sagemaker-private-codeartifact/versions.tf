# =============================================================================
# Terraform Version and Required Providers
# =============================================================================
# This file defines the required Terraform version and provider versions.
# Provider configuration is in provider.tf
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
