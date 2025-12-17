output "organization_id" {
  description = "Identifier of the organization"
  value       = data.aws_organizations_organization.org.id
}

output "data_scientist_ou_id" {
  description = "Identifier of the Data Scientist OU"
  value       = aws_organizations_organizational_unit.data_scientist.id
}

output "data_scientist_ou_arn" {
  description = "ARN of the Data Scientist OU"
  value       = aws_organizations_organizational_unit.data_scientist.arn
}

output "sso_permission_set_arn" {
  description = "ARN of the Data Scientist SSO permission set"
  value       = aws_ssoadmin_permission_set.data_scientist.arn
}

# SageMaker Outputs
output "sagemaker_domain_id" {
  description = "ID of the SageMaker domain"
  value       = aws_sagemaker_domain.data_scientist.id
}

output "sagemaker_domain_url" {
  description = "URL of the SageMaker domain"
  value       = aws_sagemaker_domain.data_scientist.url
}

output "sagemaker_user_profile_arn" {
  description = "ARN of the SageMaker user profile for herley"
  value       = aws_sagemaker_user_profile.herley.arn
}

# VPC Outputs
output "sagemaker_vpc_id" {
  description = "ID of the SageMaker VPC"
  value       = aws_vpc.sagemaker.id
}
