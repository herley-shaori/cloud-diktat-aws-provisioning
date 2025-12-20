# =============================================================================
# Data Upload to S3 for Knowledge Base
# =============================================================================
# All coffee shop data is defined in scripts/upload_knowledge_data.py
# =============================================================================

resource "null_resource" "upload_knowledge_data" {
  depends_on = [
    aws_s3_bucket.knowledge_base,
    aws_s3_bucket_versioning.knowledge_base,
    aws_s3_bucket_policy.knowledge_base
  ]

  triggers = {
    bucket_id    = aws_s3_bucket.knowledge_base.id
    data_version = "v1.0.0" # Change this to re-upload data
    region       = local.region
  }

  provisioner "local-exec" {
    command     = "${abspath(path.module)}/.venv/Scripts/python.exe ${abspath(path.module)}/scripts/upload_knowledge_data.py ${local.region} ${aws_s3_bucket.knowledge_base.id} pribadi"
    interpreter = ["PowerShell", "-Command"]
  }

  # CRITICAL: Delete all objects before bucket destruction
  provisioner "local-exec" {
    when        = destroy
    command     = "${abspath(path.module)}/.venv/Scripts/python.exe ${abspath(path.module)}/scripts/delete_s3_objects.py ${self.triggers.region} ${self.triggers.bucket_id} pribadi"
    interpreter = ["PowerShell", "-Command"]
  }
}

# -----------------------------------------------------------------------------
# Sync Knowledge Base after data upload
# -----------------------------------------------------------------------------

resource "null_resource" "sync_knowledge_base" {
  depends_on = [
    null_resource.upload_knowledge_data,
    aws_bedrockagent_data_source.s3
  ]

  triggers = {
    data_source_id    = aws_bedrockagent_data_source.s3.data_source_id
    knowledge_base_id = aws_bedrockagent_knowledge_base.coffee_shop.id
    data_version      = null_resource.upload_knowledge_data.triggers.data_version
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "Write-Host 'Starting knowledge base sync...'; aws bedrock-agent start-ingestion-job --knowledge-base-id ${aws_bedrockagent_knowledge_base.coffee_shop.id} --data-source-id ${aws_bedrockagent_data_source.s3.data_source_id} --region ${local.region} --profile pribadi; Write-Host 'Ingestion job started. It may take a few minutes to complete.'"
  }
}
