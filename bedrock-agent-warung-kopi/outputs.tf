# =============================================================================
# Outputs
# =============================================================================

output "agent_id" {
  description = "Bedrock Agent ID"
  value       = aws_bedrockagent_agent.warung_kopi.id
}

output "agent_arn" {
  description = "Bedrock Agent ARN"
  value       = aws_bedrockagent_agent.warung_kopi.agent_arn
}

output "agent_alias_id" {
  description = "Bedrock Agent Alias ID for invoking"
  value       = aws_bedrockagent_agent_alias.live.agent_alias_id
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.warung_kopi.function_name
}

# =============================================================================
# Testing Commands
# =============================================================================

output "test_command_menu" {
  description = "AWS CLI command to test the agent - ask for menu"
  value       = <<-EOT

    # Test: Tanya menu
    aws bedrock-agent-runtime invoke-agent \
      --agent-id ${aws_bedrockagent_agent.warung_kopi.id} \
      --agent-alias-id ${aws_bedrockagent_agent_alias.live.agent_alias_id} \
      --session-id test-session-001 \
      --input-text "Apa saja menu yang tersedia?" \
      --region ${local.region} \
      output.txt

    cat output.txt

  EOT
}

output "test_command_stock" {
  description = "AWS CLI command to test the agent - check stock"
  value       = <<-EOT

    # Test: Cek stok
    aws bedrock-agent-runtime invoke-agent \
      --agent-id ${aws_bedrockagent_agent.warung_kopi.id} \
      --agent-alias-id ${aws_bedrockagent_agent_alias.live.agent_alias_id} \
      --session-id test-session-002 \
      --input-text "Apakah Kopi Susu masih ada stoknya?" \
      --region ${local.region} \
      output.txt

    cat output.txt

  EOT
}
