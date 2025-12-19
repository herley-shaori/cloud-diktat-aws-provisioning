# =============================================================================
# Bedrock Agent Hello World - Warung Kopi
# =============================================================================
# Simple Bedrock Agent for a coffee shop that can view menu and check stock
# =============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  common_tags = {
    Project = var.project_name
  }
}
