data "aws_ssoadmin_instances" "this" {}

data "aws_caller_identity" "current" {}

resource "aws_ssoadmin_permission_set" "data_scientist" {
  name             = "DataScientist"
  description      = "Permission set for Data Scientists with SageMaker and S3 access"
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "sagemaker_full_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.data_scientist.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "s3_read_only" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.data_scientist.arn
}

resource "aws_identitystore_group" "data_scientist" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  display_name      = "data-scientist@cloud-diktat.info"
  description       = "Data Scientists group from Google Workspace"
}

resource "aws_ssoadmin_account_assignment" "data_scientist_assignment" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.data_scientist.arn

  principal_id   = aws_identitystore_group.data_scientist.group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}