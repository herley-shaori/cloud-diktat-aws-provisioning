data "aws_ssoadmin_instances" "this" {}

resource "aws_ssoadmin_permission_set" "data_scientist" {
  name             = "DataScientist"
  description      = "Read-only access for Data Scientists from Google Workspace SSO"
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "data_scientist_readonly" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.data_scientist.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_ssoadmin_permission_set_inline_policy" "data_scientist_sagemaker" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.data_scientist.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SageMakerDomainAccess"
        Effect = "Allow"
        Action = [
          "sagemaker:ListDomains",
          "sagemaker:DescribeDomain",
          "sagemaker:ListApps",
          "sagemaker:DescribeApp",
          "sagemaker:ListUserProfiles",
          "sagemaker:DescribeUserProfile",
          "sagemaker:CreatePresignedDomainUrl",
          "sagemaker:ListSpaces",
          "sagemaker:DescribeSpace"
        ]
        Resource = "*"
      }
    ]
  })
}

data "aws_identitystore_group" "data_scientist" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "data-scientist@cloud-diktat.info"
    }
  }
}

resource "aws_ssoadmin_account_assignment" "data_scientist" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.data_scientist.arn

  principal_id   = data.aws_identitystore_group.data_scientist.group_id
  principal_type = "GROUP"

  target_id   = data.aws_organizations_organization.org.master_account_id
  target_type = "AWS_ACCOUNT"
}
