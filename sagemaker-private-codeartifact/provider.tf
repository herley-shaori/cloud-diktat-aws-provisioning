provider "aws" {
  region  = "ap-southeast-1"
  profile = "pribadi"
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}