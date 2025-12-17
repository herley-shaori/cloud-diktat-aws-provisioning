data "aws_ssoadmin_instances" "this" {}

data "aws_caller_identity" "current" {}

resource "aws_ssoadmin_permission_set" "data_scientist" {
  name             = "DataScientist"
  description      = "Permission set for Data Scientists with SageMaker and S3 access"
  instance_arn     = data.aws_ssoadmin_instances.this.arns[0]
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "sagemaker_full_access" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.data_scientist.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_ssoadmin_managed_policy_attachment" "s3_read_only" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.data_scientist.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_identitystore_user" "data_scientist" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]

  user_name    = "data-scientist@cloud-diktat.info"
  display_name = "Data Scientist"

  name {
    given_name  = "Data"
    family_name = "Scientist"
  }

  emails {
    value   = "data-scientist@cloud-diktat.info"
    primary = true
  }
}

resource "aws_identitystore_group" "data_scientist" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  display_name      = "DataScientists"
  description       = "Data Scientists group"
}

resource "aws_identitystore_group_membership" "data_scientist" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  group_id          = aws_identitystore_group.data_scientist.group_id
  member_id         = aws_identitystore_user.data_scientist.user_id
}

resource "aws_ssoadmin_account_assignment" "data_scientist_assignment" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.data_scientist.arn

  principal_id   = aws_identitystore_group.data_scientist.group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}

# Look up Herley user from Google Workspace SCIM provisioning
data "aws_identitystore_user" "herley" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = "herley@cloud-diktat.info"
    }
  }
}

# Add Herley to DataScientists group
resource "aws_identitystore_group_membership" "herley" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  group_id          = aws_identitystore_group.data_scientist.group_id
  member_id         = data.aws_identitystore_user.herley.user_id
}