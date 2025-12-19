# =============================================================================
# API Gateway for Testing Bedrock Agent
# =============================================================================

# -----------------------------------------------------------------------------
# Lambda Function - API Proxy to Bedrock Agent
# -----------------------------------------------------------------------------

data "archive_file" "api_proxy" {
  type        = "zip"
  output_path = "${path.module}/.terraform/tmp/api_proxy.zip"

  source {
    content  = <<-PYTHON
import json
import boto3
import os

bedrock_agent = boto3.client('bedrock-agent-runtime', region_name=os.environ['AWS_REGION'])

def lambda_handler(event, context):
    """
    API Gateway proxy to Bedrock Agent.
    Accepts POST with {"message": "your question here", "session_id": "optional-session-id"}
    """
    try:
        # Parse request body
        if event.get('body'):
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        else:
            body = {}

        message = body.get('message', '')
        session_id = body.get('session_id', context.aws_request_id)

        if not message:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'error': 'Missing "message" in request body'})
            }

        # Invoke Bedrock Agent
        response = bedrock_agent.invoke_agent(
            agentId=os.environ['AGENT_ID'],
            agentAliasId=os.environ['AGENT_ALIAS_ID'],
            sessionId=session_id,
            inputText=message
        )

        # Collect streaming response
        completion = ""
        for event_stream in response['completion']:
            if 'chunk' in event_stream:
                chunk = event_stream['chunk']
                if 'bytes' in chunk:
                    completion += chunk['bytes'].decode('utf-8')

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'response': completion,
                'session_id': session_id
            })
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }
PYTHON
    filename = "index.py"
  }
}

resource "aws_lambda_function" "api_proxy" {
  function_name    = "${local.name_prefix}-api-proxy"
  description      = "API Gateway proxy to Bedrock Agent"
  role             = aws_iam_role.api_proxy_lambda.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  memory_size      = 256
  filename         = data.archive_file.api_proxy.output_path
  source_code_hash = data.archive_file.api_proxy.output_base64sha256

  environment {
    variables = {
      AGENT_ID       = aws_bedrockagent_agent.barista_assistant.id
      AGENT_ALIAS_ID = aws_bedrockagent_agent_alias.barista_assistant.agent_alias_id
    }
  }

  depends_on = [aws_bedrockagent_agent_alias.barista_assistant]

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# IAM Role for API Proxy Lambda
# -----------------------------------------------------------------------------

resource "aws_iam_role" "api_proxy_lambda" {
  name = "${local.name_prefix}-api-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "api_proxy_logs" {
  name = "cloudwatch-logs"
  role = aws_iam_role.api_proxy_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_proxy_bedrock" {
  name = "bedrock-agent-invoke"
  role = aws_iam_role.api_proxy_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeAgent"
        ]
        Resource = [
          aws_bedrockagent_agent.barista_assistant.agent_arn,
          "${aws_bedrockagent_agent.barista_assistant.agent_arn}/*"
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# API Gateway REST API
# -----------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "coffee_shop" {
  name        = "${local.name_prefix}-api"
  description = "API Gateway for Coffee Shop AI Assistant"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.common_tags
}

# /chat resource
resource "aws_api_gateway_resource" "chat" {
  rest_api_id = aws_api_gateway_rest_api.coffee_shop.id
  parent_id   = aws_api_gateway_rest_api.coffee_shop.root_resource_id
  path_part   = "chat"
}

# POST /chat
resource "aws_api_gateway_method" "chat_post" {
  rest_api_id   = aws_api_gateway_rest_api.coffee_shop.id
  resource_id   = aws_api_gateway_resource.chat.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "chat_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.coffee_shop.id
  resource_id             = aws_api_gateway_resource.chat.id
  http_method             = aws_api_gateway_method.chat_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_proxy.invoke_arn
}

# OPTIONS /chat (CORS)
resource "aws_api_gateway_method" "chat_options" {
  rest_api_id   = aws_api_gateway_rest_api.coffee_shop.id
  resource_id   = aws_api_gateway_resource.chat.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "chat_options" {
  rest_api_id = aws_api_gateway_rest_api.coffee_shop.id
  resource_id = aws_api_gateway_resource.chat.id
  http_method = aws_api_gateway_method.chat_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "chat_options" {
  rest_api_id = aws_api_gateway_rest_api.coffee_shop.id
  resource_id = aws_api_gateway_resource.chat.id
  http_method = aws_api_gateway_method.chat_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "chat_options" {
  rest_api_id = aws_api_gateway_rest_api.coffee_shop.id
  resource_id = aws_api_gateway_resource.chat.id
  http_method = aws_api_gateway_method.chat_options.http_method
  status_code = aws_api_gateway_method_response.chat_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# -----------------------------------------------------------------------------
# API Gateway Deployment
# -----------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "coffee_shop" {
  rest_api_id = aws_api_gateway_rest_api.coffee_shop.id

  depends_on = [
    aws_api_gateway_integration.chat_lambda,
    aws_api_gateway_integration.chat_options
  ]

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.chat.id,
      aws_api_gateway_method.chat_post.id,
      aws_api_gateway_integration.chat_lambda.id,
      aws_api_gateway_method.chat_options.id,
      aws_api_gateway_integration.chat_options.id,
    ]))
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.coffee_shop.id
  rest_api_id   = aws_api_gateway_rest_api.coffee_shop.id
  stage_name    = "prod"

  tags = local.common_tags
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_proxy.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.coffee_shop.execution_arn}/*/*"
}
