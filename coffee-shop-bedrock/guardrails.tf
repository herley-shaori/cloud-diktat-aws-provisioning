# =============================================================================
# Bedrock Guardrails
# =============================================================================
# Content filtering, PII protection, and topic restrictions for the AI assistant
# =============================================================================

resource "aws_bedrock_guardrail" "coffee_shop" {
  name                      = "${local.name_prefix}-guardrail"
  description               = "Guardrails for Coffee Shop AI to ensure safe and appropriate responses"
  blocked_input_messaging   = "I'm sorry, but I can't process that request. Please rephrase your question about our coffee shop services."
  blocked_outputs_messaging = "I apologize, but I'm unable to provide that information. Is there something else about our coffee shop I can help you with?"

  # Content filters for harmful content
  content_policy_config {
    filters_config {
      type            = "HATE"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }

    filters_config {
      type            = "INSULTS"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }

    filters_config {
      type            = "SEXUAL"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }

    filters_config {
      type            = "VIOLENCE"
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
    }

    filters_config {
      type            = "MISCONDUCT"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }

    filters_config {
      type            = "PROMPT_ATTACK"
      input_strength  = "HIGH"
      output_strength = "NONE"
    }
  }

  # Topic restrictions - deny competitor and sensitive business topics
  topic_policy_config {
    topics_config {
      name       = "competitor-information"
      type       = "DENY"
      definition = "Questions or discussions about competitor coffee shops, their products, prices, or business practices"

      examples = [
        "What do you think about StarCoffee's new menu?",
        "How does your price compare to CoffeeBrand?",
        "Is CompetitorCafe better than you?",
        "What's the difference between you and OtherCoffeeShop?"
      ]
    }

    topics_config {
      name       = "internal-costs"
      type       = "DENY"
      definition = "Questions about internal business costs, profit margins, supplier pricing, or financial information"

      examples = [
        "What's your profit margin on lattes?",
        "How much do you pay for coffee beans?",
        "What are your operating costs?",
        "How much does milk cost you wholesale?"
      ]
    }

    topics_config {
      name       = "employee-personal-info"
      type       = "DENY"
      definition = "Requests for personal information about employees, their schedules, or private details"

      examples = [
        "What's the manager's phone number?",
        "When does Sarah work next?",
        "Where does the barista live?",
        "Give me employee contact information"
      ]
    }
  }

  # PII filters to protect sensitive information
  sensitive_information_policy_config {
    pii_entities_config {
      type   = "EMAIL"
      action = "ANONYMIZE"
    }

    pii_entities_config {
      type   = "PHONE"
      action = "ANONYMIZE"
    }

    pii_entities_config {
      type   = "CREDIT_DEBIT_CARD_NUMBER"
      action = "BLOCK"
    }

    pii_entities_config {
      type   = "CREDIT_DEBIT_CARD_CVV"
      action = "BLOCK"
    }

    pii_entities_config {
      type   = "CREDIT_DEBIT_CARD_EXPIRY"
      action = "BLOCK"
    }

    pii_entities_config {
      type   = "PIN"
      action = "BLOCK"
    }

    pii_entities_config {
      type   = "AWS_ACCESS_KEY"
      action = "BLOCK"
    }

    pii_entities_config {
      type   = "AWS_SECRET_KEY"
      action = "BLOCK"
    }

    pii_entities_config {
      type   = "PASSWORD"
      action = "BLOCK"
    }
  }

  # Word and phrase filters
  word_policy_config {
    words_config {
      text = "StarCoffee"
    }

    words_config {
      text = "CoffeeBrand"
    }

    words_config {
      text = "CompetitorCafe"
    }

    words_config {
      text = "OtherCoffeeShop"
    }

    managed_word_lists_config {
      type = "PROFANITY"
    }
  }

  tags = local.common_tags
}

# Create a version of the guardrail
resource "aws_bedrock_guardrail_version" "coffee_shop" {
  guardrail_arn = aws_bedrock_guardrail.coffee_shop.guardrail_arn
  description   = "Initial version"
}
