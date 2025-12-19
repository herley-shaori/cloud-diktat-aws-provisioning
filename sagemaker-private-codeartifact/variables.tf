# =============================================================================
# Input Variables
# =============================================================================
# All configurable parameters for the SageMaker + CodeArtifact infrastructure.
# =============================================================================

# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for deploying resources. Singapore region for Southeast Asia."
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name used for tagging and resource naming (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for tagging and resource naming."
  type        = string
  default     = "ml-platform"
}

# -----------------------------------------------------------------------------
# VPC Configuration
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be large enough to accommodate all subnets."
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets. Each subnet will be in a different AZ."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for subnet placement. Must match the number of subnet CIDRs."
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

# -----------------------------------------------------------------------------
# CodeArtifact Configuration
# -----------------------------------------------------------------------------

variable "codeartifact_domain_name" {
  description = "Name of the CodeArtifact domain. Must be unique within the AWS account."
  type        = string
  default     = "mlplatform"
}

variable "codeartifact_upstream_repo_name" {
  description = "Name of the upstream repository that connects to public PyPI."
  type        = string
  default     = "pypi-store"
}

variable "codeartifact_internal_repo_name" {
  description = "Name of the internal repository for SageMaker packages."
  type        = string
  default     = "sagemaker-packages"
}

# -----------------------------------------------------------------------------
# SageMaker Configuration
# -----------------------------------------------------------------------------

variable "sagemaker_notebook_name" {
  description = "Name of the SageMaker notebook instance."
  type        = string
  default     = "ml-notebook-private"
}

variable "sagemaker_instance_type" {
  description = "Instance type for the SageMaker notebook. ml.t3.medium is cost-effective for development."
  type        = string
  default     = "ml.t3.medium"
}

variable "sagemaker_volume_size" {
  description = "Size of the EBS volume attached to the notebook instance in GB."
  type        = number
  default     = 50
}
