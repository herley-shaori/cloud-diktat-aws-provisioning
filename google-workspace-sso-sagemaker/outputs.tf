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

output "data_scientist_user_name" {
  description = "Name of the Data Scientist IAM user"
  value       = aws_iam_user.data_scientist.name
}

output "data_scientist_user_arn" {
  description = "ARN of the Data Scientist IAM user"
  value       = aws_iam_user.data_scientist.arn
}
