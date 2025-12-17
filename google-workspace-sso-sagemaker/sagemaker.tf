# IAM Role for SageMaker Execution
resource "aws_iam_role" "sagemaker_execution" {
  name = "sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "sagemaker-execution-role"
  }
}

# Attach SageMaker Full Access policy to execution role
resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Attach S3 Read Only policy to execution role
resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.sagemaker_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# SageMaker Domain (VpcOnly mode for private access)
resource "aws_sagemaker_domain" "data_scientist" {
  domain_name = "data-scientist-sagemaker-domain"
  auth_mode   = "SSO"
  vpc_id      = aws_vpc.sagemaker.id
  subnet_ids  = aws_subnet.private[*].id

  default_user_settings {
    execution_role  = aws_iam_role.sagemaker_execution.arn
    security_groups = [aws_security_group.sagemaker.id]
  }

  domain_settings {
    security_group_ids = [aws_security_group.sagemaker.id]
  }

  # VpcOnly mode - private mode without internet access
  app_network_access_type = "VpcOnly"

  tags = {
    Name = "Data Scientist SageMaker domain"
  }

  depends_on = [
    aws_vpc_endpoint.s3,
    aws_vpc_endpoint.sagemaker_api,
    aws_vpc_endpoint.sagemaker_runtime,
    aws_vpc_endpoint.sagemaker_studio,
    aws_vpc_endpoint.sts,
    aws_vpc_endpoint.logs,
    aws_vpc_endpoint.ecr_api,
    aws_vpc_endpoint.ecr_dkr
  ]
}

# SageMaker User Profile for herley@cloud-diktat.info
# This profile is linked to the SSO user so only herley@cloud-diktat.info can claim it
resource "aws_sagemaker_user_profile" "herley" {
  domain_id         = aws_sagemaker_domain.data_scientist.id
  user_profile_name = "herley-cloud-diktat"

  single_sign_on_user_identifier = "UserName"
  single_sign_on_user_value      = "herley@cloud-diktat.info"

  user_settings {
    execution_role  = aws_iam_role.sagemaker_execution.arn
    security_groups = [aws_security_group.sagemaker.id]
  }

  tags = {
    Name  = "herley-sagemaker-profile"
    Email = "herley@cloud-diktat.info"
  }
}
