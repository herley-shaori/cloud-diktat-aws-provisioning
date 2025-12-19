# =============================================================================
# IAM Roles and Policies
# =============================================================================
# IAM configuration for SageMaker notebook instance with permissions for
# SageMaker operations, CodeArtifact access, S3, and CloudWatch logging.
# =============================================================================

# -----------------------------------------------------------------------------
# SageMaker Execution Role
# -----------------------------------------------------------------------------
# This role is assumed by the SageMaker notebook instance.

resource "aws_iam_role" "sagemaker_execution" {
  name = "${local.name_prefix}-sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-sagemaker-execution-role"
  }
}

# -----------------------------------------------------------------------------
# SageMaker Full Access Policy Attachment
# -----------------------------------------------------------------------------
# Provides full access to SageMaker services for ML workflows.

resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# -----------------------------------------------------------------------------
# CodeArtifact Access Policy
# -----------------------------------------------------------------------------
# Custom policy for CodeArtifact read access to download packages.

resource "aws_iam_policy" "codeartifact_access" {
  name        = "${local.name_prefix}-codeartifact-access"
  description = "Policy for CodeArtifact read access from SageMaker"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CodeArtifactGetAuthorizationToken"
        Effect = "Allow"
        Action = [
          "codeartifact:GetAuthorizationToken"
        ]
        Resource = aws_codeartifact_domain.main.arn
      },
      {
        Sid    = "CodeArtifactReadRepository"
        Effect = "Allow"
        Action = [
          "codeartifact:ReadFromRepository",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:DescribeRepository",
          "codeartifact:ListPackages",
          "codeartifact:ListPackageVersions",
          "codeartifact:GetPackageVersionReadme"
        ]
        Resource = [
          aws_codeartifact_repository.sagemaker_packages.arn,
          aws_codeartifact_repository.pypi_store.arn
        ]
      },
      {
        Sid    = "STSGetServiceBearerToken"
        Effect = "Allow"
        Action = [
          "sts:GetServiceBearerToken"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "sts:AWSServiceName" = "codeartifact.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-codeartifact-access"
  }
}

resource "aws_iam_role_policy_attachment" "codeartifact_access" {
  role       = aws_iam_role.sagemaker_execution.name
  policy_arn = aws_iam_policy.codeartifact_access.arn
}

# -----------------------------------------------------------------------------
# S3 Access Policy
# -----------------------------------------------------------------------------
# Provides access to S3 for storing notebooks, datasets, and model artifacts.

resource "aws_iam_policy" "s3_access" {
  name        = "${local.name_prefix}-s3-access"
  description = "Policy for S3 access from SageMaker"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3FullAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::*"
        ]
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-s3-access"
  }
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.sagemaker_execution.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# -----------------------------------------------------------------------------
# CloudWatch Logs Policy
# -----------------------------------------------------------------------------
# Allows SageMaker to write logs to CloudWatch.

resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "${local.name_prefix}-cloudwatch-logs"
  description = "Policy for CloudWatch Logs access from SageMaker"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/sagemaker/*"
        ]
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-cloudwatch-logs"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.sagemaker_execution.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# -----------------------------------------------------------------------------
# ECR Access Policy
# -----------------------------------------------------------------------------
# Allows pulling container images from ECR (required for SageMaker kernels).

resource "aws_iam_policy" "ecr_access" {
  name        = "${local.name_prefix}-ecr-access"
  description = "Policy for ECR read access from SageMaker"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRReadAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-ecr-access"
  }
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.sagemaker_execution.name
  policy_arn = aws_iam_policy.ecr_access.arn
}
