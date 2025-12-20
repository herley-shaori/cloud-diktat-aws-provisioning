# =============================================================================
# Bedrock Agent - Barista Assistant
# =============================================================================

resource "aws_bedrockagent_agent" "barista_assistant" {
  agent_name                  = "${local.name_prefix}-barista-assistant"
  agent_resource_role_arn     = aws_iam_role.bedrock_agent.arn
  foundation_model            = var.bedrock_model_id
  idle_session_ttl_in_seconds = 600
  description                 = "AI-powered assistant for coffee shop operations, recipes, inventory management, and customer service"

  instruction = <<-EOT
    You are a helpful Barista Assistant for A Coffee Shop. Your role is to assist baristas, managers, and staff with:

    1. MENU & RECIPES:
       - Provide detailed drink recipes including ingredients, proportions, and preparation steps
       - Suggest drink modifications and customizations
       - Explain the differences between drink types (latte vs cappuccino, etc.)
       - Provide nutritional information when available

    2. INVENTORY MANAGEMENT:
       - Check current stock levels for any branch (Sudirman, Kemang, Senayan)
       - Identify items that need reordering
       - Help create purchase orders for suppliers
       - Track supplier information and lead times

    3. OPERATIONS:
       - Answer questions about Standard Operating Procedures (SOPs)
       - Provide food safety guidelines
       - Explain equipment maintenance procedures
       - Help troubleshoot common equipment issues

    4. CUSTOMER SERVICE:
       - Answer frequently asked questions
       - Check queue lengths at different branches
       - Provide information about store hours and locations
       - Handle common customer inquiries professionally

    GUIDELINES:
    - Always be helpful, professional, and accurate
    - If you're unsure about something, say so rather than making up information
    - For inventory actions, always confirm the branch location
    - Provide step-by-step instructions when explaining procedures
    - Use the knowledge base to find accurate recipe and SOP information
    - Use the action functions to check real-time inventory and queue data

    IMPORTANT:
    - Never discuss competitor products or pricing
    - Never share internal cost information with customers
    - Protect customer privacy - don't share personal information
    - Escalate serious issues to management
  EOT

  guardrail_configuration {
    guardrail_identifier = aws_bedrock_guardrail.coffee_shop.guardrail_id
    guardrail_version    = aws_bedrock_guardrail_version.coffee_shop.version
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Agent Action Group
# -----------------------------------------------------------------------------

resource "aws_bedrockagent_agent_action_group" "inventory" {
  agent_id          = aws_bedrockagent_agent.barista_assistant.id
  agent_version     = "DRAFT"
  action_group_name = "InventoryManagement"
  description       = "Actions for managing inventory, orders, and operational data"

  action_group_executor {
    lambda = aws_lambda_function.agent_actions.arn
  }

  function_schema {
    member_functions {
      functions {
        name        = "checkStock"
        description = "Check the current stock level of an item at a specific branch. Returns quantity, unit, and whether reordering is needed."

        parameters {
          map_block_key = "branch_id"
          type          = "string"
          description   = "The branch identifier (sudirman, kemang, or senayan)"
          required      = true
        }

        parameters {
          map_block_key = "item_name"
          type          = "string"
          description   = "The item to check (e.g., milk, coffee_beans, sugar, oat_milk, cups_small). Leave empty to get all inventory."
          required      = false
        }
      }

      functions {
        name        = "createPurchaseOrder"
        description = "Create a purchase order for supplies from a specific supplier"

        parameters {
          map_block_key = "items"
          type          = "string"
          description   = "Comma-separated list of items to order (e.g., 'milk:20L, coffee_beans:5kg')"
          required      = true
        }

        parameters {
          map_block_key = "supplier_id"
          type          = "string"
          description   = "Supplier ID (SUP001=Coffee Beans, SUP002=Dairy, SUP003=Syrups, SUP004=Packaging)"
          required      = true
        }

        parameters {
          map_block_key = "branch_id"
          type          = "string"
          description   = "The branch to deliver to (sudirman, kemang, or senayan)"
          required      = true
        }
      }

      functions {
        name        = "getQueueLength"
        description = "Get the current queue length and estimated wait time at a branch"

        parameters {
          map_block_key = "branch_id"
          type          = "string"
          description   = "The branch identifier (sudirman, kemang, or senayan)"
          required      = true
        }
      }

      functions {
        name        = "getSupplierInfo"
        description = "Get information about suppliers including contact details and items they supply"

        parameters {
          map_block_key = "supplier_id"
          type          = "string"
          description   = "Supplier ID (optional - leave empty to list all suppliers)"
          required      = false
        }
      }
    }
  }

  depends_on = [aws_lambda_permission.bedrock_invoke]
}

# -----------------------------------------------------------------------------
# Agent Knowledge Base Association
# -----------------------------------------------------------------------------

resource "aws_bedrockagent_agent_knowledge_base_association" "coffee_shop" {
  agent_id             = aws_bedrockagent_agent.barista_assistant.id
  agent_version        = "DRAFT"
  knowledge_base_id    = aws_bedrockagent_knowledge_base.coffee_shop.id
  description          = "Coffee shop recipes, SOPs, FAQ, and operational guides"
  knowledge_base_state = "ENABLED"
}

# -----------------------------------------------------------------------------
# Prepare and Create Agent Alias
# -----------------------------------------------------------------------------

# Prepare the agent (required before creating alias)
resource "null_resource" "prepare_agent" {
  depends_on = [
    aws_bedrockagent_agent_action_group.inventory,
    aws_bedrockagent_agent_knowledge_base_association.coffee_shop
  ]

  triggers = {
    agent_id = aws_bedrockagent_agent.barista_assistant.id
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "aws bedrock-agent prepare-agent --agent-id ${aws_bedrockagent_agent.barista_assistant.id} --region ${local.region} --profile pribadi; Write-Host 'Waiting for agent to be prepared...'; Start-Sleep -Seconds 30"
  }
}

resource "aws_bedrockagent_agent_alias" "barista_assistant" {
  agent_id         = aws_bedrockagent_agent.barista_assistant.id
  agent_alias_name = "production"
  description      = "Production alias for Barista Assistant"

  depends_on = [null_resource.prepare_agent]

  tags = local.common_tags
}
