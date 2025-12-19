# =============================================================================
# AWS CodeArtifact Configuration
# =============================================================================
# CodeArtifact provides a secure, managed artifact repository that caches
# packages from public registries like PyPI. This enables pip installations
# in private subnets without internet access.
# =============================================================================

# -----------------------------------------------------------------------------
# CodeArtifact Domain
# -----------------------------------------------------------------------------
# A domain is a container for repositories. All repositories in a domain
# share the same underlying storage.

resource "aws_codeartifact_domain" "main" {
  domain = var.codeartifact_domain_name

  tags = {
    Name = "${local.name_prefix}-codeartifact-domain"
  }
}

# -----------------------------------------------------------------------------
# Upstream Repository (PyPI Store)
# -----------------------------------------------------------------------------
# This repository connects to public PyPI and caches downloaded packages.
# It acts as a proxy/cache for external packages.

resource "aws_codeartifact_repository" "pypi_store" {
  repository = var.codeartifact_upstream_repo_name
  domain     = aws_codeartifact_domain.main.domain

  description = "Upstream repository connected to public PyPI for caching packages"

  external_connections {
    external_connection_name = "public:pypi"
  }

  tags = {
    Name = "${local.name_prefix}-pypi-store"
    Type = "upstream"
  }
}

# -----------------------------------------------------------------------------
# Internal Repository (SageMaker Packages)
# -----------------------------------------------------------------------------
# This is the main repository that SageMaker notebooks will use.
# It inherits packages from the upstream pypi-store repository.

resource "aws_codeartifact_repository" "sagemaker_packages" {
  repository = var.codeartifact_internal_repo_name
  domain     = aws_codeartifact_domain.main.domain

  description = "Internal repository for SageMaker packages with upstream to PyPI store"

  upstream {
    repository_name = aws_codeartifact_repository.pypi_store.repository
  }

  tags = {
    Name = "${local.name_prefix}-sagemaker-packages"
    Type = "internal"
  }
}

# -----------------------------------------------------------------------------
# Domain Policy (Optional)
# -----------------------------------------------------------------------------
# Controls who can access the CodeArtifact domain.
# Currently allows the account to perform all actions.

resource "aws_codeartifact_domain_permissions_policy" "main" {
  domain = aws_codeartifact_domain.main.domain

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "codeartifact:*"
        Resource = "*"
      }
    ]
  })
}
