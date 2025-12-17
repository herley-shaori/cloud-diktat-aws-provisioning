variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-3"
}

variable "organization_id" {
  description = "The ID of the existing AWS Organization"
  type        = string
}

variable "admin_email" {
  description = "Admin user email for Identity Store"
  type        = string
}
