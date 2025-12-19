variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "bedrock-agent-hello-world"
}

variable "agent_name" {
  description = "Bedrock agent name"
  type        = string
  default     = "warung-kopi-agent"
}

variable "foundation_model" {
  description = "Bedrock foundation model ID"
  type        = string
  default     = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}
