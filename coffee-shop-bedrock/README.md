# Coffee Shop AI Management System

AI-powered coffee shop assistant using Amazon Bedrock services for recipe guidance, inventory management, and customer service.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud (ap-southeast-1)                          │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                           Amazon Bedrock                                     ││
│  │                                                                              ││
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         ││
│  │  │   Guardrails    │    │  Barista Agent  │    │ Knowledge Base  │         ││
│  │  │                 │    │                 │    │                 │         ││
│  │  │ • Content Filter│◄───│ Claude 3 Haiku  │───►│ • Recipes       │         ││
│  │  │ • PII Protection│    │ • Instructions  │    │ • SOPs          │         ││
│  │  │ • Topic Blocks  │    │ • Action Groups │    │ • FAQ           │         ││
│  │  │ • Word Filters  │    │                 │    │ • Suppliers     │         ││
│  │  └─────────────────┘    └────────┬────────┘    │ • Troubleshoot  │         ││
│  │                                  │             └────────┬────────┘         ││
│  └──────────────────────────────────┼──────────────────────┼───────────────────┘│
│                                     │                      │                    │
│                                     ▼                      ▼                    │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐             │
│  │     Lambda      │    │ OpenSearch      │    │       S3        │             │
│  │                 │    │ Serverless      │    │                 │             │
│  │ • checkStock    │    │                 │    │ Knowledge Base  │             │
│  │ • createPO      │    │ Vector Store    │◄───│ Documents       │             │
│  │ • getQueue      │    │ (Embeddings)    │    │ (JSON files)    │             │
│  │ • getSupplier   │    │                 │    │                 │             │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘             │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

User Query Flow:
┌──────┐    ┌───────────┐    ┌─────────────┐    ┌────────────┐    ┌──────────┐
│ User │───►│ Guardrail │───►│   Agent     │───►│ Knowledge  │───►│ Response │
└──────┘    │ (Filter)  │    │ (Reasoning) │    │ Base/Lambda│    │          │
            └───────────┘    └─────────────┘    └────────────┘    └──────────┘
```

## Features

### Knowledge Base Content
- **Menu & Recipes**: 12+ drinks with detailed recipes, ingredients, and preparation steps
- **SOPs**: Opening/closing procedures, food safety guidelines, cleaning schedules
- **FAQ**: Common customer questions about hours, WiFi, menu, allergies, loyalty
- **Supplier Info**: Coffee beans, dairy, syrups, packaging suppliers
- **Troubleshooting**: Espresso machine, grinder, refrigerator issue guides

### Agent Capabilities
- Answer questions about menu and recipes
- Check inventory levels at different branches
- Create purchase orders for suppliers
- Check queue lengths and wait times
- Provide operational guidance from SOPs

### Guardrails
- **Content Filters**: Block hate speech, inappropriate content, prompt attacks
- **Topic Blocks**: Competitor information, internal costs, employee personal info
- **PII Protection**: Anonymize emails/phones, block credit card numbers
- **Word Filters**: Block competitor brand names, profanity

## Prerequisites

- **Terraform** >= 1.0.0
- **AWS CLI** configured with appropriate credentials
- **Python 3** with `boto3` and `opensearch-py` packages
- **AWS Permissions**:
  - bedrock:*
  - bedrock-agent:*
  - s3:*
  - lambda:*
  - iam:*
  - aoss:*
  - logs:*

### Install Python Dependencies

```bash
pip install boto3 opensearch-py requests-aws4auth
```

## Deployment

### 1. Initialize Terraform

```bash
cd coffee-shop-bedrock
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

**Note**: Deployment takes approximately 10-15 minutes due to:
- OpenSearch Serverless collection creation (~60 seconds)
- Knowledge Base index creation
- Agent preparation
- Data ingestion

### 4. Verify Deployment

```bash
# Get outputs
terraform output

# Check agent status
aws bedrock-agent get-agent \
  --agent-id $(terraform output -raw agent_id) \
  --region ap-southeast-1
```

## Testing the Agent

### Using API Gateway (Recommended)

```bash
# Get the API endpoint
terraform output -raw api_endpoint

# Test with curl
curl -X POST $(terraform output -raw api_endpoint) \
  -H "Content-Type: application/json" \
  -d '{"message": "How do I make a cappuccino?"}'

# With session persistence (for multi-turn conversations)
curl -X POST $(terraform output -raw api_endpoint) \
  -H "Content-Type: application/json" \
  -d '{"message": "What about a latte?", "session_id": "my-session-123"}'
```

**Request format:**
```json
{
  "message": "Your question here",
  "session_id": "optional-session-id-for-conversation"
}
```

**Response format:**
```json
{
  "response": "AI assistant response here",
  "session_id": "session-id-used"
}
```

### Using AWS CLI

