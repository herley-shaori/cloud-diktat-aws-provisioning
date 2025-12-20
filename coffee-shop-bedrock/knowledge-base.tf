# =============================================================================
# Bedrock Knowledge Base with OpenSearch Serverless
# =============================================================================

# -----------------------------------------------------------------------------
# OpenSearch Serverless Collection for Vector Store
# -----------------------------------------------------------------------------

resource "aws_opensearchserverless_security_policy" "encryption" {
  name = "${local.name_prefix}-encryption"
  type = "encryption"

  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/${local.name_prefix}-vectors"]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "network" {
  name = "${local.name_prefix}-network"
  type = "network"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource     = ["collection/${local.name_prefix}-vectors"]
          ResourceType = "collection"
        }
      ]
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_access_policy" "data" {
  name = "${local.name_prefix}-data-access"
  type = "data"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource     = ["collection/${local.name_prefix}-vectors"]
          ResourceType = "collection"
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
        },
        {
          Resource     = ["index/${local.name_prefix}-vectors/*"]
          ResourceType = "index"
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
        }
      ]
      Principal = [
        aws_iam_role.knowledge_base.arn,
        "arn:aws:iam::${local.account_id}:root"
      ]
    }
  ])
}

resource "aws_opensearchserverless_collection" "vectors" {
  name        = "${local.name_prefix}-vectors"
  type        = "VECTORSEARCH"
  description = "Vector store for Coffee Shop AI Knowledge Base"

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network,
    aws_opensearchserverless_access_policy.data
  ]

  tags = local.common_tags
}

# Wait for collection to be active
resource "time_sleep" "wait_for_collection" {
  depends_on      = [aws_opensearchserverless_collection.vectors]
  create_duration = "60s"
}

# -----------------------------------------------------------------------------
# Create OpenSearch Index using null_resource
# -----------------------------------------------------------------------------

resource "null_resource" "create_opensearch_index" {
  depends_on = [time_sleep.wait_for_collection]

  triggers = {
    collection_endpoint = aws_opensearchserverless_collection.vectors.collection_endpoint
  }

  provisioner "local-exec" {
    command     = "${abspath(path.module)}/.venv/Scripts/python.exe ${abspath(path.module)}/scripts/create_opensearch_index.py ${local.region} ${aws_opensearchserverless_collection.vectors.collection_endpoint} pribadi"
    interpreter = ["PowerShell", "-Command"]
  }
}

# -----------------------------------------------------------------------------
# Bedrock Knowledge Base
# -----------------------------------------------------------------------------

resource "aws_bedrockagent_knowledge_base" "coffee_shop" {
  name        = "${local.name_prefix}-knowledge-base"
  description = "Knowledge base for Coffee Shop AI containing recipes, SOPs, FAQ, and operational guides"
  role_arn    = aws_iam_role.knowledge_base.arn

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${local.region}::foundation-model/${var.embedding_model_id}"
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"

    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.vectors.arn
      vector_index_name = "bedrock-knowledge-base-default-index"

      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }

  depends_on = [
    null_resource.create_opensearch_index,
    aws_iam_role_policy.knowledge_base_s3,
    aws_iam_role_policy.knowledge_base_bedrock,
    aws_iam_role_policy.knowledge_base_aoss
  ]

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Knowledge Base Data Source (S3)
# -----------------------------------------------------------------------------

resource "aws_bedrockagent_data_source" "s3" {
  name                 = "${local.name_prefix}-s3-source"
  knowledge_base_id    = aws_bedrockagent_knowledge_base.coffee_shop.id
  data_deletion_policy = "DELETE"

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn = aws_s3_bucket.knowledge_base.arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"

      fixed_size_chunking_configuration {
        max_tokens         = 300
        overlap_percentage = 20
      }
    }
  }
}
