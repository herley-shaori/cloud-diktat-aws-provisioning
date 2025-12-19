# =============================================================================
# Outputs
# =============================================================================

output "knowledge_base_id" {
  description = "ID of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.coffee_shop.id
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.coffee_shop.arn
}

output "agent_id" {
  description = "ID of the Bedrock Agent"
  value       = aws_bedrockagent_agent.barista_assistant.id
}

output "agent_arn" {
  description = "ARN of the Bedrock Agent"
  value       = aws_bedrockagent_agent.barista_assistant.agent_arn
}

output "guardrail_id" {
  description = "ID of the Bedrock Guardrail"
  value       = aws_bedrock_guardrail.coffee_shop.guardrail_id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for knowledge base data"
  value       = aws_s3_bucket.knowledge_base.id
}

output "lambda_function_name" {
  description = "Name of the Lambda function for agent actions"
  value       = aws_lambda_function.agent_actions.function_name
}

output "test_agent_command" {
  description = "AWS CLI command to test the agent"
  value       = <<-EOT
    aws bedrock-agent-runtime invoke-agent \
      --agent-id ${aws_bedrockagent_agent.barista_assistant.id} \
      --agent-alias-id ${aws_bedrockagent_agent_alias.barista_assistant.agent_alias_id} \
      --session-id "test-session-001" \
      --input-text "What drinks do you have on the menu?" \
      --region ${var.aws_region}
  EOT
}
