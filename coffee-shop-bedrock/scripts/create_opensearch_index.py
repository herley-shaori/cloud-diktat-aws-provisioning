#!/usr/bin/env python3
"""Create OpenSearch index for Bedrock Knowledge Base."""
import sys
import boto3
from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth

region = sys.argv[1]
collection_endpoint = sys.argv[2]
profile = sys.argv[3] if len(sys.argv) > 3 else None

# Get credentials
session = boto3.Session(profile_name=profile, region_name=region)
credentials = session.get_credentials()
auth = AWSV4SignerAuth(credentials, region, "aoss")

# Connect to OpenSearch Serverless
host = collection_endpoint.replace("https://", "")
client = OpenSearch(
    hosts=[{"host": host, "port": 443}],
    http_auth=auth,
    use_ssl=True,
    verify_certs=True,
    connection_class=RequestsHttpConnection,
    timeout=300
)

# Create index with vector field
index_name = "bedrock-knowledge-base-default-index"
index_body = {
    "settings": {
        "index": {
            "knn": True,
            "knn.algo_param.ef_search": 512
        }
    },
    "mappings": {
        "properties": {
            "bedrock-knowledge-base-default-vector": {
                "type": "knn_vector",
                "dimension": 1536,
                "method": {
                    "name": "hnsw",
                    "space_type": "l2",
                    "engine": "faiss",
                    "parameters": {
                        "ef_construction": 512,
                        "m": 16
                    }
                }
            },
            "AMAZON_BEDROCK_METADATA": {"type": "text", "index": False},
            "AMAZON_BEDROCK_TEXT_CHUNK": {"type": "text"}
        }
    }
}

try:
    if not client.indices.exists(index=index_name):
        response = client.indices.create(index=index_name, body=index_body)
        print(f"Index created: {response}")
    else:
        print("Index already exists")
except Exception as e:
    print(f"Error creating index: {e}")
    # Index might already exist, continue