```bash
# Get the test command from outputs
terraform output -raw test_agent_command

# Or manually invoke:
aws bedrock-agent-runtime invoke-agent \
  --agent-id <AGENT_ID> \
  --agent-alias-id <ALIAS_ID> \
  --session-id "test-001" \
  --input-text "What drinks do you have?" \
  --region ap-southeast-1
```

### Sample Questions to Test

**Menu & Recipes:**
```
"How do I make a cappuccino?"
"What's the difference between a latte and flat white?"
"Do you have any non-coffee drinks?"
"What's in a Caramel Macchiato?"
```

**Inventory (uses Lambda):**
```
"Check milk stock at Sudirman branch"
"What's the inventory level at Kemang?"
"Is coffee beans stock low at any branch?"
```

**Operations:**
```
"What are the opening procedures?"
"How often should I backflush the espresso machine?"
"What temperature should the fridge be?"
```

**Customer Service:**
```
"Do you have WiFi?"
"What are your opening hours?"
"Do you have vegan options?"
```

### Test Guardrails

```bash
# These should be blocked:
"What do you think about StarCoffee?"
"How much do you pay for milk?"
"What's the manager's phone number?"
```

### Check Lambda Logs

```bash
aws logs tail /aws/lambda/coffee-shop-ai-agent-actions \
  --follow \
  --region ap-southeast-1
```

## Project Structure

```
coffee-shop-bedrock/
├── main.tf              # Provider config, data sources, locals
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── iam.tf               # IAM roles and policies
├── s3.tf                # S3 bucket for knowledge base
├── knowledge-base.tf    # OpenSearch + Bedrock Knowledge Base
├── agent.tf             # Bedrock Agent configuration
├── guardrails.tf        # Content filtering and protection
├── lambda.tf            # Lambda for agent actions (inline code)
├── api-gateway.tf       # API Gateway + Lambda proxy for testing
├── data-upload.tf       # Knowledge base data (inline JSON)
└── README.md            # This file
```

## Cost Estimation

| Resource | Estimated Cost |
|----------|----------------|
| OpenSearch Serverless | ~$0.24/hour (2 OCU minimum) |
| Bedrock Claude 3 Haiku | ~$0.00025/1K input tokens |
| Bedrock Titan Embeddings | ~$0.0001/1K tokens |
| Lambda | Free tier eligible |
| API Gateway | ~$3.50/million requests |
| S3 | ~$0.023/GB |
| **Total (idle)** | **~$175/month** |

**Note**: OpenSearch Serverless has a minimum of 2 OCUs which is the primary cost driver.

## Cleanup

### Destroy All Resources

```bash
terraform destroy
```

**Important**: The destroy process will:
1. Delete all S3 objects (via destroy provisioner)
2. Delete the OpenSearch collection
3. Delete the Knowledge Base
4. Delete the Agent
5. Delete all IAM roles and policies

If destroy fails, manually empty the S3 bucket:

```bash
aws s3 rm s3://coffee-shop-ai-kb-<ACCOUNT_ID> --recursive
```

## Troubleshooting

### OpenSearch Index Creation Fails

```bash
# Check if opensearch-py is installed
pip install opensearch-py requests-aws4auth

# Verify collection is active
aws opensearchserverless batch-get-collection \
  --names coffee-shop-ai-vectors \
  --region ap-southeast-1
```

### Agent Not Responding

```bash
# Check agent status
aws bedrock-agent get-agent --agent-id <ID> --region ap-southeast-1

# Re-prepare agent
aws bedrock-agent prepare-agent --agent-id <ID> --region ap-southeast-1
```

### Knowledge Base Empty

```bash
# Trigger ingestion manually
aws bedrock-agent start-ingestion-job \
  --knowledge-base-id <KB_ID> \
  --data-source-id <DS_ID> \
  --region ap-southeast-1

# Check ingestion status
aws bedrock-agent list-ingestion-jobs \
  --knowledge-base-id <KB_ID> \
  --data-source-id <DS_ID> \
  --region ap-southeast-1
```

### Lambda Errors

```bash
# View recent logs
aws logs tail /aws/lambda/coffee-shop-ai-agent-actions \
  --since 1h \
  --region ap-southeast-1
```

## Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| Claude 3 Haiku | Cost-effective for conversational AI |
| OpenSearch Serverless | Managed vector store, scales to zero |
| Inline Lambda Code | No external files, easier deployment |
| JSON Data Format | Structured, easy to update |
| S3 for Knowledge Base | Simple, cost-effective storage |

## Limitations

- OpenSearch Serverless has minimum billing (2 OCU)
- Guardrails may have false positives on edge cases
- Knowledge base updates require re-ingestion
- Lambda cold starts may add latency on first call

## Contributing

1. Update data in `data-upload.tf`
2. Run `terraform apply`
3. Trigger knowledge base sync

## License

MIT License
