# =============================================================================
# Bedrock Agent
# =============================================================================

resource "aws_bedrockagent_agent" "warung_kopi" {
  agent_name                  = var.agent_name
  agent_resource_role_arn     = aws_iam_role.bedrock_agent.arn
  foundation_model            = var.foundation_model
  idle_session_ttl_in_seconds = 600

  instruction = <<-EOT
    Kamu adalah asisten warung kopi yang ramah dan helpful.
    Bantu customer melihat menu dan cek stok barang.
    Selalu gunakan tools yang tersedia untuk menjawab pertanyaan.
    Jawab dalam Bahasa Indonesia dengan ramah dan sopan.
    Jika customer bertanya tentang menu, gunakan tool getMenu.
    Jika customer bertanya tentang stok, gunakan tool getStock dengan parameter nama item.
  EOT

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Action Group
# -----------------------------------------------------------------------------

resource "aws_bedrockagent_agent_action_group" "warung_kopi" {
  agent_id          = aws_bedrockagent_agent.warung_kopi.id
  agent_version     = "DRAFT"
  action_group_name = "warung-kopi-actions"
  description       = "Actions untuk melihat menu dan cek stok warung kopi"

  action_group_executor {
    lambda = aws_lambda_function.warung_kopi.arn
  }

  api_schema {
    payload = file("${path.module}/schema/openapi.yaml")
  }
}

# -----------------------------------------------------------------------------
# Prepare Agent (required before creating alias)
# -----------------------------------------------------------------------------

resource "null_resource" "prepare_agent" {
  depends_on = [
    aws_bedrockagent_agent_action_group.warung_kopi
  ]

  triggers = {
    agent_id     = aws_bedrockagent_agent.warung_kopi.id
    action_group = aws_bedrockagent_agent_action_group.warung_kopi.action_group_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws bedrock-agent prepare-agent \
        --agent-id ${aws_bedrockagent_agent.warung_kopi.id} \
        --region ${local.region}
    EOT
  }
}

# Wait for agent to be prepared
resource "time_sleep" "wait_for_agent_preparation" {
  depends_on      = [null_resource.prepare_agent]
  create_duration = "30s"
}

# -----------------------------------------------------------------------------
# Agent Alias (required for invoking the agent)
# -----------------------------------------------------------------------------

resource "aws_bedrockagent_agent_alias" "live" {
  depends_on       = [time_sleep.wait_for_agent_preparation]
  agent_id         = aws_bedrockagent_agent.warung_kopi.id
  agent_alias_name = "live"
  description      = "Live alias for testing"

  tags = local.common_tags
}
