# =============================================================================
# Lambda Function
# =============================================================================

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/warung_kopi.py"
  output_path = "${path.module}/lambda_warung_kopi.zip"
}

resource "aws_lambda_function" "warung_kopi" {
  function_name    = "${var.agent_name}-handler"
  description      = "Lambda handler for Warung Kopi Bedrock Agent"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "warung_kopi.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = 30
  memory_size      = 128
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.warung_kopi.function_name}"
  retention_in_days = 7

  tags = local.common_tags
}
