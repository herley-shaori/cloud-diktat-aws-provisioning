# =============================================================================
# Outputs
# =============================================================================
# Important values exported after deployment for reference and integration.
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

# -----------------------------------------------------------------------------
# SageMaker Outputs
# -----------------------------------------------------------------------------

output "sagemaker_notebook_name" {
  description = "Name of the SageMaker notebook instance"
  value       = aws_sagemaker_notebook_instance.main.name
}

output "sagemaker_notebook_arn" {
  description = "ARN of the SageMaker notebook instance"
  value       = aws_sagemaker_notebook_instance.main.arn
}

output "sagemaker_notebook_url" {
  description = "URL to access the SageMaker notebook instance"
  value       = "https://${var.aws_region}.console.aws.amazon.com/sagemaker/home?region=${var.aws_region}#/notebook-instances/${aws_sagemaker_notebook_instance.main.name}"
}

output "sagemaker_execution_role_arn" {
  description = "ARN of the SageMaker execution IAM role"
  value       = aws_iam_role.sagemaker_execution.arn
}

# -----------------------------------------------------------------------------
# CodeArtifact Outputs
# -----------------------------------------------------------------------------

output "codeartifact_domain_name" {
  description = "Name of the CodeArtifact domain"
  value       = aws_codeartifact_domain.main.domain
}

output "codeartifact_domain_arn" {
  description = "ARN of the CodeArtifact domain"
  value       = aws_codeartifact_domain.main.arn
}

output "codeartifact_repository_name" {
  description = "Name of the internal CodeArtifact repository"
  value       = aws_codeartifact_repository.sagemaker_packages.repository
}

output "codeartifact_repository_arn" {
  description = "ARN of the internal CodeArtifact repository"
  value       = aws_codeartifact_repository.sagemaker_packages.arn
}

output "codeartifact_repository_endpoint" {
  description = "CodeArtifact repository endpoint URL for pip"
  value       = local.codeartifact_repo_endpoint
}

output "codeartifact_pip_login_command" {
  description = "AWS CLI command to configure pip to use CodeArtifact (for local development)"
  value       = <<-EOT
    aws codeartifact login --tool pip \
      --domain ${var.codeartifact_domain_name} \
      --domain-owner ${local.account_id} \
      --repository ${var.codeartifact_internal_repo_name} \
      --region ${var.aws_region}
  EOT
}

# -----------------------------------------------------------------------------
# VPC Endpoint Outputs
# -----------------------------------------------------------------------------

output "vpc_endpoint_s3_id" {
  description = "ID of the S3 VPC Gateway Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_ids" {
  description = "Map of interface VPC endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

# -----------------------------------------------------------------------------
# Security Group Outputs
# -----------------------------------------------------------------------------

output "sagemaker_security_group_id" {
  description = "ID of the SageMaker security group"
  value       = aws_security_group.sagemaker.id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = aws_security_group.vpc_endpoints.id
}

# -----------------------------------------------------------------------------
# Helpful Information
# -----------------------------------------------------------------------------

output "deployment_info" {
  description = "Summary of the deployment"
  value = {
    region               = var.aws_region
    environment          = var.environment
    project              = var.project_name
    notebook_instance    = var.sagemaker_notebook_name
    notebook_type        = var.sagemaker_instance_type
    codeartifact_domain  = var.codeartifact_domain_name
    codeartifact_repo    = var.codeartifact_internal_repo_name
    private_subnet_count = length(var.private_subnet_cidrs)
    vpc_endpoint_count   = length(local.vpc_endpoint_services) + 1 # +1 for S3 gateway
  }
}
