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
