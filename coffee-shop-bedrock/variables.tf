# =============================================================================
# Input Variables
# =============================================================================

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "coffee-shop-ai"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "bedrock_model_id" {
  description = "Bedrock foundation model ID for the agent"
  type        = string
  default     = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "embedding_model_id" {
  description = "Bedrock embedding model ID for knowledge base"
  type        = string
  default     = "amazon.titan-embed-text-v2:0"
}

variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "python3.11"
}
